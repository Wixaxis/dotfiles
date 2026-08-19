#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "socket"
require "time"
require "uri"

UPSTREAM_BASE = URI("https://opencode.ai/zen/go/v1")
PORT = Integer(ENV.fetch("RAYCAST_OPENCODE_GO_PROXY_PORT", "4127"))
HOP_BY_HOP_HEADERS = %w[connection content-length host transfer-encoding].freeze
LOG_PATH = ENV.fetch("RAYCAST_OPENCODE_GO_PROXY_LOG", "/tmp/raycast-opencode-go-proxy.requests.log")

def upstream_uri(path)
  clean_path = path.sub(%r{\A/v1/?}, "")
  URI.join("#{UPSTREAM_BASE}/", clean_path)
end

def read_request(socket)
  header = +""
  header << socket.readpartial(1024) until header.include?("\r\n\r\n")
  raw_headers, body = header.split("\r\n\r\n", 2)
  lines = raw_headers.lines(chomp: true)
  method, target = lines.shift.split(" ", 3)
  headers = {}
  lines.each do |line|
    name, value = line.split(":", 2)
    headers[name.downcase] = value.strip if name && value
  end

  content_length = headers.fetch("content-length", "0").to_i
  body ||= +""
  body << socket.read(content_length - body.bytesize).to_s if body.bytesize < content_length

  [method, target, headers, body]
end

def write_headers(socket, status, headers)
  reason = status == 200 ? "OK" : "Upstream"
  socket.write "HTTP/1.1 #{status} #{reason}\r\n"
  headers.each { |name, value| socket.write "#{name}: #{value}\r\n" }
  socket.write "\r\n"
end

def write_chunk(socket, data)
  return if data.empty?

  socket.write "#{data.bytesize.to_s(16)}\r\n"
  socket.write data
  socket.write "\r\n"
end

def forward_request(method, target, headers, body, socket)
  path, query = target.split("?", 2)
  uri = upstream_uri(path)
  uri.query = query
  log_request_shape(path, body) if method == "POST" && path.end_with?("/chat/completions")

  request_class = Net::HTTP.const_get(method.capitalize)
  upstream_request = request_class.new(uri)
  headers.each do |name, value|
    next if HOP_BY_HOP_HEADERS.include?(name)

    upstream_request[name] = value
  end
  upstream_request.body = body unless body.empty?

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 600) do |http|
    http.request(upstream_request) do |upstream_response|
      response_headers = {}
      upstream_response.each_header do |name, value|
        next if HOP_BY_HOP_HEADERS.include?(name.downcase)

        response_headers[name] = value
      end

      if upstream_response["content-type"].to_s.include?("text/event-stream")
        response_headers["transfer-encoding"] = "chunked"
        write_headers(socket, upstream_response.code.to_i, response_headers)
        stream_filtered(upstream_response, socket)
        socket.write "0\r\n\r\n"
      else
        payload = upstream_response.body.to_s
        response_headers["content-length"] = payload.bytesize.to_s
        write_headers(socket, upstream_response.code.to_i, response_headers)
        socket.write payload
      end
    end
  end
end

def log_request_shape(path, body)
  payload = JSON.parse(body)
  messages = Array(payload["messages"]).map do |message|
    content = message["content"]
    content_summary =
      if content.is_a?(Array)
        content.map do |part|
          case part["type"]
          when "text"
            { type: "text", chars: part["text"].to_s.length }
          when "image_url"
            url = part.dig("image_url", "url").to_s
            { type: "image_url", scheme: url[/\A[^:]+/], chars: url.length }
          else
            { type: part["type"].to_s, keys: part.keys }
          end
        end
      else
        { type: content.class.name, chars: content.to_s.length }
      end

    { role: message["role"], content: content_summary }
  end

  File.open(LOG_PATH, "a") do |file|
    file.puts JSON.generate(
      at: Time.now.utc.iso8601,
      path: path,
      model: payload["model"],
      stream: payload["stream"],
      messages: messages
    )
  end
rescue StandardError => e
  File.open(LOG_PATH, "a") { |file| file.puts JSON.generate(at: Time.now.utc.iso8601, path: path, log_error: e.message) }
end

def stream_filtered(upstream_response, socket)
  buffer = +""
  done_seen = false

  upstream_response.read_body do |chunk|
    buffer << chunk
    while (idx = buffer.index("\n\n"))
      event = buffer.slice!(0, idx + 2)
      data = event.lines.grep(/^data:/).map { |line| line.sub(/^data:\s?/, "").strip }.join("\n")

      next if done_seen

      write_chunk(socket, event)
      done_seen = true if data == "[DONE]"
    end
  end

  write_chunk(socket, buffer) unless done_seen || buffer.empty?
end

server = TCPServer.new("127.0.0.1", PORT)
warn "raycast-opencode-go-proxy listening on 127.0.0.1:#{PORT}"

loop do
  client = server.accept
  Thread.new(client) do |socket|
    begin
      method, target, headers, body = read_request(socket)
      forward_request(method, target, headers, body, socket)
    rescue StandardError => e
      payload = JSON.generate(error: { message: e.message, type: e.class.name })
      write_headers(socket, 500, "content-type" => "application/json", "content-length" => payload.bytesize.to_s)
      socket.write payload
    ensure
      socket.close
    end
  end
end
