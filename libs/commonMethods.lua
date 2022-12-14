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


return commonMethods