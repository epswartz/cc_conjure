-- Utility functions for working with tables

-- Get length of table (number of entries).
function len(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- copy table.
function clone(T)
    return {table.unpack(T)}
  end