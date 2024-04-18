-- gen2con (Main) Lua Config v0.1
-- a.dinis (c) 2019

require 'cairo'
require 'imlib2'

sysUpdates = 0

function conky_main()

  if conky_window == nil then return end
  local cs = cairo_xlib_surface_create(
    conky_window.display, conky_window.drawable, conky_window.visual,
    conky_window.width, conky_window.height)
  local cr = cairo_create(cs)
  cWidth = conky_window.width
  cHeight = conky_window.height
  cCenter = { x = cWidth / 2, y = cHeight / 2 }
  updates = tonumber(conky_parse('${updates}'))
  updatesGap = 5

  -- get arch updates every 15 minutes
  if updates == 6 or updates % 900 == 0 then
    --sysUpdates = get_con("checkupdates | wc -l")
    sysUpdates = sysUpdates ~= nil and sysUpdates or 0
  end

  do_cpu(cr, updates)

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
