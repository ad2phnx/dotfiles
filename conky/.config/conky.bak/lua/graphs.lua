-- graphs
graphs = {

  -- cpu
  {
    name = 'cpu',
    arg = '0',
    max = 100,
    x = 12,
    y = 110,
    width = 350,
    height = 20,
    autoscale = true,
    nbValues = 100,
    angle = 0,
    inverse = true,
    bgColor = {{1, color.white, 0}},
    bgOrientation = 'ss',
    bgBdSize = 0,
    bgBdColor = {{0, color.black, 0.1}, {1, color.white, 0.75}},
    bgBdOrientation = 'nn',
    fgColor = {{1, color.black, 0}, {0, color.curiousBlue, 1}},
    fgOrientation = 'ee',
    fgBdSize = 2,
    fgBdColor = {{1, color.black, 0}, {0, color.orangeRoughy, 1}},
    fgBdOrientation = 'ee',
    foreground = true,
    background = true,
  },

  -- mem 
  {
    name = 'memperc',
    arg = '',
    max = 100,
    x = 12,
    y = 150,
    width = 375,
    height = 20,
    autoscale = true,
    nbValues = 100,
    angle = 0,
    inverse = true,
    bgColor = {{1, color.white, 0}},
    bgOrientation = 'ss',
    bgBdSize = 0,
    bgBdColor = {{0, color.black, 0.1}, {1, color.white, 0.75}},
    bgBdOrientation = 'nn',
    fgColor = {{1, color.black, 0}, {0, color.roseGold, 1}},
    fgOrientation = 'ee',
    fgBdSize = 3,
    fgBdColor = {{1, color.black, 0}, {0, color.deYork, 1}},
    fgBdOrientation = 'ee',
    foreground = true,
    background = true,
  },

  -- net up
  {
    name = 'upspeedf',
    arg = 'enp0s3',
    max = 100,
    x = 12,
    y = 440,
    width = 350,
    height = 20,
    autoscale = true,
    nbValues = 100,
    angle = 0,
    inverse = true,
    bgColor = {{0, color.black, 0.1}, {1, color.white, 0.1}},
    bgOrientation = 'ee',
    bgBdSize = 0,
    bgBdColor = {{0, color.black, 0.1}, {1, color.white, 0.75}},
    bgBdOrientation = 'nn',
    fgColor = {{1, color.black, 0}, {0, color.white, 0}},
    fgOrientation = 'ee',
    fgBdSize = 1,
    fgBdColor = {{1, color.black, 0}, {0, color.yellow, 1}},
    fgBdOrientation = 'ee',
    foreground = true,
    background = true,
  },

  -- net down
  {
    name = 'downspeedf',
    arg = 'enp0s3',
    max = 100,
    x = 12,
    y = 440,
    width = 350,
    height = 20,
    autoscale = true,
    nbValues = 100,
    angle = 0,
    inverse = true,
    bgColor = {{0, color.black, 0.1}, {1, color.white, 0.1}},
    bgOrientation = 'ee',
    bgBdSize = 0,
    bgBdColor = {{0, color.black, 0.1}, {1, color.white, 0.75}},
    bgBdOrientation = 'nn',
    fgColor = {{1, color.black, 0}, {0, color.white, 1}},
    fgOrientation = 'ee',
    fgBdSize = 1,
    fgBdColor = {{1, color.black, 0}, {0, color.green, 1}},
    fgBdOrientation = 'ee',
    foreground = false,
    background = false,
  },
}
