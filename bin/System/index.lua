dofile("System/util.lua");
dofile("System/config.lua");
dofile("System/generator.lua");

Font.fmLoad()

function dummy()
  Screen.clear()
  Font.fmPrint(32, 32, 2, "SORRY NOTHING")
  Screen.flip()
  while 1 do end
end

circle = LoadImageHelper("assets/circle.png")
cross = LoadImageHelper("assets/cross.png")
square = LoadImageHelper("assets/square.png")
triangle = LoadImageHelper("assets/triangle.png")

-- up = LoadImageHelper("assets/up.png")
-- down = LoadImageHelper("assets/down.png")
-- left = LoadImageHelper("assets/left.png")
-- right = LoadImageHelper("assets/right.png")

start = LoadImageHelper("assets/start.png")
pad_select = LoadImageHelper("assets/select.png")

l1 = LoadImageHelper("assets/L1.png")
r1 = LoadImageHelper("assets/R1.png")

-- l2 = LoadImageHelper("assets/L2.png")
-- l2 = LoadImageHelper("assets/R2.png")
--
-- l3 = LoadImageHelper("assets/L3.png")
-- r3 = LoadImageHelper("assets/R3.png")

disabled_selected_color = Color.new(128, 128, 128, 128)
error_color = Color.new(255, 90, 90, 128)
disabled_unselected_color = Color.new(64, 64, 64, 64)

screen_mode = Screen.getMode()

pad, last_pad = nil

ret = nil

osdmenu_variant = 0

Control_sets = {
  ENTER_BACK = {
    {x = 32, y = -64, label = "  Enter", icons = {{tex = cross}}},
    {x = -144, y = -64, label = "  Back", icons = {{tex = circle}}}
  },
  DIR_TREE = {
    {x = 32, y = -64, label = "  Enter", icons = {{tex = cross}}},
    {x = -112, y = -64, label = "  Up", icons = {{tex = triangle}}}
  },
  KEY_INPUT = {
    {x = 32, y = -64, label = "  Enter", icons = {{tex = cross}}},
    {x = -208, y = -64, label = "  Cancel", icons = {{tex = circle}}},
    {x = -214, y = 32, label = "    Cursor", icons = {{tex = l1}, {tex = r1, x = -177.6}}}
  },
  OK = {
    {x = 32, y = -64, label = "  OK", icons = {{tex = cross}}}
  }
}

Exit_type = {
  NEW_MENU = 0,
  FUNCTION = 1,
  REPEAT = 2
}

Menu_ids = {
  ROOT = 1,
  OSDMENU = 2,
  OSDSYS = 3,
  PS1 = 4,
  MENU_ITEMS = 5
}

function showControls(control_set)
  for i = 1, #control_set do
    Font.fmPrint(
      ifBool(control_set[i].x < 0, screen_mode.width + control_set[i].x, control_set[i].x),
      ifBool(control_set[i].y < 0, screen_mode.height + control_set[i].y, control_set[i].y),
      1,
      control_set[i].label
    )
    for j = 1, #control_set[i].icons do
      local x = ifBool(control_set[i].icons[j].x, control_set[i].icons[j].x, control_set[i].x)
      local y = ifBool(control_set[i].icons[j].y, control_set[i].icons[j].y, control_set[i].y)

      if x < 0 then x = screen_mode.width + x end
      if y < 0 then y = screen_mode.height + y end

      Graphics.drawImage(
        control_set[i].icons[j].tex,
        x,
        y - 4
      )
    end
  end
end

function getPad()
  last_pad = ifBool(not pad, Pads.get(), pad)
  pad = Pads.get()
end

function breakString(index, str)
  if not str then return "" end
  if index <= #str + 1 then str = str:sub(1, index - 1) .. "\n" .. str:sub(index, -1) end
  return str
end

function doNumpad(title, starting_num, signed)
  local exit = false
  local num = starting_num
  local str
  if num and (num ~= -math.huge) and (num ~= math.huge) then
    str = string.format("%.f", num)
  else
    str = "";
  end

  local keys = {
    "123",
    "456",
    "789",
    "-0.",
    "\2\0\0"
  }

  local selected_key = 1
  local exit = false
  local cursor = #str+1
  repeat
    repeat
      Screen.clear()

      Font.fmPrint(32, 32, 1, title, OSDSYS_selected_color)
      Font.fmPrint(32, 80, 0.5, breakString(63, str))
      Font.fmPrint(32, 80, 0.5, breakString(63, string.rep(" ", cursor - 1) .. "_"))

      for y = 0, 4 do
        for x = 1, 3 do
          local current_key = y * 3 + x
          if current_key == 13 then
            Font.fmPrint(50.2, 320, 1, "\f0104", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          elseif current_key == 14 then
            Font.fmPrint(4.7 + 45.83333333 * 2, 320, 1, "OK", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          elseif current_key == 15 then
          else
            if (current_key == 10) and signed or current_key ~= 10 then
              Font.fmPrint(32 + 45.83333333 * (x - 1), 128 + 48 * y, 1, string.sub(keys[y+1], x, x), ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
            end
          end
        end
      end

      showControls(Control_sets.KEY_INPUT)

      getPad()

      if Pads.check(pad, PAD_UP) and not Pads.check(last_pad, PAD_UP) then
        if selected_key > 3 then selected_key = selected_key - 3 end
      end

      if Pads.check(pad, PAD_DOWN) and not Pads.check(last_pad, PAD_DOWN) then
        if selected_key < 13 then selected_key = selected_key + 3 end
      end

      if Pads.check(pad, PAD_LEFT) and not Pads.check(last_pad, PAD_LEFT) then
        if selected_key > 1 then selected_key = selected_key - 1 end
      end

      if Pads.check(pad, PAD_RIGHT) and not Pads.check(last_pad, PAD_RIGHT) then
        if selected_key < 14 then selected_key = selected_key + 1 end
      end

      if (selected_key == 10) and (signed == false) then selected_key = 11 end
      if selected_key == 15 then selected_key = 14 end

      if Pads.check(pad, PAD_L1) and not Pads.check(last_pad, PAD_L1) then
        if cursor > 1 then cursor = cursor - 1 end
      end

      if Pads.check(pad, PAD_R1) and not Pads.check(last_pad, PAD_R1) then
        if cursor < #str+1 then cursor = cursor + 1 end
      end

      Screen.flip()
      if Pads.check(pad, PAD_CIRCLE) and not Pads.check(last_pad, PAD_CIRCLE) then return starting_num end
    until Pads.check(pad, PAD_CROSS) and not Pads.check(last_pad, PAD_CROSS)

    local x = (selected_key - 1) % 3 + 1
    local y = (selected_key - 1) // 3 + 1

    local character = keys[y]:sub(x, x)
    if character == "\0" then
      exit = true
    else
      if character == "\2" then
        if cursor > 1 then
          str = str:sub(1, cursor - 2) .. str:sub(cursor)
          cursor = cursor - 1
        end
      else
        if #str < 124 then
          str = str:sub(1, cursor - 1) .. character .. str:sub(cursor)
          cursor = cursor + 1
        end
      end
    end

  until exit

  num = tonumber(str)
  if num and (num ~= -math.huge) and (num ~= math.huge) then
    return num
  end
  return starting_num
end

function doKeyboard(title, starting_str, special)
  local exit = false

  local keys = {
    { -- layer 1
      "`1234567890-=",
      "qwertyuiop[]\\",
      "asdfghjkl;'\2\0",
      "\1zxcvbnm,./ \7"
    },
    { -- layer 2
      "~!@#$%^&*()_+",
      "QWERTYUIOP{}|",
      "ASDFGHJKL:\"\2\0",
      "\1ZXCVBNM<>? \7"
    }
  }

  local selected_key = 1
  local shift_mode = 0
  local layer
  local exit = false
  if starting_str then
    local str = starting_str
  end
  local cursor = #str+1
  repeat
  layer = (shift_mode > 0 and 1 or 0) + 1
    repeat
      Screen.clear() -- 794 for hollow up arrow, 798 for filled up arrow, 104 for thin left arrow

      Font.fmPrint(32, 32, 1, title, OSDSYS_selected_color)
      local display_str = manual_gsub(breakString(63, str), "\7", "\f0089")
      Font.fmPrint(32, 80, 0.5, display_str)
      Font.fmPrint(32, 80, 0.5, breakString(63, string.rep(" ", cursor - 1) .. "_"))

      for y = 0, 3 do
        for x = 1, 13 do
          local current_key = y * 13 + x
          if current_key == 38 then
            Font.fmPrint(32 + 45.83333333 * 11, 256, 1, "\f0104", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          elseif current_key == 39 then
            Font.fmPrint(22.9 + 45.83333333 * 12, 256, 1, "OK", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          elseif current_key == 40 then
            if layer == 2 then
              Font.fmPrint(32, 320, 1, "\f0798", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
            else
              Font.fmPrint(32, 320, 1, "\f0794", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
            end
            if shift_mode == 2 then Font.fmPrint(32, 320, 1, "\f0017", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color)) end
          elseif current_key == 51 then
            Font.fmPrint(22.9 + 45.83333333 * 11, 320, 1, "SP", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          elseif (current_key == 52) and (special == true) then
            Font.fmPrint(32 + 45.83333333 * 12, 320, 1, "\f0089", ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          else
            Font.fmPrint(32 + 45.83333333 * (x - 1), 128 + 64 * y, 1, string.sub(keys[layer][y+1], x, x), ifBool(current_key == selected_key, OSDSYS_selected_color, OSDSYS_unselected_color))
          end
        end
      end

      showControls(Control_sets.KEY_INPUT)

      getPad()

      if Pads.check(pad, PAD_UP) and not Pads.check(last_pad, PAD_UP) then
        if selected_key > 13 then selected_key = selected_key - 13 end
      end

      if Pads.check(pad, PAD_DOWN) and not Pads.check(last_pad, PAD_DOWN) then
        if selected_key < 40 then selected_key = selected_key + 13 end
      end

      if Pads.check(pad, PAD_LEFT) and not Pads.check(last_pad, PAD_LEFT) then
        if selected_key > 1 then selected_key = selected_key - 1 end
      end

      if Pads.check(pad, PAD_RIGHT) and not Pads.check(last_pad, PAD_RIGHT) then
        if selected_key < 52 then selected_key = selected_key + 1 end
      end

      if Pads.check(pad, PAD_L1) and not Pads.check(last_pad, PAD_L1) then
        if cursor > 1 then cursor = cursor - 1 end
      end

      if Pads.check(pad, PAD_R1) and not Pads.check(last_pad, PAD_R1) then
        if cursor < #str+1 then cursor = cursor + 1 end
      end

      if (selected_key == 52) and (special == false) then selected_key = 51 end

      Screen.flip()
      if Pads.check(pad, PAD_CIRCLE) and not Pads.check(last_pad, PAD_CIRCLE) then return starting_str end
    until Pads.check(pad, PAD_CROSS) and not Pads.check(last_pad, PAD_CROSS)

    local x = (selected_key - 1) % 13 + 1
    local y = (selected_key - 1) // 13 + 1

    local character = keys[y]:sub(x, x)
    if character == "\0" then
      exit = true
    elseif character == "\1" then
      if shift_mode == 1 then
        shift_mode = 2
      elseif shift_mode == 2 then
        shift_mode = 0
      else
        shift_mode = 1
      end
    else
      if character == "\2" then
        if cursor > 1 then
          str = str:sub(1, cursor - 2) .. str:sub(cursor)
          cursor = cursor - 1
        end
      else
        if #str < 124 then
          str = str:sub(1, cursor - 1) .. character .. str:sub(cursor)
          cursor = cursor + 1
        end
      end
    end

  until exit

  str = str:gsub("\7\7\7\7\7","\7")
  if (str == "") or (not str) then
    return starting_str
  end
  return str
end

function doFileSelect(title, starting_dir)
  local dir = starting_dir
  local ret
  repeat
    if dir then
      last_dir = System.currentDirectory()
      print(last_dir)
      System.currentDirectory(dir)
      dir_path = System.currentDirectory()
    end
    if (not dir) or (dir_path == last_dir) then
      local ret = doTextMenu(title, {
        {"mc0:/", "Memory Card 1", checkDevice("mc0:/")},
        {"mc1:/", "Memory Card 2", checkDevice("mc1:/")},
        {"hdd0:/", "Expansion Bay Storage", checkDevice("hdd0:/")},
      }, 1)
      if ret == 0 then
        return nil
      elseif ret == 1 then
        dir = "mc0:/"
      elseif ret == 2 then
        dir = "mc1:/"
      elseif ret == 3 then
        dir = "hdd0:/"
      end
    end
--     dir = dir:gsub("")
    System.currentDirectory(dir)
    ret = doFileMenu(title, System.listDirectory(), System.currentDirectory(), (dir:sub(1, 3) == "hdd") or (dir:sub(1, 4) == "part"))
    if ret[2] then
      dir = ret[1]
    else
      return ret[1]
    end
  until false
end

function doFileMenu(title, dir, path, hdd)
  local item_count = #dir

  local seperator = ifBool(hdd, "\\", "/")

  local selected_item = 0
  local current_item = 0

  repeat
    local y = 112
    Screen.clear()

    Font.fmPrint(32, 32, 1, title, OSDSYS_selected_color)
    Font.fmPrint(32, y - 16, 0.5, "../", ifBool(selected_item == 0, OSDSYS_selected_color, OSDSYS_unselected_color))
    for i = ifBool(dir[1].name == ".", 3, 1), 16 do
      if i <= item_count then
        Font.fmPrint(32, y, 0.5, ifBool(dir[i].directory, dir[i].name .. "/", dir[i].name), ifBool(selected_item == i, OSDSYS_selected_color, OSDSYS_unselected_color))
        y = y + 16
      end
    end

    Font.fmPrint(32, screen_mode.height - 96, 0.5, path)
    showControls(Control_sets.DIR_TREE)

    getPad()

    if Pads.check(pad, PAD_UP) and not Pads.check(last_pad, PAD_UP) then
      if selected_item > 0 then selected_item = selected_item - 1 end
    end

    if Pads.check(pad, PAD_DOWN) and not Pads.check(last_pad, PAD_DOWN) then
      if selected_item < item_count then selected_item = selected_item + 1 end
    end

    if dir[1].name == "." then
      if selected_item == 1 then selected_item = 3 end
      if selected_item == 2 then selected_item = 0 end
    end

    Screen.flip()

    if Pads.check(pad, PAD_TRIANGLE) and not Pads.check(last_pad, PAD_TRIANGLE) then return {".." .. seperator, true} end

  until Pads.check(pad, PAD_CROSS) and not Pads.check(last_pad, PAD_CROSS)
  if selected_item == 0 then return {".." .. seperator, true} end
  return {path .. ifBool(path:sub(#path, #path) == seperator, "", seperator) .. dir[selected_item].name, dir[selected_item].directory}
end

function doTextMenu(title, menu_items, initial_selection)
  local item_count = #menu_items

  local selected_item = initial_selection
  local current_item = 1

  repeat
    local y = 96
    Screen.clear()

    Font.fmPrint(32, 32, 1, title, OSDSYS_selected_color)
    for i = 1, item_count do
      Font.fmPrint(32, y, 1, menu_items[i][1], ifBool(selected_item == i, ifBool(menu_items[i][3], OSDSYS_selected_color, disabled_selected_color), ifBool(menu_items[i][3], OSDSYS_unselected_color, disabled_unselected_color)))
      y = y + 32
    end

    Font.fmPrint(32, screen_mode.height - 144, 0.5, menu_items[selected_item][2])
    showControls(Control_sets.ENTER_BACK)

    getPad()

    if Pads.check(pad, PAD_UP) and not Pads.check(last_pad, PAD_UP) then
      if selected_item > 1 then selected_item = selected_item - 1 end
    end

    if Pads.check(pad, PAD_DOWN) and not Pads.check(last_pad, PAD_DOWN) then
      if selected_item < item_count then selected_item = selected_item + 1 end
    end

    Screen.flip()

    if Pads.check(pad, PAD_CIRCLE) and not Pads.check(last_pad, PAD_CIRCLE) then return 0 end

  until (Pads.check(pad, PAD_CROSS) and not Pads.check(last_pad, PAD_CROSS)) and menu_items[selected_item][3]
  return selected_item
end

function rootMenu(initial_selection)
  local ret = doTextMenu("OSDMenu Configurator", {
    {"Configure OSDMenu", "", true},
    {"Configure HOSDMenu", "", true},
    {"Configure OSDMenu MBR", "", true},
    {"Configure eGSM", "", true},
    {"Load Configuration", "", true},
    {"Save Configuration", "", true}
  }, initial_selection)
  if ret == 0 then
    return -Menu_ids.ROOT
  else
    osdmenu_variant = ret
    return ret
  end
end

function OSDM_mainMenu(initial_selection)
  local title = ifTable(osdmenu_variant, {"Configure OSDMenu", "Configure HOSDMenu", "Configure OSDMenu MBR"})
  local ret =  doTextMenu(title, {
    {"OSDSYS Options", "", true},
    {"PS1 Options", "", true},
    {"Skip PS2LOGO: " .. ifBool(cdrom_skip_ps2logo, "On", "Off"), "Enables/disables running discs via rom0:PS2LOGO.\nUseful for MechaPwn-patched consoles.", true},
    {"Visual Game ID: " .. ifBool(cdrom_disable_gameid, "Off", "On"), "Enables/disables visual Game ID.", true}, --ifBool()
    {"Visual Game ID for ELFs: " .. ifBool(app_gameid, "On", "Off"), "if enabled, visual Game ID will be displayed for ELF\napplications launched from OSDMenu. The ID is generated from\nthe ELF name (up to 11 characters).", not cdrom_disable_gameid},
  }, initial_selection)
  if ret == 0 then
    return -Menu_ids.ROOT
  elseif ret == 3 then
    cdrom_skip_ps2logo = not cdrom_skip_ps2logo
  elseif ret == 4 then
    cdrom_disable_gameid = not cdrom_disable_gameid
  elseif ret == 5 then
    app_gameid = not app_gameid
  end

  return ret

end

function OSDM_OSDSYS(initial_selection)
  ret = doTextMenu("OSDSYS Options", {
    {"Korbo please add details", "Korbo please add details", true},
    {"Korbo please add details", "Korbo please add details", true},
    {"Korbo please add details", "Korbo please add details", true},
    {"Korbo please add details", "Korbo please add details", true},
    {"Korbo please add details", "Korbo please add details", true}
  }, initial_selection)
  if ret == 0 then
    return -Menu_ids.OSDMENU
  end

  return ret
end

function OSDM_PS1(initial_selection)
  local ret
  if osdmenu_variant == 1 then
    ret = doTextMenu("PS1 Options", {
      {"Use DKWDRV: " .. ifBool(cdrom_use_dkwdrv, "On", "Off"), "Enables/disables launching DKWDRV for PS1 discs.", true},
      {"DKWDRV Path: [...]", "Custom path to DKWDRV.ELF. The path MUST be on the memory card.\nCurrent Path: " .. path_DKWDRV_ELF, cdrom_use_dkwdrv},
      {"Fast Disc Speed: " .. ifBool(ps1drv_enable_fast, "On", "Off"), "Will enable fast disc speed for PS1 discs when not using DKWDRV.", not cdrom_use_dkwdrv},
      {"Texture Smoothing: " .. ifBool(ps1drv_enable_smooth, "On", "Off"), "Will enable texture smoothing for PS1 discs when not using DKWDRV.", not cdrom_use_dkwdrv},
      {"Use PS1VModeNeg: " .. ifBool(ps1drv_use_ps1vn, "On", "Off"), "Korbo please add details", not cdrom_use_dkwdrv}
    }, initial_selection)
    if ret == 2 then
      result = doFileSelect("DKWDRV Path", path_DKWDRV_ELF)
      if result then
        path_DKWDRV_ELF = result
      end
    elseif ret == 3 then
      ps1drv_enable_fast = not ps1drv_enable_fast
    elseif ret == 4 then
      ps1drv_enable_smooth = not ps1drv_enable_smooth
    elseif ret == 5 then
      ps1drv_use_ps1vn = not ps1drv_use_ps1vn
    end
  else
    ret = doTextMenu("PS1 Options", {
      {"Use DKWDRV: " .. ifBool(cdrom_use_dkwdrv, "On", "Off"), "Enables/disables launching DKWDRV for PS1 discs.", true},
      {"Fast Disc Speed: " .. ifBool(ps1drv_enable_fast, "On", "Off"), "Will enable fast disc speed for PS1 discs when not using DKWDRV", not cdrom_use_dkwdrv},
      {"Texture Smoothing: " .. ifBool(ps1drv_enable_smooth, "On", "Off"), "Will enable texture smoothing for PS1 discs when not using DKWDRV", not cdrom_use_dkwdrv},
      {"Use PS1VModeNeg: " .. ifBool(ps1drv_use_ps1vn, "On", "Off"), "custom path to DKWDRV.ELF. The path MUST be on the memory card.", not cdrom_use_dkwdrv}
    }, initial_selection)

    if ret == 2 then
      ps1drv_enable_fast = not ps1drv_enable_fast
    elseif ret == 3 then
      ps1drv_enable_smooth = not ps1drv_enable_smooth
    elseif ret == 4 then
      ps1drv_use_ps1vn = not ps1drv_use_ps1vn
    end
  end

  if ret == 0 then
    return -Menu_ids.OSDMENU
  elseif ret == 1 then
    cdrom_use_dkwdrv = not cdrom_use_dkwdrv
  end

  return ret
end

menu_functions = {
  [1] = {rootMenu, nil},
  [2] = {OSDM_mainMenu, nil},
  [3] = {OSDM_OSDSYS, nil},
  [4] = {OSDM_PS1, nil},
  [5] = {dummy, nil},
}

menu_calls = {
  {
    {Exit_type.NEW_MENU, Menu_ids.OSDMENU},
    {Exit_type.NEW_MENU, Menu_ids.OSDMENU},
    {Exit_type.NEW_MENU, Menu_ids.OSDMENU},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy}
  },
  {
    {Exit_type.NEW_MENU, Menu_ids.OSDSYS},
    {Exit_type.NEW_MENU, Menu_ids.PS1},
    {Exit_type.REPEAT},
    {Exit_type.REPEAT},
    {Exit_type.REPEAT}
  },
  {
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy}
  },
  {
    {Exit_type.REPEAT},
    {Exit_type.REPEAT},
    {Exit_type.REPEAT},
    {Exit_type.REPEAT},
    {Exit_type.REPEAT}
  },
  {
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy},
    {Exit_type.FUNCTION, dummy}
  },
}

function newTextMenu(id, initial_selection)
  local current_id = id
  local ret = 1
  repeat
    local do_again = false
    local current_function = menu_functions[current_id]
    ret = current_function[1](ret, current_function[2])
    local call_info = nil;
    if ret > 0 then
      call_info = menu_calls[current_id][ret]
    else
      call_info = {Exit_type.NEW_MENU, math.abs(ret)}
    end

    if call_info[1] == Exit_type.FUNCTION then
      call_info[2](call_info[3], call_info[4]);
    elseif call_info[1] == Exit_type.NEW_MENU then
      do_again = true
      current_id = call_info[2]
      ret = 1
    elseif call_info[1] == Exit_type.REPEAT then
      do_again = true
    end
  until not do_again
end

loadCfg("mc0:/SYS-CONF/OSDMENU.CNF", 0)

-- mount_hdd();
-- int = 12345
str = "test"
while true do
  Screen.clear()
--   doKeyboard("Keyboard Test 1", "12345", true)
--   int = doNumpad("Keyboard Test 2", int, false)

  str = doFileSelect(str, "mc0:/")
--   newTextMenu(Menu_ids.ROOT, 1)

  Screen.flip()
  --Screen.waitVblankStart()
end
