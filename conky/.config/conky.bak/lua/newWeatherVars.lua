-- base line forecast/calendar connector
baseLine = {
  x = cCenter.x,
  y = cCenter.y - 550,
  tox = cCenter.x,
  toy = cCenter.y,
  color = {color.white, 0.25},
  width = 34,
}

-- base forecast text
fcastText = {
  text = 'testing',
  xc = cCenter.x - 400,
  yc = cCenter.y + 50,
  --font = 'Source Code Pro',
  --font = 'HakusyuKaisyoExtraBold_kk',
  font = 'Kochi Mincho',
  --font = 'Sazanami Mincho',
  size = 12,
  color = {color.white, 0.75},
}

-- base forecast images
fcastImg = {
  x = cCenter.x,
  y = cCenter.y - 550,
  w = 48,
  h = 48,
  file = os.getenv("HOME") .. '/.config/conky.bak/weather/NA.png',
}

-- images
images = {

    -- current condition
    {
        x = 175,
        y = 910,
        w = 128,
        h = 128,
        file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((weather ~= nil and weather['weather'] ~= nil) and weather['weather'][1]['icon'] .. '@2x' or 'NA') .. '.png',
        --file = weatherIcons.currentIcon:read('*a'),
    },

    -- Moon
    {
        x = 325 - 24,
        y = 1080 - 16 - 24,
        w = 48,
        h = 48,
        file = os.getenv("HOME") .. '/.config/conky.bak/moon/' .. ((moon ~= nil and moon.icon ~= nil) and moon.icon or 'NA.png'),
        rotate = true,
        theta = (moon ~= nil and moon.degree) or 0,
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

-- boxes
boxes = {

      -- clock bg
      --{
      --  x = cCenter.x - 400 - 175 - 1,
      --  y = cCenter.y - cHeight / 4 - 225,
      --  w = 350,
      --  h = 450,
      --  scaleX = 1,
      --  scaleY = 1,
      --  corners = {{'circle', 2}},
      --  color = {{0, monthColor[tonumber(time.month)], 0.1}},
      --  border = 0,
      --},

      -- calendar bg
      --{
      --  x = cCenter.x - 400 - 175 - 1,
      --  y = cCenter.y + cHeight / 4 - 225,
      --  w = 350,
      --  h = 450,
      --  scaleX = 1,
      --  scaleY = 1,
      --  corners = {{'circle', 2}},
      --  color = {{0, monthCompliment[tonumber(time.month)], 0.1}},
      --  border = 0,
      --},

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
        y = 1080 - 16 - 48,
        w = 48,
        h = 48,
        corners = {{'circle', 24}},
        color = {{1, color.lavenderGrey, 0.25}, {0, color.black, 0}},
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
        --arg = tonumber(string.format("%.f", ((time.twofour * 60 + time.minutes)/1440) * 100)),
        arg = tonumber(string.format("%d", ((time.twofour * 60 + time.minutes)/1440) * 100)),
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
        --fgColor1 = {{0, color.black, 0}, {0.25, weekdayColor[time.weekday], 1}, {0.5, color.black, 0}, {0.75, weekdayColor[time.weekday], 1}, {1, color.black, 0}},
        fgColor1 = {{0, color.black, 0}, {0.25, color.yellow, 1}, {0.5, color.black, 0}, {0.75, color.yellow, 1}, {1, color.black, 0}},
    },

    -- Midday
    {
        name = '',
        --arg = sun.timePct,
        --arg = tonumber(string.format("%.f", ((seconds_to_min(sun.midDay)) / 1440 * 100))),
        arg = tonumber(string.format("%d", ((seconds_to_min(sun.midDay)) / 1440 * 100))),
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
        fgColor1 = {{0, color.black, 0}, {0.15, color.sun30, 1}, {0.5, color.black, 0}, {0.85, color.sun30, 1}, {1, color.black, 0}},
    },

}

texts = {
    {
        text = 'weather',
        x = 25,
        yc = 830,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- current conditions
    {
        text = (weather ~= nil and weather['main'] ~= nil and weather['weather'] ~= nil) and weather['main']['temp'] .. '°C ' .. weather['weather'][1]['main'] .. (weather['weather'][2] ~= nil and ' [' .. weather['weather'][2]['main'] .. ']' or '') or 'loading...',
        xc = 175,
        yc = 830,
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 12,
        color = {color.white, 0.75},
    },

    {
        text = (weather ~= nil and weather['weather']) and weather['weather'][1]['description'] .. (weather['weather'][2] ~= nil and '・' .. weather['weather'][2]['description'] or ''),
        xc = 175,
        yc = 850,
        --font = 'HakusyuKaisyoExtraBold_kk',
        font = 'Kochi Mincho',
        --font = 'Sazanami Mincho',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 24,
        color = {color.white, 0.75},
    },

    -- last update
    {
        text = (weather ~= nil and weather['dt'] ~= nil) and os.date("%H:%M", weather['dt']) or '',
        xr = 325,
        yc = 830,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- advisory
    -- today forecast morning
    -- hi/lo today
    -- today forecast evening
    
    -- feels like
    {
        text = 'Feels',
        x = 25,
        yc = 860,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = '░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
        xc = 175,
        yc = 860,
        --font = 'Square Sans Serif 7',
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {color.white, 0.25},
    },

    {
        text = (weather ~= nil and weather['main'] ~= nil and weather['main']['feels_like'] ~= nil) and weather['main']['feels_like'] .. '°C' or '',
        xr = 325,
        yc = 860,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- wind
    {
        text = 'Wind',
        x = 25,
        yc = 875,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = (weather ~= nil and weather['wind'] ~= nil) and weather['wind']['speed'] .. ' m/s' .. (weather['wind']['deg'] ~= nil and ' ' .. degreeToCardinal(weather['wind']['deg']) or '') or '',
        xr = 325,
        yc = 875,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- humidity
    {
        text = 'Humidity',
        x = 25,
        yc = 890,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = '░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
        xc = 175,
        yc = 890,
        --font = 'Square Sans Serif 7',
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {color.white, 0.25},
    },


    {
        text = (weather ~= nil and weather['main'] ~= nil) and weather['main']['humidity'] .. '%' or '',
        xr = 325,
        yc = 890,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- clouds
    {
        text = 'Clouds',
        x = 25,
        yc = 905,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = (weather ~= nil and weather['clouds'] ~= nil) and (weather['clouds']['all'] .. '%') or '',
        xr = 320,
        yc = 905,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- rain
    {
        text = 'Rain',
        x = 25,
        yc = 920,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = '░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
        xc = 175,
        yc = 920,
        --font = 'Square Sans Serif 7',
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {color.white, 0.25},
    },


    {
        text = (weather ~= nil and weather['rain'] ~= nil and weather['rain']['1h'] ~= nil) and weather['rain']['1h'] .. ' m' or '-',
        xr = 325,
        yc = 920,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- snow 
    {
        text = 'Snow',
        x = 25,
        yc = 935,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = (weather ~= nil and weather['snow'] ~= nil and weather['snow']['1h'] ~= nil) and weather['snow']['1h'] .. ' m' or '-',
        xr = 325,
        yc = 935,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },


    -- pressure
    {
        text = 'Pressure',
        x = 25,
        yc = 950,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = '░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
        xc = 175,
        yc = 950,
        --font = 'Square Sans Serif 7',
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {color.white, 0.25},
    },

    {
        text = (weather ~= nil and weather['main'] ~= nil) and weather['main']['pressure'] .. ' hPa' or '',
        xr = 325,
        yc = 950,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },


    -- visibility
    {
        text = 'Visibility',
        x = 25,
        yc = 965,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = (weather ~= nil and weather['visibility'] ~= nil) and weather['visibility'] .. ' m' or '',
        xr = 325,
        yc = 965,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    -- location
    {
        text = 'Location',
        x = 25,
        yc = 980,
        font = 'Square Sans Serif 7',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        --color = {color.curiousBlue, 1},
        color = {weekdayColor[time.weekday], 1},
    },

    {
        text = '░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
        xc = 175,
        yc = 980,
        --font = 'Square Sans Serif 7',
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 10,
        color = {color.white, 0.25},
    },


    {
        text = ((weather ~= nil and weather['coord'] ~= nil) and (string.format('%0.f', math.abs(weather['coord']['lat'])) .. (tonumber(weather['coord']['lat']) > 0 and 'N' or 'S') .. ' ' .. string.format('%0.f', math.abs(weather['coord']['lon'])) .. (tonumber(weather['coord']['lon']) > 0 and 'E' or 'W')) or ''),
        xr = 325,
        yc = 980,
        font = 'Source Code Pro',
        size = 10,
        color = {color.white, 0.75},
    },

    {
        text = (weather ~= nil and weather['name'] ~= nil) and weather['name'] or '',
        xc = 175,
        yc = 980,
        font = 'HakusyuKaisyoExtraBold_kk',
        size = 16,
        color = {color.white, 0.75},
    },

    -- sunrise/sunset
    {
        text = '日の出',
        x = 25,
        yc = 995,
        font = 'HakusyuKaisyoExtraBold_kk',
        size = 18,
        color = {color.sunriseBlue, 0.75},
    },

    {
        text = '日の入',
        xr = 325,
        yc = 995,
        font = 'HakusyuKaisyoExtraBold_kk',
        size = 18,
        color = {color.sunsetOrange, 0.75},
    },

    {
        text = ((weather ~= nil and weather['sys'] ~= nil) and os.date("%I:%M %p", weather['sys']['sunrise']) or '') .. ' |',
        xc = 125,
        yc = 995,
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 12,
        color = {color.sunriseBlue, 1},
        --color = {color.white, 0.75},
    },

    {
        text = ((sun.percent ~= nil and sun.percent ~= 0) and sun.percent .. '%' or ''),
        xc = 175,
        yc = 995,
        font = 'Source Code Pro',
        face = CAIRO_FONT_WEIGHT_BOLD,
        size = 12,
        color = {(sun.percent ~= nil) and sunColor[roundUpToMultiple(sun.percent, 10)] or color.white, (sun.percent ~= nil) and (sun.percent > 50 and (100-sun.percent)/50 or sun.percent/50) + .25 or 1},
    },

    {
        text = '| ' .. ((weather ~= nil and weather['sys'] ~= nil) and os.date("%I:%M %p", weather['sys']['sunset']) or ''),
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
        color = {color.sun50, 1},
    },

    -- moon type
    {
        text = ((moon ~= nil and moon.phase ~= nil) and moon.phase or ''),
        xr = 325,
        yc = 1010,
        font = 'Source Code Pro',
        size = 10,
        --color = {color.white, 0.75},
        color = {color.moon50, 0.75},
    },
}
