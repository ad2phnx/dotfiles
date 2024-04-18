--[[Colors]]--
color = {
  aeroBlue = 0xb9ffee,
  amethyst = 0x9e50bf,
  aquamarine = 0x7fffd4,
  bahamaBlue = 0x086fa1,
  balticSea = 0x18171a,
  black = 0x080709,
  blazeOrange = 0xff9600,
  chartreuse = 0x7ce700,
  cinder = 0x111018,
  cumulus = 0xfffed7,
  curiousBlue = 0x1793d1,
  cyan = 0x00ffff,
  deYork = 0x81c080,
  diamond = 0xffc6b9,
  doveGray = 0x737373,
  dustyGray = 0x989898,
  electricViolet = 0xde00e6,
  emerald = 0x50c878,
  flamePea = 0xd55630,
  freebsdDarkRed = 0xa2bb28,
  freebsdRed = 0xeb0028,
  freebsdBlack = 0x000000,
  freebsdDark = 0x333333,
  freebsdGrey = 0x8c8c8c,
  freebsdLightGrey = 0xcccccc,
  freebsdAOrange = 0xff671b,
  freebsdAYellow = 0xffc628,
  freebsdABlue = 0x002e6d,
  forestGreen = 0x438527,
  fuzzyWuzzyBrown = 0xc85a50,
  garnet = 0x852743,
  gentooGray = 0xdddaec,
  gentooGreen = 0x73d216,
  gentooPurple = 0x54487a,
  gentooPurpleLight = 0x61538d,
  gentooPurpleLight2 = 0x6e56af,
  gentooRed = 0xd9534f,
  gold = 0xffd700,
  green = 0x00fd00,
  greenSmoke = 0xa2b579,
  heavyMetal = 0x262621,
  heliotrope = 0x927cff,
  indigo = 0x5973c1,
  jade = 0x00b64f,
  jellyBean = 0x2974a6,
  koromiko = 0xffae64,
  kournikova = 0xffe764,
  lavenderGrey = 0xccbada,
  lima = 0x60e011,
  magenta = 0xff00ff,
  midGray = 0x625f6c,
  milkPunch = 0xfff7d7,
  mineshaft = 0x323232,
  oldRose = 0xc08081,
  orange = 0xffa500,
  orangeRoughy = 0xd15517,
  opal = 0xa9c6c2,
  orinoco = 0xeef9d2,
  orient = 0x015e85,
  paarl = 0x9e5d2f,
  pearl = 0xa65529,
  peridot = 0xe6e200,
  persianGreen = 0x00a2a7,
  pizazz = 0xfe8800,
  purple = 0x7009a9,
  red = 0xff0000,
  regentsBlue = 0xadd8e6,
  rose = 0xfd007f,
  roseGold = 0xb76e79,
  roti = 0xbfae50,
  ruby = 0xe0115f,
  sapphire = 0x2f519e,
  scarlet = 0xff3500,
  silk = 0xc6afa9,
  silver = 0xcacaca,
  sunriseBlue = 0xccd5df,
  sun20 = 0xbdd9de,
  sun30 = 0xafddd1,
  sun40 = 0xa1dcb6,
  sun50 = 0x96db93,
  sun60 = 0xaada85,
  sun70 = 0xc8d978,
  sun80 = 0xd8c06a,
  sun90 = 0xd78c5d,
  sunsetOrange = 0xd65050,
  moon50 = 0xc093db,
  topaz = 0xffc87c,
  toryBlue = 0x133aac,
  turquoise = 0x30d5c8,
  violet = 0x8f3599,
  vividTangerine = 0xff947f,
  yellow = 0xfdfd00,
  white = 0xfdfdfd,
}

-- Weekday/Week/Month colors
weekdayColor = {
  color.white, color.lavenderGrey, color.scarlet, color.bahamaBlue,
  color.blazeOrange, color.yellow, color.green
}
weekdayCompliment = {
  color.silver, color.cumulus, color.jade, color.pizazz, color.persianGreen,
  color.purple, color.red
}
monthColor = {
  color.garnet, color.amethyst, color.aquamarine, color.diamond, color.emerald,
  color.pearl, color.ruby, color.peridot, color.sapphire, color.opal, color.topaz,
  color.turquoise
}
monthCompliment = {
  color.forestGreen, color.roti, color.vividTangerine, color.aeroBlue,
  color.fuzzyWuzzyBrown, color.jellyBean, color.lima, color.electricViolet,
  color.paarl, color.silk, color.heliotrope, color.flamePea
}

-- Sunlight colors
sunColor = {
  [10] = color.sunriseBlue,
  [20] = color.sun20,
  [30] = color.sun30,
  [40] = color.sun40,
  [50] = color.sun50,
  [60] = color.sun60,
  [70] = color.sun70,
  [80] = color.sun80,
  [90] = color.sun90,
  [100] = color.sunsetOrange,
}

-- Kanji/Hiragana substitutions
weekdayKanji = { '日', '月', '火', '水', '木', '金', '土' }
monthKanji = {
  '一', '二', '三', '四', '五', ' 六','七', '八', '九', '十', '十一', '十二'
}
monthEnd = '月'
weatherKanji = {
  morning = '朝',
  night = '夜',
  forecast = '天気予報',
}
nameKatakana = 'アナトリー'
yearKanji = '令和'

--[[WaniKani]]--
wkRevIcon = ''
wkLesIcon = ''
wkCritIcon = ''
wkLevelIcon = ''

--[[Battery]]--
power = ''
batPlug = ''
batDesk = ''
bat = {
  empty = '',
  quarter = '',
  half = '',
  threeQuarters = '',
  full = '',
}

--[[Weather]]--
sWeather = {
  id = '1850144',   -- Tokyo-to
  --id = '1850147', -- Tokyo
  --id = '1864529',   -- Chiyoda-ku
  units = 'metric',
  lang = 'ja',
}

--[[Calendar]]--
calendarFile = "${HOME}/.config/conky.bak/lua/calendar.txt"
