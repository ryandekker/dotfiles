require 'totalspaces2'

# Primes the pump, so to speak.
windows = TotalSpaces2.window_list

# Get the window id we're looking up from the passed arg.
window_id = ARGV[0].to_i

# Only output a value if there is one.
if !windows.empty?
  current_space_windows = windows.select {|window| window[:window_id] == window_id}
  puts current_space_windows[0][:space_number]
end
