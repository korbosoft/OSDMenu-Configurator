function ifBool(bool, on, off)
  return bool and on or off
end

function ifTable(index, values)
  return values[index]
end

partition_list = {}

function mount_hdd()
  local partitions = System.listDirectory("hdd0:/")
  for i = 1, #partitions do
    System.fileXioMount("hdd0:" .. partitions[i].name , "part" .. i .. ":", FIO_MT_RDWR)
    partition_list[partitions[i].name] = i
  end
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
