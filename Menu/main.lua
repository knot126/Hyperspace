MODE_TRAINING = 0
MODE_CLASSIC = 1
MODE_EXPERT = 2
MODE_ZEN = 3
MODE_VERSUS = 4
MODE_COOP = 5
MODE_COUNT = 6

HOSTNAME = "192.168.1.243:5000"
NO_API = false

waiting = false
waitingReason = ""
loadingFrame = 0
targetLevel = nil
listRequestType = "featured"

waitMgr = {
	start = function (self, reason)
		waiting = true
		waitingReason = reason
	end,
	stop = function (self)
		waiting = false
		waitingReason = ""
	end,
	isWaiting = function (self)
		return waiting
	end
}

errorPopup = {
	showing = false,
	message = "",
	show = function (self, message)
		knLog(LOG_ERROR, "Error Message: " .. message)
		self.showing = true
		self.message = message
	end,
	hide = function (self)
		self.showing = false
	end,
	isShowing = function (self)
		return self.showing
	end,
	draw = function (self)
		if self.showing then
			mgFullScreenColor(0, 0, 0, 0.3)
			mgDraw(errorUi)
		end
	end
}

function startsWith(str,start)
   return string.sub(str,1,string.len(start))==start
end

function getFirst(str)
	i = string.find(str, " ")
	if i > 0 then
		return string.sub(str, 1, i-1)
	end
	return ""
end

function getSecond(str)
	i = string.find(str, " ")
	if i > 0 then
		i = i + 1
		return string.sub(str, i, string.len(str))
	end
	return ""
end

function initGlobals()
	top = tonumber(mgGet("display.visibleTop"))
	left = tonumber(mgGet("display.visibleLeft"))
	right = tonumber(mgGet("display.visibleRight"))
	bottom = tonumber(mgGet("display.visibleBottom"))
	centerX = (left+right)*0.5
	centerY = (top+bottom)*0.5
	uiScale = tonumber(mgGet("game.uiscale"))
	screenWidth = right - left
	screenHeight = bottom - top
end

splashes = {
	"Woo!",
	"Where are we dropping today, kids?",
	"I'm cool, I hope",
	"Uses tmpfile()!",
	"Uses Leafhook!",
	"Uses Leaf!"
}

function init2()
	initGlobals()
	
	clientIcon = mgCreateImage("Hyperspace.png")
	mgSetScale(clientIcon, 0.14, 0.14)
	mgSetOrigo(clientIcon, "center")
	mgSetPos(clientIcon, centerX, top + 215)
	
	splashText = mgCreateText("lexend")
	mgSetText(splashText, "asdf")
	mgSetScale(splashText, 0.09, 0.09)
	mgSetOrigo(splashText, "center")
	mgSetPos(splashText, centerX-3, top+270)
	
	loadingDots = {}
	for i=1,8 do
		loadingDots[i] = mgCreateImage("loadingdot.png")
		mgSetOrigo(loadingDots[i], "center")
		mgSetScale(loadingDots[i], 0.1, 0.1)
		mgSetPos(loadingDots[i], centerX+(i-4.5)*8, top+250.75)
		mgSetAlpha(loadingDots[i], 0.1)
	end
	
	loadingFrame = 0
end

function init()
	local status, msg = pcall(init2)
	
	if not status then
		knLog(LOG_ERROR, msg)
		os.exit()
	end
end

function load()
	bgImage = mgCreateImage("Background.png")
	mgSetScale(bgImage, screenWidth/1280, screenHeight/720)
	mgSetPos(bgImage, left, top)
	
	back = mgCreateUi("back.xml")
	mgSetScale(back, .75, .75)
	mgSetPos(back, left + 25, top)
	
	optionsButton = mgCreateUi("optionsbutton.xml")
	mgSetOrigo(optionsButton, "center")
	mgSetScale(optionsButton, .75, .75)
	mgSetPos(optionsButton, centerX, bottom-95)
	
	optionsCanvas = mgCreateCanvas(1,1)
	mgSetPos(optionsCanvas, centerX, centerY)
	mgSetScale(optionsCanvas, .5, .5)
	mgSetAlpha(optionsCanvas, 0)
	
	optionsUi = mgCreateUi("options.xml")
	mgSetOrigo(optionsUi, "center")
	mgSetPos(optionsUi, 0, 0)
	
	optionsGfx = mgCreateImage("toggle_graphics.png")
	mgSetPos(optionsGfx, 0, 15)
	
	optionsSnd = mgCreateImage("toggle_sound.png")
	
	waitImg = mgCreateImage("Wait.png")
	mgSetScale(waitImg, 0.75, 0.75)
	mgSetOrigo(waitImg, "center")
	mgSetPos(waitImg, centerX, centerY)
	waitAngle = 0
	
	waitText = mgCreateText("lexend")
	mgSetScale(waitText, 0.75, 0.75)
	mgSetPos(waitText, centerX, centerY + 192)
	
	levelListUi = mgCreateUi("levellistui.xml")
	mgSetOrigo(levelListUi, "center")
	mgSetScale(levelListUi, 0.75, 0.75)
	mgSetPos(levelListUi, centerX, centerY)
	
	levelText = mgCreateText("lexend")
	mgSetColor(levelText, 1, 1, 1)
	mgSetScale(levelText, 0.75, 0.75)
	mgSetPos(levelText, centerX, centerY)
	
	errorUi = mgCreateUi("error.xml")
	mgSetOrigo(errorUi, "center")
	mgSetScale(errorUi, 1.5, 1.5)
	mgSetPos(errorUi, centerX, centerY)
	
	pushMainMenu()
	startLevelListRequest()
end

function firstDraw()
	knInclude("common/request.lua")
end

function drawLoading()
	initGlobals()
	
	local f = tonumber(mgGet("game.frame"))
	local a = 1.0-(f-30)/60
	if a < 0 then a = 0 end
	if a > 1 then a = 1 end
	
	mgSetAlpha(clientIcon, a)
	mgDraw(clientIcon)
	
	mgSetAlpha(splashText, a)
	mgDraw(splashText)
	
	for i=1, 8 do
		if loadingFrame==20+i*10 then 
			mgSetAlpha(loadingDots[i], 1)
		end
		
		local la = mgGetAlpha(loadingDots[i])
		mgSetAlpha(loadingDots[i], la * a)
		mgDraw(loadingDots[i])
		mgSetAlpha(loadingDots[i], la)
	end
	
	if loadingFrame < 8 then
		mgFullScreenColor(0,0,0,1.0-loadingFrame/8.0)
	end
	
	loadingFrame = loadingFrame + 1
	
	if loadingFrame == 110 then
		mgCommand("audio.playBackgroundMusic music/menu.ogg")
	end
end

function frame()
	if mgGet("game.loaded")=="0" then
		for i=1, 8 do
			if loadingFrame==i*10 then 
				mgCommand("game.load")
			end
		end
		return
	end
end

function process()
-- 	updateLevelRequest()
-- 	updateLevelListRequest()
end

function drawWorld2()
	if mgGet("game.loaded")=="0" then
		drawLoading()
		if loadingFrame == 1 then
			firstDraw()
		end
		return
	end
	
	if httpRequestDispatcher ~= nil then
		httpRequestDispatcher:update()
	end
	
	mgDraw(bgImage)
	
	pcall(process)
	
	t = mgGet("game.menutransition")
	t = (t-0.5)*2
	if t < 0 then t = 0 end
	
	local t = menu:getType()
	local state = menu:getState()
	
	if t == "levellist" then
		mgDraw(levelListUi)
		
		mgSetPos(levelText, centerX - 50, top + 90)
		mgSetText(levelText, tostring(state.title))
		mgSetOrigo(levelText, "center")
		mgDraw(levelText)
		
		mgSetPos(levelText, centerX - 50, bottom - 90)
		mgSetText(levelText, tostring(state.offset) .. " of " .. tostring(#state.list))
		mgSetOrigo(levelText, "center")
		mgDraw(levelText)
		
		local textX = centerX - 450
		local textY = centerY - 330
		for i = 1, 3 do
			if #state.list < state.offset + i then
				break
			end
			
			local info = state.list[state.offset + i]
			
			if info == nil then
				break
			end
			
			mgSetPos(levelText, textX, textY)
			mgSetText(levelText, info.name)
			mgSetOrigo(levelText, "topleft")
			mgDraw(levelText)
			
			mgSetPos(levelText, textX, textY+80)
			mgSetText(levelText, "by " .. info.creator)
			mgSetOrigo(levelText, "topleft")
			mgDraw(levelText)
			
			textY = textY + 240
		end
	elseif t == "options" then
		mgSetAlpha(optionsButton, 1)
		mgDraw(optionsButton)
		
		local optAlpha = mgGetAlpha(optionsCanvas)
		if optAlpha > 0 then
			mgFullScreenColor(0,0,0,optAlpha*0.5)
			mgPushCanvas(optionsCanvas)
			mgDraw(optionsUi)
			local gfx = mgGet("game.graphics")
			if gfx == "low" then
				mgSetCrop(optionsGfx, 0, 0, 512, 128)
			elseif gfx == "medium" then 
				mgSetCrop(optionsGfx, 0, 128, 512, 256)
			elseif gfx == "high" then 
				mgSetCrop(optionsGfx, 0, 256, 512, 384) 
			end
			mgSetOrigo(optionsGfx, "pixel", 256, -150)
			mgDraw(optionsGfx)
			
			local snd1 = mgGet("audio.musicEnabled")
			if snd1 == "0" then
				mgSetCrop(optionsSnd, 0, 0, 110, 128)
			elseif snd1 == "0.3" then 
				mgSetCrop(optionsSnd, 0, 128, 110, 256)
			elseif snd1 == "0.7" then
				mgSetCrop(optionsSnd, 0, 256, 110, 384) 
			else
				mgSetCrop(optionsSnd, 0, 384, 110, 512) 
			end
			mgSetOrigo(optionsSnd, "center")
			mgSetPos(optionsSnd, -135, -110)
			mgDraw(optionsSnd)
			
			local snd1 = mgGet("audio.soundEnabled")
			if snd1 == "0" then
				mgSetCrop(optionsSnd, 0, 0, 110, 128)
			elseif snd1 == "0.3" then 
				mgSetCrop(optionsSnd, 0, 128, 110, 256)
			elseif snd1 == "0.7" then
				mgSetCrop(optionsSnd, 0, 256, 110, 384) 
			else
				mgSetCrop(optionsSnd, 0, 384, 110, 512) 
			end
			mgSetOrigo(optionsSnd, "center")
			mgSetPos(optionsSnd, 225, -110)
			mgDraw(optionsSnd)
			mgPopCanvas()
		end
	else
		menu:draw()
	end
	
	if menu:depth() >= 2 then
		mgDraw(back)
	end
	
	errorPopup:draw()
	
	if waiting then
		mgFullScreenColor(0,0,0,0.5)
		waitAngle = waitAngle - 0.1
		mgSetRot(waitImg, waitAngle)
		mgDraw(waitImg)
		
		mgSetText(waitText, waitingReason)
		mgSetOrigo(waitText, "center")
		mgDraw(waitText)
	end
end

function drawWorld()
	local status, msg = pcall(drawWorld2)
	
	if not status then
		knLog(LOG_ERROR, msg)
		os.exit()
	end
end

function startLevelListRequest(type)
	waitMgr:start("Getting " .. type .. " levels...")
	
	local url = "http://" .. HOSTNAME .. "/api/v1/levels/" .. type .. "?format=binary"
	
	if NO_API then
		url = "http://" .. HOSTNAME .. "/" .. type .. ".bin"
	end
	
	httpGet(url, function (response)
		if response.success then
			
		else
			loadOfflineLevelMenu()
			waitMgr:stop()
		end
	end)
end

function updateLevelListRequest()
	if LevelListRequest then
		local status = knHttpUpdate(LevelListRequest)
		
		if status == KN_HTTP_DONE then
			local data = knHttpData(LevelListRequest)
			
			-- cache it so if the user is offline later they can still open the
			-- game and play downloaded levels. make sure to tell them they are
			-- offline tho!
			knWriteFile(knGetInternalDataPath() .. "/" .. listRequestType .. ".bin", data)
			
			pushNewLevelMenu("Featured levels", decodeBinary(data))
			
			waitMgr:stop()
			knHttpRelease(LevelListRequest)
			LevelListRequest = nil
		elseif status == KN_HTTP_ERROR then
			-- If we have a cached response, load that instead of just failing.
			if hasCachedLevelList() then
				loadOfflineLevelMenu()
			else
				errorPopup:show("Failed to get level list")
			end
			
			waitMgr:stop()
			knHttpRelease(LevelListRequest)
			LevelListRequest = nil
		end
	end
end

function decodeBinary(string)
	local list = {}
	
	-- split by nulls
	for item in string.gmatch(string, "([^%z]+)") do
		list[#list + 1] = item
	end
	
	-- keys
	local keys = {}
	
	for _, item in ipairs(list) do
		if item == "*END*" then break end
		keys[#keys + 1] = item
	end
	
	-- values
	local objCount = (#list - #keys - 1) / #keys
	local values = {}
	
	for i = 1, objCount do
		values[i] = {}
		
		for j = 1, #keys do
			values[i][keys[j]] = list[(i * #keys + 1) + j]
		end
	end
	
	return values
end

function filterOffline(data)
	local newlist = {}
	
	for i, v in ipairs(data) do
		if knIsFile(knGetInternalDataPath() .. "/saved/" .. v.filename) then
			newlist[#newlist + 1] = v
		end
	end
	
	return newlist
end

function hasCachedLevelList()
	return knIsFile(knGetInternalDataPath() .. "/" .. listRequestType .. ".bin")
end

function loadOfflineLevelMenu()
	local data = knReadFile(knGetInternalDataPath() .. "/" .. listRequestType .. ".bin")
	pushNewLevelMenu("Featured levels", filterOffline(decodeBinary(data)))
	errorPopup:show("You seem to be offline. You can still play previously downloaded levels, but not download any new ones.")
end

function pushNewLevelMenu(title, levels)
	menu:push("levellist", {
		title = title,
		offset = 0,
		list = levels,
	})
end

function pushMainMenu()
	menu:push("main", {})
end

function downloadAndStart(info)
	waitMgr:start("Getting " .. type .. " levels...")
	
	httpGet(info.url, function (response)
		if response.success then
			waitMgr:stop()
			
			knMakeDir(knGetInternalDataPath() .. "/saved")
			local path = knGetInternalDataPath() .. "/saved/" .. info.filename
			local data = response:getData()
			knWriteFile(path, data)
			
			knLog(LOG_INFO, "Wrote " .. path)
			
			startLevel(info)
		else
			errorPopup:show("Failed to request level")
			waitMgr:stop()
		end
	end)
end

function startLevel(info)
	-- Various fixups for old database versions
	info.start_balls = tonumber(info.start_balls)
	info.start_streak = tonumber(info.start_streak)
	
	if info.start_balls == 0 then
		info.start_balls = 25
	end
	
	if info.level == "*NONE*" then
		info.level = string.lower(info.name)
	end
	
	-- Actually mount and load the level
	local path = knGetInternalDataPath() .. "/saved/" .. info.filename
	
	knUnmountOverlay()
	local success = knMountOverlay(path)
	
	if success then
		knLog(LOG_INFO, "Mounted " .. path)
		knLoadTemplates()
		knSetPlayerZeroState(info.start_balls, info.start_streak)
		mgCommand("level.start level:" .. info.level)
	else
		knLog(LOG_ERROR, "Failed to mount " .. path)
	end
end

function handleCommand2(cmd)
	knLog(LOG_INFO, cmd)
	
	if cmd == "load" then
		load()
	end
	
	if getFirst(cmd) == "call" then
		_G[getSecond(cmd)]()
	end
	
	if cmd == "popmenu" then
		menu:pop()
	end
	
	if cmd == "back" then
		if waitMgr:isWaiting() then
			-- do nothing
		elseif errorPopup:isShowing() then
			handleCommand("closeError")
		elseif menu:depth() >= 2 then
			handleCommand("popmenu")
		else
			mgCommand("game.quit")
		end
	end
	
	if cmd == "gameover" then
		local newScore = tonumber(mgGet("level.score"))
		local newTime = tonumber(mgGet("level.simtime"))
	end
	
	if cmd == "closeError" then
		errorPopup:hide()
	end
	
	if cmd == "showoptions" then
		mgSetUiModal(optionsUi, true)
		mgSetAlpha(optionsCanvas, 0)
		mgSetScale(optionsCanvas, 1.5, 1.2)
		mgSetScale(optionsCanvas, uiScale, uiScale, "easeout", 0.15)
		mgSetAlpha(optionsCanvas, 1, "easeout", 0.15)
	end

	if cmd == "hideoptions" then
		mgSetUiModal(optionsUi, false)
		mgSetScale(optionsCanvas, 0.2, 0.4, "easein", 0.15)
		mgSetAlpha(optionsCanvas, 0, "easein", 0.15)
	end
	
	if startsWith(cmd, "startLevelAtIndexFromCurrentOffset") then
		status, message = pcall(function ()
			local state = menu:getState()
			
			if menu:getType() == "levellist" then
				local index = state.offset + tonumber(getSecond(cmd))
				
				if index <= #state.list then
					local info = state.list[index]
					
					targetLevel = info
					
					-- If we've already downloaded the level, don't download it
					-- again. Otherwise fetch it.
					if knIsFile(knGetInternalDataPath() .. "/saved/" .. info.filename) then
						startLevel(info)
					else
						downloadAndStart(info)
					end
				end
			end
		end)
		
		if not status then
			knLog(LOG_ERROR, message)
		end
	end
	
	if startsWith(cmd, "addOffset") then
		local state = menu:getState()
		
		if menu:getType() == "levellist" then
			state.offset = state.offset + tonumber(getSecond(cmd))
			
			if state.offset > #state.list then
				state.offset = 0
			end
		end
	end
	
	if startsWith(cmd, "subOffset") then
		local state = menu:getState()
		
		if menu:getType() == "levellist" then
			state.offset = state.offset - tonumber(getSecond(cmd))
			
			if state.offset < 0 then
				state.offset = (#state.list - #state.list % 3)
			end
		end
	end
end

function handleCommand(cmd)
	local status, msg = pcall(function () handleCommand2(cmd) end)
	
	if not status then
		knLog(LOG_ERROR, msg)
	end
end

function MenuStack()
	return {
		items = {},
		push = function (self, t, state, onPush, onDraw, onPop)
			self.items[#self.items + 1] = {
				type = t,
				state = state,
				onPush = onPush,
				onDraw = onDraw,
				onPop = onPop,
			}
			
			local obj = self.items[#self.items]
			
			if obj.onPush ~= nil then
				obj:onPush()
			end
		end,
		pop = function (self)
			local obj = self.items[#self.items]
			
			if obj.onPop ~= nil then
				obj:onPop()
			end
			
			self.items[#self.items] = nil
		end,
		draw = function (self)
			local obj = self.items[#self.items]
			
			if obj.onDraw ~= nil then
				obj:onDraw()
			end
		end,
		getState = function (self)
			if #self.items == 0 then return end
			return self.items[#self.items].state
		end,
		getType = function (self)
			if #self.items == 0 then return end
			return self.items[#self.items].type
		end,
		depth = function (self)
			return #self.items
		end
	}
end

menu = MenuStack()
