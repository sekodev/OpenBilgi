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

local mainGroup

local sceneTransitionTime = composer.getVariable( "sceneTransitionTime" )
local sceneTransitionEffect = composer.getVariable( "sceneTransitionEffect" )

local timerChangeScene


local function changeScene()
    timer.cancel( timerChangeScene )
    timerChangeScene = nil

    local optionsChangeScene = {effect = sceneTransitionEffect, time = sceneTransitionTime, params = {callSource = "logoScreen"}}
    composer.gotoScene( "screens.menuScreen", optionsChangeScene )
end

local function printBuildVersion()
    local fontLogo = composer.getVariable( "fontLogo" )
    local colorTextDefault = themeData.colorTextDefault

    local optionsLabelVersion = { text = composer.getVariable("currentVersion"), 
        height = 0, align = "center", font = fontLogo, fontSize = contentHeightSafe / 50 }
    local labelVersionNumber = display.newText( optionsLabelVersion )
    labelVersionNumber:setFillColor( unpack(colorTextDefault) )
    labelVersionNumber.x = display.contentCenterX
    labelVersionNumber.y = contentHeightSafe - labelVersionNumber.height
    mainGroup:insert(labelVersionNumber)
end

function scene:create( event )
    mainGroup = self.view

    local background = display.newRect( mainGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) ) -- themeData is global, main.lua

    -- Your logo here
    local heightLogo = contentHeightSafe / 3
    local widthLogo = heightLogo
    local logoSB = display.newImageRect( mainGroup, "assets/other/logoSleepyBug.png", widthLogo, heightLogo)
    logoSB.x, logoSB.y = display.contentCenterX, display.contentCenterY

    printBuildVersion()
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()

        -- Wait some time and automatically change to menu screen
        timerChangeScene = timer.performWithDelay( 1500, changeScene, 1 )
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
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