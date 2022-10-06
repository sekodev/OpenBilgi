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

local mainGroup
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

local tmr


local function changeScene()
	timer.cancel( tmr )
	tmr = nil

    local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "logoScreen"}}
    composer.gotoScene( "screens.menuScreen", optionsChangeScene )
end

function scene:create( event )
    mainGroup = self.view

    local background = display.newRect( mainGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight )
    background:setFillColor( unpack(themeData.colorBackground) ) -- themeData is global, main.lua

    -- This is included because of low asset quality
    -- Can be fixed with a higher quality asset
    local scaleLogo = 0.8

    -- Your company/team logo here
    local logoSB = display.newImageRect( mainGroup, "assets/other/logoSleepyBug.png", 813 * scaleLogo, 194 * scaleLogo )
    logoSB.x, logoSB.y = display.contentCenterX, display.contentCenterY
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()

        -- Wait some time and automatically change to menu screen
        tmr = timer.performWithDelay( 1500, changeScene, 1 )
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