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

local composer = require ("libs.composer_alt")
local scene = composer.newScene()

local widget = require ("widget")

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

local mainGroup, statsGroup, resetGroup

local containerStats

local menuSeparator, yLimitBottom

local callSource
local scoreCurrent = 0
local statusGame = ""

local tableSoundFiles = {}


local function moveStats()
    -- Stop moving statistics elements when scene is changed
    if ( composer.getVariable("currentAppScene") == "menuScreen" ) then
        return
    end

    -- Move stats elements up and down
    -- Reverse movement speed when container y limits are hit
    for i = 1, containerStats.numChildren do
        if (containerStats.movementSpeed < 0) then  -- moving down
            if (i == containerStats.numChildren) then
                if (containerStats[i].y + containerStats[i].height + containerStats.movementSpeed < containerStats.height) then                
                    containerStats.movementSpeed = 0

                    timer.performWithDelay( 1000, function () 
                            containerStats.movementSpeed = containerStats.ySpeed
                        end, 1 )
                else
                    containerStats[i].y = containerStats[i].y + containerStats.movementSpeed
                end
            else
                containerStats[i].y = containerStats[i].y + containerStats.movementSpeed
            end
        elseif (containerStats.movementSpeed > 0) then  -- moving up
            if (i == 1) then
                if (containerStats[i].y + containerStats.movementSpeed > containerStats[i].height) then
                    containerStats.movementSpeed = 0

                    timer.performWithDelay( 1000, function () 
                            containerStats.movementSpeed = -containerStats.ySpeed
                        end, 1 )
                else
                    containerStats[i].y = containerStats[i].y + containerStats.movementSpeed
                end
            else
                containerStats[i].y = containerStats[i].y + containerStats.movementSpeed
            end
        end        
    end
end

local function clearDisplayGroup(targetGroup)
    for i = targetGroup.numChildren, 1, -1 do
        display.remove( targetGroup[i] )
        targetGroup[i] = nil
    end
end

local function handleConfirmationTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "resetStatsConfirm") then
            -- Resetting statistics takes player back to logoScreen
            resetStatistics()

            local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene}
            composer.gotoScene( "screens.logoScreen", optionsChangeScene )
        elseif (event.target.id == "resetStatsDeny") then
            clearDisplayGroup(resetGroup)
        end
    end
    return true
end

-- Show confirmation warning for statistics reset
local function showResetConfirmation()
    local backgroundShade = display.newRect( resetGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .9
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local fontSizeQuestion = display.safeActualContentHeight / 30

    local frameQuestionReset = display.newRect( resetGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth / 1.1, 0 )
    frameQuestionReset:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local optionsTextReset = { text = sozluk.getString("resetStatsAsk"), 
        width = frameQuestionReset.width / 1.1, height = 0, align = "center", font = fontLogo, fontSize = fontSizeQuestion }
    frameQuestionReset.textLabel = display.newText( optionsTextReset )
    frameQuestionReset.textLabel:setFillColor( unpack(themeData.colorBackground) )
    frameQuestionReset.textLabel.x = frameQuestionReset.x
    resetGroup:insert(frameQuestionReset.textLabel)

    local widthRateButtons = frameQuestionReset.width / 1.1
    local heightRateButtons = display.safeActualContentHeight / 10
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

    local optionsButtonResetConfirm = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthRateButtons,
        height = heightRateButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("resetStatsConfirm"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "resetStatsConfirm",
        onEvent = handleConfirmationTouch,
    }
    local buttonResetConfirm = widget.newButton( optionsButtonResetConfirm )
    buttonResetConfirm.x = display.contentCenterX
    resetGroup:insert( buttonResetConfirm )

    local optionsButtonConfirmDeny = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthRateButtons,
        height = heightRateButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("resetStatsDeny"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "resetStatsDeny",
        onEvent = handleConfirmationTouch,
    }
    local buttonResetDeny = widget.newButton( optionsButtonConfirmDeny )
    buttonResetDeny.x = display.contentCenterX
    resetGroup:insert( buttonResetDeny )

    frameQuestionReset.height = frameQuestionReset.textLabel.height + buttonResetConfirm.height + buttonResetDeny.height + distanceChoices * 4
    frameQuestionReset.y = display.contentCenterY
    frameQuestionReset.textLabel.y = frameQuestionReset.y - frameQuestionReset.height / 2 + frameQuestionReset.textLabel.height / 1.5
    buttonResetDeny.y = (frameQuestionReset.y + frameQuestionReset.height / 2) - buttonResetDeny.height / 2 - distanceChoices
    buttonResetConfirm.y = buttonResetDeny.y - heightRateButtons - distanceChoices
end

local function handleTouch(event)
    if (event.phase == "began") then
        if (event.target.id == "resetStats") then
            local colorButtonOver = themeData.colorButtonOver
            local colorTextOver = themeData.colorTextOver

            audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

            event.target:setFillColor( unpack(colorButtonOver) )
            event.target:setStrokeColor( unpack(colorButtonOver) )
            event.target.textLabel:setFillColor( unpack(colorTextOver) )
        end
    elseif (event.phase == "ended") then
        if (event.target.id == "resetStats") then
            local colorButtonFillDefault = themeData.colorButtonFillDefault
            local colorButtonStroke = themeData.colorButtonStroke
            local colorTextDefault = themeData.colorTextDefault

            showResetConfirmation()

            event.target:setFillColor( unpack(colorButtonFillDefault) )
            event.target:setStrokeColor( unpack(colorButtonStroke) )
            event.target.textLabel:setFillColor( unpack(colorTextDefault) )
        elseif (event.target.id == "buttonBack") then
            Runtime:removeEventListener( "enterFrame", moveStats )

            if (callSource == "endScreen") then
                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
                params = {callSource = "statsScreen", scoreCurrent = scoreCurrent, statusGame = statusGame}}
                composer.gotoScene( "screens.endScreen", optionsChangeScene )
            else
                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "statsScreen"}}
                composer.gotoScene( "screens.menuScreen", optionsChangeScene )
            end
        end
    end
    return true
end

-- Statistics that will be shown to the player
local function createStatisticsElements()
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonStroke = themeData.colorButtonStroke

    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local widthMenuButtons = display.safeActualContentWidth / 1.5
    local fontSizeButtons = display.safeActualContentHeight / 30

    
    local optionsLabelScoreValue = { text = composer.getVariable( "scoreHigh" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelScoreValue = display.newText( optionsLabelScoreValue )
    labelScoreValue:setFillColor( unpack(colorTextDefault) )
    labelScoreValue.x = display.contentCenterX
    labelScoreValue.y = labelScoreValue.height  -- height is determined this way because it's relative to container coordinates
    statsGroup:insert(labelScoreValue)

    local optionsLabelScoreTitle = { text = sozluk.getString("bestScore"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelScoreTitle = display.newText( optionsLabelScoreTitle )
    labelScoreTitle:setFillColor( unpack(colorTextDefault) )
    labelScoreTitle.x = display.contentCenterX
    labelScoreTitle.y = labelScoreValue.y + labelScoreValue.height / 2 + labelScoreTitle.height / 2
    statsGroup:insert(labelScoreTitle)

    local optionsLabelGamesPlayedValue = { text = composer.getVariable( "gamesPlayed" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelGamesValue = display.newText( optionsLabelGamesPlayedValue )
    labelGamesValue:setFillColor( unpack(colorTextDefault) )
    labelGamesValue.x = display.contentCenterX
    labelGamesValue.y = labelScoreTitle.y + labelScoreTitle.height + labelGamesValue.height * 1.5
    statsGroup:insert(labelGamesValue)

    local optionsLabelGamesTitle = { text = sozluk.getString("gamesPlayed"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelGamesTitle = display.newText( optionsLabelGamesTitle )
    labelGamesTitle:setFillColor( unpack(colorTextDefault) )
    labelGamesTitle.x = display.contentCenterX
    labelGamesTitle.y = labelGamesValue.y + labelGamesValue.height / 2 + labelGamesTitle.height / 2
    statsGroup:insert(labelGamesTitle)

    local optionsLabelAnsweredValue = { text = composer.getVariable( "questionsAnsweredTotal" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelAnsweredValue = display.newText( optionsLabelAnsweredValue )
    labelAnsweredValue:setFillColor( unpack(colorTextDefault) )
    labelAnsweredValue.x = display.contentCenterX
    labelAnsweredValue.y = labelGamesTitle.y + labelGamesTitle.height + labelAnsweredValue.height * 1.5
    statsGroup:insert(labelAnsweredValue)

    local optionsLabelAnsweredTitle = { text = sozluk.getString("questionsAnsweredTotal"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelAnsweredTitle = display.newText( optionsLabelAnsweredTitle )
    labelAnsweredTitle:setFillColor( unpack(colorTextDefault) )
    labelAnsweredTitle.x = display.contentCenterX
    labelAnsweredTitle.y = labelAnsweredValue.y + labelAnsweredValue.height / 2 + labelAnsweredTitle.height / 2
    statsGroup:insert(labelAnsweredTitle)

    local optionsLabelRunsValue = { text = composer.getVariable( "runsCompleted" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelRunsValue = display.newText( optionsLabelRunsValue )
    labelRunsValue:setFillColor( unpack(colorTextDefault) )
    labelRunsValue.x = display.contentCenterX
    labelRunsValue.y = labelAnsweredTitle.y + labelAnsweredTitle.height + labelRunsValue.height * 1.5
    statsGroup:insert(labelRunsValue)

    local optionsLabelRunsTitle = { text = sozluk.getString("runsCompleted"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelRunsTitle = display.newText( optionsLabelRunsTitle )
    labelRunsTitle:setFillColor( unpack(colorTextDefault) )
    labelRunsTitle.x = display.contentCenterX
    labelRunsTitle.y = labelRunsValue.y + labelRunsValue.height / 2 + labelRunsTitle.height / 2
    statsGroup:insert(labelRunsTitle)

    local optionsLabelLocksValue = { text = composer.getVariable( "locksUsed" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelLocksValue = display.newText( optionsLabelLocksValue )
    labelLocksValue:setFillColor( unpack(colorTextDefault) )
    labelLocksValue.x = display.contentCenterX
    labelLocksValue.y = labelRunsTitle.y + labelRunsTitle.height + labelLocksValue.height * 1.5
    statsGroup:insert(labelLocksValue)

    local optionsLabelLocksTitle = { text = sozluk.getString("locksUsed"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelLocksTitle = display.newText( optionsLabelLocksTitle )
    labelLocksTitle:setFillColor( unpack(colorTextDefault) )
    labelLocksTitle.x = display.contentCenterX
    labelLocksTitle.y = labelLocksValue.y + labelLocksValue.height / 2 + labelLocksTitle.height / 2
    statsGroup:insert(labelLocksTitle)

    local optionsLabelCoinsValue = { text = composer.getVariable( "coinsTotal" ), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelCoinsValue = display.newText( optionsLabelCoinsValue )
    labelCoinsValue:setFillColor( unpack(colorTextDefault) )
    labelCoinsValue.x = display.contentCenterX
    labelCoinsValue.y = labelLocksTitle.y + labelLocksTitle.height + labelCoinsValue.height * 1.5
    statsGroup:insert(labelCoinsValue)

    local optionsLabelCoinsTitle = { text = sozluk.getString("coinsTotal"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelCoinsTitle = display.newText( optionsLabelCoinsTitle )
    labelCoinsTitle:setFillColor( unpack(colorTextDefault) )
    labelCoinsTitle.x = display.contentCenterX
    labelCoinsTitle.y = labelCoinsValue.y + labelCoinsValue.height / 2 + labelCoinsTitle.height / 2
    statsGroup:insert(labelCoinsTitle)

    local optionsLabelRevivalValue = { text = composer.getVariable( "percentageRevival" ) .. "%", 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelRevivalValue = display.newText( optionsLabelRevivalValue )
    labelRevivalValue:setFillColor( unpack(colorTextDefault) )
    labelRevivalValue.x = display.contentCenterX
    labelRevivalValue.y = labelCoinsTitle.y + labelCoinsTitle.height + labelRevivalValue.height * 1.5
    statsGroup:insert(labelRevivalValue)

    local optionsLabelRevivalTitle = { text = sozluk.getString("percentageRevival"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    local labelRevivalTitle = display.newText( optionsLabelRevivalTitle )
    labelRevivalTitle:setFillColor( unpack(colorTextDefault) )
    labelRevivalTitle.x = display.contentCenterX
    labelRevivalTitle.y = labelRevivalValue.y + labelRevivalValue.height / 2 + labelRevivalTitle.height / 2
    statsGroup:insert(labelRevivalTitle)

    containerStats = display.newContainer( display.safeActualContentWidth, yLimitBottom - menuSeparator.y )
    containerStats.anchorX, containerStats.anchorY = 0, 0
    containerStats.x, containerStats.y = 0, menuSeparator.y + menuSeparator.height / 2
    containerStats.anchorChildren = false
    containerStats.ySpeed = 1
    containerStats.movementSpeed = -containerStats.ySpeed
    statsGroup:insert(containerStats)

    containerStats:insert(labelScoreValue)
    containerStats:insert(labelScoreTitle)
    containerStats:insert(labelGamesValue)
    containerStats:insert(labelGamesTitle)
    containerStats:insert(labelAnsweredValue)
    containerStats:insert(labelAnsweredTitle)
    containerStats:insert(labelRunsValue)
    containerStats:insert(labelRunsTitle)
    containerStats:insert(labelLocksValue)
    containerStats:insert(labelLocksTitle)
    containerStats:insert(labelCoinsValue)
    containerStats:insert(labelCoinsTitle)
    containerStats:insert(labelRevivalValue)
    containerStats:insert(labelRevivalTitle)
end

-- Create UI elements like back button etc.
local function createUIElements()
    local xDistanceSides = display.safeActualContentWidth / 10
    local widthButtonSettings = display.safeActualContentWidth / 8
    local heightButtonSettings = widthButtonSettings

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonStroke = themeData.colorButtonStroke

    local widthMenuButtons = display.safeActualContentWidth / 1.5
    local fontSizeButtons = display.safeActualContentHeight / 30
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local background = display.newRect( statsGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillDefault },
        width = display.safeActualContentWidth / 6,
        height = display.safeActualContentHeight / 10,
        label = "<",
        labelColor = { default = colorButtonDefault, over = colorButtonOver },
        font = fontLogo,
        fontSize = display.safeActualContentHeight / 15,
        id = "buttonBack",
        onEvent = handleTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.x = buttonBack.width / 2
    buttonBack.y = display.safeScreenOriginY + buttonBack.height / 2
    statsGroup:insert( buttonBack )

    menuSeparator = display.newRect( statsGroup, background.x, 0, background.width, 10 )
    menuSeparator.y = buttonBack.y + buttonBack.height / 2
    menuSeparator:setFillColor( unpack(colorButtonOver) )

    local frameButtonReset = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonReset.id = "resetStats"
    frameButtonReset:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonReset.strokeWidth = strokeWidthButtons
    frameButtonReset:setStrokeColor( unpack(colorButtonStroke) )
    frameButtonReset:addEventListener( "touch", handleTouch )
    statsGroup:insert( frameButtonReset )

    local optionsLabelReset = { text = sozluk.getString("resetStats"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonReset.textLabel = display.newText( optionsLabelReset )
    frameButtonReset.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonReset.textLabel.x = frameButtonReset.x
    statsGroup:insert(frameButtonReset.textLabel)

    frameButtonReset.width = frameButtonReset.textLabel.width * 1.2
    frameButtonReset.height = frameButtonReset.textLabel.height * 2
    frameButtonReset.y = display.safeActualContentHeight - frameButtonReset.height
    frameButtonReset.textLabel.y = frameButtonReset.y

    yLimitBottom = frameButtonReset.y - frameButtonReset.height
end

local function cleanUp()
    Runtime:removeEventListener( "enterFrame", moveStats )
end

local function unloadSoundFX()
    for i = 2, audio.totalChannels do
        audio.stop(i)
    end 

    for k, v in pairs ( tableSoundFiles ) do
        audio.dispose( tableSoundFiles[k] )
        tableSoundFiles[k] = nil
    end
end

local function loadSoundFX()
    tableSoundFiles["answerChosen"] = audio.loadSound( "assets/soundFX/answerChosen.wav" )
end

function scene:create( event )
    mainGroup = self.view

    statsGroup = display.newGroup( )
    resetGroup = display.newGroup( )

    loadSoundFX()

    createUIElements()
    createStatisticsElements()

    mainGroup:insert(statsGroup)
    mainGroup:insert(resetGroup)
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        if (event.params) then
            if (event.params["callSource"] == "endScreen") then
                callSource = event.params["callSource"]
                scoreCurrent = event.params["scoreCurrent"]
                statusGame = event.params["statusGame"]

                -- Game status is passed for endScreen
                -- When this screen is called from endScreen, player will return to that screen
                if (statusGame == "successSetUnlocked" or statusGame == "successSetNA" or 
                    statusGame == "successSetCompletedBefore" or statusGame == "successEndgame") then
                    statusGame = "success"
                end
            end
        end

        composer.removeHidden()
        composer.setVariable("currentAppScene", "statsScreen")

        Runtime:addEventListener( "enterFrame", moveStats )
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        cleanUp()
    elseif ( phase == "did" ) then
        unloadSoundFX()
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