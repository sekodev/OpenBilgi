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

-- Set properties to hide OS related UI elements
display.setStatusBar( display.HiddenStatusBar )

native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
native.setProperty( "prefersHomeIndicatorAutoHidden", true )

composer = require ( "libs.composer_alt" ) -- Modified version is used for tossLeft effect

preference = require ( "libs.preference" ) -- Used to save player-related variables
themeSettings = require ( "libs.themeSettings" ) -- Contains theme data
utils = require ( "libs.utils" ) -- Contains universally usable code
commonMethods = require ( "libs.commonMethods" ) -- Contains project specific functions used in different occassions


contentWidthSafe = display.safeActualContentWidth
contentHeightSafe = display.safeActualContentHeight
contentWidth = display.contentWidth
contentHeight = display.contentHeight

math.randomseed( os.time() )


local function assignVariables()
    -- userX variables are inactive in current builds.
    -- Those variables were used for online functionalities that existed before.
    -- Stays in code to keep preference/save file intact.
    composer.setVariable( "userID" , "" )
    composer.setVariable( "userName" , "asd" )
    composer.setVariable( "userToken", "" )

    composer.setVariable( "emailSupport", "info.sleepybug@gmail.com" ) -- Used to show player a way to get in contact
    composer.setVariable( "currentVersion" , "OpenBilgi, v0.8 (57)" ) -- Visible in Settings screen
    composer.setVariable( "idAppStore" , "123456789" ) -- Required to show rating pop-ups
    composer.setVariable( "urlLandingPage" , "https://sekodev.github.io/bilgiWeb/" ) -- Required for sharing landing page on social media
    composer.setVariable( "pathIconFile" , "assets/menu/iconQuiz.png" ) -- Required for share UI

    composer.setVariable( "currentTheme" , "dark") -- dark/light
    composer.setVariable( "currentLanguage" , "tr") -- Default: Turkish
    composer.setVariable( "fullScreen" , true) -- Full screen support - Default: true
    composer.setVariable( "currentAppScene" , "menuScreen") -- Required for back button on Android
    composer.setVariable( "timeTransitionScene", 250 ) -- Used in every scene change

    composer.setVariable( "fontIngame", "Arial" )
    composer.setVariable( "fontLogo", "Russo_One.ttf" )

    composer.setVariable( "askedRateGame", false ) -- Used to show rate game popup
    composer.setVariable( "askedConsent", false ) -- Inactive
    composer.setVariable( "analyticsConsent", false ) -- Inactive

    composer.setVariable( "soundLevel", 0.5 )
    composer.setVariable( "musicLevel", 0.5 )

    composer.setVariable( "timeSuspend", 0 ) -- Used to track plsyer away time to prevent searching for answer

    composer.setVariable( "lastRandomSeed", 0 )
    composer.setVariable( "lastQuestionSet", 1 )    -- fail-safe value is 1

    -- Save and quit variables
    composer.setVariable( "savedRandomSeed", 0 )
    composer.setVariable( "savedQuestionSet", 1 )
    composer.setVariable( "savedQuestionsAsked", { } )
    composer.setVariable( "savedQuestionCurrent", 1 )
    composer.setVariable( "savedPlayerScore", 0 )
    composer.setVariable( "savedIsRevived", false )

    -- Number of questions sets available
    -- New sets should be added to lockedQuestionSets
    composer.setVariable( "lockedQuestionSets", { 1, 2, 3, 4 } )
    composer.setVariable( "availableQuestionSets", { 1 } )
    composer.setVariable( "completedQuestionSets", { } )

    -- Starting pack for player
    composer.setVariable( "locksAvailable", 3 )
    composer.setVariable( "coinsAvailable", 250 )
    composer.setVariable( "coinsCompletedSet", 250 )
    composer.setVariable( "priceLockCoins", 1000 )

    -- Amount of questions can be changed here
    -- Single set is number of questions between two campfires
    composer.setVariable( "amountQuestionSingleGame", 20 )
    composer.setVariable( "amountQuestionSingleSet", 5 )

    composer.setVariable( "lockInfoAvailable", true ) -- "Do not show again" flag for lock usage information
    composer.setVariable( "percentageRevival", 2 )      -- default - %2
    composer.setVariable( "sharedGame", false ) -- Used to increase percentageRevival

    composer.setVariable( "isQuestionResetNeeded", true ) -- Used to fix a consistency between versions

    composer.setVariable( "isTermsPrivacyAccepted", false ) -- Privacy policy & terms of use information flag

    -- Statistics variables
    composer.setVariable( "scoreHigh", 0 )
    composer.setVariable( "gamesPlayed", 0 )
    composer.setVariable( "questionsAnsweredTotal", 0 )
    composer.setVariable( "runsCompleted", 0 )
    composer.setVariable( "locksUsed", 0 )
    composer.setVariable( "coinsTotal", 0 )
end

-- Loads previously saved settings and variables
local function loadPreferences()
    if ( preference.getValue("settings") ) then
        composer.setVariable( "userToken", preference.getValue("settings")[1] )
        composer.setVariable( "askedConsent", preference.getValue("settings")[2] )
        composer.setVariable( "analyticsConsent", preference.getValue("settings")[3] )
        composer.setVariable( "soundLevel", preference.getValue("settings")[4] )
        composer.setVariable( "musicLevel", preference.getValue("settings")[5] )
        composer.setVariable( "timeSuspend", preference.getValue("settings")[6] )
        composer.setVariable( "scoreHigh", preference.getValue("settings")[7] )
        composer.setVariable( "gamesPlayed", preference.getValue("settings")[8] )
        composer.setVariable( "questionsAnsweredTotal", preference.getValue("settings")[9] )
        composer.setVariable( "askedRateGame", preference.getValue("settings")[10] )
        composer.setVariable( "currentTheme", preference.getValue("settings")[11] )
        composer.setVariable( "percentageRevival", preference.getValue("settings")[12] )
        composer.setVariable( "sharedGame", preference.getValue("settings")[13] )
        composer.setVariable( "userID", preference.getValue("settings")[14] )
        composer.setVariable( "userName", preference.getValue("settings")[15] )
        composer.setVariable( "runsCompleted", preference.getValue("settings")[16] )
        composer.setVariable( "lastRandomSeed", preference.getValue("settings")[17] )
        composer.setVariable( "availableQuestionSets", preference.getValue("settings")[18] )
        composer.setVariable( "lockedQuestionSets", preference.getValue("settings")[19] )
        composer.setVariable( "locksAvailable", preference.getValue("settings")[20] )
        composer.setVariable( "lockInfoAvailable", preference.getValue("settings")[21] )
        composer.setVariable( "coinsAvailable", preference.getValue("settings")[22] )
        composer.setVariable( "isQuestionResetNeeded", preference.getValue("settings")[23] )
        composer.setVariable( "lastQuestionSet", preference.getValue("settings")[24] )
        composer.setVariable( "completedQuestionSets", preference.getValue("settings")[25] )
        composer.setVariable( "locksUsed", preference.getValue("settings")[26] )
        composer.setVariable( "coinsTotal", preference.getValue("settings")[27] )
        composer.setVariable( "savedRandomSeed", preference.getValue("settings")[28] )
        composer.setVariable( "savedQuestionSet", preference.getValue("settings")[29] )
        composer.setVariable( "savedQuestionsAsked", preference.getValue("settings")[30] )
        composer.setVariable( "savedQuestionCurrent", preference.getValue("settings")[31] )
        composer.setVariable( "savedPlayerScore", preference.getValue("settings")[32] )
        composer.setVariable( "savedIsRevived", preference.getValue("settings")[33] )
        composer.setVariable( "isTermsPrivacyAccepted", preference.getValue("settings")[34] )
        composer.setVariable( "fullScreen", preference.getValue("settings")[35] )
    end
end

-- Saves settings and variables
function savePreferences()
    preference.save{settings = { 
        composer.getVariable( "userToken" ),
        composer.getVariable( "askedConsent" ),
        composer.getVariable( "analyticsConsent" ),
        composer.getVariable( "soundLevel" ),
        composer.getVariable( "musicLevel" ),
        composer.getVariable( "timeSuspend" ),
        composer.getVariable( "scoreHigh" ),
        composer.getVariable( "gamesPlayed" ),
        composer.getVariable( "questionsAnsweredTotal" ),
        composer.getVariable( "askedRateGame" ),
        composer.getVariable( "currentTheme" ),
        composer.getVariable( "percentageRevival" ),
        composer.getVariable( "sharedGame" ),
        composer.getVariable( "userID" ),
        composer.getVariable( "userName" ),
        composer.getVariable( "runsCompleted" ),
        composer.getVariable( "lastRandomSeed" ),
        composer.getVariable( "availableQuestionSets" ),
        composer.getVariable( "lockedQuestionSets" ),
        composer.getVariable( "locksAvailable" ),
        composer.getVariable( "lockInfoAvailable" ),
        composer.getVariable( "coinsAvailable" ),
        composer.getVariable( "isQuestionResetNeeded" ),
        composer.getVariable( "lastQuestionSet" ),
        composer.getVariable( "completedQuestionSets" ),
        composer.getVariable( "locksUsed" ),
        composer.getVariable( "coinsTotal" ),
        composer.getVariable( "savedRandomSeed" ),
        composer.getVariable( "savedQuestionSet" ),
        composer.getVariable( "savedQuestionsAsked" ),
        composer.getVariable( "savedQuestionCurrent" ),
        composer.getVariable( "savedPlayerScore" ),
        composer.getVariable( "savedIsRevived" ),
        composer.getVariable( "isTermsPrivacyAccepted" ),
        composer.getVariable( "fullScreen" ), } }
end

-- Reset preferences file
-- Used in previous versions but not used in later versions to avoid unintended user errors
local function resetPreferences()
    assignVariables()
    savePreferences()
end

-- Resets question sets
-- Used in settings screen
local function resetQuestionSets()
    local lockedQuestionSets = { 1, 2, 3, 4 }
    local availableQuestionSets = { 1 }
    local completedQuestionSets = { }
    
    table.remove( lockedQuestionSets, 1 )

    composer.setVariable( "availableQuestionSets", availableQuestionSets )
    composer.setVariable( "completedQuestionSets", completedQuestionSets )
    composer.setVariable( "lockedQuestionSets", lockedQuestionSets )
    composer.setVariable( "lastQuestionSet", 1 )
end

-- Picks the starting set
-- Starting set was random in earlier versions but thought it would be better to fix it to 1 for better UX
-- Fine tuning the first question set after making it a fixed value is important
local function pickStartingQuestionSet()
    local lockedQuestionSets = composer.getVariable("lockedQuestionSets")
    local availableQuestionSets = composer.getVariable("availableQuestionSets")
    local isQuestionResetNeeded = composer.getVariable("isQuestionResetNeeded")

    -- trigger reset for previous build versions
    if (isQuestionResetNeeded) then
        composer.setVariable( "isQuestionResetNeeded", false )

        resetQuestionSets()
    else
        if (lockedQuestionSets ~= nil) then
            -- defensive. reset questions if available question sets and locked question sets is somehow not filled
            if (#lockedQuestionSets <= 0 and availableQuestionSets) then
                if (#availableQuestionSets <= 0) then
                    resetQuestionSets()
                end
            end
        else
            -- reset in case the locked question sets are somehow not created
            resetQuestionSets()
        end
    end
end

-- Safety net for bugs introduced in different versions and game reset
local function resetFaultyVariables()
    -- reset fault revival percentage
    if (composer.getVariable( "percentageRevival" ) > 10) then
        composer.setVariable( "percentageRevival", 2 )      -- default - %2
    end

    -- reset random seed on cold start
    composer.setVariable( "lastRandomSeed", 0 )

    -- set starting question set to 1
    local amountAvailableQuestionSets = #composer.getVariable( "availableQuestionSets" )
    if ( amountAvailableQuestionSets <= 1 ) then
        pickStartingQuestionSet()
    end

    savePreferences()
end

-- Resets question sets, locks previously unlocked sets
-- Triggered from settings screen
function resetQuestions()
    -- preferences not reset to preserve earned currency and statistics
    --resetPreferences()
    resetQuestionSets()
    resetFaultyVariables()
end

-- Adjust screen dimensions depending on full screen option
function adjustScreenDimensions(fullScreen)
    if (fullScreen == false) then
        contentWidth = contentWidthSafe
        contentHeight = contentHeightSafe
    else
        contentWidth = display.contentWidth
        contentHeight = display.contentHeight
    end
end


assignVariables()

-- Import sozluk library for localization
-- https://github.com/sekodev/sozluk
sozluk = require ( "libs.sozluk" )
sozluk.setTranslationsPath( "libs.translations" )
sozluk.setTranslationFolder( "translations" )
sozluk.init()


-- Code block used for language selection
local shownLanguage

if (system.getInfo("targetAppStore") == "google" or system.getInfo("targetAppStore") == "amazon" or system.getInfo("targetAppStore") == "none") then
    shownLanguage = system.getPreference( "locale", "language" )
elseif (system.getInfo("targetAppStore") == "apple") then
    shownLanguage = string.sub( system.getPreference( "ui", "language" ), 1, 2 )
end

if ( shownLanguage == "tr" or shownLanguage == "TR" or "Türkçe" == shownLanguage or shownLanguage == "Turkish" or "Turkce" == shownLanguage ) then
    composer.setVariable( "currentLanguage", "tr" )
else
    composer.setVariable( "currentLanguage", "en" )
end

--composer.setVariable( "currentLanguage", "tr" )
sozluk.setSelectedTranslation( composer.getVariable("currentLanguage") )

-- Load preferences file and initialize variables
loadPreferences()

-- Adjust screen dimensions depending on full screen option
adjustScreenDimensions(composer.getVariable( "fullScreen" ))

-- Pick starting set and handle bugs caused by previous versions
pickStartingQuestionSet()
resetFaultyVariables()


-- Assign selected theme data
local currentTheme = composer.getVariable( "currentTheme" )
themeData = themeSettings.getData(currentTheme)

-- Start playing theme music
audio.setVolume( 1 )
streamMusicBackground = audio.loadStream("assets/music/menuTheme.mp3")
channelMusicBackground = audio.play(streamMusicBackground, { channel = 1, loops = -1})
audio.setVolume( composer.getVariable("musicLevel"), {channel = channelMusicBackground} )

for i = 2, audio.totalChannels do
    audio.setVolume( composer.getVariable("soundLevel"), {channel = i} )
end


local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

-- Back button behavior for Android
local function onKeyEvent( event )
     if ( event.keyName == "back" and event.phase == "up" ) then
        local currentAppScene = composer.getVariable( "currentAppScene" )
        
        if ( currentAppScene == "menuScreen" ) then
            native.requestExit()
        elseif ( currentAppScene == "gameScreen" ) then
            composer.setVariable( "currentAppScene", "menuScreen" )

            audio.fade( {channel = channelMusicBackground, time = timeTransitionScene, volume = 0} )

            local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = currentAppScene}}
            composer.gotoScene( "screens.menuScreen", optionsChangeScene )
        else
            composer.setVariable( "currentAppScene", "menuScreen" )

            --audio.fade( {channel = channelMusicBackground, time = timeTransitionScene, volume = 0} )

            local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = currentAppScene}}
            composer.gotoScene( "screens.menuScreen", optionsChangeScene )
        end
        return true
    end
end

Runtime:addEventListener( "key", onKeyEvent )


-- After everything is done, switch to logo screen to start the game
local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
    params = {callSource = "main"}}
composer.gotoScene( "screens.logoScreen", optionsChangeScene )
