require 'totalspaces2'

# Prime the pump, so to speak.
TotalSpaces2.window_list

# Move this window to that Space.
TotalSpaces2.move_window_to_space(ARGV[0].to_i, ARGV[1].to_i)
