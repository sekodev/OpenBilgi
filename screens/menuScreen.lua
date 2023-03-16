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

local mainGroup, menuGroup, shareGroup, infoGroup, URLGroup

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

local URLselected = ""

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
                        tableTimers, locksAvailable = commonMethods.useLock(infoGroup, tableTimers, locksAvailable, menuGroup.textNumLocks)
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

                commonMethods.showShareUI(shareGroup)
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
                        commonMethods.showLocksAvailable(infoGroup, yTopFrame, locksAvailable)
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
                            commonMethods.showLocksAvailable(infoGroup, yTopFrame, locksAvailable)
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

-- Close progress reset dialog box
local function closeDialogBox()
    utils.clearDisplayGroup(URLGroup)
end

-- Open URL after user confirmation
local function openURL()
    system.openURL( URLselected )
    closeDialogBox()
end

-- Handle touch events for permission dialog box
local function handlePermissionTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "openURL") then
            URLselected = event.target.URL

            if (event.target.underline) then
                event.target.underline:setFillColor( unpack( themeData.colorHyperlinkPopupVisited ) )
            end

            local dialogTextBody = sozluk.getString("openURLQuestion") .. "\n\n" .. URLselected

            -- Declare options for dialog box creation
            local optionsDialogBox = {
                fontDialog = fontLogo,
                dialogText = dialogTextBody,
                confirmText = sozluk.getString("openURLConfirm"),
                confirmFunction = openURL,
                denyText = sozluk.getString("openURLDeny"),
                denyFunction = closeDialogBox,
            }

            utils.showDialogBox(URLGroup, optionsDialogBox)
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
    local colorHyperlinkPopup = themeData.colorHyperlinkPopup
    local colorHyperlinkPopupVisited = themeData.colorHyperlinkPopupVisited

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
        labelColor = { default = { unpack(colorHyperlinkPopup) }, over = { unpack(colorHyperlinkPopupVisited) } },
        id = "openURL",
        onEvent = handlePermissionTouch,
    }
    local buttonPrivacyPolicy = widget.newButton( optionsButtonPrivacyPolicy )
    buttonPrivacyPolicy.URL = "https://sekodev.github.io/games/privacy/privacyPolicy-" .. currentLanguage .. ".html"
    buttonPrivacyPolicy.x = display.contentCenterX
    infoGroup:insert(buttonPrivacyPolicy)

    buttonPrivacyPolicy.underline = display.newRect( infoGroup, buttonPrivacyPolicy.x, 0, buttonPrivacyPolicy.width, 5 )
    buttonPrivacyPolicy.underline:setFillColor( unpack( colorHyperlinkPopup ) )

    local optionsButtonTermsUse = 
    {
        label = sozluk.getString("termsUse"),
        width = widthPermissionButton,
        height = heightPermissionButton,
        textOnly = true,
        font = fontLogo,
        fontSize = fontSizePolicy,
        labelColor = { default = { unpack(colorHyperlinkPopup) }, over = { unpack(colorHyperlinkPopupVisited) } },
        id = "openURL",
        onEvent = handlePermissionTouch,
    }
    local buttonTermsUse = widget.newButton( optionsButtonTermsUse )
    buttonTermsUse.URL = "https://sekodev.github.io/games/terms/termsUse-" .. currentLanguage .. ".html"
    buttonTermsUse.x = display.contentCenterX
    infoGroup:insert(buttonTermsUse)

    buttonTermsUse.underline = display.newRect( infoGroup, buttonTermsUse.x, 0, buttonTermsUse.width, 5 )
    buttonTermsUse.underline:setFillColor( unpack( colorHyperlinkPopup ) )

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
        audio.stop()
        audio.dispose( streamMusicBackground )

        streamMusicBackground = audio.loadStream("assets/music/menuTheme.mp3")
        channelMusicBackground = audio.play(streamMusicBackground, {channel = channelMusicBackground, loops = -1})
        audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
     end, 1)
    table.insert( tableTimers, timerAudio )
end

function scene:create( event )
    mainGroup = self.view
    menuGroup = display.newGroup( )
    shareGroup = display.newGroup( )
    infoGroup = display.newGroup( )
    URLGroup = display.newGroup( )

    priceLockCoins = commonMethods.calculateLockPrice(priceLockCoins)
    
    local tableFileNames = { "answerChosen.wav", "answerRight.wav", "answerWrong.wav", "lockQuestionSet.wav", "campfire.mp3" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)

    createMenuElements()

    mainGroup:insert(menuGroup)
    mainGroup:insert(shareGroup)
    mainGroup:insert(infoGroup)
    mainGroup:insert(URLGroup)
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