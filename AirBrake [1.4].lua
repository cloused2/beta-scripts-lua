---=== About script ===---

script_author('cloused2')
script_name('AirBrake V2')
script_version('1.2')
script_description('Added mimgui window and new settings for cheat')

---=== Библиотеки ===---

local requests = require 'requests'
local imgui = require 'mimgui'
local hotkey = require'mimhotkey'
local ffi = require 'ffi'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local IniFilename = 'AirBrakeSettings.ini'

-----===== Переменные =====----

local MOP = false
local zfix = nil
local scroll = 0

url = requests.get("https://raw.githubusercontent.com/cloused2/beta-scripts-lua/main/updater_airbrake-s0beit.json") -- Отправляем GET запрос к нашей таблице
a = decodeJson(url.text)

local new = imgui.new
local str = ffi.string
local renderWindow = new.bool(false)
hotkey.no_flood = false -- Отключаем защиту от флуда в Mimgui HotKeys

-----===== Настройки =====----
local settings = inicfg.load({
	main = {
		ClickSpeedOnFoot = 0.0100,
		ClickSpeedOnVeh = 0.0100,
		SpeedFoot = 0.50,
		SpeedCar = 1.50,
		enabled = false,
		scroll = false,
		mouse = true,
		hotkey = false
	},
	scroll = {
		ScrollSpeedOnFoot = 0.003,
		ScrollSpeedOnVeh = 0.003,
	},
	hotkeys = {
		speed_up = '[187]', -- Бинд клавиши
		speed_down = '[189]', -- Бинд клавиши
		activation = '[113]' -- Бинд клавиши
	}
}, IniFilename)

---=== Mimgui Переменные ===---

speedClickFoot = new.float(settings.main.ClickSpeedOnFoot)
speedClickVeh = new.float(settings.main.ClickSpeedOnVeh)
speedScrollFoot = new.float(settings.scroll.ScrollSpeedOnFoot)
speedScrollVeh = new.float(settings.scroll.ScrollSpeedOnVeh)
speedFoot = new.float(settings.main.SpeedFoot)
speedCar = new.float(settings.main.SpeedCar)
AirWork = new.bool(settings.main.enabled)
ScrollWork = new.bool(settings.main.scroll)
MouseWork = new.bool(settings.main.mouse)
HotKeyWork = new.bool(settings.main.hotkey)

---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
---////////////////////////////////////////////////////////////		Mimgui HotKeys Binds	 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local Binds = {
    SpeedUP = {
        desc = u8'Добавить скорость',
        keys = decodeJson(settings.hotkeys.speed_up),
        callback = function()
		if HotKeyWork[0] then
            if not sampIsCursorActive() then
				speedFoot[0] = speedFoot[0] + speedClickFoot[0]
				printStringNow("speed +"..("%.2f"):format(speedFoot[0]), 1000)
            end
        end
	end
    },
	SpeedDOWN = {
        desc = u8'Убавить скорость',
        keys = decodeJson(settings.hotkeys.speed_down),
        callback = function()
		if HotKeyWork[0] then
            if not sampIsCursorActive() then
				speedFoot[0] = speedFoot[0] - speedClickFoot[0]
				if speedFoot[0] < 0 then
					speedFoot[0] = 0
				end
				printStringNow("speed -"..("%.2f"):format(speedFoot[0]), 1000)
            end
        end
	end
    },
    Activation = {
        desc = u8'Активация',
        keys = decodeJson(settings.hotkeys.activation),
        callback = function()
		if AirWork[0] then
            if not sampIsCursorActive() then
				if isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then
					MOP_()
				elseif not isCharInAnyCar(PLAYER_PED) then
					MOP_()
				end
            end
        end
	end
    }
}

---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



---=== Mimgui Code ===---

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
	imgui.DarkTheme()
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 650, 470
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Настройки AirBrake | Version: ' .. thisScript().version, renderWindow, imgui.WindowFlags.NoResize)
			imgui.Text(u8'Настройки AirBrake')
			imgui.Separator()
				if imgui.Checkbox(u8'Включить', AirWork) then
					settings.main.enabled = AirWork[0] 
					inicfg.save(settings, IniFilename)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8'Переключение скорости колесиком мышки', ScrollWork) then
					settings.main.scroll = ScrollWork[0]
					inicfg.save(settings, IniFilename)
				end
				if imgui.Checkbox(u8'Переключение скорости кнопками мышки', MouseWork) then
					settings.main.mouse = MouseWork[0]
					inicfg.save(settings, IniFilename)
				end
				if imgui.Checkbox(u8'Переключение скорости хоткей кнопками', HotKeyWork) then
					settings.main.hotkey = HotKeyWork[0]
					inicfg.save(settings, IniFilename)
				end

				imgui.Separator()

				local Activation = hotkey.KeyEditor('activation_hk', u8'Активация') -- Хоткей активации
				if Activation then
					settings.hotkeys.activation = encodeJson(Activation)
					inicfg.save(settings, IniFilename)
				end	
																			
				local Speedup = hotkey.KeyEditor('speed_up_hk', u8'Увеличить скорость') -- Хоткей +
				if Speedup then
					settings.hotkeys.speed_up = encodeJson(Speedup)
					inicfg.save(settings, IniFilename)
				end		
																		
				imgui.SameLine()

				local Speeddown = hotkey.KeyEditor('speed_down_hk', u8'Уменьшить скорость') -- Хоткей -
				if Speeddown then
					settings.hotkeys.speed_down = encodeJson(Speeddown)
					inicfg.save(settings, IniFilename)
				end	
																				
				imgui.Text(u8'Настройки переключения скорости | Кнопки мышки')

				if imgui.SliderFloat(u8'Смена скорости OnFoot', speedClickFoot, 0, 0.0500) then
					settings.main.ClickSpeedOnFoot = speedClickFoot[0]
					inicfg.save(settings, IniFilename)
				end

				if imgui.SliderFloat(u8'Смена скорости Veh', speedClickVeh, 0, 0.0500) then
					settings.main.ClickSpeedOnVeh = speedClickVeh[0]
					inicfg.save(settings, IniFilename)
				end
				imgui.Separator()

				imgui.Text(u8'Настройки переключения скорости | Колесико мышки')

				if imgui.SliderFloat(u8'#Смена скорости OnFoot', speedScrollFoot, 0, 0.0500) then
					settings.scroll.ScrollSpeedOnFoot = speedScrollFoot[0]
					inicfg.save(settings, IniFilename)
				end

				if imgui.SliderFloat(u8'#Смена скорости Veh1', speedScrollVeh, 0, 0.0500) then
					settings.scroll.ScrollSpeedOnVeh = speedScrollVeh[0]
					inicfg.save(settings, IniFilename)
				end
				imgui.Separator()

				imgui.Text(u8'Настройки скорости')

				if imgui.SliderFloat(u8'Начальная скорость onFoot', speedFoot, 0, 25) then
					settings.main.SpeedFoot = speedFoot[0]
					inicfg.save(settings, IniFilename)
				end

				if imgui.SliderFloat(u8'Начальная скорость onVeh', speedCar, 0, 25) then
					settings.main.SpeedCar = speedCar[0]
					inicfg.save(settings, IniFilename)
				end

				imgui.TextWrapped(u8'Переключение скорости: ЛКМ - прибавить  |  ПКМ - убавить  |  Колесико мышки ')
        imgui.End()
    end)


---=== Main Code ===---

function MOP_()
	MOP = not MOP
	freezeCharPosition(PLAYER_PED, MOP)
	zfix = select(3, getCharCoordinates(PLAYER_PED))
	if not isCharInAnyCar(PLAYER_PED) then
		setCharCollision(PLAYER_PED, not MOP)
		local x, y, z = getCharCoordinates(PLAYER_PED)
		setCharCoordinates(PLAYER_PED, x, y, z - 1)
	end
end

function f(v)
	return v+tonumber("0.0000"..math.random(9))
end

function main()
	while not isSampAvailable() do wait(0) end

	if tostring(a["update"]) > thisScript().version then
        sampShowDialog(1234, "Обновление "..a["update"], "Обнаружено обновление "..a["update"].."!\nПерейдите в тему со скриптом на blast.hk\n\n"..u8:decode(a["news"]), "Понял")
    end

	sampRegisterChatCommand('airb', function ()
		renderWindow[0] = not renderWindow[0]
	end)

---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
---////////////////////////////////////////////////////////////	   Mimgui HotKeys CallBack	 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	hotkey.RegisterCallback('activation_hk', Binds.Activation.keys, Binds.Activation.callback) -- 
	hotkey.RegisterCallback('speed_up_hk', Binds.SpeedUP.keys, Binds.SpeedUP.callback) -- 
	hotkey.RegisterCallback('speed_down_hk', Binds.SpeedDOWN.keys, Binds.SpeedDOWN.callback) -- 
    hotkey.Text.wait_for_key = u8'Нажмите клавишу'
    hotkey.Text.no_key = u8'Нет'

---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	sampAddChatMessage('{FF8C00}[AirBrake] {FFFFFF}Успешно загружен! Активация: /airb', -1)
	sampAddChatMessage('{FF8C00}[AirBrake] {FFFFFF}Ваша версия скрипта: ' ..thisScript().version, -1)
	while true do wait(0)
		if wasKeyPressed(27) then
			renderWindow[0] = false
		end
		if AirWork[0] then
			if MOP then
				if isCharInAnyCar(playerPed) then
					car()
				else
					onfoot()
				end
				
				scroll = getMousewheelDelta()
			end
		end
	end
end

function car()
if AirWork[0] then
	repeat
		printString("~g~AirBrake: ON")
		freezeCarPosition = true

	if MouseWork[0] then
		if isKeyDown(1) then
			speedCar[0] = speedCar[0] + speedClickVeh[0]
			printStringNow(" speed +"..("%.2f"):format(speedCar[0]), 1000)
		elseif isKeyDown(2) then
			speedCar[0] = speedCar[0] - speedClickVeh[0]
			if speedCar[0] < 0 then
				speedCar[0] = 0
			end
			printStringNow(" speed -"..("%.2f"):format(speedCar[0]), 1000)
		end
	end
		
	if ScrollWork[0] then
		if scroll == 1 then
			speedCar[0] = speedCar[0] + settings.main.ClickSpeedOnVeh
			printStringNow("speed +"..("%.2f"):format(speedCar[0]), 1000)
		elseif scroll == -1 then
			speedCar[0] = speedCar[0] - settings.main.ClickSpeedOnVeh
			if speedCar[0] < 0 then
				speedCar[0] = 0
			end
			printStringNow("speed -"..("%.2f"):format(speedCar[0]), 1000)
		end
	end
		
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local x1, y1, z1 = getActiveCameraCoordinates()
		local head = math.rad(getHeadingFromVector2d(x-x1, y-y1))
		if isKeyDown(87) and not sampIsCursorActive() then
			x = x-math.sin(-head+3.14)*speedCar[0]
			y = y-math.cos(-head+3.14)*speedCar[0]
		elseif isKeyDown(83) and not sampIsCursorActive() then
			x = x+math.sin(-head+3.14)*speedCar[0]
			y = y+math.cos(-head+3.14)*speedCar[0]
		end
		if isKeyDown(65) and not sampIsCursorActive() then
			x = x-math.sin(-head+1.57)*speedCar[0]
			y = y-math.cos(-head+1.57)*speedCar[0]
		elseif isKeyDown(68) and not sampIsCursorActive() then
			x = x+math.sin(-head+1.57)*speedCar[0]
			y = y+math.cos(-head+1.57)*speedCar[0]
		end
		if isKeyDown(0xA0) and not sampIsCursorActive() then
			zfix = zfix-math.log(speedCar[0]+1)*0.75
		elseif isKeyDown(32) and not sampIsCursorActive() then
			zfix = zfix+math.log(speedCar[0]+1)*0.75
		end
		local sync = samp_create_sync_data("vehicle")
		sync.position = {f(x),f(y),f(z)}
		sync.moveSpeed = {f(0),f(0),f(0)}
		local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
		if x ~= x2 or y ~= y2 or z ~= z2 then
			sync.moveSpeed = {f(0.05),f(0.05),f(0.05)}
		end
		sync.send()
		setCarHeading(getCarCharIsUsing(PLAYER_PED), getHeadingFromVector2d(select(1, getActiveCameraPointAt()) - select(1, getActiveCameraCoordinates()), select(2, getActiveCameraPointAt()) - select(2, getActiveCameraCoordinates())))
		setCharCoordinates(PLAYER_PED, x, y, zfix)
	until MOP
end
end

function onfoot()
if AirWork[0] then
    repeat
		printString("~g~AirBrake: ON")

	if MouseWork[0] then
		if isKeyDown(1) and isCurrentCharWeapon(PLAYER_PED, 0) then
			speedFoot[0] = speedFoot[0] + speedClickFoot[0]
			printStringNow("speed +"..("%.2f"):format(speedFoot[0]), 1000)
		elseif isKeyDown(2) and isCurrentCharWeapon(PLAYER_PED, 0) then
			speedFoot[0] = speedFoot[0] - speedClickFoot[0]
			if speedFoot[0] < 0 then
				speedFoot[0] = 0
			end
			printStringNow("speed -"..("%.2f"):format(speedFoot[0]), 1000)
		end
	end

	if ScrollWork[0] then

		if scroll == 1 then
			speedFoot[0] = speedFoot[0] + settings.main.ClickSpeedOnFoot
			printStringNow("speed +"..("%.2f"):format(speedFoot[0]), 1000)
		elseif scroll == -1 then
			speedFoot[0] = speedFoot[0] - settings.main.ClickSpeedOnFoot
			if speedFoot[0] < 0 then
				speedFoot[0] = 0
			end
			printStringNow("speed -"..("%.2f"):format(speedFoot[0]), 1000)
		end
	end
		
		local x, y, z = getCharCoordinates(playerPed)
		local x1, y1, z1 = getActiveCameraCoordinates()
		local head = math.rad(getHeadingFromVector2d(x-x1, y-y1))
		if isKeyDown(87) and not sampIsCursorActive() then
			x = x-math.sin(-head+3.14)*speedFoot[0]
			y = y-math.cos(-head+3.14)*speedFoot[0]
		elseif isKeyDown(83) and not sampIsCursorActive() then
			x = x+math.sin(-head+3.14)*speedFoot[0]
			y = y+math.cos(-head+3.14)*speedFoot[0]
		end
		if isKeyDown(65) and not sampIsCursorActive() then
			x = x-math.sin(-head+1.57)*speedFoot[0]
			y = y-math.cos(-head+1.57)*speedFoot[0]
		elseif isKeyDown(68) and not sampIsCursorActive() then
			x = x+math.sin(-head+1.57)*speedFoot[0]
			y = y+math.cos(-head+1.57)*speedFoot[0]
		end
		if isKeyDown(0xA0) and not sampIsCursorActive() then
			z = z-speedFoot[0]/2.2
		elseif isKeyDown(32) and not sampIsCursorActive() then
			z = z+speedFoot[0]/2.2
		end
		local sync = samp_create_sync_data("player")
		sync.position = {f(x),f(y),f(z)}
		sync.moveSpeed = {f(0),f(0),f(0)}
		local x2,y2,z2 = getCharCoordinates(playerPed)
		if x ~= x2 or y ~= y2 or z ~= z2 then
			sync.moveSpeed = {f(0.09),f(0.091),f(0.071)}
		end
		sync.send()
		setCharHeading(playerPed, math.deg(head))
		setCharCoordinatesDontResetAnim(playerPed, x, y, z)
	until MOP
end
end

addEventHandler('onWindowMessage', function(msg, wparam, lparam)
if AirWork[0] then
    if MOP and (wparam == 16 or wparam == 32) and isKeyCheckAvailable() then
        consumeWindowMessage(true, false)
    end
end
end)

function isKeyCheckAvailable()
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() and not sampIsScoreboardOpen()
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
if AirWork[0] then
  if doesCharExist(char) then
    local ptr = getCharPointer(char)
    setEntityCoordinates(ptr, x, y, z)
  end
end
end

function setEntityCoordinates(entityPtr, x, y, z)
if AirWork[0] then
  if entityPtr ~= 0 then
    local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
    if matrixPtr ~= 0 then
      local posPtr = matrixPtr + 0x30
      writeMemory(posPtr + 0, 4, representFloatAsInt(x), false)
      writeMemory(posPtr + 4, 4, representFloatAsInt(y), false)
      writeMemory(posPtr + 8, 4, representFloatAsInt(z), false)
    end
  end
end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        settings.hotkeys.activation = encodeJson(Activation)
		settings.hotkeys.speed_down = encodeJson(Speeddown)
		settings.hotkeys.speed_up = encodeJson(Speedup)
    end
end

---=== Темная Тема Mimgui ===---

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(10, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 0
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 10
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
	imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end