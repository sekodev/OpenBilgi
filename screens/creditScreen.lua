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

local currentLanguage = composer.getVariable( "currentLanguage" )
local currentTheme = composer.getVariable( "currentTheme" )
local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

local mainGroup, creditsGroup

local containerCredits

local heightCreditsElements = 0

local yLimitBottom

--[[
    WARNING!!!
    This is pretty bad code. I'm not proud of it.
    I didn't have enough time to make it better.
]]--

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

-- Handle touch events for everything on screen including URLs attached to credits elements
local function handleTouch(event)
    if (event.phase == "ended") then
        if (event.target.id == "sendMail") then
            local mailAddress = composer.getVariable("emailSupport")
            local mailSubject = sozluk.getString("sendSupportMailSubject")
            local mailBody = sozluk.getString("sendSupportMailBody")

            utils.showMailUI(mailAddress, mailSubject, mailBody)
        elseif (event.target.id == "openURL") then
            if (event.target.underline) then
                event.target.underline:setFillColor( unpack( themeData.colorHyperlinkVisited ) )
            end

            system.openURL( event.target.URL )
        elseif (event.target.id == "mainMenu") then
            Runtime:removeEventListener( "enterFrame", moveCredits )

            local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "creditScreen"}}
            composer.gotoScene( "screens.menuScreen", optionsChangeScene )
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
    local sizeTitles = contentHeightSafe / 25
    local sizeNames = contentHeightSafe / 30

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local colorTitle = themeData.colorButtonFillWrong
    local colorHyperlink = themeData.colorHyperlink

    local background = display.newRect( creditsGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )

    local optionsButtonBack = 
    {
        shape = "rect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillDefault },
        width = contentWidthSafe / 6,
        height = contentHeightSafe / 10,
        label = "<",
        labelColor = { default = colorButtonDefault, over = colorButtonOver },
        font = fontLogo,
        fontSize = contentHeightSafe / 15,
        id = "mainMenu",
        onEvent = handleTouch,
    }
    local buttonBack = widget.newButton( optionsButtonBack )
    buttonBack.x = buttonBack.width / 2
    buttonBack.y = display.safeScreenOriginY + buttonBack.height / 2
    creditsGroup:insert( buttonBack )

    local menuSeparator = display.newRect( creditsGroup, background.x, 0, background.width, 10 )
    menuSeparator.y = buttonBack.y + buttonBack.height / 2
    menuSeparator:setFillColor( unpack(colorButtonOver) )

    createContactButtons()

    local scaleLogo = 0.8
    local logoSB = display.newImageRect( creditsGroup, "assets/other/logoSleepyBug.png", 813 * scaleLogo, 194 * scaleLogo )
    logoSB.x, logoSB.y = display.contentCenterX, yLimitBottom + logoSB.height

    local optionsDevTeam = { text = sozluk.getString("developedBy"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleDevTeam = display.newText( optionsDevTeam )
    titleDevTeam:setFillColor( unpack( colorTitle ) )
    titleDevTeam.x = display.contentCenterX
    titleDevTeam.y = logoSB.y + logoSB.height + titleDevTeam.height
    creditsGroup:insert(titleDevTeam)

    local optionsDevName = { text = "Serkan Aksit", font = fontIngame, fontSize = sizeNames, align = "center"}
    titleDevTeam.name = display.newText( optionsDevName )
    titleDevTeam.name:setFillColor( unpack(colorTextDefault) )
    titleDevTeam.name.x = display.contentCenterX
    titleDevTeam.name.y = titleDevTeam.y + titleDevTeam.height + titleDevTeam.name.height / 2
    creditsGroup:insert(titleDevTeam.name)

    local optionsTitleTester = { text = sozluk.getString("testedBy"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleTester = display.newText( optionsTitleTester )
    titleTester:setFillColor( unpack( colorTitle ) )
    titleTester.x = display.contentCenterX
    titleTester.y = titleDevTeam.name.y + titleDevTeam.name.height + titleTester.height * 1.5
    creditsGroup:insert(titleTester)

    local optionsDevServerSide = { text = "Bilge Kol", font = fontIngame, fontSize = sizeNames, align = "center"}
    titleTester.name = display.newText( optionsDevServerSide )
    titleTester.name:setFillColor( unpack(colorTextDefault) )
    titleTester.name.x = titleTester.x
    titleTester.name.y = titleTester.y + titleTester.height + titleTester.name.height / 2
    creditsGroup:insert(titleTester.name)

    local optionsTitleServerSide = { text = sozluk.getString("serverSideBy") .. "\n" .. sozluk.getString("prev04"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleDevServerSide = display.newText( optionsTitleServerSide )
    titleDevServerSide:setFillColor( unpack( colorTitle ) )
    titleDevServerSide.x = display.contentCenterX
    titleDevServerSide.y = titleTester.name.y + titleTester.name.height + titleDevServerSide.height
    creditsGroup:insert(titleDevServerSide)

    local optionsDevServerSide = { text = "Can Ertong", font = fontIngame, fontSize = sizeNames, align = "center"}
    titleDevServerSide.name = display.newText( optionsDevServerSide )
    titleDevServerSide.name:setFillColor( unpack(colorTextDefault) )
    titleDevServerSide.name.x = titleDevServerSide.x
    titleDevServerSide.name.y = titleDevServerSide.y + titleDevServerSide.height / 1.5 + titleDevServerSide.name.height / 2
    creditsGroup:insert(titleDevServerSide.name)


    local optionsMusic = { text = sozluk.getString("music"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleMusic = display.newText( optionsMusic )
    titleMusic:setFillColor( unpack( colorTitle ) )
    titleMusic.x = display.contentCenterX
    titleMusic.y = titleDevServerSide.name.y + titleDevServerSide.name.height + titleMusic.height * 1.5
    creditsGroup:insert( titleMusic )

    local optionsComposerMusic = { text = "Eric Matyas", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleMusic.nameComposer = display.newText( optionsComposerMusic )
    titleMusic.nameComposer:setFillColor( unpack(colorTextDefault) )
    titleMusic.nameComposer.x = display.contentCenterX
    titleMusic.nameComposer.y = titleMusic.y + titleMusic.height + titleMusic.nameComposer.height / 2
    creditsGroup:insert(titleMusic.nameComposer)

    local optionsLinkComposer = { text = "soundimage.org", font = fontIngame, fontSize = sizeNames / 1.2, align = "center"}
    titleMusic.linkComposer = display.newText( optionsLinkComposer )
    titleMusic.linkComposer:setFillColor( unpack( colorHyperlink ) )
    titleMusic.linkComposer.x = display.contentCenterX
    titleMusic.linkComposer.y = titleMusic.nameComposer.y + titleMusic.nameComposer.height + titleMusic.linkComposer.height / 2
    titleMusic.linkComposer.id = "openURL"
    titleMusic.linkComposer.URL = "https://soundimage.org"
    titleMusic.linkComposer:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleMusic.linkComposer)

    local optionsMusicTheme = { text = "Automation", font = fontIngame, width = contentWidthSafe / 1.1, fontSize = sizeNames / 1.2, align = "center" }
    titleMusic.nameTheme = display.newText( optionsMusicTheme )
    titleMusic.nameTheme:setFillColor( unpack(colorHyperlink) )
    titleMusic.nameTheme.x = display.contentCenterX
    titleMusic.nameTheme.y = titleMusic.linkComposer.y + titleMusic.linkComposer.height + titleMusic.nameTheme.height / 2
    titleMusic.nameTheme.id = "openURL"
    titleMusic.nameTheme.URL = "https://soundimage.org/looping-music/"
    titleMusic.nameTheme:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleMusic.nameTheme)

    local optionsMusicIngame = { text = "Safe Cracking", font = fontIngame, width = contentWidthSafe / 1.1, fontSize = sizeNames / 1.2, align = "center" }
    titleMusic.nameIngame = display.newText( optionsMusicIngame )
    titleMusic.nameIngame:setFillColor( unpack(colorHyperlink) )
    titleMusic.nameIngame.x = display.contentCenterX
    titleMusic.nameIngame.y = titleMusic.nameTheme.y + titleMusic.nameTheme.height + titleMusic.nameIngame.height / 2
    titleMusic.nameIngame.id = "openURL"
    titleMusic.nameIngame.URL = "https://soundimage.org/city-urban-2/"
    titleMusic.nameIngame:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleMusic.nameIngame)


    local optionsTitleSoundFX = { text = sozluk.getString("soundFX"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleSoundFX = display.newText( optionsTitleSoundFX )
    titleSoundFX:setFillColor( unpack(colorTitle) )
    titleSoundFX.x = display.contentCenterX
    titleSoundFX.y = titleMusic.nameIngame.y + titleMusic.nameIngame.height + titleSoundFX.height * 1.5
    creditsGroup:insert(titleSoundFX)

    local optionsComposerChoose = { text = "Mattias 'MATTIX' Lahoud", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerChoose = display.newText( optionsComposerChoose )
    titleSoundFX.nameComposerChoose:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerChoose.x = display.contentCenterX
    titleSoundFX.nameComposerChoose.y = titleSoundFX.y + titleSoundFX.height + titleSoundFX.nameComposerChoose.height / 2
    creditsGroup:insert(titleSoundFX.nameComposerChoose)

    local optionsLinkSoundChoose = { text = "freesound.org/404151/", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundChoose = display.newText( optionsLinkSoundChoose )
    titleSoundFX.linkSoundChoose:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundChoose.x = display.contentCenterX
    titleSoundFX.linkSoundChoose.y = titleSoundFX.nameComposerChoose.y + titleSoundFX.nameComposerChoose.height + titleSoundFX.linkSoundChoose.height / 2
    titleSoundFX.linkSoundChoose.id = "openURL"
    titleSoundFX.linkSoundChoose.URL = "https://freesound.org/people/MATTIX/sounds/404151/"
    titleSoundFX.linkSoundChoose:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundChoose)

    local optionsComposerWrong = { text = "RICHERlandTV", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerWrong = display.newText( optionsComposerWrong )
    titleSoundFX.nameComposerWrong:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerWrong.x = display.contentCenterX
    titleSoundFX.nameComposerWrong.y = titleSoundFX.linkSoundChoose.y + titleSoundFX.linkSoundChoose.height + titleSoundFX.nameComposerWrong.height
    creditsGroup:insert(titleSoundFX.nameComposerWrong)

    local optionsLinkSoundWrong = { text = "freesound.org/216090/", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundWrong = display.newText( optionsLinkSoundWrong )
    titleSoundFX.linkSoundWrong:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundWrong.x = display.contentCenterX
    titleSoundFX.linkSoundWrong.y = titleSoundFX.nameComposerWrong.y + titleSoundFX.nameComposerWrong.height + titleSoundFX.linkSoundWrong.height / 2
    titleSoundFX.linkSoundWrong.id = "openURL"
    titleSoundFX.linkSoundWrong.URL = "https://freesound.org/people/RICHERlandTV/sounds/216090/"
    titleSoundFX.linkSoundWrong:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundWrong)

    local optionsComposerRight = { text = "renatalmar", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerRight = display.newText( optionsComposerRight )
    titleSoundFX.nameComposerRight:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerRight.x = display.contentCenterX
    titleSoundFX.nameComposerRight.y = titleSoundFX.linkSoundWrong.y + titleSoundFX.linkSoundWrong.height + titleSoundFX.nameComposerRight.height
    creditsGroup:insert(titleSoundFX.nameComposerRight)

    local optionsLinkSoundRight = { text = "freesound.org/264981/", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundRight = display.newText( optionsLinkSoundRight )
    titleSoundFX.linkSoundRight:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundRight.x = display.contentCenterX
    titleSoundFX.linkSoundRight.y = titleSoundFX.nameComposerRight.y + titleSoundFX.nameComposerRight.height + titleSoundFX.linkSoundRight.height / 2
    titleSoundFX.linkSoundRight.id = "openURL"
    titleSoundFX.linkSoundRight.URL = "https://freesound.org/people/renatalmar/sounds/264981/"
    titleSoundFX.linkSoundRight:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundRight)

    local optionsComposerLock = { text = "Jagadamba", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerLock = display.newText( optionsComposerLock )
    titleSoundFX.nameComposerLock:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerLock.x = display.contentCenterX
    titleSoundFX.nameComposerLock.y = titleSoundFX.linkSoundRight.y + titleSoundFX.linkSoundRight.height + titleSoundFX.nameComposerLock.height
    creditsGroup:insert(titleSoundFX.nameComposerLock)

    local optionsLinkSoundLock = { text = "freesound.org/387713/", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundLock = display.newText( optionsLinkSoundLock )
    titleSoundFX.linkSoundLock:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundLock.x = display.contentCenterX
    titleSoundFX.linkSoundLock.y = titleSoundFX.nameComposerLock.y + titleSoundFX.nameComposerLock.height + titleSoundFX.linkSoundLock.height / 2
    titleSoundFX.linkSoundLock.id = "openURL"
    titleSoundFX.linkSoundLock.URL = "https://freesound.org/people/Jagadamba/sounds/387713/"
    titleSoundFX.linkSoundLock:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundLock)

    local optionsComposerWarning = { text = "severaltimes", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerWarning = display.newText( optionsComposerWarning )
    titleSoundFX.nameComposerWarning:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerWarning.x = display.contentCenterX
    titleSoundFX.nameComposerWarning.y = titleSoundFX.linkSoundLock.y + titleSoundFX.linkSoundLock.height + titleSoundFX.nameComposerWarning.height
    creditsGroup:insert(titleSoundFX.nameComposerWarning)

    local optionsLinkSoundWarning = { text = "freesound.org/80600/", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundWarning = display.newText( optionsLinkSoundWarning )
    titleSoundFX.linkSoundWarning:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundWarning.x = display.contentCenterX
    titleSoundFX.linkSoundWarning.y = titleSoundFX.nameComposerWarning.y + titleSoundFX.nameComposerWarning.height + titleSoundFX.linkSoundWarning.height / 2
    titleSoundFX.linkSoundWarning.id = "openURL"
    titleSoundFX.linkSoundWarning.URL = "https://freesound.org/people/severaltimes/sounds/80600/"
    titleSoundFX.linkSoundWarning:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundWarning)

    local optionsComposerIntro = { text = "ModulationStation", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleSoundFX.nameComposerIntro = display.newText( optionsComposerIntro )
    titleSoundFX.nameComposerIntro:setFillColor( unpack(colorTextDefault) )
    titleSoundFX.nameComposerIntro.x = display.contentCenterX
    titleSoundFX.nameComposerIntro.y = titleSoundFX.linkSoundWarning.y + titleSoundFX.linkSoundWarning.height + titleSoundFX.nameComposerIntro.height
    creditsGroup:insert(titleSoundFX.nameComposerIntro)

    local optionsLinkIntro = { text = "freesound.org/392465/\n" .. sozluk.getString("shortenedUse"), width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleSoundFX.linkSoundIntro = display.newText( optionsLinkIntro )
    titleSoundFX.linkSoundIntro:setFillColor( unpack(colorHyperlink) )
    titleSoundFX.linkSoundIntro.x = display.contentCenterX
    titleSoundFX.linkSoundIntro.y = titleSoundFX.nameComposerIntro.y + titleSoundFX.nameComposerIntro.height + titleSoundFX.linkSoundIntro.height / 2
    titleSoundFX.linkSoundIntro.id = "openURL"
    titleSoundFX.linkSoundIntro.URL = "https://freesound.org/people/ModulationStation/sounds/392465/"
    titleSoundFX.linkSoundIntro:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleSoundFX.linkSoundIntro)


    local optionsDisclaimer = { text = sozluk.getString("disclaimerSoundLicense"), width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.1, align = "center" }
    local textDisclaimer = display.newText( optionsDisclaimer )
    textDisclaimer:setFillColor( unpack(colorTextDefault) )
    textDisclaimer.x = display.contentCenterX
    textDisclaimer.y = titleSoundFX.linkSoundIntro.y + titleSoundFX.linkSoundIntro.height + textDisclaimer.height / 1.5
    creditsGroup:insert( textDisclaimer )

    local optionsFont = { text = sozluk.getString("font"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleFont = display.newText( optionsFont )
    titleFont:setFillColor( unpack(colorTitle) )
    titleFont.x = display.contentCenterX
    titleFont.y = textDisclaimer.y + textDisclaimer.height + titleFont.height / 1.5
    creditsGroup:insert( titleFont )

    local optionsFontAuthor = { text = "Jovanny Lemonad", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleFont.nameAuthor = display.newText( optionsFontAuthor )
    titleFont.nameAuthor:setFillColor( unpack(colorTextDefault) )
    titleFont.nameAuthor.x = display.contentCenterX
    titleFont.nameAuthor.y = titleFont.y + titleFont.height + titleFont.nameAuthor.height / 2
    creditsGroup:insert(titleFont.nameAuthor)

    local optionsFontName = { text = "Russo One", font = fontIngame, fontSize = sizeNames, align = "center" }
    titleFont.nameFont = display.newText( optionsFontName )
    titleFont.nameFont:setFillColor( unpack(colorTextDefault) )
    titleFont.nameFont.x = display.contentCenterX
    titleFont.nameFont.y = titleFont.nameAuthor.y + titleFont.nameAuthor.height + titleFont.nameFont.height / 2
    creditsGroup:insert(titleFont.nameFont)

    local optionsLinkFont = { text = "dafont.com/russo-one.font", width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleFont.linkFont = display.newText( optionsLinkFont )
    titleFont.linkFont:setFillColor( unpack(colorHyperlink) )
    titleFont.linkFont.x = display.contentCenterX
    titleFont.linkFont.y = titleFont.nameFont.y + titleFont.nameFont.height + titleFont.linkFont.height / 2
    titleFont.linkFont.id = "openURL"
    titleFont.linkFont.URL = "https://www.dafont.com/russo-one.font"
    titleFont.linkFont:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleFont.linkFont)

    local optionsDisclaimerFont = { text = sozluk.getString("disclaimerFont"), width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.2, align = "center" }
    titleFont.disclaimer = display.newText( optionsDisclaimerFont )
    titleFont.disclaimer:setFillColor( unpack(colorTextDefault) )
    titleFont.disclaimer.x = display.contentCenterX
    titleFont.disclaimer.y = titleFont.linkFont.y + titleFont.linkFont.height + titleFont.disclaimer.height / 2
    titleFont.disclaimer.id = "openURL"
    titleFont.disclaimer.URL = "https://scripts.sil.org/OFL"
    titleFont.disclaimer:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleFont.disclaimer)

    local optionsTitleEngine = { text = sozluk.getString("poweredBy"), font = fontLogo, fontSize = sizeTitles, align = "center" }
    local titleEngine = display.newText( optionsTitleEngine )
    titleEngine:setFillColor( unpack(colorTitle) )
    titleEngine.x = display.contentCenterX
    titleEngine.y = titleFont.disclaimer.y + titleFont.disclaimer.height + titleEngine.height / 1.5
    creditsGroup:insert(titleEngine)

    local scaleLogo = 0.5
    local fileLogo = "assets/other/logoSolar2D.png"
    if (currentTheme == "light") then
        fileLogo = "assets/other/logoSolar2D-light.png"
    end
    titleEngine.imageLogo = display.newImageRect( creditsGroup, fileLogo, 1144 * scaleLogo, 400 * scaleLogo )
    titleEngine.imageLogo.x = display.contentCenterX
    titleEngine.imageLogo.y = titleEngine.y + titleEngine.height + titleEngine.imageLogo.height / 1.5
    titleEngine.imageLogo.id = "openURL"
    titleEngine.imageLogo.URL = "https://solar2d.com/"
    titleEngine.imageLogo:addEventListener( "touch", handleTouch )
    creditsGroup:insert(titleEngine.imageLogo)

    local optionsDisclaimerCopyright = { text = sozluk.getString("disclaimerCopyright"), width = contentWidthSafe / 1.1, font = fontIngame, fontSize = sizeNames / 1.1, align = "center" }
    local textDisclaimerCopyright = display.newText( optionsDisclaimerCopyright )
    textDisclaimerCopyright:setFillColor( unpack(colorTextDefault) )
    textDisclaimerCopyright.x = display.contentCenterX
    textDisclaimerCopyright.y = titleEngine.imageLogo.y + titleEngine.imageLogo.height + textDisclaimerCopyright.height / 1.5
    creditsGroup:insert( textDisclaimerCopyright )


    -- I used a container so elements are not rendered outside of the specified bounds
    -- https://docs.coronalabs.com/guide/graphics/container.html#groups-vs.-containers
    containerCredits = display.newContainer( contentWidthSafe, yLimitBottom - menuSeparator.y )
    containerCredits.anchorX, containerCredits.anchorY = 0, 0
    containerCredits.x, containerCredits.y = 0, menuSeparator.y + menuSeparator.height / 2
    containerCredits.anchorChildren = false
    containerCredits.moveSpeed = 4
    creditsGroup:insert(containerCredits)

    containerCredits:insert(logoSB)
    containerCredits:insert(titleDevTeam)
    containerCredits:insert(titleDevTeam.name)
    containerCredits:insert(titleTester)
    containerCredits:insert(titleTester.name)
    containerCredits:insert(titleDevServerSide)
    containerCredits:insert(titleDevServerSide.name)
    containerCredits:insert(titleMusic)
    containerCredits:insert(titleMusic.nameComposer)
    containerCredits:insert(titleMusic.linkComposer)
    containerCredits:insert(titleMusic.nameTheme)
    containerCredits:insert(titleMusic.nameIngame)
    containerCredits:insert(titleSoundFX)
    containerCredits:insert(titleSoundFX.nameComposerChoose)
    containerCredits:insert(titleSoundFX.linkSoundChoose)
    containerCredits:insert(titleSoundFX.nameComposerWrong)
    containerCredits:insert(titleSoundFX.linkSoundWrong)
    containerCredits:insert(titleSoundFX.nameComposerRight)
    containerCredits:insert(titleSoundFX.linkSoundRight)
    containerCredits:insert(titleSoundFX.nameComposerLock)
    containerCredits:insert(titleSoundFX.linkSoundLock)
    containerCredits:insert(titleSoundFX.nameComposerWarning)
    containerCredits:insert(titleSoundFX.linkSoundWarning)
    containerCredits:insert(titleSoundFX.nameComposerIntro)
    containerCredits:insert(titleSoundFX.linkSoundIntro)
    containerCredits:insert(textDisclaimer)
    containerCredits:insert(titleFont)
    containerCredits:insert(titleFont.nameAuthor)
    containerCredits:insert(titleFont.nameFont)
    containerCredits:insert(titleFont.linkFont)
    containerCredits:insert(titleFont.disclaimer)
    containerCredits:insert(titleEngine)
    containerCredits:insert(titleEngine.imageLogo)
    containerCredits:insert(textDisclaimerCopyright)


    -- Store initial y coordinates so you can move them back to their starting point after each moved out of the screen
    logoSB.y0 = logoSB.y
    titleDevTeam.y0 = titleDevTeam.y
    titleDevTeam.name.y0 = titleDevTeam.name.y
    titleTester.y0 = titleTester.y
    titleTester.name.y0 = titleTester.name.y
    titleDevServerSide.y0 = titleDevServerSide.y
    titleDevServerSide.name.y0 = titleDevServerSide.name.y
    titleMusic.y0 = titleMusic.y
    titleMusic.nameComposer.y0 = titleMusic.nameComposer.y
    titleMusic.linkComposer.y0 = titleMusic.linkComposer.y
    titleMusic.nameTheme.y0 = titleMusic.nameTheme.y
    titleMusic.nameIngame.y0 = titleMusic.nameIngame.y
    titleSoundFX.y0 = titleSoundFX.y
    titleSoundFX.nameComposerChoose.y0 = titleSoundFX.nameComposerChoose.y
    titleSoundFX.linkSoundChoose.y0 = titleSoundFX.linkSoundChoose.y
    titleSoundFX.nameComposerWrong.y0 = titleSoundFX.nameComposerWrong.y
    titleSoundFX.linkSoundWrong.y0 = titleSoundFX.linkSoundWrong.y
    titleSoundFX.nameComposerRight.y0 = titleSoundFX.nameComposerRight.y
    titleSoundFX.linkSoundRight.y0 = titleSoundFX.linkSoundRight.y
    titleSoundFX.nameComposerLock.y0 = titleSoundFX.nameComposerLock.y
    titleSoundFX.linkSoundLock.y0 = titleSoundFX.linkSoundLock.y
    titleSoundFX.nameComposerWarning.y0 = titleSoundFX.nameComposerWarning.y
    titleSoundFX.linkSoundWarning.y0 = titleSoundFX.linkSoundWarning.y
    titleSoundFX.nameComposerIntro.y0 = titleSoundFX.nameComposerIntro.y
    titleSoundFX.linkSoundIntro.y0 = titleSoundFX.linkSoundIntro.y
    textDisclaimer.y0 = textDisclaimer.y
    titleFont.y0 = titleFont.y
    titleFont.nameAuthor.y0 = titleFont.nameAuthor.y
    titleFont.nameFont.y0 = titleFont.nameFont.y
    titleFont.linkFont.y0 = titleFont.linkFont.y
    titleFont.disclaimer.y0 = titleFont.disclaimer.y
    titleEngine.y0 = titleEngine.y
    titleEngine.imageLogo.y0 = titleEngine.imageLogo.y
    textDisclaimerCopyright.y0 = textDisclaimerCopyright.y
end

local function cleanUp()
    Runtime:removeEventListener( "enterFrame", moveCredits )
end

function scene:create( event )
    mainGroup = self.view

    creditsGroup = display.newGroup( )

    createCreditsElements()

    mainGroup:insert(creditsGroup)
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