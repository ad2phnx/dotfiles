-- conky.bak (Main) Lua Config v0.1
-- a.dinis (c) 2019

require 'cairo'
--require 'imlib2'

-- setup parsers
local xml2lua = require('xml2lua')
local xmltree = require('xmlhandler.tree')
local cURL = require('cURL')
local json = require('json')

-- static functions + vars that should keep persitant data
dofile '.config/conky.bak/lua/funcs.lua'
dofile '.config/conky.bak/lua/staticVars.lua'
dofile '.apiKeys.lua'
weather = {}
forecast = {}
moon = {}
weatherIcons = {}
file = ""
wLastUp = 0
sun = {secOSet = 0, secRise = 0}
sysUpdates = 0
-- Wanikani
wanikani = {
  linkBase = "https://api.wanikani.com/v2/",
  linkSummary = "summary",
  linkReviewStats = "review_statistics?percentages_less_than=70",
  linkUser = "user",
  linkReviewsAvail = "assignments?immediately_available_for_review",
  linkSubjects = "subjects",
  headers = {
    "Authorization: Bearer " .. WKAPIToken,
    "Wanikani-Revision: 20170710",
    "Content-Type: application/json",
  },
  lastModified = "",
  userLastModified = "",
  revStatLastModified = "",
  reviewsNow = 0,
  reviews24H = 0,
  reviews = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}},
  lessons = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}},
  idsSubjectLessThan = {},
  infoSubjectLessThan = {},
  randomSubject = {},
  lessonsNow = 0,
  nextAvailAt = "",
  userLevel = 0,
}
-- show cpu info
function do_cpu(cr, updates)

  if updates == 1 then

    dofile '.config/conky.bak/lua/graphs.lua'
    
    local flagOk = 0
    for i in pairs(graphs) do
      if graphs[i].width == nil then graphs[i].width = 100 end
      if graphs[i].nbValues == nil then
        graphs[i].nbValues = graphs[i].width
      end
      graphs[i]['values'] = {}
      graphs[i].beg = graphs[i].nbValues
      for j = 1, graphs[i].nbValues do
        graphs[i].values[j] = 0
      end
      graphs[i].flagInit = true
      flagOk = flagOk + checkGraphSettings(graphs[i])
    end
  end

  if flagOk ~= nil and flagOk > 0 then
    print('Error: check graphs table')
    return
  end

  if updates > 5 then

    -- vars
    dofile '.config/conky.bak/lua/mainVars.lua'

    -- every 1 min check wanikani
    -- if updates == 6 or updates % 10 == 0 then
    --   --if getWKReviews(cURL, json, wanikani) then
    --     -- do something useful here
    --   --else
    --     --wanikani.reviews = -1
    --   --end
    --   if getWKSummary(cURL, json, wanikani) then
    --     --print("new data")
    --   else
    --     -- Old data
    --   end
    --
    --   if getWKUser(cURL, json, wanikani) then
    --     --print("WKLevel: " .. wanikani.userLevel)
    --   else
    --   end
    --
    --   if getWKReviewStats(cURL, json, wanikani) then
    --       --print("Got reviews stats... " .. table.concat(wanikani.idsSubjectLessThan,","))
    --       wanikani.linkSubjects = "subjects?ids=" .. table.concat(wanikani.idsSubjectLessThan,",")
    --       getWKSubjectsLessThan(cURL, json, wanikani)
    --   else
    --   end
    -- end
    -- background
    draw_background(cr, background)

    -- lines
    for i in pairs(lines) do
      --draw_line(cr, lines[i])
    end

    -- boxes
    for i in pairs(boxes) do
      draw_box(cr, boxes[i])
    end

    -- rings
    for i in pairs(rings) do
      draw_ring(cr, rings[i])
    end

    -- texts
    for i in pairs(texts) do
      draw_text(cr, texts[i])
    end

    --local startYc = baseWKSubject.yc
    --local currLvl = 1
    --local currItem = 1
    --local i = 1
    --if wanikani.infoSubjectLessThan[1] ~= nil and (updates == 6 or updates % 60 == 0) then
    --    randomSubject = wanikani.infoSubjectLessThan[math.random(#wanikani.infoSubjectLessThan)]
    --end
    --if randomSubject['type'] == 'radical' then
    --    baseWKSubject.color = {color.curiousBlue, 1.0}
    --elseif randomSubject['type'] == 'kanji' then
    --    baseWKSubject.color = {color.roseGold, 1.0}
    --elseif randomSubject['type'] == 'vocabulary' then
    --    baseWKSubject.color = {color.gentooPurpleLight2, 1.0}
    --end
    --baseWKSubject.text = randomSubject['characters'] ~= nil and randomSubject['characters'] or ''
    --draw_text(cr, baseWKSubject)
    --baseWKSubject.text = randomSubject['reading'] ~= nil and randomSubject['reading'] or ''
    --baseWKSubject.size = 16
    --baseWKSubject.xc = nil
    --baseWKSubject.x = cCenter.x - 550
    --baseWKSubject.yc = cCenter.y + 45
    --draw_text(cr, baseWKSubject)
    --baseWKSubject.text = randomSubject['meaning'] ~= nil and randomSubject['meaning'] .. ' (L.' .. randomSubject['level'] .. ')' or ''
    --baseWKSubject.x = nil
    --baseWKSubject.xr = cCenter.x - 250
    --baseWKSubject.size = 14
    --baseWKSubject.font = 'Source Code Pro'
    --draw_text(cr, baseWKSubject)
    --    while currItem <= 25 do
    --        local v = wanikani.infoSubjectLessThan[currItem]
    --        if currLvl ~= v['level'] then
    --            baseWKSubject.text = '[' .. v['level'] .. ']'
    --            baseWKSubject.color = {color.white, 1.0}
    --            baseWKSubject.size = 10
    --            currLvl = v['level']
    --        else
    --            if v['type'] == 'kanji' then
    --                baseWKSubject.color = {color.roseGold, 1.0}
    --            elseif v['type'] == 'radical' then
    --                baseWKSubject.color = {color.curiousBlue, 1.0}
    --            elseif v['type'] == 'vocabulary' then
    --                baseWKSubject.color = {color.gentooPurple, 1.0}
    --            end
    --            baseWKSubject.text = v['characters']
    --            baseWKSubject.size = 14
    --            currItem = currItem + 1
    --        end
    --        baseWKSubject.yc = startYc + ((i-1) * 20)
    --        draw_text(cr, baseWKSubject)
    --        i = i + 1
    --    end
    --end


    -- bars
    for i in pairs(bars) do
      draw_bar(cr, bars[i])
    end

    -- processes
    local yOff = baseTop.y
    local xOff = baseTop.x
    for i = 0, 10 do
      -- get tops procs
      local typeN = 0
      for j, v in pairs(baseOrdProc) do
        if i > 0 then
          topProc[baseOrdProc[j]] = conky_parse('${top ' .. baseOrdProc[j] .. ' ' .. i .. '}')
          baseTop.text = topProc[baseOrdProc[j]]
          baseTop.size = 10
          baseTop.face = CAIRO_FONT_WEIGHT_NORMAL
          if baseOrdProc[j] == 'user' and topProc[baseOrdProc[j]] == os.getenv("USER") then
            baseTop.color = {color.curiousBlue, 1}
          else
            baseTop.color = {color.white, 0.75}
          end
        else
          baseTop.text = baseOrdProc[j] 
          baseTop.face = CAIRO_FONT_WEIGHT_BOLD
          baseTop.size = 12
        end
        baseTop.x = xOff + (typeN * 50)
        baseTop.y = yOff + (i * 15)
        draw_text(cr, baseTop)
        baseTop.text = ''
        typeN = typeN + 1
      end
      --baseTop.text = topProc['name']
    end

    -- graphs
    if graphs ~= nil then
      for i in pairs(graphs) do

        if graphs[i].drawMe == true then graphs[i].drawMe = nil end
        if (graphs[i].drawMe == nil or conky_parse(tostring(graphs[i].drawMe)) == '1') then
          local nbValues = graphs[i].nbValues
          graphs[i].automax = 0
          for j = 1, nbValues do
            if graphs[i].values[j+1] == nil then
              graphs[i].values[j + 1] = 0
            end

            graphs[i].values[j] = graphs[i].values[j + 1]
            if j == nbValues then
              if graphs[i].name == '' then
                value = graphs[i].arg
              else
                value = tonumber(conky_parse('${' .. graphs[i].name .. ' ' .. graphs[i].arg .. '}'))
              end
              graphs[i].values[nbValues] = value
            end
            graphs[i].automax = math.max(graphs[i].automax, graphs[i].values[j])
            if graphs[i].automaxx == 0 then graphs[i].automax = 1 end
          end
          draw_graph(cr, graphs[i])
        end
      end
    end
  end
end -- end do_cpu

-- calendar wheel
function do_cal_wheel(updates)

  -- if image exists draw it
  local actDate = os.date("%Y%m%d")
  local actCal = imlib_load_image(imgCal)

  if updates > 5 then

    -- vars
    dofile '.config/conky.bak/lua/calendarVars.lua'

    if lastDate ~= actDate or actCal == nil then
      draw_cal_wheel(calWheel)
      lastDate = actDate
    end

    if actCal == nil then
      actCal = imlib_load_image(imgCal)
    end

    imlib_context_set_image(actCal)
    imlib_render_image_on_drawable(0, 0)
    imlib_free_image()
  end
end


function do_calendar(cr, updates)

  if updates > 5 then

    -- vars
    dofile '.config/conky.bak/lua/calendarVars.lua'

    -- draw calendar
    draw_calendar(cr, calendar)
    --draw_calendar(cr, minCal)
  end
end

function do_music(cr, updates)

  if updates > 5 then

    -- testing

    file = get_con('mpc -f %file% | head -n 1')
    dofile '.config/conky.bak/lua/musicVars.lua'
    dofile '.config/conky.bak/lua/coverVars.lua'

    if playChange then
      run_cmd('rm -f "' .. coverArt .. '.jpg"')
      run_cmd('rm -f "' .. coverArt .. '.jpeg"')
      run_cmd('rm -f "' .. coverArt .. '.png"')
      coverColor = color.white
      --sleep(1)
      if mpd.status ~= 'Stopped' then
        if file and check_file(os.getenv("HOME") .. '/Music/' .. file) then
          os.execute('eyeD3 -l error ' .. os.getenv("HOME") .. '/Music/"' .. file .. '" --write-images ' .. os.getenv("HOME") .. '/.config/conky.bak/covers/ &> /dev/null')
          if check_file(coverArt .. '.jpeg') then
            os.execute('convert ' .. coverArt .. '.jpeg ' .. coverArt .. '.png')
          end
          if check_file(coverArt .. '.jpg') then
            os.execute('convert ' .. coverArt .. '.jpg ' .. coverArt .. '.png')
          end
          if check_file(coverArt .. '.png') then
            coverColor = '0x' .. get_con('convert "$HOME/.config/conky.bak/covers/FRONT_COVER.png" -resize 1x1\\! -format "%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]" info:- | awk -F \'[(,)]\' \'{printf("#%x%x%x\\n",$1,$2,$3)}\' | sed "s/#//"')
            --run_cmd('getCoverColor.py')
            coverCompliment = getCompliment(coverColor)
          end
        end
      end
    end

    -- draw boxes
    for i in pairs(boxes) do
      draw_box(cr, boxes[i])
    end

    -- draw images
    for i in pairs(images) do
      put_image(cr, images[i])
    end

    -- put ratings
    local rating = 0
    for i = 0, 4 do
      if (tonumber(mpd.rating) ~= 0) and (tonumber(mpd.rating) >= (i * 64 - 1)) then
        rating = rating + 1
      end
    end
    baseRating.text = string.rep('★', rating) .. string.rep('☆', 5 - rating)
    draw_text(cr, baseRating)

    -- texts
    for i in pairs(texts) do
      draw_text(cr, texts[i])
    end

    -- bars
    for i in pairs(bars) do
      draw_bar(cr, bars[i])
    end

  end
end

function do_clock(cr, updates)

  if updates > 5 then

    dofile '.config/conky.bak/lua/clockVars.lua'

    -- get weeks for each month
    --get_con('~/.bin/weeks.py')

    -- draw boxes
    for i in pairs(boxes) do
      draw_box(cr, boxes[i])
    end

    -- draw text
    for i in pairs(texts) do
      draw_text(cr, texts[i])
    end

    -- draw rings
    for i in pairs(rings) do
      draw_ring(cr, rings[i])
    end

    -- draw weeks rings and 24 hour clock
    for i=0,24 do

      -- setup weeks of year
      if i > 0  and i < 13 then
        weekRing.gapSectors = 1
        weekRing.inverseArc = false
        weekRing.fillSector = true
        weekRing.allSectors = true
        weekRing.background = false
        weekRing.foreground = true
        if i < tonumber(time.month) then
          weekRing.borderSize = 1
          --weekRing.fgColor1 = {{0, color.black, 0}, {0.3, monthColor[i], i/time.month}, {0.5, color.white, 1}, {0.7, monthColor[i], i/time.month}, {1, color.black, 0}}
          weekRing.fgColor1 = {{0, color.black, 0}, {0.3, color.silver, 0.1}, {0.5, color.white, 0.5}, {0.7, color.silver, 0.1}, {1, color.black, 0}}
          weekRing.bdColor1 = {{0, color.black, 0}, {0.5, color.black, 0.5}, {1, color.black, 0}}
        elseif i == tonumber(time.month) then
          weekRing.borderSize = 1
          weekRing.bdColor1 = {{0, color.black, 0}, {0.3, monthCompliment[i], 0.75}, {0.5, color.white, 1}, {0.7, monthCompliment[i], 0.75}, {1, color.black, 0}}
          weekRing.fgColor1 = {{0, color.black, 0}, {0.3, monthColor[i], 1}, {0.5, color.white, 1}, {0.7, monthColor[i], 1}, {1, color.black, 0}}
        else
          weekRing.borderSize = 0
        end
        draw_ring(cr, build_weeks_ring(i, weekRing))
      else
        draw_ring(cr, weekRing)
      end

      -- setup 24 hour clock
      local hour = i % 12
      local hRad = 135
      local hrX, hrXd = round(hRad * math.cos(i * 15 * deg2rad + deg90rad))
      local hrY, hrYd = round(hRad * math.sin(i * 15 * deg2rad + deg90rad))
      hourText.text = (hour == 0 and i < 13) and 12 or hour
      hourText.xc = cCenter.x + hrX - 400
      hourText.yc = cCenter.y - cHeight / 4 + hrY
      hourText.font = 'Square Sans Serif 7'
      hourText.size = (tonumber(time.twofour) == i) and 20 or 12
      hourText.color = (tonumber(time.twofour) == i) and  {weekdayColor[time.weekday], 0.75} or {color.white, 0.75}

      local wkRad = 90
      local wkX, wkXd = round(wkRad * math.cos(((tonumber(time.twofour) + i) % 24) * 15 * deg2rad + deg90rad))
      local wkY, wkYd = round(wkRad * math.sin(((tonumber(time.twofour) + i) % 24) * 15 * deg2rad + deg90rad))
      wkReviews.text = #wanikani.reviews[i+1] > 0 and #wanikani.reviews[i+1] or ''
      wkReviews.xc = cCenter.x + wkX - 400
      wkReviews.yc = cCenter.y - cHeight / 4 + wkY
      --wkReviews.font = 'Square Sans Serif 7'
      wkReviews.font = 'Japan'
      if i > 0 then
        if 24 - time.twofour > i then
            wkReviews.color = {color.roseGold, 1 - (i * .03)}
        else
            wkReviews.color = {color.gentooPurpleLight2, 1 - ((i - (24-time.twofour) + 1) * .03)}
        end
        draw_text(cr, hourText)
        draw_text(cr, wkReviews)
      end

      -- setup wanikani info
      --if i > 0 and i < 6 then
      --  local hr = time.hours

        --print(#wanikani.reviews[i+1])
        --wkRevRing.thickness = (-1) * (#wanikani.reviews[i+1])
        --local thck = #wanikani.reviews[i+1]
        --wkRevRing.arg = thck
        --wkRevRing.thickness = thck
        --print('Set thickness of ' .. i .. ' to: ' .. wkRevRing.thickness)
        --wkRevRing.thickness = (i * 2)
        --wkRevRing.startAngle = ((hr + i) * 15) - 93
        --wkRevRing.endAngle =  ((hr + i) * 15) - 85
        --draw_ring(cr, wkRevRing)
      --end
    end
  end
end

function do_new_weather(cr, updates)

    if updates > 5 then

        -- vars
        dofile '.config/conky.bak/lua/newWeatherVars.lua'

        -- every 15 minutes get weather info
        if (weather == nil or (updates > wLastUp + 60)) or updates == 6 or updates % 900 == 0 then
            --print('updating weather: updates', updates)

            -- get current weather
            --print("Getting weather...", updates, wLastUp)
            local curlCall = 'curl -s -H "Cache-Control: no-cache" "api.openweathermap.org/data/2.5/weather?id=' .. sWeather.id .. '&units=' .. sWeather.units .. '&lang=' .. sWeather.lang ..  '&APPID=' .. OWMAPIKEY .. '"'
            local curFile = assert(io.popen(curlCall))
            local curRFile = assert(curFile:read('*a'))
            curFile:close()
            weather = json.decode(curRFile)
            if weather ~= nil and weather['weather'] ~= nil and check_file(os.getenv("HOME") .. '/.config/conky.bak/weather/' .. weather['weather'][1]['icon'] .. '@2x.png') then
                --print('File exists: ' .. weather['weather'][1]['icon'] .. '@2x.png')
            elseif weather ~= nil and weather['weather'] ~= nil then 
                run_cmd('wget -nc http://openweathermap.org/img/wn/' .. weather['weather'][1]['icon'] .. '@2x.png -O ' .. os.getenv("HOME") .. '/.config/conky.bak/weather/' .. weather['weather'][1]['icon'] .. '@2x.png')
            end

            if weather ~= nil and weather['weather'] ~= nil then
                sunAmount(weather['sys']['sunrise'],  weather['sys']['sunset'], sun)
            end

            -- get weather forecast
            curlCall = 'curl -s -H "Cache-Control: no-cache" "api.openweathermap.org/data/2.5/forecast?id=' .. sWeather.id .. '&units=' .. sWeather.units .. '&lang=' .. sWeather.lang ..  '&APPID=' .. OWMAPIKEY .. '"'
            curFile = assert(io.popen(curlCall))
            curRFile = assert(curFile:read('*a'))
            curFile:close()
            forecast = json.decode(curRFile)

            -- download forecast images
            if (forecast ~= nil and forecast['list'] ~= nil) then
                for fIdx = 1, 40 do
                    if check_file(os.getenv("HOME") .. '/.config/conky.bak/weather/' .. forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x.png') then
                        --print('File exists: ' .. forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x.png')
                    else
                        run_cmd('wget -nc http://openweathermap.org/img/wn/' .. forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x.png -O ' .. os.getenv("HOME") .. '/.config/conky.bak/weather/' .. forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x.png')
                    end
                end
            end

            -- update moon info
            local moonFile = assert(io.popen('curl -s "https://moonphases.co.uk/service/getMoonDetails.php?day=' .. time.day .. '^&month=' .. time.month .. '^&year=' .. time.year .. '^&lat=' .. weather['coord']['lat'] .. '^&lng=' .. weather['coord']['lon'] .. '^&len=6' .. '^&tz=' .. 'jst' .. '" --compressed'))
            local rMoonFile = assert(moonFile:read('*a'))
            moonFile:close()
            local moonJson = json.decode(rMoonFile)
            moon.degree = -tonumber(moonJson.moonsign_deg)
            moon.icon = moonJson.days[1].phase_img
            moon.phase = moonJson.days[1].phase_name

            -- save last weather update "time"
            wLastUp = updates
        end


        -- draw images
        for i in pairs(images) do
            put_image(cr, images[i])
        end

        -- draw forecast
        for dIdx = 0, 6 do
            local space = 43
            local yOff = cCenter.y + 50
            local xOff = ((cCenter.x - 400 - 130) + (space * ((dIdx + time.weekday - 1) % 7)))
            local lx0, ly0 = xOff, cCenter.y - cHeight / 4 - 190
            local lx1, ly1, bly1 = xOff, cCenter.y + cHeight / 4 + 190, cCenter.y - cHeight / 4 + 190

            -- weekday lines
            baseLine.x, baseLine.y = lx0, ly0
            baseLine.tox, baseLine.toy = lx1, bly1
            baseLine.color = {weekdayColor[((dIdx + time.weekday - 1) % 7 + 1)], dIdx == 0 and 0.25 or 0.1}

            if (dIdx == 0) then
                baseLine.y = baseLine.y - 10
                baseLine.toy = baseLine.toy + 2
            end
            draw_line(cr, baseLine)


            baseLine.y, baseLine.toy = cCenter.y + cHeight / 4 - 200, cCenter.y + cHeight / 4 + 200
            if (dIdx == 0) then
                baseLine.y = baseLine.y - 2
                baseLine.toy = baseLine.toy + 10
            end
            draw_line(cr, baseLine)


            -- fcast morning images
            local fIdx = math.ceil(((24 * dIdx) - time.twofour + 9) / 3)
            yOff = 50
            fcastImg.x = xOff
            fcastImg.y = cCenter.y - cHeight / 4 - 190
            fcastImg.file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and (forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x') or 'NA') .. '.png'
            local lx0, ly0 = fcastImg.x, fcastImg.y

            -- morning forecast
            fcastText.xc = fcastImg.x
            fcastText.yc = fcastImg.y + 32
            fcastText.font = 'Kochi Mincho'
            --fcastText.font = 'Sazanami Mincho'
            fcastText.text = (fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and forecast['list'][fIdx]['weather'][1]['description'] or ''
            if (fIdx > 0 and fIdx <= 40 and dIdx < 6) then
                put_image(cr, fcastImg)
                draw_text(cr, fcastText)
                -- morning temperature
                fcastText.yc = fcastImg.y + 20
                --fcastText.font = 'Japan'
                fcastText.font = 'Square Sans Serif 7'
                fcastText.text = (fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and round(forecast['list'][fIdx]['main']['temp']) .. '°C' or ''
                draw_text(cr, fcastText)
            end

            -- morning precipitation

            -- fcast night images
            fIdx = math.ceil(((24 * dIdx) - time.twofour + 21) / 3)
            fcastImg.y = fcastImg.y + 380
            fcastImg.file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and (forecast['list'][fIdx]['weather'][1]['icon'] .. '@2x') or 'NA') .. '.png'
            local lx1, ly1 = fcastImg.x, cCenter.y + cHeight / 4 + 190

            -- night precipitation
            -- forecast low

            -- night forecast
            fcastText.xc = fcastImg.x
            fcastText.yc = fcastImg.y - 32
            fcastText.font = 'Kochi Mincho'
            --fcastText.font = 'Sazanami Mincho'
            fcastText.text = (fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and forecast['list'][fIdx]['weather'][1]['description'] or ''
            if (fIdx > 0 and fIdx <= 40 and dIdx < 6) then
                put_image(cr, fcastImg)
                draw_text(cr, fcastText)
                -- night temperature
                fcastText.yc = fcastImg.y - 20
                --fcastText.font = 'Japan'
                fcastText.font = 'Square Sans Serif 7'
                fcastText.text = (fIdx > 0 and fIdx <= 40 and forecast ~= nil and forecast['list'] ~= nil) and round(forecast['list'][fIdx]['main']['temp']) .. '°C' or ''
                draw_text(cr, fcastText)
            end
        end

        -- draw boxes
        for i in pairs(boxes) do
            draw_box(cr, boxes[i])
        end

        -- draw rings
        for i in pairs(rings) do
            draw_ring(cr, rings[i])
        end

        -- draw pies
        for i in pairs(pies) do
            draw_pie(cr, pies[i])
        end

        -- draw text
        for i in pairs(texts) do
            draw_text(cr, texts[i])
        end
    end
end

function do_weather(cr, updates)

  if updates > 5 then

    -- vars
    dofile '.config/conky.bak/lua/weatherVars.lua'

    -- every 15 minutes get weather info
    if (weather ~= nil and weather.cc == nil and (updates > wLastUp + 60)) or updates == 6 or updates % 900 == 0 then

      -- get weather info
      local file = assert(io.popen('curl -s -H "Cache-Control: no-cache" "wxdata.weather.com/wxdata/weather/local/' .. sWeather.loc .. '?cc=*&unit=' .. sWeather.unit .. '&dayf=' .. sWeather.dayf .. '"'))
      local rFile = assert(file:read('*a'))
      file:close()
      local handler = xmltree:new()
      local parser = xml2lua.parser(handler)
      parser:parse(rFile)

      -- update weather info
      weather = deepcopy(handler.root.weather)
      --weather.locImg = string.gsub(weather.cc.obst, "(%a+),.*", "%1")
      --weather.locImg = "Syracuse"

      -- upate sunlight amount
      sunAmount(weather.loc.sunr, weather.loc.suns, sun)

      -- update moon info
      local moonFile = assert(io.popen('curl -s "https://moonphases.co.uk/service/getMoonDetails.php?day=' .. time.day .. '^&month=' .. time.month .. '^&year=' .. time.year .. '^&lat=' .. weather.loc.lat .. '^&lng=' .. weather.loc.lon .. '^&len=6' .. '^&tz=' .. weather.loc.zone .. '" --compressed'))
      local rMoonFile = assert(moonFile:read('*a'))
      moonFile:close()
      weather.moonDeg = -tonumber(json.decode(rMoonFile).moonsign_deg)

      -- save last weather update "time"
      wLastUp = updates

    end

    -- draw images
    for i in pairs(images) do
      put_image(cr, images[i])
    end

    ---- draw forecast kanji
    draw_text(cr, fcastKanji)

    -- draw forecast images
    for dIdx = 1, 6 do
      local space = 43
      local yOff = cCenter.y + 50
      local xOff = ((cCenter.x - 400 - 130) + (space * ((dIdx + time.weekday - 1) % 7)))

      -- fcast morning images
      yOff = 50
      fcastImg.x = xOff 
      fcastImg.y = cCenter.y - cHeight / 4 - 190
      fcastImg.file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((weather ~= nil and weather.dayf ~= nil) and weather.dayf.day[dIdx+1].part[1].icon or 'NA') .. '.png'
      put_image(cr, fcastImg)
      local lx0, ly0 = fcastImg.x, fcastImg.y

      -- morning forecast
      --fcastText.xc = fcastImg.x
      --fcastText.yc = fcastImg.y + 32
      --fcastText.text = (weather.dayf ~= nil) and weather.dayf.day[dIdx + 1].part[1].bt or 'testing'
      --draw_text(cr, fcastText)

      -- fcast hi
      fcastText.xc = fcastImg.x
      fcastText.yc = fcastImg.y - 25 
      fcastText.text = (weather ~= nil and weather.dayf ~= nil) and 'H' .. weather.dayf.day[dIdx + 1].hi .. '°' or 'tst'
      draw_text(cr, fcastText)

      -- morning precipitation
      fcastText.xc = fcastImg.x
      fcastText.yc = fcastImg.y + 25 
      fcastText.text = (weather ~= nil and weather.dayf ~= nil) and weather.dayf.day[dIdx + 1].part[1].ppcp .. '% ' or 'tst'
      draw_text(cr, fcastText)


      -- fcast night images
      fcastImg.y = fcastImg.y + 380
      fcastImg.file = os.getenv("HOME") .. '/.config/conky.bak/weather/' .. ((weather ~= nil and weather.dayf ~= nil) and weather.dayf.day[dIdx+1].part[2].icon or 'NA') .. '.png'
      put_image(cr, fcastImg)
      local lx1, ly1 = fcastImg.x, cCenter.y + cHeight / 4 + 190

      -- night forecast
      --fcastText.yc = fcastText.yc + yOff * 2
      --fcastText.text = (weather.dayf ~= nil) and weather.dayf.day[dIdx + 1].part[2].bt or 'testing'
      --draw_text(cr, fcastText)

      -- night precipitation
      fcastText.yc = fcastImg.y - 20
      fcastText.text = (weather ~= nil and weather.dayf ~= nil) and weather.dayf.day[dIdx + 1].part[2].ppcp .. '% ' or 'tst'
      draw_text(cr, fcastText)

      -- fcast low
      fcastText.yc = fcastImg.y + 25 
      fcastText.text = (weather ~= nil and weather.dayf ~= nil) and 'L' .. weather.dayf.day[dIdx + 1].low .. '°' or 'tst'
      draw_text(cr, fcastText)

      --local xOff = (cCenter.x - 200 + (350/7 * ((dIdx + time.weekday - 1) % 7 + 1)))
      baseLine.x, baseLine.y = lx0, ly0
      ly1 = cCenter.y - cHeight / 4 + 190
      baseLine.tox, baseLine.toy = lx1, ly1
      baseLine.color = {weekdayColor[((dIdx + time.weekday - 1) % 7 + 1)], 0.1}
      draw_line(cr, baseLine)
      baseLine.y, baseLine.toy = cCenter.y + cHeight / 4 - 200, cCenter.y + cHeight / 4 + 200 
      draw_line(cr, baseLine)
    end

    -- draw boxes
    for i in pairs(boxes) do
      draw_box(cr, boxes[i])
    end

    -- draw rings
    for i in pairs(rings) do
      draw_ring(cr, rings[i])
    end

    -- draw pies
    for i in pairs(pies) do
      draw_pie(cr, pies[i])
    end

    -- draw text
    for i in pairs(texts) do
      draw_text(cr, texts[i])
    end

  end
end

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

  -- common vars
  dofile '.config/conky.bak/lua/vars.lua'
  dofile '.config/conky.bak/lua/monthWeeks.lua'

  -- get arch updates every 15 minutes
  if updates == 6 or updates % 900 == 0 then
    --sysUpdates = get_con("checkupdates | wc -l")
    sysUpdates = sysUpdates ~= nil and sysUpdates or 0
  end

  do_cpu(cr, updates)
  --do_weather(cr, updates)
  --do_new_weather(cr, updates)
  do_calendar(cr, updates)
  --do_music(cr, updates)
  do_clock(cr, updates)

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
