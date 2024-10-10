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

local sceneTransitionTime = composer.getVariable( "sceneTransitionTime" )
local sceneTransitionEffect = composer.getVariable( "sceneTransitionEffect" )

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )

local mainGroup, statsGroup, resetGroup

local containerStats

local yStartingPlacement, yLimitBottom

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

-- Reverts statistics variables to starting values
local function resetStatistics()
    composer.setVariable( "scoreHigh", 0 )
    composer.setVariable( "gamesPlayed", 0 )
    composer.setVariable( "questionsAnsweredTotal", 0 )
    composer.setVariable( "runsCompleted", 0 )
    composer.setVariable( "locksUsed", 0 )
    composer.setVariable( "coinsTotal", 0 )

    savePreferences()

    -- Resetting statistics takes player back to logoScreen
    local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime}
    composer.gotoScene( "screens.logoScreen", optionsChangeScene )
end

-- Close progress reset dialog box
local function closeDialogBox()
    utils.clearDisplayGroup(resetGroup)
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
            -- Declare options for dialog box creation
            local optionsDialogBox = {
                fontDialog = fontLogo,
                dialogText = sozluk.getString("resetStatsAsk"),
                confirmText = sozluk.getString("resetStatsConfirm"),
                confirmFunction = resetStatistics,
                denyText = sozluk.getString("resetStatsDeny"),
                denyFunction = closeDialogBox,
            }
            utils.showDialogBox(resetGroup, optionsDialogBox)

            local colorButtonFillDefault = themeData.colorButtonFillDefault
            local colorButtonStroke = themeData.colorButtonStroke
            local colorTextDefault = themeData.colorTextDefault

            event.target:setFillColor( unpack(colorButtonFillDefault) )
            event.target:setStrokeColor( unpack(colorButtonStroke) )
            event.target.textLabel:setFillColor( unpack(colorTextDefault) )
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

    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30


    containerStats = display.newContainer( contentWidthSafe, yLimitBottom - yStartingPlacement )
    containerStats.anchorX, containerStats.anchorY = 0, 0
    containerStats.x, containerStats.y = 0, yStartingPlacement
    containerStats.anchorChildren = false
    containerStats.ySpeed = 1
    containerStats.movementSpeed = -containerStats.ySpeed
    statsGroup:insert(containerStats)
    

    local tableStatsElements = {}

    local tableStats = { 
        { statsTitle = sozluk.getString("bestScore"), statsValue = composer.getVariable( "scoreHigh" ) },
        { statsTitle = sozluk.getString("gamesPlayed"), statsValue = composer.getVariable( "gamesPlayed" ) },
        { statsTitle = sozluk.getString("questionsAnsweredTotal"), statsValue = composer.getVariable( "questionsAnsweredTotal" ) },
        { statsTitle = sozluk.getString("runsCompleted"), statsValue = composer.getVariable( "runsCompleted" ) },
        { statsTitle = sozluk.getString("locksUsed"), statsValue = composer.getVariable( "locksUsed" ) },
        { statsTitle = sozluk.getString("coinsTotal"), statsValue = composer.getVariable( "coinsTotal" ) },
        { statsTitle = sozluk.getString("percentageRevival"), statsValue = composer.getVariable( "percentageRevival" ) .. "%" },
    }

    for i = 1, #tableStats do
        local optionsLabelStatsTitle = { text = tableStats[i].statsTitle,
            height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
        local labelStatsTitle = display.newText( optionsLabelStatsTitle )
        labelStatsTitle:setFillColor( unpack(colorTextDefault) )
        labelStatsTitle.x = display.contentCenterX
        if (i == 1) then
            labelStatsTitle.y = labelStatsTitle.height  -- height is determined this way because it's relative to container coordinates
        else
            labelStatsTitle.y = tableStatsElements[i - 1].y + tableStatsElements[i - 1].height + labelStatsTitle.height * 1.5
        end
        statsGroup:insert(labelStatsTitle)

        local optionslabelStatsValue = { text = tableStats[i].statsValue,
            height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
        local labelStatsValue = display.newText( optionslabelStatsValue )
        labelStatsValue:setFillColor( unpack(colorTextDefault) )
        labelStatsValue.x = display.contentCenterX
        labelStatsValue.y = labelStatsTitle.y + labelStatsTitle.height / 2 + labelStatsValue.height / 2
        statsGroup:insert(labelStatsValue)

        table.insert(tableStatsElements, labelStatsValue)

        containerStats:insert(labelStatsTitle)
        containerStats:insert(labelStatsValue)
    end
end

local function goBack()
    Runtime:removeEventListener( "enterFrame", moveStats )

    if (callSource == "endScreen") then
        local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, 
        params = {callSource = "statsScreen", scoreCurrent = scoreCurrent, statusGame = statusGame}}
        composer.gotoScene( "screens.endScreen", optionsChangeScene )
    else
        local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, params = {callSource = "statsScreen"}}
        composer.gotoScene( "screens.menuScreen", optionsChangeScene )
    end
end

-- Create UI elements like back button etc.
local function createUIElements()
    local xDistanceSides = contentWidthSafe / 10
    local widthButtonSettings = contentWidthSafe / 8
    local heightButtonSettings = widthButtonSettings

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonStroke = themeData.colorButtonStroke

    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local background = display.newRect( statsGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )

    local optionsNavigationMenu = { position = "top", fontName = fontLogo, 
        backFunction = goBack }
    yStartingPlacement = commonMethods.createNavigationMenu(statsGroup, optionsNavigationMenu)


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
    frameButtonReset.y = contentHeightSafe - frameButtonReset.height
    frameButtonReset.textLabel.y = frameButtonReset.y

    yLimitBottom = frameButtonReset.y - frameButtonReset.height
end

local function cleanUp()
    Runtime:removeEventListener( "enterFrame", moveStats )
    timer.cancelAll( )
end

function scene:create( event )
    mainGroup = self.view

    statsGroup = display.newGroup( )
    resetGroup = display.newGroup( )

    local tableFileNames = { "answerChosen.wav" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)

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

        timer.performWithDelay( 1000, function ()
                Runtime:addEventListener( "enterFrame", moveStats )
            end, 1)
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