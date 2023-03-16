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

-- This file gathers functions that can be used in different projects
-- Using those functions in other projects may require little to no modifications

local utils = {}

local widget = require ( "widget" )


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

local function handleInfoBoxTouch(event)
    if (event.phase == "ended" or "cancelled" == event.phase) then
        if (event.target.id == "closeInfoBox") then
            utils.clearDisplayGroup(event.target.refGroup)
        elseif (event.target.id == "hideInfoForever") then
            -- If player chose note to see the warning about lock system, don't show again
            if (event.target.markerPrompt.isActivated) then
                event.target.markerPrompt.isActivated = false
                event.target.markerPrompt.alpha = 0

                local stringPromptPreference = event.target.markerPrompt.stringPromptPreference
                composer.setVariable( stringPromptPreference, true )

                savePreferences()
            else
                event.target.markerPrompt.isActivated = true
                event.target.markerPrompt.alpha = 1

                local stringPromptPreference = event.target.markerPrompt.stringPromptPreference
                composer.setVariable( stringPromptPreference, false )

                savePreferences()
            end
        end
    end

    return true
end

-- Create and show dialog box that is used to display information
function utils.showInformationBox(infoGroup, infoText, infoFont, isPromptAvailable, stringPromptPreference)
    infoGroup.alpha = 0

    local backgroundShade = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = 1
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    frameInformation = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameInformation:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local widthButton = frameInformation.width / 1.1
    local heightButton = contentHeightSafe / 10
    local yDistanceElements = heightButton / 2
    local fontSizeInformation = contentHeightSafe / 30

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons


    local optionsLockInformation = { text = infoText, font = infoFont, fontSize = fontSizeInformation,
                                width = widthButton, height = 0, align = "center" }
    local textLockInformation = display.newText( optionsLockInformation )
    textLockInformation:setFillColor( unpack(themeData.colorBackground) )
    textLockInformation.x = display.contentCenterX
    infoGroup:insert(textLockInformation)

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillOver, over = colorButtonFillOver },
        width = frameInformation.width / 6,
        height = heightButton / 1.5,
        label = "x",
        labelColor = { default = colorButtonFillDefault, over = colorButtonOver },
        font = infoFont,
        fontSize = heightButton / 2,
        id = "closeInfoBox",
        onEvent = handleInfoBoxTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.anchorX = 0
    buttonBack.x = frameInformation.x + frameInformation.width / 2 - buttonBack.width
    infoGroup:insert( buttonBack )

    -- Add a reference to display group so we can remove it in handleInfoBoxTouch()
    buttonBack.refGroup = infoGroup


    --isPromptAvailable = true
    if (isPromptAvailable) then
        local rectHideInformation = display.newRoundedRect( infoGroup, 0, 0, 1, 1, 5 )
        rectHideInformation.id = "hideInfoForever"
        rectHideInformation:setFillColor( unpack(themeData.colorBackgroundPopup) )
        rectHideInformation.strokeWidth = 5
        rectHideInformation:setStrokeColor( unpack(themeData.colorBackground) )
        rectHideInformation:addEventListener( "touch", handleInfoBoxTouch )

        local optionsTextNotShowAgain = { text = sozluk.getString("lockInformationHide"), font = infoFont, fontSize = fontSizeInformation / 1.1,
                                    height = 0, align = "center" }
        rectHideInformation.textNotShowAgain = display.newText( optionsTextNotShowAgain )
        rectHideInformation.textNotShowAgain.id = "hideInfoForever"
        rectHideInformation.textNotShowAgain:setFillColor( unpack(themeData.colorBackground) )
        rectHideInformation.textNotShowAgain:addEventListener( "touch", handleInfoBoxTouch )
        infoGroup:insert(rectHideInformation.textNotShowAgain)

        rectHideInformation.height = rectHideInformation.textNotShowAgain.height
        rectHideInformation.width = rectHideInformation.height

        local optionsRectLockMarker = { text = "X", font = infoFont, fontSize = rectHideInformation.height / 1.1 }
        rectHideInformation.markerPrompt = display.newText( optionsRectLockMarker )
        rectHideInformation.markerPrompt.alpha = 0
        rectHideInformation.markerPrompt.isActivated = false
        rectHideInformation.markerPrompt:setFillColor( unpack( themeData.colorButtonFillTrue ) )
        infoGroup:insert(rectHideInformation.markerPrompt)

        -- Add a reference to the variable where you save "Don't show again" preference for this information box
        if (stringPromptPreference) then
            rectHideInformation.markerPrompt.stringPromptPreference = stringPromptPreference
        end

        -- Add a reference to marker lock so when player presses the text, it also makes the marker visible
        rectHideInformation.textNotShowAgain.markerPrompt = rectHideInformation.markerPrompt

        frameInformation.height = textLockInformation.height + rectHideInformation.textNotShowAgain.height + buttonBack.height + yDistanceElements * 2.5
        frameInformation.y = display.contentCenterY + frameInformation.height / 3
        buttonBack.y = frameInformation.y - frameInformation.height / 2 + buttonBack.height / 2

        local xDistanceInfoElements = (frameInformation.width - (rectHideInformation.textNotShowAgain.width + rectHideInformation.width)) / 3
        rectHideInformation.x = (frameInformation.x - frameInformation.width / 2) + rectHideInformation.width / 2 + xDistanceInfoElements
        rectHideInformation.y = (frameInformation.y + frameInformation.height / 2) - rectHideInformation.height / 2 - yDistanceElements
        rectHideInformation.markerPrompt.x = rectHideInformation.x
        rectHideInformation.markerPrompt.y = rectHideInformation.y

        rectHideInformation.textNotShowAgain.x = rectHideInformation.x + rectHideInformation.width / 1.2 + rectHideInformation.textNotShowAgain.width / 2
        rectHideInformation.textNotShowAgain.y = rectHideInformation.y

        textLockInformation.y = rectHideInformation.textNotShowAgain.y - rectHideInformation.textNotShowAgain.height / 2 - textLockInformation.height / 2 - yDistanceElements
    else
        frameInformation.height = textLockInformation.height + buttonBack.height + yDistanceElements * 1.5
        frameInformation.y = display.contentCenterY + frameInformation.height / 3
        buttonBack.y = frameInformation.y - frameInformation.height / 2 + buttonBack.height / 2

        textLockInformation.y = (frameInformation.y + frameInformation.height / 2) - textLockInformation.height / 2 - yDistanceElements
    end


    infoGroup.alpha = 1


    -- Return top y coordinate of information box so you can adjust other elements if necessary
    return frameInformation.y - frameInformation.height / 2
end

-- Handle touch events for dialog box
-- Calls assigned function when corresponding option is selected
local function handleDialogTouch(event)
    if (event.phase == "ended") then
        event.target.methodAssigned()
    end
    return true
end

-- Create and show dialog box that contains a text and two options - confirm & deny
-- Confirm/Deny strings and assigned functionality will be passed on function call with tableDialogOptions
function utils.showDialogBox(dialogGroup, tableDialogOptions)
    local fontDialog = tableDialogOptions["fontDialog"]
    local dialogText = tableDialogOptions["dialogText"]
    local confirmText = tableDialogOptions["confirmText"]
    local denyText = tableDialogOptions["denyText"]
    local confirmFunction = tableDialogOptions["confirmFunction"]
    local denyFunction = tableDialogOptions["denyFunction"]


    local backgroundShade = display.newRect( dialogGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .9
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local fontSizeDialogText = contentHeightSafe / 28

    local frameQuestionDialog = display.newRect( dialogGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
    frameQuestionDialog:setFillColor( unpack(themeData.colorBackgroundPopup) )

    local optionsTextDialog = { text = dialogText, width = frameQuestionDialog.width / 1.1, height = 0, 
        align = "center", font = fontDialog, fontSize = fontSizeDialogText }
    frameQuestionDialog.textLabel = display.newText( optionsTextDialog )
    frameQuestionDialog.textLabel:setFillColor( unpack(themeData.colorBackground) )
    frameQuestionDialog.textLabel.x = frameQuestionDialog.x
    dialogGroup:insert(frameQuestionDialog.textLabel)


    local widthDialogButton = frameQuestionDialog.width / 1.1
    local heightDialogButton = contentHeightSafe / 10
    local yDistanceChoices = heightDialogButton / 5
    local fontSizeChoices = fontSizeDialogText

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver

    local optionsButtonConfirm = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthDialogButton,
        height = heightDialogButton,
        label = confirmText,
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontDialog,
        fontSize = fontSizeChoices,
        id = "confirmDialog",
        onEvent = handleDialogTouch,
    }
    local buttonConfirm = widget.newButton( optionsButtonConfirm )
    buttonConfirm.x = display.contentCenterX
    dialogGroup:insert( buttonConfirm )
    buttonConfirm.methodAssigned = confirmFunction

    local optionsButtonDeny = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthDialogButton,
        height = heightDialogButton,
        label = denyText,
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontDialog,
        fontSize = fontSizeChoices,
        id = "denyDialog",
        onEvent = handleDialogTouch,
    }
    local buttonDeny = widget.newButton( optionsButtonDeny )
    buttonDeny.x = display.contentCenterX
    dialogGroup:insert( buttonDeny )
    buttonDeny.methodAssigned = denyFunction

    frameQuestionDialog.height = frameQuestionDialog.textLabel.height + buttonConfirm.height + buttonDeny.height + yDistanceChoices * 4
    frameQuestionDialog.y = display.contentCenterY
    frameQuestionDialog.textLabel.y = frameQuestionDialog.y - frameQuestionDialog.height / 2 + frameQuestionDialog.textLabel.height / 2 + yDistanceChoices
    buttonConfirm.y = frameQuestionDialog.textLabel.y + frameQuestionDialog.textLabel.height / 2 + buttonConfirm.height / 2 + yDistanceChoices
    buttonDeny.y = buttonConfirm.y + buttonConfirm.height / 2 + buttonDeny.height / 2 + yDistanceChoices
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

-- Show rating UI depending on the operating system
-- Better approach would be to implement Scott H's Review PopUp Plugin
-- https://solar2dmarketplace.com/plugins?ReviewPopUp_tech-scotth
function utils.showRateUI()
    if (system.getInfo("platform") == "ios" or system.getInfo("platform") == "macos" or system.getInfo("platform") == "tvos") then
        local idAppStore = composer.getVariable( "idAppStore" )

        local optionsRateGame = {
            iOSAppId = idAppStore
        }
    else
        local storeSupported = { "google" }

        local optionsRateGame = {
            supportedAndroidStores = storeSupported
        }
    end

    native.showPopup( "appStore", optionsRateGame )
end


return utils