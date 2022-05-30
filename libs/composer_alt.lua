-----------------------------------------------------------------------------------------
--
-- Corona Labs
--
-- composer.lua
--
-- Code is MIT licensed; see https://www.coronalabs.com/links/code/license
-- 
-- Repository: https://github.com/coronalabs/framework-composer
-----------------------------------------------------------------------------------------

local Library = require "CoronaLibrary"

-- the transition object
local lib = Library:new{ name='composer', publisherId='com.coronalabs', version=2 }

-- the scene class
local composerScene = require ( "composer_scene" )

-----------------------------------------------------------------------------------------

-- top level group in which the scenes will be inserted
local stage = display.newGroup()

-- instance variables

-- reference to the currently loaded scene's module name (String)
lib._currentModule = nil

-- reference to the currently loaded scene's display group
lib._currentScene = nil

-- reference to the previously loaded scene's module name (String)
lib._previousScene = nil

-- reference to the currently shown scene in overlay / popup
lib._currentOverlayScene = nil

-- the touch-disabling overlay
lib._touchOverlay = nil

-- the touch-disabling rect that goes in the background of overlay scenes
lib._modalRect = nil

-- a table containing the history of the most recently used scenes, Strings
lib.loadedSceneModules = {}

-- a table containing the loaded scenes. references to package.loaded removed below
lib.loadedScenes = {}

-- the internal table used for storing variables across composer scenes
lib.variables = {}

lib.stage = stage 	-- allows external access to composer's display group
lib.recycleOnLowMemory = true -- if false, no scenes will auto-purge on low memory
lib.recycleOnSceneChange = false -- if true, will automatically purge non-active scenes on scene change
lib.isDebug = false	-- if true, will print useful info to the terminal in some situations
lib.debugPrefix = "COMPOSER: "

-- localized variables
local _tonumber = tonumber
local _pairs = pairs
local _toString = tostring
local _stringSub = string.sub
local _stringFind = string.find
local _type = type
local _stringFormat = string.format
local _getInfo = system.getInfo
local displayW = display.contentWidth
local displayH = display.contentHeight
local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

-----------------------------------------------------------------------------------------

-- TRANSITION EFFECTS

local effectList = {
	["fade"] =
	{
		["from"] =
		{
			alphaStart = 1.0,
			alphaEnd = 0,
		},

		["to"] =
		{
			alphaStart = 0,
			alphaEnd = 1.0
		}
	},
	
	["zoomOutIn"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 0.001,
			yScaleEnd = 0.001
		},

		["to"] =
		{
			xScaleStart = 0.001,
			yScaleStart = 0.001,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0
		},
		hideOnOut = true
	},
	
	["zoomOutInFade"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 0.001,
			yScaleEnd = 0.001,
			alphaStart = 1.0,
			alphaEnd = 0
		},

		["to"] =
		{
			xScaleStart = 0.001,
			yScaleStart = 0.001,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			alphaStart = 0,
			alphaEnd = 1.0
		},
		hideOnOut = true
	},
	
	["zoomInOut"] =
	{
		["from"] =
		{
			xEnd = -displayW*0.5,
			yEnd = -displayH*0.5,
			xScaleEnd = 2.0,
			yScaleEnd = 2.0
		},

		["to"] =
		{
			xScaleStart = 2.0,
			yScaleStart = 2.0,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = -displayW*0.5,
			yStart = -displayH*0.5,
			xEnd = 0,
			yEnd = 0
		},
		hideOnOut = true
	},
	
	["zoomInOutFade"] =
	{
		["from"] =
		{
			xEnd = -displayW*0.5,
			yEnd = -displayH*0.5,
			xScaleEnd = 2.0,
			yScaleEnd = 2.0,
			alphaStart = 1.0,
			alphaEnd = 0
		},

		["to"] =
		{
			xScaleStart = 2.0,
			yScaleStart = 2.0,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = -displayW*0.5,
			yStart = -displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			alphaStart = 0,
			alphaEnd = 1.0
		},
		hideOnOut = true
	},
	
	["flip"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			xScaleEnd = 0.001
		},

		["to"] =
		{
			xScaleStart = 0.001,
			xScaleEnd = 1.0,
			xStart = displayW*0.5,
			xEnd = 0
		}
	},
	
	["flipFadeOutIn"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			xScaleEnd = 0.001,
			alphaStart = 1.0,
			alphaEnd = 0
		},

		["to"] =
		{
			xScaleStart = 0.001,
			xScaleEnd = 1.0,
			xStart = displayW*0.5,
			xEnd = 0,
			alphaStart = 0,
			alphaEnd = 1.0
		}
	},
	
	["zoomOutInRotate"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 0.001,
			yScaleEnd = 0.001,
			rotationStart = 0,
			rotationEnd = -360
		},

		["to"] =
		{
			xScaleStart = 0.001,
			yScaleStart = 0.001,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			rotationStart = -360,
			rotationEnd = 0
		},
		hideOnOut = true
	},
	
	["zoomOutInFadeRotate"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 0.001,
			yScaleEnd = 0.001,
			rotationStart = 0,
			rotationEnd = -360,
			alphaStart = 1.0,
			alphaEnd = 0
		},

		["to"] =
		{
			xScaleStart = 0.001,
			yScaleStart = 0.001,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			rotationStart = -360,
			rotationEnd = 0,
			alphaStart = 0,
			alphaEnd = 1.0
		},
		hideOnOut = true
	},
	
	["zoomInOutRotate"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 2.0,
			yScaleEnd = 2.0,
			rotationStart = 0,
			rotationEnd = -360
		},

		["to"] =
		{
			xScaleStart = 2.0,
			yScaleStart = 2.0,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			rotationStart = -360,
			rotationEnd = 0
		},
		hideOnOut = true
	},
	
	["zoomInOutFadeRotate"] =
	{
		["from"] =
		{
			xEnd = displayW*0.5,
			yEnd = displayH*0.5,
			xScaleEnd = 2.0,
			yScaleEnd = 2.0,
			rotationStart = 0,
			rotationEnd = -360,
			alphaStart = 1.0,
			alphaEnd = 0
		},

		["to"] =
		{
			xScaleStart = 2.0,
			yScaleStart = 2.0,
			xScaleEnd = 1.0,
			yScaleEnd = 1.0,
			xStart = displayW*0.5,
			yStart = displayH*0.5,
			xEnd = 0,
			yEnd = 0,
			rotationStart = -360,
			rotationEnd = 0,
			alphaStart = 0,
			alphaEnd = 1.0
		},
		hideOnOut = true
	},
	
	["fromRight"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = displayW,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["fromLeft"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = -displayW,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["fromTop"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = 0,
			yStart = -displayH,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["fromBottom"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = 0,
			yStart = displayH,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["slideLeft"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = -displayW,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = displayW,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["slideRight"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = displayW,
			yEnd = 0,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = -displayW,
			yStart = 0,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["slideDown"] =
	{ 
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = displayH,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = 0,
			yStart = -displayH,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["slideUp"] =
	{
		["from"] =
		{
			xStart = 0,
			yStart = 0,
			xEnd = 0,
			yEnd = -displayH,
			transition = easing.outQuad
		},

		["to"] =
		{
			xStart = 0,
			yStart = displayH,
			xEnd = 0,
			yEnd = 0,
			transition = easing.outQuad
		},
		concurrent = true,
		sceneAbove = true
	},
	
	["crossFade"] =
	{
		["from"] =
		{
			alphaStart = 1.0,
			alphaEnd = 0,
		},

		["to"] =
		{
			alphaStart = 0,
			alphaEnd = 1.0
		},
		concurrent = true
	},

	["tossLeft"] =
	{
		["from"] =
		{
			xStart = 0,
			xEnd = -displayW * 2,
			rotationStart = 0,
			rotationEnd = -30,
		},

		["to"] =
		{
			xStart = 0,
			xEnd = 0,
		},
		concurrent = true
	},
}
lib.effectList = effectList

-----------------------------------------------------------------------------------------

local function debug_print( ... )
	print( lib.debugPrefix )
	print( ... )
	print( "" )
end

-----------------------------------------------------------------------------------------

-- _getSceneByIndex
-- private
-- return the index of the sceneName if it exists, nil otherwise.
lib._getSceneByIndex = function( sceneName )
	for i=1,#lib.loadedSceneModules do
		if lib.loadedSceneModules[i] == sceneName then
			return i
		end
	end
end

-----------------------------------------------------------------------------------------

-- _removeFromHistory
-- private
-- removes the scene name from the history table (loaded scenes table)
lib._removeFromHistory = function( sceneName )
	local index = lib._getSceneByIndex( sceneName )
	if index then
		table.remove( lib.loadedSceneModules, index )
	end
end

-----------------------------------------------------------------------------------------

-- _addToHistory
-- private
-- adds the scene name to the history table (loaded scenes table)
lib._addToSceneHistory = function( sceneName )
	lib._removeFromHistory( sceneName )
	lib.loadedSceneModules[#lib.loadedSceneModules+1] = sceneName
end

-----------------------------------------------------------------------------------------

-- _saveSceneAndHide
-- private
-- saves the current scene and hides it
lib._saveSceneAndHide = function( currentScene, newModule, noEffect )
	if not currentScene then return; end
    local screenshot
    if currentScene and currentScene.numChildren and currentScene.numChildren > 0 and not noEffect then
        --screenshot = display.capture( currentScene )
        screenshot = currentScene
    elseif noEffect and currentScene then
    	currentScene.isVisible = false
    end
	
	-- Since display.capture() only captures the group as far as content width/height,
	-- we must make calculations to account for groups that are both less than the total width/height
	-- of the screen, as well as groups that are offset have elements that are not on the screen:
	local bounds = currentScene.contentBounds
	local xMin, xMax = bounds.xMin, bounds.xMax
	local yMin, yMax = bounds.yMin, bounds.yMax

	local objectsOutsideLeft = xMin < display.screenOriginX
	local objectsOutsideRight = xMax > displayW+(-display.screenOriginX)
	local objectsAboveTop = yMin < display.screenOriginY
	local objectsBelowBottom = yMax > displayH+(-display.screenOriginY)
	
	-- Calculate xMin and xMax
	if xMin < 0 then xMin = 0; end
	if xMax > displayW then
		xMax = displayW
	end
	
	-- Caluclate yMin and yMax
	if yMin < 0 then yMin = 0; end
	if yMax > displayH then
		yMax = displayH
	end

	-- Calculate actual width/height of screen capture
	local width = xMax - xMin
	local height = yMax - yMin
	
	-- loop through current scene and remove potential Runtime table listeners
	for i=currentScene.numChildren,1,-1 do
		if currentScene[i].enterFrame then Runtime:removeEventListener( "enterFrame", currentScene[i] ); end
	end
	
	-- dispatch current scene's exitScene event
	if lib._currentModule and lib.loadedScenes[lib._currentModule] then
		local event = {}
		event.name = "hide"
		event.phase = "will"
		lib.loadedScenes[lib._currentModule]:dispatchEvent( event )
	end
	
	-- set new currentModule
	lib._currentModule = newModule

	-- display screenshot of previous scene
    if screenshot then
        stage:insert( screenshot )
        return screenshot
    end
end

-----------------------------------------------------------------------------------------

-- _createTouchOverlay
-- private
-- creates the touch overlay

lib._createTouchOverlay = function()
	
	local overlayRect = display.newRect( 0, 0, displayW, displayH )
	if not isGraphicsV1 then
		overlayRect.anchorX = 0
		overlayRect.anchorY = 0
	end
	overlayRect:setFillColor( 0 )
	overlayRect.isVisible = false
	overlayRect.isHitTestable = true	-- allow touches when invisible
	overlayRect:addEventListener( "touch", function() return true end )
	overlayRect:addEventListener( "tap", function() return true end )
	
	return overlayRect
end

-----------------------------------------------------------------------------------------

-- purgeScene
-- public
-- removes the scene (display group) from memory

-- TODO: This is deprecated.
lib.purgeScene = function( sceneName )
	print( "WARNING: composer.purgeScene() is deprecated. This now calls through to composer.removeScene( true ) instead." )
	lib.removeScene( sceneName, true )
end

lib.removeScene = function( sceneName, shouldRecycle )
	-- Unload a scene and remove its display group
	-- NOTE: global reference in composer.scenes is removed, unless shouldRecycle is set to true
	
	local scene = lib.loadedScenes[sceneName]
	if scene and scene.view then
		local event = {}
		event.name = "destroy"
		scene:dispatchEvent( event )
				
		if scene.view then
			display.remove( scene.view )
			scene.view = nil
		end
	elseif lib.isDebug then
		if not scene then
			debug_print( sceneName .. "'s was not removed because it does not exist. Use composer.loadScene() or composer.gotoScene()." )
		elseif scene and not scene.view then
			debug_print( sceneName .. "'s view was not purged because it's view (display group) does not exist. This means it has already been purged or the view was never created." )
		end
	end
	
	if not shouldRecycle then
		-- remove module from scene history table
		lib._removeFromHistory( sceneName )
		-- remove global reference
		lib.loadedScenes[sceneName] = nil
		-- remove the package reference
		package.loaded[sceneName] = nil
	end
	
end

-----------------------------------------------------------------------------------------

-- purgeAll
-- public
-- purges all the loaded scenes

-- TODO: This is deprecated.
lib.purgeAll = function()
	print("WARNING: composer.purgeAll() is deprecated. This now calls through to composer.removeHidden( true ) instead." )
	lib.removeHidden( true )
end

-- TODO: This is deprecated.
lib.removeAll = function()
	print( "WARNING: composer.removeAll() is deprecated. This now calls through to composer.removeHidden( false ) instead." )
	lib.removeHidden( false )
end

lib.removeHidden = function( shouldRecycle )
	lib.hideOverlay()
	local purge_count = 0

	-- Purges all scenes (except for the one that is currently showing)
	for i=#lib.loadedSceneModules,1,-1 do
		local sceneToUnload = lib.loadedSceneModules[i]
		
		if sceneToUnload ~= lib._currentModule then
			purge_count = purge_count + 1
			lib.removeScene( sceneToUnload, shouldRecycle )
		end
	end

	if lib.isDebug then
		local msg = "A total of [" .. purge_count .. "] scene(s) have been removed."
		if purge_count == 0 then
			msg = "No scenes were removed."
		end
		debug_print( msg )
	end
	
end

-- TODO: This is deprecated.
lib.getPrevious = function()
	print("WARNING: composer.getPrevious() is deprecated. This now calls through to composer.getSceneName( \"previous\" ) instead.")
	return lib.getSceneName( "previous" )
end

-----------------------------------------------------------------------------------------

-- getSceneName()
-- public
-- returns the name (string) of the requested scene (current, previous or overlay), or nil if we have only one loaded scene / no overlay / current scene

lib.getSceneName = function( whichScene )
	local sceneName = nil
	if "current" == whichScene then
		sceneName = lib._currentModule
	elseif "previous" == whichScene then
		sceneName = lib._previousScene
	elseif "overlay" == whichScene then
		if lib._currentOverlayScene then
			sceneName = lib._currentOverlayScene.name
		else
			sceneName = nil
		end
	end
	return sceneName
end

-----------------------------------------------------------------------------------------

-- getScene
-- public
-- returns a reference to the specified sceneName

lib.getScene = function( sceneName )
	local scene
	if nil == sceneName then
		local currentSceneName = lib.getCurrentSceneName
		scene = lib.loadedScenes[ currentSceneName ]
	else
		
		scene = lib.loadedScenes[ sceneName ]
		if lib.isDebug and not scene then
			debug_print( "getScene: The specified scene, " .. sceneName .. ", does not exist." )
		end
	end
	
	return scene
end

-----------------------------------------------------------------------------------------

-- getCurrentSceneName
-- public
-- returns the current scene name as string

lib.getCurrentSceneName = function()
	print("WARNING: composer.getCurrentSceneName() is deprecated. This now calls through to composer.getSceneName( \"current\" ) instead.")
	return lib.getSceneName( "current" )
end

-----------------------------------------------------------------------------------------

-- newScene
-- factory method
-- creates a new scene

lib.newScene = function( sceneName )
	-- sceneName is optional if they don't want to use external module
	local s = composerScene:new()	-- TODO: Get real event listener class (we're cheating by using this)

	if sceneName and not lib.loadedScenes[sceneName] then
		lib.loadedScenes[sceneName] = s
	end
	
	if sceneName then
		-- replace all '.' with '/'
		local basename = string.gsub( sceneName, "%.", '/' )
		-- append file extension
		local filename = basename .. '.ccscene'
		s:setComposerSceneName( filename )
	end
	
	return s
end

-----------------------------------------------------------------------------------------

-- nextTransition
-- private
-- creates the transition for the next scene

lib._nextTransition = function( sceneGroup, fx, effectTime, touchOverlay, oldScreenshot, customParams )
	
	-- remove touch disabling overlay rectangle:
	local disableOverlay = function()
		lib._touchOverlay.isHitTestable = false	-- disable touches when invisible
		--display.remove( oldScreenshot ); oldScreenshot = nil
		if oldScreenshot then oldScreenshot.isVisible = false; end

		-- dispatch previous scene's didExitScene event
		local previous = lib.getSceneName( "previous" )
		if previous and lib.loadedScenes[previous] then
			local event = {}
			event.name = "hide"
			event.phase = "did"
			lib.loadedScenes[previous]:dispatchEvent( event )
		end

		-- dispatch scene's enterScene event
		if lib._currentModule and lib.loadedScenes[lib._currentModule] then
			lib._addToSceneHistory( lib._currentModule )
			local event = {}
			event.name = "show"
			event.phase = "did"
			event.params = customParams
			lib.loadedScenes[lib._currentModule]:dispatchEvent( event )

			if lib.recycleOnSceneChange then
				lib.removeHidden()
			end
		end
	end
	


	-- dispatch show event, phase will
	if lib.loadedScenes[lib._currentModule] then
		local event = {}
		event.name = "show"
		event.phase = "will"
		event.params = customParams
		lib.loadedScenes[lib._currentModule]:dispatchEvent( event )
	end
	
	local options = {}
	options.x = fx.to.xEnd
	options.y = fx.to.yEnd
	options.alpha = fx.to.alphaEnd
	options.xScale = fx.to.xScaleEnd
	options.yScale = fx.to.yScaleEnd
	options.rotation =  fx.to.rotationEnd
	options.time = effectTime or 500
	options.transition = fx.to.transition
	options.onComplete = disableOverlay
	options.generatedBy = "composer"

	if oldScreenshot and fx.hideOnOut then
		oldScreenshot.isVisible = false
	end
	sceneGroup.isVisible = true -- unhide next scene
	local sceneTransition = transition.to( sceneGroup, options )
end

-----------------------------------------------------------------------------------------

-- composer.hideOverlay()
-- public
-- hides the overlay scene

lib.hideOverlay = function( purgeOnly, effect, effectTime, argOffset )

	local overlay = lib._currentOverlayScene
	lib._currentOverlayScene = nil
	
	if overlay then
		-- auto-correct if colon syntax was used instead of dot syntax
		if purgeOnly and purgeOnly == lib then
			purgeOnly = effect
			effect = effectTime
			effectTime = argOffset

			if lib.isDebug then
				debug_print( "WARNING: You should use dot-syntax when calling composer functions. For example, composer.hideOverlay() instead of composer:hideOverlay()." )
			end
		end

		-- correct arguments
		if purgeOnly and _type(purgeOnly) == "string" then
			if effect then
				effectTime = effect
			end
			effect = purgeOnly
			purgeOnly = nil
		end

		local function dispatchSceneEvents()
			-- remove the overlay when hiding is done
			display.remove( lib._modalRect ); lib._modalRect = nil

			-- dispatch "exitScene" event on overlay scene before purge/removal
			local event = {}
			event.name = "hide"
			event.phase = "did"
			event.sceneName = overlay.name
			
			-- if the overlay has a parent scene, add event.parent to the dispatched event
			if lib._currentModule then
				local currentScene = lib.loadedScenes[ lib._currentModule ]
				event.parent = currentScene
			end
			
			overlay:dispatchEvent( event )

			-- check to see if overlay scene is also being used as a normal scene (in which case we won't remove; only purge)
			local sceneExistsAsNormal = lib._getSceneByIndex( overlay.name )
			if sceneExistsAsNormal then purgeOnly = true; end

			if purgeOnly then
				lib.removeScene( overlay.name, true )
			else
				lib.removeScene( overlay.name, false )
			end

			-- on current scene (not overlay), dispatch "hide" event with did phase
			--[[if lib._currentModule then
				local current = lib.loadedScenes[lib._currentModule]
				local event = {}
				event.name = "hide"
				event.phase = "did"
				event.sceneName = overlay.name
				current:dispatchEvent( event )
			end]]--
			
			overlay = nil
			lib._touchOverlay.isHitTestable = false -- ensure touches are enabled
		end

		local event = {}
		event.name = "hide"
		event.phase = "will"
		event.sceneName = overlay.name
		
		-- if the overlay has a parent scene, add event.parent to the dispatched event
		if lib._currentModule then
			local currentScene = lib.loadedScenes[ lib._currentModule ]
			event.parent = currentScene
		end
		
		overlay:dispatchEvent( event )

		if effect and effectList[effect] then
			local fx = effectList[effect].from

			local function overlayTransitionComplete()
				dispatchSceneEvents()
			end

			-- set scene up according to effect (start)
			overlay.view.x = fx.xStart or 0
			overlay.view.y = fx.yStart or 0
			overlay.view.alpha = fx.alphaStart or 1.0
			overlay.view.xScale = fx.xScaleStart or 1.0
			overlay.view.yScale = fx.yScaleStart or 1.0
			overlay.view.rotation = fx.rotationStart or 0

			-- set transition options table up according to effect (end)
			local o = {}
			o.x = fx.xEnd
			o.y = fx.yEnd
			o.alpha = fx.alphaEnd
			o.xScale = fx.xScaleEnd
			o.yScale = fx.yScaleEnd
			o.rotation = fx.rotationEnd
			o.time = effectTime
			o.transition = fx.transition
			o.onComplete = overlayTransitionComplete
			o.generatedBy = "composer"

			local fxTransition = transition.to( overlay.view, o ) 
		else
			dispatchSceneEvents()
		end
	end
end

-----------------------------------------------------------------------------------------

-- composer.showOverlay()
-- public
-- creates the overlay scene

function lib.showOverlay( sceneName, options, argOffset )

	-- first, hide any overlay that may currently be showing
	lib.hideOverlay()

	-- if the overlay does not exist, we create it
	if not lib._touchOverlay then
		lib._touchOverlay = lib._createTouchOverlay()	-- creates overlay that disables touches on entire device screen (during scene transition)
	else
		lib._touchOverlay.isHitTestable = true	-- allow touches when invisible
	end

	-- auto-correct if colon syntax is used instead of dot
	if sceneName == lib then
		if options and _type(options) == "string" then
			sceneName = options
			if argOffset then options = argOffset; end
		end
	end

	-- parse arguments
	local options = options or {}
	local effect = options.effect
	local fxTime = options.time or 500
	local params = options.params  -- optional table user can pass to scene
	local isModal = options.isModal -- disables touches to calling scene (non-overlay, active scene)

	-- check to see if scene has already been loaded
	local scene = lib.loadedScenes[sceneName]
	
	if scene then
		-- scene exists

		-- if view does not exist, create it and re-dispatch "create" event
		if not scene.view then
			scene.view = display.newGroup()
			local event = {}
			event.name = "create"
			event.params = params
			event.sceneName = sceneName
			lib.loadedScenes[sceneName]:dispatchEvent( event )
		end
	else
		lib.loadedScenes[sceneName] = require( sceneName )
		scene = lib.loadedScenes[sceneName]

		if _type(scene) == 'boolean' then
			error( "Attempting to load scene from invalid scene module (" .. sceneName .. ".lua). Did you forget to return the scene object at the end of the scene module? (e.g. 'return scene')" )
		end
		
		-- create the scene's view
		scene.view = scene.view or display.newGroup()
		local event = {}
		event.name = "create"
		event.params = params
		event.sceneName = sceneName
		
		local currentCcFile = scene:getComposerSceneName()
		if nil ~= currentCcFile and lib._sceneFileExists( currentCcFile ) then
			scene:load( currentCcFile )
		end
		
		lib.loadedScenes[sceneName]:dispatchEvent( event )
	end
	
	-- assign the scene name and the scene object to library variables
	lib._currentOverlayScene = scene
	lib._currentOverlayScene.name = sceneName

	-- dispatch show event, phase will
	local event = {}
	event.name = "show"
	event.phase = "will"
	event.params = params
	event.sceneName = sceneName
	
	-- if the overlay has a parent scene, add event.parent to the dispatched event
	if lib._currentModule then
		local currentScene = lib.loadedScenes[ lib._currentModule ]
		event.parent = currentScene
	end
	
	scene:dispatchEvent( event )

	local function dispatchSceneEvents()
		-- dispatch "enterScene" event
		local event = {}
		event.name = "show"
		event.phase = "did"
		event.params = params
		event.sceneName = sceneName
		
		-- if the overlay has a parent scene, add event.parent to the dispatched event
		if lib._currentModule then
			local currentScene = lib.loadedScenes[ lib._currentModule ]
			event.parent = currentScene
		end
		
		scene:dispatchEvent( event )

		-- dispatch "overlayBegan" event to current scene
		--[[if lib._currentModule then
			local current = lib.loadedScenes[lib._currentModule]
			local event = {}
			event.name = "show"
			event.phase = "did"
			event.sceneName = sceneName  -- name of overlay scene
			event.params = params
			event.sceneName = sceneName
			current:dispatchEvent( event )
		end]]--

		lib._touchOverlay.isHitTestable = false	-- re-enable touches
	end

	-- begin transition w/ or w/out effect
	if effect and effectList[effect] then
		local fx = effectList[effect].to
		lib._touchOverlay.isHitTestable = true	-- disable touches during transition

		local function overlayTransitionComplete()
			dispatchSceneEvents( event )
		end

		-- set scene up according to effect (start)
		scene.view.x = fx.xStart or 0
		scene.view.y = fx.yStart or 0
		scene.view.alpha = fx.alphaStart or 1.0
		scene.view.xScale = fx.xScaleStart or 1.0
		scene.view.yScale = fx.yScaleStart or 1.0
		scene.view.rotation = fx.rotationStart or 0
		scene.view.isVisible = true

		-- set transition options table up according to effect (end)
		local o = {}
		o.x = fx.xEnd
		o.y = fx.yEnd
		o.alpha = fx.alphaEnd
		o.xScale = fx.xScaleEnd
		o.yScale = fx.yScaleEnd
		o.rotation = fx.rotationEnd
		o.time = fxTime
		o.transition = fx.transition
		o.onComplete = overlayTransitionComplete
		o.generatedBy = "composer"

		local fxTransition = transition.to( scene.view, o )
	else
		-- instant transition (no effect)
		lib._touchOverlay.isHitTestable = false
		scene.isVisible = true
		scene.view.x, scene.view.y = 0, 0

		dispatchSceneEvents()
	end

	if isModal then
		lib._modalRect = display.newRect( 0, 0, display.actualContentWidth * 1.25, display.actualContentHeight * 1.25 )
		lib._modalRect.x = display.contentCenterX
		lib._modalRect.y = display.contentCenterY
		lib._modalRect.isVisible = false
		lib._modalRect.isHitTestable = true
		-- prevent touches 
		lib._modalRect.touch = function() return true; end
		lib._modalRect.tap = function() return true; end
		lib._modalRect:addEventListener( "touch", function() return true end )
		lib._modalRect:addEventListener( "tap", function() return true end )
		stage:insert( lib._modalRect )
	end

	stage:insert( scene.view )	-- ensure the overlay scene is above current scene
end

-----------------------------------------------------------------------------------------

--
--
-- composer.loadScene()
-- Same as composer.gotoScene(), but no transition is initiated.
--
--

function lib.loadScene( sceneName, doNotLoadView, params )
	-- SYNTAX: composer.loadScene( sceneName [, doNotLoadView, params ] )	-- params is optional table w/ custom data

	-- check for dot syntax (to prevent errors)
	if sceneName == lib then
		error( "You must use a dot (instead of a colon) when calling composer.loadScene()" )
	end

	-- check to see if scene has already been loaded
	local scene = lib.loadedScenes[sceneName]

	if doNotLoadView ~= nil and _type(doNotLoadView) ~= "boolean" then
		params = doNotLoadView
	end
	
	if scene then
		-- scene exists

		-- if view does not exist, create it and re-dispatch "create" event
		if not scene.view and not doNotLoadView then
			scene.view = display.newGroup()
			local event = {}
			event.name = "create"
			event.params = params
			lib.loadedScenes[sceneName]:dispatchEvent( event )
			lib._addToSceneHistory( sceneName )
		end
	else
		lib.loadedScenes[sceneName] = require( sceneName )
		scene = lib.loadedScenes[sceneName]
		
		-- scene's view will be created (default), unless user explicity
		-- tells it not to by setting doNotLoadView to true
		if not doNotLoadView then
			scene.view = scene.view or display.newGroup()
			local event = {}
			event.name = "create"
			event.params = params
			lib.loadedScenes[sceneName]:dispatchEvent( event )
			lib._addToSceneHistory( sceneName )
		end
	end

	if not doNotLoadView then
		scene.view.isVisible = false	-- ensure the view is invisible
		stage:insert( 1, scene.view )	-- insert this scene's view 'behind' the currently loaded scene
	end

	return scene
end

-----------------------------------------------------------------------------------------

function lib.gotoScene( ... )
	-- OLD SYNTAX: composer.gotoScene( sceneName [, effect, effectTime] )
	--
	-- NEW SYNTAX:
	--
	-- local options = {
	--     effect = "slideLeft"
	--     time = 800,
	--     params = { any="vars", can="go", here=true }	-- optional params table to pass to scene event
	-- }
	-- composer.gotoScene( sceneName, options )
	--
	-- NOTE: params table will only be visible in the following events: "createScene", "willEnterScene" and "enterScene"
    --

   	lib.hideOverlay()	-- hide any overlay that may be currently showing
	
	-- parse arguments
	local arg = {...}
	local argOffset = 0

	-- if user uses colon syntax (composer:gotoScene()), autocorrect to prevent errors
	if arg[1] and arg[1] == lib then
		argOffset = 1

		if lib.isDebug then
			debug_print( "WARNING: You should use dot-syntax when calling composer functions. For example, composer.gotoScene() instead of composer:gotoScene()." )
		end
	end
	
	if arg and _type(arg[1+argOffset]) == "boolean" then
		argOffset = argOffset + 1	-- showActivityIndicator parameter has been deprecated; users should control this on their own
	end
	local newScene = arg[1+argOffset]
	local options, params, effect, effectTime

	if _type(arg[2+argOffset]) == "table" then
		options = arg[2+argOffset]
		effect = options.effect
		effectTime = _tonumber(options.time)
		params = options.params		-- params is an optional table that users can pass to the next scene

	elseif arg[2+argOffset] then
		effect = arg[2+argOffset]
		effectTime = _tonumber(arg[3+argOffset])
	end
	
	-- If there is no effect defined make one happen anyway (un-noticable visually but gives roughly a 1ms delay so runtime listeners don't overlap)
	if not effect then
		effect = "crossFade"
		effectTime = 0
	end
	
	----- end parse args
	
	-- create a reference to current module
	if not lib._currentModule then
		lib._currentModule = newScene
		
	elseif lib._currentModule == newScene then
		-- if the scene is the same with the one we have on screen
	
		if not lib._currentModule then
			return
		end
		
		lib.hideOverlay()	-- hide any overlay/popup scenes that may be showing

		local scene = lib.getScene( lib._currentModule )
		
		if not scene then
			-- no scene exists, we create it
			local success, msg = pcall( function() lib.loadedScenes[newScene] = require( newScene ) end )
			if not success and msg then
				if lib.isDebug then
					debug_print( "Cannot transition to scene: " .. _toString(newScene) .. ". There is either an error in the scene module, or you are attempting to go to a scene that does not exist. If you called composer.removeScene() on a scene that is NOT represented by a module, the scene must be re-created before transitioning back to it." )
				end
				error( msg )
			end
			scene = lib.loadedScenes[newScene]
			if _type(scene) == 'boolean' then
				error( "Attempting to load scene from invalid scene module (" .. sceneName .. ".lua). Did you forget to return the scene object at the end of the scene module? (e.g. 'return scene')" )
			end
		end		
		
		if options and options.recreate == true then
			lib.removeScene(lib._currentModule, true)
		end

		local function next_render( callback )
			return timer.performWithDelay( 1, callback, 1 )
		end

		local function dispatch_enterScene()
			scene:dispatchEvent( { name="show", phase = "did", params = params } )
		end

		local function dispatch_willEnterScene()
			scene:dispatchEvent( { name="show", phase="will", params = params } )
			next_render( dispatch_enterScene )
		end

		local function dispatch_createScene()
			
			if not scene.view then
				scene.view = display.newGroup()
				scene:dispatchEvent( { name="create", params = params } )
				lib._currentScene = scene.view
				stage:insert( lib._currentScene )
			end
			next_render( dispatch_willEnterScene )
		end

		local function dispatch_didExitScene()
			scene:dispatchEvent( { name="hide", phase = "did" } )
			next_render( dispatch_createScene )
		end

		scene:dispatchEvent( { name="hide", phase = "will" } )

		next_render( dispatch_didExitScene )

		-- end if the scene is the same with the one we have on screen
		
		return
		
	elseif lib._currentModule then
		lib._previousScene = lib._currentModule
	end
	
	local fx = effectList[effect] or {}
	local noEffect = not effect
	local screenshot = lib._saveSceneAndHide( lib._currentScene, newScene, noEffect )	-- save screenshot, remove current scene, show scene capture
	if not lib._touchOverlay then
		lib._touchOverlay = lib._createTouchOverlay()	-- creates overlay that disables touches on entire device screen (during scene transition)
	else
		lib._touchOverlay.isHitTestable = true	-- allow touches when invisible
	end
	
	-- load the scene (first check if scene has already been loaded)
	local scene = lib.loadedScenes[newScene]
	
	-- Create the specified scene and view group if necessary. Then set the
	-- currentScene variable to specified scene (to be transitioned to)
	
	if scene then
		if not scene.view then
			-- if view does not exist, create it and re-dispatch "createScene" event
			scene.view = display.newGroup()
			
			local currentCcFile = scene:getComposerSceneName()
			if nil ~= currentCcFile and lib._sceneFileExists( currentCcFile ) then
				scene:load( currentCcFile )
			end
			local event = {}
			event.name = "create"
			event.params = params
			lib.loadedScenes[newScene]:dispatchEvent( event )
		end
		lib._currentScene = scene.view
	else
		local success, msg = pcall( function() lib.loadedScenes[newScene] = require( newScene ) end )
		if not success and msg then
			if lib.isDebug then
				debug_print( "Cannot transition to scene: " .. _toString(newScene) .. ". There is either an error in the scene module, or you are attempting to go to a scene that does not exist. If you called composer.removeScene() on a scene that is NOT represented by a module, the scene must be re-created before transitioning back to it." )
			end
			error( msg )
		end
		scene = lib.loadedScenes[newScene]
		if _type(scene) == 'boolean' then
			error( "Attempting to load scene from invalid scene module (" .. sceneName .. ".lua). Did you forget to return the scene object at the end of the scene module? (e.g. 'return scene')" )
		end
		scene.view = scene.view or display.newGroup()
		lib._currentScene = scene.view
		
		local event = {}
		event.name = "create"
		event.params = params

		local currentCcFile = scene:getComposerSceneName()
		if nil ~= currentCcFile and lib._sceneFileExists( currentCcFile ) then
			scene:load( currentCcFile )
		end
		lib.loadedScenes[newScene]:dispatchEvent( event )
	end
	
	-- Set initial values for scene that will be transitioned into (and other relevant elements, such as touchOverlay)
	if fx.sceneAbove then
		stage:insert( lib._currentScene )
	else
		stage:insert( 1, lib._currentScene )	-- ensure new scene is in composer's 'stage' display group
	end
	lib._touchOverlay:toFront()	-- make sure touch overlay is in front of newly loaded scene

	-- set starting properties for the next scene (currentScene)
    lib._currentScene.isVisible = false

    if fx.to then
    	lib._currentScene.x = fx.to.xStart or 0
    	lib._currentScene.y = fx.to.yStart or 0
    	lib._currentScene.alpha = fx.to.alphaStart or 1.0
    	lib._currentScene.xScale = fx.to.xScaleStart or 1.0
    	lib._currentScene.yScale = fx.to.yScaleStart or 1.0
    	lib._currentScene.rotation = fx.to.rotationStart or 0
    end
	
	-- onComplete listener for first transition (previous scene; screenshot)
	local transitionNewScene = function() 
		lib._nextTransition( lib._currentScene, fx, effectTime, lib._touchOverlay, screenshot, params )
	end
	
	-- transition the previous scene out (the screenshot):
	if effect then
		-- create transition options table (for the scene that's on the way out)
		local options = {}
		options.x = fx.from.xEnd
		options.y = fx.from.yEnd
		options.alpha = fx.from.alphaEnd
		options.xScale = fx.from.xScaleEnd
		options.yScale = fx.from.yScaleEnd
		options.rotation = fx.from.rotationEnd
		options.time = effectTime or 500
		options.transition = fx.from.transition
		options.onComplete = transitionNewScene
		options.delay = 1 -- Delay the transition from starting by 1ms to keep the old scenes transition and the new scenes transition in sync
		options.generatedBy = "composer"

		-- for effects where both scenes should transition concurrently, remove onComplete listener
		if fx.concurrent then options.onComplete = nil; end
		
		-- begin scene transitions
		if screenshot then
			if not fx.concurrent and options.onComplete then

				-- next scene should transition AFTER first scene (e.g. scene1 -> done. -> scene2)
				local sceneTransition = transition.to( screenshot, options )
			else
				-- first and next scene should transition at the same time (e.g. scene1 -> scene2 )

				local sceneTransition = transition.to( screenshot, options )
				transitionNewScene()
			end
		else
			-- no screenshot, meaning there was no previous scene (first scene; coming from main.lua, most likely)
			transitionNewScene()
		end
	else
		--if screenshot then display.remove( screenshot ); screenshot = nil; end   -- for screen capture logic
		lib._touchOverlay.isHitTestable = false
		lib._currentScene.isVisible = true
		lib._currentScene.x, lib._currentScene.y = 0, 0
		
		-- dispatch previous scene's didExitScene event
		local previous = lib.getPreviousSceneName()
		if previous and lib.loadedScenes[previous] then
			local event = {}
			event.name = "hide"
			event.phase = "did"
			lib.loadedScenes[previous]:dispatchEvent( event )
		end

		-- dispatch current scene's show / phase will and enterScene events
		if lib.loadedScenes[lib._currentModule] then
			local event = {}
			event.name = "show"
			event.phase = "will"
			event.params = params
			lib.loadedScenes[lib._currentModule]:dispatchEvent( event )

			lib._addToSceneHistory( lib._currentModule )
			local event = {}
			event.name = "show"
			event.phase = "did"
			event.params = params
			lib.loadedScenes[lib._currentModule]:dispatchEvent( event )
			

			if lib.recycleOnSceneChange then
				lib.removeHidden(lib.recycleOnSceneChange)
			end
		end
	end
end

-----------------------------------------------------------------------------------------

-- on low memory warning, automatically purge least recently used scene
local function purgeLruScene( event )	-- Lru = "least recently used"
	if lib.recycleOnLowMemory then
		local lruScene = lib.loadedSceneModules[1]
		
		-- ensure the "lruScene" is not the currently loaded scene
		-- also ensure that there are at least 2 scenes left (to prevent
		-- currently transitioning-out scene from being purged)
		if lruScene and lruScene ~= lib._currentModule and #lib.loadedSceneModules > 2 then
			if lib.isDebug then
				debug_print( "Auto-purging scene: " .. lruScene " due to low memory. If you want to disable auto-purging on low memory, set composer.recycleOnLowMemory to false." )
			end
			lib.removeScene( lruScene, true )
		end
	elseif lib.isDebug and not lib.recycleOnSceneChange then
		debug_print( "Low memory warning received (auto-purging is disabled). You should manually purge un-needed scenes at this time." )
	end
end

Runtime:addEventListener( "memoryWarning", purgeLruScene )

-- TODO: This is deprecated.
lib.printMemUsage = function()
	print("WARNING: composer.printMemUsage() has been removed.")
end

lib.setVariable = function( key, value )
	if nil ~= key and nil ~= value then
		lib.variables[ key ] = value
	end
end

lib.getVariable = function( key )
	if nil ~= key then
		return lib.variables[ key ]
	end
end

lib._sceneFileExists = function( fileName )

	local fileExists = false

	local path = system.pathForFile( fileName, system.ResourceDirectory )
	
	if path then
	
		local testHandler = io.open( path )
	
		if testHandler then
		   fileExists = true
		   testHandler:close()
		end
	
	end
	
	return fileExists
end

return lib