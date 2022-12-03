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

function utils.closeDatabases(tableDatabases)
    for i = #tableDatabases, 1, -1 do
        if (tableDatabases[i] and tableDatabases[i]:isopen()) then
            tableDatabases[i]:close()
            tableDatabases[i] = nil
        end
    end

    return tableDatabases
end

function utils.closeFiles(tableFiles)
    for i = #tableFiles, 1, -1 do
        if (tableFiles[i]) then
            tableFiles[i]:close()
            tableFiles[i] = nil
        end
    end

    return tableFiles
end

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

function utils.showDialogBox()
    -- Create and show dialog box that is used to ask for consent
end

function utils.showInformationBox()
    -- Create and show dialog box that is used to display information
end

function utils.openURL(urlHyperlink)
    -- Ask for consent to take player out of the app
    -- Show two options: OK or Cancel
    -- If 'OK' -> system.openURL( urlHyperlink )
    -- If 'Cancel' -> close dialog box
end

-- Load short, frequently used sound effects into memory
function utils.loadSoundFX(tableSoundFiles, pathFolder, tableFileNames)
    -- File names come with extension in case we use different file types
    for i = 1, #tableFileNames do
        local nameFile = tableFileNames[i]
        local keyFile = string.sub(nameFile, 1, -5) -- Strip file extension to use file name as key value
        local pathFile = pathFolder .. nameFile

        tableSoundFiles[keyFile] = audio.loadSound( pathFile )
    end

    return tableSoundFiles
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

local function handleShareTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "shareCancel") then
            utils.clearDisplayGroup(event.target.refGroup)
        end
    end
    return true
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
    backgroundShade.refGroup = shareGroup
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