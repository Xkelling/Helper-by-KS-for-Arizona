script_name('AU')
script_version('1.1')

local tag = '{FF0000}[AU] {FFFFFF}'
local mc = 0xFF0000

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end

sampAddChatMessage(tag..'AUTO-UPDATE', mc)
autoupdate("https://raw.githubusercontent.com/Xkelling/Admin-Scripts/main/upate.ini", '['..string.upper(thisScript().name)..'] ', 'https://www.blast.hk/threads/94823')
sampRegisterChatCommand('cmd', function()
sampAddChatMessage(tag..'Версия: '..thisScript().version, mc)
end)

	while true do
	wait(0)

	end
end

function autoupdate(json_url, tag, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(tag)
                local dlstatus = require('moonloader').download_status
                sampAddChatMessage((tag..'{FFFFFF}Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), mc)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((tag..'{FFFFFF}Обновление завершено! Перезагружаю скрипт.'), mc)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((tag..'{FFFFFF}Обновление прошло неудачно. Запускаю устаревшую версию..'), mc)
                        update = false
                      end
                    end
                  end
                )
		end, tag
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          sampAddChatMessage(tag..'{FFFFFF}Не могу проверить обновление. Проверьте обновление в теме на BlastHack: '..url, mc)
					sampAddChatMessage(tag..'{FFFFFF}Ссылка на тему BlastHack продублирована в консоли SF', mc)
					  print('v'..thisScript().version..': Ссылка на тему BlastHack: '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
