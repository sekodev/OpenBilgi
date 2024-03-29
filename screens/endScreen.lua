------------------------------------------------------------------------------
--
-- This file is part of OpenBilgi, a roguelike trivia game repository
--
-- For overview and more information on licensing please refer to README.md 
--
-- Home page: https://github.com/sekodev/OpenBilgi
--
-- Contact: info.sleepybug@gmail.com
--
------------------------------------------------------------------------------

--local composer = require ("libs.composer_alt")
local scene = composer.newScene()

local widget = require ("widget")
local particleDesigner = require( "libs.particleDesigner" )
local random = math.random

local mainGroup, menuGroup, scoreGroup, mapGroup, rateGroup, shareGroup, infoGroup

local sceneTransitionTime = composer.getVariable( "sceneTransitionTime" )
local sceneTransitionEffect = composer.getVariable( "sceneTransitionEffect" )

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local fontSize = contentHeightSafe / 15

local priceLockCoins = composer.getVariable( "priceLockCoins" )
local coinsAvailable = composer.getVariable( "coinsAvailable" )
local locksAvailable = composer.getVariable( "locksAvailable" )
local savedRandomSeed = composer.getVariable( "savedRandomSeed" )

local amountQuestionSingleGame = composer.getVariable( "amountQuestionSingleGame" )     --20
local amountQuestionSingleSet = composer.getVariable( "amountQuestionSingleSet" )   --5

local isRecordBroken = false
local isInteractionAvailable = false

local scoreHigh = composer.getVariable( "scoreHigh" )
local scoreCurrent = 0
local questionCurrent = 0

local statusGame = ""
local coinsEarned = 0
local coinsCompletedSet = composer.getVariable( "coinsCompletedSet" )

local frameButtonPlay, frameButtonSettings, frameButtonMainMenu, frameButtonConvert
local buttonLockQuestionSet
local textScore, labelScore
local textAwardCoinSet, textAwardCoinEarned, textAwardLock
local mapPin

local tableSoundFiles = {}
local tableTimers = {}
local tableCheckpoints = {}


local function cleanUp()
    tableTimers = utils.cancelTimers(tableTimers)
    transition.cancel( )

    if (#tableCheckpoints > 0) then
        for i = #tableCheckpoints, 1, -1 do
            tableCheckpoints[i] = {}
            table.remove( tableCheckpoints, i )
        end
    end
end

-- Handle touch events for every visible UI element
function handleTouch(event)
    if (event.phase == "began") then
        if (isInteractionAvailable) then
            local colorButtonOver = themeData.colorButtonOver
            local colorButtonFillTrue = themeData.colorButtonFillTrue
            local colorButtonFillWrong = themeData.colorButtonFillWrong
            local colorTextDefault = themeData.colorTextDefault
            local colorTextOver = themeData.colorTextOver
            local colorTextSelected = themeData.colorTextSelected

            if (event.target.id == "mainMenu" or 
                event.target.id == "leaderboard" or
                event.target.id == "restart" or
                event.target.id == "settings") then

                isInteractionAvailable = false

                -- Change the color of the button to indicate selection
                event.target:setFillColor( unpack(colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(colorTextOver) )
                event.target:setStrokeColor( unpack(colorButtonOver) )

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                local timeWaitChoice = 500
                local targetScreen = ""

                if (event.target.id == "mainMenu") then
                    targetScreen = "menuScreen"
                elseif (event.target.id == "leaderboard") then
                    targetScreen = "leaderboard"
                elseif (event.target.id == "restart") then
                    targetScreen = "gameScreen"
                    timeWaitChoice = 750

                    audio.fadeOut( { channel = channelMusicBackground, time = timeWaitChoice } )

                    -- if lock is enabled, show player that a lock is used
                    if (buttonLockQuestionSet.isActivated) then
                        tableTimers, locksAvailable = commonMethods.useLock(infoGroup, tableTimers, locksAvailable, menuGroup.textNumLocks)
                    end
                elseif (event.target.id == "settings") then
                    targetScreen = "settingScreen"
                end
                

                -- Wait some time before changing the scene
                -- One reason for this is the particle effects that we need to hide
                -- If particle effects are not properly handled, it doesn't look good
                -- Other reason is a design choice. It mimics the ingame action of choosing the answer
                local timerHighlightChoice = timer.performWithDelay( timeWaitChoice, function () 
                        event.target:setFillColor( unpack(colorButtonFillTrue) )
                        event.target.textLabel:setFillColor( unpack(colorTextSelected) )
                        event.target:setStrokeColor( unpack(colorButtonFillTrue) )

                        audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                        local timerChangeScene = timer.performWithDelay( timeWaitChoice, function () 
                                local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, 
                                    params = {callSource = "endScreen", scoreCurrent = scoreCurrent,
                                     isSetLocked = buttonLockQuestionSet.isActivated, statusGame = statusGame}}
                                composer.gotoScene( "screens." .. targetScreen, optionsChangeScene )
                            end, 1 )
                        table.insert( tableTimers, timerChangeScene )
                    end, 1 )
                table.insert( tableTimers, timerHighlightChoice )
            elseif (event.target.id == "shareSocial") then
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                commonMethods.showShareUI(shareGroup)
            elseif (event.target.id == "showStats") then
                isInteractionAvailable = false

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime,
                 params = {callSource = "endScreen", scoreCurrent = scoreCurrent, statusGame = statusGame}}
                composer.gotoScene( "screens.statsScreen", optionsChangeScene )
            elseif (event.target.id == "convertCurrency") then
                isInteractionAvailable = false

                -- Convert coins to locks if possible
                -- Else, if player doesn't have enough funds, show minimum number of coins needed to get a single(1) lock
                if (coinsAvailable >= priceLockCoins) then
                    local locksConverted = math.floor(coinsAvailable / priceLockCoins)
                    local coinsConverted = locksConverted * priceLockCoins
                    local coinsLeft = coinsAvailable - coinsConverted

                    if (locksConverted > 0) then
                        audio.play( tableSoundFiles["answerRight"], {channel = 2} )
                        event.target.textLabel:setFillColor( unpack(colorButtonFillTrue) )

                        local timeAnimationCurrency = 100
                        local timeWaitConversion = 1000

                        coinsAvailable = coinsLeft


                        local paramsCoins = { coinsAvailable = coinsAvailable, coinsConverted = coinsConverted }
                        local paramsAnimationValues = { timeAnimationCurrency = timeAnimationCurrency, timeWaitConversion = timeWaitConversion }

                        tableTimers, coinsAvailable = commonMethods.showCoinsConverted(menuGroup, tableTimers,
                         paramsCoins, paramsAnimationValues)


                        local timerWaitShowLocksPurchased = timer.performWithDelay( timeWaitConversion, function ()
                                local paramsLocks = { locksAvailable = locksAvailable, locksConverted = locksConverted }

                                tableTimers, locksAvailable = commonMethods.showLocksConverted( menuGroup, frameButtonPlay, tableTimers,
                                 event.target, paramsLocks, paramsAnimationValues )
                            end, 1 )
                        table.insert( tableTimers, timerWaitShowLocksPurchased )

                        isInteractionAvailable = true
                    end
                else
                    isInteractionAvailable = true

                    event.target.isAvailable = false -- Take defensive action, change availability to false
                    commonMethods.showConversionAvailability(event.target, tableSoundFiles, infoGroup, priceLockCoins, frameButtonPlay)
                end
            end
        end
    elseif (event.phase == "ended" or "cancelled" == event.phase) then
        if (isInteractionAvailable) then
            if (event.target.id == "shareSocial") then
                event.target:setFillColor( unpack(themeData.colorButtonDefault) )
            elseif (event.target.id == "lockQuestionSet") then
                commonMethods.switchLock(event.target, infoGroup, locksAvailable, 
                    tableSoundFiles["lockQuestionSet"], fontLogo)
            end
        end
    end
    return true
end

-- Start fireworks on high score
local function shootFireworks()
    local numFireworks = random(3, 5)

    for i = 1, numFireworks do
        local timerFire = timer.performWithDelay( 1000 * (i - 1), function () 
                local emitterFireworks = particleDesigner.newEmitter( "assets/particleFX/fireworks.json" )
                emitterFireworks.x = random(contentWidthSafe)
                emitterFireworks.y = random(contentHeightSafe)
                scoreGroup:insert(emitterFireworks)

                audio.play( tableSoundFiles["fireworks"], {channel = 2, loops = numFireworks} )
            end, 1 )
        table.insert(tableTimers, timerFire)
    end
end

-- Show number of locks the player earned in this run
local function showLocksEarned()
    if (textAwardLock ~= nil) then
        transition.to( textAwardLock, { time = 500, y = menuGroup.textNumLocks.y, alpha = 0, onComplete = function ()
            locksAvailable = locksAvailable + 1
            menuGroup.textNumLocks.text = locksAvailable
        end } )
    end
end

-- Show number of coins player earned in this run
local function showCoinsEarned()
    transition.to( textAwardCoinEarned, { time = 500, y = menuGroup.textNumCoins.y, alpha = 0, onComplete = function ()
        coinsAvailable = coinsAvailable + coinsEarned

        local currencyShort, currencyAbbreviation = commonMethods.formatCurrencyString(coinsAvailable)
        menuGroup.textNumCoins.text = currencyShort .. currencyAbbreviation

        commonMethods.adjustConvertElements(menuGroup, frameButtonPlay)
        
        -- If player completes a set successfully, will earn a fixed amount of coins(coinsCompletedSet) + coinsEarned
        if (textAwardCoinSet) then
            transition.to( textAwardCoinSet, { time = 500, y = menuGroup.textNumCoins.y, alpha = 0, onComplete = function ()
                coinsAvailable = coinsAvailable + coinsCompletedSet

                local currencyShort, currencyAbbreviation = commonMethods.formatCurrencyString(coinsAvailable)
                menuGroup.textNumCoins.text = currencyShort .. currencyAbbreviation

                commonMethods.adjustConvertElements(menuGroup, frameButtonPlay)
            end } )
        end
    end } )
end

-- Show player progress in single run, x / 20(amountQuestionSingleGame) questions
local function showProgressMade()
    -- Check if progress map is created
    if (mapPin) then
        transition.to( mapPin, { time = 1000, x = mapPin.xTarget, onComplete = function () 
                -- If (questionCurrent > 1) then     -- test line
                -- Shake pin if player is more than 3/4 of the way
                if (questionCurrent >= amountQuestionSingleGame - amountQuestionSingleSet) then
                    local timeShake = 150
                    local rotationShake = 40

                    transition.to( mapPin, { time = timeShake, xScale = 1.5, yScale = 1.5, onComplete = function ()
                            transition.to( mapPin, { time = timeShake, rotation = rotationShake, onComplete = function ()
                                transition.to( mapPin, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                        transition.to( mapPin, { time = timeShake, rotation = rotationShake, onComplete = function ()
                                            transition.to( mapPin, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                                transition.to( mapPin, { time = timeShake, xScale = 1, yScale = 1, onComplete = function ()
                                                        mapPin.rotation = 0
                                                    end })
                                                end })
                                        end })
                                    end })
                            end })
                        end })
                end
            end } )
    end
end

-- When every UI element becomes visible on the screen, show progress map and then, player progress
local function showProgressMap()
    if (mapGroup.numChildren > 0) then
        transition.to( mapGroup, { time = 250, alpha = 1, onComplete = function ()
                showProgressMade()
            end} )
    end
end

-- Show player that they scored better than before
local function showHighScore()
    shootFireworks()

    transition.to( textScore, {time = 2000, xScale = 1, yScale = 1, onComplete = function () 
            transition.to( labelScore, {time = 1000, xScale = 1, yScale = 1, alpha = 1, onComplete = function () 
                    showProgressMap()
                    
                    transition.to( menuGroup, {time = 250, alpha = 1, onComplete = function ()
                            isInteractionAvailable = true

                            local timerInformation = timer.performWithDelay( 1000, function ()
                                    showLocksEarned()
                                    showCoinsEarned()
                                end, 1 )
                            table.insert( tableTimers, timerInformation )
                        end} )
                end} )
        end} )
end

local function checkHighScore()
    if (scoreCurrent > scoreHigh) then
        isRecordBroken = true

        composer.setVariable( "scoreHigh", scoreCurrent )
        savePreferences()
    end
end

local function createProgressMap(yButtonTop)
    -- Hide progress map if record is broken
    -- It will be made visible after fireworks are over
    if (isRecordBroken) then
        mapGroup.alpha = 0
    end

    local colorTextDefault = themeData.colorTextDefault

    local mapLine = display.newRect( mapGroup, display.contentCenterX, 0, contentWidthSafe / 1.2, 15 )
    mapLine:setFillColor( unpack(colorTextDefault) )
    mapLine.y = yButtonTop - mapLine.height


    -- Add +1 to take starting point into the mix
    local amountCheckpoints = (amountQuestionSingleGame / amountQuestionSingleSet) + 1
    local widthCheckpoint = 10
    local widthBetweenCheckpoints = mapLine.width / 4

    for i = 1, amountCheckpoints do
        local mapCheckpoint = display.newRect( mapGroup, 0, 0, widthCheckpoint, mapLine.height * 2 )
        mapCheckpoint:setFillColor( unpack(colorTextDefault) )
        if (i == 1) then
            mapCheckpoint.x = mapLine.x - mapLine.width / 2 + mapCheckpoint.width / 2
        else
            mapCheckpoint.x = tableCheckpoints[i - 1].x + widthBetweenCheckpoints
        end

        mapCheckpoint.y = mapLine.y

        table.insert(tableCheckpoints, mapCheckpoint) 
    end

    local widthMapPin = mapLine.height * 3
    mapPin = display.newImageRect( mapGroup, "assets/menu/pinMap.png", widthMapPin, widthMapPin )
    mapPin:setFillColor( unpack(themeData.colorPadlock) )
    mapPin.x = mapLine.x - mapLine.width / 2 + widthCheckpoint / 2
    mapPin.y = mapLine.y - mapLine.height / 2 - mapPin.height

    local xPositionMapAbsolute = (questionCurrent * mapLine.width) / amountQuestionSingleGame
    mapPin.xTarget = mapLine.x - mapLine.width / 2 + widthCheckpoint / 2 + xPositionMapAbsolute
end

local function createScoreElements()
    local optionsTextScore = { text = scoreCurrent, font = fontLogo, fontSize = fontSize }
    textScore = display.newText( optionsTextScore )
    textScore:setFillColor( unpack( themeData.colorTextDefault ) )
    textScore.x = display.contentCenterX
    if (mapPin ~= nil) then
        textScore.y = mapPin.y - mapPin.height / 2 - textScore.height
    else
        textScore.y = frameButtonPlay.y - frameButtonPlay.height / 2 - textScore.height * 1.5
    end
    scoreGroup:insert(textScore)

    local optionsLabelScore = { text = sozluk.getString("score"), font = fontLogo, fontSize = fontSize / 1.1 }
    labelScore = display.newText( optionsLabelScore )
    labelScore:setFillColor( unpack(themeData.colorButtonFillWrong) )
    labelScore.x = display.contentCenterX
    labelScore.y = textScore.y - textScore.height / 2 - labelScore.height / 1.5
    scoreGroup:insert(labelScore)


    if (isRecordBroken) then
        textScore.xScale, textScore.yScale = contentHeightSafe / 3, textScore.xScale

        labelScore.text = sozluk.getString("highScore")
        labelScore.alpha = 0
        labelScore.xScale, labelScore.yScale = textScore.xScale, textScore.yScale
    end
end

local function createMenuElements()
    local background = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )


    local widthUIButton = contentWidthSafe / 9
    local heightUIButton = widthUIButton

    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonStroke = themeData.colorButtonStroke
    local colorPadlock = themeData.colorPadlock

    local optionsButtonShare = 
    {
        id = "shareSocial",
        defaultFile = "assets/menu/share.png",
        width = widthUIButton,
        height = heightUIButton,
        onEvent = handleTouch,
    }
    local buttonShare = widget.newButton( optionsButtonShare )
    buttonShare:setFillColor( unpack(colorButtonDefault) )
    buttonShare.x = contentWidthSafe - buttonShare.width / 1.2
    buttonShare.y = contentHeightSafe - buttonShare.height / 1.2
    menuGroup:insert(buttonShare)

    local optionsButtonStats = 
    {
        id = "showStats",
        defaultFile = "assets/menu/stats.png",
        width = widthUIButton,
        height = heightUIButton,
        onEvent = handleTouch,
    }
    local buttonStats = widget.newButton( optionsButtonStats )
    buttonStats:setFillColor( unpack(colorButtonDefault) )
    buttonStats.x = buttonStats.width / 1.2
    buttonStats.y = contentHeightSafe - buttonStats.height / 1.2
    menuGroup:insert(buttonStats)

    frameButtonMainMenu = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonMainMenu.id = "mainMenu"
    frameButtonMainMenu:setFillColor( unpack( colorButtonFillDefault ) )
    frameButtonMainMenu.strokeWidth = strokeWidthButtons
    frameButtonMainMenu:setStrokeColor( unpack( colorButtonStroke ) )
    frameButtonMainMenu:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonMainMenu )

    local optionsLabelMainMenu = { text = sozluk.getString("mainMenu"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonMainMenu.textLabel = display.newText( optionsLabelMainMenu )
    frameButtonMainMenu.textLabel:setFillColor( unpack( colorTextDefault ) )
    frameButtonMainMenu.textLabel.x = frameButtonMainMenu.x
    menuGroup:insert(frameButtonMainMenu.textLabel)

    frameButtonMainMenu.height = frameButtonMainMenu.textLabel.height * 2
    frameButtonMainMenu.y = buttonShare.y - buttonShare.height / 2 - frameButtonMainMenu.height
    frameButtonMainMenu.textLabel.y = frameButtonMainMenu.y

    frameButtonSettings = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, frameButtonMainMenu.height, cornerRadiusButtons )
    frameButtonSettings.id = "settings"
    frameButtonSettings:setFillColor( unpack( colorButtonFillDefault ) )
    frameButtonSettings.strokeWidth = strokeWidthButtons
    frameButtonSettings:setStrokeColor( unpack( colorButtonStroke ) )
    frameButtonSettings.y = frameButtonMainMenu.y - frameButtonMainMenu.height / 2 - frameButtonSettings.height / 1.2
    frameButtonSettings:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonSettings )

    local optionsLabelSettings = { text = sozluk.getString("settings"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonSettings.textLabel = display.newText( optionsLabelSettings )
    frameButtonSettings.textLabel:setFillColor( unpack( colorTextDefault ) )
    frameButtonSettings.textLabel.x, frameButtonSettings.textLabel.y = frameButtonSettings.x, frameButtonSettings.y
    menuGroup:insert(frameButtonSettings.textLabel)

    frameButtonPlay = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, frameButtonSettings.height * 1.5, cornerRadiusButtons )
    frameButtonPlay.id = "restart"
    frameButtonPlay:setFillColor( unpack( colorButtonFillDefault ) )
    frameButtonPlay.strokeWidth = strokeWidthButtons * 3
    frameButtonPlay:setStrokeColor( unpack( colorButtonStroke ) )
    frameButtonPlay.y = frameButtonSettings.y - frameButtonSettings.height / 2 - frameButtonPlay.height
    frameButtonPlay:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonPlay )


    -- When player fails to complete a set successfully, show "Restart" button
    -- When player is successful, show "Continue" to convey the message that there is more
    local labelSettings = sozluk.getString("restart")
    if (statusGame == "success" or statusGame == "successSetUnlocked" or 
        statusGame == "successSetNA" or statusGame == "successSetCompletedBefore" or
        statusGame == "successEndgame") then
        labelSettings = sozluk.getString("continue")
    end
    local optionsLabelSettings = { text = labelSettings, 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonPlay.textLabel = display.newText( optionsLabelSettings )
    frameButtonPlay.textLabel:setFillColor( unpack( colorTextDefault ) )
    frameButtonPlay.textLabel.x, frameButtonPlay.textLabel.y = frameButtonPlay.x, frameButtonPlay.y
    menuGroup:insert(frameButtonPlay.textLabel)

    if (isRecordBroken) then
        menuGroup.alpha = 0
    else
        isInteractionAvailable = true
    end


    buttonLockQuestionSet = display.newImageRect( menuGroup, "assets/menu/padlock.png", widthUIButton, heightUIButton )
    buttonLockQuestionSet:setFillColor( unpack(colorPadlock) )
    buttonLockQuestionSet.id = "lockQuestionSet"
    buttonLockQuestionSet.isActivated = false
    buttonLockQuestionSet.x = frameButtonPlay.x + frameButtonPlay.width / 2 + buttonLockQuestionSet.width / 1.5
    buttonLockQuestionSet.y = frameButtonPlay.y
    buttonLockQuestionSet.alpha = 0.3
    buttonLockQuestionSet.alphaInactive = buttonLockQuestionSet.alpha
    buttonLockQuestionSet:addEventListener( "touch", handleTouch )


    --coinsAvailable = 250

    -- Create coin-lock conversion UI
    frameButtonConvert = display.newRoundedRect( display.contentCenterX, 0, 0, 0, cornerRadiusButtons )
    frameButtonConvert.id = "convertCurrency"
    frameButtonConvert.isAvailable = false -- This will be 'true' if player has enough coins to get a lock
    frameButtonConvert:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonConvert:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonConvert )

    local optionsLabelConvert = { text = "<<", 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons * 1.5 }
    frameButtonConvert.textLabel = display.newText( optionsLabelConvert )
    frameButtonConvert.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonConvert.textLabel.x, frameButtonConvert.textLabel.y = frameButtonConvert.x, frameButtonConvert.y
    menuGroup:insert(frameButtonConvert.textLabel)

    frameButtonConvert.width = contentWidthSafe
    frameButtonConvert.height = frameButtonConvert.textLabel.height


    -- Lock asset is created, will be hidden if not available
    menuGroup.imageLock = display.newImageRect( menuGroup, "assets/menu/padlock.png", widthUIButton / 1.5, heightUIButton / 1.5 )
    menuGroup.imageLock:setFillColor( unpack(colorPadlock) )
    menuGroup.imageLock.x = frameButtonPlay.x - frameButtonPlay.width / 2 + menuGroup.imageLock.width / 2
    menuGroup.imageLock.y = display.safeScreenOriginY + menuGroup.imageLock.height / 1.5

    local fontSizeCurrency = menuGroup.imageLock.height / 1.2

    local optionsNumLocks = { text = locksAvailable, font = fontLogo, fontSize = fontSizeCurrency }
    menuGroup.textNumLocks = display.newText( optionsNumLocks )
    menuGroup.textNumLocks:setFillColor( unpack(colorTextDefault) )
    menuGroup.textNumLocks.x = menuGroup.imageLock.x + menuGroup.imageLock.width + menuGroup.textNumLocks.width / 2
    menuGroup.textNumLocks.y = menuGroup.imageLock.y
    menuGroup:insert(menuGroup.textNumLocks)


    -- Currency will be formatted for better looks
    local currencyShort, currencyAbbreviation = commonMethods.formatCurrencyString(coinsAvailable)
    local optionsNumCoins = { text = currencyShort .. currencyAbbreviation, font = fontLogo, fontSize = fontSizeCurrency }
    menuGroup.textNumCoins = display.newText( optionsNumCoins )
    menuGroup.textNumCoins:setFillColor( unpack(colorTextDefault) )
    menuGroup.textNumCoins.x = frameButtonPlay.x + frameButtonPlay.width / 2 - menuGroup.textNumCoins.width / 2
    menuGroup.textNumCoins.y = menuGroup.imageLock.y
    menuGroup:insert(menuGroup.textNumCoins)

    menuGroup.imageCoin = display.newCircle( menuGroup, 0, menuGroup.imageLock.y, menuGroup.imageLock.width / 2 )
    menuGroup.imageCoin:setFillColor( unpack( colorButtonOver ) )
    menuGroup.imageCoin.x = menuGroup.textNumCoins.x - menuGroup.textNumCoins.width / 2 - menuGroup.imageCoin.width / 1.5
    menuGroup.imageCoin.y = menuGroup.textNumCoins.y

    menuGroup.imageCoin.symbolCurrency = display.newRect( menuGroup, menuGroup.imageCoin.x, menuGroup.imageCoin.y, menuGroup.imageCoin.width / 3, menuGroup.imageCoin.height / 3 )
    menuGroup.imageCoin.symbolCurrency:setFillColor( unpack( themeData.colorBackground ) )
    menuGroup.imageCoin.symbolCurrency.rotation = 45


    -- Indicator elements are created here, will be used after convert button(frameButtonConvert) is pressed
    local optionsLocksConverted = { text = "+ 0", font = fontLogo, fontSize = fontSizeCurrency }
    menuGroup.textLocksConverted = display.newText( optionsLocksConverted )
    menuGroup.textLocksConverted:setFillColor( unpack(colorTextDefault) )
    menuGroup.textLocksConverted.x = menuGroup.textNumLocks.x - menuGroup.textLocksConverted.width / 2
    menuGroup.textLocksConverted.y = display.safeScreenOriginY + (menuGroup.imageLock.height / 1.5) * 4
    menuGroup.textLocksConverted.yTarget = menuGroup.textNumLocks.y
    menuGroup.textLocksConverted.alpha = 0
    menuGroup:insert(menuGroup.textLocksConverted)

    local optionsCoinsConverted = { text = "- 0", font = fontLogo, fontSize = fontSizeCurrency }
    menuGroup.textCoinsConverted = display.newText( optionsCoinsConverted )
    menuGroup.textCoinsConverted:setFillColor( unpack(colorTextDefault) )
    menuGroup.textCoinsConverted.x = menuGroup.textNumCoins.x - menuGroup.textCoinsConverted.width / 2
    menuGroup.textCoinsConverted.y = menuGroup.textNumCoins.y
    menuGroup.textCoinsConverted.yTarget = menuGroup.textLocksConverted.y
    menuGroup.textCoinsConverted.alpha = 0
    menuGroup.textCoinsConverted.xScale, menuGroup.textCoinsConverted.yScale = 0.01, 0.01
    menuGroup:insert(menuGroup.textCoinsConverted)

    frameButtonConvert.y = menuGroup.imageCoin.y
    frameButtonConvert.textLabel.y = frameButtonConvert.y


    local optionsCoinAwardEarned = { text = "+ " .. coinsEarned, font = fontLogo, fontSize = fontSizeCurrency }
    textAwardCoinEarned = display.newText( optionsCoinAwardEarned )
    textAwardCoinEarned:setFillColor( unpack( colorTextDefault ) )
    textAwardCoinEarned.x = menuGroup.textNumCoins.x
    textAwardCoinEarned.y = menuGroup.textNumCoins.y + menuGroup.textNumCoins.height / 2 + textAwardCoinEarned.height / 1.5
    menuGroup:insert(textAwardCoinEarned)

    if (coinsEarned <= 0) then
        textAwardCoinEarned.alpha = 0
    end

    -- If a set is completed, there is a %25 chance that a lock will be awarded
    if (statusGame == "successSetUnlocked" or statusGame == "successSetNA" or 
        statusGame == "successSetCompletedBefore" or statusGame == "successEndgame") then
        local chanceEarnLocks = 25 -- %25
        local randomChanceLocks = random(1, 100)
        if (randomChanceLocks <= chanceEarnLocks) then
            local optionsLockAward = { text = "+1", font = fontLogo, fontSize = fontSizeCurrency }
            textAwardLock = display.newText( optionsLockAward )
            textAwardLock:setFillColor( unpack( colorTextDefault ) )
            textAwardLock.x = menuGroup.textNumLocks.x
            textAwardLock.y = textAwardCoinEarned.y
            menuGroup:insert(textAwardLock)
        end

        local optionsCoinAwardSet = { text = "+ " .. coinsCompletedSet, font = fontLogo, fontSize = fontSizeCurrency }
        textAwardCoinSet = display.newText( optionsCoinAwardSet )
        textAwardCoinSet:setFillColor( unpack( colorTextDefault ) )
        textAwardCoinSet.x = menuGroup.textNumCoins.x
        textAwardCoinSet.y = textAwardCoinEarned.y + textAwardCoinEarned.height / 2 + textAwardCoinSet.height / 1.5
        menuGroup:insert(textAwardCoinSet)
    end


    -- Show lock icon if a save file is available
    local lastRandomSeed = composer.getVariable( "lastRandomSeed" )
    if (lastRandomSeed == 0 or savedRandomSeed ~= 0) then
        buttonLockQuestionSet.alpha = 0
    end
end

local function handleRatingTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "rateOK") then
            composer.setVariable( "askedRateGame", true )
            savePreferences()
            
            utils.clearDisplayGroup(rateGroup)
            utils.showRateUI(composer.getVariable( "idAppStore" ))
        elseif (event.target.id == "rateLater") then
            -- This option is NOT used to ask for ratings later
            composer.setVariable( "askedRateGame", true )
            savePreferences()

            utils.clearDisplayGroup(rateGroup)
        elseif (event.target.id == "sendFeedback") then
            composer.setVariable( "askedRateGame", true )
            savePreferences()

            utils.clearDisplayGroup(rateGroup)


            local currentVersion = composer.getVariable( "currentVersion" )

            local mailAddress = composer.getVariable("emailSupport")
            local mailSubject = sozluk.getString("sendSupportMailSubject")
            local mailBody = sozluk.getString("sendSupportMailVersionInformation") .. ": " .. currentVersion .. "\n\n"
             .. sozluk.getString("sendSupportMailBody") .. "\n\n"

            utils.showMailUI(mailAddress, mailSubject, mailBody)
        end
    end
    return true
end

-- Show a dialog box asking to rate the game
-- This is only shown once. After that, game only shows a rate button and leaves it up to the player
function createAskRatingElements()
    local backgroundShade = display.newRect( rateGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .9
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )


    local fontSizeQuestion = contentHeightSafe / 30

    local frameQuestionRating = display.newRect( rateGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameQuestionRating:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local optionsTextRating = { text = sozluk.getString("ratingAsk"), 
        width = frameQuestionRating.width / 1.1, height = 0, align = "center", font = fontLogo, fontSize = fontSizeQuestion }
    frameQuestionRating.textLabel = display.newText( optionsTextRating )
    frameQuestionRating.textLabel:setFillColor( unpack(themeData.colorBackground) )
    frameQuestionRating.textLabel.x = frameQuestionRating.x
    rateGroup:insert(frameQuestionRating.textLabel)


    local widthRateButtons = frameQuestionRating.width / 1.1
    local heightRateButtons = contentHeightSafe / 10
    local distanceChoices = heightRateButtons / 5
    local fontSizeChoices = fontSizeQuestion / 1.1

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local optionsButtonSendFeedback = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthRateButtons,
        height = heightRateButtons,
        cornerRadius = cornerRadiusButtons,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        label = sozluk.getString("ratingFeedback"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        id = "sendFeedback",
        onEvent = handleRatingTouch,
    }
    local buttonSendFeedback = widget.newButton( optionsButtonSendFeedback )
    buttonSendFeedback.x = display.contentCenterX
    rateGroup:insert( buttonSendFeedback )

    local optionsButtonAskLater = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthRateButtons,
        height = heightRateButtons,
        cornerRadius = cornerRadiusButtons,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        label = sozluk.getString("ratingLater"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        id = "rateLater",
        onEvent = handleRatingTouch,
    }
    local buttonAskLater = widget.newButton( optionsButtonAskLater )
    buttonAskLater.x = display.contentCenterX
    rateGroup:insert( buttonAskLater )

    local optionsButtonRateOK = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthRateButtons,
        height = heightRateButtons,
        cornerRadius = cornerRadiusButtons,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        label = sozluk.getString("ratingOK"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        id = "rateOK",
        onEvent = handleRatingTouch,
    }
    local buttonRateOK = widget.newButton( optionsButtonRateOK )
    buttonRateOK.x = display.contentCenterX
    rateGroup:insert( buttonRateOK )


    frameQuestionRating.height = frameQuestionRating.textLabel.height + buttonRateOK.height + buttonAskLater.height + buttonSendFeedback.height + distanceChoices * 5
    frameQuestionRating.y = display.contentCenterY
    frameQuestionRating.textLabel.y = frameQuestionRating.y - frameQuestionRating.height / 2 + frameQuestionRating.textLabel.height / 1.5
    buttonSendFeedback.y = (frameQuestionRating.y + frameQuestionRating.height / 2) - buttonSendFeedback.height / 2 - distanceChoices
    buttonAskLater.y = buttonSendFeedback.y - heightRateButtons - distanceChoices
    buttonRateOK.y = buttonAskLater.y - heightRateButtons - distanceChoices
end

-- Saves what player earned in this session(coins and locks)
local function savePlayerEarnings()
    local coinsPlayer = coinsAvailable

    coinsPlayer = coinsPlayer + coinsEarned
    if (textAwardCoinSet) then
        coinsPlayer = coinsPlayer + coinsCompletedSet 
    end

    composer.setVariable( "coinsAvailable", coinsPlayer )

    -- Collect coins total information for stats screen
    local coinsTotal = composer.getVariable( "coinsTotal" ) + coinsEarned
    composer.setVariable( "coinsTotal", coinsTotal )


    local locksPlayer = locksAvailable

    if (textAwardLock) then
        locksPlayer = locksPlayer + 1

        composer.setVariable( "locksAvailable", locksPlayer )
    end

    savePreferences()
end

function scene:create( event )
    mainGroup = self.view

    menuGroup = display.newGroup( )
    scoreGroup = display.newGroup( )
    mapGroup = display.newGroup( )
    rateGroup = display.newGroup( )
    shareGroup = display.newGroup( )
    infoGroup = display.newGroup( )

    if (event.params) then
        if (event.params["scoreCurrent"]) then
            scoreCurrent = event.params["scoreCurrent"]
        end

        if (event.params["questionCurrent"]) then
            questionCurrent = event.params["questionCurrent"]
        end

        if (event.params["statusGame"]) then
            statusGame = event.params["statusGame"]
        end

        if (event.params["coinsEarned"]) then
            coinsEarned = event.params["coinsEarned"]
        end
    end

    priceLockCoins = commonMethods.calculateLockPrice(priceLockCoins)

    local tableFileNames = { "answerChosen.wav", "answerRight.wav", "fireworks.wav", "lockQuestionSet.wav" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)
    
    checkHighScore()

    createMenuElements()

    if (statusGame == "fail") then
        -- Check if player is halfway through and not completed (defensive)
        -- if (questionCurrent > 0) then
        if (questionCurrent >= amountQuestionSingleGame / 2 and questionCurrent < amountQuestionSingleGame) then
            local yButtonTop = frameButtonPlay.y - frameButtonPlay.height
            createProgressMap(yButtonTop)
        end
    end

    createScoreElements()

    mainGroup:insert(menuGroup)
    mainGroup:insert(scoreGroup)
    mainGroup:insert(mapGroup)
    mainGroup:insert(rateGroup)
    mainGroup:insert(shareGroup)
    mainGroup:insert(infoGroup)
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()
        composer.setVariable("currentAppScene", "endScreen")

        if (event.params) then
            if (event.params["callSource"] == "gameScreen") then
                -- Increase volume back to level set by the user
                -- We do this because we lower the volume in gameScreen when player sees visual cue of time remaining
                channelMusicBackground = audio.play(streamMusicBackground, {channel = channelMusicBackground, loops = -1})
                audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
            end
        end


        local gamesPlayed = composer.getVariable( "gamesPlayed" )
        local askedRateGame = composer.getVariable( "askedRateGame" )

        savePlayerEarnings()

        -- Check if current score is better than all time high
        -- If player beats a record, show fireworks
        if (isRecordBroken) then
            showHighScore()
        else
            -- If player wasn't asked to rate the game before, ask for rating
            if (not askedRateGame) then
                if (gamesPlayed % 10 == 0) then
                    createAskRatingElements()
                end
            end

            local timerInformation = timer.performWithDelay( 1000, function () 
                    showLocksEarned()
                    showCoinsEarned()
                    showProgressMade()
                end, 1 )
            table.insert( tableTimers, timerInformation )
        end


        -- Start checking for conversion availability
        -- If minimum number of coins are available to purchase a single(1) lock, vibration animation will start
        -- Animation won't stop until conversion is triggered
        local timerConversionCheck
        timerConversionCheck = timer.performWithDelay( 3000, function ()
                if (coinsAvailable >= priceLockCoins) then
                    frameButtonConvert.isAvailable = true
                    commonMethods.showConversionAvailability(frameButtonConvert, tableSoundFiles, infoGroup, priceLockCoins, frameButtonPlay)
                else
                    frameButtonConvert.isAvailable = false

                    timer.cancel(timerConversionCheck)
                    timerConversionCheck = nil
                end
            end, -1 )
        table.insert( tableTimers, timerConversionCheck )
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        cleanUp()
    elseif ( phase == "did" ) then
        tableSoundFiles = utils.unloadSoundFX(tableSoundFiles)
    end
end

function scene:destroy( event )
    
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene