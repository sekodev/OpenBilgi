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

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

local mainGroup, menuGroup, resetGroup

local tableSoundFiles = {}

local callSource
local scoreCurrent = 0

local isInteractionAvailable = true


local function cleanUp()
    -- Save changes before the player leaves settings
    -- This is called here to avoid discarding changes when Android user presses OS back button
    savePreferences()
end

-- Change scene to logoScreen after resetting player progress
local function resetProgress()
    resetQuestions()

    local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene}
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
            elseif (event.target.id == "controlSound" or "controlMusic" == event.target.id) then
                -- Start controlling music and sound effects
                display.getCurrentStage( ):setFocus( event.target )

                event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
            elseif (event.target.id == "muteSound") then
                -- Pressing the icon mutes sound effects
                event.target.buttonControl.x = event.target.buttonControl.line.x

                -- Quick mute/unmute
                if (event.target.buttonControl.levelCurrent <= 0) then
                    event.target.buttonControl.levelCurrent = event.target.buttonControl.levelBeforeMute
                else
                    event.target.buttonControl.levelBeforeMute = event.target.buttonControl.levelCurrent
                    event.target.buttonControl.levelCurrent = 0
                end

                event.target.buttonControl.x = event.target.buttonControl.line.x + (event.target.buttonControl.line.width * event.target.buttonControl.levelCurrent)

                for i = 2, audio.totalChannels do
                    audio.setVolume( event.target.buttonControl.levelCurrent, {channel = i} )
                end

                composer.setVariable( "soundLevel", event.target.buttonControl.levelCurrent )
            elseif (event.target.id == "muteMusic") then
                -- Pressing the icon mutes the music
                event.target.buttonControl.x = event.target.buttonControl.line.x

                -- Quick mute/unmute
                if (event.target.buttonControl.levelCurrent <= 0) then
                    event.target.buttonControl.levelCurrent = event.target.buttonControl.levelBeforeMute
                else
                    event.target.buttonControl.levelBeforeMute = event.target.buttonControl.levelCurrent
                    event.target.buttonControl.levelCurrent = 0
                end

                event.target.buttonControl.x = event.target.buttonControl.line.x + (event.target.buttonControl.line.width * event.target.buttonControl.levelCurrent)

                audio.setVolume( event.target.buttonControl.levelCurrent, {channel = channelMusicBackground} )

                composer.setVariable( "musicLevel", event.target.buttonControl.levelCurrent )
            end
        end
    elseif (event.phase == "moved") then
        if (isInteractionAvailable) then
            if (event.target.id == "controlSound" or "controlMusic" == event.target.id) then
                -- Main code used to control sound and music levels
                if (event.x >= event.target.line.x and event.x <= event.target.line.x + event.target.line.width) then
                    event.target.x = event.x

                    event.target.levelBeforeMute = event.target.levelCurrent
                    event.target.levelCurrent = (event.target.x - event.target.line.x) / event.target.line.width

                    if (event.target.levelCurrent < 0.05) then
                        event.target.levelCurrent = 0
                    end
                    

                    if (event.target.id == "controlSound") then
                        audio.setVolume( event.target.levelCurrent, {channel = 2} )

                        -- Play sample sound
                        if (not audio.isChannelPlaying( 2 )) then
                            audio.play( tableSoundFiles["answerChosen"], {channel = 2} ) 
                        end
                    elseif (event.target.id == "controlMusic") then
                        audio.setVolume( event.target.levelCurrent, {channel = channelMusicBackground} )
                    end
                end
            end
        end
    elseif (event.phase == "ended") then
        if (isInteractionAvailable) then
            if (event.target.id == "buttonBack") then
                -- Return player to the screen where they pressed "Settings"
                -- Player can reach settings from either menuScreen or endScreen
                if (callSource == "endScreen") then
                    local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
                    params = {callSource = "settingScreen", scoreCurrent = scoreCurrent, statusGame = statusGame}}
                    composer.gotoScene( "screens.endScreen", optionsChangeScene )
                else
                    local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "settingScreen"}}
                    composer.gotoScene( "screens.menuScreen", optionsChangeScene )
                end
            elseif (event.target.id == "controlMusic") then
                display.getCurrentStage( ):setFocus( nil )

                event.target:setFillColor( unpack(themeData.colorButtonFillWrong) )

                composer.setVariable( "musicLevel", event.target.levelCurrent )
            elseif (event.target.id == "controlSound") then
                display.getCurrentStage( ):setFocus( nil )

                for i = 2, audio.totalChannels do
                    audio.setVolume( event.target.levelCurrent, {channel = i} )
                end

                event.target:setFillColor( unpack(themeData.colorButtonFillWrong) )

                composer.setVariable( "soundLevel", event.target.levelCurrent )
            elseif (event.target.id == "resetQuestions") then
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

function createSettingsElements()
    local xDistanceSides = contentWidthSafe / 10
    local widthButtonSettings = contentWidthSafe / 8
    local heightButtonSettings = widthButtonSettings

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonStroke = themeData.colorButtonStroke

    local background = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillDefault },
        width = contentWidthSafe / 6,
        height = contentHeightSafe / 10,
        label = "<",
        labelColor = { default = colorButtonDefault, over = colorButtonOver },
        font = fontLogo,
        fontSize = contentHeightSafe / 15,
        id = "buttonBack",
        onEvent = handleTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.x = buttonBack.width / 2
    buttonBack.y = display.safeScreenOriginY + buttonBack.height / 2
    menuGroup:insert( buttonBack )

    local optionsLabelVersion = { text = composer.getVariable("currentVersion"), 
        height = 0, align = "center", font = fontLogo, fontSize = contentHeightSafe / 40 }
    local labelVersionNumber = display.newText( optionsLabelVersion )
    labelVersionNumber:setFillColor( unpack(colorTextDefault) )
    labelVersionNumber.anchorX = 1
    labelVersionNumber.x = contentWidthSafe - buttonBack.width / 2
    labelVersionNumber.y = buttonBack.y
    menuGroup:insert(labelVersionNumber)

    local menuSeparator = display.newRect( menuGroup, background.x, 0, background.width, 10 )
    menuSeparator.y = buttonBack.y + buttonBack.height / 2
    menuSeparator:setFillColor( unpack(colorButtonOver) )


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

    -- This will keep track of the latest element created, in case full screen toggle is not available
    yButtonPlacementNextElement = frameButtonTheme.y - frameButtonTheme.height / 2


    -- Show full screen toggle based on device resolution
    -- If device doesn't have a notch / carved out camera etc. toggle is unnecessary
    if (display.contentHeight > display.safeActualContentHeight) then
        local statusFullScreen
        if (composer.getVariable( "fullScreen" ) == true) then
            statusFullScreen = sozluk.getString("fullScreenOn")
        else
            statusFullScreen = sozluk.getString("fullScreenOff")
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
        frameButtonFullScreen.y = frameButtonTheme.y - frameButtonTheme.height / 2 - frameButtonFullScreen.height / 2
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


    local imageMusic = display.newImageRect( menuGroup, "assets/menu/music.png", widthButtonSettings, heightButtonSettings )
    imageMusic.id = "muteMusic"
    imageMusic:setFillColor( unpack(colorButtonDefault) )
    imageMusic.anchorX = 0
    imageMusic.x = xDistanceSides
    imageMusic.y = frameButtonLanguage.y - frameButtonLanguage.height * 2
    imageMusic:addEventListener( "touch", handleTouch )

    local widthLineMusic = contentWidthSafe - xDistanceSides * 2 - imageMusic.width * 1.5
    local heightLineMusic = imageMusic.height / 12
    local xLineMusic = imageMusic.x + imageMusic.width * 1.5
    local yLineMusic = imageMusic.y

    imageMusic.buttonControl = display.newCircle( menuGroup, xLineMusic + widthLineMusic / 2, yLineMusic, imageMusic.height / 4 )
    imageMusic.buttonControl:setStrokeColor( unpack(colorButtonStroke) )
    imageMusic.buttonControl.strokeWidth = 10
    imageMusic.buttonControl:setFillColor( unpack(colorButtonFillWrong) )
    imageMusic.buttonControl.id = "controlMusic"
    imageMusic.buttonControl.levelCurrent = composer.getVariable("musicLevel")
    imageMusic.buttonControl.levelBeforeMute = imageMusic.buttonControl.levelCurrent -- Used to keep last music level before mute is pressed
    imageMusic.buttonControl:addEventListener( "touch", handleTouch )

    imageMusic.buttonControl.line = display.newRect( menuGroup, 0, imageMusic.y, 0, imageMusic.height / 12 )
    imageMusic.buttonControl.line:setFillColor( unpack(colorButtonDefault) )
    imageMusic.buttonControl.line.anchorX = 0
    imageMusic.buttonControl.line.x = xLineMusic
    imageMusic.buttonControl.line.width = widthLineMusic


    local imageSound = display.newImageRect( menuGroup, "assets/menu/sound.png", widthButtonSettings, heightButtonSettings )
    imageSound.id = "muteSound"
    imageSound:setFillColor( unpack(colorButtonDefault) )
    imageSound.anchorX = 0
    imageSound.x = xDistanceSides
    imageSound.y = imageMusic.y - imageMusic.height / 2 - imageMusic.height * 1.2
    imageSound:addEventListener( "touch", handleTouch )

    local widthLineSound = widthLineMusic
    local heightLineSound = heightLineMusic
    local xLineSound = xLineMusic
    local yLineSound = imageSound.y

    imageSound.buttonControl = display.newCircle( menuGroup, xLineSound + widthLineSound / 2, yLineSound, imageSound.height / 4 )
    imageSound.buttonControl:setStrokeColor( unpack(colorButtonStroke) )
    imageSound.buttonControl.strokeWidth = 10
    imageSound.buttonControl:setFillColor( unpack(colorButtonFillWrong) )
    imageSound.buttonControl.id = "controlSound"
    imageSound.buttonControl.levelCurrent = composer.getVariable("soundLevel")
    imageSound.buttonControl.levelBeforeMute = imageSound.buttonControl.levelCurrent -- Used to keep last sound level before mute is pressed
    imageSound.buttonControl:addEventListener( "touch", handleTouch )

    imageSound.buttonControl.line = display.newRect( menuGroup, 0, imageSound.buttonControl.y, 0, heightLineSound )
    imageSound.buttonControl.line:setFillColor( unpack(colorButtonDefault) )
    imageSound.buttonControl.line.anchorX = 0
    imageSound.buttonControl.line.x = xLineSound
    imageSound.buttonControl.line.width = widthLineSound


    imageSound.buttonControl.x = imageSound.buttonControl.line.x + (imageSound.buttonControl.line.width * imageSound.buttonControl.levelCurrent)
    imageMusic.buttonControl.x = imageMusic.buttonControl.line.x + (imageMusic.buttonControl.line.width * imageMusic.buttonControl.levelCurrent)

    imageSound.buttonControl:toFront( )
    imageMusic.buttonControl:toFront( )
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