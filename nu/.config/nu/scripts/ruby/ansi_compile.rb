#!/usr/bin/env ruby

class AnsiCompile
  def initialize(width = 120, height = 1000)
    @width = width
    @height = height
    @buffer = Array.new(height) { Array.new(width, ' ') }
    @cursor_x = 0
    @cursor_y = 0
    @saved_cursor_x = 0
    @saved_cursor_y = 0
  end

  def process_io(input_io = $stdin, output_io = $stdout)
    input = input_io.read
    process_text(input)
    output_io.write(to_s)
  end

  def process_text(text)
    parts = text.scan(/(\e\[[0-9;]*[A-Za-z]|\e\[\?[0-9;]*[A-Za-z]|\r|\n|[^\e\r\n]+)/)
    parts.each do |part|
      part = part[0]  # Extract from scan group
      if part.start_with?("\e[")
        process_ansi_sequence(part)
      elsif part == "\r"
        @cursor_x = 0
      elsif part == "\n"
        @cursor_y += 1
        @cursor_x = 0
      else
        write_text(part)
      end
    end
  end

  def write_text(text)
    text.each_char do |char|
      if @cursor_x < @width && @cursor_y < @height
        # Handle character overwrites
        @buffer[@cursor_y][@cursor_x] = char
        @cursor_x += 1
      end
      
      # Handle line wrapping
      if @cursor_x >= @width
        @cursor_x = 0
        @cursor_y += 1
      end

      # Handle scrolling
      if @cursor_y >= @height
        @buffer.shift
        @buffer.push(Array.new(@width, ' '))
        @cursor_y = @height - 1
      end
    end
  end

  def process_ansi_sequence(sequence)
    case sequence
    when /\e\[(\d+)?A/  # Cursor Up
      count = ($1 || 1).to_i
      @cursor_y = [@cursor_y - count, 0].max
    when /\e\[(\d+)?B/  # Cursor Down
      count = ($1 || 1).to_i
      @cursor_y = [@cursor_y + count, @height - 1].min
    when /\e\[(\d+)?C/  # Cursor Forward
      count = ($1 || 1).to_i
      @cursor_x = [@cursor_x + count, @width - 1].min
    when /\e\[(\d+)?D/  # Cursor Back
      count = ($1 || 1).to_i
      @cursor_x = [@cursor_x - count, 0].max
    when /\e\[(\d+)?G/  # Cursor Horizontal Absolute
      column = ($1 || 1).to_i
      @cursor_x = [column - 1, 0].max
    when /\e\[(\d+);(\d+)H/, /\e\[(\d+);(\d+)f/  # Cursor Position
      row = $1.to_i
      column = $2.to_i
      @cursor_y = [row - 1, 0].max
      @cursor_x = [column - 1, 0].max
    when /\e\[H/, /\e\[f/  # Cursor Home
      @cursor_x = 0
      @cursor_y = 0
    when /\e\[(\d+)?J/  # Erase in Display
      mode = ($1 || 0).to_i
      case mode
      when 0  # Clear from cursor to end of screen
        @buffer[@cursor_y][@cursor_x..-1] = Array.new(@width - @cursor_x, ' ')
        (@cursor_y + 1...@height).each do |y|
          @buffer[y] = Array.new(@width, ' ')
        end
      when 1  # Clear from cursor to beginning of screen
        (0...@cursor_y).each do |y|
          @buffer[y] = Array.new(@width, ' ')
        end
        @buffer[@cursor_y][0..@cursor_x] = Array.new(@cursor_x + 1, ' ')
      when 2, 3  # Clear entire screen
        @buffer = Array.new(@height) { Array.new(@width, ' ') }
      end
    when /\e\[(\d+)?K/  # Erase in Line
      mode = ($1 || 0).to_i
      case mode
      when 0  # Clear from cursor to end of line
        @buffer[@cursor_y][@cursor_x..-1] = Array.new(@width - @cursor_x, ' ')
      when 1  # Clear from cursor to beginning of line
        @buffer[@cursor_y][0..@cursor_x] = Array.new(@cursor_x + 1, ' ')
      when 2  # Clear entire line
        @buffer[@cursor_y] = Array.new(@width, ' ')
      end
    when /\e\[s/  # Save Cursor Position
      @saved_cursor_x = @cursor_x
      @saved_cursor_y = @cursor_y
    when /\e\[u/  # Restore Cursor Position
      @cursor_x = @saved_cursor_x
      @cursor_y = @saved_cursor_y
    when /\e\[\?25[hl]/  # Hide/Show cursor - ignore
    when /\e\[\d*[mK]/   # Color/Style/Clear line - ignore for now
    end
  end

  def to_s
    # Remove trailing empty lines
    last_non_empty = @buffer.rindex { |line| line.any? { |char| char != ' ' } } || 0
    @buffer[0..last_non_empty].map(&:join).join("\n")
  end
end

if __FILE__ == $PROGRAM_NAME
  begin
    terminal = AnsiCompile.new(200, $stdin.read.lines.count)
    terminal.process_io
  rescue => e
    warn "Error: #{e.message}"
    exit 1
  end
end
