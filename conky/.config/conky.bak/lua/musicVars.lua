-- mpd vars
mpdOn = conky_parse('${if_running mpd}On${else}Off${endif}')
mpd = {
  on = conky_parse('${if_running mpd}On${else}Off${endif}'),
  name = conky_parse('${if_mpd_playing}${mpd_name}${else}No name${endif}'),
  file = conky_parse('${if_mpd_playing}${mpd_file}${else}No file${endif}') or "",
  smart = conky_parse('${if_mpd_playing}${mpd_smart}${else}Stopped${endif}'),
  dir = string.gsub(conky_parse('${if_mpd_playing}${mpd_smart}${else}Stopped${endif}'), "(.*)/(.*)", "%1"),
  fName = string.gsub(conky_parse('${if_mpd_playing}${mpd_smart}${else}Stopped${endif}'), ".*/(.*)", "%1"),
  percent = conky_parse('${if_mpd_playing}${mpd_percent}${else}0${endif}'),
  rnd = conky_parse('${mpd_random}'),
  rpt = conky_parse('${mpd_repeat}'),
  sgl = get_con("mpc | awk 'NR==3 {print $7}'"),
  csm = get_con("mpc | awk 'NR==3 {print $9}'"),
  status = conky_parse('${if_running mpd}${mpd_status}${else}MPD Not Running${endif}'),
  title = conky_parse('${if_mpd_playing}${mpd_title 30}${else}No title${endif}'),
  track = conky_parse('${if_mpd_playing}${mpd_track}${else}No track${endif}'),
  --volume = conky_parse('${mpd_vol}'),
  volume = string.gsub(get_con("amixer sget Master | awk 'NR==6 {print $5}'"), '[^%d]', ''),
  headphones = string.gsub(get_con("pactl list sinks | grep \"Active Port\" | awk 'NR==1 {print $3}'"), 'analog%-output%-(.*)', '%1'),
  isVolOn = string.gsub(get_con("amixer sget Master | awk 'NR==6 {print $6}'"), '[^%w]', ''),
  elapsed = conky_parse('${if_mpd_playing}${mpd_elapsed}${else}${endif}'),
  length = conky_parse('${if_mpd_playing}${mpd_length}${else}${endif}'),
  bitrate = conky_parse('${if_mpd_playing}${mpd_bitrate}${else}${endif}'),
  album = conky_parse('${if_mpd_playing}${mpd_album}${else}${endif}'),
  artist = conky_parse('${if_mpd_playing}${mpd_artist}${else}${endif}'),
  rating = mpdOn == "On" and file and (check_file(os.getenv("HOME") .. '/Music/' .. file) and get_con('eyeD3 -l error ' .. os.getenv("HOME") ..  '/Music/"' .. file .. '" | awk \'/Popularity/\' | sed -r \'s/.*rating: ([0-9]+)\\].*/\\1/\'') or 0) or 0, 
  --rating = 0, 
  favorite = get_con('if grep -q "$(ncmpcpp -q --current-song %D/%f)" ' .. os.getenv("HOME") .. '/.config/mpd/playlists/Favorites.m3u; then echo True; else echo False; fi')
}

-- play change / cover info
coverArt = os.getenv("HOME") .. "/.config/conky.bak/covers/FRONT_COVER"
coverColor = coverColor or color.black
coverCompliment = coverCompliment or color.white
noCover = os.getenv("HOME") .. "/.config/conky.bak/covers/no_cover.png"
playChange = ((mpd.file ~= "" and currentPlay ~= mpd.file) and true or false)
currentPlay = (mpd.file or "")

-- images
images = {

  -- album art 
  {
    x = 175,
    y = 650,
    w = 256,
    h = 256,
    file = ((check_file(coverArt .. '.png') and (coverArt .. '.png') or noCover)),
  },
}

-- boxes
boxes = {

  -- album bg
  {
    x = 25,
    y = 500,
    w = 300,
    h = 300,
    corners = {{'circle', 5}},
    color = {(mpd.favorite == 'True') and {0, coverColor, 0.75} or {0, coverColor, 0.1}},
    --color = {(mpd.favorite == 'True') and {0, albumCoverColor, 0.75} or {0, albumCoverColor, 0.25}},
    --border = 2,
  },
}

-- base rating
baseRating = {
  xc = 175,
  yt = 502,
  font = 'DejaVu Sans',
  size = 24,
  color = {color.white, 1},
}
    
texts = {

  -- favorite
  {
    text = '',
    xr = 320,
    yt = 505,
    font = 'Font Awesome 6 Free',
    size = 24,
    --color = {color.white, 0.1},
    color = (mpd.favorite == 'True') and {coverColor, 0.75} or {coverColor, 0.1},
  },

  -- headphones
  {
    text = '',
    x = 30,
    yt = 505,
    font = 'Font Awesome',
    size = 24,
    --color = {color.white, 0.75},
    color = (mpd.headphones == 'headphones') and {color.curiousBlue, 0.75} or {color.white, 0.1},
  },

  -- mpd header
  {
    text = 'mpd ' .. mpd.on,
    x = 25,
    yc = 450,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 0.75},
  },

  -- elapsed/length
  {
    text = (mpd.on == 'On') and mpd.elapsed .. ' / ' .. mpd.length or '',
    xr = 325,
    yc = 450,
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 1},
  },

  -- mpd album 
  {
    text = (mpd.on == 'On') and string.sub(mpd.album, 1, 50) or '',
    x = 25,
    yc = 470,
    --font = (string.match(mpd.album, "[\0-\x7F\xC2-\xF4][\x80-\xBF]") ~= nil) and 'Sazanami Mincho' or 'Source Code Pro',
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 1},
  },

  {
    text = (mpd.on == 'On' and mpd.album == '') and string.sub(mpd.dir, 1, 50) or '',
    x = 25,
    yc = 470,
    --font = (string.match(mpd.dir, "[\0-\x7F\xC2-\xF4][\x80-\xBF]") ~= nil) and 'Sazanami Mincho' or 'Source Code Pro',
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 1},
  },

  -- mpd title
  {
    text = (mpd.on == 'On') and string.sub(mpd.title, 1, 50) or 'Off',
    x = 25,
    yc = 485,
    --font = (string.match(mpd.title, "[\0-\x7F\xC2-\xF4][\x80-\xBF]") ~= nil) and 'Sazanami Mincho' or 'Source Code Pro',
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 1},
  },

  {
    text = (mpd.on == 'On' and mpd.title == '') and string.sub(mpd.fName, 1, 50) or '',
    x = 25,
    yc = 485,
    --font = (string.match(mpd.fName, "[\0-\x7F\xC2-\xF4][\x80-\xBF]") ~= nil) and 'Sazanami Mincho' or 'Source Code Pro',
    font = 'Source Code Pro',
    size = 10,
    color = {color.white, 1},
  },

  -- mpd status
  {
    --text = mpd.on == 'On' and (mpd.status == 'Playing' and '' or mpd.status == 'Paused' and '') or '',
    text = mpd.on == 'On' and mpd.status or '',
    x = 25,
    y = 815,
    --font = 'Font Awesome',
    font = 'Square Sans Serif 7',
    size = 16,
    color = mpd.on == 'On' and (mpd.status == 'Playing' and {color.curiousBlue, 1} or mpd.status == 'Paused' and {color.yellow, 1}) or {color.scarlet, 1},
  },

  --  repeat/random/all
  {
    --text = '',
    text = 'rpt',
    text = mpd.sgl == 'on' and 'sgl' or 'rpt',
    xr = 265,
    y = 815,
    --font = 'Font Awesome',
    font = 'Square Sans Serif 7',
    font = 'Source Code Pro',
    size = 12,
    color = (mpd.rpt == 'On' or mpd.sgl == 'on') and {color.curiousBlue, 1} or {color.white, 0.5},
  },

  {
    --text = '',
    text = 'rnd',
    xr = 295,
    y = 815,
    --font = 'Font Awesome',
    font = 'Square Sans Serif 7',
    font = 'Source Code Pro',
    size = 12,
    color = mpd.rnd == 'On' and {color.curiousBlue, 1} or {color.white, 0.5},
  },

  {
    --text = '',
    text = 'csm',
    xr = 325,
    y = 815,
    --font = 'Font Awesome',
    font = 'Square Sans Serif 7',
    font = 'Source Code Pro',
    size = 12,
    color = mpd.csm == 'on' and {color.curiousBlue, 1} or {color.white, 0.5},
  },

}

-- bars
bars = {

  -- mpd play progress
  {
    name = '',
    arg = (mpd.on == 'On' and (mpd.status == 'Playing' or mpd.status == 'Paused')) and mpd.percent or 0,
    max = 100,
    x = 100,
    y = 448,
    blocks = 1, 
    space = 4,
    height = 150,
    width = 4,
    angle = 90,
    ledEffect = 'r',
    alarm = 10,
    cap = 'r',
    bgColor = {color.white, 0.5},
    bgLed = {color.black, 0},
    fgColor = {color.curiousBlue, 1},
    fgLed = {color.white, 1},
    --midColor = {{0, coverColor, 1}, {0.2, color.white, 1}, {0.3, coverColor, 1}, {0.6, coverColor, 1}, {0.8, color.white, 1}, {1, coverColor, 1}},
    --fgLed = {color.scarlet, 1},
    --smooth = true,
  },

  -- volume
  {
    name = '',
    arg = (mpd.isVolOn == 'on') and (tonumber(mpd.volume) <= 100 and mpd.volume or 100) or 0,
    max = 100,
    x = 125,
    y = 810,
    blocks = 1, 
    space = 4,
    height = 100,
    width = 4,
    angle = 90,
    ledEffect = 'r',
    alarm = 10,
    cap = 'r',
    bgColor = {color.white, 0.5},
    bgLed = {color.black, 0},
    fgColor = (mpd.isVolOn == 'on') and (tonumber(mpd.volume) <= 100 and {color.roseGold, 1} or {color.scarlet, 1}) or {color.black, 1},
    fgLed = {color.white, 1},
  },
}
