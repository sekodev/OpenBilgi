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

local utils = {}


function utils.resumeTimers(tableTimers)
    for i = #tableTimers, 1, -1 do
        timer.resume( tableTimers[i] )
    end
end

function utils.pauseTimers(tableTimers)
    for i = #tableTimers, 1, -1 do
        timer.pause( tableTimers[i] )
    end
end

function utils.cancelTimers(tableTimers)
    for i = #tableTimers, 1, -1 do
        timer.cancel( tableTimers[i] )
        tableTimers[i] = nil
    end

    return tableTimers
end

function utils.clearDisplayGroup(targetGroup)
    for i = targetGroup.numChildren, 1, -1 do
        display.remove( targetGroup[i] )
        targetGroup[i] = nil
    end
end

function utils.loadSoundFX()

end

function utils.unloadSoundFX(tableSoundFiles)
    for i = 2, audio.totalChannels do
        audio.stop(i)
    end 

    for k, v in pairs ( tableSoundFiles ) do
        audio.dispose( tableSoundFiles[k] )
        tableSoundFiles[k] = nil
    end

    return tableSoundFiles
end

-- Show share UI based on the operating system
function utils.showSystemShareUI(pathShareAsset, urlLandingPage)
    if (system.getInfo("platform") == "ios" or system.getInfo("platform") == "macos" or system.getInfo("platform") == "tvos") then
        -- Use Activity Popup for iOS
        -- https://docs.coronalabs.com/plugin/CoronaProvider_native_popup_activity/index.html
    else
        local itemsSocial = {
            image = { filename = pathShareAsset, baseDir = system.resourceDirectory },
            url = { urlLandingPage }
        }

        native.showPopup( "social", itemsSocial )
    end
end

-- Show QR code that contains the link to the game
-- Currently links to Google Play page
-- Replace QR code assets to change the link
function utils.showShareQR(shareGroup, pathQRCode)
    local backgroundShade = display.newRect( shareGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.id = "shareCancel"
    backgroundShade:addEventListener( "touch", handleShareTouch )

    local widthQRCode = contentHeightSafe / 2
    local heightQRCode = widthQRCode

    local qrCode = display.newImageRect( shareGroup, pathQRCode, widthQRCode, heightQRCode )
    qrCode.x, qrCode.y = display.contentCenterX, display.contentCenterY
end

-- Show mail UI using the operating system functionality
function utils.showMailUI(mailAddress, mailSubject, mailBody)
    local mailOptions = { to = mailAddress, subject = mailSubject, body = mailBody }

    native.showPopup( "mail", mailOptions )
end


return utils