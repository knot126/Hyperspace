MODE_TRAINING = 0
MODE_CLASSIC = 1
MODE_EXPERT = 2
MODE_ZEN = 3
MODE_VERSUS = 4
MODE_COOP = 5
MODE_COUNT = 6

IsWaiting = false

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

levelCount = 13

function setCanvasMode()
	local mode = tonumber(mgGet("player.mode"))
	if mode==MODE_ZEN or mode==MODE_VERSUS or mode==MODE_COOP then
		mgSetCanvasMovable(levelCanvas, "")
	else
		mgSetCanvasMovable(levelCanvas, "x")
	end
end


function initGlobals()
	top = tonumber(mgGet("display.visibleTop"))
	left = tonumber(mgGet("display.visibleLeft"))
	right = tonumber(mgGet("display.visibleRight"))
	bottom = tonumber(mgGet("display.visibleBottom"))
	centerX = (left+right)*0.5
	centerY = (top+bottom)*0.5
end


function init()
	initGlobals()
	uiScale = tonumber(mgGet("game.uiscale"))
	
	platform = mgGet("game.platform")

	levelCanvas = mgCreateCanvas(1024*15, 2048)
	mgSetCanvasWindow(levelCanvas, 0, 0, 2048, 1536)
	setCanvasMode()
	
	loadingLogo = mgCreateImage("logo.png")
	mgSetOrigo(loadingLogo, "center")
	mgSetPos(loadingLogo, centerX+4, top+203)
	mgSetScale(loadingLogo, 0.75, 0.75)
	
	loadingMediocre = mgCreateImage("loading_mediocre.png")
	mgSetOrigo(loadingMediocre, "center")
	mgSetPos(loadingMediocre, centerX, top+230)
	mgSetScale(loadingMediocre, 0.11, 0.11)
	
	loadingBg = mgCreateImage("loading_bg.png")
	mgSetOrigo(loadingBg, "center")
	mgSetScale(loadingBg, 0.85, 0.85)
	mgSetPos(loadingBg, centerX, top+230)

	loadingBall = mgCreateImage("loading_ball.png")
	mgSetOrigo(loadingBall, "center")
	mgSetScale(loadingBall, 0.11, 0.11)
	mgSetPos(loadingBall, centerX, top+230)

	loadingDots = {}
	for i=1,8 do
		loadingDots[i] = mgCreateImage("loading_dot.png")
		mgSetOrigo(loadingDots[i], "center")	
		mgSetScale(loadingDots[i], 0.02, 0.02)
		mgSetPos(loadingDots[i], centerX+(i-4.5)*6.25, top+250.75+0.7*math.sin(i/3))
	end
	
	loadingFrame = 0
	
	panSnd = mgCreateSound("camera_pan.ogg")
	loadingClick = mgCreateSound("loadingclick.ogg")
	
	continueLevel = 1
	scrollFrame = 0

	rate = -1
	ads_icon = -1
	checkAds()
end


function drawLoading()
	initGlobals()
	
	local f = tonumber(mgGet("game.frame"))
	local a = 1.0-(f-30)/60
	if a < 0 then a = 0 end
	if a > 1 then a = 1 end	

	mgSetAlpha(loadingLogo, 1-a)
	mgDraw(loadingLogo)

	mgSetAlpha(loadingBg, a)
	mgDraw(loadingBg)
	mgSetAlpha(loadingBall, a)
	mgDraw(loadingBall)
	mgSetAlpha(loadingMediocre, a)
	mgDraw(loadingMediocre)
	for i=1, 8 do
		if loadingFrame==20+i*10 then 
			mgSetScale(loadingDots[i], 0.06+math.sin(i/3)/30, 0.06+math.sin(i/3)/30, "easeout", 0.15)
			mgPlaySound(loadingClick, 0.5)
		end
		mgSetAlpha(loadingDots[i], a)
		mgDraw(loadingDots[i])
	end
	if loadingFrame < 8 then
		mgFullScreenColor(0,0,0,1.0-loadingFrame/8.0)
	end
	loadingFrame = loadingFrame + 1
	if loadingFrame == 110 then
		mgPlaySound(panSnd)
		mgCommand("audio.playBackgroundMusic music/menu.ogg")
	end
end


function loadRanks()
	local mode = tonumber(mgGet("player.mode"))
	if mode == MODE_COOP then
		ranks = mgCreateImage("ranks_coop.png")
		mgSetScale(ranks, .75, .75)
		mgSetPos(ranks, left+727, bottom-139)
		rankScore = {}
		for i=1,8 do
			rankScore[i] = (i-1)*800
		end
	else
		ranks = mgCreateImage("ranks.png")
		mgSetScale(ranks, .75, .75)
		mgSetPos(ranks, left+727, bottom-139)
		rankScore = {}
		for i=1,17 do
			rankScore[i] = (i-1)*1000
		end
		rankScore[14] = 12500
		rankScore[15] = 13000
		rankScore[16] = 13500
		rankScore[17] = 14000
	end
end


function load()
	optionsButton = mgCreateUi("optionsbutton.xml")
	mgSetOrigo(optionsButton, "bottomright")
	mgSetScale(optionsButton, .75, .75)
	mgSetPos(optionsButton, right-360, bottom-55)

	optionsCanvas = mgCreateCanvas(1,1)
	mgSetPos(optionsCanvas, centerX, centerY)
	mgSetScale(optionsCanvas, .5, .5)
	mgSetAlpha(optionsCanvas, 0)
	
	optionsUi = mgCreateUi("options.xml")
	mgSetOrigo(optionsUi, "center")
	mgSetPos(optionsUi, 0, 0)

	haloCircle = mgCreateImage("menu_halo.png")
	mgSetOrigo(haloCircle, "center")
	mgSetPos(haloCircle, centerX, centerY)
	mgSetAlpha(haloCircle, 0)
	
	moreButton = mgCreateUi("morebutton.xml")
	mgSetOrigo(moreButton, "bottomright")
	mgSetScale(moreButton, .75, .75)
	mgSetPos(moreButton, right-55, bottom-55)
	
	scoreButton = mgCreateUi("scorebutton.xml")
	mgSetOrigo(scoreButton, "bottomleft")
	mgSetPos(scoreButton, left+498, bottom-55)
	mgSetScale(scoreButton, .75, .75)
	
	moreUi = mgCreateUi("menu_more.xml")
	mgSetOrigo(moreUi, "center")
	mgSetPos(moreUi, centerX, centerY)
	mgSetAlpha(moreUi, 0)

	gameOverCanvas = mgCreateCanvas(1024, 1024)
	mgSetOrigo(gameOverCanvas, "center")
	mgSetPos(gameOverCanvas, centerX, centerY)
	mgSetScale(gameOverCanvas, 0, 0)
	mgSetAlpha(gameOverCanvas, 0)
	
	gameOver = mgCreateImage("gameover.png")
	mgSetPos(gameOver, 512, 512)
	
	gameOverRestart = mgCreateUi("gameover_restart.xml")
	mgSetOrigo(gameOverRestart, "center")
	mgSetPos(gameOverRestart, 512, 700)

	gameOverContinue = mgCreateUi("gameover_continue.xml")
	mgSetOrigo(gameOverContinue, "center")
	mgSetPos(gameOverContinue, 512, 700)

	gameOverContinueText = mgCreateText("numbers_light", true)
	mgSetPos(gameOverContinueText, 495, 755)
	mgSetColor(gameOverContinueText, 0, 0, 0)

	gameOverScore = mgCreateText("numbers_bold", true)
	mgSetPos(gameOverScore, 470, 430)
	
	buttons = {}
	for i=1,levelCount do
		buttons[i] = mgCreateUi("button"..i..".xml")
		mgSetOrigo(buttons[i], "center")
	end
	
	scoreText = mgCreateText("smashhit")
	mgSetScale(scoreText, 0.5, 0.5)

	buttonText = mgCreateText("numbers_light", true)
	mgSetColor(buttonText, 1, 1, 1)

	dbgButton = mgCreateUi("debug.xml")
	mgSetOrigo(dbgButton, "topleft")
	mgSetPos(dbgButton, left+70, top+70)
	
	dbgMenu = mgCreateUi("debugmenu.xml")
	mgSetOrigo(dbgMenu, "center")
	mgSetPos(dbgMenu, (left+right)*0.5, (top+bottom)*0.5)
	mgSetScale(dbgMenu, 0, 0)
	
	playMenuCanvas = mgCreateCanvas(2048, 1536)
	mgSetOrigo(playMenuCanvas, "center")
	mgSetPos(playMenuCanvas, centerX, centerY)
	mgSetAlpha(playMenuCanvas, 0)
	
	playMenu = mgCreateUi("play_menu.xml")
	mgSetOrigo(playMenu, "center")
	mgSetPos(playMenu, centerX, centerY)
	
	playMenuText = mgCreateText("numbers_light", true)
	mgSetColor(playMenuText, 0, 0, 0)

	playMenuScore = mgCreateText("numbers_bold", true)
	mgSetScale(playMenuScore, .8, .8)
	mgSetPos(playMenuScore, centerX+30, centerY-45)
	
	playMenuStreak = mgCreateImage("hud/streak_balls.png")
	mgSetScale(playMenuStreak, .8, .8)
	mgSetPos(playMenuStreak, centerX-70, centerY-40)
	
	premiumImg = mgCreateImage("premium.png")
	mgSetScale(premiumImg, 1, 1)
	mgSetOrigo(premiumImg, "topright")
	mgSetPos(premiumImg, right-110, top+80)
	
	waitImg = mgCreateImage("wait.png")
	mgSetScale(waitImg, 2, 2)
	mgSetOrigo(waitImg, "center")
	mgSetPos(waitImg, centerX, centerY)
	waitAngle = 0
	
	logo = mgCreateImage("logo.png")
	mgSetOrigo(logo, "center")
	mgSetPos(logo, centerX+4, top+203)
	mgSetScale(logo, 0.75, 0.75)
	
	logoMode = mgCreateImage("logo_mode.png")
	mgSetPos(logoMode, centerX-62, top+171)
	mgSetScale(logoMode, 0.75, 0.75)

	modeButton = mgCreateUi("modebutton.xml")
	mgSetScale(modeButton, .75, .75)
	mgSetPos(modeButton, left+50, bottom-155)

	top_gradient = mgCreateImage("gradient_edges.png")
	mgSetScale(top_gradient, 2, 5)
	mgSetAlpha(top_gradient, 1)
	mgSetOrigo(top_gradient, "topleft")
	mgSetPos(top_gradient, left, top-100)

	bottom_gradient = mgCreateImage("gradient_bottom.png")
	mgSetScale(bottom_gradient, 2, 2.75)
	mgSetOrigo(bottom_gradient, "bottomleft")
	mgSetPos(bottom_gradient, left, bottom)
	
	button_pole = mgCreateImage("button_pole.png")
	mgSetScale(button_pole, 1, 1)
	mgSetOrigo(button_pole, "center")

	currentHighscore = mgGetHighScore()
	displayHighscore = currentHighscore
	highscoreProgress = 0
	highscoreSound = mgCreateSound("menu/counting.ogg")
 	
	n = 0
		
	glowLine = mgCreateImage("menu_lineglow.png")
	mgSetScale(glowLine, 4, 4)
	mgSetOrigo(glowLine, "center")
	mgSetPos(glowLine, centerX, centerY)
	mgSetAlpha(glowLine, 0)
	
	optionsGfx = mgCreateImage("toggle_graphics.png")
	mgSetPos(optionsGfx, 0, 15)
	
	optionsSnd = mgCreateImage("toggle_sound.png")
	
	upgradeButton = mgCreateUi("upgradebutton.xml")
	mgSetOrigo(upgradeButton, "topright")
	mgSetPos(upgradeButton, right-28, top+22)
	mgSetScale(upgradeButton, .75, .75)

	upgradeCanvas = mgCreateCanvas(2048, 768)
	mgSetAlpha(upgradeCanvas, 0)
	mgSetOrigo(upgradeCanvas, "center")
	mgSetPos(upgradeCanvas, centerX, centerY-50)
	mgSetScale(upgradeCanvas, 1, 0)
	
	upgrade = mgCreateImage("upgrade.png")
	upgradeBuy = mgCreateUi("upgrade_buy.xml")
	mgSetOrigo(upgradeBuy, "center")
	upgradeRestore = mgCreateUi("upgrade_restore.xml")
	mgSetOrigo(upgradeRestore, "center")
	mgSetPos(upgradeRestore, centerX, 630)

	upgradeCheckpoints = mgCreateImage("upgrade_checkpoints.png")
	mgSetOrigo(upgradeCheckpoints, "center")
	mgSetPos(upgradeCheckpoints, 340, 250)
	upgradeGamemodes = mgCreateImage("upgrade_gamemodes.png")
	mgSetOrigo(upgradeGamemodes, "center")
	mgSetPos(upgradeGamemodes, 1700, 250)
	upgradeCloud = mgCreateImage("upgrade_cloud.png")
	mgSetOrigo(upgradeCloud, "center")
	mgSetPos(upgradeCloud, 340, 615)
	upgradeStatistics = mgCreateImage("upgrade_statistics.png")
	mgSetOrigo(upgradeStatistics, "center")
	mgSetPos(upgradeStatistics, 1700, 655)
	
	premiumPrice = mgCreateText("smashhit")

	saleMain = mgCreateImage("hud/sale/smashhit_sale_main.jpg")
	mgSetPos(saleMain, right-390, top-50)
	mgSetRot(saleMain, -math.pi/4)
	salePremium = mgCreateImage("hud/sale/smashhit_sale_premium.png")
	mgSetPos(salePremium, 340, -46)
	salePremiumBg = mgCreateImage("hud/sale/smashhit_sale_premium_bg.png")
	mgSetPos(salePremiumBg, 0, -236)
	saleText = mgCreateText("numbers", true)
	mgSetPos(saleText, 1054, 20)
	premiumDash = mgCreateImage("oldprice_dash.png")
	mgSetOrigo(premiumDash, "center")
	mgSetPos(premiumDash, centerX, 570)

	highscoreText = mgCreateText("numbers", true)
	mgSetScale(highscoreText, 0.5, 0.5)
	mgSetPos(highscoreText, left+705, bottom-74)

	loadRanks()

	scoreInit()
	
	gameOverShown = false
	
	displayHighscore = mgGetHighScore()
	displayRank = getRank(displayHighscore)
	targetRank = displayRank
	rankFrame = 0
	rankSound = mgCreateSound("score/rank.ogg")
	
	showSound = mgCreateSound("showmenu.ogg")
	showCpSound = mgCreateSound("showcheckpoint.ogg")
	hideSound = mgCreateSound("hidemenu.ogg")

	statsHidden = mgCreateImage("statshidden.png")
	mgSetOrigo(statsHidden, "pixel", 0, 2)
	mgSetScale(statsHidden, 0.8, 0.8)
	
	statsBlank = mgCreateUi("statsblank.xml")
	mgSetScale(statsBlank, 100, 1)
	mgSetPos(statsBlank, 0, 420)
	
	supportButton = mgCreateUi("supportbutton.xml")
	mgSetOrigo(supportButton, "center")
	mgSetPos(supportButton, 0, 310)
	
	modeCanvas = mgCreateCanvas(2048, 1536)
	mgSetOrigo(modeCanvas, "center")
	mgSetPos(modeCanvas, centerX, centerY)
	mgSetAlpha(modeCanvas, 0)

	modeMenu = mgCreateUi("mode_menu.xml")
	mgSetOrigo(modeMenu, "center")
	mgSetPos(modeMenu, centerX, centerY)
	mgSetScale(modeMenu, 0.75, 0.75)

	modePremium = mgCreateImage("premium_banner.png")
	
	newUi = mgCreateUi("newgamemodes.xml")
	mgSetPos(newUi, left+50, bottom-170)
	mgSetOrigo(newUi, "bottomleft")
	mgSetScale(newUi, uiScale, uiScale)
	--if (mgGet("game.trymode") == "2" or tonumber(mgGet("player.startcount")) < 2) then
	mgSetAlpha(newUi, 0)
	--else
	--	mgSetUiModal(newUi, true)
	--	mgSetCanvasEnabled(levelCanvas, false)
	--end
	
	statsCounter = 0
end


function getRank(score)
	for i=#rankScore, 1, -1 do
		if score >= rankScore[i] then
			return i
		end
	end
	return 1
end


function scoreInit()
	scCanvas = mgCreateCanvas(2048, 850)
	mgSetOrigo(scCanvas, "center")
	mgSetPos(scCanvas, centerX, centerY)
	mgSetScale(scCanvas, 1, 0)
	mgSetAlpha(scCanvas, 0)
	scBackground = mgCreateImage("score/background.png")
	scMode = "gc"
	
	scGcIn = mgCreateUi("score/gc_in.xml")
	mgSetPos(scGcIn, 240, 170)

	if platform=="android" then
		mgSetPos(scGcIn, 120, 200)
		scGcOut = mgCreateUi("score/gc_out.xml")
		mgSetPos(scGcOut, 120, 200)
	end
	
	scStats = mgCreateText("numbers", true)
	mgSetScale(scStats, 0.6, 0.6)
	
	scRankFrame = 0
	
	scOpenSound = mgCreateSound("score_open.ogg")
	scOpenClose = mgCreateSound("score_close.ogg")
end


function scoreFrame()
end


function scoreDraw()
	local tmp, a = mgGetScale(scCanvas)
	if a > 0 then
		mgFullScreenColor(0, 0, 0, a*0.3)
	else
		return
	end

	mgPushCanvas(scCanvas)
	mgDraw(scBackground)
	
	local signedIn = true
	if platform=="android" then
		signedIn = (mgGet("game.signedin") == "1")
	end
	if signedIn then
		mgDraw(scGcIn)
	else
		if scGcOut then
			mgDraw(scGcOut)
		end
	end
	
	statsCounter = statsCounter + 1
	if statsCounter == 20 then mgPlaySound(highscoreSound) end
	
	local tr = (statsCounter-20) / 60
	if tr > 0 then 
		if tr > 1 then tr = 1 end

		local premium = (mgGet("game.premium") == "1")
	
		local ballsHit = tonumber(mgGet("stats.ballshit"))
		local balls = tonumber(mgGet("stats.balls"))
		if balls == 0 then balls = 1 end
		local hitRate = ballsHit / balls * 100
	
		local avgStreak = 0
		local avgBalls = 0
		if tonumber(mgGet("stats.rooms")) > 0 then
			avgStreak = math.floor(tonumber(mgGet("stats.accstreak")) / tonumber(mgGet("stats.rooms")))
			avgBalls = math.floor(tonumber(mgGet("stats.accballs")) / tonumber(mgGet("stats.rooms")))
		end

		stats = {}
		stats[0] = mgGet("stats.distance")
		stats[1] = mgGet("stats.streak")
		stats[2] = mgGet("stats.peakballs")
		stats[3] = hitRate
		stats[4] = avgStreak
		stats[5] = avgBalls
		stats[6] = mgGet("stats.balls")
		stats[7] = mgGet("stats.broken")
	
		for i=0,7 do
			local x,y	
			if i<4 then x = 620 else x = 1520 end
			y = (i%4)*89+360
			if premium then
				mgSetPos(scStats, x, y) 
				local txt = math.floor(tonumber(stats[i])*tr)
				if i==3 then
					txt = txt .. ">"
				end
				mgSetText(scStats, txt) 
				mgDraw(scStats)
			else
				mgSetPos(statsHidden, x, y)
				mgDraw(statsHidden)
			end
		end
	
		if not premium then
			mgDraw(statsBlank)
		end
	end
	mgPopCanvas()
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
		
	if tonumber(mgGet("game.menutransition")) > 0.99 then
		local highscore = mgGetHighScore()
		if highscore > currentHighscore then
			if highscoreProgress == 0 then
				--Init highscore sequence
				highscoreProgress = 0.01
				mgPlaySound(highscoreSound)
			elseif highscoreProgress > 1 then
				--End highscore sequence
				currentHighscore = highscore
				displayHighscore = highscore
				highscoreProgress = 0
			else
				--Highscore sequence
				highscoreProgress = highscoreProgress + 0.02
				displayHighscore = math.floor(currentHighscore + (highscore-currentHighscore)*highscoreProgress)
			end
		end
		if highscore < currentHighscore then
			currentHighscore = highscore
			displayHighscore = highscore
			highscoreProgress = 0
		end
	end
	scoreFrame()

	if displayHighScore == currentHighScore then
		targetRank = getRank(currentHighscore)
	end	
	
	scrollFrame = scrollFrame + 1
	if scrollFrame < 30 and mgGetHighScore(1) > 0 then
		local x,y = mgGetPos(levelCanvas)
		if x > -220 then mgSetPos(levelCanvas, x+(-220-x)*0.2, y) end
	end

	if displayRank ~= targetRank then
		if rankFrame == 0 then
			rankFrame = 1
			mgSetAlpha(ranks, 1)
			mgSetAlpha(ranks, 0, "easeout", 0.5)
			--mgSetScale(ranks, 1, 1)
			--mgSetScale(ranks, 0, 0, "easein", 0.5)
		else
			rankFrame = rankFrame + 1
			if rankFrame == 30 then
				mgPlaySound(rankSound)
				displayRank = targetRank
				mgSetAlpha(ranks, 0)
				mgSetAlpha(ranks, 1, "easein", 0.5)
				--mgSetScale(ranks, 2, 2)
				--mgSetScale(ranks, 1, 1, "easeout", 0.5)
				rankFrame = 0
			end
		end
	end
end


function draw()
	if mgGet("game.loaded")=="0" then
		return
	end

	mgDraw(glowLine)
	
	local goa = mgGetAlpha(gameOverCanvas)
	if goa > 0 then
		mgFullScreenColor(0,0,0,goa*0.5)
		mgPushCanvas(gameOverCanvas)
		mgDraw(gameOver)
		mgSetScale(gameOverScore, mgGetScale(gameOver))
		mgDraw(gameOverScore)
		mgDraw(gameOverRestart)
		mgDraw(gameOverContinue)
		mgDraw(gameOverContinueText)
		mgPopCanvas()
	end
	
	if glowT > 0 then
		glowT = glowT-1
	end
	
	scoreLineCheck = mgGetAlpha(glowLine)
	if scoreLineCheck > 0 and glowT == 0 then
		mgSetAlpha(glowLine, 0, "linear", .05)
		mgSetScale(glowLine, 4, .1, "linear", .05)
	end
end

function drawWorld()
	if mgGet("game.loaded")=="0" then
		drawLoading()
		return
	end

	t = mgGet("game.menutransition")
	t = (t-0.5)*2
	if t < 0 then t = 0 end

	local mode = tonumber(mgGet("player.mode"))

	mgSetZ(0)

	mgFullScreenColor(0, .2, .25, t)

	mgDrawMenuMesh()

	mgSetAlpha(top_gradient, t)
	mgDraw(top_gradient)
	mgSetAlpha(bottom_gradient, t)
	mgDraw(bottom_gradient)
	
	if mgGet("game.premium") ~= "1" then
		mgSetAlpha(upgradeButton, t)
		mgDraw(upgradeButton)
		if mgGet("player.adssale") ~= "0" then
			mgDraw(saleMain)
		end
	end
	
	mgSetAlpha(dbgButton, t*0.3)
	mgSetAlpha(optionsButton, t)
	if mgGet("game.deploy")=="0" then
		mgDraw(dbgButton)
	end
	mgSetAlpha(optionsButton, t)
	mgDraw(optionsButton)

	mgSetAlpha(moreButton, t)
	mgDraw(moreButton)

	for i=0,MODE_COUNT do
		mgSetUiSelectionEnabled(modeButton, i, false)
	end
	mgSetUiSelectionEnabled(modeButton, mode, true)
	mgSetAlpha(modeButton, t)
	mgDraw(modeButton)
	if mode == 1 then mgSetCrop(modeButton, 0, 0, 580, 134)
	elseif mode == 3 then mgSetCrop(modeButton, 0, 135, 580, 268)
	elseif mode == 0 then mgSetCrop(modeButton, 0, 268, 580, 401)
	elseif mode == 4 then mgSetCrop(modeButton, 0, 536, 580, 668)
	elseif mode == 5 then mgSetCrop(modeButton, 0, 670, 580, 802)
	else mgSetCrop(modeButton, 0, 402, 580, 535)
	end

	if mode == MODE_CLASSIC or mode == MODE_TRAINING or mode == MODE_EXPERT or mode == MODE_COOP then
		mgSetAlpha(scoreButton, t)
		mgDraw(scoreButton)

		local scoreProgress = 1
		if targetRank < #rankScore then
			local scoreLow = rankScore[targetRank]
			local scoreHigh = rankScore[targetRank+1]
			scoreProgress = (displayHighscore-scoreLow)/(scoreHigh-scoreLow)
			if scoreProgress > 1 then scoreProgress = 1 end
		end

		mgSetText(highscoreText, displayHighscore)
		mgSetOrigo(highscoreText, "bottomright")
		mgSetColor(highscoreText, .75, .9, .95)
		mgSetAlpha(highscoreText, t)
		mgDraw(highscoreText)

		local y = 93*(displayRank-1)
		mgSetCrop(ranks, 0, y, 520, y+93)
		mgSetOrigo(ranks, "topleft")
		mgSetAlpha(ranks, t)
		mgDraw(ranks)
	end

	x,y = mgGetPos(levelCanvas)
	mgSet("game.levelpos", x)

	local wide = 4.0*(1.0-(bottom-top)/1536)
	if wide > 1.0 then wide = 1.0 end
	for i=1,levelCount do
		x = (i-1)*680
		dist = (i-1)*1000
		score = mgGetHighScore(i-1)

		bx,by = mgGetCheckpointPos(i-1)
		bx = bx + 15
		by = by - 50 - 40*wide
		local buttonOffset = math.sin(mgScriptTime()*2+2*i)*5.0;
		mgSetPos(buttons[i], bx, by + buttonOffset)

		mgSetZ(7)
		mgSetAlpha(buttons[i], t)
		mgDraw(buttons[i])

		mgSetPos(button_pole, bx, by+160)
		mgSetAlpha(button_pole, t)
		mgDraw(button_pole)
		
		mgSetText(buttonText, ""..i-1)
		mgSetOrigo(buttonText, "center")
		mgSetPos(buttonText, bx-20, by-35+buttonOffset)
		mgSetScale(buttonText, 1, 1)
		mgSetAlpha(buttonText, t)

		if i > 1 and i < levelCount then
			mgDraw(buttonText)
		end

		if mgGetHighScore(i) == 0 then
			break
		end
	end
	mgSetZ(0)

	local f = tonumber(mgGet("game.frame"))
	if f > 100 then
		mgSetAlpha(logo, t)
		mgDraw(logo)
		if mode ~= 1 then
			if mode == 3 then mgSetCrop(logoMode, 0, 0, 164, 174) end
			if mode == 0 then mgSetCrop(logoMode, 0, 174, 164, 174*2) end
			if mode == 2 then mgSetCrop(logoMode, 0, 174*2, 164, 174*3) end		
			if mode == 4 then mgSetCrop(logoMode, 0, 174*3, 164, 174*4) end		
			if mode == 5 then mgSetCrop(logoMode, 0, 174*4, 164, 174*5) end		
			mgSetAlpha(logoMode, t)
			mgDraw(logoMode)
		end

	else
		mgFullScreenColor(0, 0, 0, 1.0-(f-30)/30)
		drawLoading()
	end

	local newAlpha = mgGetAlpha(newUi)
	if newAlpha > 0 then
		mgFullScreenColor(0,0,0,newAlpha*0.5)
		mgDraw(newUi)
	end
	
	local a = mgGetAlpha(playMenuCanvas)
	if a > 0 then
		mgFullScreenColor(0,0,0,a*0.5)
		mgPushCanvas(playMenuCanvas)
		mgDraw(playMenu)
		mgDraw(playMenuStreak)
		mgDraw(playMenuScore)
		if selectedLevel then
			score = mgGetHighScore(selectedLevel)
			local lvl = tonumber(selectedLevel)
			if lvl < 12 then
			mgSetText(playMenuText, lvl)
			else
				mgSetText(playMenuText, ";") -- Endless
			end
			mgSetOrigo(playMenuText, "center")
			mgSetAlpha(playMenuText, 1)
			mgSetPos(playMenuText, centerX + 215, centerY - 151)
			mgSetScale(playMenuText, 0.68, 0.68)
			mgDraw(playMenuText)		
		end
		mgPopCanvas()
	end
	
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
	
	if rate ~= -1 then
		local rateAlpha = mgGetAlpha(rate)
		if rateAlpha > 0 then
			mgFullScreenColor(0,0,0,rateAlpha*0.5)
			mgDraw(rate)
		end
	end
		
	local moreAlpha = mgGetAlpha(moreUi)
	if moreAlpha > 0 then
		mgFullScreenColor(0,0,0,moreAlpha*0.5)
		mgDraw(moreUi)
	end
	mgDraw(dbgMenu)
	
	if ads_icon ~= -1 and mgGet("player.adsshown") == "0" then
		if mgGet("player.adsonlyfree") == "0" or mgGet("game.premium")=="0" then
			mgDraw(ads_icon)
		end
	end

	local a = mgGetAlpha(upgradeCanvas)
	if a > 0 then
		local secLeft = tonumber(mgGet("player.adssale"))
		mgFullScreenColor(0,0,0,a*0.5)
		mgPushCanvas(upgradeCanvas)
		mgDraw(upgrade)
		local s = math.sin(mgScriptTime()*5)*0.02 + 1.0
		mgSetScale(upgradeBuy, s, s)
		local buyOffset = 0
		if secLeft > 0 then
			buyOffset = 20
			mgSetPos(upgradeRestore, centerX, 670)
		else
			mgSetPos(upgradeRestore, centerX, 620)
		end
		mgSetPos(upgradeBuy, centerX, 425-buyOffset)
		mgDraw(upgradeBuy)
		mgDraw(upgradeRestore)
		mgDraw(upgradeCheckpoints)
		mgDraw(upgradeGamemodes)
		mgDraw(upgradeCloud)
		mgDraw(upgradeStatistics)

		local price = mgGet("game.premiumprice")

		if price ~= "" then
			mgSetText(premiumPrice, price)
			mgSetOrigo(premiumPrice, "center")
			mgSetColor(premiumPrice, 1, 1, 1)
			mgSetPos(premiumPrice, centerX-20, 445-buyOffset+30*s)
			mgSetScale(premiumPrice, s*0.85, s*0.85)
			mgDraw(premiumPrice)
		end
		if secLeft > 0 then
			local daysLeft = math.floor(0.5+secLeft/3600/24)
			mgDraw(salePremiumBg)
			mgDraw(salePremium)
			mgSetText(saleText, ""..daysLeft)
			mgSetOrigo(saleText, "center")
			mgDraw(saleText)
			
			price = mgGet("game.premiumorgprice")
			if price ~= "" then
				mgSetText(premiumPrice, price)
				mgSetOrigo(premiumPrice, "center")
				mgSetColor(premiumPrice, .65, 0.8, .73)
				mgSetPos(premiumPrice, centerX-20, 570)
				mgSetScale(premiumPrice, 0.8)
				mgDraw(premiumPrice)
				mgDraw(premiumDash)
			end
		end
		mgPopCanvas()
	end

	mgDraw(haloCircle)

	if mgGetAlpha(modeCanvas) > 0 then
		mgFullScreenColor(0,0,0,0.5*mgGetAlpha(modeCanvas))
		mgPushCanvas(modeCanvas)
		mgDraw(modeMenu)
		if mgGet("game.premium") == "0" then
			mgSetPos(modePremium, centerX+794, centerY-224)
			mgDraw(modePremium)
			mgSetPos(modePremium, centerX+108, centerY-224)
			mgDraw(modePremium)
			mgSetPos(modePremium, centerX-536, centerY-224)
			mgDraw(modePremium)
			mgSetPos(modePremium, centerX+108, centerY+30)
			mgDraw(modePremium)
			mgSetPos(modePremium, centerX+794, centerY+30)
			mgDraw(modePremium)
		end
		mgPopCanvas()
	end
		
	mgSetZ(-1.3)
	scoreDraw()
	mgSetZ(0)

	if mgGet("game.purchasing") == "1" or IsWaiting then
		mgFullScreenColor(0,0,0,0.5)
		waitAngle = waitAngle - 0.1
		mgSetRot(waitImg, waitAngle)
		mgDraw(waitImg)
	end

	updateLevelRequest()
end

function startLevelRequest()
	LevelRequest = HSHttpRequest("http://192.168.1.128:5000/basic.zip")
	if LevelRequest then
		IsWaiting = true
	end
end

function updateLevelRequest()
	if LevelRequest then
		local status = HSHttpUpdate(LevelRequest)
		
		if status == HS_HTTP_PENDING then
			-- nop
		elseif status == HS_HTTP_DONE then
			IsWaiting = false
			
			local path = HSGetInternalDataPath() .. "/overlay.zip"
			local data = HSHttpData(LevelRequest)
			HSWriteFile(path, data)
			
			HSLog(HS_LOG_ERROR, "Wrote " .. path)
			
			HSHttpRelease(LevelRequest)
			LevelRequest = nil
			
			HSOverlayUnmount()
			HSOverlayMount(path)
			
			HSLog(HS_LOG_ERROR, "Mounted " .. path)
			
			mgCommand("level.start level:basic")
		elseif status == HS_HTTP_ERROR then
			HSLog(HS_LOG_ERROR, "Failed to request level")
			HSHttpRelease(LevelRequest)
			LevelRequest = nil
			IsWaiting = false
		end
	end
end

function showGameOver()
	mgSetScale(gameOverCanvas, uiScale, uiScale, "linear", 0.1) 
	mgSetAlpha(gameOverCanvas, 1, "easeout", 0.1) 
	mgSetCanvasEnabled(levelCanvas, false)
end


function distanceToCanvasPos(distance)
	return -distance*1.06
end


function handleCommand(cmd)
	if cmd == "showoptions" then
		mgSetUiModal(optionsUi, true)
		mgSetCanvasEnabled(levelCanvas, false)
		
		mgSetAlpha(optionsCanvas, 0)
		mgSetScale(optionsCanvas, 1.5, 1.2)
		mgSetScale(optionsCanvas, uiScale, uiScale, "easeout", 0.15)
		mgSetAlpha(optionsCanvas, 1, "easeout", 0.15)

		mgSetScale(haloCircle, 1.5, 1.2)
		mgSetScale(haloCircle, uiScale, uiScale, "easeout", 0.15)
		mgSetAlpha(haloCircle, 0)
		mgSetAlpha(haloCircle, 1, "easeout", 0.05)
		mgRunDelayed('mgSetAlpha(haloCircle, 0, "easeout", 0.4)', 0.05)
		mgPlaySound(showSound)
		
	end

	if cmd == "hideoptions" then
		mgSetUiModal(optionsUi, false)
		mgSetCanvasEnabled(levelCanvas, true)
		
		mgSetScale(optionsCanvas, 0.2, 0.4, "easein", 0.15)
		mgSetAlpha(optionsCanvas, 0, "easein", 0.15)

		mgSetAlpha(haloCircle, 0)
		mgSetAlpha(haloCircle, 0, "easein", 0.1)
		mgSetScale(haloCircle, 0.2, 0.2, "easein", 0.15)
		mgPlaySound(hideSound)
	end


	if cmd == "showmore" then
		mgSetAlpha(moreUi, 0)
		mgSetScale(moreUi, 1.5, 1.2)
		mgSetScale(moreUi, uiScale, uiScale, "easeout", 0.15)
		mgSetAlpha(moreUi, 1, "easeout", 0.15)
		mgSetUiModal(moreUi, true)
		mgSetCanvasEnabled(levelCanvas, false)
		mgPlaySound(showSound)
		mgSetScale(haloCircle, 1.5, 1.2)
		mgSetScale(haloCircle, uiScale*1.12, uiScale*1.12, "easeout", 0.15)
		mgSetAlpha(haloCircle, 0)
		mgSetAlpha(haloCircle, 1, "easeout", 0.05)
		mgRunDelayed('mgSetAlpha(haloCircle, 0, "easeout", 0.4)', 0.05)
	end

	if cmd == "hidemore" then
		mgSetScale(moreUi, 0.2, 0.4, "easein", 0.15)
		mgSetAlpha(moreUi, 0, "easein", 0.15)
		mgSetUiModal(moreUi, false)
		mgSetCanvasEnabled(levelCanvas, true)
		mgPlaySound(hideSound)

		mgSetAlpha(haloCircle, 0)
		mgSetAlpha(haloCircle, 0, "easein", 0.1)
		mgSetScale(haloCircle, 0.2, 0.2, "easein", 0.15)
	end

	if startsWith(cmd, "level") then
		startLevelRequest()
-- 		selectedLevel = getSecond(cmd)
-- 		if selectedLevel == "0" then
-- 			selectedLevel = nil
-- 			mgSetCanvasEnabled(levelCanvas, false)
-- 			mgSetPos(levelCanvas, 0, 0, "cosine", 0.5)
-- 			mgCommand("level.start 0")
-- 		else
-- 			local i = tonumber(selectedLevel)
-- 			local score, streak = mgGetHighScore(i);
-- 			mgSetText(playMenuScore, score)
-- 			mgSetOrigo(playMenuScore, "center")
-- 			local balls = math.floor(streak/10)+1
-- 			if balls > 5 then balls = 5 end
-- 			mgSetCrop(playMenuStreak, 210*(balls-1), 0, 210*balls, 210)
-- 			mgSetOrigo(playMenuStreak, "center")
-- 			local lx, ly = mgGetPos(buttons[i+1])
-- 			local cx, cy = mgGetPos(levelCanvas)
-- 			mgSetPos(playMenuCanvas, lx, ly+30)
-- 			mgSetPos(playMenuCanvas, centerX, centerY, "easeout", 0.25)
-- 			mgSetAlpha(playMenuCanvas, 0)
-- 			mgSetAlpha(playMenuCanvas, 1, "easeout", 0.15)
-- 			mgSetScale(playMenuCanvas, 0.3, 0.3)
-- 			mgSetScale(playMenuCanvas, uiScale, uiScale, "easeout", 0.25)
-- 			mgSetUiModal(playMenu, true)
-- 			mgSetCanvasEnabled(levelCanvas, false)
-- 			mgSetPos(levelCanvas, distanceToCanvasPos(1000*i), 0, "easeout", 0.25)
-- 
-- 			mgSetPos(haloCircle, lx, ly+30)
-- 			mgSetPos(haloCircle, centerX, centerY, "easeout", 0.25)
-- 			mgSetScale(haloCircle, 0.3, 0.3)
-- 			mgSetScale(haloCircle, uiScale*0.86, uiScale*0.86, "easeout", 0.25)
-- 			mgSetAlpha(haloCircle, 0)
-- 			mgSetAlpha(haloCircle, 1, "easeout", 0.15)
-- 			mgRunDelayed('mgSetAlpha(haloCircle, 0, "easeout", 0.6)', 0.15)
-- 			mgPlaySound(showCpSound)
-- 		end
	end
	
	if cmd == "play" then
		mgCommand("level.start "..selectedLevel)
		mgSetScale(playMenuCanvas, 1.4, 1.4, "easein", 0.25)
		mgSetAlpha(playMenuCanvas, 0, "easein", 0.25)
		mgSetUiModal(playMenu, false)
		selectedLevel = nil
	end
	
	if cmd == "hideplaymenu" then
		mgSetScale(playMenuCanvas, 0.4, 0.4, "easein", 0.15)
		mgSetAlpha(playMenuCanvas, 0, "easein", 0.15)
		mgSetUiModal(playMenu, false)
		selectedLevel = nil
		mgSetCanvasEnabled(levelCanvas, true)
		mgPlaySound(hideSound)
	end
	
	if cmd == "showdebug" then
		mgSetScale(dbgMenu, 1, 1, "cosine", 0.1)
		mgSetUiModal(dbgMenu, true)
	end

	if cmd == "hidedebug" then
		mgSetScale(dbgMenu, 0, 0, "cosine", 0.1)
		mgSetUiModal(dbgMenu, false)
	end

	if cmd == "gameover" then
		gameOverShown = true
		local score = tonumber(mgGet("level.score"))
		trigShowRate=false
		if score > currentHighscore then
			mgSetCrop(gameOver, 0, 860, 860, 1720)
			if mgGet("player.rated") == "0" and score > 3000 and tonumber(mgGet("player.startcount")) > 2 then
				trigShowRate = true
			end
		else
			mgSetCrop(gameOver, 0, 0, 860, 860)
		end
		local mode = tonumber(mgGet("player.mode"))
		if score < 1000 or mode == MODE_COOP then
			mgSetScale(gameOverRestart, uiScale, uiScale)
			mgSetScale(gameOverContinue, 0, 0)
			mgSetAlpha(gameOverContinueText, 0)
		else
			mgSetScale(gameOverRestart, 0, 0)
			mgSetScale(gameOverContinue, uiScale, uiScale)
			mgSetAlpha(gameOverContinueText, 1)
			local cp = math.floor(score/1000)
			if cp > 12 then cp = 12 end
			continueLevel = cp
			if cp == 12 then
				mgSetText(gameOverContinueText, ";") -- endless
			else
				mgSetText(gameOverContinueText, cp)
			end
			mgSetOrigo(gameOverContinueText, "center")
		end
		mgSetOrigo(gameOver, "center")
		mgSetText(gameOverScore, "=" .. mgGet("level.score"));
		mgSetOrigo(gameOverScore, "center")
		mgSetUiModal(gameOverRestart, true)
		mgSetUiModal(gameOverContinue, true)
		mgRunDelayed("showGameOver()", 1.0)
	end

	if cmd == "hidegameover" then
		gameOverShown = false
		mgSetScale(gameOverCanvas, 0, 0, "easein", 0.15)
		mgSetAlpha(gameOverCanvas, 0, "easein", 0.15)
		mgSetUiModal(gameOverRestart, false)
		mgSetUiModal(gameOverContinue, false)
		mgSetCanvasEnabled(levelCanvas, true)
		if trigShowRate then trigShowRate=false handleCommand("showrate") end
	end
	
	if cmd == "showscore" then
		if mgGet("game.premium") == "1" and tonumber(mgGet("stats.distance")) > 0 then
			statsCounter = 0
		else
			statsCounter = 1000
		end
		mgPlaySound(scOpenSound)
		mgSetScale(scCanvas, 1, 1, "easeout", 0.15)
		mgSetAlpha(scCanvas, 1, "easeout", 0.15)
		mgSetUiModal(scGcIn, true)
		if scGcOut then
			mgSetUiModal(scGcOut, true)
		end
		mgSetUiModal(statsBlank, true)
		mgSetCanvasEnabled(levelCanvas, false)
		mgSetAlpha(glowLine, .5, "easeout", .1)
		mgSetScale(glowLine, 8, 11, "easeout", .1)
		glowT = 10
	end

	if cmd == "hidescore" then
		mgPlaySound(scOpenClose)
		mgSetScale(scCanvas, 1, 0, "easein", 0.15)
		mgSetAlpha(scCanvas, 0, "easein", 0.15)
		mgSetUiModal(scGcIn, false)
		mgSetUiModal(statsBlank, false)
		if scGcOut then
			mgSetUiModal(scGcOut, false)
		end
		mgSetCanvasEnabled(levelCanvas, true)
		mgSetAlpha(glowLine, 1)
		mgSetAlpha(glowLine, 0, "linear", .3)
		mgSetScale(glowLine, 8, 11)
		mgSetScale(glowLine, 8, 0.1, "easeout", 0.2)
		glowT = 15
	end
	
	if startsWith(cmd, "scmode") then
		scMode = getSecond(cmd)
	end
	
	if cmd == "activate" then
		local mode = tonumber(mgGet("player.mode"))
		if mode ~= MODE_ZEN and mode ~= MODE_VERSUS and mode ~= MODE_COOP then
			mgSetPos(levelCanvas, distanceToCanvasPos(tonumber(mgGet("level.distance"))), 0)
		end
		mgSetCanvasEnabled(levelCanvas, true)
	end

	if cmd == "showupgradedelayed" then
		mgRunDelayed('handleCommand("showupgrade")', 1.1)
		mgSetUiModal(upgradeBuy, true)
	end
	
	if cmd == "showupgrade" then
		mgPlaySound(showSound)
		mgSetAlpha(upgradeCanvas, 0)
		mgSetScale(upgradeCanvas, 1, 0.6)
		mgSetAlpha(upgradeCanvas, 1, "easeout", 0.15)
		mgSetScale(upgradeCanvas, 1, 1, "easeout", 0.15)
		mgSetUiModal(upgradeBuy, true)
		mgSetUiModal(upgradeRestore, true)
		mgSetCanvasEnabled(levelCanvas, false)
		mgSetScale(upgradeCheckpoints, 1.5, 1.5)
		mgSetAlpha(upgradeCheckpoints, 0)
		mgRunDelayed('mgSetScale(upgradeCheckpoints, 1, 1, "easeout", 0.25) mgSetAlpha(upgradeCheckpoints, 1, "easeout", 0.25)', 0.1)

		mgSetScale(upgradeGamemodes, 1.5, 1.5)
		mgSetAlpha(upgradeGamemodes, 0)
		mgRunDelayed('mgSetScale(upgradeGamemodes, 1, 1, "easeout", 0.25) mgSetAlpha(upgradeGamemodes, 1, "easeout", 0.25)', 0.25)
		
		mgSetScale(upgradeCloud, 1.5, 1.5)
		mgSetAlpha(upgradeCloud, 0)
		mgRunDelayed('mgSetScale(upgradeCloud, 1, 1, "easeout", 0.25) mgSetAlpha(upgradeCloud, 1, "easeout", 0.25)', 0.25)

		mgSetScale(upgradeStatistics, 1.5, 1.5)
		mgSetAlpha(upgradeStatistics, 0)
		mgRunDelayed('mgSetScale(upgradeStatistics, 1, 1, "easeout", 0.25) mgSetAlpha(upgradeStatistics, 1, "easeout", 0.25)', 0.4)
	end

	if cmd == "hideupgrade" then
		mgPlaySound(hideSound)
		mgSetUiModal(upgradeBuy, false)
		mgSetUiModal(upgradeRestore, false)
		mgSetAlpha(upgradeCanvas, 0, "easein", 0.15)
		mgSetScale(upgradeCanvas, 0.9, 0.7, "easein", 0.15)
		mgSetCanvasEnabled(levelCanvas, true)
	end
	
	if cmd == "facebook" then
		if platform == "ios" then
			mgCommand("game.url fb://profile/1447160805510492")
		else
			mgCommand("game.url http://www.facebook.com/smashhitgame")
		end
	end
	
	if cmd == "twitter" then
		mgCommand("game.url http://www.twitter.com/smashhitgame")
	end

	if cmd == "website" then
		mgCommand("game.url http://www.smashhitgame.com")
	end

	if cmd == "support" then
		mgCommand("game.url http://www.smashhitgame.com/support")
	end

	if cmd == "rate" then
		mgCommand("player.rate")
		if platform == "android" then
			mgCommand("game.url http://play.google.com/store/apps/details?id=com.mediocre.smashhit")
		end
		if platform == "ios" then
			mgCommand("game.url itms-apps://itunes.apple.com/app/id603527166?at=10l6dK")
		end
	end	

	if cmd == "moregames" then
		if platform == "android" then
			mgCommand("game.url http://www.smashhitgame.com/moregames_android")
		else
			mgCommand("game.url http://www.smashhitgame.com/moregames")
		end
	end	
	
	if cmd == "back" then
		if mgGetAlpha(optionsCanvas) > 0 then
			handleCommand("hideoptions")
		elseif mgGetAlpha(moreUi) > 0 then
			handleCommand("hidemore")
		elseif mgGetAlpha(scCanvas) > 0 then
			handleCommand("hidescore")
		elseif mgGetAlpha(upgradeCanvas) > 0 then
			handleCommand("hideupgrade")
		elseif mgGetAlpha(gameOverCanvas) > 0 then
			handleCommand("hidegameover")
		elseif mgGetAlpha(playMenuCanvas) > 0 then
			handleCommand("hideplaymenu")
		elseif mgGetAlpha(modeCanvas) > 0 then
			handleCommand("hidemode")
		elseif rate ~= -1 and mgGetAlpha(rate) > 0 then
			handleCommand("hiderate")
		else
			mgCommand("game.quit")
		end
	end

	if cmd == "hidenew" then
		mgSetUiModal(newUi, false)
		mgSetAlpha(newUi, 0, "linear", 0.2)
		mgSetCanvasEnabled(levelCanvas, true)
	end
	
	if cmd == "showmode" then
		mgSet("game.trymode", "2")
		mgCommand("game.saveConfig")
		mgRadioSelect(modeMenu, mgGet("player.mode"))
		mgSetAlpha(modeCanvas, 1, "easeout", 0.15)
		mgSetScale(modeCanvas, 1, 1, "easeout", 0.15)
		mgSetUiModal(modeMenu, true)
		mgPlaySound(showSound)
		mgSetAlpha(glowLine, .5, "easeout", .1)
		mgSetScale(glowLine, 8, 11, "easeout", .1)
		mgSetCanvasEnabled(levelCanvas, false)
		glowT = 10
	end
	
	if cmd == "hidemode" then
		mgSetAlpha(modeCanvas, 0, "easeout", 0.15)
		mgSetScale(modeCanvas, 1, 0.6, "easeout", 0.15)
		mgSetUiModal(modeMenu, false)
		mgPlaySound(hideSound)
		mgSetAlpha(glowLine, 1)
		mgSetAlpha(glowLine, 0, "linear", .3)
		mgSetScale(glowLine, 8, 11)
		mgSetScale(glowLine, 8, 0.1, "easeout", 0.2)
		glowT = 15
		mgSetCanvasEnabled(levelCanvas, true)
		return
	end

	if cmd == "newmode" then
		mgSetPos(levelCanvas, 0, 0)
		mgSet("game.lastdistance", 0)
		setCanvasMode()
		scrollFrame = 0
	end
	
	if cmd == "showrate" then
		mgCommand("player.rate")
		rate = mgCreateUi("rate.xml")
		mgSetOrigo(rate, "center")
		mgSetPos(rate, centerX, centerY)
		mgSetAlpha(rate, 0.01)
		mgSetScale(rate, 1.5, 1.2)
		mgSetScale(rate, uiScale, uiScale, "easeout", 0.15)
		mgSetAlpha(rate, 1, "easeout", 0.15)

		mgSetUiModal(rate, true)
		mgSetCanvasEnabled(levelCanvas, false)

		mgPlaySound(showSound)
	end
	
	if cmd == "hiderate" then
		mgSetUiModal(rate, false)
		mgSetCanvasEnabled(levelCanvas, true)
		
		mgSetScale(rate, 0.2, 0.4, "easein", 0.15)
		mgSetAlpha(rate, 0, "easein", 0.15)
		mgPlaySound(hideSound)
	end
	
	if cmd == "load" then
		load()
	end
	
	if cmd == "gameover_restart" then
		if rate == -1 or mgGetAlpha(rate) == 0 then
			mgCommand("level.start 0")
		end
	end
	
	if cmd == "gameover_continue" then
		if rate == -1 or mgGetAlpha(rate) == 0 then
			mgCommand("level.start " .. continueLevel)
		end
	end
	
	if cmd ~= "" and startsWith(cmd, "mode") then
		if mgGet("game.premium") == "1" then
			mgCommand("game.mode " .. getSecond(cmd))
			loadRanks()
			mgRunDelayed('handleCommand("hidemode")', 0.1)
		else
			if getSecond(cmd) ~= "classic" then
				handleCommand("hidemode")
				handleCommand("showupgrade")
			end
		end
	end
	
	if cmd == "checkads" then
		checkAds()
	end

	if cmd == "hideads" and ads_icon~=-1 then
		mgSetScale(ads_icon, 0.5, 0.5, "linear", 0.3)
		mgSetAlpha(ads_icon, 0, "linear", 0.3)
		mgCommand("player.adsshown")
	end
end


function checkAds()
	if mgGet("player.adsfront") == "1" and tonumber(mgGet("player.startcount")) > 2 then
		ads_icon = mgCreateUi("user://ads.xml")
		w,h = mgGetSize(ads_icon)
		mgSetOrigo(ads_icon, "center")
		mgSetPos(ads_icon, left+w/2, top+h/2)
	else
		ads_icon = -1
	end
end


