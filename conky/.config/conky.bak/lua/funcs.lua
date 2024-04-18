--[[macros]]--
rad2deg = 180 / math.pi
halfdeg = math.pi / 360
deg2rad = math.pi / 180
deg90rad = math.pi / 2
deg180rad = math.pi
deg270rad = 3 * math.pi / 2
deg360rad = 2 * math.pi

--[[support]]--

-- Parse a date from json to 
function parseJsonDate(jsonDate)
    if (jsonDate == nil or jsonDate == "") then
        return 0
    end
    --print("parsing date: " .. jsonDate)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-])(%d?%d?)%:?(%d?%d?)"
    --print("using pattern: " .. pattern)
    local year, month, day, hour, minute, seconds, offsetsign, offsethour, offsetmin = jsonDate:match(pattern)
    local timestamp = os.time{year = year, month = month, day = day, hour = hour, min = minute, sec = seconds}
    local offset = 0
    if offsetsign ~= 'Z' then
        offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
        if offsetsign == "-" then offset = offset * -1 end
    end

    local timeInSeconds = timestamp + offset

    return tonumber(timeInSeconds)
end

-- UTC date string to hour
function parseWKDateToHour(wkDate)
    local wkTimestamp = parseJsonDate(wkDate)

    local currentTime = os.time()
    local lct = os.date("*t", currentTime)
    local utc = os.date("!*t", currentTime)
    local wkt = os.date("*t", wkTimestamp)
    --print("utc: " .. utc.hour)
    --print("wkt: " .. wkt.hour)
    local offset = wkt.hour - utc.hour
    local nextHr = lct.hour + offset
    nextHr = (nextHr) > 24 and nextHr - 24 or nextHr

    if (offset > 0) then
        return nextHr .. ":00"
    else
        return "now"
    end
end

-- get wanikani review stats
function getWKReviewStats(curl, json, wk)

    -- Setup curl call
    if (time.minutes % 10 == 0) then
    else
        wk.headers[4] = "If-Modified-Since: " .. wk.revStatLastModified
    end
    c = curl.easy {
        url = wk.linkBase .. wk.linkReviewStats,
        httpheader = wk.headers
    }

    t = {}
    lastModified = ""
    wk.headers[4] = nil

    -- Perform curl lookup
    c:perform({
        headerfunction = function(str)
            for k, v in str:gmatch("(Last%-Modified): (.*)\r\n") do
                lastModified = v
            end
        end,
        writefunction = function(str)
            --print("Writing str to table: " .. str)
            t[#t+1] = str
        end
    })

    wkData = json.decode(table.concat(t))
    newData = false
    if wkData ~= nil then

        local wkRevStats = wkData['data']

        wk.revStatLastModified = lastModified
        wk.idsSubjectLessThan = {}

        for n, t in pairs(wkRevStats) do
            wk.idsSubjectLessThan[#wk.idsSubjectLessThan+1] = t['data']['subject_id']
        end


        newData = true
    end

    return newData
end

-- get subjects that have poor percentages
function getWKSubjectsLessThan(curl, json, wk)

    -- Setup curl call
    wk.headers[4] = nil
    c = curl.easy {
        url = wk.linkBase .. wk.linkSubjects,
        httpheader = wk.headers
    }

    t = {}

    -- Perform curl lookup
    c:perform({
        headerfunction = function(str)
        end,
        writefunction = function(str)
            t[#t+1] = str
        end
    })

    wkData = json.decode(table.concat(t))

    newData = false
    if wkData ~= nil then

        local wkSubjects = wkData['data']
        wk.infoSubjectLessThan = {}

        for n, t in pairs(wkSubjects) do
            local subInfo = {
                type = t['object'],
                characters = t['data']['characters'],
                level = t['data']['level'],
                meaning = t['data']['meanings'][1]['meaning'],
                reading = t['data']['readings'][1]['reading'],
            }
            wk.infoSubjectLessThan[#wk.infoSubjectLessThan+1]= subInfo
        end

        newData = true
    end

    return newData
end


-- get wanikani summary
function getWKSummary(curl, json, wk)

  -- Setup curl call
  if (time.minutes % 10 == 0) then
    --wk.lastModified = ""
    --wk.headers[4] = ""
  else
    wk.headers[4] = "If-Modified-Since: " .. wk.lastModified
  end
  c = curl.easy {
    url = wk.linkBase ..wk.linkSummary,
    httpheader = wk.headers
  }

  t = {}
  lastModified = ""
  wk.headers[4] = nil

  -- Perform curl lookup
  c:perform({
      headerfunction = function(str)
        for k, v in str:gmatch("(Last%-Modified): (.*)\r\n") do
	  lastModified = v
        end
      end,
      writefunction = function(str)
        t[#t+1] = str
      end
  })

  wkData = json.decode(table.concat(t))

  newData = false
  if wkData ~= nil then
    wk.nextAvailAt = wkData['data']['next_reviews_at']

    local wkLessons = wkData['data']['lessons']
    local wkReviews = wkData['data']['reviews']

    -- lessons
    wk.lessons = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
    for hr, lessons in pairs(wkLessons) do
      for k, sid in pairs(lessons['subject_ids']) do
	table.insert(wk.lessons[hr], sid)
      end
      --print('l: ' .. hr, #wk.lessons[hr])
    end
    wk.lessonsNow = #wk.lessons[1]

    wk.reviews = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
    -- reviews
    for hr, reviews in pairs(wkReviews) do
      --print(hr, reviews)
      for _, sid in pairs(reviews['subject_ids']) do
        table.insert(wk.reviews[hr], sid)
      end
      --print(hr, #wk.reviews[hr])
    end

    wk.reviewsNow = #wk.reviews[1]
    newData = true
  end

  wk.lastModified = lastModified

  return newData
end

-- get wanikani user info
function getWKUser(curl, json, wk)
  
  -- Setup curl call
  if (time.minutes % 10 == 0) then
    --wk.etagUser = ""
    --wk.headers[4] = ""
  else
    wk.headers[4] = "If-Modified-Since: " .. wk.userLastModified
  end
  c = curl.easy {
    url = wk.linkBase .. wk.linkUser,
    httpheader = wk.headers
  }

  t = {}
  userLastModified = ""
  wk.headers[4] = nil

  -- Perform curl lookup
  c:perform({
    headerfunction = function(str)
      for k, v in str:gmatch("(Last-Modified): (.*)\r\n") do
        userLastModified = v
      end
    end,
    writefunction = function(str)
      t[#t+1] = str
    end
  })

  userData = json.decode(table.concat(t))

  newData = false
  if userData ~= nil then
    wk.userLevel = userData['data']['level']
    newData = true
  end

  wk.userLastModified = userLastModified

  return newData
end

-- get total transfered
function getTotalXd(down, up)

  local units = {[1] = 'B', [2] = 'KiB', [3] = 'MiB', [4] = 'GiB'}
  local dNum, dUnit = down:match('(%d+)(%a+)')
  local uNum, uUnit = up:match('(%d+)(%a+)')
  local tDown, tUp = 0, 0

  for i, v in pairs(units) do
    if dUnit == v then
      tDown = dNum * math.pow(1024, i)
    end
    if uUnit == v then
      tUp = uNum * math.pow(1024, i)
    end
  end

  local total = (tUp + tDown) or 1

  local base = math.log(total, 1024) or 1
  local roundBase = roundWithP(math.pow(1024, base - math.floor(base)), 2)
  local outUnits = units[math.floor(base)]
  local totalOut = (roundBase or 0) .. (outUnits or 'NA')

  return totalOut
end


-- simple sorting
function hilo(a, b, c)
  if c < b then b, c = c, b end
  if b < a then a, b = b, a end
  if c < b then b, c = c, b end
  return a + c
end


-- get a compliment color
function rgb2hsl(r, g, b)

  local min = math.min(r, g, b)
  local max = math.max(r, g, b)
  local del = max - min
  local h, s, l = 0, 0, 0
  l = (max + min) / 2

  if del == 0 then
    h = 0
    s = 0
  else
    if l < 0.5 then
      s = del / (max + min)
    else
      s = max / (2 - max - min)
    end

    local rdel = (((max - r) / 6) + (max / 2)) / max
    local gdel = (((max - g) / 6) + (max / 2)) / max
    local bdel = (((max - b) / 6) + (max / 2)) / max

    if r == max then
      h = bdel - gdel
    elseif g == max then
      h = (1 / 3) + rdel - bdel
    elseif b == max then
      h = (2 / 3) + gdel - rdel
    end

    if h < 0 then
      h = h + 1
    end

    if h > 1 then
      h = h - 1
    end
  end

  return h, s, l
end

function hsl2rgb(h, s, l)

  local r, g, b = 0, 0, 0
  local var1, var2 = 0, 0

  if s == 0 then
    r = l * 255
    g = l * 255
    b = l * 255
  else
    if l < 0.5 then
      var2 = l * (1 + s)
    else
      var2 = (l + s) - (s * l)
    end

    var1 = 2 * l - var2
    r = 255 * hue2rgb(var1, var2, h + (1 / 3))
    g = 255 * hue2rgb(var1, var2, h)
    b = 255 * hue2rgb(var1, var2, h - (1 / 3))
  end

  return r, g, b
end

function hue2rgb(var1, var2, varh)

  local v1, v2, vh = var1, var2, varh

  if vh < 0 then
    vh = vh + 1
  end

  if vh > 1 then
    vh = vh - 1
  end

  if (6 * vh) < 1 then
    return (v1 + (v2 - v1) * 6 * vh)
  end

  if (2 * vh) < 1 then
    return v2
  end

  if (3 * vh) < 2 then
    return (v1 + (v2 - v1) * ((2 / 3 - vh) * 6))
  end
  
  return v1
end



function getCompliment(color)
  local r = (color / 0x10000) % 0x100 / 0xFF
  local g = (color / 0x100) % 0x100 / 0xFF
  local b = (color / 0x1) % 0x100 / 0xFF

  local k = hilo(r, g, b)

  local kr = k - r
  local kg = k - g
  local kb = k - b

  local rp = math.max(r,g,b) + math.min(r,g,b) - r
  local gp = math.max(r,g,b) + math.min(r,g,b) - g
  local bp = math.max(r,g,b) + math.min(r,g,b) - b

  return '0x' .. string.format("%x%x%x", round(rp * 256), round(gp * 256), round(bp * 256))
end

-- sleep for n seconds
local clock = os.clock
function sleep(n) -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

-- run a command
function run_cmd(cmd)
  cmd, err = io.popen(cmd)
  if cmd then
    cmd:close()
    return "Done"
  else
    return err
  end
end

-- get output from a command
function get_con(cmd)
  cmd, err = io.popen(cmd)
  if cmd then
    for str in cmd:lines() do
      return str
    end
    cmd:close()
  else
    return err
  end
end

-- check if file exists
function check_file(f)
  local file = io.open(f, "r")
  if file ~= nil then return true else return false end
end

-- convert seconds to minutes
function seconds_to_min(secs)
  local seconds = tonumber(secs) or 0
  local min = math.floor(seconds / 60)
  return min
end

-- convert seconds to hours:minutes:seconds
function seconds_to_clock(secs)
  local seconds = tonumber(secs) or 0
  local ampm, hrs, min, sec = "AM", 0, 0, 0

  if seconds > 0 then
    hrs = string.format("%2.f", math.floor(seconds / 3600))
    min = string.format("%02.f", math.floor(seconds / 60 - (hrs* 60)))
    sec = string.format("%02.f", math.floor(seconds - hrs * 3600 - min * 60))
    if tonumber(hrs) >= 12 then
      ampm = "PM"
      --hrs = string.format("%.f", tonumber(hrs) - 12)
    end
  end
  return hrs .. ':' .. min .. ' ' .. ampm
end

-- size format
function size_to_text(size, nbDec)
  local txtV
  if nbDec < 0 then nbDec = 0 end
  size = tonumber(size)
  if size > 1024 * 1024 * 1024 then
    txtV = string.format("%." .. nbDec .. "f Go", size / 1024 / 1024 / 1024)
  elseif size > 1024 * 1024 then
    txtV = string.format("%." .. nbDec .. "f Mo", size / 1024 / 1024)
  elseif size > 1024 then
    txtV = string.format("%." .. nbDec .. "f Ko", size / 1024)
  else
    txtV = string.format("%." .. nbDec .. "f o", size)
  end
  return txtV
end

-- split a string
function string:split(delimiter)
  local result = {}
  local from = 1
  local delimFrom, delimTo = string.find(self, delimiter, from)
  while delimFrom do
    table.insert(result, string.sub(self, from, delimFrom-1))
    from = delimTo + 1
    delimFrom, delimTo = string.find(self, delimiter, from)
  end
  table.insert(result, string.sub(self, from))
  return result
end

-- round to multiple
function roundUpToMultiple(n, mult)
  rem = n % mult
  if rem == 0 then
    return n
  end
  return n + mult - rem
end

-- round a number
function round(n)
  local x = .5
  if n < 0 then x = -.5 end
  return math.modf(n + x)
end

function roundWithP(n, prec)
  if prec and prec > 0 then
    local mult = 10 ^ prec
    return math.floor(n * mult + 0.5) / mult
  end
  return math.floor(n + 0.5)
end

-- run a command and get output
function get_con(cmd)
  cmd, err = io.popen(cmd)
  if cmd then
    for str in cmd:lines() do
      return str
    end
    cmd:close()
  else
    return err
  end
end

-- color difference between 2 colors
function color_delta(tc1, tc2, n)
  for x = 1, #tc1 do
    tc1[x].dP = 0
    tc1[x].dR = 0
    tc1[x].dG = 0
    tc1[x].dB = 0
    tc1[x].dA = 0
    if tc2 ~= nil and #tc1 == #tc2 then
      local r1, g1, b1, a1 = rgba_to_r_g_b_a(tc1[x])
      local r2, g2, b2, a2 = rgba_to_r_g_b_a(tc2[x])
      tc1[x].dP = (tc2[x][1] - tc1[x][1]) / n
      tc1[x].dR = (r2 - r1) / n
      tc1[x].dG = (g2 - g1) / n
      tc1[x].dB = (b2 - b1) / n
      tc1[x].dA = (a2 - a1) / n
    end
  end
  return tc1
end

-- deep copy table
function deepcopy(orig)
  local origType = type(orig)
  local copy
  if origType == 'table' then
    copy = {}
    for origKey, origValue in next, orig, nil do
      copy[deepcopy(origKey)] = deepcopy(origValue)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else --number, string, boolean, etc
    copy = orig
  end
  return copy
end

-- convert rgba (hex color + 0-1 alpha) to 4 distinct vals (1-255,1-255,1-255,0-1)
function rgb_a_to_r_g_b_a(color, alpha)
  if color == nil then color = 0xFFFFFF end
  local r = (color / 0x10000) % 0x100 / 0xFF
  local g = (color / 0x100) % 0x100 / 0xFF
  local b = (color / 0x1) % 0x100 / 0xFF
  return r, g, b, alpha
end

-- convert a table of {offset, color, alpha} or {color, alpha} to rgba
function rgba_to_r_g_b_a(tcol)
  local c, a = color.white, 1
  if #tcol == 2 then
    c, a = tcol[1], tcol[2]
  elseif #tcol == 3 then
    c, a = tcol[2], tcol[3]
  end
  return rgb_a_to_r_g_b_a(c, a)
end

-- convert degree to rad and rotate (0 degree is top)
function angle_to_pos(startAngle, currentAngle)
  local pos = currentAngle + startAngle
  return ((pos * deg2rad) - deg90rad)
end

-- splice a table
function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

-- weeks unto day
function weeksTo(l, fn)
  local acc
  for k, v in ipairs(l) do
    if 1 == k then
      acc = v
    else
      acc = acc + v
    end
  end
  return acc
end

--[[building]]--
function build_weeks_ring(month, tWeeks)
  prevMonth = month - 1
  if prevMonth == 0 then
    tWeeks.arg = time.weekNum + 1
  else
    tWeeks.arg = (tonumber(time.month) > month) and mthWeeks[month] or (time.weekNum - weeksTo(table.slice(mthWeeks,1,prevMonth)) + 1)
    --tWeeks.arg = (tonumber(time.month) > month) and mthWeeks[month] or (time.weekNum - weeksTo(table.slice(mthWeeks,1,prevMonth)))
  end
  --print('weeksTo: ' .. time.weekNum .. ' ' .. (time.weekNum - weeksTo(table.slice(mthWeeks,1,1))))
  --print('weeksTo: ' .. tWeeks.arg)
  --tWeeks.arg = (tonumber(time.month) > month) and mthWeeks[month] or (time.weekNum - time.weekNow)
  tWeeks.max = mthWeeks[month]
  tWeeks.startAngle = (-90 + ((month - 1) * 30)) + 2
  tWeeks.endAngle = (-60 + ((month - 1) * 30)) - 2
  tWeeks.sectors = mthWeeks[month]

  return tWeeks
end


--[[drawing]]--

-- draw background
function draw_background(cr, t)
  cairo_set_line_width(cr, 1)
  cairo_rectangle(cr, t.x, t.y, t.w, t.h)
  cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.color))
  cairo_fill_preserve(cr)
  cairo_stroke(cr)
end

-- draw png image to screen
function put_image(cr, t)
  local img = cairo_image_surface_create_from_png(t.file)
  local imgW = cairo_image_surface_get_width(img)
  local imgH = cairo_image_surface_get_height(img)
  local w = t.w or imgW
  local h = t.h or imgH
  local ratioW = w / imgW
  local ratioH = h / imgH
  local scale = math.min(ratioH, ratioW)

  cairo_save(cr)
  cairo_translate(cr, t.x, t.y)
  if t.rotate then cairo_rotate(cr, t.theta * deg2rad) end
  cairo_scale(cr, scale, scale)
  cairo_translate(cr, -0.5 * imgW, -0.5 * imgH)
  cairo_set_source_surface(cr, img, 0, 0)
  cairo_paint(cr)
  cairo_surface_destroy(img)
  cairo_restore(cr)
end

-- draw box (line)
function draw_box(cr, t)

  -- sanity check
  if t.drawMe == true then t.drawMe = nil end
  if t.drawMe ~= nil and conky_parse(tostring(t.drawMe)) ~= "1" then return end

  local tableCorners = {"circle", "curve", "line"}
  local tOps = {
    clear     = CLEAR_OPERATOR_CLEAR,
    source    = CAIRO_OPERATOR_SOURCE,
    over      = CAIRO_OPERATOR_OVER,
    ["in"]    = CAIRO_OPERATOR_IN,
    out       = CAIRO_OPERATOR_OUT,
    atop      = CAIRO_OPERATOR_ATOP,
    dest      = CAIRO_OPERATOR_DEST,
    destOver  = CAIRO_OPERATOR_DEST_OVER,
    destIn    = CAIRO_OPERATOR_DEST_IN,
    destOut   = CAIRO_OPERATOR_DEST_OUT,
    destAtop  = CAIRO_OPERATOR_DEST_ATOP,
    xor       = CAIRO_OPERATOR_XOR,
    add       = CAIRO_OPERATOR_ADD,
    saturate  = CAIRO_OPERATOR_SATURATE,
  }

  local function draw_corner(num, t)
    local shape = t[1]
    local radius = t[2]
    local x,y = t[3], t[4]
    if shape == "line" then
      if num == 1 then cairo_line_to(cr, radius, 0)
      elseif num == 2 then cairo_line_to(cr, x, radius)
      elseif num == 3 then cairo_line_to(cr, x - radius, y)
      elseif num == 4 then cairo_line_to(cr, 0, y - radius)
      end
    end
    if shape == "circle" then
      if num == 1 then cairo_arc(cr, radius, radius, radius, -deg180rad, -deg90rad)
      elseif num == 2 then cairo_arc(cr, x - radius, y + radius, radius, -deg90rad, 0)
      elseif num == 3 then cairo_arc(cr, x - radius, y - radius, radius, 0, deg90rad)
      elseif num == 4 then cairo_arc(cr, radius, y - radius, radius, deg90rad, -deg180rad)
      end
    end
    if shape == "curve" then
      if num == 1 then cairo_arc(cr, 0, radius, 0, 0, radius, 0)
      elseif num == 2 then cairo_arc(cr, x - radius, 0, x, y, x, radius)
      elseif num == 3 then cairo_arc(cr, x, y - radius, x, y, x - radius, y)
      elseif num == 4 then cairo_arc(cr, radius, y, x, y, 0, y - radius)
      end
    end
  end

  -- Check values and set defaults
  if t.x == nil then t.x = 0 end
  if t.y == nil then t.y = 0 end
  if t.w == nil then t.w = cWidth end
  if t.h == nil then t.h = cHeight end
  if t.radius == nil then t.radius = 0 end
  if t.border == nil then t.border = 0 end
  if t.color == nil then t.color = {{1, color.white, 0.5}} end
  if t.linearGradient ~= nil then
    if #t.linearGradient ~= 4 then
      t.linearGradient = {t.x, t.y, t.width, t.height}
    end
  end
  if t.angle == nil then t.angle = 0 end
  if t.skewX == nil then t.skewX = 0 end
  if t.skewY == nil then t.skewY = 0 end
  if t.scaleX == nil then t.scaleX = 1 end
  if t.scaleY == nil then t.scaleY = 1 end
  if t.rotX == nil then t.rotX = 0 end
  if t.rotY == nil then t.rotY = 0 end
  if t.operator == nil then t.operator = "over" end
  if (tOps[t.operator]) == nil then
    print("wrong operator :", t.operator)
    t.operator = "over"
  end
  if t.radialGradient ~= nil then
    if #t.radialGradient ~= 6 then
      t.radialGradient = {t.x, t.y, 0, t.x, t.y, t.width}
    end
  end
  for i = 1, #t.color do
    if #t.color[i] ~= 3 then
      print("error in color table")
      t.color[i] = {1, color.white, 1}
    end
  end
  if t.corners == nil then t.corners = {{"line", 0}} end
  local tCorners = {}
  local tCorners = deepcopy(t.corners)
  for i = #t.corners + 1, 4 do
    tCorners[i] = tCorners[#tCorners]
    local flag = false
    for j, v in pairs(tableCorners) do flag = flag or (tCorners[i][1] == v) end
    if not flag then print("error in corners table :", tCorners[i][1]); tCorners[i][1] = "curve" end
  end
  tCorners[1] = {tCorners[1][1], tCorners[1][2], 0, 0}
  tCorners[2] = {tCorners[2][1], tCorners[2][2], t.w, 0}
  tCorners[3] = {tCorners[3][1], tCorners[3][2], t.w, t.h}
  tCorners[4] = {tCorners[4][1], tCorners[4][2], 0, t.h}

  t.noGradient = (t.linearGradient == nil) and (t.radialGradient == nil)

  -- Start drawing
  cairo_save(cr)
  cairo_translate(cr, t.x, t.y)
  if t.rotX ~= 0 or t.rotY ~= 0 or t.angle ~= 0 then
    cairo_translate(cr, t.rotX, t.rotY)
    cairo_translate(cr, t.angle * deg2rad)
    cairo_translate(cr, -t.rotX, -t.rotY)
  end
  if t.scaleX ~= 1 or t.scaleY ~= 1 or t.skewX ~= 0 or t.skewY ~= 0 then
    local matrix0 = cairo_matrix_t:create()
    tolua.takeownership(matrix0)
    cairo_matrix_init(matrix0, t.scaleX, t.skewY * deg2rad, t.skewX * deg2rad, t.scaleY, 0, 0)
    cairo_transform(cr, matrix0)
  end
  local tc = tCorners
  cairo_move_to(cr, tc[1][2], 0)
  cairo_line_to(cr, t.w - tc[2][2], 0)
  draw_corner(2, tc[2])
  cairo_line_to(cr, t.w, t.h - tc[3][2])
  draw_corner(3, tc[3])
  cairo_line_to(cr, tc[4][2], t.h)
  draw_corner(4, tc[4])
  cairo_line_to(cr, 0, tc[1][2])
  draw_corner(1, tc[1])
  if t.noGradient then
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.color[1]))
  else
    if t.linearGradient ~= nil then
      pat = cairo_pattern_create_linear(t.linearGradient[1], t.linearGradient[2], t.linearGradient[3], t.linearGradient[4])
    elseif t.radialGradient ~= nil then
      pat = cairo_pattern_create_radial(t.radialGradient[1], t.radialGradient[2], t.radialGradient[3], t.radialGradient[4], t.radialGradient[5], t.radialGradient[6])
    end
    for i = 1, #t.color do
      cairo_pattern_add_color_stop_rgba(pat, t.color[i][1], rgba_to_r_g_b_a(t.color[i]))
    end
    cairo_set_source(cr, pat)
    cairo_pattern_destroy(pat)
  end
  cairo_set_operator(cr, tOps[t.operator])
  if t.border > 0 then
    cairo_close_path(cr)
    if t.dash ~= nil then cairo_set_dash(cr, t.dash, 1, 0.0) end
    cairo_set_line_width(cr, t.border)
    cairo_stroke(cr)
  else
    cairo_fill(cr)
  end

  cairo_restore(cr)
end

-- draw ring
function draw_ring(cr, t)

  -- check values
  local function setup(t)

    if t.name == nil and t.arg == nil then
      print('Missing name and arg values')
      return
    end

    if t.max == nil then
      print('No max value')
      return
    end

    if t.name == nil then t.name = '' end
    if t.arg == nil then t.arg = '' end
    if t.xc == nil then t.xc = cCenter.x end
    if t.yc == nil then t.yc = cCenter.y end
    if t.thickness == nil then t.thickness = 10 end
    if t.radius == nil then t.radius = cWidth / 4 end
    if t.startAngle == nil then t.startAngle = 0 end
    if t.endAngle == nil then t.endAngle = 360 end
    if t.bgColor1 == nil then
      t.bgColor1 = {{0, color.cyan, 0.1}, {0.5, color.green, 1}, {1, color.cyan, 0.1}}
    end
    if t.fgColor1 == nil then
      t.fgColor1 = {{0, color.green, 0.1}, {0.5, color.green, 1}, {1, color.green, 0.1}}
    end
    if t.bdColor1 == nil then
      t.bdColor1 = {{0, color.yellow, 0.5}, {0.5, color.yellow, 1}, {1, color.yellow, 0.5}}
    end
    if t.sectors == nil then t.sectors = 10 end
    if t.gapSectors == nil then t.gapSectors = 1 end
    if t.fillSector == nil then t.fillSector = false end
    if t.allSectors == nil then t.allSectors = true end
    if t.borderSize == nil then t.borderSize = 0 end
    if t.cap == nil then t.cap = 'p' end
    if t.thickness > t.radius then t.thickness = t.radius * 0.1 end
    if t.intRadius == nil or t.intRadius > (t.radius - t.thickness) then
      t.intRadius = t.radius - t.thickness
    end
    for i = 1, #t.bgColor1 do
      if #t.bgColor1[i] ~= 3 then t.bgColor1[i] = {1, color.white, 0.5} end
    end
    for i = 1, #t.fgColor1 do
      if #t.fgColor1[i] ~= 3 then t.fgColor1[i] = {1, color.scarlet, 1} end
    end
    for i = 1, #t.bdColor1 do
      if #t.bdColor1[i] ~= 3 then t.bdColor1[i] = {1, color.yellow, 1} end
    end
    if t.bgColor2 ~= nil then
      for i = 1, #t.bgColor2 do
        if #t.bgColor2[i] ~= 3 then t.bgColor2[i] = {1, color.white, 0.5} end
      end
    end
    if t.fgColor2 ~= nil then
      for i = 1, #t.fgColor2 do
        if #t.fgColor2[i] ~= 3 then t.fgColor2[i] = {1, color.scarlet, 1} end
      end
    end
    if t.bdColor2 ~= nil then
      for i = 1, #t.bdColor2 do
        if #t.bdColor2[i] ~= 3 then t.bdColor2[i] = {1, color.yellow, 1} end
      end
    end
    if t.startAngle >= t.endAngle then
      t.startAngle, t.endAngle = t.endAngle, t.startAngle
      if t.endAngle - t.startAngle > 360 and t.startAngle > 0 then
        t.endAngle = 360 + t.startAngle
        print('Reduce angles...')
      end
      if t.endAngle + t.startAngle > 360 and t.startAngle <= 0 then
        t.endAngle = 360 + t.startAngle
        print('Reduce angles...')
      end
      if t.intRadius < 0 then t.intRadius = 0 end
      if t.intRadius > t.radius then
        t.intRadius, t.radius = t.radius, t.intRadius
        print('Inversed radii...')
      end
      if t.intRadius == t.radius then
        i.intRadius = 0
        print('Interior radius set for 0')
      end
    end

    t.bgColor1 = color_delta(t.bgColor1, t.bgColor2, t.sectors)
    t.fgColor1 = color_delta(t.fgColor1, t.fgColor2, t.sectors)
    t.bdColor1 = color_delta(t.bdColor1, t.bdColor2, t.sectors)
  end

  local function draw_sector(typeArc, angle0, angle, valpc, idx)
    -- type of arc, start angle, angle of sector, value in %, sector index
    local tcolor
    if typeArc == 'bg' then
      if valpc == 1 then return end
      tcolor = t.bgColor1
    elseif typeArc == 'fg' then
      if valpc == 0 then return end
      tcolor = t.fgColor1
    elseif typeArc == 'bd' then
      tcolor = t.bdColor1
    end

    -- angles for gap sector
    local extDelta = math.atan(t.gapSectors / (2 * t.radius))
    local intDelta = math.atan(t.gapSectors / (2 * t.intRadius))

    -- angles of arcs
    local extAngle = (angle - extDelta * 2) * valpc
    local intAngle = (angle - intDelta * 2) * valpc

    -- colors of sector
    if #tcolor == 1 then
      -- one color
      local vR, vG, vB, vA = rgba_to_r_g_b_a(tcolor[1])
      cairo_set_source_rgba(cr, vR + tcolor[1].dR * idx,
                                vG + tcolor[1].dG * idx,
                                vB + tcolor[1].dB * idx,
                                vA + tcolor[1].dA * idx)
    else
      -- radient color
      local pat = cairo_pattern_create_radial(0, 0, t.intRadius, 0, 0, t.radius)
      for i = 1, #tcolor do
        local vP, vR, vG, vB, vA = tcolor[i][1], rgba_to_r_g_b_a(tcolor[i])
        cairo_pattern_add_color_stop_rgba(pat, vP + tcolor[i].dP * idx,
                                               vR + tcolor[i].dR * idx,
                                               vG + tcolor[i].dG * idx,
                                               vB + tcolor[i].dB * idx,
                                               vA + tcolor[i].dA * idx)
      end
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)
    end

    -- start drawing
    cairo_save(cr)
    -- x axis is parralel to start of sector
    cairo_rotate(cr, angle0 - deg2rad)

    local ri, re = t.intRadius, t.radius

    -- point A
    local angleA

    if t.cap == 'p' then
      angleA = intDelta
      if t.inverseArc and typeArc ~= 'bg' then
        angleA = angle - intAngle - intDelta
      end
      if not(t.inverseArc) and typeArc == 'bg' then
        angleA = intDelta + intAngle
      end
    else
      angleA = extDelta
      if t.inverseArc and typeArc ~= 'bg' then
        angleA = angle - extAngle - extDelta
      end
      if not(t.inverseArc) and typeArc == 'bg' then
        angleA = extDelta + extAngle
      end
    end
    local ax, ay = ri * math.cos(angleA), ri * math.sin(angleA)

    -- point B
    local angleB = extDelta
    if t.cap == 'p' then
      if t.inverseArc and typeArc ~= 'bg' then
        angleB = angle - extAngle - extDelta
      end
      if not(t.inverseArc) and typeArc == 'bg' then
        angleB = extDelta + extAngle
      end
    else
      if t.inverseArc and typeArc ~= 'bg' then
        angleB = angle - extAngle - extDelta
      end
      if not(t.inverseArc) and typeArc == 'bg' then
        angleB = extDelta + extAngle
      end
    end
    local bx, by = re * math.cos(angleB), re * math.sin(angleB)

    -- external arc b -> c
    local b0, b1
    if t.inverseArc then
      if typeArc == 'bg' then
        b0, b1 = extDelta, angle - extDelta - extAngle
      else
        b0, b1 = angle - extAngle - extDelta, angle - extDelta
      end
    else
      if typeArc == 'bg' then
        b0, b1 = extDelta + extAngle, angle - extDelta
      else
        b0, b1 = extDelta, extAngle + extDelta
      end
    end

    -- point d
    local angleC, angleD
    if t.cap == 'p'then
      angleD = angle - intDelta
      if t.inverseArc and typeArc == 'bg' then
        angleD = angle - intDelta - intAngle
      end
      if not(t.inverseArc) and typeArc ~= 'bg' then
        angleD = intDelta + intAngle
      end
    else
      angleD = angle - extDelta
      if t.inverseArc and typeArc == 'bg' then
        angleD = angle - extDelta - extAngle
      end
      if not(t.inverseArc) and typeArc ~= 'bg' then
        angleD = extAngle + extDelta
      end
    end
    local dx, dy = ri * math.cos(angleD), ri * math.sin(angleD)

    -- internal arc d -> a
    local d0, d1
    if t.cap == 'p' then
      if t.inverseArc then
        if typeArc == 'bg' then
          d0, d1 = angle - intDelta - intAngle, intDelta
        else
          d0, d1 = angle - intDelta, angle - intAngle - intDelta
        end
      else
        if typeArc == 'bg' then
          d0, d1 = angle - intDelta, intDelta + intAngle
        else
          d0, d1 = intDelta + intAngle, intDelta
        end
      end
    else
      if t.inverseArc then
        if typeArc == 'bg' then
          d0, d1 = angle - extDelta - extAngle, extDelta
        else
          d0, d1 = angle - extDelta, angle - extAngle - extDelta
        end
      else
        if typeArc == 'bg' then
          d0, d1 = angle - extDelta, extDelta + extAngle
        else
          d0, d1 = extAngle + extDelta, extDelta
        end
      end
    end

    -- draw sector
    cairo_move_to(cr, ax, ay)
    cairo_line_to(cr, bx, by)
    cairo_arc(cr, 0, 0, re, b0, b1)
    cairo_line_to(cr, dx, dy)
    cairo_arc_negative(cr, 0, 0, ri, d0, d1)
    cairo_close_path(cr)

    -- stroke or fill sector
    if typeArc == 'bd' then
      cairo_set_line_width(cr, t.borderSize)
      cairo_stroke(cr)
    else
      cairo_fill(cr)
    end

    cairo_restore(cr)
  end

  -- do value setup
  setup(t)

  -- init cairo context
  cairo_save(cr)
  cairo_translate(cr, t.xc, t.yc)
  cairo_set_line_join(cr, CAIRO_LINE_JOIN_ROUND)
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)

  -- get value
  local value = 0
  if t.name ~= "" then
    value = tonumber(conky_parse(string.format('${%s %s}', t.name, t.arg)))
  else
    value = tonumber(t.arg)
  end
  if value == nil then value = 0 end

  -- init sectors
  -- angle of sector
  local angleA = ((t.endAngle - t.startAngle) / t.sectors) * deg2rad
  -- value of sector
  local valueA = t.max / t.sectors
  -- first angle of sector
  local lastAngle = t.startAngle * deg2rad

  -- draw sectors
  local n0, n1, n2 = 1, t.sectors, 1
  if t.inverseArc then n0, n1, n2 = t.sectors, 1, -1 end
  local index = 0
  for i = n0, n1, n2 do
    index = index + 1
    local valueZ = 1
    local cstA, cstB = (i -1), i
    if t.inverseArc then cstA, cstB = (t.sectors - i), (t.sectors - i + 1) end

    if value > valueA * cstA and value < valueA * cstB then
      if not(t.fillSector) then
        valueZ = (value - valueA * cstA) / valueA
      end
    else
      if value < valueA * cstB then valueZ = 0 end
    end

    local startAngle = lastAngle + (i - 1) * angleA
    if t.foreground ~= false then
      if t.allSectors then
        draw_sector('fg', startAngle, angleA, valueZ, index)
      else
        if value == i then
          draw_sector('fg', startAngle, angleA, valueZ, index)
        end
      end
    end
    if t.background ~= false then
      if t.allSectors then
        draw_sector('bg', startAngle, angleA, valueZ, i)
      else
        if value ~= i then
          draw_sector('bg', startAngle, angleA, 0, i)
        end
      end
    end
    if t.borderSize > 0 then draw_sector('bd', startAngle, angleA, 1, i) end
  end

  cairo_restore(cr)
end

-- draw text
function draw_text(cr, t)
  local function widthandheight(txt)
    local text = txt
    extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    return extents.width, extents.x_bearing, extents.height, extents.y_bearing
  end

  local font = t.font or "Mono"
  local size = t.size or 12
  local slant = t.slant or CAIRO_FONT_SLANT_NORMAL
  local face = t.face or CAIRO_FONT_WEIGHT_NORMAL
  cairo_select_font_face(cr, font, slant, face)
  cairo_set_font_size(cr, size)
  cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.color))
  w, xb, h, yb = widthandheight(t.text)
  if t.x ~= nil then
    x = t.x
  elseif t.xc ~= nil then
    x = t.xc - (w / 2 + xb)
  elseif t.xr ~= nil then
    x = t.xr - w - xb
  end
  if t.y ~= nil then
    y = t.y
  elseif t.yc ~= nil then
    y = t.yc - (h / 2 + yb)
  elseif t.yt ~= nil then
    y = t.yt - yb
  end
  cairo_save(cr)
  cairo_move_to(cr, x, y)
  if t.rotate then cairo_rotate(cr, (math.rad(t.theta))) end
  cairo_show_text(cr, t.text)

  -- help lines when test is 'testing'
  --if t.text == "testing" then
  --  cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
  --  cairo_set_line_width(cr, 6)
  --  cairo_arc(cr, x, y, 10, 0, 2 * math.pi)
  --  cairo_fill(cr)
  --  cairo_move_to(cr, x, y)
  --  cairo_rel_line_to(cr, 0, -h)
  --  cairo_rel_line_to(cr, w, 0)
  --  cairo_rel_line_to(cr, xb, -yb)
  --end

  cairo_stroke(cr)
  cairo_restore(cr)
end

-- fancy text
function draw_fancy_text(cr, t)
  if t.drawMe == true then t.drawMe = nil end
  if t.drawMe ~= nil and conky_parse(tostring(t.drawMe)) ~= "1" then return end

  local function linear_orientation(t, te)
    local w, h = te.width, te.height
    local xb, yb = te.x_bearing, te.y_bearing

    if t.hAlign == 'c' then
      xb = xb - w / 2
    elseif t.hAlign == 'r' then
      xb = xb - w
    end
    if t.vAlign == 'm' then
      yb = yb - h / 2
    elseif t.vAlign == 't' then
      yb = 0
    end
    local p = 0
    if t.orientation == 'nn' then
      p = {xb + w / 2, yb, xb + w / 2, yb + h}
    elseif t.orientation == 'ne' then
      p = {xb + w, yb, xb, yb + h}
    elseif t.orientation == 'ww' then
      p = {xb, h / 2, xb + w, h / 2}
    elseif t.orientation == 'se' then
      p = {xb + w, yb + h, xb ,yb}
    elseif t.orientation == 'ss' then
      p = {xb + w / 2, yb + h, xb + w / 2, yb}
    elseif t.orientation == 'ee' then
      p = {xb + w, h / 2, xb, h / 2}
    elseif t.orientation == 'sw' then
      p = {xb, yb + h, xb + w, yb}
    elseif t.orientation == 'nw' then
      p = {xb, yb, xb + w, yb + h}
    end
    return p
  end

  local function set_pattern(te)
    if #t.color == 1 then
      cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.color[1]))
    else
      local pat

      if t.radial == nil then
        local pts = linear_orientation(t, te)
        pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
      else
        pat = cairo_pattern_create_radial(t.radial[1], t.radial[2], t.radial[3], t.radial[4], t.radial[5], t.radial[6])
      end

      for i = 1, #t.color do
        cairo_pattern_add_color_stop_rgba(pat, t.color[i][1], rgba_to_r_g_b_a(t.color[i]))
      end
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)
    end
  end

  -- set defaults
  if t.text == nil then t.text = 'Fancy text' end
  if t.x == nil then t.x = cWidth / 2 end
  if t.y == nil then t.y = cHeight / 2 end
  if t.color == nil then t.color = {{1, color.white, 1}} end
  if t.font == nil then t.font = "Mono" end
  if t.size == nil then t.size = 14 end
  if t.angle == nil then t.angle = 0 end
  if t.italic == nil then t.italic = false end
  if t.oblique == nil then t.oblique = false end
  if t.bold == nil then t.bold = false end
  if t.radial ~= nil then
    if #t.radial ~= 6 then
      print('Error in radial table')
      t.radial = nil
    end
  end
  if t.orientation == nil then t.orientation = 'ww' end
  if t.hAlign == nil then t.hAlign = 'l' end
  if t.vAlign == nil then t.vAlign = 'b' end
  if t.reflectionAlpha == nil then t.reflectionAlpha = 0 end
  if t.reflectionLength == nil then t.reflectionLength = 1 end
  if t.reflectionScale == nil then t.reflectionScale = 1 end
  if t.skewX == nil then t.skewX = 0 end
  if t.skewY == nil then t.skewY = 0 end
  cairo_translate(cr, t.x, t.y)
  cairo_rotate(cr, t.angle * deg2rad)
  cairo_save(cr)

  local slant = CAIRO_FONT_SLANT_NORMAL
  local weight = CAIRO_FONT_WEIGHT_NORMAL
  if t.italic then slant = CAIRO_FONT_SLANT_ITALIC end
  if t.oblique then slant = CAIRO_FONT_SLANT_OBLIQUE end
  if t.bold then weight = CAIRO_FONT_WEIGHT_BOLD end

  cairo_select_font_face(cr, t.font, slant, weight)

  for i = 1, #t.color do
    if #t.color[i] ~= 3 then
      print('Error in color table')
      t.color[i] = {1, color.white, 1}
    end
  end

  local matrix0 = cairo_matrix_t:create()
  tolua.takeownership(matrix0)
  local skewX, skewY = t.skewX / t.size, t.skewY / t.size
  cairo_matrix_init(matrix0, 1, skewY, skewX, 1, 0, 0)
  cairo_transform(cr, matrix0)
  cairo_set_font_size(cr, t.size)
  local te = cairo_text_extents_t:create()
  tolua.takeownership(te)
  t.text = conky_parse(t.text)
  cairo_text_extents(cr, t.text, te)
  set_pattern(te)

  local mx, my = 0, 0
  
  if t.hAlign == 'c' then
    mx = -te.width / 2 - te.x_bearing
  elseif t.hAlign == 'r' then
    mx = -te.width
  end
  if t.vAlign == 'm' then
    my = -te.height / 2 - te.y_bearing
  elseif t.vAlign == 't' then
    my = -te.y_bearing
  end
  cairo_move_to(cr, mx, my)
  cairo_show_text(cr, t.text)

  if t.reflectionAlpha ~= 0 then
    local matrix1 = cairo_matrix_t:create()
    tolua.takeownership(matrix1)
    cairo_set_font_size(cr, t.size)

    cairo_matrix_init(matrix1, 1, 0, 0, -1 * t.reflectionScale, 0, (te.height + te.y_bearing + my) * (1 + t.reflectionScale))
    cairo_set_font_size(cr, t.size)
    te = nil
    local te = cairo_text_extents_t:create()
    tolua.takeownership(te)
    cairo_text_extents(cr, t.text, te)

    cairo_transform(cr, matrix1)
    set_pattern(te)
    cairo_move_to(cr, mx, my)
    cairo_show_text(cr, t.text)

    local pat2 = cairo_pattern_create_linear(0, (te.y_bearing + te.height + my), 0, te.y_bearing + my)
    cairo_pattern_add_color_stop_rgba(pat2, 0, 1, 0, 0, 1 - t.reflectionAlpha)
    cairo_pattern_add_color_stop_rgba(pat2, t.reflectionLength, 0, 0, 0, 1)

    -- line not drawn but w/ size 0, mask won't be nice
    cairo_set_line_width(cr, 1)
    local dy = te.x_bearing
    if dy < 0 then dy = dy * (-1) end
    cairo_rectangle(cr, mx + te.x_bearing, te.y_bearing + te.height + my, te.width + dy, -te.height * 1.05)
    cairo_clip_preserve(cr)
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR)
    cairo_stroke(cr)
    cairo_mask(cr, pat2)
    cairo_pattern_destroy(pat2)
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
    te = nil
  end

  cairo_restore(cr)

end

-- draw clock
function draw_clock(cr, t)

  -- angles for hands
  local gamma = deg90rad - math.atan(t.radS / (t.radius * t.lenS))
  local secArc = (deg360rad / 60) * time.seconds
  local secArc0 = secArc - gamma
  local secArc1 = secArc + gamma

  gamma = deg90rad - math.atan(t.radM / (t.radius * t.lenM))
  local minArc = (deg360rad / 60) * time.minutes + secArc/60
  local minArc0 = minArc - gamma
  local minArc1 = minArc + gamma

  gamma = deg90rad - math.atan(t.radH / (t.radius * t.lenH))
  local hourArc = (deg360rad/ 24) * time.twofour + minArc/24 + deg180rad
  local hourArc0 = hourArc - gamma
  local hourArc1 = hourArc + gamma

  -- drawing hands func
  local function draw_hand(arc, arc0, arc1, lg, r, fgColor, borderSize, borderColor, shadowColor)

    -- calculations
    local xx = t.xc + t.radius * math.sin(arc) * lg
    local yy = t.yc - t.radius * math.cos(arc) * lg
    local x0 = t.xc + r * math.sin(arc0)
    local y0 = t.yc - r * math.cos(arc0)
    local x1 = t.xc + r * math.sin(arc1)
    local y1 = t.yc - r * math.cos(arc1)

    -- shadow
    if shadowColor ~= nil then
      cairo_move_to(cr, x0, y0)
      cairo_curve_to(cr, x0, y0, xx - t.shdXOff, yy - t.shdYOff, x1, y1)
      cairo_arc(cr, t.xc, t.yc, r, arc1 -deg90rad, arc0-deg90rad)
      pat = cairo_pattern_create_radial(t.xc, t.yc, 0, t.xc, t.yc, (t.radius / 2) * lg)
      cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(shadowColor, t.shdOpacity))
      cairo_pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 0)
      cairo_set_source(cr, pat)
      cairo_fill(cr)
    end

    -- border
    if borderSize > 0 and borderColor ~= nil then
      cairo_set_line_width(cr, borderSize)
      pat = cairo_pattern_create_radial(t.xc, t.yc, t.radius / 10, t.xc, t.yc, t.radius * lg)
      cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(borderColor, 1))
      cairo_pattern_add_color_stop_rgba(pat, 0.75, 0, 0, 0, 1)
      cairo_set_source(cr, pat)
      -- header
      cairo_move_to(cr, x0, y0)
      cairo_curve_to(cr, x0, y0, xx, yy, x1, y1)
      -- footer
      cairo_arc(cr, t.xc, t.yc, r, arc1 - deg90rad, arc0 - deg90rad)
      cairo_stroke(cr)
    end

    if borderSize > 0 and borderColor == nil then
      print('Error: try to draw a border with color set to nil')
    end

    -- hand
    if fgColor ~= nil then
      cairo_move_to(cr, x0, y0)
      cairo_curve_to(cr, x0, y0, xx, yy, x1, y1)
      cairo_arc(cr, t.xc, t.yc, r, arc1 - deg90rad, arc0 - deg90rad)
      pat = cairo_pattern_create_radial(t.xc, t.yc, t.radius / 10, t.xc, t.yc, t.radius * lg)
      cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(fgColor, 1))
      cairo_pattern_add_color_stop_rgba(pat, 0.75, 0, 0, 0, 1)
      cairo_set_source(cr, pat)
      cairo_fill(cr)
    end
    cairo_pattern_destroy(pat)
  end

  -- draw hands
  draw_hand(hourArc, hourArc0, hourArc1, t.lenH, t.radH, t.fgH, t.bsH, t.bfgH, t.shdH)
  draw_hand(minArc, minArc0, minArc1, t.lenM, t.radM, t.fgM, t.bsM, t.bfgM, t.shdM)
  draw_hand(secArc, secArc0, secArc1, t.lenS, t.radS, t.fgS, t.bsS, t.bfgS, t.shdS)

  -- draw dot
  if t.dotPc > 0 then

    local lgShadowCenter = 5
    local radius = math.min(t.radH, t.radM, t.radS)
    if radius < 1 then radius = 1 end
    local ang = math.atan(t.shdYOff / t.shdXOff)

    if t.shdXOff >= 0 then ang = ang + deg90rad end
    if t.shdXOff < 0 then  ang = ang - deg90rad end

    local x0 = t.xc + radius * math.sin(ang - deg90rad)
    local y0 = t.yc - radius * math.cos(ang - deg90rad)
    local xx = t.xc + radius * math.sin(ang - deg180rad) * t.dotShdLen
    local yy = t.yc - radius * math.cos(ang - deg180rad) * t.dotShdLen
    local x1 = t.xc - radius * math.sin(ang - deg90rad)
    local y1 = t.yc + radius * math.cos(ang - deg90rad)

    cairo_move_to(cr, x0, y0)
    cairo_curve_to(cr, x0, y0, xx, yy, x1, y1)

    local pat = cairo_pattern_create_radial(t.xc, t.yc, 0, t.xc, t.yc, radius * 2)
    cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(t.dotShdColor, t.shdOpacity))
    cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(t.dotShdColor, 0))
    cairo_set_source(cr, pat)
    cairo_fill(cr)

    -- gradient
    local xshad = t.xc + radius * math.sin(ang) * .5
    if t.shdXOff == 0 then xshad = t.xc end
    local yshad = t.yc - radius * math.cos(ang) * .5
    if t.shdYOff == 0 then yshad = t.yc end
    local dsPat = cairo_pattern_create_radial(t.xc, t.yc, 0, xshad, yshad, radius)
    cairo_pattern_add_color_stop_rgba(dsPat, 0, rgb_a_to_r_g_b_a(t.dotColor, 1))
    cairo_pattern_add_color_stop_rgba(dsPat, 1, 0, 0, 0, 1)

    cairo_arc(cr, t.xc, t.yc, radius, 0, deg360rad)
    cairo_set_source(cr, dsPat)
    cairo_fill(cr)
  end
end

function degreeToCardinal(deg)
    directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "N", ""}
    closestDeg = deg ~= nil and round((deg % 360) / 45) or 10
    return directions[closestDeg+1]
end

function sunAmount(sunr, suns, tSun)
    local offTime, offSs = 0, 0
    tSun.percent = 0
    local lSunrise = os.date("*t", sunr)
    local lSunset = os.date("*t", suns)
    local secTime = time.twofour * 60 * 60 + time.minutes * 60 + time.seconds
    local minTime = time.twofour * 60 * time.minutes
    tSun.secRise = lSunrise.hour * 60 * 60 + lSunrise.min * 60 + lSunrise.sec
    tSun.secSet = lSunset.hour * 60 * 60 + lSunset.min * 60 + lSunset.sec
    tSun.secOSet = 86400 - tSun.secSet
    local durDay = suns - sunr
    tSun.durPct = string.format('%.0f', math.ceil(durDay / 86400 * 100))
    tSun.durHrs = math.floor(durDay / (60 * 60))
    tSun.durMin = math.floor((durDay % (60 * 60)) / 60)
    tSun.durSec = math.floor(durDay % 60)
    local secMid = durDay / 2
    tSun.midDay = tSun.secRise + secMid
    local dltLeft = os.difftime(tSun.secSet, secTime)
    tSun.left = math.floor(dltLeft / (60 * 60)) .. ':' .. string.format("%02d", math.floor((dltLeft % (60 * 60)) / 60))
    if secTime > tSun.secRise and secTime < tSun.secSet then
        offTime = secTime - tSun.secRise
        offSs = tSun.secSet - tSun.secRise
        tSun.percent = tonumber(string.format('%.0f', offTime / offSs * 100))
    end
    --print("sunset", sun.secOSet, "sunrise", sun.secRise)
    --print(tSun.durHrs, tSun.durMin, tSun.durSec, tSun.durPct)
    --print(lSunrise.hour,lSunrise.min,lSunrise.sec,lSunset.hour,lSunset.min,lSunset.sec, tSun.percent)
end

--function sunAmount(sunr, suns, tSun)
--  local offTime, offSs = 0, 0
--  tSun.percent = 0
--  local lSunrise = string.split(string.gsub(sunr, " [AP]M", ""), ":")
--  local lSunset = string.split(string.gsub(suns, " [AP]M", ""), ":")
--  local secTime = time.twofour * 60 * 60 + time.minutes * 60 + time.seconds
--  local minTime = time.twofour * 60 + time.minutes
--  local lSr1, lSr2 = tonumber(lSunrise[1]) or 0, tonumber(lSunrise[2]) or 0
--  tSun.secRise = lSr1 * 60 * 60 + lSr2 * 60
--  local lSs1, lSs2 = tonumber(lSunset[1]) or 0, tonumber(lSunset[2]) or 0
--  tSun.secSet = (lSs1 + 12) * 60 * 60 + lSs2 * 60
--  tSun.secOSet = 86400 - tSun.secSet
--  local durDay = tSun.secSet - tSun.secRise
--  tSun.durPct = string.format('%.0f', math.ceil(durDay / 86400 * 100))
--  tSun.durHrs = math.floor(durDay / (60 * 60))
--  tSun.durMin = math.floor((durDay % (60 * 60)) / 60)
--  tSun.durSec = math.floor(durDay % 60)
--  tSun.timePct = string.format('%.0f', math.ceil(minTime / 1440 * 100))
--  local secMid = durDay / 2
--  tSun.midDay = tSun.secRise + secMid
--  local dltLeft = os.difftime(tSun.secSet, secTime)
--  tSun.left = math.floor(dltLeft / (60 * 60)) .. ':' .. string.format("%02d", math.floor((dltLeft % (60 * 60)) / 60))
--  if secTime > tSun.secRise and secTime < tSun.secSet then
--    offTime = secTime - tSun.secRise
--    offSs = tSun.secSet - tSun.secRise
--    tSun.percent = tonumber(string.format('%.0f', offTime / offSs * 100))
--  end
--end

-- draw pie
function draw_pie(cr, t)

  if t.drawMe == true then t.drawMe = nil end
  if t.drawMe ~= nil and conky_parse(tostring(t.drawMe)) ~= "1" then return end

  local lastAngle
  local lastPt2
  local tableV
  if t.tableV == nil then
    print('No input values ...')
    return
  else
    tableV = t.tableV
  end

  if t.xc == nil then t.xc = cWidth / 2 end
  if t.yc == nil then t.yc = cHeight / 2 end
  if t.radiusInt == nil then t.radiusInt = cWidth / 6 end
  if t.radiusExt == nil then t.radiusExt = cHeight / 4 end
  if t.sun == nil then t.sun = false end
  if t.firstAngle == nil then t.firstAngle = 0 end
  if t.lastAngle == nil then t.lastAngle = 360 end
  if t.proportional == nil then t.proportional = false end
  if t.tablebg == nil then t.tablebg = {{color.white, 0.5}, {color.white, 0.5}} end
  if t.tablefg == nil then t.tablefg = {{color.scarlet, 1}, {color.green, 1}} end
  if t.gradientEffect == nil then t.gradientEffect = true end
  if t.showText == nil then t.showText = true end
  if t.lineLength == nil then t.lineLength = t.radiusInt end
  if t.lineSpace == nil then t.lineSpace = 10 end
  if t.lineThickness == nil then t.lineThickness = 1 end
  if t.extendLine == nil then t.extendLine = true end
  if t.fontName == nil then t.fontName = 'Japan' end
  if t.fontSize == nil then t.fontSize = 12 end
  if t.fontColor == nil then t.fontColor = color.white end
  if t.fontAlpha == nil then t.fontAlpha = 1 end
  if t.txtOffset == nil then t.txtOffset = 1 end
  if t.txtFormat == nil then t.txtFormat = "&l : &v" end
  if t.nbDecimals == nil then t.nbDecimals = 1 end
  if t.typeArc == nil then t.typeArc = 'l' end
  if t.inverseLArc == nil then t.inverseLArc = false end

  local radiuspc
  local angle0
  local function draw_sector(tablecolor, colorindex, pc, lastAngle, angle, radius, radiusInt, gradientEffect, typeArc, inverseLArc)
    -- draw portion of arc
    radiuspc = (radius - radiusInt) * pc + radiusInt
    angle0 = lastAngle
    local val = 1
    if typeArc == 'l' then
      val = pc
      radiuspc = radius
    end
    local angle1 = angle * val

    if typeArc == 'l' and inverseLArc then

      cairo_save(cr)
      cairo_rotate(cr, angle0 + angle)

      if gradientEffect then
        local pat = cairo_pattern_create_radial(0, 0, radiusInt, 0, 0, radius)
        cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], 0))
        cairo_pattern_add_color_stop_rgba(pat, 0.5, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], tablecolor[colorindex][2]))
        cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(tablecolor[colorindex][1],0))
        cairo_set_source(cr, pat)
        cairo_pattern_destroy(pat)
      else
        cairo_set_source_rgba(cr, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], tablecolor[colorindex][2]))
      end
      cairo_move_to(cr, 0, -radiusInt)
      cairo_line_to(cr, 0, -radiuspc)
      cairo_rotate(cr, -deg90rad)

      cairo_arc_negative(cr, 0, 0, radiuspc, 0, -angle1)
      cairo_rotate(cr, -deg90rad - angle1)
      cairo_line_to(cr, 0, radiusInt)
      cairo_rotate(cr, deg90rad)
      cairo_arc(cr, 0, 0, radiusInt, 0, angle1)
      cairo_close_path(cr)
      cairo_fill(cr)

      cairo_restore(cr)
    else

      cairo_save(cr)
      cairo_rotate(cr, angle0)

      if gradientEffect then
        local pat = cairo_pattern_create_radial(0, 0, radiusInt, 0, 0, radius)
        cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(tablecolor[colorindex][1],0))
        cairo_pattern_add_color_stop_rgba(pat, 0.5, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], tablecolor[colorindex][2]))
        cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], 0))
        cairo_set_source(cr, pat)
        cairo_pattern_destroy(pat)
      else
        cairo_set_source_rgba(cr, rgb_a_to_r_g_b_a(tablecolor[colorindex][1], tablecolor[colorindex][2]))
      end
      cairo_move_to(cr, 0, -radiusInt)
      cairo_line_to(cr, 0, -radiuspc)
      cairo_rotate(cr, -deg90rad)
      cairo_arc(cr, 0, 0, radiuspc, 0, angle1)
      cairo_rotate(cr, angle1 - deg90rad)
      cairo_line_to(cr, 0, radiusInt)
      cairo_rotate(cr, deg90rad)
      cairo_arc_negative(cr, 0, 0, radiusInt, 0, -angle1)
      cairo_close_path(cr)
      cairo_fill(cr)
      cairo_restore(cr)
    end
  end

  local function draw_lines(idx, nbArcs, angle, tableColors, idxColor, adjust, lineLength, lengthTxt, txtOffset, radius, lineThickness, lineSpace, fontColor, fontAlpha)
    --draw lines
    local x0 = radiuspc * math.sin(lastAngle + angle / 2)
    local y0 = -radiuspc * math.cos(lastAngle + angle / 2)
    local x1 = 1.2 * radius * math.sin(lastAngle + angle / 2)
    local y1 = 1.2 * radius * math.cos(lastAngle + angle / 2)

    local x2 = lineLength
    local y2 = y1
    local x3, y3 = nil, nil
    if x0 <= 0 then
      x2 = -x2
    end

    if adjust then
      if x0 > 0 and x2 - x1 < lengthTxt then x2 = x1 + lengthTxt end
      if x0 <= 0 and x1 - x2 < lengthTxt then x2 = x1 - lengthTxt end
    end

    if idx > 1 then
      local dY = math.abs(y2 - lastPt2[2])
      if dY < lineSpace and lastPt2[1] * x1 > 0 then
        if x0 > 0 then
          y2 = lineSpace + lastPt2[2]
        else
          y2 = -lineSpace + lastPt2[2]
        end
        if (y2 > y1 and x0 > 0) or (y2 < y1 and x0 < 0) then
          -- x3 is for vertical segment if needed
          x3, y3 = x2, y2
          x2 = x1
          if x3 > 0 then x3 = x3 + txtOffset end
        else
          local Z = intercept({x0, y0}, {x1, y1}, {0, y2}, {1, y2})
          x1, y1 = Z[1], Z[2]
        end
      end
    end

    if fontColor == nil then
      cairo_set_source_rgba(cr, rgb_a_to_r_g_b_a(tableColors[idxColor][1], tableColors[idxColor][2]))
    else
      local pat = cairo_pattern_create_linear(x2, y2, x0, y0)
      cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(fontColor, fontAlpha))
      cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(tableColors[idxColor][1], tableColors[idxColor][2]))
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)
    end

    cairo_move_to(cr, x0, y0)
    cairo_line_to(cr, x1, y1)
    cairo_line_to(cr, x2, y2)
    if x3 ~= nil then
      cairo_line_to(cr, x3, y3)
      x2, y2 = x3, y3
    end
    cairo_set_line_width(cr, lineThickness)
    cairo_stroke(cr)
    --lastAngle = lastAngle + angle
    return {x2, y2}
  end

  local function intercept(p11, p12, p21, p22)
    -- calculate intersection of two lines and return coordinates
    local a1 = (p12[2] - p11[2]) / (p12[1] - p11[1])
    local a2 = (p22[2] - p21[2]) / (p22[1] - p21[1])
    local b1 = p11[2] - a1 * p11[1]
    local b2 = p21[2] - a2 * p21[1]
    local X = (b2 - b1) / (a1 - a2)
    local Y = a1 * X + b1
    return {X, Y}
  end

  -- checks
  if t.firstAngle >= t.lastAngle then
    local tmpAngle = t.lastAngle
    t.lastAngle = t.firstAngle
    t.firstAngle = tmpAngle
    --print('inversed first and last angles')
  end

  if t.lastAngle - t.firstAngle > 360 and t.firstAngle > 0 then
    t.lastAngle = 360 + t.firstAngle
    print('reduce angles')
  end

  if t.lastAngle + t.firstAngle > 360 and t.firstAngle <= 0 then
    t.lastAngle = 360 + t.firstAngle
    print('reduce angles')
  end

  if t.radiusInt < 0 then t.radiusInt = 0 end
  if t.radiusInt > t.radiusExt then
    local tmpRadius = t.radiusExt
    t.radiusExt = t.radiusInt
    t.radiusInt = tmpRadius
    print('inversed internal radius and external radius')
  end
  if t.radiusInt == t.radiusExt then
    t.radiusInt = 0
    print('int radiusExt set for 0')
  end

  cairo_save(cr)
  cairo_translate(cr, t.xc, t.yc)
  cairo_set_line_join(cr, CAIRO_LINE_JOIN_ROUND)
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)

  local nbArcs = #tableV
  local anglefull = (t.lastAngle - t.firstAngle) * deg2rad
  local fullsize = 0
  for i = 1, nbArcs do
    fullsize = fullsize + tableV[i][4]
  end

  local cb, cf, angle = 0, 0, anglefull / nbArcs
  lastAngle = t.firstAngle * deg2rad
  lastPt2 = {nil, nil}

  for i = 1, nbArcs do
    if t.proportional then
      angle = tableV[i][4] / fullsize * anglefull
    end

    -- set colors
    cb, cf = cb + 1, cf + 1
    if cb > #t.tablebg then cb = 1 end
    if cf > #t.tablefg then cf = 1 end

    local str
    if tableV[i][2] ~= "" then
      str = string.format('${%s %s}', tableV[i][2], tableV[i][3])
    else
      str = tableV[i][3]
    end
    if t.sun == false then
      str = conky_parse(str)
    end

    local value = tonumber(str)
    if value == nil then value = 0 end

    -- draw sectors
    draw_sector(t.tablebg, cb, 1, lastAngle, angle, t.radiusExt, t.radiusInt, t.gradientEffect, t.typeArc, t.inverseLArc)
    draw_sector(t.tablefg,cf,value / tableV[i][4], lastAngle, angle, t.radiusExt, t.radiusInt, t.gradientEffect, t.typeArc, t.inverseLArc)

    if t.showText then
      --draw text
      local txtL = tableV[i][1]
      local txtOpc = round(100 * value / tableV[i][4], t.nbDecimals) .. "%%"
      local txtFpc = round(100 * (tableV[i][4] - value / tableV[i][4]), t.nbDecimals) .. "%%"
      local txtOv, txtFv, txtMax
      if tableV[i][5] == true then
        txtOv = size_to_text(value, t.nbDecimals)
        txtFv = size_to_text(tableV[i][4] - value, t.nbDecimals)
        txtMax = size_to_text(tableV[i][4], t.nbDecimals)
      else
        if tableV[i][5] == '%' then tableV[i][5] = "%%" end
        txtOv = string.format("%." .. t.nbDecimals .. "f ", value) .. tableV[i][5]
        txtFv = string.format("%." .. t.nbDecimals .. "f", tableV[i][4] - value) .. tableV[i][5]
        txtMax = string.format("%." .. t.nbDecimals .. "f", tableV[i][4]) .. tableV[i][5]
      end
      local txtPc = string.format("%." .. t.nbDecimals .. "f", 100 * tableV[i][4] / fullsize) .. "%%"
      local txtOut = t.txtFormat
      txtOut = string.gsub(txtOut, "&l", txtL) -- label
      txtOut = string.gsub(txtOut, "&o", txtOpc) -- occ. %
      txtOut = string.gsub(txtOut, "&f", txtFpc) -- free %
      txtOut = string.gsub(txtOut, "&v", txtOv) -- occ. value
      txtOut = string.gsub(txtOut, "&n", txtOv) -- free value
      txtOut = string.gsub(txtOut, "&m", txtOv) -- max
      txtOut = string.gsub(txtOut, "&p", txtOv) -- percent

      local te = cairo_text_extents_t:create()
      tolua.takeownership(te)
      cairo_set_font_size(cr, t.fontSize)
      cairo_select_font_face(cr, t.fontName, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
      cairo_text_extents(cr, txtOut, te)

      -- draw lines
      lastPt2 = draw_lines(i, nbArcs, angle, t.tablefg, cf, t.extendLine, t.lineLength + t.radiusExt, te.width + te.x_bearing, t.txtOffset, t.radiusExt, t.lineThickness, t.lineSpace, t.fontColor, t.fontAlpha)

      local xA = lastPt2[1]
      local yA = lastPt2[2] - t.lineThickness - t.txtOffset
      if xA > 0 then xA = xA - (te.width + te.x_bearing) end
      cairo_move_to(cr, xA, yA)
      cairo_show_text(cr, txtOut)
    end

    lastAngle = lastAngle + angle
  end
  lastAngle = nil
  lastPt2 = nil
  cairo_restore(cr)
end

-- draw calendar support functions
function create_pattern_linear(cr, x, y, w, h, tCol, orientation)
  local col0, col1, alpha0, alpha1 = tCol[1], tCol[2], tCol[3], tCol[4]
  local p = {x, y, x + w, y + h}

  if orientation == "nn" then
    p = {x + w / 2, y, x + w / 2, y + h}
  elseif orientation == "ne" then
    p = {x + w, y, x, y + h}
  elseif orientation == "ee" then
    p = {x + w, y + h / 2, x, y + h / 2}
  elseif orientation == "se" then
    p = {x + w, y + h, x, y}
  elseif orientation == "ss" then
    p = {x + w / 2, y + h, x + w / 2, y}
  elseif orientation == "sw" then
    p = {x, y + h, x + w, y}
  elseif orientation == "ww" then
    p = {x, y, x + w, y + h}
  end

  local pat = cairo_pattern_create_linear(p[1], p[2], p[3], p[4])
  cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(col0, alpha0))
  cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(col1, alpha1))
  cairo_set_source(cr, pat)
  cairo_pattern_destroy(pat)
end

function create_pattern_radial(cr, x, y, w, h, tCol, orientation, gradient)
  local col0, col1, alpha0, alpha1 = tCol[1], tCol[2], tCol[3], tCol[4]
  local decn = gradient
  local dec = 1 - decn
  local p = {x + w * (1 - dec), y + h * (1 - dec)}
  if orientation == "nn" then
    p = {x + w / 2, y + h * decn}
  elseif orientation == "ne" then
    p = {x + w * dec, y + h * decn}
  elseif orientation == "ee" then
    p = {x + w * dec, y + h / 2}
  elseif orientation == "se" then
    p = {x + w * dec, y + h * dec}
  elseif orientation == "ss" then
    p = {x + w / 2, y + h * dec}
  elseif orientation == "sw" then
    p = {x + w * decn, y + h * dec}
  elseif orientation == "ww" then
    p = {x + w * decn, y + h / 2}
  end

  local radius = w / dec
  if h > w then radius = h / dec end
  local pat = cairo_pattern_create_radial(p[1], p[2], 0, p[1], p[2], radius)
  cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(col0, alpha0))
  cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(col1, alpha1))
  cairo_set_source(cr, pat)
  cairo_pattern_destroy(pat)
end

function create_pattern(cr, x, y, w, h, tCol, orientation, gradient)
  if gradient ~= 0 then
    create_pattern_radial(cr, x, y, w, h, tCol, orientation, gradient)
  else
    create_pattern_linear(cr, x, y, w, h, tCol, orientation)
  end
end

function draw_square(cr, x, y, w, h, r)
  local r = tonumber(r)

  cairo_new_sub_path(cr)
  if r > 0 then
    cairo_arc(cr, x + w - r, y + r, r, -deg90rad, 0)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, deg90rad)
    cairo_arc(cr, x + r, y + h - r, r, deg90rad, deg180rad)
    cairo_arc(cr, x + r, y + r, r, deg180rad, deg270rad)
  else
    cairo_rectangle(cr, x, y, w, h)
  end
  cairo_close_path(cr)
  
  return
end

function draw_frame(cr, x, y, w, h, tCol, r, border, orientation, gradient)

  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE)
  create_pattern(cr, x, y, w, h, {tCol[5], tCol[6], tCol[7], tCol[8]}, orientation, gradient)
  draw_square(cr, x, y, w, h, r)
  cairo_set_line_width(cr, border)
  cairo_fill(cr)

  create_pattern(cr, x, y, w, h, {tCol[1], tCol[2], tCol[3], tCol[4]}, orientation, gradient)
  draw_square(cr, x + border, y + border, w - border * 2, h - border * 2, r)
  cairo_fill(cr)

  cairo_set_operator(cr, CAIRO_OPERATOR_OVER)

  if tCol[3] <= 0 and tCol[4] <= 0 then
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR)
  end

  create_pattern(cr, x, y, w, h, {tCol[1], tCol[2], tCol[3], tCol[4]}, orientation, gradient)
  draw_square(cr, x + border, y + border, w - border * 2, h - border * 2, r)
  cairo_fill(cr)
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
end

function calc_max_square_size(cr, font, size, txtExt, tVals, format, border, hpad, vpad)

  local maxSide = 0
  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, size)

  for i, v in ipairs(tVals) do
    cairo_text_extents(cr, string.format(format, v), txtExt)
    local totalWidth = txtExt.width + txtExt.x_bearing + 2 * hpad
    local totalHeight = txtExt.height + txtExt.y_bearing + 2 * vpad
    maxSide = math.max(maxSide, totalWidth, totalHeight)
  end

  maxSide = maxSide + 2 * border

  return maxSide
end

-- Get the weekday of the 1st of the month from current month (or month offset
-- +/- from current month) in 0-6 (Sunday - Saturady) format
function get_first_of_month(tMonth, monthOffset)

  day, weekday = tMonth.day, tMonth.wday
  firstDay = weekday - 1 - (day - 1) % 7
  -- Add 8 when negative b/c lua date table uses 1-7 for weekdays
  if firstDay < 0 then firstDay = firstDay + 7 end

  return firstDay
end

-- get a date table based on month offset
function get_month_table(monthOffset)

  local dateTable = os.date("*t")
  local monthTable = dateTable
  monthTable.month = dateTable.month + monthOffset
  monthTable = os.date("*t", os.time(monthTable))

  return monthTable
end

-- get number of days in a month
function get_days_in_month(month, year)
  local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
  local day = daysInMonth[month]

  -- check leap year
  if (month == 2) then
    if (math.fmod(year, 4) == 0) then
      if (math.fmod(year, 100) == 0) then
        if (math.fmod(year, 400) == 0) then
          day = 29
        end
      else
        day = 29
      end
    end
  end

  return day
end

-- draw calendar
function draw_calendar(cr, t)

  -- default values
  local te = cairo_text_extents_t:create()
  local x0, y0 = t.x, t.y
  local strFormat = "%d"
  local orientation, alignment, monthPos, daysPos, infoPos = "nn", "c", "t", "t", "b"
  
  -- user values
  if t.twoDigits then strFormat = "%02d" end

  for i, v in ipairs({"nn", "ne", "ee", "se", "ss", "sw", "ww", "nw"}) do
    if v == t.orientation then orientation = v end
  end
  for i, v in ipairs({"l", "c", "r"}) do
    if v == t.alignment then alignment = v end
  end
  for i, v in ipairs({"t", "b", "l", "r"}) do
    if v == t.monthPos then monthPos = v end
    if v == t.daysPos then daysPos = v end
    if v == t.infoPos then infoPos = v end
  end

  -- calculate the max side of square
  local days = {}
  for day = 1, 31 do table.insert(days, day) end
  local maxSide = calc_max_square_size(cr, t.font, t.fontSize, te, days, strFormat, t.border, t.hpadding, t.vpadding)

  -- get weekday of first of month and number of days in month
  local dateTable = get_month_table(t.monthOffset)
  local monthTable = get_month_table(t.monthOffset)
  local firstDay = get_first_of_month(monthTable, t.monthOffset)
  local totalDays = get_days_in_month(monthTable.month, monthTable.year)

  -- set current month text format
  local txtMonth = os.date(t.monthFormat, os.time(monthTable))
  txtMonth = string.upper(string.sub(txtMonth, 1, 1)) .. string.sub(txtMonth, 2)
  txtMonth = monthKanji[tonumber(time.month)] .. monthEnd

  -- previous month table
  local prevMonthTable = get_month_table(-1)
  local prevMonthLastDay = get_days_in_month(prevMonthTable.month, prevMonthTable.year)

  -- read calendar file TODO
  local file = io.open(t.calendarFile, "r")
  local infoTable = {}
  local idx = 1
  local line, likeok = "", ""
  local txtInfo = ""
  if file ~= nil then
    while true do
      line = file:read("*l")
      if line == nil then break end
      lineok = string.split(line, ";")
      if #lineok == 3 then
        infoTable[idx] = {lineok[1], lineok[2], lineok[3]}
        idx = idx + 1
        if lineok[1] == os.date("%m%d", os.time()) then
          txtInfo = lineok[3]
        end
      end
    end
  end
  if not t.displayEmptyInfoBox and txtInfo == "" then
    t.displayInfoBox = false
  end
  if not t.displayInfoBox then infoPos = "b" end
  local nInfoLines = idx - 1
  io.close()

  -- table for weekday names
  weekdayNames = weekdayKanji

  -- draw
  local displayDay, flagEnd, day = true, 0, 0
  local X, Y = 0, 0
  local monthDay = ""
  local delta = 0

  -- get total width and height
  local totalW, totalH = 7 * maxSide + t.gap * 7, 7 * maxSide + t.gap * 5
  totalH = totalH + maxSide + t.gap
  if monthPos == "t" or monthPos == "b" then
    totalH = totalH + maxSide + t.gap
  else
    totalW = totalW + maxSide + t.gap
  end

  -- get current week in terms of cWeek
  tmpDay = day
  for cWeek = 0, 5 do
    for cDay = 0, 6 do
      tmpDay = tmpDay + 1
      if dateTable.day == tmpDay - firstDay and t.monthOffset == 0 then
        time.weekNow = cWeek
        break
      end
    end
  end

  -- run through weeks
  for cWeek = 0, 5 do

    -- stop when flagged at end
    if flagEnd > 0 then break end

    -- run through days
    for cDay = 0, 6 do

      day = day + 1

      -- get x, y pos, set text to -
      X = x0 + cDay * maxSide + t.gap * cDay - (totalW / 2)
      Y = y0 + cWeek * maxSide + t.gap * cWeek - (totalH / 2)
      local txtDay = "-"
      local txtColor = t.colBoxText
      local txtSize = t.fontSize

      -- check where boxes are to place proper position
      if monthPos == "t" then
        Y = Y + maxSide + t.gap
      elseif monthPos == "l" then
        X = X + maxSide + t.gap
      end

      if infoPos == "t" then
        Y = Y + maxSide + t.gap
      elseif infoPos == "l" then
        X = X + maxSide + t.gap
      end

      if daysPos == "t" then
        Y = Y + maxSide + t.gap
      end

      -- check if this is a special day
      monthTable = get_month_table(t.monthOffset)
      monthTable.day = day - firstDay
      monthDay = os.date("%m%d", os.time(monthTable))

      -- highlight holidays
      local flagHoliday = false
      for idy = 1, nInfoLines do
        if infoTable[idy][1] == monthDay then
          if infoTable[idy][2] == "1" then
            flagHoliday = true
          end
          break
        end
      end

      -- draw frames
      local colorBox = t.colBox
      local border = t.border
      --if (day - firstDay > 0 and day - firstDay <= totalDays) and  cWeek == (time.weekNum - weeksTo(table.slice(mthWeeks, 1, tonumber(time.month) - 1 % 12)) - 1) then
      if (day - firstDay >0 and day - firstDay <= totalDays and cWeek == time.weekNow and t.monthOffset == 0) then
        colorBox = t.colBoxCurrentWeek
      end
      if dateTable.day == day - firstDay and t.monthOffset == 0 then
        colorBox = t.colBoxToday
        border = t.border * 2
      elseif flagHoliday then
        if day <= firstDay then
          colorBox = t.colBoxHolidayBefore
        elseif day - firstDay > 0 and day - firstDay <= totalDays then
          colorBox = t.colBoxHoliday
        else
          colorBox = t.colBoxHolidayAfter
        end
      end
      draw_frame(cr, X, Y, maxSide, maxSide, colorBox, t.radius, border, orientation, t.gradient)

      -- format text
      if day <= firstDay then
        txtDay = prevMonthLastDay - firstDay + day
        txtColor = t.colBoxTextBefore
        if flagHoliday == true then
          txtColor = t.colBoxTextHolidayBefore
        end
        displayDay = t.displayOtherDays
      elseif day - firstDay > 0 and day - firstDay <= totalDays then
        txtDay = day - firstDay
        if txtDay == dateTable.day and t.monthOffset == 0 then
          txtColor = t.colBoxTextToday
          txtSize = t.fontSizeToday
        elseif flagHoliday then
          txtColor = t.colBoxTextHoliday
        elseif txtDay > dateTable.day and t.monthOffset == 0 then
          txtColor = t.colBoxTextUpcoming
        --elseif  cWeek == (time.weekNum - weeksTo(table.slice(mthWeeks, 1, tonumber(time.month) - 1 % 12)) - 1) then
        elseif (cWeek == time.weekNow and t.monthOffset == 0) then
          txtColor = t.colBoxTextCurrentWeek
        end
        displayDay = true
      else
        txtDay = day - firstDay - totalDays
        txtColor = t.colBoxTextAfter
        if flagHoliday == true then
          txtColor = t.colBoxTextHolidayAfter
        end
        displayDay = t.displayOtherDays
      end

      create_pattern(cr, X, Y, maxSide * (1 - t.gradient), maxSide * (1 - t.gradient), txtColor, orientation, t.gradient)

      -- show text
      if displayDay then
        cairo_set_font_size(cr, txtSize)
        cairo_text_extents(cr, string.format(strFormat, txtDay), te)

        if alignment == "r" then
          delta = maxSide - te.width - te.x_bearing - t.border - t.hpadding
        elseif alignment == "c" then
          delta = (maxSide - te.width) / 2 - te.x_bearing
        else
          delta = t.border + t.hpadding
        end

        cairo_move_to(cr, X + delta, Y + maxSide / 2 + te.height / 2)
        cairo_show_text(cr, string.format(strFormat, txtDay))
      end

      -- check end
      if day - firstDay >= totalDays then
        flagEnd = cWeek
      end
    end
  end


  -- show weekday names
  if daysPos == "t" then
    Y = y0 - (totalH / 2)
    if monthPos == "t" then Y = Y + maxSide + t.gap end
    if infoPos == "t" then Y = Y + maxSide + t.gap end
  else
    Y = y0 + (flagEnd + 1) * (maxSide + t.gap) - (totH / 2)
  end

  local deltaX = 0

  if monthPos == "l" then deltaX = deltaX + maxSide + t.gap end
  if infoPos == "l" then deltaX = deltaX + maxSide + t.gap end
  flagEnd = flagEnd + 1

  for cDay = 0, 6 do
    X = x0 + cDay * maxSide + t.gap * cDay + deltaX - (totalW / 2)
    local colorDay = t.colBoxDays
    local colorDayText = t.colBoxDaysText
    local border = t.border
    colorDay[5], colorDay[6] = weekdayColor[cDay + 1], weekdayColor[cDay + 1]
    colorDayText[1], colorDayText[2] = weekdayColor[cDay + 1], weekdayColor[cDay + 1]
    if (cDay + 1) == time.weekday then
      border = t.border * 3
      colorDay[7], colorDay[8] = 0.5, 0.5
    else
      colorDay[7], colorDay[8] =  0.25, 0.25
    end
    draw_frame(cr, X, Y, maxSide, maxSide, colorDay, t.radius, border, orientation, t.gradient)
    cairo_save(cr)
    cairo_select_font_face(cr, t.fontWeekday, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, t.fontSizeWeekday)
    cairo_text_extents(cr, weekdayNames[cDay + 1], te)
    local ratio = (maxSide - 2 * t.border - 2 * t.hpadding) / (te.width + te.x_bearing + t.border + t.hpadding)
    if ratio > 1 then ratio = 1 end
    local xm = X + t.hpadding + (maxSide - 2 * t.hpadding - te.width) / 2 - te.x_bearing
    local ym = Y + (maxSide + te.height) / 2
    if ratio < 1 then xm = X + t.border + t.hpadding end

    if alignment == "r" then
      delta = maxSide - te.width - te.x_bearing - t.border - t.hpadding
    elseif alignment == "c" then
      delta = (maxSide - te.width) / 2 - te.x_bearing
    else
      delta = t.border + t.hpadding
    end

    cairo_move_to(cr, xm, ym)
    create_pattern(cr, X, Y, maxSide, maxSide, colorDayText, orientation, t.gradient)
    cairo_save(cr)
    --cairo_scale(cr, ratio, 1)
    cairo_show_text(cr, weekdayNames[cDay+1])
    cairo_restore(cr)
  end

  -- function to show big box (month, info)
  local function show_big_box(txt, box, pos)
    if box == "month" then
      cairo_select_font_face(cr, t.fontMonth, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
      cairo_set_font_size(cr, t.fontSizeMonth)
    else
      cairo_select_font_face(cr, t.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
      cairo_set_font_size(cr, t.fontSize)
    end
    cairo_text_extents(cr, txt, te)

    local hbox = {width = maxSide * 7 + t.gap * 6, height = maxSide}
    local vbox = {width = maxSide, height = maxSide * (flagEnd + 1) + t.gap * flagEnd}
    local deltaX, deltaY = 0, 0
    local tColor, tColorText = {}, {}
    local lX0 = x0 - (totalW / 2)
    local lY0 = y0 - (totalH / 2)

    if box == "month" then
      tColor = t.colBoxMonth
      tColorText = t.colBoxMonthText

      if infoPos == "l" or infoPos == "r" then
        hbox = {width = maxSide * 8 + t.gap * 7, height = maxSide}
      end
      if infoPos == "l" then deltaX = maxSide + t.gap end
      if infoPos == "t" and monthPos == "t" then deltaY = maxSide + t.gap end
      if (monthPos == "l" or monthPos == "r") and infoPos == "t" then
        deltaY = maxSide + t.gap
      end
      if monthPos == "b" and infoPos == "t" then deltaY = maxSide + t.gap end
    elseif box == "info" then
      tColor = t.colBoxInfo
      tColorText = t.colBoxInfoText

      if monthPos == "l" or monthPos == "r" then
        hbox = {width = maxSide * 8 + t.gap * 7, height = maxSide}
      end
      if monthPos == "r" or infoPos == "r" then deltaX = maxSide + t.gap end
      if monthPos == "t" and (infoPos == "l" or infoPos == "r") then
        deltaY = maxSide + t.gap
      end
      if monthPos == "t" and infoPos == "b" then deltaY = maxSide + t.gap end
      if monthPos == "b" then
        vbox = {width = maxSide, height = maxSide * flagEnd + t.gap * (flagEnd-1)}
      end
    else
      return
    end

    if pos == "b" then
      flagEnd = flagEnd + 1
      draw_frame(cr, lX0, lY0 + flagEnd * (maxSide + t.gap) + deltaY, hbox.width, hbox.height, tColor, t.radius, t.border, orientation, t.gradient)
    elseif pos == "l" then
      draw_frame(cr, lX0 + deltaX, lY0 + deltaY, vbox.width, vbox.height, tColor, t.radius, t.border, orientation, t.gradient)
    elseif pos == "r" then
      draw_frame(cr, lX0 + 7 * (maxSide + t.gap) + deltaX, lY0 + deltaY, vbox.width, vbox.height, tColor, t.radius, t.border, orientation, t.gradient)
    else
      draw_frame(cr, lX0, lY0 + deltaY, hbox.width, hbox.height, tColor, t.radius, t.border, orientation, t.gradient)
    end

    if pos == "t" or pos == "b" then
      cairo_save(cr)
      local ratio = (hbox.width * 2 - t.border - 2 * t.hpadding) / (te.width + te.x_bearing)
      if ratio > 1 then ratio = 1 end

      local xm = lX0 + hbox.width / 2 - (te.width / 2 + te.x_bearing)
      local ym = lY0 + hbox.height / 2 - (te.height / 2 + te.y_bearing)
      if ratio < 1 then xm = lX0 + t.border + t.hpadding end
      local y1 = lY0
      if pos == "b" then
        ym = ym + flagEnd * (maxSide + t.gap)
        y1 = lY0 + flagEnd * (maxSide + t.gap)
      end

      create_pattern(cr, lX0, y1, hbox.width, hbox.height, tColorText, orientation, t.gradient)
      cairo_translate(cr, xm, ym + deltaY)
      cairo_scale(cr, ratio, 1)
      cairo_show_text(cr, txt)
      cairo_restore(cr)
    end

    if pos == "l" or pos == "r" then
      cairo_save(cr)
      local ratio = (vbox.height - 2 * t.border - 2 * t.hpadding) / (te.width + te.x_bearing)
      if ratio > 1 then ratio = 1 end

      local xm = lX0 + vbox.width / 2 - (te.height / 2 + te.y_bearing) + deltaX
      local ym = lY0 + vbox.height / 2 + (te.width / 2 + te.x_bearing)
      if ratio < 1 then ym = lY0 + vbox.height - t.border - t.hpadding end
      if pos == "r" then xm = xm + 7 * (maxSide + t.gap) end

      create_pattern(cr, xm - hbox.height + te.height, ym - te.width - te.x_bearing, hbox.height, te.width + te.x_bearing, tColorText, orientation, t.gradient)
      cairo_translate(cr, xm, ym + deltaY)
      cairo_rotate(cr, -deg90rad)
      cairo_scale(cr, ratio, 1)
      cairo_show_text(cr, txt)
      cairo_restore(cr)
    end
  end

  local yZ = y0 + (flagEnd + 1) * (maxSide + t.gap)
  show_big_box(txtMonth, "month", monthPos)
  if monthPos == "t" or monthPos == "b" then yZ = yZ + maxSide + t.gap end

  if t.displayInfoBox then
    show_big_box(txtInfo, "info", infoPos)
    if infoPos == "t" or infoPos == "b" then yZ = yZ + maxSide + t.gap end
  end

end

-- draw graph
function draw_graph(cr, t)

  local function linear_orientation(orientation, width, height)
    -- set gradient for bg and bg border
    local pts
    if orientation == "nn" then
      pts = {width / 2, height, width / 2, 0}
    elseif orientation == "ne" then
      pts = {width, height, 0, 0}
    elseif orientation == "ee" then
      pts = {width, height / 2, 0, height / 2}
    elseif orientation == "se" then
      pts = {width, 0, 0, height}
    elseif orientation == "ss" then
      pts = {width / 2, 0, width / 2, height}
    elseif orientation == "sw" then
      pts = {0, 0, width, height}
    elseif orientation == "ww" then
      pts = {0, height / 2, width, height / 2}
    elseif orientation == "nw" then
      pts = {0, height, width, 0}
    end

    return pts
  end

  local function linear_orientation_inv(orientation, width, height)
    -- set gradient for fg and fg border
    local pts
    if orientation == "nn" then
      pts = {width / 2, 0, width / 2, height}
    elseif orientation == "ne" then
      pts = {0, 0, width, height}
    elseif orientation == "ee" then
      pts = {0, height / 2, width, height / 2}
    elseif orientation == "se" then
      pts = {0, height, width, 0}
    elseif orientation == "ss" then
      pts = {width / 2, height, width / 2, 0}
    elseif orientation == "sw" then
      pts = {width, height, 0, 0}
    elseif orientation == "ww" then
      pts = {width, height / 2, 0, height / 2}
    elseif orientation == "nw" then
      pts = {width, 0, 0, height}
    end

    return pts
  end

  -- set defaults
  if t.drawMe ~= nil and conky_parse(tostring(t.drawMe)) ~= "1" then
    return
  end

  if t.height == nil then t.height = 20 end
  if t.background == nil then t.background = true end
  if t.bgBdSize == nil then t.bgBdSize = 0 end
  if t.x == nil then t.x = cCenter.x end
  if t.y == nil then t.y = cCenter.y end
  if t.bgColor == nil then t.bgColor = {{0, color.black, 0.5}, {1, color.white, 0.5}} end
  if t.bgBdColor == nil then t.bgBdColor = {{1, color.white, 1}} end
  if t.foreground == nil then t.foreground = true end
  if t.fgColor == nil then t.fgColor = {{0, color.curiousBlue, 1}, {1, color.scarlet, 1}} end
  if t.fgBdSize == nil then t.fgBdSize = 0 end
  if t.fgBdColor == nil then t.fgBdColor = {{1, color.yellow, 1}} end
  if t.autoscale == nil then t.autoscale = false end
  if t.inverse == nil then t.inverse = false end
  if t.angle == nil then t.angle = 0 end
  if t.bgBdOrientation == nil then t.bgBdOrientation = "nn" end
  if t.bgOrientation == nil then t.bgOrientation = "nn" end
  if t.fgBdOrientation == nil then t.fgBdOrientation = "nn" end
  if t.fgOrienation == nil then t.fgOrienation = "nn" end
  for i = 1, #t.fgColor do
    if #t.fgColor[i] ~= 3 then
      print('error in fgBdColor table')
      t.fgColor[i] = {1, color.scarlet, 1}
    end
  end
  for i = 1, #t.fgBdColor do
    if #t.fgBdColor[i] ~= 3 then
      print('error in fgBColor table')
      t.fgBdColor[i] = {1, color.green, 1}
    end
  end
  for i = 1, #t.bgColor do
    if #t.bgColor[i] ~= 3 then
      print('error in bgColor table')
      t.bgColor[i] = {1, color.white, 0.5}
    end
  end
  for i = 1, #t.bgBdColor do
    if #t.bgBdColor[i] ~= 3 then
      print('error in bgBdColor table')
      t.bgBdColor[i] = {1, color.white, 1}
    end
  end

  -- calculate skew params
  if t.flagInit then
    if t.skewX == nil then
      t.skewX = 0
    else
      t.skewX = t.skewX * deg2rad
    end
    if t.skewY == nil then
      t.skewY = 0
    else
      t.skewY = t.skewY * deg2rad
    end
    t.flagInit = false
  end

  cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
  cairo_set_line_join(cr, CAIRO_LINE_JOIN_ROUND)

  local matrix0 = cairo_matrix_t:create()
  tolua.takeownership(matrix0)
  cairo_save(cr)
  cairo_matrix_init(matrix0, 1, t.skewY, t.skewX, 1, 0, 0)
  cairo_transform(cr, matrix0)

  local ratio = t.width / t.nbValues

  cairo_translate(cr, t.x, t.y)
  cairo_rotate(cr, t.angle * deg2rad)
  cairo_scale(cr, 1, -1)

  -- background
  if t.background then
    local pts = linear_orientation(t.bgOrientation, t.width, t.height)
    local pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
    for i = 1, #t.bgColor do
      cairo_pattern_add_color_stop_rgba(pat, t.bgColor[i][1], rgba_to_r_g_b_a(t.bgColor[i]))
    end
    cairo_set_source(cr, pat)
    cairo_rectangle(cr, 0, 0, t.width, t.height)
    cairo_fill(cr)
    cairo_pattern_destroy(pat)
  end

  -- autoscale
  cairo_save(cr)
  if t.autoscale then
    t.max = t.automax * 1.1
  end

  local scaleX = t.width / (t.nbValues - 1)
  local scaleY = t.height / t.max

  -- define first point of graph
  if updates - updatesGap < t.nbValues then
    t.beg = t.beg - 1
    if t.beg < 0 then t.beg = 0 end
  else
    t.beg = 0
  end
  if t.inverse then
    cairo_scale(cr, -1, 1)
    cairo_translate(cr, -t.width, 0)
  end

  -- foreground
  if t.foreground then
    local pts = linear_orientation_inv(t.fgOrientation, t.width, t.height)
    local pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
    for i = 1, #t.fgColor do
      cairo_pattern_add_color_stop_rgba(pat, 1 - t.fgColor[i][1], rgba_to_r_g_b_a(t.fgColor[i]))
    end
    cairo_set_source(cr, pat)

    cairo_move_to(cr, t.beg * scaleX, 0)
    cairo_line_to(cr, t.beg * scaleX, t.values[t.beg + 1] * scaleY)
    for i = t.beg, t.nbValues - 1 do
      cairo_line_to(cr, i * scaleX, t.values[i + 1] * scaleY)
    end
    cairo_line_to(cr, (t.nbValues - 1) * scaleX, 0)
    cairo_close_path(cr)
    cairo_fill(cr)
    cairo_pattern_destroy(pat)
  end

  -- graph border
  if t.fgBdSize > 0 then
    local pts = linear_orientation_inv(t.fgBdOrientation, t.width, t.height)
    local pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
    for i = 1, #t.fgBdColor do
      cairo_pattern_add_color_stop_rgba(pat, 1 - t.fgBdColor[i][1], rgba_to_r_g_b_a(t.fgBdColor[i]))
    end
    cairo_set_source(cr, pat)
    cairo_move_to(cr, t.beg * scaleX, t.values[t.beg + 1] * scaleY)
    for i = t.beg, t.nbValues - 1 do
      cairo_line_to(cr, i * scaleX, t.values[i + 1] * scaleY)
    end
    cairo_set_line_width(cr, t.fgBdSize)
    cairo_stroke(cr)
    cairo_pattern_destroy(pat)
  end
  cairo_restore(cr)

  -- background border
  if t.bgBdSize > 0 then
    local pts = linear_orientation(t.bgBdOrientation, t.width, t.height)
    local pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
    for i = 1, #t.bgBdColor do
      cairo_pattern_add_color_stop_rgba(pat, t.bgBdColor[i][1], rgba_to_r_g_b_a(t.bgBdColor[i]))
    end
    cairo_set_source(cr, pat)
    cairo_rectangle(cr, 0, 0, t.width, t.height)
    cairo_set_line_width(cr, t.bgBdSize)
    cairo_stroke(cr)
    cairo_pattern_destroy(pat)
  end

  cairo_restore(cr)
end

function checkGraphSettings(t)

  if t.name == nil and t.arg == nil then
    print('No input values ... use params name with arg or only param arg')
    return 1
  end

  if t.max == nil then
    print('no maximum value defined, use max')
    print('for name=' .. t.name .. ' with arg=' .. t.arg)
    return 1
  end

  if t.name == nil then t.name = "" end
  if t.arg == nil then t.arg = "" end
  return 0
end

-- draw bar
function draw_bar(cr, t)

  cairo_save(cr)
  -- check values
  if t.drawMe == true then t.drawMe = nil end
  if t.drawMe ~= nil and conky_parse(tostring(t.drawMe)) ~= "1" then return end
  if t.name == nil and t.arg == nil then
    print ("No input values ... use params 'name' with 'arg' or only param 'arg'")
    return
  end
  if t.max == nil then
    print("No max value defined, use 'max'")
    return
  end
  if t.name == nil then t.name = "" end
  if t.arg == nil then t.arg = "" end

  -- set defaults
  if t.x == nil then t.x = cWidth / 2 end
  if t.y == nil then t.y = cHeight / 2 end
  if t.blocks == nil then t.blocks = 10 end
  if t.height == nil then t.height = 10 end
  if t.angle == nil then t.angle = 0 end
  t.angle = t.angle * deg2rad
  -- line cap style
  if t.cap == nil then t.cap = "b" end
  local cap = "b"
  for i, v in ipairs({"s", "r", "b"}) do
    if v == t.cap then cap = v end
  end
  local delta = 0
  if t.cap == "r" or t.cap == "s" then delta = t.height end
  if cap == "s" then
    cap = CAIRO_LINE_CAP_SQUARE
  elseif cap == "r" then
    cap = CAIRO_LINE_CAP_ROUND
  elseif cap == "b" then
    cAP = CAIRO_LINE_CAP_BUTT
  end
  -- end line cap style
  if t.ledEffect == nil then t.ledEffect = "r" end
  if t.width == nil then t.width = 20 end
  if t.space == nil then t.space = 2 end
  if t.radius == nil then t.radius = 0 end
  if t.angleBar == nil then t.angleBar = 0 end
  t.angleBar = t.angleBar * halfdeg -- halt angle

  -- colors
  if t.bgColor == nil then t.bgColor = {color.green, 0.5} end
  if #t.bgColor ~= 2 then t.bgColor = {color.green, 0.5} end
  if t.fgColor == nil then t.fgColor = {color.green, 1} end
  if #t.fgColor ~= 2 then t.fgColor = {color.green, 1} end
  if t.alarmColor == nil then t.alarmColor = t.fgColor end
  if #t.alarmColor ~= 2 then t.alarmColor = t.fgColor end
  if t.midColor ~= nil then
    for i = 1, #t.midColor do
      if #t.midColor[i] ~= 3 then
        print('error in mid color table')
        t.midColor[i] = {1, color.white, 1}
      end
    end
  end
  if t.bgLed ~= nil and #t.bgLed ~= 2 then t.bgLed = t.bgColor end
  if t.fgLed ~= nil and #t.fgLed ~= 2 then t.fgLed = t.fgColor end
  if t.alarmLed ~= nil and #t.alarmLed ~= 2 then t.alarmLed = t.fgLed end
  if t.ledEffect ~= nil then
    if t.bgLed == nil then t.bgLed = t.bgColor end
    if t.fgLed == nil then t.fgLed = t.fgColor end
    if t.alarmLed == nil then t.alarmLed = t.fgLed end
  end
  if t.alarm == nil then t.alarm = t.max end
  if t.smooth == nil then t.smooth = false end

  -- skews/reflections
  if t.skewX == nil then
    t.skewX = 0
  else
    t.skewX = t.skewX * deg2rad
  end
  if t.skewY == nil then
    t.skewY = 0
  else
    t.skewY = t.skewY * deg2rad
  end
  if t.reflectionAlpha == nil then t.reflectionAlpha = 0 end
  if t.reflectionLength == nil then t.reflectionLength = 1 end
  if t.reflectionScale == nil then t.reflectionScale = 1 end

  -- functions to create patterns
  local function create_smooth_linear_gradient(x0, y0, x1, y1)
    local pat = cairo_pattern_create_linear(x0, y0, x1, y1)
    cairo_pattern_add_color_stop_rgba(pat, 0, rgba_to_r_g_b_a(t.fgColor))
    cairo_pattern_add_color_stop_rgba(pat, 1, rgba_to_r_g_b_a(t.alarmColor))
    if t.midColor ~= nil then
      for i = 1, #t.midColor do
        cairo_pattern_add_color_stop_rgba(pat, t.midColor[i][1], rgba_to_r_g_b_a({t.midColor[i][2], t.midColor[i][3]}))
      end
    end
    return pat
  end

  local function create_smooth_radial_gradient(x0, y0, r0, x1, y1, r1)
    local pat = cairo_pattern_create_radial(x0, y0, r0, x1, y1, r1)
    cairo_pattern_add_color_stop_rgba(pat, 0, rgba_to_r_g_b_a(t.fgColor))
    cairo_pattern_add_color_stop_rgba(pat, 1, rgba_to_r_g_b_a(t.alarmColor))
    if t.midColor ~= nil then
      for i = 1, #t.midColor do
        cairo_pattern_add_color_stop_rgba(pat, t.midColor[i][1], rgba_to_r_g_b_a({t.midColor[i][2], t.midColor[i][3]}))
      end
    end
    return pat
  end

  local function create_led_linear_gradient(x0, y0, x1, y1, colAlpha, colLed)
    local pat = cairo_pattern_create_linear(x0, y0, x1, y1)
    cairo_pattern_add_color_stop_rgba(pat, 0.0, rgba_to_r_g_b_a(colAlpha))
    cairo_pattern_add_color_stop_rgba(pat, 0.5, rgba_to_r_g_b_a(colLed))
    cairo_pattern_add_color_stop_rgba(pat, 1.0, rgba_to_r_g_b_a(colAlpha))
    return pat
  end

  local function create_led_radial_gradient(x0, y0, r0, x1, y1, r1, colAlpha, colLed, mode)
    local pat = cairo_pattern_create_radial(x0, y0, r0, x1, y1, r1)
    if mode == 3 then
      cairo_pattern_add_color_stop_rgba(pat, 0.0, rgba_to_r_g_b_a(colAlpha))
      cairo_pattern_add_color_stop_rgba(pat, 0.5, rgba_to_r_g_b_a(colLed))
      cairo_pattern_add_color_stop_rgba(pat, 1.0, rgba_to_r_g_b_a(colAlpha))
    else
      cairo_pattern_add_color_stop_rgba(pat, 0, rgba_to_r_g_b_a(colLed))
      cairo_pattern_add_color_stop_rgba(pat, 1, rgba_to_r_g_b_a(colAlpha))
    end
    return pat
  end

  -- draw a single bar
  local function draw_single_bar()

    -- used for drawing bars with single bar, but cut in 3 blocks
    local function create_pattern(colAlpha, colLed, bg)
      local pat
      if not t.smooth then
        if t.ledEffect == 'e' then
          pat = create_led_linear_gradient(-delta, 0, delta + t.width, 0, colAlpha, colLed)
        elseif t.ledEffect == 'a' then
          pat = create_led_linear_gradient(t.width / 2, 0, t.width / 2, -t.height, colAlpha, colLed)
        elseif t.ledEffect == 'r' then
          pat = create_led_radial_gradient(t.width / 2, -t.height / 2, 0, t.width / 2, -t.height / 2, t.height / 1.5, colAlpha, colLed,2)
        else
          pat = cairo_pattern_create_rgba(rgba_to_r_g_b_a(colAlpha))
        end
      else
        if bg then
          pat = cairo_pattern_create_rgba(rgba_to_r_g_b_a(t.bgColor))
        else
          pat = create_smooth_linear_gradient(t.width / 2, 0, t.width / 2, -t.height)
        end
      end
      return pat
    end

    local y1 = -t.height * pct / 100
    local y2, y3
    if pct > (100 * t.alarm / t.max) then
      y1 = -t.height * t.alarm / 100
      y2 = -t.height * pct / 100
      if t.smooth then y1 = y2 end
    end

    if t.angleBar == 0 then

      -- block for fg value
      local pat = create_pattern(t.fgColor, t.fgLed, false)
      cairo_set_source(cr, pat)
      cairo_rectangle(cr, 0, 0, t.width, y1)
      cairo_fill(cr)
      cairo_pattern_destroy(pat)

      -- block for alarm value
      if not t.smooth and y2 ~= nil then
        pat = create_pattern(t.alarmColor, t.alarmLed, false)
        cairo_set_source(cr, pat)
        cairo_rectangle(cr, 0, y1, t.width, y2 - y1)
        cairo_fill(cr)
        y3 = y2
        cairo_pattern_destroy(pat)
      else
        y2, y3 = y1, y1
      end

      -- block for bg value
      cairo_rectangle(cr, 0, y2, t.width, -t.height - y3)
      pat = create_pattern(t.bgColor, t.bgLed, true)
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)
      cairo_fill(cr)
    end
  end

  local function draw_multi_bar()

    -- function used for bars with 2 or more blocks
    for pt = 1, t.blocks do

      -- set block y
      local y1 = -(pt - 1) * (t.height + t.space)
      local lightOn = false

      -- set colors
      local colAlpha = t.bgColor
      local colLed = t.bgLed
      if pct >= (100 / t.blocks) or pct > 0 then -- light on or not
        if pct >= (pcb * (pt - 1)) then
          lightOn = true
          colAlpha = t.fgColor
          colLed = t.fgLed
          if pct >= (100 * t.alarm / t.max) and (pcb * pt) > (100 * t.alarm / t.max) then
            colAlpha = t.alarmColor
            colLed = t.alarmLed
          end
        end
      end

      local pat
      if not t.smooth then
        if t.angleBar == 0 then
          if t.ledEffect == 'e' then
            pat = create_led_linear_gradient(-delta, 0, delta + t.width, 0, colAlpha, colLed)
          elseif t.ledEffect == 'a' then
            pat = create_led_linear_gradient(t.width / 2, -t.height / 2 + y1, t.width / 2, 0 + t.height / 2 + y1, colAlpha, colLed)
          elseif t.ledEffect == 'r' then
            pat = create_led_radial_gradient(t.width / 2, y1, 0, t.width / 2, y1, t.width / 1.5, colAlpha, colLed, 2)
          else
            pat = cairo_pattern_create_rgba(rgba_to_r_g_b_a(colAlpha))
          end
        else
          if t.ledEffect == 'a' then
            pat = create_led_radial_gradient(0, 0, t.radius + (t.height + t.space) * (pt - 1), 0, 0, t.radius + (t.height + t.space) * pt, colAlpha, colLed, 3)
          else
            pat = cairo_pattern_create_rgba(rgba_to_r_g_b_a(colAlpha))
          end
        end
      else
        if lightOn then
          if t.angleBar == 0 then
            pat = create_smooth_linear_gradient(t.width / 2, t.height / 2, t.width / 2, -(t.blocks - 0.5) * (t.height + t.space))
          else
            pat = create_smooth_radial_gradient(0, 0, (t.height + t.space), 0, 0, (t.blocks + 1) * (t.height + t.space), 2)
          end
        else
          pat = cairo_pattern_create_rgba(rgba_to_r_g_b_a(t.bgColor))
        end
      end
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)

      -- draw a block
      if t.angleBar == 0 then
        cairo_move_to(cr, 0, y1)
        cairo_line_to(cr, t.width, y1)
      else
        cairo_arc(cr, 0, 0, t.radius + (t.height + t.space) * pt - t.height / 2, -t.angleBar - deg90rad, t.angleBar - deg90rad)
      end
      cairo_stroke(cr)
    end
  end

  local function setup_bar_graph()

    -- function used to retrieve the value to display and to set the cairo structure
    if t.blocks ~= 1 then t.y = t.y - t.height / 2 end

    local value = 0
    if t.name ~= '' then
      value = tonumber(conky_parse(string.format('${%s %s}', t.name, t.arg)))
    else
      value = tonumber(t.arg)
    end

    if value == nil then value = 0 end

    pct = 100 * value / t.max
    pcb = 100 / t.blocks

    cairo_set_line_width(cr, t.height)
    cairo_set_line_cap(cr, cap)
    cairo_translate(cr, t.x, t.y)
    cairo_rotate(cr, t.angle)

    local matrix0 = cairo_matrix_t:create()
    tolua.takeownership(matrix0)
    cairo_matrix_init(matrix0, 1, t.skewY, t.skewX, 1, 0, 0)
    cairo_translate(cr, matrix0)

    -- call drawing function for blocks
    if t.blocks == 1 and t.angleBar == 0 then
      draw_single_bar()
      if t.reflection == 't' or t.reflection == 'b' then cairo_translate(cr, 0, -t.height) end
    else
      draw_multi_bar()
    end

    -- dot for reminder
    --if t.blocks ~= 1 then
    --  cairo_set_source_rgba(cr, 1, 0, 0, 1)
    --  cairo_arc(cr, 0, t.height / 2, 3, 0, deg360rad)
    --  cairo_fill(cr)
    --else
    --  cairo_set_source_rgba(cr, 1, 0, 0, 1)
    --  cairo_arc(cr, 0, 0, 3, 0, deg360rad)
    --  cairo_fill(cr)
    --end

    -- call function for reflection and prepare the mask
    if t.reflectionAlpha > 0 and t.angleBar == 0 then
      local pat2
      local matrix1 = cairo_matrix_t:create()
      tolua.takeownership(matrix1)
      if t.angleBar == 0 then
        pts = {-delta / 2, (t.height + t.space) / 2, t.width + delta, -(t.height + t.space) * t.blocks}
        if t.reflection == 't' then
          cairo_matrix_init(matrix1, 1, 0, 0, -t.reflectionScale, 0, -(t.height + t.space) * (t.blocks - 0.5) * 2 * (t.reflectionScale + 1) / 2)
          pat2 = cairo_pattern_create_linear(t.width / 2, -(t.height + t.space) * t.blocks, t.width / 2, (t.height + t.space) / 2)
        elseif t.reflection == 'r' then
          cairo_matrix_init(matrix1, -t.reflectionScale, 0, 0, 1, delta + 2 * t.width, 0)
          pat2 = cairo_pattern_create_linear(delta / 2 + t.width, 0, -delta / 2, 0)
        elseif t.reflection == 'l' then
          cairo_matrix_init(matrix1, -t.reflectionScale, 0, 0, 1, -delta, 0)
          pat2 = cairo_pattern_create_linear(-delta / 2, 0, delta / 2 + t.width, 0)
        else
          cairo_matrix_init(matrix1, 1, 0, 0, -1 * t.reflectionScale, 0, (t.height + t.space) * (t.reflectionScale + 1) / 2)
          pat2 = cairo_pattern_create_linear(t.width / 2, (t.height + t.space) / 2, t.width / 2, -(t.height + t.space) * t.blocks)
        end
      end
      cairo_transform(cr, matrix1)

      if t.blocks == 1 and t.angleBar == 0 then
        draw_single_bar()
        cairo_translate(cr, 0, -t.height / 2)
      else
        draw_multi_bar()
      end

      cairo_set_line_width(cr, 0.01)
      cairo_pattern_add_color_stop_rgba(pat2, 0, 0, 0, 0, 1 - t.reflectionAlpha)
      cairo_pattern_add_color_stop_rgba(pat2, t.reflectionLength, 0, 0, 0, 1)
      if t.angleBar == 0 then
        cairo_rectangle(cr, pts[1], pts[2], pts[3], pts[4])
      end
      cairo_clip_preserve(cr)
      cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR)
      cairo_stroke(cr)
      cairo_mask(cr, pat2)
      cairo_pattern_destroy(pat2)
      cairo_set_operator(cr, CAIRO_OPERATOR_OVER)

    end

    pct, pcb = nil
  end

  setup_bar_graph()
  cairo_restore(cr)
end

-- draw a line
function draw_line(cr, t)

  local x0 = t.x
  local y0 = t.y
  local x1 = t.tox
  local y1 = t.toy
  cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.color))
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_SQUARE)

  cairo_move_to(cr, x0, y0)
  cairo_line_to(cr, x1, y1)
  cairo_set_line_width(cr, t.width)
  cairo_stroke(cr)
end

-- calendar wheel
function draw_cal_wheel(t)

  -- init problem when w/h are to to 0 or 2
  if cWidth < 3 or cHeight < 3 then return end

  local cs = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, cWidth, cHeight)
  local cr = cairo_create(cs)

  -- segment from x=0 to x=radius - xc
  -- arrow = external, arrow2 = internal
  local arrow = t.radius
  local arrow2 = arrow * t.ratioArc

  -- vertical segment (x = 0) of external
  local verSeg = math.sqrt(t.radius * 8 * arrow - 4 * arrow^2)

  -- calculations
  local radius2 = (verSeg^2 + 4 * arrow2^2) / (8 * arrow2)
  local decal = t.txtOffset
  local xc2 = t.xc + (arrow2 - radius2)

  if t.alignR then
    xc2 = t.xc - (arrow2 - radius2)
  end

  local hTxt = cHeight / (2 * t.range + 1)

  local dateT = os.date('*t')
  local dateS = os.time(dateT)

  -- read calendar file
  local file = io.open(calendarFile, "r")
  local tabCal = {}
  local idx = 1
  local line, lineOk = "", ""
  if file ~= nil then
    while true do
      line = file:read("*l")
      if line == nil then break end
      lineOk = string.split(line, ";")
      if (#lineOk) == 3 then
        tabCal[idx] = {lineOk[1], lineOk[2], lineOk[3]}
        idx = idx + 1
      end
    end
  end
  io.close()
  
  local angMini = math.atan((verSeg / 2) / (t.radius - arrow))

  local imageDates = imlib_create_image(cWidth, cHeight)
  imlib_context_set_image(imageDates)
  imlib_image_set_has_alpha(1)
  imlib_save_image(imgDates)

  for i = -t.range, t.range do
    local s2 = dateS + 3600 * 24 * (i - t.todayYOffset)

    local wd = os.date("%w", s2)
    local md = os.date("%m%d", s2)
    local dt = os.date(t.dateFormat, s2)

    -- % of vertical gradient
    local pc = (t.range - math.abs(i)) / t.range
    if not t.vGradient then pc = 1 end

    -- angle min and max of one block
    local ang0 = angMini * (i - 0.5) / t.range
    local ang1 = angMini * (i + 0.5) / t.range
    if t.alignR then
      ang0 = deg180rad - ang0
      ang1 = deg180rad - ang1
    end
    local angM = (ang0 + ang1) / 2

    -- read calendar.txt array
    local flag = false
    for idy = 1, idx - 1 do
      if tabCal[idy][1] == md then
        if (i - t.todayYOffset) == 0 then
          today = tabCal[idy]
        end
        if tabCal[idy][2] == "1" then
          flag = true
        end
        break
      end
    end

    -- colors
    local color = color.white
    if wd == "6" or wd == "0" or flag == true then
      color = t.weDayColor
    else
      color = t.wkDayColor
    end

    -- offset for today
    local offsetX = 0
    local way = 1
    if (i - t.todayYOffset) == 0 then
      if t.alignR then way = -1 end
      offsetX = t.todayXOffset * way
    end

    local pat = cairo_pattern_create_radial(t.xc + offsetX, t.yc, t.radius, xc2 + offsetX, t.yc, radius2)
    cairo_pattern_add_color_stop_rgba(pat, 0, rgb_a_to_r_g_b_a(color, pc))
    cairo_pattern_add_color_stop_rgba(pat, 1, rgb_a_to_r_g_b_a(color, t.hGradient))
    cairo_set_source(cr, pat)

    -- draw portion of arc
    if t.alignR then
      x1, y1 = t.radius * math.cos(ang0) + t.xc + offsetX, (t.radius - offsetX) * math.sin(ang0) + t.yc
      x2, y2 = t.radius * math.cos(ang1) + t.xc + offsetX, (t.radius - offsetX) * math.sin(ang1) + t.yc
    else
      x1, y1 = t.radius * math.cos(ang0) + t.xc + offsetX, (t.radius + offsetX) * math.sin(ang0) + t.yc
      x2, y2 = t.radius * math.cos(ang1) + t.xc + offsetX, (t.radius + offsetX) * math.sin(ang1) + t.yc
    end
    cairo_move_to(cr, x1, y1)
    cairo_line_to(cr, x2, y2)
    cairo_line_to(cr, t.xc, t.yc)
    cairo_fill(cr)


    -- length of arc
    local dx, dy = math.abs(x2 - x1), math.abs(y2 - y1)
    local hTxt = math.sqrt(dx * dx + dy * dy)
    local wTxt = t.fontSize * 10

    -- write text to another image
    local cs2 = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, wTxt, hTxt)
    local cr2 = cairo_create(cs2)
    cairo_set_font_size(cr2, t.fontSize)
    if (i - t.todayYOffset) == 0 then
      color = t.dDayColor
      pc = 1
    end
    cairo_select_font_face(cr2, t.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)

    -- write one date object in one picture
    local txtDate= " " .. dt .. " "
    cairo_move_to(cr2, 0, hTxt - decal)
    cairo_set_source_rgba(cr2, rgb_a_to_r_g_b_a(color, pc))
    cairo_show_text(cr2, txtDate)

    -- write info if needed
    local have = ""
    if (today ~= nil) then
      cairo_select_font_face(cr, t.fontInfo, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
      cairo_set_line_width(cr, 0)
      cairo_set_font_size(cr, t.fontSizeInfo)
      cairo_set_source_rgba(cr, rgb_a_to_r_g_b_a(t.infoColor, t.fontAlphaInfo))
      have = string.split(today[3], "*")
      for i = 1, #have do
        cairo_move_to(cr, t.txtX, t.txtY + (i - #have / 2) * t.fontSizeInfo)
        cairo_show_text(cr, have[i])
        cairo_stroke(cr)
      end
    end

    if t.alignR then
      local xMax, yMax = cairo_get_current_point(cr2, 0, 0)
      cs2fit = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, xMax, hTxt)
      cr2fit = cairo_create(cs2fit)

      cairo_set_font_size(cr2fit, t.fontSize)
      cairo_select_font_face(cr2fit, t.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
      cairo_move_to(cr2fit, 0, hTxt - decal)
      cairo_set_source_rgba(cr2fit, rgb_a_to_r_g_b_a(color, pc))
      cairo_show_text(cr2fit, txtDate)
      cairo_stroke(cr2fit)
      cairo_surface_write_to_png(cs2fit, imgTmp)
    else
      cairo_stroke(cr2)
      cairo_surface_write_to_png(cs2, imgTmp)
    end

    -- blend image on cairo surface
    local imageTemp = imlib_load_image(imgTmp)
    imlib_context_set_image(imageTemp)

    if t.alignR then
      rotImg = imlib_create_rotated_image(angM + deg180rad)
    else
      rotImg = imlib_create_rotated_image(angM)
    end

    imlib_context_set_image(imageTemp)
    imlib_free_image()

    -- image now a square
    imlib_context_set_image(rotImg)
    local wImg0, hImg0 = imlib_image_get_width(), imlib_image_get_height()

    local rt = t.radius + wImg0 / 2
    if t.alignR then
      rt = rt - offsetX
    else
      rt = rt + offsetX
    end
    local xt = rt * math.cos(angM) + t.xc - wImg0 / 2
    local yt = rt * math.sin(angM) + t.yc - hImg0 / 2

    imlib_context_set_image(imageDates)
    imlib_blend_image_onto_image(rotImg, 1, 0, 0, wImg0, hImg0, xt, yt, wImg0, hImg0)
    imageDates = imlib_context_get_image()
    imlib_context_set_image(rotImg)
    imlib_free_image()

    if t.alignR then
      cairo_destroy(cr2fit)
      cairo_surface_destroy(cs2fit)
    end

    cairo_destroy(cr2)
    cairo_surface_destroy(cs2)

    cairo_pattern_destroy(pat)
  end

  -- write to disk images with dates only
  imlib_context_set_image(imageDates)
  imlib_save_image(imgDates)

  -- write to disk image with arc
  cairo_surface_write_to_png(cs, imgCal)

  -- make final image
  local imageCal = imlib_load_image(imgCal)
  imlib_context_set_image(imageCal)
  imlib_blend_image_onto_image(imageDates, 1, 0, 0, cWidth, cHeight, 0, 0, cWidth, cHeight)

  imlib_save_image(imgCal)
  imlib_free_image()

  imlib_context_set_image(imageDates)
  imlib_free_image()

  -- free mem
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
