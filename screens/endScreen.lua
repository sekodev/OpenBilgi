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
local particleDesigner = require( "libs.particleDesigner" )
local random = math.random

local mainGroup, menuGroup, scoreGroup, mapGroup, rateGroup, shareGroup, infoGroup

local timeTransitionScene = composer.getVariable( "timeTransitionScene" )
local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local fontSize = display.safeActualContentHeight / 15

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

local frameButtonPlay, frameButtonSettings, frameButtonMainMenu, frameButtonConvert, frameLockQuestionSet
local textScore, labelScore
local textAwardCoinSet, textAwardCoinEarned, textAwardLock
local mapPin

local tableSoundFiles = {}
local tableTimers = {}
local tableCheckpoints = {}


local function cancelTimers()
    for i = #tableTimers, 1, -1 do
        timer.cancel( tableTimers[i] )
        tableTimers[i] = nil
    end
end

local function cleanUp()
    cancelTimers()
    transition.cancel( )

    if (#tableCheckpoints > 0) then
        for i = #tableCheckpoints, 1, -1 do
            tableCheckpoints[i] = {}
            table.remove( tableCheckpoints, i )
        end
    end
end

local function clearDisplayGroup(targetGroup, callSource)
    if (callSource == nil) then
        callSource = ""
    end

    for i = targetGroup.numChildren, 1, -1 do
        display.remove( targetGroup[i] )
        targetGroup[i] = nil
    end
end

local function showMailUI()
    local mailAddress = "info.sleepybug@gmail.com"
    local mailSubject = sozluk.getString("sendSupportMailSubject")
    local mailBody = sozluk.getString("sendSupportMailBody")

    local mailOptions = { to = mailAddress, subject = mailSubject, body = mailBody }

    native.showPopup( "mail", mailOptions )
end

-- Show share UI based on the operating system
local function showShareSystemUI()
    local urlStore = ""
    local pathShareAsset = composer.getVariable( "pathIconFile" ) -- You can change pathIconFile from main.lua

    if (system.getInfo("platform") == "ios" or system.getInfo("platform") == "macos" or system.getInfo("platform") == "tvos") then
        -- You can change store URL from main.lua
        -- urlStore = composer.getVariable( "urlAppStore" )

        -- You need to use Activity Popup for iOS
        -- https://docs.coronalabs.com/plugin/CoronaProvider_native_popup_activity/index.html
    else
        -- You can change store URL from main.lua
        urlStore = composer.getVariable( "urlGooglePlay" )

        local itemsSocial = {
            image = { filename = pathShareAsset, baseDir = system.resourceDirectory },
            url = { urlStore }
        }

        native.showPopup( "social", itemsSocial )
    end
end

-- Show QR code that contains the link to the game
-- Currently links to Google Play page
-- Replace QR code assets to change the link
local function showShareQR()
    local backgroundShade = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.id = "shareCancel"
    backgroundShade:addEventListener( "touch", handleShareTouch )


    -- QR codes will be picked depending on the theme selection-- Handles touch events when in-game share UI is shown
    local fileQRCode = "assets/other/QRCode.png"
    if (composer.getVariable( "currentTheme" ) == "dark") then
        fileQRCode = "assets/other/QRCode.png"
    elseif (composer.getVariable( "currentTheme" ) == "light") then
        fileQRCode = "assets/other/QRCode-light.png"
    end

    local qrCode = display.newImageRect( shareGroup, fileQRCode, display.safeActualContentHeight / 2, display.safeActualContentHeight / 2 )
    qrCode.x, qrCode.y = display.contentCenterX, display.contentCenterY
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

            clearDisplayGroup(shareGroup)
            showShareQR()
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

            clearDisplayGroup(shareGroup)
            showShareSystemUI()
        elseif (event.target.id == "shareCancel") then
            clearDisplayGroup(shareGroup)
        end
    end
    return true
end
-- Create share UI that shows two options - QR code or system(OS) share UI
local function showShareUI()
    local backgroundShade = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .8
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameShareOptions = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth / 1.1, 0 )
    frameShareOptions:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local widthShareButtons = frameShareOptions.width / 1.1
    local heightShareButtons = display.safeActualContentHeight / 10
    local distanceChoices = heightShareButtons / 5
    local fontSizeChoices = (display.safeActualContentHeight / 25) / 1.1

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
-- Create warning box to give user information about the lock system
local function showLockInformation()
    infoGroup.alpha = 0
    
    local backgroundShade = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = 1
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameLockInformation = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth / 1.1, 0 )
    frameLockInformation:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local widthLockInfoButtons = frameLockInformation.width / 1.1
    local heightLockInfoButtons = display.safeActualContentHeight / 10
    local yDistanceElements = heightLockInfoButtons / 3
    local fontSizeInformation = display.safeActualContentHeight / 30

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons

    local infoText
    if (locksAvailable > 0) then
        infoText = sozluk.getString("lockInformation")
    else
        infoText = sozluk.getString("lockInformationNA")
    end

    local optionsLockInformation = { text = infoText, font = fontLogo, fontSize = fontSizeInformation,
                                width = frameLockInformation.width / 1.1, height = 0, align = "center" }
    local textLockInformation = display.newText( optionsLockInformation )
    textLockInformation:setFillColor( unpack(themeData.colorBackground) )
    textLockInformation.x = display.contentCenterX
    infoGroup:insert(textLockInformation)

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillOver, over = colorButtonFillOver },
        width = frameLockInformation.width / 6,
        height = heightLockInfoButtons / 1.5,
        label = "x",
        labelColor = { default = colorButtonFillDefault, over = colorButtonOver },
        font = fontLogo,
        fontSize = heightLockInfoButtons / 2,
        id = "closeLockInfo",
        onEvent = handleTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.anchorX = 0
    buttonBack.x = frameLockInformation.x + frameLockInformation.width / 2 - buttonBack.width
    infoGroup:insert( buttonBack )


    local widthUIButton = display.safeActualContentWidth / 9
    local heightUIButton = widthUIButton

    local imageLock = display.newImageRect( infoGroup, "assets/menu/padlock.png", widthUIButton / 1.5, heightUIButton / 1.5 )
    imageLock:setFillColor( unpack(colorButtonDefault) )
    imageLock.x = frameButtonPlay.x - frameButtonPlay.width / 2 + imageLock.width / 2
    imageLock.y = display.safeScreenOriginY + imageLock.height / 1.5

    local fontSizeCurrency = imageLock.height / 1.1

    local optionsNumLocks = { text = locksAvailable, font = fontLogo, fontSize = fontSizeCurrency }
    infoGroup.textNumLocks = display.newText( optionsNumLocks )
    infoGroup.textNumLocks:setFillColor( unpack(colorTextDefault) )
    infoGroup.textNumLocks.x = menuGroup.textNumLocks.x
    infoGroup.textNumLocks.y = imageLock.y
    infoGroup:insert(infoGroup.textNumLocks)


    local rectHideLockInfo, textHideLockInfo
    --locksAvailable = 1
    if (locksAvailable > 0) then
        rectHideLockInfo = display.newRoundedRect( infoGroup, 0, 0, 1, 1, 5 )
        rectHideLockInfo.id = "hideLockInfoForever"
        rectHideLockInfo.isActivated = false
        rectHideLockInfo:setFillColor( unpack(themeData.colorBackgroundPopup) )
        rectHideLockInfo.strokeWidth = 5
        rectHideLockInfo:setStrokeColor( unpack(themeData.colorBackground) )
        rectHideLockInfo:addEventListener( "touch", handleTouch )

        local optionsHideLockInfo = { text = sozluk.getString("lockInformationHide"), font = fontLogo, fontSize = fontSizeInformation / 1.1,
                                    height = 0, align = "center" }
        textHideLockInfo = display.newText( optionsHideLockInfo )
        textHideLockInfo:setFillColor( unpack(themeData.colorBackground) )
        infoGroup:insert(textHideLockInfo)

        rectHideLockInfo.height = textHideLockInfo.height
        rectHideLockInfo.width = rectHideLockInfo.height

        local optionsRectLockMarker = { text = "X", font = fontLogo, fontSize = rectHideLockInfo.height / 1.1 }
        rectHideLockInfo.markerLock = display.newText( optionsRectLockMarker )
        rectHideLockInfo.markerLock.alpha = 0
        rectHideLockInfo.markerLock:setFillColor( unpack( themeData.colorButtonFillTrue ) )
        infoGroup:insert(rectHideLockInfo.markerLock)

        frameLockInformation.height = textLockInformation.height + textHideLockInfo.height + buttonBack.height + yDistanceElements * 2.5
        frameLockInformation.y = display.contentCenterY + frameLockInformation.height / 3
        buttonBack.y = frameLockInformation.y - frameLockInformation.height / 2 + buttonBack.height / 2

        local xDistanceInfoElements = (frameLockInformation.width - (textHideLockInfo.width + rectHideLockInfo.width)) / 3
        rectHideLockInfo.x = (frameLockInformation.x - frameLockInformation.width / 2) + rectHideLockInfo.width / 2 + xDistanceInfoElements
        rectHideLockInfo.y = (frameLockInformation.y + frameLockInformation.height / 2) - rectHideLockInfo.height / 2 - yDistanceElements
        rectHideLockInfo.markerLock.x = rectHideLockInfo.x
        rectHideLockInfo.markerLock.y = rectHideLockInfo.y

        textHideLockInfo.x = rectHideLockInfo.x + rectHideLockInfo.width / 1.2 + textHideLockInfo.width / 2
        textHideLockInfo.y = rectHideLockInfo.y

        textLockInformation.y = textHideLockInfo.y - textHideLockInfo.height / 2 - textLockInformation.height / 2 - yDistanceElements
        --buttonBack.y = textLockInformation.y - textLockInformation.height / 2 - buttonBack.height / 2 - yDistanceElements
    else
        frameLockInformation.height = textLockInformation.height + buttonBack.height + yDistanceElements * 1.5
        frameLockInformation.y = display.contentCenterY + frameLockInformation.height / 3
        buttonBack.y = frameLockInformation.y - frameLockInformation.height / 2 + buttonBack.height / 2

        textLockInformation.y = (frameLockInformation.y + frameLockInformation.height / 2) - textLockInformation.height / 2 - yDistanceElements
        --buttonBack.y = textLockInformation.y - textLockInformation.height / 2 - buttonBack.height / 2 - yDistanceElements
    end


    imageLock.xTarget = display.contentCenterX - imageLock.width / 2
    imageLock.yTarget = frameLockInformation.y - frameLockInformation.height / 2 - imageLock.height * 2
    infoGroup.textNumLocks.xTarget = imageLock.xTarget + imageLock.width / 2 + infoGroup.textNumLocks.width
    infoGroup.textNumLocks.yTarget = imageLock.yTarget


    local timeTransitionShowInfo = 250
    transition.to( infoGroup, { time = timeTransitionShowInfo, alpha = 1, onComplete = function()
            transition.to( imageLock, { time = timeTransitionShowInfo, x = imageLock.xTarget, y = imageLock.yTarget} )
            transition.to( infoGroup.textNumLocks, { time = timeTransitionShowInfo, x = infoGroup.textNumLocks.xTarget, y = infoGroup.textNumLocks.yTarget} )
        end })
end

-- Hide tooltip for coins needed
local function hideCoinsNeeded()
    transition.to( infoGroup, { time = 100, alpha = 0, onComplete = function() 
            clearDisplayGroup(infoGroup)
        end })
end

-- Create tooltip to show minimum number of coins needed to convert to a single(1) lock
local function showCoinsNeeded()
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault

    local widthUIButton = display.safeActualContentWidth / 9
    local heightUIButton = widthUIButton

    infoGroup.alpha = 0


    local imageLock = display.newImageRect( infoGroup, "assets/menu/padlock.png", widthUIButton / 1.5, heightUIButton / 1.5 )
    imageLock:setFillColor( unpack(colorButtonDefault) )
    imageLock.x = frameButtonPlay.x - frameButtonPlay.width / 2 + imageLock.width / 2
    imageLock.y = display.safeScreenOriginY + (imageLock.height / 1.5) * 4

    local fontSizeCurrency = imageLock.height / 1.1

    local optionsNumLocks = { text = "= ", font = fontLogo, fontSize = fontSizeCurrency }
    local textNumLocks = display.newText( optionsNumLocks )
    textNumLocks:setFillColor( unpack(colorTextDefault) )
    textNumLocks.x = imageLock.x + imageLock.width + textNumLocks.width / 2
    textNumLocks.y = imageLock.y
    infoGroup:insert(textNumLocks)

    local imageCoin = display.newCircle( infoGroup, 0, imageLock.y, imageLock.width / 2 )
    --imageCoin:setFillColor( unpack( colorButtonDefault ) )
    imageCoin:setFillColor( unpack( colorButtonOver ) )
    imageCoin.x = textNumLocks.x + textNumLocks.width / 2 + imageCoin.width / 2
    imageCoin.y = textNumLocks.y

    imageCoin.symbolCurrency = display.newRect( infoGroup, imageCoin.x, imageCoin.y, imageCoin.width / 3, imageCoin.height / 3 )
    imageCoin.symbolCurrency:setFillColor( unpack( themeData.colorBackground ) )
    imageCoin.symbolCurrency.rotation = 45

    local optionsNumCoins = { text = priceLockCoins, font = fontLogo, fontSize = fontSizeCurrency }
    local textNumCoins = display.newText( optionsNumCoins )
    textNumCoins:setFillColor( unpack(colorTextDefault) )
    textNumCoins.x = imageCoin.x + imageCoin.width + textNumCoins.width / 2
    textNumCoins.y = imageLock.y
    infoGroup:insert(textNumCoins)


    local widthWarningElements = (textNumCoins.x + textNumCoins.width / 2) - (imageLock.x - imageLock.width / 2)
    local xDistanceSides = (display.safeActualContentWidth - widthWarningElements) / 2

    imageLock.x = xDistanceSides + imageLock.width / 2
    textNumLocks.x = imageLock.x + imageLock.width + textNumLocks.width / 2
    imageCoin.x = textNumLocks.x + textNumLocks.width / 2 + imageCoin.width / 2
    imageCoin.symbolCurrency.x = imageCoin.x
    textNumCoins.x = imageCoin.x + imageCoin.width + textNumCoins.width / 2


    transition.to( infoGroup, { time = 100, alpha = 1 })
end

-- Adjust conversion element positions after coins are converted to lock(s)
local function adjustConvertElements()
    local timeAdjustElements = 250

    menuGroup.imageLock.xTarget = frameButtonPlay.x - frameButtonPlay.width / 2 + menuGroup.imageLock.width / 2
    menuGroup.textNumLocks.xTarget = menuGroup.imageLock.x + menuGroup.imageLock.width + menuGroup.textNumLocks.width / 2
    menuGroup.textNumCoins.xTarget = frameButtonPlay.x + frameButtonPlay.width / 2 - menuGroup.textNumCoins.width / 2
    menuGroup.imageCoin.xTarget = menuGroup.textNumCoins.x - menuGroup.textNumCoins.width / 2 - menuGroup.imageCoin.width
    menuGroup.imageCoin.symbolCurrency.xTarget = menuGroup.imageCoin.xTarget

    transition.to( menuGroup.imageLock, { time = timeAdjustElements, x = menuGroup.imageLock.xTarget } )
    transition.to( menuGroup.textNumLocks, { time = timeAdjustElements, x = menuGroup.textNumLocks.xTarget } )
    transition.to( menuGroup.textNumCoins, { time = timeAdjustElements, x = menuGroup.textNumCoins.xTarget } )
    transition.to( menuGroup.imageCoin, { time = timeAdjustElements, x = menuGroup.imageCoin.xTarget } )
    transition.to( menuGroup.imageCoin.symbolCurrency, { time = timeAdjustElements, x = menuGroup.imageCoin.symbolCurrency.xTarget } )
end

-- Calculate and show number of coins spent/coins left and number of locks gained in return
local function showCoinsConverted( buttonConverter, locksConverted, coinsConverted, coinsLeft )
    local colorButtonDefault = themeData.colorButtonDefault
    local colorTextDefault = themeData.colorTextDefault

    local widthUIButton = display.safeActualContentWidth / 9
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

                                            adjustConvertElements()

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
                    if (frameLockQuestionSet.isActivated) then
                        useLock()
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
                                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
                                    params = {callSource = "endScreen", scoreCurrent = scoreCurrent,
                                     isSetLocked = frameLockQuestionSet.isActivated, statusGame = statusGame}}
                                composer.gotoScene( "screens." .. targetScreen, optionsChangeScene )
                            end, 1 )
                        table.insert( tableTimers, timerChangeScene )
                    end, 1 )
                table.insert( tableTimers, timerHighlightChoice )
            elseif (event.target.id == "shareSocial") then
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                showShareUI()
            elseif (event.target.id == "showStats") then
                isInteractionAvailable = false

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )

                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene,
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

                                                        showCoinsNeeded()

                                                        local timerHideCoinsNeeded = timer.performWithDelay( 2000, function () 
                                                                hideCoinsNeeded()

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
            if (event.target.id == "shareSocial") then
                event.target:setFillColor( unpack(themeData.colorButtonDefault) )
            elseif (event.target.id == "closeLockInfo") then
                clearDisplayGroup(infoGroup)
            elseif (event.target.id == "hideLockInfoForever") then
                -- If player chose note to see the warning about lock system, don't show again
                if (event.target.isActivated) then
                    event.target.isActivated = false
                    event.target.markerLock.alpha = 0

                    composer.setVariable( "lockInfoAvailable", true )
                    savePreferences()
                else
                    event.target.isActivated = true
                    event.target.markerLock.alpha = 1

                    composer.setVariable( "lockInfoAvailable", false )
                    savePreferences()
                end
            elseif (event.target.id == "lockQuestionSet") then
                local lockInfoAvailable = composer.getVariable( "lockInfoAvailable" )

                -- Only change the flag as activated
                -- This change will be used later on button press("Play") and scene change
                if (event.target.isActivated) then
                    event.target.isActivated = false
                    event.target.alpha = event.target.alphaInactive
                    event.target:setFillColor( unpack(themeData.colorButtonDefault) )
                else
                    audio.play( tableSoundFiles["lockQuestionSet"], {channel = 2} )

                    -- Check to see if information about lock system will be shown
                    -- If player discarded the message and chose "Don't show again", don't show info box
                    if (lockInfoAvailable) then
                        if (locksAvailable > 0) then
                            event.target.isActivated = true
                            event.target.alpha = 1
                            --event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
                        end

                        showLockInformation()
                    else
                        if (locksAvailable > 0) then
                            event.target.isActivated = true
                            event.target.alpha = 1
                            --event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
                        else
                            showLockInformation()
                        end
                    end
                end
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
                emitterFireworks.x = random(display.safeActualContentWidth)
                emitterFireworks.y = random(display.safeActualContentHeight)
                scoreGroup:insert(emitterFireworks)

                audio.play( tableSoundFiles["fireworks"], {channel = 2, loops = numFireworks} )
            end, 1 )
        table.insert(tableTimers, timerFire)
    end
end

-- Animate conversion elements to draw players' attention to the game mechanic
local function showConversionAvailable()
    local timeShake = 75
    local rotationShake = 20

    frameButtonConvert.textLabel:setFillColor( unpack(themeData.colorButtonFillTrue) )

    transition.to( frameButtonConvert.textLabel, { time = timeShake, xScale = 1.5, yScale = 1.5, onComplete = function ()
            transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                        transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                            transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                transition.to( frameButtonConvert.textLabel, { time = timeShake, xScale = 1, yScale = 1, onComplete = function ()
                                        frameButtonConvert.textLabel.rotation = 0
                                        frameButtonConvert.textLabel:setFillColor( unpack(themeData.colorTextDefault) )
                                    end })
                                end })
                        end })
                    end })
            end })
        end })
end

-- Show number of locks the player earned in this run
local function showLocksEarned()
    if (textAwardLock ~= nil) then
        transition.to( textAwardLock, { time = 500, y = menuGroup.textNumLocks.y, alpha = 0, onComplete = function ()
            locksAvailable = locksAvailable + 1
            menuGroup.textNumLocks.text = locksAvailable

            composer.setVariable( "locksAvailable", locksAvailable )

            savePreferences()
        end } )
    end
end

-- Show number of coins player earned in this run
local function showCoinsEarned()
    transition.to( textAwardCoinEarned, { time = 500, y = menuGroup.textNumCoins.y, alpha = 0, onComplete = function ()
        coinsAvailable = coinsAvailable + coinsEarned

        local currencyShort, currencyAbbreviation = formatCurrencyString(coinsAvailable)
        menuGroup.textNumCoins.text = currencyShort .. currencyAbbreviation
        
        -- If player completes a set successfully, will earn a fixed amount of coins(coinsCompletedSet) + coinsEarned
        if (textAwardCoinSet) then
            transition.to( textAwardCoinSet, { time = 500, y = menuGroup.textNumCoins.y, alpha = 0, onComplete = function ()
                coinsAvailable = coinsAvailable + coinsCompletedSet

                local currencyShort, currencyAbbreviation = formatCurrencyString(coinsAvailable)
                menuGroup.textNumCoins.text = currencyShort .. currencyAbbreviation

                composer.setVariable( "coinsAvailable", coinsAvailable )

                local coinsTotal = composer.getVariable( "coinsTotal" ) + coinsEarned
                composer.setVariable( "coinsTotal", coinsTotal )

                savePreferences()
            end } )
        else
            composer.setVariable( "coinsAvailable", coinsAvailable )

            local coinsTotal = composer.getVariable( "coinsTotal" ) + coinsEarned
            composer.setVariable( "coinsTotal", coinsTotal )

            savePreferences()
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

    local mapLine = display.newRect( mapGroup, display.contentCenterX, 0, display.safeActualContentWidth / 1.2, 15 )
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

    local widthMapPin = mapLine.height * 2.5
    mapPin = display.newImageRect( mapGroup, "assets/menu/pinMap.png", widthMapPin, widthMapPin )
    mapPin:setFillColor( unpack(colorTextDefault) )


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
        textScore.xScale, textScore.yScale = display.safeActualContentHeight / 3, textScore.xScale

        labelScore.text = sozluk.getString("highScore")
        labelScore.alpha = 0
        labelScore.xScale, labelScore.yScale = textScore.xScale, textScore.yScale
    end
end

local function createMenuElements()
    local background = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )


    local widthUIButton = display.safeActualContentWidth / 9
    local heightUIButton = widthUIButton

    local widthMenuButtons = display.safeActualContentWidth / 1.5
    local fontSizeButtons = display.safeActualContentHeight / 30
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorTextDefault = themeData.colorTextDefault
    local colorButtonStroke = themeData.colorButtonStroke

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
    buttonShare.x = display.safeActualContentWidth - buttonShare.width / 1.2
    buttonShare.y = display.safeActualContentHeight - buttonShare.height / 1.2
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
    buttonStats.y = display.safeActualContentHeight - buttonStats.height / 1.2
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


    frameLockQuestionSet = display.newImageRect( menuGroup, "assets/menu/padlock.png", widthUIButton, heightUIButton )
    frameLockQuestionSet:setFillColor( unpack(colorButtonDefault) )
    frameLockQuestionSet.id = "lockQuestionSet"
    frameLockQuestionSet.isActivated = false
    frameLockQuestionSet.x = frameButtonPlay.x + frameButtonPlay.width / 2 + frameLockQuestionSet.width / 1.5
    frameLockQuestionSet.y = frameButtonPlay.y
    frameLockQuestionSet.alpha = 0.3
    frameLockQuestionSet.alphaInactive = frameLockQuestionSet.alpha
    frameLockQuestionSet:addEventListener( "touch", handleTouch )


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

    frameButtonConvert.width = display.safeActualContentWidth
    frameButtonConvert.height = frameButtonConvert.textLabel.height


    -- Lock asset is created, will be hidden if not available
    menuGroup.imageLock = display.newImageRect( menuGroup, "assets/menu/padlock.png", widthUIButton / 1.5, heightUIButton / 1.5 )
    menuGroup.imageLock:setFillColor( unpack(colorButtonDefault) )
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
    local currencyShort, currencyAbbreviation = formatCurrencyString(coinsAvailable)
    local optionsNumCoins = { text = currencyShort .. currencyAbbreviation, font = fontLogo, fontSize = fontSizeCurrency }
    menuGroup.textNumCoins = display.newText( optionsNumCoins )
    menuGroup.textNumCoins:setFillColor( unpack(colorTextDefault) )
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
        frameLockQuestionSet.alpha = 0
    end
end

-- Show rating UI depending on the operating system
local function showRateUI()
	if (system.getInfo("platform") == "ios" or system.getInfo("platform") == "macos" or system.getInfo("platform") == "tvos") then
		-- local idAppStore = "1234567890" -- placeholder
        -- https://solar2dmarketplace.com/plugins?ReviewPopUp_tech-scotth
	else
	    local namePackage = composer.getVariable( "packageName" )
	    local storeSupported = { "google" }

	    local optionsRateGame = {
	        --iOSAppId = idAppStore,
	        androidAppPackageName = namePackage,
	        supportedAndroidStores = storeSupported
	    }
	    native.showPopup( "appStore", optionsRateGame )
	end
end

local function handleRatingTouch(event)
    if (event.phase == "ended") then
		if (event.target.id == "rateOK") then
			composer.setVariable( "askedRateGame", true )
            savePreferences()

            clearDisplayGroup(rateGroup)
			showRateUI()
		elseif (event.target.id == "rateLater") then
            -- This option is NOT used to ask for ratings later
			composer.setVariable( "askedRateGame", true )
            savePreferences()

            clearDisplayGroup(rateGroup)
		elseif (event.target.id == "sendFeedback") then
            composer.setVariable( "askedRateGame", true )
            savePreferences()

            clearDisplayGroup(rateGroup)
            showMailUI()
		end
	end
	return true
end

-- Show a dialog box asking to rate the game
-- This is only shown once. After that, game only shows a rate button and leaves it up to the player
function createAskRatingElements()
    local backgroundShade = display.newRect( rateGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .9
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )


    local fontSizeQuestion = display.safeActualContentHeight / 30

    local frameQuestionRating = display.newRect( rateGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth / 1.1, 0 )
    frameQuestionRating:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local optionsTextRating = { text = sozluk.getString("ratingAsk"), 
        width = frameQuestionRating.width / 1.1, height = 0, align = "center", font = fontLogo, fontSize = fontSizeQuestion }
    frameQuestionRating.textLabel = display.newText( optionsTextRating )
    frameQuestionRating.textLabel:setFillColor( unpack(themeData.colorBackground) )
    frameQuestionRating.textLabel.x = frameQuestionRating.x
    rateGroup:insert(frameQuestionRating.textLabel)


    local widthRateButtons = frameQuestionRating.width / 1.1
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

-- Increase lock price as the player advances through the game, unlocks more question sets
local function calculateLockPrice()
    local numAvailableQuestionSets = #composer.getVariable("availableQuestionSets")
    priceLockCoins = priceLockCoins * math.round(numAvailableQuestionSets / 2)

    if (priceLockCoins < composer.getVariable("priceLockCoins")) then
        priceLockCoins = composer.getVariable("priceLockCoins")
    end
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

-- Load short, frequently used sound effects into memory
local function loadSoundFX()
    tableSoundFiles["answerChosen"] = audio.loadSound( "assets/soundFX/answerChosen.wav" )
    tableSoundFiles["answerRight"] = audio.loadSound( "assets/soundFX/answerRight.wav" )
    tableSoundFiles["answerWrong"] = audio.loadSound( "assets/soundFX/answerWrong.wav" )
    tableSoundFiles["fireworks"] = audio.loadSound( "assets/soundFX/fireworks.wav" )
    tableSoundFiles["lockQuestionSet"] = audio.loadSound( "assets/soundFX/lockSet.wav" )
end

local function handleAudioTransition()
    audio.dispose( streamMusicBackground )

    streamMusicBackground = audio.loadStream("assets/music/questionsTheme.mp3")
    channelMusicBackground = audio.play(streamMusicBackground, {loops = -1})
    audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
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

    calculateLockPrice()
    loadSoundFX()
    checkHighScore()
--isRecordBroken = true
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
                handleAudioTransition()
            end
        end


        local gamesPlayed = composer.getVariable( "gamesPlayed" )
        local askedRateGame = composer.getVariable( "askedRateGame" )

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
                    showConversionAvailable()
                else
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