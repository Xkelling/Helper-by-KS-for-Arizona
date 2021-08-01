script_name    		('Helper KerSoft')
script_properties	("work-in-pause")
script_author  		('Rice')
script_version		('1.2')


-- Lib --
               require "lib.moonloader"
local sampev = require 'lib.samp.events'
local  imgui = require 'imgui'
local  imadd = require 'imgui_addons'
local     fa = require 'fAwesome5'
local inicfg = require 'inicfg'


-- U8 --
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8


-- fAwesome5 --
local fa_font = nil
local fontsize25 = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, font_config, fa_glyph_ranges)
    end
    if fontsize25 == nil then
        fontsize25 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 25.0, font_config, fa_glyph_ranges)
    end
end


-- Ini CFG --
local cfg = inicfg.load({
	TimerVipChat = {
			x = 0,
			y = 0,
			timer = false
	},
	MessageHook = {
			replaceAdd = false,
			replaceVipTag = false,
			VipTag = u8'Тэг',
			ColorTag = '{FF0000}'
	},
	CasinoAndBar = {
		casino = false,
		bar = false
	},
	AutoUpdate = {
		enable = false
	},
	Style = {
		theme = 0
	}
}, "Helper KerSoft")


		local window = imgui.ImBool(false)
		local settings = imgui.ImBool(false)
		local timer = imgui.ImBool(cfg.TimerVipChat.timer)
		local posX, posY = cfg.TimerVipChat.x, cfg.TimerVipChat.y

		local replaceAdd = imgui.ImBool(cfg.MessageHook.replaceAdd)
		local replaceVipTag = imgui.ImBool(cfg.MessageHook.replaceVipTag)
		local VipTag = imgui.ImBuffer(cfg.MessageHook.VipTag,256)
		local ColorTag = imgui.ImBuffer(cfg.MessageHook.ColorTag,256)

		local casino = imgui.ImBool(cfg.CasinoAndBar.casino)
		local bar = imgui.ImBool(cfg.CasinoAndBar.bar)

		local Aupdate = imgui.ImBool(cfg.AutoUpdate.enable)

		local theme = imgui.ImInt(cfg.Style.theme)

		local tema = {
			u8'Синяя тема',
			u8'Красная тема',
			u8'Коричневая тема',
			u8'Голубая тема',
			u8'Салатовая тема',
			u8'Фиолетовая тема',
			u8'Тёмная тема',
			u8'Тёмно-Красная тема',
			u8'Тёмно-Зелёная тема'
		}

		local menu = 1

		local vremya = false
		local time = 0
		local time2 = 0

		local tag = '{228B22}[Helper KerSoft] {FFFFFF}'
		local mc = 0x228B22


function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end

		imgui.Process = false

		sampAddChatMessage(tag..'Запущен! Активация - /hk', mc)

		if not doesFileExist('moonloader/config/Helper KerSoft.ini') then
			if inicfg.save(cfg, 'Helper KerSoft.ini') then sampAddChatMessage(tag..'Создан файл конфигурации: Helper KerSoft.ini', mc)
		end end

	if Aupdate.v then
		autoupdate("https://raw.githubusercontent.com/Xkelling/Helper-by-KS-for-Arizona/main/update.ini", '['..string.upper(thisScript().name)..'] ', 'https://www.blast.hk/threads/94823')
	end

		sampRegisterChatCommand('calc', calc)

		sampRegisterChatCommand('hk', function()
			settings.v = not settings.v
		end)

	while true do
	wait(0)

				if settings.v then
						imgui.ShowCursor = true
						imgui.Process = true
				elseif window.v then
						imgui.ShowCursor = false
						imgui.Process = true
				else
						imgui.Process = false
				end

			if timer.v == true then
				window.v = true
			else
				window.v = false
			end

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
                sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), mc)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Обновление завершено! Перезагружаю скрипт.'), mc)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Обновление прошло неудачно. Запускаю устаревшую версию..'), mc)
                        update = false
                      end
                    end
                  end
                )
		end, tag
              )
            else
              update = false
              sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Обновление не требуется! Актуальная версия: '..thisScript().version, mc)
            end
          end
        else
          sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Не могу проверить обновление. Проверьте обновление в теме на BlastHack: '..url, mc)
					sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Ссылка на тему BlastHack продублирована в консоли SF', mc)
					  print('v'..thisScript().version..': Ссылка на тему BlastHack: '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end


function imgui.OnDrawFrame()

	if cfg.Style.theme == 0 then theme0() end
	if cfg.Style.theme == 1 then theme1() end
	if cfg.Style.theme == 2 then theme2() end
	if cfg.Style.theme == 3 then theme3() end
	if cfg.Style.theme == 4 then theme4() end
	if cfg.Style.theme == 5 then theme5() end
	if cfg.Style.theme == 6 then theme6() end
	if cfg.Style.theme == 7 then theme7() end
	if cfg.Style.theme == 8 then theme8() end

		if settings.v then
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("##settings", settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			imgui.CenterText(u8'Helper KerSoft')
			imgui.PushFont(fontsize25)
			imgui.SetCursorPos(imgui.ImVec2(490, 2))
			imgui.Text(fa.ICON_FA_TIMES_CIRCLE)
			imgui.PopFont()
			if imgui.IsItemClicked() then
				lua_thread.create(function()
				wait(75)
				settings.v = not settings.v
			end) end

			imgui.BeginChild('left', imgui.ImVec2(100, 47), true)
			if imgui.Selectable(fa.ICON_FA_USER..u8" Основное  ", menu == 1) then menu = 1 end
			if imgui.Selectable(fa.ICON_FA_COG..u8" Настройки ", menu == 2) then menu = 2 end
			imgui.EndChild()

			imgui.SameLine()

			if menu == 1 then

			imgui.BeginGroup()

			if timer.v == true then
				imgui.BeginChild("##ChildTimer", imgui.ImVec2(400, 75), true)
				else
				imgui.BeginChild("##ChildTimer", imgui.ImVec2(400, 50), true)
			end
			imgui.Text(fa.ICON_FA_COMMENTS.. u8' Таймер последнего сообщения в /vr')
			imgui.SameLine()
			imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
			imgui.Hint(u8'В окне будет показываться кол-во секунд после последнего сообщения в Вип-Чат')
			if imadd.ToggleButton(u8'Включить##timer', timer) then
				cfg.TimerVipChat.timer = timer.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(u8(timer.v and 'Включено' or 'Выключено'))
			if timer.v == true then
				if imgui.Button(u8'Местоположение', imgui.ImVec2(200, 20)) then
				lua_thread.create(function ()
						showCursor(true, true)
						checkCursor = true
						settings.v = false
						sampSetCursorMode(4)
					sampAddChatMessage(tag..'Нажмите {289008}ПРОБЕЛ{FFFFFF} что-бы сохранить позицию', mc)
						while checkCursor do
								local cX, cY = getCursorPos()
								posX, posY = cX, cY
								if isKeyDown(32) then
									sampSetCursorMode(0)
									cfg.TimerVipChat.x, cfg.TimerVipChat.y = posX, posY
										settings.v = true
										checkCursor = false
										showCursor(false, false)
										if inicfg.save(cfg, 'Helper KerSoft.ini') then sampAddChatMessage(tag..'Позиция сохранена!', mc) end
								end
								wait(0)
						end
				end)
				end
				imgui.Hint(u8'Местоположение таймера (местоположение сохраняется после перезахода)')
			end
			imgui.EndChild()


			imgui.BeginChild("##ChildHook", imgui.ImVec2(400, 50), true)
			imgui.Text(fa.ICON_FA_NEWSPAPER.. u8' Замена объявлений в чате')
			imgui.SameLine()
			imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
			imgui.Hint(u8'[Пример]\n\nВключено:\nAD: Куплю в/c "Горный". Бюджет: Свободный. Отправил: Yuki_Rice[111] Тел. 1234567\n\nВыключено:\nОбъявление: Куплю в/c "Горный". Бюджет: Свободный. Отправил: Yuki_Rice[111] Тел. 1234567\nОтредактировал сотрудник СМИ [ LS ] : Yuki_Rice[111]')
			if imadd.ToggleButton(u8'Включить##replaceAdd', replaceAdd) then
				cfg.MessageHook.replaceAdd = replaceAdd.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(u8(replaceAdd.v and 'Включено' or 'Выключено'))
			imgui.EndChild()


		if replaceVipTag.v == true then
			imgui.BeginChild("##ChildHook2", imgui.ImVec2(400, 120), true)
		else
			imgui.BeginChild("##ChildHook2", imgui.ImVec2(400, 50), true)
		end
			imgui.Text(fa.ICON_FA_COMMENT_DOTS.. u8' Личный тэг в /vr')
			imgui.SameLine()
			imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
			imgui.Hint(u8'[Пример]\n\nВключено:\n[Ловец] Yuki_Rice[111]: Текст\n\nВыключено:\n[PREMIUM] Yuki_Rice[111]: Текст')
		if imadd.ToggleButton(u8'Включить##replaceVipTag', replaceVipTag) then
			cfg.MessageHook.replaceVipTag = replaceVipTag.v
			inicfg.save(cfg, 'Helper KerSoft.ini')
		end
			imgui.SameLine()
			imgui.Text(u8(replaceVipTag.v and 'Включено' or 'Выключено'))
		if replaceVipTag.v == true then
			if imgui.InputText(fa.ICON_FA_PENCIL_ALT..u8' Введите Ваш тэг', VipTag) then
				cfg.MessageHook.VipTag = VipTag.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
		end end

		if replaceVipTag.v == true then
			if imgui.InputText(fa.ICON_FA_PAINT_ROLLER..u8' Цвет тэга', ColorTag) then
				cfg.MessageHook.ColorTag = ColorTag.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
			imgui.Hint(u8"Обязательно вводить цвет в формате: {цвет}\nПример: {FFFFFF}")
		end

		if replaceVipTag.v == true then
			imgui.Link('https://colorscheme.ru/html-colors.html',fa.ICON_FA_INFO_CIRCLE..(u8' Основные HEX цвета ')..fa.ICON_FA_INFO_CIRCLE)
		end
	imgui.EndChild()


	imgui.BeginChild("##CasinoAndBar", imgui.ImVec2(400, 90), true)

		imgui.Text(fa.ICON_FA_CUBES..u8' Анти-Казино')

		imgui.SameLine()

		imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)

		imgui.Hint(u8'- Скрипт не будет позволять отправить команду /dice или /yes\n- Скрипт не будет позволять открыть диалог с покупкой фишек')

		if imadd.ToggleButton(u8'Включить##casino', casino) then
			cfg.CasinoAndBar.casino = casino.v
			inicfg.save(cfg, 'Helper KerSoft.ini')
		end
		imgui.SameLine()
		imgui.Text(u8(casino.v and 'Включено' or 'Выключено'))

		imgui.Text(fa.ICON_FA_DOLLAR_SIGN..u8' Анти-Бар')

		imgui.SameLine()

		imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)

		imgui.Hint(u8'- Скрипт не будет позволять отправить команду /orel или /reshka\n- Скрипт не будет позволять принять ставку в баре')

		if imadd.ToggleButton(u8'Включить##bar', bar) then
			cfg.CasinoAndBar.bar = bar.v
			inicfg.save(cfg, 'Helper KerSoft.ini')
		end
		imgui.SameLine()
		imgui.Text(u8(bar.v and 'Включено' or 'Выключено'))

	imgui.EndChild()

	imgui.EndGroup()

	end

	if menu == 2 then

	imgui.BeginGroup()

	imgui.BeginChild("##AutoUpdate", imgui.ImVec2(400, 75), true)

		imgui.Text(fa.ICON_FA_CLOUD_UPLOAD_ALT..u8' Авто-Обновление')

		imgui.SameLine()

		imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)

		imgui.Hint(u8'Если функция включено, то при загрузке скрипта будет проверяться обновление')

		if imadd.ToggleButton(u8'##AutoUpdate', Aupdate) then
			cfg.AutoUpdate.enable = Aupdate.v
			inicfg.save(cfg, 'Helper KerSoft.ini')
		end

		imgui.SameLine()

		imgui.Text(u8(Aupdate.v and 'Включено' or 'Выключено'))

		if imgui.Button(u8'Проверить обновление') then
			lua_thread.create(function()
				autoupdate("https://raw.githubusercontent.com/Xkelling/Helper-by-KS-for-Arizona/main/update.ini", '['..string.upper(thisScript().name)..'] ', 'https://www.blast.hk/threads/94823')
			end)
		end

	imgui.EndChild()


	imgui.BeginChild("##Theme", imgui.ImVec2(400, 50), true)

	imgui.Text(fa.ICON_FA_ADJUST..u8' Темы скрипта')

		if imgui.Combo(u8'##Temi', theme, tema, -1)then
			cfg.Style.theme = theme.v
			inicfg.save(cfg, 'Helper KerSoft.ini')
		end

	imgui.EndChild()
	imgui.EndGroup()
	end


			imgui.End()
		end


		if window.v then
			imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always)
			imgui.Begin("##window", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if vremya then
        time = os.time() - time2
	    end
	    imgui.Text(u8"Таймер: " ..time)
			imgui.End()
		end
end


function sampev.onServerMessage(color, text)
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	if text:find('{......}%[.+%] {......}'..nick..'%[%d+%]: .+') then
		vremya = true
		time2 = os.time()
	end

	if replaceVipTag.v == true and text:find('{......}%[.+%] {......}'..nick..'%[%d+%]%: .+') then
		local id, message = text:match('{......}%[.+%] {......}'..nick..'(%[%d+%])%: (.+)')
		sampAddChatMessage(u8:decode(ColorTag.v..'['..VipTag.v..'] {FFFFFF}'..nick..id..': '..u8(message)), -1)
		return false
	end

	if replaceAdd.v == true and text:find('Объявление%: .+%. Отправил%: .+%[%d+%] Тел%. %d+') then
		local Add = text:match('Объявление%: (.+%. Отправил%: .+%[%d+%] Тел%. %d+)')
		sampAddChatMessage('{78b169}AD: '..Add, 0x78b169)
		return false
	end

	if replaceAdd.v == true and text:find('Отредактировал сотрудник СМИ %[ .+ %] %: .+%[%d+%]') and replaceAdd.v == true then
		return false
	end
end


function sampev.onShowDialog(dialogId, style, title, button1, button2, text)

	if dialogId == 1465 and bar.v then
		sampAddChatMessage(tag..'Диалог от бара заблокирован, потому-что включена функция "Анти-Бар".', mc)
		return false
	end

	if dialogId == 8001 and text:find('Введите количество') and casino.v then
		sampAddChatMessage(tag..'Диалог с покупкой фишек был заблокирован, потому-что включена функция "Анти-Казино".', mc)
		return false
	end
end


function sampev.onSendCommand(command)
    if command:find("/orel") and bar.v or command:find("/reshka") and bar.v then
	    sampAddChatMessage(tag..'Команды "/orel" и "/reshka" заблокированы, потому-что Вы включили функцию "Анти-Бар".', mc)
			return false
    end

		if command:find("/yes") and casino.v  or command:find("/dice") and casino.v then
			sampAddChatMessage(tag..'Команды "/dice" и "/yes" заблокированы, потому-что Вы включили функцию "Анти-Казино".', mc)
			return false
		end
end


function imgui.Hint(text, delay, action)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then
		    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
		    imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
		        imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.PopupBg])
		            imgui.BeginTooltip()
		            imgui.PushTextWrapPos(700)
		            imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonActive], fa.ICON_FA_INFO_CIRCLE..u8' Подсказка:')
		            imgui.TextUnformatted(text)
		            if action ~= nil then
		            	imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.TextDisabled], '\n'..fa.ICON_FA_SHARE..' '..action)
		            end
		            if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
		            imgui.PopTextWrapPos()
		            imgui.EndTooltip()
		        imgui.PopStyleColor()
		    imgui.PopStyleVar(2)
		end
    end
end


function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.Link(link,name,myfunc)
				myfunc = type(name) == 'boolean' and name or myfunc or false
				name = type(name) == 'string' and name or type(name) == 'boolean' and link or link
				local size = imgui.CalcTextSize(name)
				local p = imgui.GetCursorScreenPos()
				local p2 = imgui.GetCursorPos()
				local resultBtn = imgui.InvisibleButton('##'..link..name, size)
				if resultBtn then
						if not myfunc then
								os.execute('explorer '..link)
						end
				end
				imgui.SetCursorPos(p2)
				if imgui.IsItemHovered() then
						imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonActive], name)
						imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]))
				else
						imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Text], name)
				end
				return resultBtn
end


function calc(params)
    if params == '' then
        sampAddChatMessage(tag.. 'Использование: /calc [пример]', mc)
    else
        local func = load('return ' .. params)
        if func == nil then
            sampAddChatMessage(tag.. 'Ошибка.', mc)
        else
            local bool, res = pcall(func)
            if bool == false or type(res) ~= 'number' then
                sampAddChatMessage(tag.. 'Ошибка.', mc)

            else
                sampAddChatMessage(tag.. 'Результат: ' .. res, mc)
            end
        end
    end
end


function theme0()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end


function theme1()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		 colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
		 colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
		 colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
		 colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		 colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
		 colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		 colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
		 colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
		 colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
		 colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
		 colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
		 colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
		 colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
		 colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
		 colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
		 colors[clr.Separator]              = colors[clr.Border]
		 colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
		 colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
		 colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
		 colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
		 colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
		 colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
		 colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		 colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		 colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		 colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		 colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		 colors[clr.ComboBg]                = colors[clr.PopupBg]
		 colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
		 colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		 colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		 colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		 colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		 colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		 colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		 colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		 colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		 colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		 colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		 colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		 colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		 colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		 colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end


function theme2()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end


function theme3()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end


function theme4()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.FrameBg]                = ImVec4(0.42, 0.48, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.77, 0.88, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.82, 0.98, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.85, 0.98, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.85, 0.98, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.63, 0.75, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.63, 0.75, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.85, 0.98, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.85, 0.98, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.85, 0.98, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end



function theme5()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

	colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
	colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
	colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
	colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
	colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
	colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
	colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
	colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
	colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
	colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
	colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
	colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
	colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
	colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
	colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
	colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
	colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
	colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
	colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
	colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
	colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end


function theme6()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end


function theme7()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowPadding = imgui.ImVec2(8, 8)
		style.WindowRounding = 6
		style.ChildWindowRounding = 5
		style.FramePadding = imgui.ImVec2(5, 3)
		style.FrameRounding = 3.0
		style.ItemSpacing = imgui.ImVec2(5, 4)
		style.ItemInnerSpacing = imgui.ImVec2(4, 4)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 8
		style.GrabRounding = 1
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

		colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
	end


	function theme8()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4

			style.WindowPadding = imgui.ImVec2(8, 8)
			style.WindowRounding = 6
			style.ChildWindowRounding = 5
			style.FramePadding = imgui.ImVec2(5, 3)
			style.FrameRounding = 3.0
			style.ItemSpacing = imgui.ImVec2(5, 4)
			style.ItemInnerSpacing = imgui.ImVec2(4, 4)
			style.IndentSpacing = 21
			style.ScrollbarSize = 10.0
			style.ScrollbarRounding = 13
			style.GrabMinSize = 8
			style.GrabRounding = 1
			style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
			style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

			colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
	    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
	    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
	    colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
	    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
	    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
	    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
	    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
	    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
	    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
	    colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
	    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
	    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
	    colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
	    colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
	    colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
	    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
	    colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
	    colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
	    colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
	    colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
	    colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
	    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
	    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
	    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
	    colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
	    colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
	    colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
	    colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
	    colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
	    colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
	    colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
	    colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
	    colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
	    colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
		end
