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


return commonMethods