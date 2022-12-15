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

-- This file gathers project specific common methods that are used in different screens
-- Using those methods in other projects will probably require significant modifications

local commonMethods = {}

local widget = require ( "widget" )

-- Used in endScreen and menuScreen to format currency shown in UI
function commonMethods.formatCurrencyString(coinsAvailable)
    local currencyAbbreviation = ""
    local currencyShort = 0

    if (coinsAvailable >= 1000) then
        currencyAbbreviation = sozluk.getString("currencyThousand")

        local remainderCoin = 100
        if (coinsAvailable % remainderCoin < remainderCoin) then
            currencyShort = coinsAvailable - (coinsAvailable % remainderCoin)
        end
        currencyShort = string.format( "%3.1f", coinsAvailable / 1000 )
    else
        currencyShort = coinsAvailable
    end

    return currencyShort, currencyAbbreviation
end

-- Animate conversion elements to draw players' attention to the game mechanic
function commonMethods.showConversionAvailability(frameButtonConvert)
    local timeShake = 75
    local rotationShake = 20

    local colorButtonFillTrue = themeData.colorButtonFillTrue
    local colorTextDefault = themeData.colorTextDefault

    frameButtonConvert.textLabel:setFillColor( unpack(colorButtonFillTrue) )

    transition.to( frameButtonConvert.textLabel, { time = timeShake, xScale = 1.5, yScale = 1.5, onComplete = function ()
            transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                        transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = rotationShake, onComplete = function ()
                            transition.to( frameButtonConvert.textLabel, { time = timeShake, rotation = -rotationShake, onComplete = function ()
                                transition.to( frameButtonConvert.textLabel, { time = timeShake, xScale = 1, yScale = 1, onComplete = function ()
                                        frameButtonConvert.textLabel.rotation = 0
                                        frameButtonConvert.textLabel:setFillColor( unpack(colorTextDefault) )
                                    end })
                                end })
                        end })
                    end })
            end })
        end })
end

function commonMethods.showLocksAvailable(targetGroup, yTopInfoBox, locksAvailable, fontLockText)
    local widthUIButton = contentWidthSafe / 9
    local heightUIButton = widthUIButton

    local imageLock = display.newImageRect( targetGroup, "assets/menu/padlock.png", widthUIButton, heightUIButton )
    imageLock:setFillColor( unpack(themeData.colorPadlock) )
    imageLock.x = display.contentCenterX - imageLock.width / 2
    imageLock.y = yTopInfoBox - imageLock.height

    local fontSizeCurrency = imageLock.height / 1.1

    local optionsNumLocks = { text = locksAvailable, font = fontLockText, fontSize = fontSizeCurrency }
    imageLock.textNumAvailable = display.newText( optionsNumLocks )
    imageLock.textNumAvailable:setFillColor( unpack(themeData.colorTextDefault) )
    imageLock.textNumAvailable.x = imageLock.x + imageLock.width / 2 + imageLock.textNumAvailable.width
    imageLock.textNumAvailable.y = imageLock.y
    targetGroup:insert(imageLock.textNumAvailable)
end

-- Hide tooltip for coins needed
function commonMethods.hideCoinsNeeded(infoGroup)
    transition.to( infoGroup, { time = 100, alpha = 0, onComplete = function() 
            utils.clearDisplayGroup(infoGroup)
        end })
end

-- Create tooltip to show minimum number of coins needed to convert to a single(1) lock
function commonMethods.showCoinsNeeded(infoGroup, priceLockCoins, frameButtonPlay, fontInformation)
    local colorBackground = themeData.colorBackground
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorPadlock = themeData.colorPadlock

    local widthUIButton = contentWidthSafe / 9
    local heightUIButton = widthUIButton


    infoGroup.alpha = 0

    local imageLock = display.newImageRect( infoGroup, "assets/menu/padlock.png", widthUIButton / 1.5, heightUIButton / 1.5 )
    imageLock:setFillColor( unpack(colorPadlock) )
    imageLock.x = frameButtonPlay.x - frameButtonPlay.width / 2 + imageLock.width / 2
    imageLock.y = display.safeScreenOriginY + (imageLock.height / 1.5) * 4

    local fontSizeCurrency = imageLock.height / 1.1

    local optionsNumLocks = { text = "= ", font = fontInformation, fontSize = fontSizeCurrency }
    local textNumLocks = display.newText( optionsNumLocks )
    textNumLocks:setFillColor( unpack(colorTextDefault) )
    textNumLocks.x = imageLock.x + imageLock.width + textNumLocks.width / 2
    textNumLocks.y = imageLock.y
    infoGroup:insert(textNumLocks)

    local imageCoin = display.newCircle( infoGroup, 0, imageLock.y, imageLock.width / 2 )
    imageCoin:setFillColor( unpack( colorButtonOver ) )
    imageCoin.x = textNumLocks.x + textNumLocks.width / 2 + imageCoin.width / 2
    imageCoin.y = textNumLocks.y

    imageCoin.symbolCurrency = display.newRect( infoGroup, imageCoin.x, imageCoin.y, imageCoin.width / 3, imageCoin.height / 3 )
    imageCoin.symbolCurrency:setFillColor( unpack( colorBackground ) )
    imageCoin.symbolCurrency.rotation = 45

    local optionsNumCoins = { text = priceLockCoins, font = fontInformation, fontSize = fontSizeCurrency }
    local textNumCoins = display.newText( optionsNumCoins )
    textNumCoins:setFillColor( unpack(colorTextDefault) )
    textNumCoins.x = imageCoin.x + imageCoin.width + textNumCoins.width / 2
    textNumCoins.y = imageLock.y
    infoGroup:insert(textNumCoins)


    local widthWarningElements = (textNumCoins.x + textNumCoins.width / 2) - (imageLock.x - imageLock.width / 2)
    local xDistanceSides = (contentWidthSafe - widthWarningElements) / 2

    imageLock.x = xDistanceSides + imageLock.width / 2
    textNumLocks.x = imageLock.x + imageLock.width + textNumLocks.width / 2
    imageCoin.x = textNumLocks.x + textNumLocks.width / 2 + imageCoin.width / 2
    imageCoin.symbolCurrency.x = imageCoin.x
    textNumCoins.x = imageCoin.x + imageCoin.width + textNumCoins.width / 2


    transition.to( infoGroup, { time = 100, alpha = 1 })
end

-- Adjust conversion element positions after coins are converted to lock(s)
function commonMethods.adjustConvertElements(menuGroup, frameButtonPlay)
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

-- Handles touch events when in-game share UI is shown
local function handleShareTouch(event)
    if (event.phase == "ended") then
        local sharedGame = composer.getVariable( "sharedGame" )
        local percentageRevival = composer.getVariable( "percentageRevival" )

        local shareGroup = event.target.refGroup

        if (event.target.id == "shareCancel") then
            utils.clearDisplayGroup(shareGroup)
        elseif (event.target.id == "shareStoreQR") then
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
        end
    end

    return true
end

-- Create share UI that shows two options - QR code or system(OS) share UI
function commonMethods.showShareUI(shareGroup, fontNameUI)
    local colorBackground = themeData.colorBackground
    local colorBackgroundPopup = themeData.colorBackgroundPopup

    local backgroundShade = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(colorBackground) )
    backgroundShade.alpha = .8
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameShareOptions = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameShareOptions:setFillColor( unpack(colorBackgroundPopup) )


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
        font = fontNameUI,
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
        font = fontNameUI,
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
        font = fontNameUI,
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


    -- Add a reference to display group so we can use it in handleShareTouch()
    buttonShareLink.refGroup = shareGroup
    buttonShareQR.refGroup = shareGroup
    buttonBack.refGroup = shareGroup
end


return commonMethods