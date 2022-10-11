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

local particleDesigner = require( "libs.particleDesigner" )

local mainGroup, successGroup

local timeTransitionScene = composer.getVariable( "timeTransitionScene" )
local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )

local yStartingPlacement = display.safeScreenOriginY

local scoreCurrent = 0
local questionCurrent = 1
local coinsEarned = 0
local statusGame = ""

local textMessageSuccess
local emitterFX
local tableWoods = {}

local soundCampfire, soundWisp


local function cleanUp()
    for i = #tableWoods, 1, -1 do
        tableWoods[i] = {}
        table.remove( tableWoods, i )
    end
end

local function createWisp()
    fileParticleFX = "assets/particleFX/wisp.json"
    if (themeData.themeSelected == "light") then
        fileParticleFX = "assets/particleFX/wisp-light.json"
    end

    soundWisp = audio.loadSound( "assets/soundFX/revival.mp3" )
end

local function createBonfire()
    local heightWoodFire = 30

    for i = 1, 5 do
        local woodHorizontal = display.newRect( successGroup, 0, 0, display.safeActualContentWidth / 2, heightWoodFire )
        woodHorizontal:setFillColor( .52, .37, .26 )
        woodHorizontal.x = display.contentCenterX

        if (i == 1) then
            woodHorizontal.y = display.safeActualContentHeight - woodHorizontal.height * 2
        else
            woodHorizontal.y = tableWoods[i - 1].y - woodHorizontal.height * 1.5
        end

        table.insert( tableWoods, woodHorizontal )
    end

    local woodFire = display.newRect( successGroup, 0, 0, display.safeActualContentWidth / 2, heightWoodFire )
    woodFire.rotation = 120
    woodFire.x = display.contentCenterX - woodFire.width / 2
    woodFire.y = tableWoods[3].y - tableWoods[3].height / 2 - woodFire.height / 2
    woodFire.alpha = 1

    local woodFire2 = display.newRect( successGroup, 0, 0, woodFire.width, heightWoodFire )
    woodFire2.x = display.contentCenterX + woodFire2.width / 2
    woodFire2.rotation = 60
    woodFire2.alpha = woodFire.alpha
    woodFire2.y = woodFire.y

    local woodFire3 = display.newRect( successGroup, 0, 0, display.safeActualContentWidth / 2, heightWoodFire )
    woodFire3.rotation = 110
    woodFire3.x = display.contentCenterX - woodFire.width / 4
    woodFire3.y = woodFire.y
    woodFire3.alpha = 1

    local woodFire4 = display.newRect( successGroup, 0, 0, woodFire.width, heightWoodFire )
    woodFire4.x = display.contentCenterX + woodFire.width / 4
    woodFire4.rotation = 70
    woodFire4.alpha = woodFire.alpha
    woodFire4.y = woodFire.y

    local woodFire5 = display.newRect( successGroup, 0, 0, woodFire.width, heightWoodFire )
    woodFire5.x = display.contentCenterX
    woodFire5.rotation = 90
    woodFire5.alpha = woodFire.alpha
    woodFire5.y = woodFire.y

    fileParticleFX = "assets/particleFX/bonfire.json"
    if (themeData.themeSelected == "light") then
        fileParticleFX = "assets/particleFX/bonfire-light.json"
    end

    woodFire:setFillColor( .52, .37, .26 )
    woodFire2:setFillColor( .52, .37, .26 )
    woodFire3:setFillColor( .52, .37, .26 )
    woodFire4:setFillColor( .52, .37, .26 )
    woodFire5:setFillColor( .52, .37, .26 )

    soundCampfire = audio.loadSound( "assets/soundFX/campfire.mp3" )
end

local function handleTouch(event)
    if (event.phase == "ended") then
        audio.fadeOut( { channel = 3, time = 1000 } )
        emitterFX:stop()

        transition.to( emitterFX, { time = 1000, alpha = 0, onComplete = function ()
                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
                    params = {callSource = "gameScreen", scoreCurrent = scoreCurrent, questionCurrent = questionCurrent, 
                    coinsEarned = coinsEarned, statusGame = statusGame}}
                composer.gotoScene( "screens.endScreen", optionsChangeScene )
            end})
    end
    return true
end

local function createScreenElements()
    local backgroundSuccess = display.newRect( successGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    backgroundSuccess:setFillColor( unpack(themeData.colorBackground) )
    backgroundSuccess:addEventListener( "touch", handleTouch )

    local fontSizeSuccessTitle = display.safeActualContentHeight / 20
    local fontSizeSuccessMessage = display.safeActualContentHeight / 35

    local optionsTextSuccessTitle = { text = sozluk.getString("successCongrats"), width = display.safeActualContentWidth / 1.1, height = 0,
        font = fontLogo, fontSize = fontSizeSuccessTitle, align = "center" }
    local textMessageSuccessTitle = display.newText( optionsTextSuccessTitle )
    textMessageSuccessTitle:setFillColor( unpack( themeData.colorTextDefault ) )
    textMessageSuccessTitle.x = display.contentCenterX
    textMessageSuccessTitle.y = yStartingPlacement + textMessageSuccessTitle.height * 2
    successGroup:insert(textMessageSuccessTitle)

    local messageSuccess = ""
    if (statusGame == "successSetCompletedBefore") then
        messageSuccess = sozluk.getString("successSetCompletedBefore")
    elseif (statusGame == "successSetUnlocked") then
        messageSuccess = sozluk.getString("successSetUnlocked")
    elseif (statusGame == "successSetNA") then
        messageSuccess = sozluk.getString("successSetNA")
    elseif (statusGame == "successEndgame") then
        messageSuccess = sozluk.getString("successEndgame")
    end

    local optionsTextSuccessMessage = { text = messageSuccess, width = display.safeActualContentWidth / 1.1, height = 0,
        font = fontLogo, fontSize = fontSizeSuccessMessage, align = "center" }
    textMessageSuccess = display.newText( optionsTextSuccessMessage )
    textMessageSuccess:setFillColor( unpack( themeData.colorTextDefault ) )
    textMessageSuccess.x = display.contentCenterX
    textMessageSuccess.y = textMessageSuccessTitle.y + textMessageSuccessTitle.height / 2 + textMessageSuccess.height
    successGroup:insert(textMessageSuccess)
end

local function unloadSoundFX()
    for i = 2, audio.totalChannels do
        audio.stop(i)
    end

    if (soundWisp) then
        audio.dispose( soundWisp )
        soundWisp = nil
    end

    if (soundCampfire) then
        audio.dispose( soundCampfire )
        soundCampfire = nil
    end
end

function scene:create( event )
    mainGroup = self.view

    successGroup = display.newGroup( )

    if (event.params) then
        -- Since this screen acts as a transition, we need to get and pass those values to endScreen
        if (event.params["scoreCurrent"]) then
            scoreCurrent = event.params["scoreCurrent"]
        end

        if (event.params["questionCurrent"]) then
            questionCurrent = event.params["questionCurrent"]
        end

        if (event.params["statusGame"]) then
            statusGame = event.params["statusGame"]
        end

        if (event.params["coinsEarned"]) then
            coinsEarned = event.params["coinsEarned"]
        end
    end

    createScreenElements()

    -- Show different effects depending on new question sets
    -- If a new question set is available, a bonfire will be shown
    -- If game is out of new question sets, player will see the wisp
    if (statusGame == "successSetUnlocked" or "successSetCompletedBefore" == statusGame) then
        createBonfire()
    elseif (statusGame == "successSetNA" or "successEndgame" == statusGame) then
        createWisp()
    end

    mainGroup:insert( successGroup )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()

        emitterFX = particleDesigner.newEmitter( fileParticleFX )
        emitterFX.x = display.contentCenterX

        audio.setVolume( composer.getVariable("soundLevel"), {channel = 3} )

        -- Show different success messages depending on new question set availability
        if (statusGame == "successSetUnlocked" or "successSetCompletedBefore" == statusGame) then
            emitterFX.y = tableWoods[1].y + tableWoods[1].height
            audio.play( soundCampfire, {channel = 3, loops = -1} )
        elseif(statusGame == "successSetNA" or "successEndgame" == statusGame) then
            emitterFX.y = textMessageSuccess.y + textMessageSuccess.height * 1.5

            audio.play( soundWisp, {channel = 3, loops = -1} )
        end
        successGroup:insert(emitterFX)
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        cleanUp()
    elseif ( phase == "did" ) then
        unloadSoundFX()
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