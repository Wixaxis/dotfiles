#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

store_file_path = '/home/wixaxis/scripts/stored_brightness.txt'
curr = -> { /current value\s*=\s*(\d+)/.match(`ddcutil -d 1 getvcp 10`)[1].to_i }
set = ->(value) { `ddcutil -d 1 setvcp 10 #{value} --noverify --disable-dynamic-sleep --sleep-multiplier .2` }
store = -> { File.write(store_file_path, curr.call.to_s) }
restore = -> { set.call(File.read(store_file_path).to_i) if File.exist?(store_file_path) }
my_clamp = ->(value, min: 0, max: 100) { [min, [value, max].min].max }

reduced_op = lambda do
  case ARGV.first
  when '+', 'increase', 'add', 'plus'       then '+'
  when '-', 'decrease', 'subtract', 'minus' then '-'
  when '?', 'get', 'check'                  then '?'
  when '!', 'sync', 'synchronize'           then '!'
  when 'min'                                then 'min'
  when 'max'                                then 'max'
  when 'dim'                                then 'dim'
  when 'restore'                            then 'restore'
  else '='; end
end

new_value = lambda do
  my_clamp.call(case reduced_op.call
                when '+' then curr.call + (ARGV[1]&.to_i || 10)
                when '-' then curr.call - (ARGV[1]&.to_i || 10)
                else ARGV[1]&.to_i || ARGV[0]&.to_i || 100
                end)
end

case reduced_op.call
when '?'       then puts "#{curr.call}%"
when '!'       then sync.call
when 'max'     then set.call(100) && store.call
when 'min'     then set.call(0) && store.call
when 'dim'     then set.call(0)
when 'restore' then restore.call
else set.call(new_value.call) && store.call; end
