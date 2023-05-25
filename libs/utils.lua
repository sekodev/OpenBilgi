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

function utils.clearTable(targetTable)
    for i = #targetTable, 1, -1 do
        display.remove(targetTable[i])
        targetTable[i] = nil
    end
    targetTable = {}

    return targetTable
end

-- Adjust slider level - turn on/off or fine control
local function controlSliderLevel(event)
    if (event.phase == "began") then
        if (event.target.id == "sliderControl") then
            display.getCurrentStage( ):setFocus( event.target )

            event.target:setFillColor( unpack(event.target.colorFillOnPress) )
        elseif (event.target.id == "switchOnOff") then
            event.target.nodeControl.x = event.target.nodeControl.line.x

            -- Quick on/off
            if (event.target.nodeControl.levelCurrent <= 0) then
                event.target.nodeControl.levelCurrent = event.target.nodeControl.levelBeforeMute
            else
                event.target.nodeControl.levelBeforeMute = event.target.nodeControl.levelCurrent
                event.target.nodeControl.levelCurrent = 0
            end

            event.target.nodeControl.x = event.target.nodeControl.line.x + (event.target.nodeControl.line.width * event.target.nodeControl.levelCurrent)

            local idVariable = event.target.idVariable
            if (idVariable == "soundLevel") then
                for i = 2, audio.totalChannels do
                    audio.setVolume( event.target.nodeControl.levelCurrent, {channel = i} )
                end

                if (not audio.isChannelPlaying( 2 )) then
                    audio.play( event.target.soundSample, {channel = 2} )
                end
            elseif (idVariable == "musicLevel") then
                audio.setVolume( event.target.nodeControl.levelCurrent, {channel = channelBackgroundMusic} )
            end

            composer.setVariable( idVariable, event.target.nodeControl.levelCurrent )
        end
    elseif (event.phase == "moved") then
        if (event.target.id == "sliderControl") then
            if (event.x >= event.target.line.x and event.x <= event.target.line.x + event.target.line.width) then
                event.target.x = event.x

                event.target.levelBeforeMute = event.target.levelCurrent
                event.target.levelCurrent = (event.target.x - event.target.line.x) / event.target.line.width

                if (event.target.levelCurrent < 0.05) then
                    event.target.levelCurrent = 0
                end


                local idVariable = event.target.idVariable
                if (idVariable == "soundLevel") then
                    -- Only channels 2 and 3 are actively used in this scene
                    -- We will set volume for other channels in "ended" phase
                    audio.setVolume( event.target.levelCurrent, {channel = 2} )
                    audio.setVolume( event.target.levelCurrent, {channel = 3} )

                    if (not audio.isChannelPlaying( 2 )) then
                        audio.play( event.target.soundSample, {channel = 2} )
                    end
                elseif (idVariable == "musicLevel") then
                    audio.setVolume( event.target.levelCurrent, {channel = channelBackgroundMusic} )
                end
            end
        end
    elseif (event.phase == "ended") then
        if (event.target.id == "sliderControl") then
            display.getCurrentStage( ):setFocus( nil )

            local idVariable = event.target.idVariable
            if (idVariable == "soundLevel") then
                for i = 2, audio.totalChannels do
                    audio.setVolume( event.target.levelCurrent, {channel = i} )
                end
            end

            event.target:setFillColor( unpack(event.target.colorFillDefault) )

            composer.setVariable( idVariable, event.target.levelCurrent )
        end
    end
    return true
end

-- Create slider controls - used for SFX and music levels
function utils.createSliderControl(targetGroup, optionsSliderControl)
    local idVariable = optionsSliderControl["id"]
    local filePath = optionsSliderControl["filePath"]
    local widthButton = optionsSliderControl["widthButton"]
    local heightButton = optionsSliderControl["heightButton"]
    local yButton = optionsSliderControl["yButton"]
    local soundSample = optionsSliderControl["soundSample"]

    local colorBackground = optionsSliderControl["colorBackground"]
    local colorButtonDefault = optionsSliderControl["colorButtonDefault"]
    local colorButtonFillDefault = optionsSliderControl["colorButtonFillDefault"]
    local colorButtonFillOnPress = optionsSliderControl["colorButtonFillOnPress"]
    local colorButtonStroke = optionsSliderControl["colorButtonStroke"]
    

    local xDistanceSides = contentWidthSafe / 10
    local imageButton
    local typeSlider, yStartingPlacement

    if (optionsSliderControl["typeSlider"]) then
        typeSlider = optionsSliderControl["typeSlider"]
        yStartingPlacement = optionsSliderControl["yStartingPlacement"]
    end

    imageButton = display.newImageRect( targetGroup, filePath, widthButton, heightButton )
    imageButton:setFillColor( unpack(colorButtonDefault) )
    imageButton.id = "switchOnOff"
    imageButton.idVariable = idVariable
    imageButton.soundSample = soundSample
    imageButton.anchorX = 0
    imageButton.x = xDistanceSides
    imageButton.y = yButton
    imageButton:addEventListener( "touch", controlSliderLevel )

    local widthLineSlider = contentWidthSafe - xDistanceSides * 2 - imageButton.width * 1.5
    local heightLineSlider = imageButton.height / 12
    local xLineSlider = imageButton.x + imageButton.width * 1.5
    local yLineSlider = imageButton.y

    imageButton.nodeControl = display.newCircle( targetGroup, xLineSlider + widthLineSlider / 2, yLineSlider, imageButton.height / 4 )
    imageButton.nodeControl:setStrokeColor( unpack(colorButtonStroke) )
    imageButton.nodeControl.strokeWidth = 10
    imageButton.nodeControl.colorFillDefault = colorButtonFillDefault
    imageButton.nodeControl.colorFillOnPress = colorButtonFillOnPress
    imageButton.nodeControl:setFillColor( unpack(imageButton.nodeControl.colorFillDefault) )
    imageButton.nodeControl.id = "sliderControl"
    imageButton.nodeControl.idVariable = idVariable
    imageButton.nodeControl.levelCurrent = composer.getVariable(idVariable)
    imageButton.nodeControl.levelBeforeMute = imageButton.nodeControl.levelCurrent -- Used to keep last sound level before mute is pressed
    imageButton.nodeControl.soundSample = soundSample
    imageButton.nodeControl:addEventListener( "touch", controlSliderLevel )

    imageButton.nodeControl.line = display.newRect( targetGroup, 0, imageButton.nodeControl.y, 0, heightLineSlider )
    imageButton.nodeControl.line:setFillColor( unpack(colorButtonDefault) )
    imageButton.nodeControl.line.anchorX = 0
    imageButton.nodeControl.line.x = xLineSlider
    imageButton.nodeControl.line.width = widthLineSlider

    imageButton.nodeControl:toFront( )

    imageButton.nodeControl.x = imageButton.nodeControl.line.x + (imageButton.nodeControl.line.width * imageButton.nodeControl.levelCurrent)

    if (typeSlider == "clickOpen") then
        imageButton.background = display.newRect( targetGroup, display.contentCenterX, 0, contentWidth, 0 )
        imageButton.background:setFillColor( unpack(colorBackground) )
        imageButton.background:toBack( )
        imageButton.background:addEventListener( "touch", function () return true end )

        local position = optionsSliderControl["position"]
        if (position == "top") then
            imageButton.background.height = (imageButton.y + imageButton.height) - yStartingPlacement
            imageButton.background.y = yStartingPlacement + imageButton.background.height / 2
        elseif (position == "bottom") then
            -- Determine the y position for clickOpen type menu's top
            local yTopMenu = imageButton.y - imageButton.height

            imageButton.background.height = yStartingPlacement - yTopMenu
            imageButton.background.y = yTopMenu + imageButton.background.height / 2
        end
    end

    return imageButton
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
function utils.showInformationBox(infoGroup, optionsInfoBox)
    local infoFont = optionsInfoBox["infoFont"]
    local infoText = optionsInfoBox["infoText"]
    local isPromptAvailable = optionsInfoBox["isPromptAvailable"]
    local stringPromptPreference = optionsInfoBox["stringPromptPreference"]

    infoGroup.alpha = 0

    local backgroundShade = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    backgroundShade:setFillColor( unpack(themeData.colorBackground) )
    backgroundShade.alpha = .9
    backgroundShade.id = "backgroundShade"
    backgroundShade:addEventListener( "touch", function () return true end )

    local frameInformation = display.newRect( infoGroup, display.contentCenterX, display.contentCenterY, contentWidthSafe / 1.1, 0 )
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
-- Confirm/Deny strings and assigned functionality will be passed on function call with optionsDialogBox
function utils.showDialogBox(dialogGroup, optionsDialogBox)
    local fontDialog = optionsDialogBox["fontDialog"]
    local dialogText = optionsDialogBox["dialogText"]
    local confirmText = optionsDialogBox["confirmText"]
    local denyText = optionsDialogBox["denyText"]
    local confirmFunction = optionsDialogBox["confirmFunction"]
    local denyFunction = optionsDialogBox["denyFunction"]


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