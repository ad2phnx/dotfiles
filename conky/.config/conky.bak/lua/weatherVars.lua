-- base line forecast/calendar connector
baseLine = {
  x = cCenter.x,
  y = cCenter.y - 550,
  tox = cCenter.x,
  toy = cCenter.y,
  color = {color.white, 0.25},
  width = 34,
}

-- base forecast images
fcastImg = {
  x = cCenter.x,
  y = cCenter.y - 550,
  w = 32,
  h = 32,
  file = os.getenv("HOME") .. '/.config/conky.bak/weather/NA.png',
}

-- base forecast kanji
fcastKanji = {
  --text = weatherKanji.forecast, 
  --text = nameKatakana,
  --text = time.day .. "." .. time.month .. "." .. time.year,
  text = yearKanji .. (time.year-2019+1) .. monthEnd .. time.month .. weekdayKanji[1] .. time.day,
  xc = cCenter.x - 400,
  yc = cCenter.y,
  --font = 'HakusyuKaisyoExtraBold_kk',
  font = 'Kochi Mincho',
  --font = "Japan",
  face = CAIRO_FONT_WEIGHT_BOLD,
  size = 48,
  color = {color.white, 0.25},
}

baseNameKatakana = {
  text = '', --nameKatakana,
  xc = cCenter.x + 595,
  yc = cCenter.y + 425,
  font = 'HakusyuKaisyoExtraBold_kk',
  size = 128,
  color = {color.white, 0.2},
}


-- base forecast text
fcastText = {
  text = 'testing',
  xc = cCenter.x - 400,
  yc = cCenter.y + 50,
  font = 'Source Code Pro',
  size = 10,
  color = {color.white, 0.75},
}


-- base weekday text
wkdayText = {
  text = 'WKDAY',
  xc = cCenter.x + 264,
  yc = cCenter.y - 500,
  font = 'HakusyuKaisyoExtraBold_kk',
  size = 48,
  color = {color.white, 0.5},
}

-- images
images = {

  -- current condition
  {
    x = 175,
    y = 910,
    w = 128,
    h = 128,
    file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((weather ~= nil and weather.cc ~= nil) and weather.cc.icon or 'NA') .. '.png',
  },

  -- Moon
  {
    x = 325 - 24,
    y = 1080 - 12 - 24,
    w = 48,
    h = 48,
    file = os.getenv("HOME") .. '/.config/conky.bak/moon/' .. ((weather ~= nil and weather.cc ~= nil) and weather.cc.moon.icon or 'NA') .. '.png',
    rotate = true,
    theta = (weather ~= nil and weather.moonDeg) or 0,
  },

  -- Globe position
  {
    x = cCenter.x - 400,
    y = cCenter.y - cHeight / 4,
    w = 96,
    h = 96,
    file = os.getenv("HOME") .. '/.tmp/earth/earth-out.png',
  },

}

-- boxes
boxes = {

  -- clock bg
  {
    x = cCenter.x - 400 - 175 - 1,
    y = cCenter.y - cHeight / 4 - 225,
    w = 350,
    h = 450,
    scaleX = 1,
    scaleY = 1,
    corners = {{'circle', 2}},
    color = {{0, monthColor[tonumber(time.month)], 0.1}},
    border = 0,
  },

  -- calendar bg
  {
    x = cCenter.x - 400 - 175 - 1,
    y = cCenter.y + cHeight / 4 - 225,
    w = 350,
    h = 450,
    scaleX = 1,
    scaleY = 1,
    corners = {{'circle', 2}},
    color = {{0, monthCompliment[tonumber(time.month)], 0.1}},
    border = 0,
  },

  -- weather bg
  {
    x = 20,
    y = 820,
    w = 310,
    h = 1080 - 12 - 820,
    scaleX = 1,
    scaleY = 1,
    corners = {{'circle', 2}},
    color = {{0, weekdayCompliment[tonumber(time.weekday)], 0.1}},
    border = 0,
  },

  -- Moon bg
  {
    x = 325 - 48,
    y = 1080 - 12 - 48,
    w = 48,
    h = 48,
    corners = {{'circle', 24}},
    color = {{1, color.lavenderGrey, 0.5}, {0, color.black, 0}},
    border = 0,
    radialGradient = { 24, 24, 12, 24, 24, 24},
  },

  -- globe bg
  {
    x = cCenter.x - 400 -48,
    y = cCenter.y - 48 - cHeight / 4, 
    w = 96,
    h = 96,
    corners = {{'circle', 48}},
    color = {{1, color.green, 0.2}, {0, color.black, 0}},
    border = 0,
    radialGradient = { 48, 48, 24, 48, 48, 48},
  },

  -- Longitude globe line
  {
    x = cCenter.x - 128 - 400,
    y = cCenter.y - cHeight / 4,
    w = 256,
    h = 4,
    scaleX = 1,
    scaleY = 0.5,
    corners = {{'circle', 0}},
    color = {{0, color.black, 0}, {1, color.white, 0.5}},
    border = 0,
    radialGradient = { 128, 2, 128, 128, 2, 50},
  },

  -- Latitude globe line
  {
    x = cCenter.x - 400,
    y = cCenter.y - 100 - cHeight / 4,
    w = 4,
    h = 200,
    scaleX = 0.5,
    scaleY = 1,
    corners = {{'circle', 0}},
    color = {{0, color.white, 0.5}, {1, color.black, 0}},
    border = 0,
    radialGradient = { 2, 100, 50, 2, 100, 100},
  },

  -- horizontal center line
  {
    x = cCenter.x - 650,
    y = cCenter.y,
    w = 400,
    h = 4,
    scaleX = 1,
    scaleY = 0.5,
    corners = {{'circle', 0}},
    --color = {{0, color.black, 0}, {1, color.white, 0.2}},
    color = {{0, color.white, 0.2}, {1, color.black, 0}},
    border = 0,
    --radialGradient = { 600, 2, 600, 600, 2, 300},
    radialGradient = { 200, 2, 100, 200, 2, 200},
  },

  -- vertical line
  {
    x = cCenter.x - 600,
    y = cCenter.y - 100,
    w = 4,
    h = 200,
    scaleX = 0.5,
    scaleY = 1,
    corners = {{'circle', 0}},
    color = {{0, color.white, 0.2}, {1, color.black, 0}},
    border = 0,
    radialGradient = { 2, 100, 50, 2, 100, 100},
  },

  --{
  --  x = cCenter.x + 780,
  --  y = cCenter.y - 180,
  --  w = 70,
  --  h = 70,
  --  corners = {{'circle', 0}},
  --  color = {{0, color.white, 1}},
  --  border = 1,
  --},

}

-- rings
rings = {

  -- Sunlight
  {
    name = '',
    --arg = sun.timePct,
    arg = tonumber(string.format("%.f", ((time.twofour * 60 + time.minutes)/1440) * 100)),
    max = 100,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radius = 160,
    thickness = 60,
    startAngle = 92,
    endAngle = 452,
    sectors = 100,
    gapSectors = 1,
    cap = 'p',
    inverseArc = false,
    borderSize = 0,
    fillSector = false,
    allSectors = false,
    background = false,
    foreground = true,
    fgColor1 = {{0, color.black, 0}, {0.25, weekdayColor[time.weekday], 1}, {0.5, color.black, 0}, {0.75, weekdayColor[time.weekday], 1}, {1, color.black, 0}},
  },

  -- Midday
  {
    name = '',
    --arg = sun.timePct,
    arg = tonumber(string.format("%.f", ((seconds_to_min(sun.midDay)) / 1440 * 100))),
    max = 100,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radius = 165,
    thickness = 60,
    --startAngle = 93.6,
    --endAngle = 453.6,
    startAngle = 93.6,
    endAngle = 453.6,
    sectors = 100,
    gapSectors = 5,
    cap = 'r',
    inverseArc = false,
    borderSize = 0,
    fillSector = false,
    allSectors = false,
    background = false,
    foreground = true,
    --fgColor1 = {{0, color.black, 0}, {0.15, weekdayCompliment[time.weekday], 1}, {0.5, color.black, 0}, {0.85, weekdayCompliment[time.weekday], 1}, {1, color.black, 0}},
    fgColor1 = {{0, color.black, 0}, {0.15, color.sun50, 1}, {0.5, color.black, 0}, {0.85, color.sun50, 1}, {1, color.black, 0}},
  },


}

pies = {

  -- Night night
  {
    tableV = {
      {"sunset", "", sun.secOSet, 86400, true},
    },

    sun = true,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radiusInt = 100,
    radiusExt = 150,
    firstAngle = -180,
    lastAngle = 180,
    inverseLArc = true,
    typeArc = "l",
    proportional = true,
    gradientEffect = true,
    lineLength = 35,
    lineThickness = 2,
    lineSpace = 5,
    extendLine = true,
    showText = false,
    fontName = 'Source Code Pro',
    fontSize = 12,
    fontColor = color.white,
    txtOffset = 2,
    txtFormat = "&l",
    tablebg = {{weekdayColor[time.weekday], 0},},
    --tablefg = {{weekdayColor[time.weekday], 0.25},},
    tablefg = {{color.black, 0.5},},
  },

  -- Day night 
  {
    tableV = {
      {"sunrise", "", sun.secRise, 86400, true},
    },

    sun = true,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radiusInt = 100,
    radiusExt = 150,
    firstAngle = -180,
    lastAngle = 180,
    typeArc = "l",
    proportional = true,
    gradientEffect = true,
    lineLength = 35,
    lineThickness = 2,
    lineSpace = 5,
    extendLine = true,
    showText = false,
    fontName = 'Source Code Pro',
    fontSize = 12,
    fontColor = color.white,
    txtOffset = 2,
    txtFormat = "&l",
    tablebg = {{weekdayColor[time.weekday], 0},},
    --tablefg = {{weekdayColor[time.weekday], 0.25},},
    tablefg = {{color.black, 0.5},},
  },

  -- Night day
  {
    tableV = {
      {"morning", "", (86400 - (sun.secOSet * 2)), 86400, true},
    },

    sun = true,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radiusInt = 100,
    radiusExt = 150,
    firstAngle = 0,
    lastAngle = 180,
    inverseLArc = false,
    typeArc = "l",
    proportional = true,
    gradientEffect = true,
    lineLength = 35,
    lineThickness = 2,
    lineSpace = 5,
    extendLine = true,
    showText = false,
    fontName = 'Source Code Pro',
    fontSize = 12,
    fontColor = color.white,
    txtOffset = 2,
    txtFormat = "&l",
    tablebg = {{weekdayColor[time.weekday], 0},},
    --tablefg = {{weekdayCompliment[time.weekday], 0.5},},
    tablefg = {{color.white, 0.5},},
  },

  -- Day day
  {
    tableV = {
      {"morning", "", (86400 - (sun.secRise * 2)), 86400, true},
    },

    sun = true,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight / 4,
    radiusInt = 100,
    radiusExt = 150,
    firstAngle = 0,
    lastAngle = -180,
    inverseLArc = true,
    typeArc = "l",
    proportional = true,
    gradientEffect = true,
    lineLength = 35,
    lineThickness = 2,
    lineSpace = 5,
    extendLine = true,
    showText = false,
    fontName = 'Source Code Pro',
    fontSize = 12,
    fontColor = color.white,
    txtOffset = 2,
    txtFormat = "&l",
    tablebg = {{color.heavyMetal, 0},},
    --tablefg = {{weekdayCompliment[time.weekday], 0.5},},
    tablefg = {{color.white, 0.5},},
  },

}

-- texts
texts = {

  -- LEFT ATTEMPT
  -- weather header
  {
    --text = 'wth ' .. (weather.cc ~= nil and string.gsub(weather.cc.lsup, "%d+/%d+/%d+ (.*) EDT", "%1") or ''),
    --text = 'wth ' .. ((weather ~= nil and weather.cc ~= nil) and weather.cc.tmp .. '°' .. weather.head.ut .. ' (' .. weather.cc.flik .. '°)' or ''),
    text = 'weather',
    x = 25,
    yc = 830,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- current conditions
  {
    text = ((weather ~= nil and weather.cc ~= nil) and weather.cc.tmp .. '°' .. weather.head.ut .. ' ' .. weather.cc.t or 'loading...'),
    xc = 175,
    yc = 830,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 12,
    color = {color.white, 0.75},
  },

  -- last update
  {
    text = (weather ~= nil and weather.cc ~= nil) and string.gsub(weather.cc.lsup, "%d+/%d+/%d+ (.* [AP]M).*", "%1") or '',
    xr = 325,
    yc = 830,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- advisory
  {
    text = (weather ~= nil and weather.swa ~= nil) and weather.swa.a.t or '',
    xc = 175,
    yc = 840,
    font = 'Source Code Pro',
    size = 10,
    color = {color.yellow, 0.75},
  },

  -- today forecast morning
  {

    text = (weather ~= nil and weather.dayf ~= nil and weather.dayf.day[1].part[1] ~= nil and type(weather.dayf.day[1].part[1].bt) ~= "table") and (weather.dayf.day[1].part[1].bt .. ' ' .. weather.dayf.day[1].part[1].ppcp .. '%') or '',
    x = 25,
    yc = 850,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.sunriseBlue, 1},
  },

  -- hi/lo today
  {
    text = (weather ~= nil and weather.dayf ~= nil) and ('H' .. weather.dayf.day[1].hi .. '° L' .. weather.dayf.day[1].low .. '°') or '',
    xc = 175,
    yc = 850,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- today forecast evening
  {
    text = (weather ~= nil and weather.dayf ~= nil) and (weather.dayf.day[1].part[2] ~= nil and weather.dayf.day[1].part[2].bt .. ' ' .. weather.dayf.day[1].part[2].ppcp .. '%') or '',
    xr = 325,
    yc = 850,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.sunsetOrange, 1},
  },

  -- feels like
  {
    text = 'Feels Like',
    x = 25,
    yc = 865,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and weather.cc.flik .. '°' .. weather.head.ut or '',
    xr = 325,
    yc = 865,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- wind
  {
    text = 'Wind',
    x = 25,
    yc = 880,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and ((weather.cc.wind.t ~= 'CALM' and weather.cc.wind.t .. ' ' .. weather.cc.wind.s .. weather.head.us) or weather.cc.wind.t) or '',
    xr = 325,
    yc = 880,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- humidity
  {
    text = 'Humidity',
    x = 25,
    yc = 895,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and weather.cc.hmid .. '%' or '',
    xr = 325,
    yc = 895,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },
     -- dewpoint
  {
    text = 'Dewpoint',
    x = 25,
    yc = 910,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and (weather.cc.dewp .. '°' .. weather.head.ut) or '',
    xr = 325,
    yc = 910,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- pressure status
  {
    text = 'Pressure',
    x = 25,
    yc = 925,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and (string.format("%.0f", (tonumber(weather.cc.bar.r) or 0)) .. weather.head.up) or '',
    xr = 325,
    yc = 925,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and (weather.cc.bar.d == "" and '-' or weather.cc.bar.d) or '',
    xr = 325,
    yc = 935,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },
 
  -- visability
  {
    text = 'Visability',
    x = 25,
    yc = 950,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and (weather.cc.vis .. weather.head.ud) or '',
    xr = 325,
    yc = 950,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- UV index/status
  {
    text = 'UV Index',
    x = 25,
    yc = 965,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = (weather ~= nil and weather.cc ~= nil) and weather.cc.uv.i .. ' / 10 ' .. weather.cc.uv.t or '',
    xr = 325,
    yc = 965,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  --{
  --  text = (weather ~= nil and weather.cc ~= nil) and (weather.cc.uv.t == '' and '-' or weather.cc.uv.t) or '',
  --  xr = 325,
  --  yc = 960,
  --  font = 'Source Code Pro',
  --  size = 12,
  --  color = {color.white, 0.75},
  --},

  -- location
  {
    text = 'Location',
    x = 25,
    yc = 980,
    font = 'Square Sans Serif 7',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.curiousBlue, 1},
  },

  {
    text = ((weather ~= nil and weather.loc ~= nil) and (string.format('%0.f', math.abs(weather.loc.lat)) .. (tonumber(weather.loc.lat) > 0 and 'N' or 'S') .. ' ' .. string.format('%0.f', math.abs(weather.loc.lon)) .. (tonumber(weather.loc.lon) > 0 and 'E' or 'W')) or ''),
    xr = 325,
    yc = 980,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  {
    text = ((weather ~= nil and weather.loc ~= nil and weather.cc ~= nil and weather.cc.flik ~= nil) and string.gsub(weather.loc.dnam, "([A-za-z]*),+.*,+(.*)", "%1,%2") or ''),
    xc = 175,
    yc = 980,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- sunrise/sunset
  {
    --text = '日出 | 日没',
    text = '日の出',
    --text = '朝焼け',
    x = 25,
    yc = 995,
    font = 'HakusyuKaisyoExtraBold_kk',
    size = 18,
    color = {color.sunriseBlue, 0.75},
  },

  {
    --text = '夕焼け',
    --text = '日の入り',
    text = '日の入',
    xr = 325,
    yc = 995,
    font = 'HakusyuKaisyoExtraBold_kk',
    size = 18,
    color = {color.sunsetOrange, 0.75},
  },

  {
    text = ((weather ~= nil and weather.loc ~= nil) and weather.loc.sunr or '') .. ' |',
    xc = 125,
    yc = 995,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 12,
    color = {color.sunriseBlue, 1},
    --color = {color.white, 0.75},
  },

  {
    --text = '|',
    --text = '|' .. ((sun.durPct ~= nil) and sun.durPct .. '%' or '') .. '|',
    text = ((sun.percent ~= nil and sun.percent ~= 0) and sun.percent .. '%' or ''),
    xc = 175,
    yc = 995,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 12,
    --color = {color.white, 1},
    color = {(sun.percent ~= nil) and sunColor[roundUpToMultiple(sun.percent, 10)] or color.white, (sun.percent ~= nil) and (sun.percent > 50 and (100-sun.percent)/50 or sun.percent/50) + .25 or 1},
  },

  {
    text = '| ' .. ((weather ~= nil and weather.loc ~= nil) and weather.loc.suns or ''),
    xc = 225,
    yc = 995,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 12,
    --color = {color.white, 0.75},
    color = {color.sunsetOrange, 1},
  },

  {
    text = (sun.durPct ~= nil) and sun.durPct .. '% (' .. string.format("%d", sun.durHrs) .. ':' .. string.format("%02d", sun.durMin) .. ')' or '',
    xc = 175,
    yc = 1010,
    font = 'Source Code Pro',
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = 10,
    color = {color.white, 0.75},
    --color = {(sun.percent ~= nil) and sunColor[roundUpToMultiple(sun.percent, 10)] or color.black, 1},
  },

  -- midday
  {
    text = 'Midday ' .. seconds_to_clock(sun.midDay),
    x = 25,
    yc = 1010,
    font = 'Source Code Pro',
    size = 10,
    --color = {color.white, 0.75},
    --color = {weekdayCompliment[tonumber(time.weekday)], 1},
    color = {color.sun50, 1},
  },

  -- moon type
  {
    text = ((weather ~= nil and weather.cc ~= nil) and weather.cc.moon.t or ''),
    xr = 325,
    yc = 1010,
    font = 'Source Code Pro',
    size = 10,
    --color = {color.white, 0.75},
    color = {color.moon50, 1},
  },

}
