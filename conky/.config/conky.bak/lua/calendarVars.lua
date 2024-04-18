imgTmp = os.getenv("HOME") .. "/.tmp/imgTmp.png"
imgCal = os.getenv("HOME") .. "/.tmp/calArc.png"
imgDates = os.getenv("HOME") .. "/.tmp/calDates.png"

calWheel = {
  xc = 600,
  yc = 400,
  radius = 100,
  ratioArc = 0.8,
  range = 10,
  wkDayColor = monthColor[tonumber(time.month)],
  weDayColor = monthCompliment[tonumber(time.month)],
  dDayColor = weekdayColor[tonumber(time.weekday)],
  infoColor = color.yellow,
  infoAlpha = 0.1,
  vGradient = true,
  hGradient = 0,
  font = 'Source Code Pro',
  fontSize = 12,
  txtOffset = 4,
  fontInfo = 'Source Code Pro',
  fontSizeInfo = 24,
  fontAlphaInfo = 0.1,
  todayXOffset = 10,
  todayYOffset = -5,
  alignR = false,
  dateFormat = "%a %d %b",
  txtX = 200,
  txtY = 300,
  calendarFile = os.getenv("HOME") ..  "/.config/conky.bak/lua/calendar.txt",
}

--minCal = {
--
--  -- position
--  x = cCenter.x,
--  y = cCenter.y + 350,
--  daysPos = 't',
--  monthPos = 't',
--  infoPos = 'b',
--  hpadding = 8,
--  vpadding = 8,
--  border = 1,
--  gap = 2,
--  radius = 2,
--
--  -- font
--  font = 'Source Code Pro',
--  fontToday = 'Source Code Pro',
--  fontWeekday = 'HakusyuKaisyoExtraBold_kk',
--  --fontMonth = 'Japan',
--  fontMonth = 'HakusyuKaisyoExtraBold_kk',
--  fontSize = '16',
--  fontSizeToday = '20',
--  fontSizeWeekday = '20',
--  fontSizeMonth = '32',
--  alignment = 'c',
--
--  -- month
--  monthOffset = 0,
--  monthFormat = '%B %Y',
--  gradient = 0,
--  orientation = 'ss',
--  displayOtherDays = true,
--
--  -- colors
--  colBox = {color.black, color.black, 1, 1, color.black, color.black, 1, 1},
--  colBoxText = {color.white, monthColor[tonumber(time.month)], 1, 1},
--  colBoxTextUpcoming = {color.white, color.white, 1, 1},
--  colBoxTextBefore = {color.white, monthColor[tonumber(time.month) - 1 % 12], 0.25, 0.25},
--  colBoxTextAfter = {color.white, monthColor[tonumber(time.month) + 1 % 12], 0.25, 0.25},
--
--  colBoxToday = {color.black, color.black, 1, 1, weekdayCompliment[time.weekday], color.white, 0.5, 0.5},
--  colBoxTextToday = {weekdayColor[time.weekday], weekdayColor[time.weekday], 1, 1},
--
--  colBoxHoliday = {color.white, color.white, 1, 1, monthColor[tonumber(time.month)], color.white, 0.5, 0.5},
--  colBoxHolidayBefore = {color.black, color.black, 1, 1, monthColor[tonumber(time.month) - 1 % 12], color.white, 0.25, 0.25},
--  colBoxHolidayAfter = {color.black, color.black, 1, 1, monthColor[tonumber(time.month) + 1 % 12], color.white, 0.25, 0.25},
--  colBoxTextHoliday = {monthCompliment[tonumber(time.month)], color.black, 0.75, 0.75},
--  colBoxTextHolidayBefore = {monthCompliment[tonumber(time.month) - 1 % 12], color.white, 0.25, 0.25},
--  colBoxTextHolidayAfter = {monthCompliment[tonumber(time.month) + 1 % 12], color.white, 0.25, 0.25},
--
--  colBoxDays = {color.black, color.black, 1, 1, color.white, color.black, 0.25, 0.25},
--  colBoxDaysText = {color.white, color.white, 0.9, 1},
--
--  colBoxCurrentWeek = {monthColor[tonumber(time.month)], monthColor[tonumber(time.month)], 0.25, 0.25, color.black, color.black, 0.5, 0.5},
--  colBoxTextCurrentWeek = {color.black, color.black, 0.9, 1},
--
--  colBoxMonth = {color.black, color.black, 1, 1, color.white, color.white, 0.25, 0.25},
--  colBoxMonthText = {monthColor[tonumber(time.month)], color.white, 1, 1},
--
--  colBoxInfo = {color.black, color.black, 1, 1, color.white, color.white, 0.25, 0.25},
--  colBoxInfoText = {color.white, color.white, 1, 1},
--
--  -- info
--  displayInfoBox = true,
--  displayEmptyInfoBox = true,
--  calendarFile = os.getenv("HOME") .. "/.config/conky.bak/lua/calendar.txt",
--}



calendar = {

  -- position
  x = cCenter.x - 400,
  y = cCenter.y + cHeight / 4,
  daysPos = 't',
  monthPos = 't',
  infoPos = 'b',
  hpadding = 7,
  vpadding = 7,
  border = 1,
  gap = 2,
  radius = 2,

  -- font
  font = 'Square Sans Serif 7',
  fontToday = 'Square Sans Serif 7',
  --fontWeekday = 'HakusyuKaisyoExtraBold_kk',
  fontWeekday = 'IPAMincho',
  --fontMonth = 'Japan',
  --fontMonth = 'HakusyuKaisyoExtraBold_kk',
  fontMonth = 'IPAMincho',
  fontSize = '16',
  fontSizeToday = '24',
  fontSizeWeekday = '28',
  fontSizeMonth = '32',
  alignment = 'c',

  -- month
  monthOffset = 0,
  monthFormat = '%B %Y',
  gradient = 0,
  orientation = 'ss',
  displayOtherDays = true,

  -- colors
  colBox = {color.black, color.black, 0.75, 0.75, color.black, color.black, 0.75, 0.75},
  colBoxText = {color.white, monthColor[tonumber(time.month)], 1, 1},
  colBoxTextUpcoming = {color.white, color.white, 1, 1},
  colBoxTextBefore = {color.white, monthColor[(tonumber(time.month) - 2) % 12 + 1], 0.25, 0.25},
  colBoxTextAfter = {color.white, monthColor[(tonumber(time.month) + 1) % 12], 0.25, 0.25},

  colBoxToday = {color.black, color.black, 0.75, 0.75, weekdayCompliment[time.weekday], color.white, 0.5, 0.5},
  colBoxTextToday = {weekdayColor[time.weekday], weekdayColor[time.weekday], 1, 1},

  colBoxHoliday = {color.white, color.white, 0.75, 0.75, monthColor[tonumber(time.month)], color.white, 0.5, 0.5},
  colBoxHolidayBefore = {color.black, color.black, 0.75, 0.75, monthColor[(tonumber(time.month) - 2) % 12 + 1], color.white, 0.25, 0.25},
  colBoxHolidayAfter = {color.black, color.black, 0.75, 0.75, monthColor[tonumber(time.month) + 1 % 12], color.white, 0.25, 0.25},
  colBoxTextHoliday = {monthCompliment[tonumber(time.month)], color.black, 0.75, 0.75},
  colBoxTextHolidayBefore = {monthCompliment[(tonumber(time.month) - 2) % 12 + 1], color.white, 0.25, 0.25},
  colBoxTextHolidayAfter = {monthCompliment[tonumber(time.month) + 1 % 12], color.white, 0.25, 0.25},

  colBoxDays = {color.black, color.black, 0.75, 0.75, color.white, color.black, 0.25, 0.25},
  colBoxDaysText = {color.white, color.white, 0.9, 1},

  colBoxCurrentWeek = {monthColor[tonumber(time.month)], monthColor[tonumber(time.month)], 0.25, 0.25, color.black, color.black, 0.5, 0.5},
  colBoxTextCurrentWeek = {color.black, color.black, 0.9, 1},

  colBoxMonth = {color.black, color.black, 0.75, 0.75, color.white, color.white, 0.25, 0.25},
  colBoxMonthText = {monthColor[tonumber(time.month)], color.white, 1, 1},

  colBoxInfo = {color.black, color.black, 0.75, 0.75, color.white, color.white, 0.25, 0.25},
  colBoxInfoText = {color.white, color.white, 1, 1},

  -- info
  displayInfoBox = true,
  displayEmptyInfoBox = true,
  calendarFile = os.getenv("HOME") .. "/.config/conky.bak/lua/calendar.txt",
}
