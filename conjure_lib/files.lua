require "json"

-- Read entire file into string.
function slurp(path)
  local f = io.open(path)
  local s = f:read("*a")
  f:close()
  return s
end

-- Write a table to the given file.
-- There are a lot of things this doesn't support, since it's just json - no functions, etc.
function save_table(table, filepath)
  file = io.open(filepath, "w")
  file:write(json.encode_table(table))
  file:close()
end