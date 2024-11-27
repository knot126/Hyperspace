MODE_TRAINING = 0
MODE_CLASSIC = 1
MODE_EXPERT = 2
MODE_ZEN = 3
MODE_VERSUS = 4
MODE_COOP = 5
MODE_COUNT = 6

HOSTNAME = "192.168.1.128:5000"

waiting = false
waitingReason = ""
loadingFrame = 0
levelToPlay = ""
targetFile = ""

waitMgr = {
	start = function (self, reason)
		waiting = true
		waitingReason = reason
	end,
	stop = function (self)
		waiting = false
		waitingReason = ""
	end
}

errorPopup = {
	showing = false,
	message = "",
	show = function (self, message)
		self.showing = true
		self.message = message
	end,
	hide = function (self)
		self.showing = false
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

function init()
	initGlobals()
	
	loadingBar = mgCreateImage("LoadingBar.png")
	mgSetOrigo(loadingBar, "topleft")
	mgSetPos(loadingBar, left + (0.333 * screenWidth), top)
end

function load()
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
	mgSetScale(waitImg, 1, 1)
	mgSetOrigo(waitImg, "center")
	mgSetPos(waitImg, centerX, centerY)
	waitAngle = 0
	
	waitText = mgCreateText("smashhit")
	mgSetScale(waitText, 0.75, 0.75)
	mgSetPos(waitText, centerX, centerY + 192)
	
	levelListUi = mgCreateUi("levellistui.xml")
	mgSetOrigo(levelListUi, "center")
	mgSetScale(levelListUi, 1.5, 1.5)
	mgSetPos(levelListUi, centerX, centerY)
	
	levelText = mgCreateText("smashhit")
	mgSetColor(levelText, 0, 0, 0)
	mgSetScale(levelText, 0.75, 0.75)
	mgSetPos(levelText, centerX, centerY)
	
	errorUi = mgCreateUi("error.xml")
	mgSetOrigo(errorUi, "center")
	mgSetScale(errorUi, 1.5, 1.5)
	mgSetPos(errorUi, centerX, centerY)
	
	startLevelListRequest()
end

function drawLoading()
-- 	initGlobals() -- not needed maybe??
	
	loadingFrame = loadingFrame + 1
	
	mgFullScreenColor(0, 0, 0, 1)
	mgSetScale(loadingBar, (loadingFrame / 110 / 256) * (right - left) * (1/3), 1)
	mgDraw(loadingBar)
	
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

function drawWorld2()
	if mgGet("game.loaded")=="0" then
		drawLoading()
		return
	end
	
	mgFullScreenColor(0.5, 0.5, 0.5, 1.0)
	
	updateLevelRequest()
	updateLevelListRequest()
	
	t = mgGet("game.menutransition")
	t = (t-0.5)*2
	if t < 0 then t = 0 end
	
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
	
	local t = menuStack:getType()
	local state = menuStack:getState()
	
	if t == "levellist" then
		mgDraw(levelListUi)
		
		mgSetPos(levelText, centerX - 100, top + 30)
		mgSetText(levelText, tostring(state.offset) .. " of " .. tostring(#state.list))
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
			mgDraw(levelText)
			
			mgSetPos(levelText, textX, textY+80)
			mgSetText(levelText, "by " .. info.creator)
			mgDraw(levelText)
			
			textY = textY + 240
		end
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
		HSLog(HS_LOG_ERROR, msg)
	end
end

function startLevelListRequest()
	LevelListRequest = HSHttpRequest("http://" .. HOSTNAME .. "/api/v1/levels/featured?format=binary")
	if LevelListRequest then
		waitMgr:start("Getting featured levels...")
	else
		errorPopup:show("Failed to create connection")
	end
end

function updateLevelListRequest()
	if LevelListRequest then
		local status = HSHttpUpdate(LevelListRequest)
		
		if status == HS_HTTP_DONE then
			pushNewLevelMenu("Featured levels", decodeBinary(HSHttpData(LevelListRequest)))
			
			waitMgr:stop()
			HSHttpRelease(LevelListRequest)
			LevelListRequest = nil
		elseif status == HS_HTTP_ERROR then
			errorPopup:show("Failed to get level list")
			waitMgr:stop()
			HSHttpRelease(LevelListRequest)
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

function pushNewLevelMenu(title, levels)
	menuStack:push("levellist", {
		offset = 0,
		list = levels,
	})
end

function startLevelRequest(url)
	LevelRequest = HSHttpRequest(url)
	if LevelRequest then
		waitMgr:start("Downloading level...")
	else
		errorPopup:show("Failed to connect to server. Try again.")
	end
end

function updateLevelRequest()
	if LevelRequest then
		local status = HSHttpUpdate(LevelRequest)
		
		if status == HS_HTTP_PENDING then
			-- nop
		elseif status == HS_HTTP_DONE then
			waitMgr:stop()
			
			HSMakeDir(HSGetInternalDataPath() .. "/saved")
			local path = HSGetInternalDataPath() .. "/saved/" .. targetFile
			local data = HSHttpData(LevelRequest)
			HSWriteFile(path, data)
			
			HSLog(HS_LOG_INFO, "Wrote " .. path)
			
			HSHttpRelease(LevelRequest)
			LevelRequest = nil
			
			startLevel(targetFile)
		elseif status == HS_HTTP_ERROR then
			errorPopup:show("Failed to request level")
			HSHttpRelease(LevelRequest)
			LevelRequest = nil
			waitMgr:stop()
		end
	end
end

function startLevel(filename)
	local path = HSGetInternalDataPath() .. "/saved/" .. filename
	
	HSOverlayUnmount()
	HSOverlayMount(path)
	
	HSLog(HS_LOG_INFO, "Mounted " .. path)
	
	mgCommand("level.start level:" .. levelToPlay)
end

function handleCommand(cmd)
	HSLog(HS_LOG_INFO, cmd)
	
	if cmd == "load" then
		load()
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
			local state = menuStack:getState()
			
			if menuStack:getType() == "levellist" then
				local index = state.offset + tonumber(getSecond(cmd))
				
				if index <= #state.list then
					local info = state.list[index]
					
					if info.level == "*NONE*" then
						levelToPlay = string.lower(info.name)
					else
						levelToPlay = info.level
					end
					
					targetFile = info.filename
					
					-- If we've already downloaded the level, don't download it
					-- again. Otherwise fetch it.
					if HSIsFile(HSGetInternalDataPath() .. "/saved/" .. targetFile) then
						startLevel(targetFile)
					else
						startLevelRequest(info.url)
					end
				end
			end
		end)
		
		if not status then
			HSLog(HS_LOG_ERROR, message)
		end
	end
	
	if startsWith(cmd, "addOffset") then
		local state = menuStack:getState()
		
		if menuStack:getType() == "levellist" then
			state.offset = state.offset + tonumber(getSecond(cmd))
			
			if state.offset > #state.list then
				state.offset = 0
			end
		end
	end
	
	if startsWith(cmd, "subOffset") then
		local state = menuStack:getState()
		
		if menuStack:getType() == "levellist" then
			state.offset = state.offset - tonumber(getSecond(cmd))
			
			if state.offset < 0 then
				state.offset = (#state.list - #state.list % 3)
			end
		end
	end
end

function MenuStack()
	return {
		items = {},
		push = function (self, t, state)
			self.items[#self.items + 1] = {
				type = t,
				state = state,
			}
		end,
		pop = function (self)
			self.items[#self.items] = nil
		end,
		getState = function (self)
			if #self.items == 0 then return end
			return self.items[#self.items].state
		end,
		getType = function (self)
			if #self.items == 0 then return end
			return self.items[#self.items].type
		end
	}
end

menuStack = MenuStack()
