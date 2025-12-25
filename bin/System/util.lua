function ifBool(bool, on, off)
  return bool and on or off
end

function ifTable(index, values)
  return values[index]
end

mounted_partition = nil;

function mount_pfs(name)
--   local partitions = System.listDirectory("hdd0:/")
  if name == mounted_partition then return 0 end
  System.fileXioUmount("pfs1:")
  System.fileXioMount("pfs1:", "hdd0:" .. name)
  print(type(System.listDirectory("pfs1:/")))
  if not System.listDirectory("pfs1:/") then
    System.fileXioUmount("pfs1:")
    if mounted_partition then
      System.fileXioMount("pfs1:", "hdd0:" .. mounted_partition)
    end
    return -1
  end
  mounted_partition = name
  return 0
end

function get_mounted_partition()
  return mounted_partition
end

function manual_gsub(s, pattern, replacement) -- using gsub the way i was in doKeyboard was causing a buffer overflow
  local result = ""
  local last_pos = 1
  while true do
    local start_pos, end_pos = string.find(s, pattern, last_pos)
    if not start_pos then
      result = result .. string.sub(s, last_pos)
      break
    end
    result = result .. string.sub(s, last_pos, start_pos - 1) .. replacement
    last_pos = end_pos + 1
  end
  return result
end

function LoadImageHelper(path)
  --- Intellisense will warn us if we use images without checking if the load failed
  local I = Graphics.loadImage(path)
  if I == nil then error("failed to load image\n\nPath:"..path) end
    return I
end

function checkDevice(path)
  return ifBool(System.listDirectory(path) ~= nil, true, false)
end
