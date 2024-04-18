-- base tables

-- base weeks ring
weekRing = {
    name = '',
    arg = 0,
    max = 12,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    radius = 65,
    thickness = 20,
    startAngle = -90,
    endAngle = 270,
    sectors = 12,
    gapSectors = 4,
    cap = 'p',
    inverseArc = false,
    borderSize = 0,
    fillSector = false,
    allSectors = false,
    background = true,
    foreground = true,
    bgColor1 = {{0, color.black, 0}, {0.5, color.white, 0.2}, {1, color.black, 0}},
    fgColor1 = {{0, color.black, 0}, {0.5, color.white, 1}, {1, color.black, 0}},
}

-- base wanikani hour reviews
wkRevRing = {
  name = '',
  arg = 0,
  max = 100,
  xc = cCenter.x - 400,
  yc = cCenter.y - cHeight / 4,
  radius = 110,
  thickness = 0,
  startAngle = -90,
  endAngle = 270,
  sectors = 1,
  gapSectors = 5,
  cap = 'p',
  inverseArc = false,
  borderSize = 0,
  fillSector = false,
  allSectors = false,
  background = true,
  foreground = true,
  bgColor1 = {{0, color.gentooRed, 1}},
  fgColor1 = {{0, color.gentooPurpleLight, 1}},
}

-- base 24 hour clock text
hourText = {
  text = 'T',
  xc = cCenter.x - 400,
  yc = cCenter.y - cHeight /4,
  font = 'Square Sans Serif 7',
  size = 16,
  color = {color.white, 0.75},
}

wkReviews = {
  text = '',
  xc = cCenter.x - 500,
  yc = cCenter.y,
  font = 'Square Sans Serif 7',
  size = 12,
  color = {color.roseGold, 1},
}

-- texts
texts = {

  -- Month shadow
  --{
  --  text = monthKanji[tonumber(time.month)],
  --  xc = cCenter.x + 5,
  --  yc = cCenter.y - 310 + 5,
  --  font = 'HakusyuKaisyoExtraBold_kk',
  --  size = 96,
  --  color = {monthCompliment[tonumber(time.month)], 0.5},
  --},

  ---- Month
  --{
  --  text = monthKanji[tonumber(time.month)],
  --  xc = cCenter.x,
  --  yc = cCenter.y - 310,
  --  font = 'HakusyuKaisyoExtraBold_kk',
  --  size = 96,
  --  color = {monthColor[tonumber(time.month)], 0.5},
  --},

  -- Weekday
  {
    text = weekdayKanji[tonumber(time.weekday)],
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    --font = 'HakusyuKaisyoExtraBold_kk',
    font = 'IPAMincho',
    size = 172,
    color = {weekdayColor[tonumber(time.weekday)], 0.25},
  },

  -- Time
  {
    text = string.format("%0.f", time.hours) .. ':' .. time.minutes .. ' ' .. time.ampm,
    x = 25,
    yc = 1040,
    font = 'Square Sans Serif 7',
    size = 40,
    color = {color.white, 0.75},
  },

  -- base wanikani level
  --{
  --  text = (wanikani.userLevel > 0) and wanikani.userLevel or "0",
  --  xc = cCenter.x - 400,
  --  yc = cCenter.y - cHeight / 4,
  --  font = 'Japan',
  --  size = 48,
  --  color = {color.roseGold, 0.5},
  --},
}

rings = {

  -- 24 hour clock bg
  {
    name = '',
    arg = 0,
    max = 100,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    radius = 150,
    thickness = 30,
    startAngle = 98.5,
    endAngle = 458.5,
    sectors = 24,
    gapSectors = 9,
    cap = 'r',
    inverseArc = false,
    borderSize = 1,
    fillSector = false,
    allSectors = false,
    background = true,
    foreground = false,
    bgColor1 = {{0, color.black, 0.5}},
    bdColor1 = {{0, weekdayCompliment[time.weekday], 0}, {0.35, weekdayCompliment[time.weekday], 1}, {0.5, color.white, 0.75}, {0.75, weekdayCompliment[time.weekday], 1}, {1, weekdayCompliment[time.weekday], 0}},
  },

  -- clock ticks
  {
    name = '',
    arg = 0,
    max = 360,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    radius = 115,
    thickness = 25,
    startAngle = -43.5,
    endAngle = 316.5,
    sectors = 12,
    gapSectors = 60,
    cap = 'r',
    inverseArc = false,
    borderSize = 0,
    fillSector = false,
    allSectors = false,
    background = true,
    foreground = false,
    bgColor1 = {{0, color.black, 0}, {1, color.silver, 1}},
    --bdColor1 = {{0, weekdayCompliment[time.weekday], 0}, {0.35, weekdayCompliment[time.weekday], 1}, {0.5, color.white, 0.75}, {0.75, weekdayCompliment[time.weekday], 1}, {1, weekdayCompliment[time.weekday], 0}},
  },

  -- clock hours
  {
    name = '',
    arg = time.twofour,
    max = 24,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    radius = 85,
    thickness = 30,
    startAngle = 98.5,
    endAngle = 458.5,
    sectors = 24,
    gapSectors = 14,
    cap = 'r',
    inverseArc = false,
    borderSize = 0,
    fillSector = true,
    allSectors = false,
    background = false,
    foreground = true,
    bgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.1}, {1, color.black, 0}},
    fgColor1 = {{0.1, color.black, 0}, {0.7, weekdayColor[time.weekday], 1}, {1, color.black, 0}},
    bdColor1 = {{0.1, color.black, 0}, {0.7, color.black, 0.25}, {1, color.black, 0}},
  },

  -- clock minutes
  {
    name = '',
    arg = time.minutes + 1,
    max = 60,
    xc = cCenter.x - 400,
    yc = cCenter.y - cHeight /4,
    radius = 100,
    thickness = 50,
    startAngle = -91.5,
    endAngle = 268.5,
    sectors = 60,
    gapSectors = 7,
    cap = 'r',
    inverseArc = false,
    borderSize = 0,
    fillSector = true,
    allSectors = false,
    background = false,
    foreground = true,
    --bgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.1}, {1, color.black, 0}},
    --fgColor1 = {{0.1, color.black, 0}, {0.7, weekdayColor[time.weekday], 1}, {1, color.black, 0}},
    --bdColor1 = {{0.1, color.black, 0}, {0.7, color.black, 0.25}, {1, color.black, 0}},
    bgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.1}, {1, color.black, 0}},
    fgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 1}, {1, color.black, 0}},
    bdColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.25}, {1, color.black, 0}},
  },

  -- clock seconds
  --{
  --  name = '',
  --  arg = time.seconds + 1,
  --  max = 60,
  --  xc = cCenter.x,
  --  yc = cCenter.y,
  --  radius = 110,
  --  thickness = 20,
  --  startAngle = -91.5,
  --  endAngle = 268.5,
  --  sectors = 60,
  --  gapSectors = 10,
  --  cap = 'r',
  --  inverseArc = false,
  --  borderSize = 0,
  --  fillSector = true,
  --  allSectors = false,
  --  background = false,
  --  foreground = true,
  --  bgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.1}, {1, color.black, 0}},
  --  fgColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 1}, {1, color.black, 0}},
  --  bdColor1 = {{0.1, color.black, 0}, {0.7, weekdayCompliment[time.weekday], 0.25}, {1, color.black, 0}},
  --},

}

-- boxes
boxes = {

  -- Clock bg
  {
    x = cCenter.x - 400 - 150,
    y = cCenter.y - 150 - cHeight /4,
    w = 300,
    h = 300,
    corners = {{'circle', 128}},
    color = {{0, color.black, 0.5}, {0.5, weekdayColor[time.weekday], 0.1}, {1, color.black, 0}},
    border = 0,
    radialGradient = {150, 150, 75, 150, 150, 150},
  },
}
