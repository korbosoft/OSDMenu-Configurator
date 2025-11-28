OSD_cfg = "OSDSYS_video_mode = %s\n\z
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

local cfg_buffer = nil;

function getMostValues(buffer, key)
  local ret = regex.search(buffer, ".*" .. key .. ".*?=[ \\t]*(.*?)\\n")[1]
  print(key .. " = " .. ret)
  return ret
end

function getColorValue(buffer, key)
  local matches = regex.search(buffer, ".*" .. key .. ".*?(0x..).*?(0x..).*?(0x..).*?(0x..)")

  return Color.new(matches[1], matches[2], matches[3], matches[4])
end

function loadCfg(path, version)
  cfg_buffer = read_file(path)
  if cfg_buffer == nil then return nil end
  if version == 0 then
    OSDSYS_video_mode = getMostValues(cfg_buffer, "OSDSYS_video_mode")
    OSDSYS_Inner_Browser = tonumber(getMostValues(cfg_buffer, "OSDSYS_Inner_Browser"))
    OSDSYS_scroll_menu = tonumber(getMostValues(cfg_buffer, "OSDSYS_scroll_menu"))
    OSDSYS_selected_color = getColorValue(cfg_buffer, "OSDSYS_selected_color")
    OSDSYS_unselected_color = getColorValue(cfg_buffer, "OSDSYS_unselected_color")
    OSDSYS_menu_x = tonumber(getMostValues(cfg_buffer, "OSDSYS_menu_x"))
    OSDSYS_menu_y = tonumber(getMostValues(cfg_buffer, "OSDSYS_menu_y"))
    OSDSYS_enter_x = tonumber(getMostValues(cfg_buffer, "OSDSYS_enter_x"))
    OSDSYS_enter_y = tonumber(getMostValues(cfg_buffer, "OSDSYS_enter_y"))
    OSDSYS_version_x = tonumber(getMostValues(cfg_buffer, "OSDSYS_version_x"))
    OSDSYS_version_y = tonumber(getMostValues(cfg_buffer, "OSDSYS_version_y"))
    OSDSYS_cursor_max_velocity = tonumber(getMostValues(cfg_buffer, "OSDSYS_cursor_max_velocity"))
    OSDSYS_cursor_acceleration = tonumber(getMostValues(cfg_buffer, "OSDSYS_cursor_acceleration"))
    OSDSYS_left_cursor = getMostValues(cfg_buffer, "OSDSYS_left_cursor")
    OSDSYS_right_cursor = getMostValues(cfg_buffer, "OSDSYS_right_cursor")
    OSDSYS_menu_top_delimiter = getMostValues(cfg_buffer, "OSDSYS_menu_top_delimiter")
    OSDSYS_menu_bottom_delimiter = getMostValues(cfg_buffer, "OSDSYS_menu_bottom_delimiter")
    OSDSYS_num_displayed_items = tonumber(getMostValues(cfg_buffer, "OSDSYS_num_displayed_items"))
    OSDSYS_Skip_MC = tonumber(getMostValues(cfg_buffer, "OSDSYS_Skip_MC"))
    OSDSYS_Skip_HDD = tonumber(getMostValues(cfg_buffer, "OSDSYS_Skip_HDD"))
    OSDSYS_Skip_Disc = tonumber(getMostValues(cfg_buffer, "OSDSYS_Skip_Disc"))
    OSDSYS_Skip_Logo = tonumber(getMostValues(cfg_buffer, "OSDSYS_Skip_Logo"))
    cdrom_skip_ps2logo = tonumber(getMostValues(cfg_buffer, "cdrom_skip_ps2logo"))
    cdrom_disable_gameid = tonumber(getMostValues(cfg_buffer, "cdrom_disable_gameid"))
    cdrom_use_dkwdrv = tonumber(getMostValues(cfg_buffer, "cdrom_use_dkwdrv"))
    app_gameid = tonumber(getMostValues(cfg_buffer, "app_gameid"))
  end
  return version
end
