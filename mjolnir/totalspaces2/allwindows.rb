require 'totalspaces2'

# Get list of windows TotalSpaces knows about
windows = TotalSpaces2.window_list
window_ids = []

# Loop through all of them and get their window ids.
windows.each do|win|
  window_ids.push(win[:window_id])
end

# Output comma separated list of window ids.
puts window_ids.join(',')

