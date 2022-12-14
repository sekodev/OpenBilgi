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

local widget = require( "widget" )
local particleDesigner = require( "libs.particleDesigner" )

local mainGroup, menuGroup, loadingGroup, shareGroup, infoGroup

local currentLanguage = composer.getVariable( "currentLanguage" )
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )
local fontLogo = composer.getVariable( "fontLogo" )
local fontIngame = composer.getVariable( "fontIngame" )

local priceLockCoins = composer.getVariable( "priceLockCoins" )
local coinsAvailable = composer.getVariable( "coinsAvailable" )
local locksAvailable = composer.getVariable( "locksAvailable" )
local savedRandomSeed = composer.getVariable( "savedRandomSeed" )

local frameButtonPlay, frameButtonSettings, frameButtonCredits, frameButtonConvert
local buttonLockQuestionSet, buttonShare

local tableSoundFiles = {}
local tableTimers = {}

local isInteractionAvailable = true


local function cleanUp()
    Runtime:removeEventListener( "system", onSystemEvent )
    
    tableTimers = utils.cancelTimers(tableTimers)
    transition.cancel( )
end

-- Change scene
local function hideActiveCard()
    local isSaveAvailable = false

    if (savedRandomSeed ~= 0) then
        isSaveAvailable = true
    end

    -- Pass current scene name, lock and save status
    local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
    params = {callSource = "menuScreen", isSetLocked = buttonLockQuestionSet.isActivated, isSaveAvailable = isSaveAvailable}}
    composer.gotoScene( "screens.gameScreen", optionsChangeScene )
end

-- Handles touch events when in-game share UI is shown
function handleShareTouch(event)
    if (event.phase == "ended") then
        local sharedGame = composer.getVariable( "sharedGame" )
        local percentageRevival = composer.getVariable( "percentageRevival" )

        if (event.target.id == "shareStoreQR") then
            if (not sharedGame) then
                sharedGame = true
                composer.setVariable("sharedGame", sharedGame)

                -- Increase revival percentage if the player opens up the share option
                -- I do not track if the player actually shares
                -- This is not advertised well so it's basically a secret at this point
                percentageRevival = percentageRevival + 2
                composer.setVariable("percentageRevival", percentageRevival)

                savePreferences()
            end

            utils.clearDisplayGroup(shareGroup)

            local pathQRCode = "assets/other/QRCode.png"
            utils.showShareQR(shareGroup, pathQRCode)
        elseif (event.target.id == "shareStoreLink") then
            if (not sharedGame) then
                sharedGame = true
                composer.setVariable("sharedGame", sharedGame)

                -- Increase revival percentage if the player opens up the share option
                -- I do not track if the player actually shares
                -- This is not advertised well so it's basically a secret at this point
                percentageRevival = percentageRevival + 2
                composer.setVariable("percentageRevival", percentageRevival)

                savePreferences()
            end

            utils.clearDisplayGroup(shareGroup)


            local urlLandingPage = composer.getVariable( "urlLandingPage" ) -- You can change landing page URL from main.lua
            local pathShareAsset = composer.getVariable( "pathIconFile" ) -- You can change pathIconFile from main.lua

            utils.showSystemShareUI(pathShareAsset, urlLandingPage)
        elseif (event.target.id == "shareCancel") then
            utils.clearDisplayGroup(shareGroup)
        end
    end
    return true
end

-- Create share UI that shows two options - QR code or system(OS) share UI
local function showShareUI()
    local backgroundShade = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .8
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameShareOptions = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameShareOptions:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local widthShareButtons = frameShareOptions.width / 1.1
    local heightShareButtons = contentHeightSafe / 10
    local distanceChoices = heightShareButtons / 5
    local fontSizeChoices = (contentHeightSafe / 25) / 1.1

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local optionsButtonShareQR = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthShareButtons,
        height = heightShareButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("shareStoreQR"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "shareStoreQR",
        onEvent = handleShareTouch,
    }
    local buttonShareQR = widget.newButton( optionsButtonShareQR )
    buttonShareQR.x = display.contentCenterX
    shareGroup:insert( buttonShareQR )

    local optionsButtonShareLink = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthShareButtons,
        height = heightShareButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("shareStoreLink"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "shareStoreLink",
        onEvent = handleShareTouch,
    }
    local buttonShareLink = widget.newButton( optionsButtonShareLink )
    buttonShareLink.x = display.contentCenterX
    shareGroup:insert( buttonShareLink )

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillOver, over = colorButtonFillOver },
        width = frameShareOptions.width / 6,
        height = heightShareButtons / 1.5,
        label = "x",
        labelColor = { default = colorButtonFillDefault, over = colorButtonOver },
        font = fontLogo,
        fontSize = heightShareButtons / 2,
        id = "shareCancel",
        onEvent = handleShareTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.anchorX = 0
    buttonBack.x = buttonShareLink.x + buttonShareLink.width / 2 - buttonBack.width
    shareGroup:insert( buttonBack )


    frameShareOptions.height = buttonShareQR.height + buttonShareLink.height + buttonBack.height + distanceChoices * 3.5
    frameShareOptions.y = display.contentCenterY + frameShareOptions.height / 3
    buttonShareLink.y = (frameShareOptions.y + frameShareOptions.height / 2) - buttonShareLink.height / 2 - distanceChoices
    buttonShareQR.y = buttonShareLink.y - heightShareButtons - distanceChoices
    buttonBack.y = buttonShareQR.y - heightShareButtons - distanceChoices
end

-- Calculate and show number of coins spent/coins left and number of locks gained in return
local function showCoinsConverted( buttonConverter, locksConverted, coinsConverted, coinsLeft )
    local colorButtonDefault = themeData.colorButtonDefault
    local colorTextDefault = themeData.colorTextDefault

    local widthUIButton = contentWidthSafe / 9
    local heightUIButton = widthUIButton

    menuGroup.textCoinsConverted.text = "- " .. coinsConverted
    menuGroup.textLocksConverted.text = "+ " .. locksConverted


    local timeAnimationCurrency = 100
    local timeWaitConversion = 1000

    transition.to( menuGroup.textCoinsConverted, { time = timeAnimationCurrency, y = menuGroup.textCoinsConverted.yTarget, xScale = 1, yScale = 1, alpha = 1, onComplete = function () 
            coinsAvailable = coinsLeft
            menuGroup.textNumCoins.text = coinsAvailable

            local timerWaitCoinsConverted = timer.performWithDelay( timeWaitConversion, function () 
                    transition.to( menuGroup.textCoinsConverted, { time = timeAnimationCurrency, x = menuGroup.textLocksConverted.x, alpha = 0} )

                    transition.to( menuGroup.textLocksConverted, { time = timeAnimationCurrency, alpha = 1, onComplete = function () 
                            local timerWaitLocksConverted = timer.performWithDelay( timeWaitConversion, function () 
                                    transition.to( menuGroup.textLocksConverted, { time = timeAnimationCurrency, y = menuGroup.textLocksConverted.yTarget, xScale = 0.01, yScale = 0.01, alpha = 0, onComplete = function ()
                                            locksAvailable = locksAvailable + locksConverted
                                            menuGroup.textNumLocks.text = locksAvailable

                                            composer.setVariable( "locksAvailable", locksAvailable )
                                            composer.setVariable( "coinsAvailable", coinsAvailable )

                                            savePreferences()

                                            commonMethods.adjustConvertElements(menuGroup, frameButtonPlay)

                                            buttonConverter.textLabel:setFillColor( unpack(colorTextDefault) )

                                            isInteractionAvailable = true
                                        end } )
                                end, 1 )
                            table.insert( tableTimers, timerWaitLocksConverted)
                        end } )
                end, 1 )
            table.insert( tableTimers, timerWaitCoinsConverted )
        end } )
end

-- Visually, show player that they are using the lock system and calculate remaining locks
local function useLock()
    local colorTextDefault = themeData.colorTextDefault

    locksAvailable = locksAvailable - 1

    composer.setVariable( "locksAvailable", locksAvailable )

    local locksUsed = composer.getVariable( "locksUsed" ) + 1
    composer.setVariable( "locksUsed", locksUsed )

    savePreferences()


    infoGroup.alpha = 0

    local optionsNumLocks = { text = "-1", font = fontLogo, fontSize = menuGroup.textNumLocks.size }
    local textNumLockUsed = display.newText( optionsNumLocks )
    textNumLockUsed:setFillColor( unpack(colorTextDefault) )
    textNumLockUsed.x = menuGroup.textNumLocks.x
    textNumLockUsed.y = menuGroup.textNumLocks.y
    textNumLockUsed.yTarget = menuGroup.textCoinsConverted.yTarget
    textNumLockUsed.alpha = 0
    textNumLockUsed.xScale, textNumLockUsed.yScale = 0.01, 0.01
    infoGroup:insert(textNumLockUsed)

    infoGroup.alpha = 1

    local timeTransitionDropLockUsed = 250
    transition.to( textNumLockUsed, { time = timeTransitionDropLockUsed, y = textNumLockUsed.yTarget, xScale = 1, yScale = 1, alpha = 1, onComplete = function ()
            local timerWaitLockUsed = timer.performWithDelay( timeTransitionDropLockUsed * 2, function ()
                transition.to( textNumLockUsed, { time = timeTransitionDropLockUsed, alpha = 0, onComplete = function ()
                    menuGroup.textNumLocks.text = locksAvailable
                end })
            end )
            table.insert(tableTimers, timerWaitLockUsed)
        end })
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

            if (event.target.id == "play" or 
                event.target.id == "continue" or
                event.target.id == "settings" or
                event.target.id == "credits") then

                isInteractionAvailable = false

                -- Change the color of the button to indicate selection
                event.target:setFillColor( unpack(colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(colorTextOver) )
                event.target:setStrokeColor( unpack(colorButtonOver) )

                -- Stop particle effects before scene transition starts
                menuGroup.emitterFXLeft:stop()
                menuGroup.emitterFXRight:stop()
                audio.fadeOut( { channel = 3, time = 1000 } )

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                if (event.target.id == "play") then
                    audio.fadeOut( { channel = channelMusicBackground, time = 750 } )

                    -- if lock is enabled, show player that a lock is used
                    if (buttonLockQuestionSet.isActivated) then
                        useLock()
                    end

                    -- Wait some time before changing the scene
                    -- One reason for this is the particle effects that we need to hide
                    -- If particle effects are not properly handled, it doesn't look good
                    -- Other reason is a design choice. It mimics the ingame action of choosing the answer
                    local timeWaitChoice = 1000

                    local timerHighlightChoice = timer.performWithDelay( timeWaitChoice, function () 
                            event.target:setFillColor( unpack(colorButtonFillTrue) )
                            event.target.textLabel:setFillColor( unpack(colorTextSelected) )
                            event.target:setStrokeColor( unpack(colorButtonFillTrue) )
                            
                            audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                            local timerChangeScene = timer.performWithDelay( timeWaitChoice * 2, function () 
                                    hideActiveCard()
                                end, 1 )
                            table.insert( tableTimers, timerChangeScene )
                        end, 1 )
                    table.insert( tableTimers, timerHighlightChoice )
                elseif (event.target.id == "continue") then
                    audio.fadeOut( { channel = channelMusicBackground, time = 750 } )

                    local timeWaitChoice = 1000

                    local timerHighlightChoice = timer.performWithDelay( timeWaitChoice, function () 
                            event.target:setFillColor( unpack(colorButtonFillTrue) )
                            event.target.textLabel:setFillColor( unpack(colorTextSelected) )
                            event.target:setStrokeColor( unpack(colorButtonFillTrue) )
                            
                            audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                            local timerChangeScene = timer.performWithDelay( timeWaitChoice * 2, function () 
                                    hideActiveCard()
                                end, 1 )
                            table.insert( tableTimers, timerChangeScene )
                        end, 1 )
                    table.insert( tableTimers, timerHighlightChoice )
                elseif (event.target.id == "settings") then
                    local timeWaitChoice = 500

                    -- Transition emitters to 0 alpha because stopping particles takes more time
                    transition.to( menuGroup.emitterFXLeft, { time = timeWaitChoice, alpha = 0 } )
                    transition.to( menuGroup.emitterFXRight, { time = timeWaitChoice, alpha = 0, onComplete = function ()
                        event.target:setFillColor( unpack(colorButtonFillTrue) )
                        event.target.textLabel:setFillColor( unpack(colorTextSelected) )
                        event.target:setStrokeColor( unpack(colorButtonFillTrue) )

                        audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                        local timerChangeScene = timer.performWithDelay( timeWaitChoice, function () 
                                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "menuScreen"}}
                                composer.gotoScene( "screens.settingScreen", optionsChangeScene )
                            end, 1 )
                        table.insert( tableTimers, timerChangeScene )
                    end } )
                elseif (event.target.id == "credits") then
                    local timeWaitChoice = 500

                    transition.to( menuGroup.emitterFXLeft, { time = timeWaitChoice, alpha = 0 } )
                    transition.to( menuGroup.emitterFXRight, { time = timeWaitChoice, alpha = 0, onComplete = function ()
                        event.target:setFillColor( unpack(colorButtonFillTrue) )
                        event.target.textLabel:setFillColor( unpack(colorTextSelected) )
                        event.target:setStrokeColor( unpack(colorButtonFillTrue) )

                        audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                        local timerChangeScene = timer.performWithDelay( timeWaitChoice, function () 
                                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "menuScreen"}}
                                composer.gotoScene( "screens.creditScreen", optionsChangeScene )
                            end, 1 )
                        table.insert( tableTimers, timerChangeScene )
                    end } )
                end
            elseif (event.target.id == "shareSocial") then
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                showShareUI()
            elseif (event.target.id == "rateGame") then
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                utils.showRateUI()
            elseif (event.target.id == "showStats") then
                isInteractionAvailable = false

                menuGroup.emitterFXLeft:stop()
                menuGroup.emitterFXRight:stop()
                audio.fadeOut( { channel = 3, time = 500 } )

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                local timeWaitChoice = 500

                transition.to( menuGroup.emitterFXLeft, { time = timeWaitChoice, alpha = 0 } )
                transition.to( menuGroup.emitterFXRight, { time = timeWaitChoice, alpha = 0, onComplete = function ()
                        local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "menuScreen"}}
                        composer.gotoScene( "screens.statsScreen", optionsChangeScene )
                    end})
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

                        showCoinsConverted(event.target, locksConverted, coinsConverted, coinsLeft)
                    end
                else
                    audio.play( tableSoundFiles["answerWrong"], {channel = 2} )
                    event.target.textLabel:setFillColor( unpack(colorButtonFillWrong) )

                    local timeShake = 75
                    local rotationShake = 20
                    transition.to( event.target.textLabel, { time = timeShake, xScale = 1.5, yScale = 1.5, onComplete = function ()
                            transition.to( event.target.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                                transition.to( event.target.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                        transition.to( event.target.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                                            transition.to( event.target.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                                transition.to( event.target.textLabel, { time = timeShake, xScale = 1, yScale = 1, onComplete = function ()
                                                        event.target.textLabel.rotation = 0
                                                        event.target.textLabel:setFillColor( unpack(colorTextDefault) )

                                                        infoGroup = commonMethods.showCoinsNeeded(infoGroup, frameButtonPlay, fontLogo)

                                                        local timerHideCoinsNeeded = timer.performWithDelay( 2000, function () 
                                                                commonMethods.hideCoinsNeeded(infoGroup)

                                                                isInteractionAvailable = true
                                                            end, 1 )
                                                        table.insert( tableTimers, timerHideCoinsNeeded )
                                                    end })
                                                end })
                                        end })
                                    end })
                            end })
                        end })
                end
            end
        end
    elseif (event.phase == "ended" or "cancelled" == event.phase) then
        if (isInteractionAvailable) then
            if (event.target.id == "shareSocial" or "rateGame" == event.target.id) then
                event.target:setFillColor( unpack(themeData.colorButtonDefault) )
            elseif (event.target.id == "lockQuestionSet") then
                local lockInfoAvailable = composer.getVariable( "lockInfoAvailable" )

                -- Only change the flag as activated
                -- This change will be used later on button press("Play") and scene change
                if (event.target.isActivated) then
                    event.target.isActivated = false
                    event.target.alpha = event.target.alphaInactive
                    event.target:setFillColor( unpack(themeData.colorPadlock) )
                else
                    audio.play( tableSoundFiles["lockQuestionSet"], {channel = 2} )

                    -- Check to see if information about lock system will be shown
                    -- If player discarded the message and chose "Don't show again", don't show info box
                    if (lockInfoAvailable) then
                        if (locksAvailable > 0) then
                            event.target.isActivated = true
                            event.target.alpha = 1
                        end

                        local infoText
                        local isPromptAvailable = true
                        if (locksAvailable > 0) then
                            infoText = sozluk.getString("lockInformation")
                        else
                            infoText = sozluk.getString("lockInformationNA")
                            isPromptAvailable = false
                        end

                        yTopFrame = utils.showInformationBox(infoGroup, infoText, fontLogo, isPromptAvailable, "lockInfoAvailable")
                        infoGroup = commonMethods.showLocksAvailable(infoGroup, yTopFrame, locksAvailable, fontLogo)
                    else
                        if (locksAvailable > 0) then
                            event.target.isActivated = true
                            event.target.alpha = 1
                        else
                            local infoText
                            local isPromptAvailable = true
                            if (locksAvailable <= 0) then
                                infoText = sozluk.getString("lockInformationNA")
                                isPromptAvailable = false
                            end

                            yTopFrame = utils.showInformationBox(infoGroup, infoText, fontLogo, isPromptAvailable, "lockInfoAvailable")
                            infoGroup = commonMethods.showLocksAvailable(infoGroup, yTopFrame, locksAvailable, fontLogo)
                        end
                    end
                end
            end
        end
    end
    return true
end

local function createMenuElements()
    local background = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background.id = "background"
    background:setFillColor( unpack(themeData.colorBackground) )
    background:addEventListener( "touch", function () return true end )


    local widthUIButton = contentWidthSafe / 9
    local heightUIButton = widthUIButton

    local colorButtonOver = themeData.colorButtonOver
    local colorButtonDefault = themeData.colorButtonDefault
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons
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
    buttonShare = widget.newButton( optionsButtonShare )
    buttonShare:setFillColor( unpack(colorButtonDefault) )
    buttonShare.x = contentWidthSafe - buttonShare.width / 1.2
    buttonShare.y = contentHeightSafe - buttonShare.height / 1.2
    menuGroup:insert(buttonShare)

    local optionsButtonRate = 
    {
        id = "rateGame",
        defaultFile = "assets/menu/rateGame.png",
        width = widthUIButton,
        height = heightUIButton,
        onEvent = handleTouch,
    }
    local buttonRate = widget.newButton( optionsButtonRate )
    buttonRate:setFillColor( unpack(colorButtonDefault) )
    buttonRate.x = display.contentCenterX
    buttonRate.y = contentHeightSafe - buttonRate.height / 1.2
    menuGroup:insert(buttonRate)

    -- A rate game button will be displayed if we asked player to rate the game
    if (not composer.getVariable( "askedRateGame" )) then
        buttonRate.isVisible = false
    end

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

    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30

    frameButtonCredits = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    frameButtonCredits.id = "credits"
    frameButtonCredits:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonCredits.strokeWidth = strokeWidthButtons
    frameButtonCredits:setStrokeColor( unpack(colorButtonStroke) )
    frameButtonCredits:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonCredits )

    local optionsLabelCredits = { text = sozluk.getString("credits"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonCredits.textLabel = display.newText( optionsLabelCredits )
    frameButtonCredits.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonCredits.textLabel.x = frameButtonCredits.x
    menuGroup:insert(frameButtonCredits.textLabel)

    frameButtonCredits.height = frameButtonCredits.textLabel.height * 2
    frameButtonCredits.y = buttonShare.y - buttonShare.height / 2 - frameButtonCredits.height
    frameButtonCredits.textLabel.y = frameButtonCredits.y

    frameButtonSettings = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, frameButtonCredits.height, cornerRadiusButtons )
    frameButtonSettings.id = "settings"
    frameButtonSettings:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonSettings.strokeWidth = strokeWidthButtons
    frameButtonSettings:setStrokeColor( unpack(colorButtonStroke) )
    frameButtonSettings.y = frameButtonCredits.y - frameButtonCredits.height / 2 - frameButtonSettings.height / 1.2
    frameButtonSettings:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonSettings )

    local optionsLabelSettings = { text = sozluk.getString("settings"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonSettings.textLabel = display.newText( optionsLabelSettings )
    frameButtonSettings.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonSettings.textLabel.x, frameButtonSettings.textLabel.y = frameButtonSettings.x, frameButtonSettings.y
    menuGroup:insert(frameButtonSettings.textLabel)

    frameButtonPlay = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, frameButtonCredits.height * 1.5, cornerRadiusButtons )
    frameButtonPlay.id = "play"
    frameButtonPlay:setFillColor( unpack(colorButtonFillDefault) )
    frameButtonPlay.strokeWidth = strokeWidthButtons * 3
    frameButtonPlay:setStrokeColor( unpack(colorButtonStroke) )
    frameButtonPlay.y = frameButtonSettings.y - frameButtonSettings.height / 2 - frameButtonPlay.height
    frameButtonPlay:addEventListener( "touch", handleTouch )
    menuGroup:insert( frameButtonPlay )


    -- If there is a save available, "Start" will be shown as "Continue"
    local textLabelPlay = sozluk.getString("startGame")
    if (savedRandomSeed ~= 0) then
        textLabelPlay = sozluk.getString("continueGame")
        frameButtonPlay.id = "continue"
    end
    local optionsLabelPlay = { text = textLabelPlay, 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    frameButtonPlay.textLabel = display.newText( optionsLabelPlay )
    frameButtonPlay.textLabel:setFillColor( unpack(colorTextDefault) )
    frameButtonPlay.textLabel.x, frameButtonPlay.textLabel.y = frameButtonPlay.x, frameButtonPlay.y
    menuGroup:insert(frameButtonPlay.textLabel)


    buttonLockQuestionSet = display.newImageRect( menuGroup, "assets/menu/padlock.png", widthUIButton, heightUIButton )
    buttonLockQuestionSet:setFillColor( unpack(colorPadlock) )
    buttonLockQuestionSet.id = "lockQuestionSet"
    buttonLockQuestionSet.isActivated = false
    buttonLockQuestionSet.x = frameButtonPlay.x + frameButtonPlay.width / 2 + buttonLockQuestionSet.width / 1.5
    buttonLockQuestionSet.y = frameButtonPlay.y
    buttonLockQuestionSet.alpha = 0.3
    buttonLockQuestionSet.alphaInactive = buttonLockQuestionSet.alpha
    buttonLockQuestionSet:addEventListener( "touch", handleTouch )

    
    local optionsTitleText = { text = "?", 
        height = 0, align = "center", font = fontLogo, fontSize = contentHeightSafe / 5 }
    local logoTitle = display.newText( optionsTitleText )
    logoTitle:setFillColor( unpack(themeData.colorButtonFillTrue) )
    logoTitle.x = display.contentCenterX
    logoTitle.y = frameButtonPlay.y - frameButtonPlay.height / 2 - logoTitle.height / 1.8
    menuGroup:insert(logoTitle)

    -- Load particle file depending on selected theme
    local fileParticleFX = "assets/particleFX/torch.json"
    if (themeData.themeSelected == "light") then
        fileParticleFX = "assets/particleFX/torch-light.json"
    end

    menuGroup.emitterFXLeft = particleDesigner.newEmitter( fileParticleFX )
    menuGroup.emitterFXLeft.x = frameButtonPlay.x - frameButtonPlay.width / 3
    menuGroup.emitterFXLeft.y = logoTitle.y + logoTitle.height / 4
    menuGroup:insert(menuGroup.emitterFXLeft)

    menuGroup.emitterFXRight = particleDesigner.newEmitter( fileParticleFX )
    menuGroup.emitterFXRight.x = frameButtonPlay.x + frameButtonPlay.width / 3
    menuGroup.emitterFXRight.y = menuGroup.emitterFXLeft.y
    menuGroup:insert(menuGroup.emitterFXRight)


    --coinsAvailable = 250

    -- Create coin-lock conversion UI
    frameButtonConvert = display.newRoundedRect( display.contentCenterX, 0, 0, 0, cornerRadiusButtons )
    frameButtonConvert.id = "convertCurrency"
    frameButtonConvert:setFillColor( unpack(colorButtonFillDefault) )
    --frameButtonConvert.strokeWidth = strokeWidthButtons * 3
    --frameButtonConvert:setStrokeColor( unpack(colorButtonFillDefault) )
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

    local fontSizeCurrency = menuGroup.imageLock.height / 1.1

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
    menuGroup.textNumCoins:setFillColor( unpack( colorTextDefault ) )
    menuGroup.textNumCoins.x = frameButtonPlay.x + frameButtonPlay.width / 2 - menuGroup.textNumCoins.width / 2
    menuGroup.textNumCoins.y = menuGroup.imageLock.y
    menuGroup:insert(menuGroup.textNumCoins)

    menuGroup.imageCoin = display.newCircle( menuGroup, 0, menuGroup.imageLock.y, menuGroup.imageLock.width / 2 )
    --menuGroup.imageCoin:setFillColor( unpack( colorButtonDefault ) )
    menuGroup.imageCoin:setFillColor( unpack( colorButtonOver ) )
    menuGroup.imageCoin.x = menuGroup.textNumCoins.x - menuGroup.textNumCoins.width / 2 - menuGroup.imageCoin.width
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


    -- Show lock icon if a save file is available
    local lastRandomSeed = composer.getVariable( "lastRandomSeed" )
    if (lastRandomSeed == 0 or savedRandomSeed ~= 0) then
        buttonLockQuestionSet.alpha = 0
    end
end

-- Handle touch events for permission dialog box
local function handlePermissionTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "openURL") then
            if (event.target.underline) then
                event.target.underline:setFillColor( unpack( themeData.colorHyperlinkDarkVisited ) )
            end

            system.openURL( event.target.URL )
        elseif (event.target.id == "acceptTerms") then
            composer.setVariable( "isTermsPrivacyAccepted", true )

            savePreferences()

            utils.clearDisplayGroup(infoGroup)
        end
    end
    return true
end

-- Show dialog box for privacy policy and terms of use permission request
-- Privacy policy and terms of use documents are linked here
local function showPermissionRequest()
    infoGroup.alpha = 0

    local backgroundShade = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = 1
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameTermsPrivacyRequest = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameTermsPrivacyRequest:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local heightPermissionButton = contentHeightSafe / 14
    local widthPermissionButton = heightPermissionButton
    local yDistanceElements = heightPermissionButton / 2
    local fontSizeInformation = contentHeightSafe / 30
    
    local fontSizePolicy = heightPermissionButton / 3
    local colorHyperlink = themeData.colorHyperlink
    local colorHyperlinkDark = themeData.colorHyperlinkDark
    local colorHyperlinkVisited = themeData.colorHyperlinkVisited
    local colorHyperlinkDarkVisited = themeData.colorHyperlinkDarkVisited

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons


    local optionsTermsPrivacyRequest = { text = sozluk.getString("termsRequest"), font = fontLogo, fontSize = fontSizeInformation,
                                width = frameTermsPrivacyRequest.width / 1.1, height = 0, align = "center" }
    local textTermsPrivacyRequest = display.newText( optionsTermsPrivacyRequest )
    textTermsPrivacyRequest:setFillColor( unpack(themeData.colorBackground) )
    textTermsPrivacyRequest.x = display.contentCenterX
    infoGroup:insert(textTermsPrivacyRequest)

    local optionsButtonAcceptTerms =
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = frameTermsPrivacyRequest.width / 1.1,
        height = heightPermissionButton,
        cornerRadius = cornerRadiusButtons,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        label = sozluk.getString("termsRequestAccept"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizePolicy,
        id = "acceptTerms",
        onEvent = handlePermissionTouch,
    }
    local buttonAcceptTerms = widget.newButton( optionsButtonAcceptTerms )
    buttonAcceptTerms.x = display.contentCenterX
    infoGroup:insert( buttonAcceptTerms )

    local optionsButtonPrivacyPolicy = 
    {
        label = sozluk.getString("privacyPolicy"),
        width = widthPermissionButton,
        height = heightPermissionButton,
        textOnly = true,
        font = fontLogo,
        fontSize = fontSizePolicy,
        labelColor = { default = { unpack(colorHyperlinkDark) }, over = { unpack(colorHyperlinkDarkVisited) } },
        id = "openURL",
        onEvent = handlePermissionTouch,
    }
    local buttonPrivacyPolicy = widget.newButton( optionsButtonPrivacyPolicy )
    buttonPrivacyPolicy.URL = "https://sekodev.github.io/games/privacy/privacyPolicy-" .. currentLanguage .. ".html"
    buttonPrivacyPolicy.x = display.contentCenterX
    infoGroup:insert(buttonPrivacyPolicy)

    buttonPrivacyPolicy.underline = display.newRect( infoGroup, buttonPrivacyPolicy.x, 0, buttonPrivacyPolicy.width, 5 )
    buttonPrivacyPolicy.underline:setFillColor( unpack( colorHyperlinkDark ) )

    local optionsButtonTermsUse = 
    {
        label = sozluk.getString("termsUse"),
        width = widthPermissionButton,
        height = heightPermissionButton,
        textOnly = true,
        font = fontLogo,
        fontSize = fontSizePolicy,
        labelColor = { default = { unpack(colorHyperlinkDark) }, over = { unpack(colorHyperlinkDarkVisited) } },
        id = "openURL",
        onEvent = handlePermissionTouch,
    }
    local buttonTermsUse = widget.newButton( optionsButtonTermsUse )
    buttonTermsUse.URL = "https://sekodev.github.io/games/terms/termsUse-" .. currentLanguage .. ".html"
    buttonTermsUse.x = display.contentCenterX
    infoGroup:insert(buttonTermsUse)

    buttonTermsUse.underline = display.newRect( infoGroup, buttonTermsUse.x, 0, buttonTermsUse.width, 5 )
    buttonTermsUse.underline:setFillColor( unpack( colorHyperlinkDark ) )

    frameTermsPrivacyRequest.height = textTermsPrivacyRequest.height + buttonAcceptTerms.height + buttonPrivacyPolicy.height + buttonTermsUse.height + yDistanceElements * 3.5
    frameTermsPrivacyRequest.y = display.contentCenterY
    textTermsPrivacyRequest.y = frameTermsPrivacyRequest.y - frameTermsPrivacyRequest.height / 2 + textTermsPrivacyRequest.height / 2 + yDistanceElements

    buttonTermsUse.y = textTermsPrivacyRequest.y + textTermsPrivacyRequest.height / 2 + buttonTermsUse.height / 2 + yDistanceElements
    buttonTermsUse.underline.y = buttonTermsUse.y + buttonTermsUse.height / 2

    buttonPrivacyPolicy.y = buttonTermsUse.y + buttonTermsUse.height / 2 + buttonPrivacyPolicy.height
    buttonPrivacyPolicy.underline.y = buttonPrivacyPolicy.y + buttonPrivacyPolicy.height / 2

    buttonAcceptTerms.y = buttonPrivacyPolicy.y + buttonPrivacyPolicy.height / 2 + buttonAcceptTerms.height / 2 + yDistanceElements

    infoGroup.alpha = 1
end

-- Increase lock price as the player advances through the game, unlocks more question sets
local function calculateLockPrice()
    local numAvailableQuestionSets = #composer.getVariable("availableQuestionSets")
    priceLockCoins = priceLockCoins * math.round(numAvailableQuestionSets / 2)

    if (priceLockCoins < composer.getVariable("priceLockCoins")) then
        priceLockCoins = composer.getVariable("priceLockCoins")
    end
end

-- Handle system events such as resuming/suspending the game/application
function onSystemEvent(event)
    if( event.type == "applicationResume" ) then
        utils.resumeTimers(tableTimers)
    elseif( event.type == "applicationSuspend" ) then
        utils.pauseTimers(tableTimers)
    elseif( event.type == "applicationExit" ) then
        
    end
end

-- Transition from ingame music to menu theme
local function handleAudioTransition()
    local fadeTime = 500

    audio.fadeOut( {channel = channelMusicBackground, time = fadeTime} )

    local timerAudio = timer.performWithDelay( fadeTime + 50, function ()
        audio.dispose( streamMusicBackground )

        streamMusicBackground = audio.loadStream("assets/music/menuTheme.mp3")
        channelMusicBackground = audio.play(streamMusicBackground, {loops = -1})
        audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
     end, 1)
    table.insert( tableTimers, timerAudio )
end

function scene:create( event )
    mainGroup = self.view
    menuGroup = display.newGroup( )
    loadingGroup = display.newGroup( )
    shareGroup = display.newGroup( )
    infoGroup = display.newGroup( )

    calculateLockPrice()
    
    local tableFileNames = { "answerChosen.wav", "answerRight.wav", "answerWrong.wav", "lockQuestionSet.wav", "campfire.mp3" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)

    createMenuElements()

    mainGroup:insert(loadingGroup)
    mainGroup:insert(menuGroup)
    mainGroup:insert(shareGroup)
    mainGroup:insert(infoGroup)
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        if (event.params) then
            -- If scene is called from endScreen or gameScreen we need smooth audio transition to menu theme
            if (event.params["callSource"] == "endScreen" or "gameScreen" == event.params["callSource"]) then
                handleAudioTransition()
            end
        end

        -- Start checking for conversion availability
        -- If minimum number of coins are available to purchase a single(1) lock, vibration animation will start
        -- Animation won't stop until conversion is triggered
        local timerConversionCheck
        timerConversionCheck = timer.performWithDelay( 3000, function ()
                --local coinsAvailable = tonumber(menuGroup.textNumCoins.text)

                if (coinsAvailable >= priceLockCoins) then
                    commonMethods.showConversionAvailability(frameButtonConvert)
                else
                    timer.cancel(timerConversionCheck)
                    timerConversionCheck = nil
                end
            end, -1 )
        table.insert( tableTimers, timerConversionCheck )

        composer.removeHidden()
        composer.setVariable("currentAppScene", "menuScreen")

        -- Show user dialog box for privacy policy and terms of use upon first start
        local isTermsPrivacyAccepted = composer.getVariable( "isTermsPrivacyAccepted" )
        if (not isTermsPrivacyAccepted) then
            showPermissionRequest()
        end

        audio.setVolume( composer.getVariable( "soundLevel" ), {channel = 3} )
        audio.play( tableSoundFiles["campfire"], {channel = 3, loops = -1} )

        Runtime:addEventListener( "system", onSystemEvent )
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