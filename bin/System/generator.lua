OSD_cfg_template = "OSDSYS_video_mode = %s\n\z
OSDSYS_Inner_Browser = %i\n\z
OSDSYS_selected_color = 0x%X,0x%X,0x%X,0x%X\n\z
OSDSYS_unselected_color = 0x%X,0x%X,0x%X,0x%X\n\z
OSDSYS_scroll_menu = %i\n\z
OSDSYS_menu_x = %i\n\z
OSDSYS_menu_y = %i\n\z
OSDSYS_enter_x = %i\n\z
OSDSYS_enter_y = %i\n\z
OSDSYS_version_x = %i\n\z
OSDSYS_version_y = %i\n\z
OSDSYS_cursor_max_velocity = %i\n\z
OSDSYS_cursor_acceleration = %i\n\z
OSDSYS_left_cursor = %s\n\z
OSDSYS_right_cursor = %s\n\z
OSDSYS_menu_top_delimiter = %s\n\z
OSDSYS_menu_bottom_delimiter = %s\n\z
OSDSYS_num_displayed_items = %i\n\z
OSDSYS_Skip_MC = %i\n\z
OSDSYS_Skip_HDD = %i\n\z
OSDSYS_Skip_Disc = %i\n\z
OSDSYS_Skip_Logo = %i\n\z
cdrom_skip_ps2logo = %i\n\z
cdrom_disable_gameid = %i\n\z
cdrom_use_dkwdrv = %i\n\z
ps1drv_enable_fast = %i\n\z
ps1drv_enable_smooth = %i\n\z
ps1drv_use_ps1vn = %i\n\z
app_gameid = %i\n\z
path_DKWDRV_ELF = %s\n\z
# --------------------------------------------------"

-- name_OSDSYS_ITEM_1 = Launch Disc
-- path1_OSDSYS_ITEM_1 = cdrom
-- arg_OSDSYS_ITEM_1 = -nologo
-- # --------------------------------------------------
-- name_OSDSYS_ITEM_2 = wLaunchELF
-- path1_OSDSYS_ITEM_2 = mc?:/BOOT/BOOT.ELF
-- path2_OSDSYS_ITEM_2 = mmce?:/apps/wLaunchELF.elf
-- path3_OSDSYS_ITEM_2 = usb:/apps/wLaunchELF.elf
-- # --------------------------------------------------
-- name_OSDSYS_ITEM_250 = Shutdown
-- path1_OSDSYS_ITEM_250 = POWEROFF
-- # --------------------------------------------------

function read_file(path)
  local file = System.openFile(path, O_RDONLY)
  if (file == nil) then return nil end
  local ret = System.readFile(file, System.sizeFile(file))
  System.closeFile(file)
  return ret
end

local cfg_buf = nil;

function getNumberValue(buffer, key)
local ret = tonumber(regex.search(buffer, ".*" .. key .. ".*?=[ \\t]*(.*?)\\n")[1])
print(key .. " = " .. ret)
return ret
end

function getTextValue(buffer, key)
  local ret = regex.search(buffer, ".*" .. key .. ".*?=[ \\t]*(.*?)\\n")[1]
  print(key .. " = " .. ret)
  return ret
end

function getBooleanValue(buffer, key)
local ret = tonumber(regex.search(buffer, ".*" .. key .. ".*?=[ \\t]*(.*?)\\n")[1]) > 0
print(key .. " = " .. tostring(ret))
return ret
end

function getColorValue(buffer, key)
  local matches = regex.search(buffer, ".*" .. key .. ".*?(0x..).*?(0x..).*?(0x..).*?(0x..)")

  return Color.new(matches[1], matches[2], matches[3], matches[4])
end

function loadCfg(path, version)
  cfg_buf = read_file(path)
  if cfg_buf == nil then return nil end
  if version == 0 then
    OSDSYS_video_mode = getTextValue(cfg_buf, "OSDSYS_video_mode")
    OSDSYS_Inner_Browser = getBooleanValue(cfg_buf, "OSDSYS_Inner_Browser")
    OSDSYS_scroll_menu = getBooleanValue(cfg_buf, "OSDSYS_scroll_menu")
    OSDSYS_selected_color = getColorValue(cfg_buf, "OSDSYS_selected_color")
    OSDSYS_unselected_color = getColorValue(cfg_buf, "OSDSYS_unselected_color")
    OSDSYS_menu_x = getNumberValue(cfg_buf, "OSDSYS_menu_x")
    OSDSYS_menu_y = getNumberValue(cfg_buf, "OSDSYS_menu_y")
    OSDSYS_enter_x = getNumberValue(cfg_buf, "OSDSYS_enter_x")
    OSDSYS_enter_y = getNumberValue(cfg_buf, "OSDSYS_enter_y")
    OSDSYS_version_x = getNumberValue(cfg_buf, "OSDSYS_version_x")
    OSDSYS_version_y = getNumberValue(cfg_buf, "OSDSYS_version_y")
    OSDSYS_cursor_max_velocity = getNumberValue(cfg_buf, "OSDSYS_cursor_max_velocity")
    OSDSYS_cursor_acceleration = getNumberValue(cfg_buf, "OSDSYS_cursor_acceleration")
    OSDSYS_left_cursor = getTextValue(cfg_buf, "OSDSYS_left_cursor")
    OSDSYS_right_cursor = getTextValue(cfg_buf, "OSDSYS_right_cursor")
    OSDSYS_menu_top_delimiter = getTextValue(cfg_buf, "OSDSYS_menu_top_delimiter")
    OSDSYS_menu_bottom_delimiter = getTextValue(cfg_buf, "OSDSYS_menu_bottom_delimiter")
    OSDSYS_num_displayed_items = getNumberValue(cfg_buf, "OSDSYS_num_displayed_items")
    OSDSYS_Skip_MC = getBooleanValue(cfg_buf, "OSDSYS_Skip_MC")
    OSDSYS_Skip_HDD = getBooleanValue(cfg_buf, "OSDSYS_Skip_HDD")
    OSDSYS_Skip_Disc = getBooleanValue(cfg_buf, "OSDSYS_Skip_Disc")
    OSDSYS_Skip_Logo = getBooleanValue(cfg_buf, "OSDSYS_Skip_Logo")
    cdrom_skip_ps2logo = getBooleanValue(cfg_buf, "cdrom_skip_ps2logo")
    cdrom_disable_gameid = getBooleanValue(cfg_buf, "cdrom_disable_gameid")
    cdrom_use_dkwdrv = getBooleanValue(cfg_buf, "cdrom_use_dkwdrv")
    app_gameid = getBooleanValue(cfg_buf, "app_gameid")
  end
  return version
end
