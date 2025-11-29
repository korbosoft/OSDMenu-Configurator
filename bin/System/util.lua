function ifBool(bool, on, off)
  return bool and on or off
end

function manual_gsub(s, pattern, replacement) -- using gsub the way i was in doKeyboard had been causing a buffer overflow
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

--[[
switch (x) {
  [1] = function()
    print "Case 1."
  end,
  [2] = function()
    print "Case 2."
  end,
  [3] = function()
    print "Case 3."
  end,
  __index = function()
    print "Case default."
  end
}
--]]

function switch(value)
	return function(cases)

		setmetatable(cases, cases)

		local f = cases[value]
		if f then
			f()
		end
	end
end

function LoadImageHelper(path)
--- Intellisense will warn us if we use images without checking if the load failed
local I = Graphics.loadImage(path)
if I == nil then error("failed to load image\n\nPath:"..path) end
  return I
end
