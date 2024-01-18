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

local widget = require ("widget")

local mainGroup, menuGroup, creditsGroup, URLGroup

local sceneTransitionTime = composer.getVariable( "sceneTransitionTime" )
local sceneTransitionEffect = composer.getVariable( "sceneTransitionEffect" )

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )

local containerCredits
local creditsData
local URLselected = ""

local yLimitBottom


local function cleanUp()
    Runtime:removeEventListener( "enterFrame", moveCredits )
end

-- Reset y position of credits container to move everything back to starting point
local function resetCreditsPosition()
    for i = 1, containerCredits.numChildren do
        containerCredits[i].y = containerCredits[i].y0
    end
end

-- Move every credits element
local function moveCredits()
    -- When scene is changed, exit function. Do nothing.
    if ( composer.getVariable("currentAppScene") == "menuScreen" ) then
        return
    end

    for i = 1, containerCredits.numChildren do
        containerCredits[i].y = containerCredits[i].y - containerCredits.moveSpeed

        if (i == containerCredits.numChildren and containerCredits[i].y + containerCredits[i].height < 0) then
            resetCreditsPosition()
        end
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

-- Handle touch events for everything on screen including URLs attached to credits elements
local function handleTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "sendMail") then
            local currentVersion = composer.getVariable( "currentVersion" )

            local mailAddress = composer.getVariable("emailSupport")
            local mailSubject = sozluk.getString("sendSupportMailSubject")
            local mailBody = sozluk.getString("sendSupportMailVersionInformation") .. ": " .. currentVersion .. "\n\n"
             .. sozluk.getString("sendSupportMailBody") .. "\n\n"

            utils.showMailUI(mailAddress, mailSubject, mailBody)
        elseif (event.target.id == "openURL") then
            URLselected = event.target.URL

            if (event.target.underline) then
                event.target.underline:setFillColor( unpack( themeData.colorHyperlinkVisited ) )
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
        end
    end
    return true
end

-- Create buttons for contact information that stay on top, below the screen
local function createContactButtons()
    local heightContactButton = contentHeightSafe / 14
    local widthContactButton = heightContactButton
    local fontSizePolicy = heightContactButton / 3
    local colorHyperlink = themeData.colorHyperlink
    local colorHyperlinkVisited = themeData.colorHyperlinkVisited

    local currentTheme = composer.getVariable( "currentTheme" )

    -- Used to create links to corresponding privacy policy and terms of use
    local currentLanguage = composer.getVariable( "currentLanguage" )

    local optionsButtonPrivacyPolicy = 
    {
        label = sozluk.getString("privacyPolicy"),
        width = widthContactButton,
        height = heightContactButton,
        textOnly = true,
        font = fontLogo,
        fontSize = fontSizePolicy,
        labelColor = { default = { unpack(colorHyperlink) }, over = { unpack(colorHyperlinkVisited) } },
        id = "openURL",
        onEvent = handleTouch,
    }
    local buttonPrivacyPolicy = widget.newButton( optionsButtonPrivacyPolicy )
    buttonPrivacyPolicy.URL = "https://sekodev.github.io/games/privacy/privacyPolicy-" .. currentLanguage .. ".html"
    buttonPrivacyPolicy.x = display.contentCenterX
    buttonPrivacyPolicy.y = contentHeightSafe - buttonPrivacyPolicy.height * 1.5
    creditsGroup:insert(buttonPrivacyPolicy)

    buttonPrivacyPolicy.underline = display.newRect( creditsGroup, buttonPrivacyPolicy.x, 0, buttonPrivacyPolicy.width, 5 )
    buttonPrivacyPolicy.underline:setFillColor( unpack( colorHyperlink ) )
    buttonPrivacyPolicy.underline.y = buttonPrivacyPolicy.y + buttonPrivacyPolicy.height / 2

    local optionsButtonTermsUse = 
    {
        label = sozluk.getString("termsUse"),
        width = widthContactButton,
        height = heightContactButton,
        textOnly = true,
        font = fontLogo,
        fontSize = fontSizePolicy,
        labelColor = { default = { unpack(colorHyperlink) }, over = { unpack(colorHyperlinkVisited) } },
        id = "openURL",
        onEvent = handleTouch,
    }
    local buttonTermsUse = widget.newButton( optionsButtonTermsUse )
    buttonTermsUse.URL = "https://sekodev.github.io/games/terms/termsUse-" .. currentLanguage .. ".html"
    buttonTermsUse.x = display.contentCenterX
    buttonTermsUse.y = buttonPrivacyPolicy.y - buttonPrivacyPolicy.height / 2 - buttonTermsUse.height
    creditsGroup:insert(buttonTermsUse)

    buttonTermsUse.underline = display.newRect( creditsGroup, buttonTermsUse.x, 0, buttonTermsUse.width, 5 )
    buttonTermsUse.underline:setFillColor( unpack( colorHyperlink ) )
    buttonTermsUse.underline.y = buttonTermsUse.y + buttonTermsUse.height / 2

    local optionsButtonFacebook = 
    {
        defaultFile = "assets/menu/facebook.png",
        width = widthContactButton,
        height = heightContactButton,
        id = "openURL",
        onEvent = handleTouch,
    }
    local buttonFacebook = widget.newButton( optionsButtonFacebook )
    buttonFacebook.URL = "https://www.facebook.com/sleepybugstudio/"
    buttonFacebook.y = buttonTermsUse.y - buttonTermsUse.height - buttonFacebook.height / 1.5
    creditsGroup:insert(buttonFacebook)

    local optionsButtonTwitter = 
    {
        defaultFile = "assets/menu/twitter.png",
        width = widthContactButton,
        height = heightContactButton,
        id = "openURL",
        onEvent = handleTouch,
    }
    local buttonTwitter = widget.newButton( optionsButtonTwitter )
    buttonTwitter.URL = "https://twitter.com/sleepybugstudio"
    buttonTwitter.y = buttonFacebook.y
    creditsGroup:insert(buttonTwitter)

    local fileGithub = "assets/menu/github.png"
    if (currentTheme == "dark") then
        fileGithub = "assets/menu/github-light.png"
    end

    local optionsButtonGithub = 
    {
        defaultFile = fileGithub,
        width = widthContactButton,
        height = heightContactButton,
        id = "openURL",
        onEvent = handleTouch,
    }
    local buttonGithub = widget.newButton( optionsButtonGithub )
    buttonGithub.URL = "https://github.com/sekodev/OpenBilgi"
    buttonGithub.y = buttonTwitter.y
    creditsGroup:insert(buttonGithub)

--[[
    local optionsButtonSendMail = 
    {
        defaultFile = "assets/menu/sendMail.png",
        width = widthContactButton,
        height = heightContactButton,
        id = "sendMail",
        onEvent = handleTouch,
    }
    local buttonSendMail = widget.newButton( optionsButtonSendMail )
    buttonSendMail.y = buttonTwitter.y
    creditsGroup:insert(buttonSendMail)
]]

    local distanceButtons = (contentWidthSafe - (widthContactButton * 3) ) / 4

    buttonFacebook.x = buttonFacebook.width / 2 + distanceButtons
    buttonTwitter.x = buttonFacebook.x + widthContactButton + distanceButtons
    --buttonSendMail.x = buttonTwitter.x + widthContactButton + distanceButtons
    buttonGithub.x = buttonTwitter.x + widthContactButton + distanceButtons

    yLimitBottom = buttonTwitter.y - buttonTwitter.height / 1.5
end

-- Create scrolling elements, names and links for credits
local function createCreditsElements()
    local infoCredits = require("libs.infoCredits")
    creditsData = infoCredits.getData()

    -- I used a container so elements are not rendered outside of the specified bounds
    -- https://docs.coronalabs.com/guide/graphics/container.html#groups-vs.-containers
    containerCredits = display.newContainer( contentWidthSafe, yLimitBottom - display.safeScreenOriginY )
    containerCredits.anchorX, containerCredits.anchorY = 0, 0
    containerCredits.x, containerCredits.y = 0, display.safeScreenOriginY
    containerCredits.anchorChildren = false
    containerCredits.moveSpeed = 4
    creditsGroup:insert(containerCredits)

    local tableCredits = {}

    local sizeTitles = contentHeightSafe / 22
    local sizeNames = contentHeightSafe / 27

    local yDistanceBetweenSections = sizeTitles * 1.5
    local yDistanceBetweenTitleName = sizeTitles / 1.5
    local yDistanceBetweenNames = sizeNames

    local colorTitle = themeData.colorTitle
    local colorTextDefault = themeData.colorTextDefault
    local colorHyperlink = themeData.colorHyperlink

    for i = 1, #creditsData.entries do
        if (creditsData.entries[i].title) then
            local optionsTitlePeople = { text = creditsData.entries[i].title, font = fontLogo, 
                width = contentWidthSafe / 1.1, fontSize = sizeTitles, align = "center" }
            local titleEntry = display.newText( optionsTitlePeople )
            titleEntry:setFillColor( unpack( colorTitle ) )
            titleEntry.x = display.contentCenterX

            if (i == 1) then
                titleEntry.y = yLimitBottom + titleEntry.height
            else
                titleEntry.y = tableCredits[#tableCredits].y + tableCredits[#tableCredits].height / 2 + 
                    titleEntry.height / 2 + yDistanceBetweenSections
            end

            creditsGroup:insert(titleEntry)
            table.insert(tableCredits, titleEntry)

            containerCredits:insert(titleEntry)
            titleEntry.y0 = titleEntry.y
        end


        if (creditsData.entries[i].imagePath) then
            local filePath
            if (themeData.nameSelected == "dark") then
                filePath = creditsData.entries[i].imagePath.dark
            elseif (themeData.nameSelected == "light") then
                filePath = creditsData.entries[i].imagePath.light
            end

            local imageEntry = display.newImageRect( creditsGroup, 
                filePath, creditsData.entries[i].imagePath.width, creditsData.entries[i].imagePath.height )
            imageEntry.x = display.contentCenterX

            if (i == 1) then
                imageEntry.y = yLimitBottom + imageEntry.height
            else
                imageEntry.y = tableCredits[#tableCredits].y + tableCredits[#tableCredits].height + imageEntry.height / 1.5
            end

            table.insert(tableCredits, imageEntry)

            containerCredits:insert(imageEntry)
            imageEntry.y0 = imageEntry.y

            if (creditsData.entries[i].imagePath.hyperlink) then
                imageEntry.id = "openURL"
                imageEntry.URL = creditsData.entries[i].imagePath.hyperlink
                imageEntry:addEventListener( "touch", handleTouch )
            end
        end


        if (creditsData.entries[i].people) then
            for j = 1, #creditsData.entries[i].people do
                local optionsNamePeople = { text = creditsData.entries[i].people[j].fullName, 
                    width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames, align = "center" }
                local namePeople = display.newText( optionsNamePeople )
                namePeople:setFillColor( unpack(colorTextDefault) )
                namePeople.x = display.contentCenterX
                if (j == 1) then
                    namePeople.y = tableCredits[#tableCredits].y + tableCredits[#tableCredits].height / 2 + 
                        namePeople.height / 2 + yDistanceBetweenTitleName
                else
                    namePeople.y = tableCredits[#tableCredits].y + tableCredits[#tableCredits].height / 2 + 
                        namePeople.height / 2 + yDistanceBetweenNames
                end

                creditsGroup:insert( namePeople )
                table.insert(tableCredits, namePeople)

                containerCredits:insert(namePeople)
                namePeople.y0 = namePeople.y

                -- This needs to be handled differently because of font size difference
                if (creditsData.entries[i].people[j].author) then
                    local optionsAuthor = { text = creditsData.entries[i].people[j].author, 
                        width = contentWidthSafe / 1.1, font = fontIngame.nameMenu, fontSize = sizeNames / 1.2, align = "center" }
                    namePeople.author = display.newText( optionsAuthor )
                    namePeople.author:setFillColor( unpack(colorHyperlink) )
                    namePeople.author.x = display.contentCenterX
                    namePeople.author.y = namePeople.y + namePeople.height + namePeople.author.height / 2

                    creditsGroup:insert( namePeople.author )
                    table.insert(tableCredits, namePeople.author)

                    containerCredits:insert(namePeople.author)
                    namePeople.author.y0 = namePeople.author.y
                end

                if (creditsData.entries[i].people[j].hyperlink) then
                    namePeople.id = "openURL"
                    namePeople.URL = creditsData.entries[i].people[j].hyperlink
                    namePeople:addEventListener( "touch", handleTouch )

                    if (namePeople.author) then
                        namePeople.author.id = "openURL"
                        namePeople.author.URL = creditsData.entries[i].people[j].hyperlink
                        namePeople.author:addEventListener( "touch", handleTouch )
                    end
                end
            end
        end
    end
end

local function goBack()
    Runtime:removeEventListener( "enterFrame", moveCredits )

    local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, 
        params = {callSource = "creditScreen"}}
    composer.gotoScene( "screens.menuScreen", optionsChangeScene )
end

local function createScreenElements()
    local colorBackground = themeData.colorBackground

    local background = display.newRect( creditsGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(colorBackground) )

    local optionsNavigationMenu = { position = "top", fontName = fontLogo, 
        backFunction = goBack }
    local yStartingPlacement = commonMethods.createNavigationMenu(menuGroup, optionsNavigationMenu)

    createContactButtons()
    createCreditsElements()
end

function scene:create( event )
    mainGroup = self.view
    creditsGroup = display.newGroup( )
    menuGroup = display.newGroup( )
    URLGroup = display.newGroup( )

    createScreenElements()

    mainGroup:insert(creditsGroup)
    mainGroup:insert(menuGroup)
    mainGroup:insert(URLGroup)
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()
        composer.setVariable("currentAppScene", "creditScreen")

        Runtime:addEventListener( "enterFrame", moveCredits )
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        cleanUp()
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