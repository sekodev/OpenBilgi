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

local isMotionReduced = composer.getVariable( "isMotionReduced" )

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )

local mainGroup, menuGroup, resetGroup

local tableSoundFiles = {}

local callSource
local scoreCurrent = 0

local isInteractionAvailable = true


local function cleanUp()
    composer.setVariable( "isMotionReduced", isMotionReduced )

    -- Save changes before the player leaves settings
    -- This is called here to avoid discarding changes when Android user presses OS back button
    savePreferences()
end

-- Change scene to logoScreen after resetting player progress
local function resetProgress()
    resetQuestions()

    local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime}
    composer.gotoScene( "screens.logoScreen", optionsChangeScene )
end

-- Close progress reset dialog box
local function closeDialogBox()
    utils.clearDisplayGroup(resetGroup)
end

-- Handle touch events for everything visible on the scene
local function handleTouch(event)
    if (event.phase == "began") then
        if (isInteractionAvailable) then
            if (event.target.id == "controlTheme") then
                -- Changing theme happens in the same screen
                isInteractionAvailable = false

                local colorButtonOver = themeData.colorButtonOver
                event.target.textLabel:setFillColor( unpack(colorButtonOver) )
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                local currentTheme = composer.getVariable( "currentTheme" )
                local themeSelected = ""

                if (currentTheme == "dark") then
                    themeSelected = "light"
                elseif (currentTheme == "light") then
                    themeSelected = "dark"
                end

                composer.setVariable( "currentTheme" , themeSelected )

                themeData = themeSettings.getData(themeSelected)

                utils.clearDisplayGroup(menuGroup)
                createSettingsElements()

                isInteractionAvailable = true
            elseif (event.target.id == "controlReduceMotion") then
                -- Changing reduce motion setting happens in the same screen
                isInteractionAvailable = false

                local colorButtonOver = themeData.colorButtonOver
                event.target.textLabel:setFillColor( unpack(colorButtonOver) )
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                if (isMotionReduced) then
                    -- Turn off
                    isMotionReduced = false

                    sceneTransitionEffect = composer.getVariable( "sceneTransitionEffectDefault" )
                    composer.setVariable( "sceneTransitionEffect", sceneTransitionEffect )
                else
                    -- Turn on
                    isMotionReduced = true

                    sceneTransitionEffect = composer.getVariable( "sceneTransitionEffectReduceMotion" )
                    composer.setVariable( "sceneTransitionEffect", sceneTransitionEffect )
                end

                utils.clearDisplayGroup(menuGroup)
                createSettingsElements()

                isInteractionAvailable = true
            elseif (event.target.id == "controlFullScreen") then
                -- Changing full screen support happens in the same screen
                isInteractionAvailable = false

                local colorButtonOver = themeData.colorButtonOver
                event.target.textLabel:setFillColor( unpack(colorButtonOver) )
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                local fullScreen = composer.getVariable( "fullScreen" )

                fullScreen = not fullScreen

                composer.setVariable( "fullScreen" , fullScreen )

                adjustScreenDimensions(fullScreen)
                utils.clearDisplayGroup(menuGroup)
                createSettingsElements()

                isInteractionAvailable = true
            elseif (event.target.id == "controlLanguage") then
                -- Changing selected language happens in the same screen
                isInteractionAvailable = false

                local colorButtonOver = themeData.colorButtonOver
                event.target.textLabel:setFillColor( unpack(colorButtonOver) )
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                local currentLanguage = composer.getVariable( "currentLanguage" )
                local languageSelected = ""

                if (currentLanguage == "tr") then
                    languageSelected = "en"
                elseif (currentLanguage == "en") then
                    languageSelected = "tr"
                end

                composer.setVariable( "currentLanguage", languageSelected )
                composer.setVariable( "languageSelected", languageSelected )

                sozluk.setSelectedTranslation( composer.getVariable("currentLanguage") )
                utils.clearDisplayGroup(menuGroup)
                createSettingsElements()

                isInteractionAvailable = true
            elseif (event.target.id == "resetQuestions") then
                -- Will be handled in "ended" phase
                local colorButtonOver = themeData.colorButtonOver
                local colorTextOver = themeData.colorTextOver

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(colorButtonOver) )
                event.target:setStrokeColor( unpack(colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(colorTextOver) )
            end
        end
    elseif (event.phase == "ended") then
        if (isInteractionAvailable) then
            if (event.target.id == "resetQuestions") then
                -- Declare options for dialog box creation
                local optionsDialogBox = {
                    fontDialog = fontLogo,
                    dialogText = sozluk.getString("resetQuestionsAsk"),
                    confirmText = sozluk.getString("resetQuestionsConfirm"),
                    confirmFunction = resetProgress,
                    denyText = sozluk.getString("resetQuestionsDeny"),
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
    end
    return true
end

local function goBack()
    -- Return player to the screen where they pressed "Settings"
    -- Player can reach settings from either menuScreen or endScreen
    if (callSource == "endScreen") then
        local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, 
        params = {callSource = "settingScreen", scoreCurrent = scoreCurrent, statusGame = statusGame}}
        composer.gotoScene( "screens.endScreen", optionsChangeScene )
    else
        local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, params = {callSource = "settingScreen"}}
        composer.gotoScene( "screens.menuScreen", optionsChangeScene )
    end
end

function createSettingsElements()
    local colorBackground = themeData.colorBackground
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonFillTrue = themeData.colorButtonFillTrue
    local colorButtonStroke = themeData.colorButtonStroke

    local background = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(colorBackground) )

    local optionsNavigationMenu = { position = "top", fontName = fontLogo, 
        backFunction = goBack }
    local yStartingPlacement = commonMethods.createNavigationMenu(menuGroup, optionsNavigationMenu)


    -- Create settings elements from bottom to top so player can easily reach those options on touch screen
    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30

    local colorTextOver = themeData.colorTextOver
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local yButtonPlacementNextElement


    local frameButtonReset = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonReset.id = "resetQuestions"
    frameButtonReset:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonReset.strokeWidth = strokeWidthButtons
    frameButtonReset:setStrokeColor( unpack(colorButtonStroke) )
    frameButtonReset:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonReset )

    local optionsLabelReset = { text = sozluk.getString("resetQuestions"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonReset.textLabel = display.newText( optionsLabelReset )
    frameButtonReset.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonReset.textLabel.x = frameButtonReset.x
    menuGroup:insert(frameButtonReset.textLabel)

    frameButtonReset.width = frameButtonReset.textLabel.width * 1.2
    frameButtonReset.height = frameButtonReset.textLabel.height * 2
    frameButtonReset.y = contentHeightSafe - frameButtonReset.height
    frameButtonReset.textLabel.y = frameButtonReset.y

    local themeName
    if (composer.getVariable( "currentTheme" ) == "dark") then
        themeName = sozluk.getString("themeDark")
    elseif (composer.getVariable( "currentTheme" ) == "light") then
        themeName = sozluk.getString("themeLight")
    end

    local frameButtonTheme = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonTheme.id = "controlTheme"
    frameButtonTheme:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonTheme.strokeWidth = strokeWidthButtons
    frameButtonTheme:setStrokeColor( unpack(colorButtonFillDefault) )
    frameButtonTheme:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonTheme )

    local optionsLabelTheme = { text = sozluk.getString("themeSelected") .. " " .. themeName, 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonTheme.textLabel = display.newText( optionsLabelTheme )
    frameButtonTheme.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonTheme.textLabel.x = frameButtonTheme.x
    menuGroup:insert(frameButtonTheme.textLabel)

    frameButtonTheme.height = frameButtonTheme.textLabel.height * 2
    frameButtonTheme.y = frameButtonReset.y - frameButtonReset.height / 2 - frameButtonTheme.height
    frameButtonTheme.textLabel.y = frameButtonTheme.y


    local statusMotionReduced
    if (isMotionReduced) then
        statusMotionReduced = sozluk.getString("settingOn")
    else
        statusMotionReduced = sozluk.getString("settingOff")
    end

    local frameButtonReduceMotion = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonReduceMotion.id = "controlReduceMotion"
    frameButtonReduceMotion:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonReduceMotion.strokeWidth = strokeWidthButtons
    frameButtonReduceMotion:setStrokeColor( unpack(colorButtonFillDefault) )
    frameButtonReduceMotion:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonReduceMotion )

    local optionsLabelReduceMotion = { text = sozluk.getString("reduceMotion") .. " " .. statusMotionReduced, 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonReduceMotion.textLabel = display.newText( optionsLabelReduceMotion )
    frameButtonReduceMotion.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonReduceMotion.textLabel.x = frameButtonReduceMotion.x
    menuGroup:insert(frameButtonReduceMotion.textLabel)

    frameButtonReduceMotion.height = frameButtonReduceMotion.textLabel.height * 2
    frameButtonReduceMotion.y = frameButtonTheme.y - frameButtonTheme.height / 2 - frameButtonReduceMotion.height / 2
    frameButtonReduceMotion.textLabel.y = frameButtonReduceMotion.y

    -- This will keep track of the latest element created, in case full screen toggle is not available
    yButtonPlacementNextElement = frameButtonReduceMotion.y - frameButtonReduceMotion.height / 2


    -- Show full screen toggle based on device resolution
    -- If device doesn't have a notch / carved out camera etc. toggle is unnecessary
    if (display.contentHeight > display.safeActualContentHeight) then
        local statusFullScreen
        if (composer.getVariable( "fullScreen" ) == true) then
            statusFullScreen = sozluk.getString("settingOn")
        else
            statusFullScreen = sozluk.getString("settingOff")
        end

        local frameButtonFullScreen = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
        frameButtonFullScreen.id = "controlFullScreen"
        frameButtonFullScreen:setFillColor( unpack(colorButtonFillDefault) )
        frameButtonFullScreen.strokeWidth = strokeWidthButtons
        frameButtonFullScreen:setStrokeColor( unpack(colorButtonFillDefault) )
        frameButtonFullScreen:addEventListener( "touch", handleTouch )
        menuGroup:insert( frameButtonFullScreen )

        local optionsLabelFullScreen = { text = sozluk.getString("fullScreen") .. " " .. statusFullScreen, 
            height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
        frameButtonFullScreen.textLabel = display.newText( optionsLabelFullScreen )
        frameButtonFullScreen.textLabel:setFillColor( unpack(colorTextDefault) )
        frameButtonFullScreen.textLabel.x = frameButtonFullScreen.x
        menuGroup:insert(frameButtonFullScreen.textLabel)

        frameButtonFullScreen.height = frameButtonFullScreen.textLabel.height * 2
        frameButtonFullScreen.y = yButtonPlacementNextElement - frameButtonFullScreen.height / 2
        frameButtonFullScreen.textLabel.y = frameButtonFullScreen.y

        -- This will keep track of the latest element created
        yButtonPlacementNextElement = frameButtonFullScreen.y - frameButtonFullScreen.height / 2
    end

    local languageSelected
    if (composer.getVariable( "currentLanguage" ) == "tr") then
        languageSelected = sozluk.getString("languageTurkish")
    elseif (composer.getVariable( "currentLanguage" ) == "en") then
        languageSelected = sozluk.getString("languageEnglish")
    end

    local frameButtonLanguage = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonLanguage.id = "controlLanguage"
    frameButtonLanguage:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonLanguage.strokeWidth = strokeWidthButtons
    frameButtonLanguage:setStrokeColor( unpack(colorButtonFillDefault) )
    frameButtonLanguage:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonLanguage )

    local optionsLabelLanguage = { text = sozluk.getString("languageSelected") .. " " .. languageSelected, 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonLanguage.textLabel = display.newText( optionsLabelLanguage )
    frameButtonLanguage.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonLanguage.textLabel.x = frameButtonLanguage.x
    menuGroup:insert(frameButtonLanguage.textLabel)

    frameButtonLanguage.height = frameButtonLanguage.textLabel.height * 2
    frameButtonLanguage.y = yButtonPlacementNextElement - frameButtonLanguage.height / 2
    frameButtonLanguage.textLabel.y = frameButtonLanguage.y

    local widthMusicButton = contentWidthSafe / 8
    local heightMusicButton = widthMusicButton
    local yMusicSlider = frameButtonLanguage.y - frameButtonLanguage.height - heightMusicButton * 1.2

    local optionsSliderMusic = { id = "musicLevel", filePath = "assets/menu/music.png", 
        colorBackground = colorBackground, colorButtonDefault = colorButtonDefault, 
        colorButtonFillDefault = colorButtonFillWrong, colorButtonFillOnPress = colorButtonFillTrue, 
        colorButtonStroke = colorButtonStroke, widthButton = widthMusicButton, heightButton = heightMusicButton, 
        yButton = yMusicSlider }
    local buttonMusic = utils.createSliderControl(menuGroup, optionsSliderMusic)

    local widthSoundButton = widthMusicButton
    local heightSoundButton = heightMusicButton
    local ySoundSlider = buttonMusic.y - buttonMusic.height / 2 - heightSoundButton * 1.2
    local optionsSliderSound = { id = "soundLevel", filePath = "assets/menu/sound.png", 
        colorBackground = colorBackground, colorButtonDefault = colorButtonDefault, 
        colorButtonFillDefault = colorButtonFillWrong, colorButtonFillOnPress = colorButtonFillTrue, 
        colorButtonStroke = colorButtonStroke, widthButton = widthSoundButton, heightButton = heightSoundButton, 
        yButton = ySoundSlider, soundSample = tableSoundFiles["answerChosen"] }
    local buttonSound = utils.createSliderControl(menuGroup, optionsSliderSound)
end

function scene:create( event )
    mainGroup = self.view
    menuGroup = display.newGroup( )
    resetGroup = display.newGroup( )

    local tableFileNames = { "answerChosen.wav" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)

    createSettingsElements()

    mainGroup:insert(menuGroup)
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
        composer.setVariable("currentAppScene", "settingScreen")
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