script_name    		('Helper KerSoft v1.2')
script_properties	("work-in-pause")
script_author  		('Rice')
script_version		('1.1')


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
			VipTag = u8'Òýã',
			ColorTag = '{FF0000}'
	}
}, "Helper KerSoft")


-- Local --
		local window = imgui.ImBool(false)
		local settings = imgui.ImBool(false)
		local timer = imgui.ImBool(cfg.TimerVipChat.timer)
		local posX, posY = cfg.TimerVipChat.x, cfg.TimerVipChat.y

		local replaceAdd = imgui.ImBool(cfg.MessageHook.replaceAdd)
		local replaceVipTag = imgui.ImBool(cfg.MessageHook.replaceVipTag)
		local VipTag = imgui.ImBuffer(cfg.MessageHook.VipTag,256)
		local ColorTag = imgui.ImBuffer(cfg.MessageHook.ColorTag,256)

		local vremya = false
		local time = 0
		local time2 = 0

		local tag = '{289008}[Helper KerSoft] {FFFFFF}'
		local mc = 0x228B22

-- Function Main --
function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end

		imgui.Process = false

		if not doesFileExist('moonloader/config/Helper KerSoft.ini') then
			if inicfg.save(cfg, 'Helper KerSoft.ini') then sampAddChatMessage(tag..'Ñîçäàí ôàéë êîíôèãóðàöèè: Helper KerSoft.ini', mc)
		end end

		autoupdate("https://raw.githubusercontent.com/Xkelling/Helper-by-KS-for-Arizona/main/update.ini", '['..string.upper(thisScript().name)..'] ', 'https://www.blast.hk/threads/94823')

		_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		nick = sampGetPlayerNickname(id)

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
                sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion), mc)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Çàãðóæåíî %d èç %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')
                      sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Îáíîâëåíèå çàâåðøåíî! Ïåðåçàãðóæàþ ñêðèïò.'), mc)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage(('['..thisScript().name..'] {FFFFFF}Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..'), mc)
                        update = false
                      end
                    end
                  end
                )
		end, tag
              )
            else
              update = false
							sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Çàïóùåí! Àêòèâàöèÿ - /hk', mc)
              print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')
            end
          end
        else
          sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ïðîâåðüòå îáíîâëåíèå â òåìå íà BlastHack: '..url, mc)
					sampAddChatMessage('['..thisScript().name..'] {FFFFFF}Ññûëêà íà òåìó BlastHack ïðîäóáëèðîâàíà â êîíñîëè SF', mc)
					  print('v'..thisScript().version..': Ññûëêà íà òåìó BlastHack: '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end


function imgui.OnDrawFrame()

		if settings.v then
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("##settings", settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			imgui.CenterText(u8'Helper KerSoft')
			imgui.PushFont(fontsize25)
			imgui.SetCursorPos(imgui.ImVec2(382, 2))
			imgui.Text(fa.ICON_FA_TIMES_CIRCLE)
			imgui.PopFont()
			if imgui.IsItemClicked() then
				lua_thread.create(function()
				wait(75)
				settings.v = not settings.v
			end) end


			if timer.v == true then
				imgui.BeginChild("##ChildTimer", imgui.ImVec2(400, 75), true)
				else
				imgui.BeginChild("##ChildTimer", imgui.ImVec2(400, 50), true)
			end
			imgui.Text(fa.ICON_FA_COMMENTS.. u8' Òàéìåð ïîñëåäíåãî ñîîáùåíèÿ â /vr')
			if imadd.ToggleButton(u8'Âêëþ÷èòü##timer', timer) then
				cfg.TimerVipChat.timer = timer.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(u8(timer.v and 'Âêëþ÷åíî' or 'Âûêëþ÷åíî'))
			if timer.v == true then
				if imgui.Button(u8'Ìåñòîïîëîæåíèå', imgui.ImVec2(200, 20)) then
				lua_thread.create(function ()
						showCursor(true, true)
						checkCursor = true
						settings.v = false
						sampSetCursorMode(4)
					sampAddChatMessage(tag..'Íàæìèòå {289008}ÏÐÎÁÅË{FFFFFF} ÷òî-áû ñîõðàíèòü ïîçèöèþ', mc)
						while checkCursor do
								local cX, cY = getCursorPos()
								posX, posY = cX, cY
								if isKeyDown(32) then
									sampSetCursorMode(0)
									cfg.TimerVipChat.x, cfg.TimerVipChat.y = posX, posY
										settings.v = true
										checkCursor = false
										showCursor(false, false)
										if inicfg.save(cfg, 'Helper KerSoft.ini') then sampAddChatMessage(tag..'Ïîçèöèÿ ñîõðàíåíà!', mc) end
								end
								wait(0)
						end
				end)
				end
				imgui.Hint(u8'Ìåñòîïîëîæåíèå òàéìåðà (ìåñòîïîëîæåíèå ñîõðàíÿåòñÿ ïîñëå ïåðåçàõîäà)')
			end
			imgui.EndChild()


			imgui.BeginChild("##ChildHook", imgui.ImVec2(400, 50), true)
			imgui.Text(fa.ICON_FA_NEWSPAPER.. u8' Çàìåíà îáúÿâëåíèé â ÷àòå')
			imgui.SameLine()
			imgui.TextQuestion(u8'[Ïðèìåð]\n\nÂêëþ÷åíî:\nAD: Êóïëþ â/c "Ãîðíûé". Áþäæåò: Ñâîáîäíûé. Îòïðàâèë: Yuki_Rice[111] Òåë. 1234567\n\nÂûêëþ÷åíî:\nÎáúÿâëåíèå: Êóïëþ â/c "Ãîðíûé". Áþäæåò: Ñâîáîäíûé. Îòïðàâèë: Yuki_Rice[111] Òåë. 1234567\nÎòðåäàêòèðîâàë ñîòðóäíèê ÑÌÈ [ LS ] : Yuki_Rice[111]')
			if imadd.ToggleButton(u8'Âêëþ÷èòü##replaceAdd', replaceAdd) then
				cfg.MessageHook.replaceAdd = replaceAdd.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(u8(replaceAdd.v and 'Âêëþ÷åíî' or 'Âûêëþ÷åíî'))
			imgui.EndChild()


			if replaceVipTag.v == true then
				imgui.BeginChild("##ChildHook2", imgui.ImVec2(400, 120), true)
				else
				imgui.BeginChild("##ChildHook2", imgui.ImVec2(400, 50), true)
			end
			imgui.Text(fa.ICON_FA_COMMENT_DOTS.. u8' Ëè÷íûé òýã â /vr (âèçóàëüíî)')
			if imadd.ToggleButton(u8'Âêëþ÷èòü##replaceVipTag', replaceVipTag) then
				cfg.MessageHook.replaceVipTag = replaceVipTag.v
				inicfg.save(cfg, 'Helper KerSoft.ini')
			end
			imgui.SameLine()
			imgui.Text(u8(replaceVipTag.v and 'Âêëþ÷åíî' or 'Âûêëþ÷åíî'))
			if replaceVipTag.v == true then
				if imgui.InputText(fa.ICON_FA_PENCIL_ALT..u8' Ââåäèòå Âàø òýã', VipTag) then
					cfg.MessageHook.VipTag = VipTag.v
					inicfg.save(cfg, 'Helper KerSoft.ini')
			end end


			if replaceVipTag.v == true then
				if imgui.InputText(fa.ICON_FA_PAINT_ROLLER..u8' Öâåò òýãà', ColorTag) then
					cfg.MessageHook.ColorTag = ColorTag.v
					inicfg.save(cfg, 'Helper KerSoft.ini') end
				imgui.SameLine()
				imgui.TextQuestion(u8"Îáÿçàòåëüíî ââîäèòü öâåò â ôîðìàòå: {öâåò}\nÏðèìåð: {FFFFFF}")
			end

			if replaceVipTag.v == true then
				imgui.Link('https://colorscheme.ru/html-colors.html',fa.ICON_FA_INFO_CIRCLE..(u8' Îñíîâíûå HEX öâåòà ')..fa.ICON_FA_INFO_CIRCLE)
			end

			imgui.EndChild()

			imgui.End()
		end


		if window.v then
			imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always)
			imgui.Begin("##window", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)

			if vremya then
	        time = os.time() - time2
	    end

	    imgui.Text(u8"Òàéìåð: " ..time)

			imgui.End()
		end

end


function sampev.onServerMessage(color, text)
	if text:find('{F345FC}%[.+%] {FFFFFF}'..nick..'%[%d+%]: .+') then
		vremya = true
		time2 = os.time()
	end

	if replaceVipTag.v == true and text:find('{......}%[.+%] {......}'..nick..'%[%d+%]%: .+') then
		local id, message = text:match('{......}%[.+%] {......}'..nick..'(%[%d+%])%: (.+)')
		sampAddChatMessage(u8:decode(ColorTag.v..'['..VipTag.v..'] {FFFFFF}'..nick..id..': '..u8(message)), -1)
		return false
	end

	if replaceAdd.v == true and text:find('Îáúÿâëåíèå%: .+%. Îòïðàâèë%: .+%[%d+%] Òåë%. %d+') then
		local Add = text:match('Îáúÿâëåíèå%: (.+%. Îòïðàâèë%: .+%[%d+%] Òåë%. %d+)')
		sampAddChatMessage('{78b169}AD: '..Add, 0x78b169)
		return false
	end

	if replaceAdd.v == true and text:find('Îòðåäàêòèðîâàë ñîòðóäíèê ÑÌÈ %[ .+ %] %: .+%[%d+%]') and replaceAdd.v == true then
		return false
	end
end


function imgui.Hint(text, delay, action)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- ñêîðîñòü ïîÿâëåíèÿ
        if os.clock() >= go_hint then
		    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
		    imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
		        imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.PopupBg])
		            imgui.BeginTooltip()
		            imgui.PushTextWrapPos(450)
		            imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonActive], fa.ICON_FA_INFO_CIRCLE..u8' Ïîäñêàçêà:')
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


function imgui.TextQuestion(text)
	imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE)
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(600)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end


function calc(params)
    if params == '' then
        sampAddChatMessage(tag.. 'Èñïîëüçîâàíèå: /calc [ïðèìåð]', mc)
    else
        local func = load('return ' .. params)
        if func == nil then
            sampAddChatMessage(tag.. 'Îøèáêà.', mc)
        else
            local bool, res = pcall(func)
            if bool == false or type(res) ~= 'number' then
                sampAddChatMessage(tag.. 'Îøèáêà.', mc)

            else
                sampAddChatMessage(tag.. 'Ðåçóëüòàò: ' .. res, mc)
            end
        end
    end
end


function custom_color()
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

		colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.864, 0.864, 0.864, 1.000)
		colors[clr.WindowBg] = ImVec4(0.513, 0.513, 0.513, 0.901)
		colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg] = ImVec4(0.099, 0.099, 0.099, 0.999)
		colors[clr.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
		colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] = ImVec4(0.424, 0.424, 0.424, 1.000)
		colors[clr.FrameBgHovered] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.FrameBgActive] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.TitleBg] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.TitleBgCollapsed] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.TitleBgActive] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.MenuBarBg] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.ScrollbarBg] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.ScrollbarGrab] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.Separator] = ImVec4(1.000, 1.000, 1.000, 1.000)
		colors[clr.ComboBg] = ImVec4(0.15, 0.14, 0.15, 1.00)
		colors[clr.CheckMark] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.SliderGrab] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.SliderGrabActive] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.Button] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.ButtonHovered] = ImVec4(0.194, 0.775, 0.000, 1.000)
		colors[clr.ButtonActive] = ImVec4(0.182, 0.775, 0.000, 1.000)
		colors[clr.Header] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.HeaderHovered] = ImVec4(0.157, 0.565, 0.031, 1.000)
		colors[clr.HeaderActive] = ImVec4(0.235, 1.000, 0.000, 1.000)
		colors[clr.ResizeGrip] = ImVec4(1.00, 1.00, 1.00, 0.30)
		colors[clr.ResizeGripHovered] = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.ResizeGripActive] = ImVec4(1.00, 1.00, 1.00, 0.90)
		colors[clr.CloseButton] = ImVec4(1.00, 0.10, 0.24, 0.00)
		colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.10, 0.24, 0.00)
		colors[clr.CloseButtonActive] = ImVec4(1.00, 0.10, 0.24, 0.00)
		colors[clr.PlotLines] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PlotLinesHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PlotHistogram] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PlotHistogramHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.TextSelectedBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.00)
		end
custom_color()
