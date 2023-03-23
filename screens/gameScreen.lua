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

local widget = require( "widget" )
local particleDesigner = require( "libs.particleDesigner" )
local rng = require ( "libs.rng" )

local mainGroup, frontGroup, backGroup

local fontIngame = composer.getVariable( "fontIngame" )
local fontLogo = composer.getVariable( "fontLogo" )
local timeTransitionScene = composer.getVariable( "timeTransitionScene" )

local availableQuestionSets = composer.getVariable( "availableQuestionSets" )
local amountQuestionSingleGame = composer.getVariable( "amountQuestionSingleGame" )     --20
local amountQuestionSingleSet = composer.getVariable( "amountQuestionSingleSet" )   --5

local tableQuestions = {}
local tableTimers = {}
local tableSoundFiles = {}
local tableCheckpoints = {}

local questionData
local savedQuestionsAsked = {}

local yStartingPlacement = display.safeScreenOriginY

local numElementsTimer = 15
local intervalTimer = 1

local seedSelected
local questionSetSelected

local questionCurrent = 1 -- Keeps index of current question in total. Max value = amountQuestionSingleGame
local questionCurrentSet = 1
local questionIndex = 1 -- Keeps index of current question in a single set. Max value = amountQuestionSingleSet
local coinsEarned = 0
local multiplierScore = #availableQuestionSets

local isRevived = false
local isInteractionAvailable = false
local isSaveAvailable = false
local isSetCompletedBefore = false

local fontSizeQuestion = contentHeightSafe / 25

local random = math.random
local roundNumber = math.round


local function clearTableQuestions()
    for i = #tableQuestions, 1, -1 do
        for j = #tableQuestions[i].choices, 1, -1 do
            tableQuestions[i].choices[j] = {}
        end
        tableQuestions[i] = {}

        table.remove( tableQuestions, i )
    end

    questionIndex = 1
end

local function resetQuestionData(tableResetSelected)
    for i = #tableResetSelected.questions, 1, -1 do
        for j = #tableResetSelected.questions[i].choices, 1, -1 do
            tableResetSelected.questions[i].choices[j] = {}
        end
        tableResetSelected.questions[i] = {}

        table.remove( tableResetSelected.questions, i )
    end

    tableResetSelected.questions = {}
    tableResetSelected = {}
end

local function shuffleTable(tableUnshuffled)
    math.randomseed( os.time() )

    for i = #tableUnshuffled, 2, -1 do
        local rand = random(i)
        tableUnshuffled[i], tableUnshuffled[rand] = tableUnshuffled[rand], tableUnshuffled[i]
    end
end

local function stopGameTimer(targetGroup)
    transition.cancel( "gameTimer" )

    for i = #targetGroup.timerElements, 1, -1 do
        display.remove(targetGroup.timerElements[i])
        targetGroup.timerElements[i] = nil
    end

    targetGroup.timerElements = {}
end

local function cleanUp()
    -- No need to keep device always on outside of game screen. Going back to default
    system.setIdleTimer( true )

    Runtime:removeEventListener( "system", onSystemEvent )
    
    transition.cancel( )
    tableTimers = utils.cancelTimers(tableTimers)
end

local function playBackgroundMusic(fadeTime)
    audio.fadeOut( {channel = channelMusicBackground, time = fadeTime} )

    local timerAudio = timer.performWithDelay( fadeTime + 50, function ()
        streamMusicBackground = audio.loadStream("assets/music/questionsTheme.mp3")
        channelMusicBackground = audio.play(streamMusicBackground, {channel = channelMusicBackground, loops = -1})
        audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
     end, 1)
    table.insert( tableTimers, timerAudio )
end

-- Reset player's ingame progress. Used to get rid of saved states.
local function resetPlayerProgress()
    composer.setVariable( "savedRandomSeed", 0 )
    composer.setVariable( "savedQuestionSet", 1 )
    composer.setVariable( "savedQuestionsAsked", { } )
    composer.setVariable( "savedQuestionCurrent", 1 )
    composer.setVariable( "savedPlayerScore", 0 )
    composer.setVariable( "savedIsRevived", false )

    savePreferences()
end

-- Save player's ingame progress. This is used for 'Continue' option
local function savePlayerProgress()
    composer.setVariable( "savedRandomSeed", seedSelected )
    composer.setVariable( "savedQuestionSet", questionSetSelected )
    composer.setVariable( "savedQuestionsAsked", savedQuestionsAsked )
    composer.setVariable( "savedQuestionCurrent", questionCurrent )
    composer.setVariable( "savedPlayerScore", coinsEarned )
    composer.setVariable( "savedIsRevived", isRevived )

    savePreferences()
end

local function hideActiveCard(typeHide, activeGroup, passiveGroup, statusGame, scoreCurrent)
    local timeNeededHiding = 250

    if (typeHide == "endGame") then
        local targetScene = "screens.endScreen"

        if (statusGame == "successSetUnlocked" or statusGame == "successSetNA" or 
            statusGame == "successSetCompletedBefore" or statusGame == "successEndgame") then
            targetScene = "screens.successScreen"
        end

        resetPlayerProgress()

        local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, 
            params = {callSource = "gameScreen", scoreCurrent = scoreCurrent, questionCurrent = questionCurrent, 
            coinsEarned = coinsEarned, statusGame = statusGame}}
        composer.gotoScene( targetScene, optionsChangeScene )
    elseif (typeHide == "hideLoadingCard" or typeHide == "hideQuestionCard" or typeHide == "hideSpecialCard") then
        transition.to( activeGroup, {tag = "hideActiveCard", time = timeNeededHiding, x = -activeGroup.width * 2, rotation = -30, onComplete = function ()              
                playBackgroundMusic(500)

                local timerHide = timer.performWithDelay( 500, function () 
                        startGameTimer(passiveGroup)
                    end, 1 )
                table.insert( tableTimers, timerHide )


                if (#tableCheckpoints > 0) then
                    for i = #tableCheckpoints, 1, -1 do
                        tableCheckpoints[i] = {}
                        table.remove( tableCheckpoints, i )
                    end
                end

                utils.clearDisplayGroup(activeGroup)

                activeGroup:toBack( )
                activeGroup.x = 0
                activeGroup.rotation = 0
            end} )
    elseif (typeHide == "hideBeforeSpecialCard") then
        transition.to( activeGroup, {tag = "hideActiveCard", time = timeNeededHiding, x = -activeGroup.width * 2, rotation = -30, onComplete = function ()
                isInteractionAvailable = true   -- re-enable interaction

                audio.setVolume(0, {channel = channelMusicBackground})

                utils.clearDisplayGroup(activeGroup)

                activeGroup:toBack( )
                activeGroup.x = 0
                activeGroup.rotation = 0
            end} )
    end
end

local function endGame(statusGame)
    local activeGroup, passiveGroup

    if (frontGroup.numChildren > 0) then
        activeGroup, passiveGroup = frontGroup, backGroup
    else
        activeGroup, passiveGroup = backGroup, frontGroup
    end

    local gamesPlayed = composer.getVariable( "gamesPlayed" ) + 1
    composer.setVariable( "gamesPlayed", gamesPlayed )

    local scoreCurrent = coinsEarned

    if (statusGame == "success") then
        -- Delete current random seed to prevent player from locking down this successful session
        composer.setVariable( "lastRandomSeed", 0 )

        local runsCompleted = composer.getVariable( "runsCompleted" ) + 1
        composer.setVariable( "runsCompleted", runsCompleted )

        local completedQuestionSets = composer.getVariable( "completedQuestionSets" )

        local lockedQuestionSets = composer.getVariable( "lockedQuestionSets" )
        local selectedLockedSet

        if (#lockedQuestionSets > 0) then
            -- Add selected set to the completed sets if not previously completed else don't unlock new set
            if (not isSetCompletedBefore) then
                -- Add currently completed set to the completed question sets
                table.insert( completedQuestionSets, questionSetSelected )
                composer.setVariable( "completedQuestionSets", completedQuestionSets )

                selectedLockedSet = random(#lockedQuestionSets)

                table.insert( availableQuestionSets, lockedQuestionSets[selectedLockedSet] )
                table.remove( lockedQuestionSets, selectedLockedSet )

                composer.setVariable( "lockedQuestionSets", lockedQuestionSets )

                statusGame = "successSetUnlocked"
            else
                -- Set completed before, don't unlock new one
                statusGame = "successSetCompletedBefore"
            end
        else
            -- All sets unlocked. no locked sets left.
            if (#availableQuestionSets == #completedQuestionSets) then
                -- Condition: all sets completed
                -- No more sets available to show player
                statusGame = "successEndgame"
            else
                -- Condition: LAST(1) set remaining
                if (not isSetCompletedBefore) then
                    -- Condition: LAST(1) set completed
                    table.insert( completedQuestionSets, questionSetSelected )
                    composer.setVariable( "completedQuestionSets", completedQuestionSets )

                    -- No more sets available to show player
                    statusGame = "successSetNA"
                else
                    -- Condition: LAST(1) set NOT completed
                    -- Set completed before, don't unlock new one
                    statusGame = "successSetCompletedBefore"
                end
            end
        end
    else
        statusGame = "fail"

        -- Decrease current question to find 
        questionCurrent = questionCurrent - 1
    end

    savePreferences()

    hideActiveCard( "endGame", activeGroup, passiveGroup, statusGame, scoreCurrent )
end

-- Adjust game timer to prevent cheating
local function adjustGameTimer(timeElapsed)
    local timeElapsedMilliseconds = timeElapsed * 1000
    local targetGroup

    -- Check if the current card contains a game timer
    -- If no game timer is found, it's a break card. Don't need to do anything.
    if (backGroup.timerElements or frontGroup.timerElements) then
        if (backGroup.timerElements) then
            if (#backGroup.timerElements > 0) then
                targetGroup = backGroup
            end
        elseif (frontGroup.timerElements) then
            if (#frontGroup.timerElements > 0) then
                targetGroup = frontGroup
            end
        else
            targetGroup = nil       -- break, continue etc. cards
        end


        if (targetGroup) then
            local numElementsElapsed = math.floor(timeElapsedMilliseconds / intervalTimer)

            local timerElements = targetGroup.timerElements

            if (numElementsElapsed > #timerElements) then
                numElementsElapsed = #timerElements
            end
            
            -- Remove number of timer indicators from screen
            -- WARNING!
            -- Even if player takes more than available time away, they'll still have some time to answer
            for i = 1, numElementsElapsed - 1 do
                display.remove(timerElements[#timerElements])
                timerElements[#timerElements] = nil
            end
        end
    end
end

local function playCueVisual(targetGroup, intervalTimer)
    -- Even if sound effects and music are turned off, player will see this cue for time left
    transition.to( targetGroup.cueVisual, { alpha = 1, time = intervalTimer / 2, onComplete = function ()
        transition.to( targetGroup.cueVisual, { alpha = 0, time = intervalTimer / 2 } )
    end } )
end

local function playCueAudio()
    -- Set background music level lower so player can hear the audio cue
    -- Background music level will be lowered even when sound effects are muted so low music will be the cue
    local musicLevelLowered = audio.getVolume( { channel = channelMusicBackground } ) / 2
    audio.fade( { channel = channelMusicBackground, time = 500, volume = musicLevelLowered } )

    -- Channel 3 is used instead of 2 so sound fx won't mix and blend into each other
    -- Doing this, answer related sound fx can still be heard by the player as expected
    audio.setVolume( composer.getVariable("soundLevel"), {channel = 3} )
    audio.play( tableSoundFiles["warning"], { channel = 3 } )
end

-- Start and handle game timer related actions (recursive)
function startGameTimer(targetGroup)
    local timerElements = targetGroup.timerElements

    isInteractionAvailable = true

    transition.to( timerElements[#timerElements], {tag = "gameTimer", time = intervalTimer, alpha = 0, onComplete = function ()
            display.remove( timerElements[#timerElements] )
            timerElements[#timerElements] = nil

            if (#timerElements > 0) then
                -- Play audio cue for little time left
                if (#timerElements <= numElementsTimer / 3) then
                    playCueVisual(targetGroup, intervalTimer)
                    playCueAudio()
                end

                startGameTimer(targetGroup)
            else
                -- When player is out of time, show the answer
                isInteractionAvailable = false
                showAnswer(targetGroup)
            end
        end} )
end

-- Create display elements for a single(1) question
local function createFrameQuestion(targetGroup)
    targetGroup.frameQuestion = display.newRoundedRect( display.contentCenterX, 0, contentWidthSafe / 1.1, 0, 10 )
    targetGroup.frameQuestion:setFillColor( unpack(themeData.colorBackground) )
    targetGroup:insert(targetGroup.frameQuestion)

    -- Question text will be loaded into this object
    local optionsTextQuestion = { text = tableQuestions[questionIndex].textQuestion, 
        width = targetGroup.frameQuestion.width, height = 0, align = "center", font = fontIngame, fontSize = fontSizeQuestion }
    targetGroup.frameQuestion.textLabel = display.newText( optionsTextQuestion )
    targetGroup.frameQuestion.textLabel:setFillColor( unpack(themeData.colorTextDefault) )
    targetGroup.frameQuestion.textLabel.x = targetGroup.frameQuestion.x
    targetGroup:insert(targetGroup.frameQuestion.textLabel)


    local spaceLeftQuestion = (targetGroup.timerElements[1].y - targetGroup.timerElements[1].height / 2) - yStartingPlacement

    targetGroup.frameQuestion.height = targetGroup.frameQuestion.textLabel.height * 1.1
    targetGroup.frameQuestion.y = yStartingPlacement + spaceLeftQuestion / 2
    targetGroup.frameQuestion.textLabel.y = targetGroup.frameQuestion.y
end

-- Display objects for the game timer(time left for player to answer the question)
local function createGameTimer(targetGroup)
    targetGroup.timerElements = {}

    -- Calculate time needed(in miliseconds) for a single timer object to disappear
    -- This allows us to experiment with different time remaining values for different difficulties
    intervalTimer = (tableQuestions[questionIndex].timeRemaining / numElementsTimer) * 1000

    local widthElementTimer = contentWidthSafe / 30
    local heightElementTimer = contentHeightSafe / 50
    local distanceTimerElements = (contentWidthSafe / 1.1 - widthElementTimer * numElementsTimer) / (numElementsTimer + 1)
    local marginFirstElement = (contentWidthSafe - contentWidthSafe / 1.1) / 2

    for i = 1, numElementsTimer do
        local elementTimer = display.newRoundedRect( 0, 0, widthElementTimer, heightElementTimer, 5 )
        
        if (i <= numElementsTimer / 3) then
            elementTimer:setFillColor( unpack(themeData.colorTimeLeftLow) )
        elseif (i <= (numElementsTimer * 2) / 3) then
            elementTimer:setFillColor( unpack(themeData.colorTimeLeftMedium) )
        elseif (i <= numElementsTimer) then
            elementTimer:setFillColor( unpack(themeData.colorTimeLeftHigh) )
        end
        

        if (i == 1) then
            elementTimer.x = marginFirstElement + distanceTimerElements + elementTimer.width / 2
        else
            elementTimer.x = distanceTimerElements + targetGroup.timerElements[i - 1].x + targetGroup.timerElements[i - 1].width
        end
        elementTimer.y = targetGroup.choices[#targetGroup.choices].y - targetGroup.choices[#targetGroup.choices].height / 2 - elementTimer.height * 2

        table.insert( targetGroup.timerElements, elementTimer )
        targetGroup:insert(elementTimer)
    end
end

-- Create choices(answers) for the question
local function createFramesChoices(targetGroup)
    targetGroup.choices = {}

    local widthFrameChoice = contentWidthSafe / 1.1
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local choicesPossible = {1, 2, 3, 4}
    local fontSizeChoices = fontSizeQuestion / 1.1

    local numChoices = tableQuestions[questionIndex].numChoices
    for i = 1, numChoices do
        local frameChoice = display.newRoundedRect( display.contentCenterX, 0, widthFrameChoice, 0, cornerRadiusButtons )
        frameChoice.id = "choice"
        frameChoice.isSelected = false
        frameChoice.isAnswer = false
        frameChoice.isActive = true
        frameChoice:setFillColor( unpack(themeData.colorButtonFillDefault) )
        frameChoice.strokeWidth = 5
        frameChoice:setStrokeColor( unpack(themeData.colorButtonStroke) )
        targetGroup:insert(frameChoice)
        frameChoice:addEventListener( "touch", handleGameTouch )

        -- Make sure true choice(answer) is added to table
        -- Then, add random selection from the remaining choices
        -- This is to get different choices, even when the question is same
        -- Useful when number of choices for that question(numChoices) is 2 or 3
        local randomIndex, choiceIndex
        if (tableQuestions[questionIndex].choices[i].isAnswer) then
            frameChoice.isAnswer = true
            choiceIndex = choicesPossible[1]
            table.remove(choicesPossible, 1)
        else
            randomIndex = random(#choicesPossible)
            choiceIndex = choicesPossible[randomIndex]
            table.remove(choicesPossible, randomIndex)
        end

        local optionsTextChoice = { text = tableQuestions[questionIndex].choices[choiceIndex].textChoice, 
            width = widthFrameChoice, height = 0, align = "center", font = fontIngame, fontSize = fontSizeChoices }
        frameChoice.textLabel = display.newText( optionsTextChoice )
        frameChoice.textLabel:setFillColor( unpack(themeData.colorTextDefault) )
        frameChoice.textLabel.x = frameChoice.x
        targetGroup:insert(frameChoice.textLabel)

        table.insert( targetGroup.choices, frameChoice )
    end

    -- Shuffle choices so they don't appear at the same order every time
    shuffleTable(targetGroup.choices)

    -- Create rectangular frames to surround every single choice
    for i = 1, #targetGroup.choices do
        frameChoice = targetGroup.choices[i]

        local distanceChoices = frameChoice.height / 3
        if (numChoices == 2) then
            frameChoice.height = contentHeightSafe / 8
            distanceChoices = frameChoice.height / 3
            if (i == 1) then
                frameChoice.y = contentHeightSafe - frameChoice.height * 1.2
            else
                frameChoice.y = targetGroup.choices[i - 1].y - targetGroup.choices[i - 1].height - distanceChoices
            end
        else
            if (numChoices == 3) then
                frameChoice.height = contentHeightSafe / 9
                distanceChoices = frameChoice.height / 3
            elseif (numChoices == 4) then
                frameChoice.height = contentHeightSafe / 11
                distanceChoices = frameChoice.height / 3
            end

            if (i == 1) then
                frameChoice.y = contentHeightSafe - distanceChoices - frameChoice.height / 2
            else
                frameChoice.y = targetGroup.choices[i - 1].y - targetGroup.choices[i - 1].height - distanceChoices
            end
        end
        frameChoice.textLabel.y = frameChoice.y
    end
end

-- Create dialog box that asks player 'Are you sure?'
local function createQuitConfirmationMenu(targetGroup)
    local fontSizeConfirmation = contentHeightSafe / 30

    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillOver = themeData.colorButtonFillOver
    local colorButtonDefault = themeData.colorButtonDefault
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local colorButtonStroke = themeData.colorButtonStroke

    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local strokeWidthButtons = themeData.strokeWidthButtons


    targetGroup.backgroundQuit = display.newRect( targetGroup, display.contentCenterX, 0, contentWidth, contentHeight - yStartingPlacement )
    targetGroup.backgroundQuit.anchorY = 0
    targetGroup.backgroundQuit:setFillColor( unpack(themeData.colorBackground) )
    targetGroup.backgroundQuit:addEventListener( "touch", function () return true end )


    local optionsQuestionQuitLabel = { text = sozluk.getString("quitAsk"), 
        width = targetGroup.backgroundQuit.width / 1.1, height = 0, align = "center", font = fontLogo, fontSize = fontSizeConfirmation }
    targetGroup.questionQuitLabel = display.newText( optionsQuestionQuitLabel )
    targetGroup.questionQuitLabel:setFillColor( unpack(colorTextDefault) )
    targetGroup.questionQuitLabel.x = targetGroup.backgroundQuit.x
    targetGroup:insert(targetGroup.questionQuitLabel)


    local widthQuitButtons = targetGroup.questionQuitLabel.width / 1.1
    local heightQuitButtons = contentHeightSafe / 10
    local distanceChoices = heightQuitButtons / 3
    local fontSizeChoices = fontSizeConfirmation / 1.1

    local optionsButtonQuitAccept = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthQuitButtons,
        height = heightQuitButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("quitAccept"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "quitAccept",
        onEvent = handleUITouch,
    }
    targetGroup.buttonQuitAccept = widget.newButton( optionsButtonQuitAccept )
    targetGroup.buttonQuitAccept.x = display.contentCenterX
    targetGroup:insert( targetGroup.buttonQuitAccept )

    local optionsButtonQuitDecline = 
    {
        shape = "roundedRect",
        fillColor = { default = colorButtonFillDefault, over = colorButtonFillOver },
        width = widthQuitButtons,
        height = heightQuitButtons,
        cornerRadius = cornerRadiusButtons,
        label = sozluk.getString("quitDecline"),
        labelColor = { default = colorTextDefault, over = colorButtonFillDefault },
        font = fontLogo,
        fontSize = fontSizeChoices,
        strokeColor = { default = colorButtonStroke, over = colorButtonDefault },
        strokeWidth = strokeWidthButtons * 3,
        id = "quitDecline",
        onEvent = handleUITouch,
    }
    targetGroup.buttonQuitDecline = widget.newButton( optionsButtonQuitDecline )
    targetGroup.buttonQuitDecline.x = display.contentCenterX
    targetGroup:insert( targetGroup.buttonQuitDecline )


    targetGroup.backgroundQuit.y = yStartingPlacement
    targetGroup.questionQuitLabel.y = display.contentCenterY - targetGroup.questionQuitLabel.height / 1.5

    targetGroup.buttonQuitAccept.y = (targetGroup.questionQuitLabel.y + targetGroup.questionQuitLabel.height / 2) + targetGroup.buttonQuitAccept.height + distanceChoices
    targetGroup.buttonQuitDecline.y = targetGroup.buttonQuitAccept.y + heightQuitButtons + distanceChoices

    targetGroup.backgroundQuit.alpha = 0
    targetGroup.questionQuitLabel.alpha = 0
    targetGroup.buttonQuitAccept.alpha = 0
    targetGroup.buttonQuitDecline.alpha = 0
end

-- Create settings menu that opens up when player clicks gear(settings) icon
local function createSettingsMenu(targetGroup)
    local xDistanceSides = contentWidthSafe / 10
    local widthButtonSettings = contentWidthSafe / 10
    local heightButtonSettings = widthButtonSettings
    
    yStartingPlacement = targetGroup.menuSeparator.y + targetGroup.menuSeparator.height / 2

    targetGroup.backgroundSettings = display.newRect( targetGroup, display.contentCenterX, 0, 1, 1 )
    targetGroup.backgroundSettings.anchorY = 0
    targetGroup.backgroundSettings:setFillColor( unpack(themeData.colorBackground) )

    targetGroup.imageSound = display.newImageRect( targetGroup, "assets/menu/sound.png", widthButtonSettings, heightButtonSettings )
    targetGroup.imageSound.id = "muteSound"
    targetGroup.imageSound:setFillColor( unpack(themeData.colorButtonDefault) )
    targetGroup.imageSound.anchorX = 0
    targetGroup.imageSound.x = xDistanceSides
    targetGroup.imageSound.y = yStartingPlacement + targetGroup.imageSound.height * 1.2
    targetGroup.imageSound:addEventListener( "touch", handleUITouch )

    targetGroup.imageMusic = display.newImageRect( targetGroup, "assets/menu/music.png", widthButtonSettings, heightButtonSettings )
    targetGroup.imageMusic.id = "muteMusic"
    targetGroup.imageMusic:setFillColor( unpack(themeData.colorButtonDefault) )
    targetGroup.imageMusic.anchorX = 0
    targetGroup.imageMusic.x = xDistanceSides
    targetGroup.imageMusic.y = targetGroup.imageSound.y + targetGroup.imageSound.height / 2 + targetGroup.imageMusic.height * 1.2
    targetGroup.imageMusic:addEventListener( "touch", handleUITouch )

    
    local widthLineSound = contentWidthSafe - xDistanceSides * 2 - targetGroup.imageSound.width * 1.5
    local heightLineSound = targetGroup.imageSound.height / 12
    local xLineSound = targetGroup.imageSound.x + targetGroup.imageSound.width * 1.5
    local yLineSound = targetGroup.imageSound.y

    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong

    targetGroup.imageSound.buttonControl = display.newCircle( targetGroup, xLineSound + widthLineSound / 2, yLineSound, targetGroup.imageSound.height / 4 )
    targetGroup.imageSound.buttonControl:setStrokeColor( unpack(themeData.colorButtonStroke) )
    targetGroup.imageSound.buttonControl.strokeWidth = 10
    targetGroup.imageSound.buttonControl:setFillColor( unpack(colorButtonFillWrong) )
    targetGroup.imageSound.buttonControl.id = "controlSound"
    targetGroup.imageSound.buttonControl.levelCurrent = composer.getVariable("soundLevel")
    targetGroup.imageSound.buttonControl.levelBeforeMute = targetGroup.imageSound.buttonControl.levelCurrent -- Used to keep last sound level before mute is pressed
    targetGroup.imageSound.buttonControl:addEventListener( "touch", handleUITouch )

    targetGroup.imageSound.buttonControl.line = display.newRect( targetGroup, 0, targetGroup.imageSound.buttonControl.y, 0, heightLineSound )
    targetGroup.imageSound.buttonControl.line:setFillColor( unpack(colorButtonDefault) )
    targetGroup.imageSound.buttonControl.line.anchorX = 0
    targetGroup.imageSound.buttonControl.line.x = xLineSound
    targetGroup.imageSound.buttonControl.line.width = widthLineSound


    local widthLineMusic = widthLineSound
    local heightLineMusic = heightLineSound
    local xLineMusic = xLineSound
    local yLineMusic = targetGroup.imageMusic.y

    targetGroup.imageMusic.buttonControl = display.newCircle( targetGroup, xLineMusic + widthLineMusic / 2, yLineMusic, targetGroup.imageMusic.height / 4 )
    targetGroup.imageMusic.buttonControl:setStrokeColor( unpack(themeData.colorButtonStroke) )
    targetGroup.imageMusic.buttonControl.strokeWidth = 10
    targetGroup.imageMusic.buttonControl:setFillColor( unpack(colorButtonFillWrong) )
    targetGroup.imageMusic.buttonControl.id = "controlMusic"
    targetGroup.imageMusic.buttonControl.levelCurrent = composer.getVariable("musicLevel")
    targetGroup.imageMusic.buttonControl.levelBeforeMute = targetGroup.imageMusic.buttonControl.levelCurrent -- Used to keep last music level before mute is pressed
    targetGroup.imageMusic.buttonControl:addEventListener( "touch", handleUITouch )

    targetGroup.imageMusic.buttonControl.line = display.newRect( targetGroup, 0, targetGroup.imageMusic.y, 0, targetGroup.imageMusic.height / 12 )
    targetGroup.imageMusic.buttonControl.line:setFillColor( unpack(colorButtonDefault) )
    targetGroup.imageMusic.buttonControl.line.anchorX = 0
    targetGroup.imageMusic.buttonControl.line.x = xLineMusic
    targetGroup.imageMusic.buttonControl.line.width = widthLineMusic

    targetGroup.imageSound.buttonControl.x = targetGroup.imageSound.buttonControl.line.x + (targetGroup.imageSound.buttonControl.line.width * targetGroup.imageSound.buttonControl.levelCurrent)
    targetGroup.imageMusic.buttonControl.x = targetGroup.imageMusic.buttonControl.line.x + (targetGroup.imageMusic.buttonControl.line.width * targetGroup.imageMusic.buttonControl.levelCurrent)

    targetGroup.backgroundSettings.width = targetGroup.imageSound.buttonControl.line.x + targetGroup.imageSound.buttonControl.line.width * 1.1 - targetGroup.imageSound.x
    targetGroup.backgroundSettings.height = (targetGroup.imageMusic.y + targetGroup.imageMusic.height) - yStartingPlacement
    targetGroup.backgroundSettings.y = yStartingPlacement
 
    targetGroup.backgroundSettings.alpha = 0
    targetGroup.imageSound.alpha = 0
    targetGroup.imageMusic.alpha = 0
    targetGroup.imageSound.buttonControl.alpha = 0
    targetGroup.imageSound.buttonControl.line.alpha = 0
    targetGroup.imageMusic.buttonControl.alpha = 0
    targetGroup.imageMusic.buttonControl.line.alpha = 0
end

-- Create UI elements including visual cue
local function createUIElements(targetGroup)
    local colorBackground = themeData.colorBackground
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local colorTextDefault = themeData.colorTextDefault
    local cornerRadiusButtons = themeData.cornerRadiusButtons

    local background = display.newRect( targetGroup, display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(colorBackground) )
    background:addEventListener( "touch", function () return true end )

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
        id = "buttonBack",
        onEvent = handleUITouch,
    }
    targetGroup.buttonBack = widget.newButton( optionsButtonBack )
    targetGroup.buttonBack.isActivated = false
    targetGroup.buttonBack.x = targetGroup.buttonBack.width / 2
    targetGroup.buttonBack.y = display.safeScreenOriginY + targetGroup.buttonBack.height / 2
    targetGroup:insert( targetGroup.buttonBack )

    local optionsNumberQuestion = { text = questionCurrent .. "/" .. amountQuestionSingleGame, height = 0, 
         font = fontLogo, fontSize = contentHeightSafe / 30 }
    local numberQuestion = display.newText( optionsNumberQuestion )
    numberQuestion:setFillColor( unpack(colorTextDefault) )
    numberQuestion.y = targetGroup.buttonBack.y
    targetGroup:insert( numberQuestion )


    local imageCoin = display.newCircle( targetGroup, 0, numberQuestion.y, numberQuestion.height / 2 )
    imageCoin:setFillColor( unpack( colorButtonOver ) )
    imageCoin.x = display.contentCenterX + imageCoin.width
    imageCoin.y = numberQuestion.y

    imageCoin.symbolCurrency = display.newRect( targetGroup, imageCoin.x, imageCoin.y, imageCoin.width / 3, imageCoin.height / 3 )
    imageCoin.symbolCurrency:setFillColor( unpack( themeData.colorBackground ) )
    imageCoin.symbolCurrency.rotation = 45


    local currencyShort, currencyAbbreviation = commonMethods.formatCurrencyString(coinsEarned)
    local optionsNumCoins = { text = currencyShort .. currencyAbbreviation, font = fontLogo, fontSize = contentHeightSafe / 30 }
    targetGroup.textNumCoins = display.newText( optionsNumCoins )
    targetGroup.textNumCoins:setFillColor( unpack(colorTextDefault) )
    targetGroup.textNumCoins.x = imageCoin.x + imageCoin.width + targetGroup.textNumCoins.width / 2
    targetGroup.textNumCoins.y = numberQuestion.y
    targetGroup:insert(targetGroup.textNumCoins)


    local optionsButtonSettings = 
    {
        defaultFile = "assets/menu/settings.png",
        width = contentHeightSafe / 15,
        height = contentHeightSafe / 15,
        id = "settings",
        onEvent = handleUITouch,
    }
    targetGroup.buttonSettings = widget.newButton( optionsButtonSettings )
    targetGroup.buttonSettings:setFillColor( unpack(colorButtonDefault) )
    targetGroup.buttonSettings.isActivated = false
    targetGroup.buttonSettings.x, targetGroup.buttonSettings.y = contentWidthSafe - targetGroup.buttonBack.width / 2, targetGroup.buttonBack.y
    targetGroup:insert(targetGroup.buttonSettings)

    targetGroup.menuSeparator = display.newRect( targetGroup, background.x, 0, background.width, 10 )
    targetGroup.menuSeparator.y = targetGroup.buttonBack.y + targetGroup.buttonBack.height / 2
    targetGroup.menuSeparator:setFillColor( unpack(colorButtonOver) )


    local widthUIElements = numberQuestion.width + ((targetGroup.textNumCoins.x + targetGroup.textNumCoins.width / 2) - (imageCoin.x - imageCoin.width / 2))
    local widthAvailable = (targetGroup.buttonSettings.x - targetGroup.buttonSettings.width / 2) - (targetGroup.buttonBack.x + targetGroup.buttonBack.width / 2)
    local distanceButtons = (widthAvailable - widthUIElements) / 3

    numberQuestion.x = distanceButtons + targetGroup.buttonBack.x + targetGroup.buttonBack.width / 2 + numberQuestion.width / 2
    imageCoin.x = distanceButtons + numberQuestion.x + numberQuestion.width / 2 + imageCoin.width / 2
    imageCoin.symbolCurrency.x = imageCoin.x
    targetGroup.textNumCoins.x = imageCoin.x + imageCoin.width + targetGroup.textNumCoins.width / 2
    targetGroup.textNumCoins.xImageCoin = imageCoin.x
    targetGroup.textNumCoins.yImageCoin = imageCoin.y


    local colorVisualCue = themeData.colorVisualCue
    local strokeWidthVisualCue = themeData.strokeWidthVisualCue

    if (composer.getVariable("fullScreen") and contentWidth > contentWidthSafe) then
        targetGroup.cueVisual = display.newRoundedRect( targetGroup, display.contentCenterX, display.contentCenterY, contentWidth - strokeWidthVisualCue, contentHeight - strokeWidthVisualCue, cornerRadiusButtons )
    else
        targetGroup.cueVisual = display.newRect( targetGroup, display.contentCenterX, display.contentCenterY, contentWidth - strokeWidthVisualCue, contentHeight - strokeWidthVisualCue )
    end
    targetGroup.cueVisual:setFillColor( unpack(colorVisualCue), 0 )
    targetGroup.cueVisual.alpha = 0
    targetGroup.cueVisual.strokeWidth = strokeWidthVisualCue
    targetGroup.cueVisual:setStrokeColor( unpack(colorVisualCue) )
end

-- Create every element that player sees on the screen
local function createGameArea(targetGroup)
    createUIElements(targetGroup)
    createSettingsMenu(targetGroup)
    createQuitConfirmationMenu(targetGroup)
    createFramesChoices(targetGroup)
    createGameTimer(targetGroup)
    createFrameQuestion(targetGroup)
end

-- Show player progress in this run (x / amountQuestionSingleGame)
local function createProgressMap(targetGroup, yPositionReference)
    local colorTextDefault = themeData.colorTextDefault

    local mapLine = display.newRect( targetGroup, display.contentCenterX, 0, contentWidthSafe / 1.2, 15 )
    mapLine:setFillColor( unpack(colorTextDefault) )
    mapLine.y = (yPositionReference - display.safeScreenOriginY) / 3


    -- Add +1 to take starting point into the mix
    local amountCheckpoints = (amountQuestionSingleGame / amountQuestionSingleSet) + 1
    local widthCheckpoint = 10
    local widthBetweenCheckpoints = mapLine.width / 4

    for i = 1, amountCheckpoints do
        local mapCheckpoint = display.newRect( targetGroup, 0, 0, widthCheckpoint, mapLine.height * 2 )
        mapCheckpoint:setFillColor( unpack(colorTextDefault) )
        if (i == 1) then
            mapCheckpoint.x = mapLine.x - mapLine.width / 2 + mapCheckpoint.width / 2
        else
            mapCheckpoint.x = tableCheckpoints[i - 1].x + widthBetweenCheckpoints
        end

        mapCheckpoint.y = mapLine.y

        table.insert(tableCheckpoints, mapCheckpoint) 
    end

    local widthMapPin = mapLine.height * 2.5

    local filePinMap = "assets/menu/pinMap.png"
    if (themeData.themeSelected == "light") then
        filePinMap = "assets/menu/pinMap-light.png"
    end
    local mapPin = display.newImageRect( targetGroup, filePinMap, widthMapPin, widthMapPin )

    local currentCheckpoint = 1
    -- (questionCurrent - 1) is used because the value is set for the next question
    if (questionCurrent - 1 > amountQuestionSingleSet) then
        currentCheckpoint = (questionCurrent - 1) / amountQuestionSingleSet
        mapPin.x = tableCheckpoints[currentCheckpoint].x
    else
        mapPin.x = mapLine.x - mapLine.width / 2 + widthCheckpoint / 2
    end
    mapPin.y = mapLine.y - mapLine.height / 2 - mapPin.height

    -- Take starting point into account, +1 is used for this
    mapPin.xTarget = tableCheckpoints[currentCheckpoint + 1].x

    -- Wait for the card to swipe and then start transition
    local timerPinTravel = timer.performWithDelay(1500, function ()
            transition.to( mapPin, { time = 1000, x = mapPin.xTarget } )
        end, 1)
    table.insert( tableTimers, timerPinTravel )
end

-- Create break card(campfire) or revival card
local function createSpecialCard(targetGroup, typeCard)
    local background = display.newRect( display.contentCenterX, display.contentCenterY, contentWidth, contentHeight )
    background:setFillColor( unpack(themeData.colorBackground) )
    background:addEventListener( "touch", function () return true end )
    targetGroup:insert( background )

    local widthMenuButtons = contentWidthSafe / 1.5
    local fontSizeButtons = contentHeightSafe / 30
    local colorButtonFillDefault = themeData.colorButtonFillDefault
    local colorButtonDefault = themeData.colorButtonDefault
    local colorButtonOver = themeData.colorButtonOver
    local cornerRadiusButtons = themeData.cornerRadiusButtons
    local colorTextDefault = themeData.colorTextDefault
    local colorTextOver = themeData.colorTextOver
    local strokeWidthButtons = themeData.strokeWidthButtons
    local colorButtonStroke = themeData.colorButtonStroke

    targetGroup.frameButtonContinue = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
    targetGroup.frameButtonContinue:setFillColor( unpack(colorButtonFillDefault) )
    targetGroup.frameButtonContinue.strokeWidth = strokeWidthButtons
    targetGroup.frameButtonContinue:setStrokeColor( unpack(colorButtonStroke) )
    targetGroup.frameButtonContinue.isActive = true
    targetGroup.frameButtonContinue:addEventListener( "touch", handleGameTouch )
    targetGroup:insert( targetGroup.frameButtonContinue )

    local optionsLabelContinue = { text = sozluk.getString("breakCardContinue"), 
        height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
    targetGroup.frameButtonContinue.textLabel = display.newText( optionsLabelContinue )
    targetGroup.frameButtonContinue.textLabel:setFillColor( unpack(colorTextDefault) )
    targetGroup.frameButtonContinue.textLabel.x = targetGroup.frameButtonContinue.x
    targetGroup:insert(targetGroup.frameButtonContinue.textLabel)

    targetGroup.frameButtonContinue.height = targetGroup.frameButtonContinue.textLabel.height * 2
    targetGroup.frameButtonContinue.y = contentHeightSafe - targetGroup.frameButtonContinue.height
    targetGroup.frameButtonContinue.textLabel.y = targetGroup.frameButtonContinue.y


    --local labelSpecial
    if (typeCard == "breakCard") then
        targetGroup.frameButtonContinue.id = "breakCardContinue"
        --labelSpecial = sozluk.getString("breakCardLabel")
    elseif (typeCard == "revivalCard") then
        targetGroup.frameButtonContinue.id = "revivalCardContinue"
        --labelSpecial = sozluk.getString("revivalCardLabel")
        targetGroup.frameButtonContinue.textLabel.text = sozluk.getString("revivalCardContinue")
    end

--[[
    -- This code piece can be used to add tips about the game in later builds

    local optionsBreakText = { text = labelSpecial, width = contentWidthSafe / 1.1, height = 0, 
        align = "center", font = fontIngame, fontSize = contentHeightSafe / 20 }
    targetGroup.textSpecial = display.newText( optionsBreakText )
    targetGroup.textSpecial:setFillColor( unpack(themeData.colorTextDefault) )
    targetGroup.textSpecial.x = display.contentCenterX
    targetGroup.textSpecial.y = display.contentCenterY - targetGroup.textSpecial.height
    targetGroup:insert( targetGroup.textSpecial )
]]

    if (typeCard == "breakCard") then
        targetGroup.frameButtonSaveExit = display.newRoundedRect( display.contentCenterX, 0, widthMenuButtons, 0, cornerRadiusButtons )
        targetGroup.frameButtonSaveExit:setFillColor( unpack(colorButtonFillDefault) )
        targetGroup.frameButtonSaveExit.id = "breakCardSaveExit"
        targetGroup.frameButtonSaveExit.strokeWidth = strokeWidthButtons
        targetGroup.frameButtonSaveExit:setStrokeColor( unpack(colorButtonStroke) )
        targetGroup.frameButtonSaveExit.isActive = true
        targetGroup.frameButtonSaveExit:addEventListener( "touch", handleGameTouch )
        targetGroup:insert( targetGroup.frameButtonSaveExit )

        local optionsLabelContinue = { text = sozluk.getString("breakCardSaveExit"), 
            height = 0, align = "center", font = fontLogo, fontSize = fontSizeButtons }
        targetGroup.frameButtonSaveExit.textLabel = display.newText( optionsLabelContinue )
        targetGroup.frameButtonSaveExit.textLabel:setFillColor( unpack(colorTextDefault) )
        targetGroup.frameButtonSaveExit.textLabel.x = targetGroup.frameButtonSaveExit.x
        targetGroup:insert(targetGroup.frameButtonSaveExit.textLabel)

        targetGroup.frameButtonSaveExit.height = targetGroup.frameButtonSaveExit.textLabel.height * 2
        targetGroup.frameButtonSaveExit.y = targetGroup.frameButtonContinue.y - targetGroup.frameButtonContinue.height / 2 - targetGroup.frameButtonSaveExit.height
        targetGroup.frameButtonSaveExit.textLabel.y = targetGroup.frameButtonSaveExit.y

        local woodFire = display.newRect( targetGroup, display.contentCenterX, 0, contentWidthSafe / 4, 15 )
        woodFire.rotation = 30
        woodFire.alpha = 1
        woodFire.y = targetGroup.frameButtonSaveExit.y - targetGroup.frameButtonSaveExit.height * 1.5 - woodFire.height * 2

        local woodFire2 = display.newRect( targetGroup, display.contentCenterX, 0, woodFire.width, woodFire.height )
        woodFire2.rotation = 150
        woodFire2.alpha = woodFire.alpha
        woodFire2.y = woodFire.y


        local fileParticleFX = "assets/particleFX/campfire.json"
        if (themeData.themeSelected == "light") then
            fileParticleFX = "assets/particleFX/campfire-light.json"
        end

        woodFire:setFillColor( .52, .37, .26 )
        woodFire2:setFillColor( .52, .37, .26 )

        targetGroup.emitterFX = particleDesigner.newEmitter( fileParticleFX )
        targetGroup.emitterFX.x, targetGroup.emitterFX.y = woodFire.x, woodFire.y + woodFire.height
        targetGroup:insert(targetGroup.emitterFX)

        -- Only for break card to not distract the player from getting the sense of luck from revival
        -- Revival needs to feel very important
        createProgressMap(targetGroup, targetGroup.frameButtonSaveExit.y - targetGroup.frameButtonSaveExit.height / 2)
    elseif (typeCard == "revivalCard") then
        targetGroup.frameButtonContinue.alpha = 0
        targetGroup.frameButtonContinue.textLabel.alpha = 0
        --targetGroup.textSpecial.alpha = 0

        --targetGroup.textSpecial.y = display.safeScreenOriginY + targetGroup.frameButtonContinue.height + targetGroup.textSpecial.height


        local fileParticleFX = "assets/particleFX/revival.json"
        if (themeData.themeSelected == "light") then
            fileParticleFX = "assets/particleFX/revival-light.json"
        end

        targetGroup.emitterFX = particleDesigner.newEmitter( fileParticleFX )
        targetGroup.emitterFX.x = display.contentCenterX
        targetGroup.emitterFX.y = display.contentCenterY - targetGroup.frameButtonContinue.height * 1.5
        targetGroup:insert(targetGroup.emitterFX)
    end
end

local function hideQuitConfirmationMenu(targetGroup)
    transition.to( targetGroup.backgroundQuit, {time = 250, alpha = 0} )
    transition.to( targetGroup.questionQuitLabel, {time = 250, alpha = 0} )
    transition.to( targetGroup.buttonQuitAccept, {time = 250, alpha = 0} )
    transition.to( targetGroup.buttonQuitDecline, {time = 250, alpha = 0} )

    targetGroup.buttonBack:setLabel( "<" )
    targetGroup.buttonBack.id = "buttonBack"
    targetGroup.buttonBack.isActivated = false
end

local function showQuitConfirmationMenu(targetGroup)
    targetGroup.backgroundQuit:toFront( )
    targetGroup.questionQuitLabel:toFront( )
    targetGroup.buttonQuitAccept:toFront( )
    targetGroup.buttonQuitDecline:toFront( )

    transition.to( targetGroup.backgroundQuit, {time = 250, alpha = 1} )
    transition.to( targetGroup.questionQuitLabel, {time = 250, alpha = 1} )
    transition.to( targetGroup.buttonQuitAccept, {time = 250, alpha = 1} )
    transition.to( targetGroup.buttonQuitDecline, {time = 250, alpha = 1} )

    targetGroup.buttonBack:setLabel( "x" )
    targetGroup.buttonBack.id = "quitDecline"
end

local function hideSettingsMenu(targetGroup, isSettingsButtonActivated)
    -- Save changes made by the player
    savePreferences()

    transition.to( targetGroup.backgroundSettings, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageSound, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageMusic, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageSound.buttonControl, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageSound.buttonControl.line, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageMusic.buttonControl, {time = 250, alpha = 0} )
    transition.to( targetGroup.imageMusic.buttonControl.line, {time = 250, alpha = 0} )

    targetGroup.buttonBack:setLabel( "<" )
    targetGroup.buttonBack.id = "buttonBack"
    targetGroup.buttonBack.isActivated = false

    if (isSettingsButtonActivated) then
        targetGroup.buttonSettings.isActivated = false
    end
end

local function showSettingsMenu(targetGroup)
    targetGroup.backgroundSettings:toFront( )
    targetGroup.imageSound:toFront( )
    targetGroup.imageMusic:toFront( )
    targetGroup.imageSound.buttonControl.line:toFront( )
    targetGroup.imageSound.buttonControl:toFront( )
    targetGroup.imageMusic.buttonControl.line:toFront( )
    targetGroup.imageMusic.buttonControl:toFront( )

    transition.to( targetGroup.backgroundSettings, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageSound, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageMusic, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageSound.buttonControl, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageSound.buttonControl.line, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageMusic.buttonControl, {time = 250, alpha = 1} )
    transition.to( targetGroup.imageMusic.buttonControl.line, {time = 250, alpha = 1} )

    targetGroup.buttonBack:setLabel( "x" )
    targetGroup.buttonBack.id = "closeSettings"
end

local function showContinueEndElements(targetGroup)
    transition.to( targetGroup.frameButtonContinue, {time = 250, alpha = 1} )
    transition.to( targetGroup.frameButtonContinue.textLabel, {time = 250, alpha = 1} )
    --transition.to( targetGroup.textSpecial, {time = 250, alpha = 1} )
end

-- Roll the dice to see if the player can be revived
local function decideContinueEnd()
    local timerEndGame = timer.performWithDelay(2000, function () 
            -- For revival, player should have at least answered a set of questions(amountQuestionSingleSet)
            -- Also, should NOT have been revived earlier in this run or NOT have locked the set
            if (questionCurrent > amountQuestionSingleSet and not isRevived) then
                --if (questionCurrent > 0 and not isRevived) then   -- test line
                local percentageRevival = composer.getVariable( "percentageRevival" )
                local chanceRevival = random(100)


                -- If player can be revived, create revival card in the background
                -- Else, game over.

                --percentageRevival = 100 -- test line
                if (chanceRevival <= percentageRevival) then
                    local activeGroup, passiveGroup

                    if (frontGroup.numChildren > 0) then
                        activeGroup, passiveGroup = frontGroup, backGroup
                    else
                        activeGroup, passiveGroup = backGroup, frontGroup
                    end

                    createSpecialCard(passiveGroup, "revivalCard")

                    local timerHide = timer.performWithDelay(1000, function () 
                            hideActiveCard("hideBeforeSpecialCard", activeGroup, passiveGroup)

                            audio.setVolume( composer.getVariable("soundLevel"), {channel = 3} )
                            audio.play( tableSoundFiles["revival"], {channel = 3, loops = -1} )
                            
                            local timerRequest = timer.performWithDelay(2000, function ()
                                    -- Player will see the effects first, revival text and button later
                                    -- This is to make this rare occassion feel different than other screens
                                    showContinueEndElements(passiveGroup)
                                end, 1)
                            table.insert( tableTimers, timerRequest )
                        end, 1)
                    table.insert( tableTimers, timerHide )
                else
                    endGame("fail")
                end
            else
                endGame("fail")
            end
        end, 1)
    table.insert( tableTimers, timerEndGame )
end

-- Save the questions player viewed so far in the current run
local function saveQuestionsAsked()
    -- Defensive. get the current table to avoid bugs
    savedQuestionsAsked = composer.getVariable( "savedQuestionsAsked" )

    for i = 1, #tableQuestions do
        -- Only adding question id should work
        table.insert( savedQuestionsAsked, tableQuestions[i].id )
    end

    composer.setVariable( "savedQuestionsAsked", savedQuestionsAsked )
    savePreferences()
end

-- Show true answer to the player for both cases(true or false choice)
function showAnswer(targetGroup, choiceSelected, textCoinAward)
    local colorButtonOver = themeData.colorButtonOver
    local colorButtonFillTrue = themeData.colorButtonFillTrue
    local colorButtonFillWrong = themeData.colorButtonFillWrong
    local colorTextTrue = themeData.colorTextTrue
    local colorTextWrong = themeData.colorTextWrong

    local choices = targetGroup.choices

    -- If player made a choice, see if it's true or false and act on it
    -- Else, highlight the correct answer
    if (choiceSelected) then
        for i = 1, #choices do
            if (choices[i].isSelected) then
                -- Check the selected choice to see the answer
                -- If selected choice is the answer - !) To next question, 2) Show campfire or 3) End game
                -- Else: 1) Decide if player will be revived or 2) Game over
                if (choices[i].isAnswer) then
                    -- Total number of questions answered is kept for statistics
                    local questionsAnsweredTotal = composer.getVariable( "questionsAnsweredTotal" ) + 1
                    composer.setVariable( "questionsAnsweredTotal", questionsAnsweredTotal )


                    audio.play( tableSoundFiles["answerRight"], {channel = 2} )


                    -- Calculate and add coins to total
                    textCoinAward:setFillColor( unpack(colorButtonFillTrue) )
                    coinsEarned = coinsEarned + tonumber( textCoinAward.text )

                    
                    local timeTransAward = 250
                    local xTargetCoinImage = targetGroup.textNumCoins.xImageCoin
                    local yTargetCoinImage = targetGroup.textNumCoins.yImageCoin

                    transition.to( textCoinAward, {time = timeTransAward, x = targetGroup.textNumCoins.x, y = targetGroup.textNumCoins.y, alpha = 0, onComplete = function ()
                            targetGroup.textNumCoins.text = coinsEarned + tonumber( textCoinAward.text )

                            local currencyShort, currencyAbbreviation = commonMethods.formatCurrencyString(coinsEarned)
                            targetGroup.textNumCoins.text = currencyShort .. currencyAbbreviation
                        end} )
                    transition.to( textCoinAward.imageCoin, {time = timeTransAward, x = xTargetCoinImage, y = yTargetCoinImage, alpha = 0} )
                    transition.to( textCoinAward.symbolCurrency, {time = timeTransAward, x = xTargetCoinImage, y = yTargetCoinImage, alpha = 0} )


                    choiceSelected:setFillColor( unpack(colorButtonFillTrue) )
                    choiceSelected.textLabel:setFillColor( unpack(colorTextTrue) )
                    choiceSelected:setStrokeColor( unpack(colorButtonFillTrue) )

                    questionCurrent = questionCurrent + 1
                    questionIndex = questionIndex + 1

                    -- If there are loaded questions(amountQuestionSingleSet) left, pick one more
                    -- Else, check for success(end of run) or show break card(campfire)
                    if (questionIndex <= #tableQuestions) then
                        local activeGroup, passiveGroup
                        if (frontGroup.numChildren > 0) then
                            activeGroup, passiveGroup = frontGroup, backGroup
                        else
                            activeGroup, passiveGroup = backGroup, frontGroup
                        end

                        createGameArea(passiveGroup)

                        local timerHide = timer.performWithDelay(1000, function () 
                                hideActiveCard("hideQuestionCard", activeGroup, passiveGroup ) 
                            end, 1)
                        table.insert( tableTimers, timerHide )
                    else
                        if (questionCurrent >= amountQuestionSingleGame) then
                            -- The case of successfully completing the game
                            local timerEndGame = timer.performWithDelay( 1500, function () 
                                    endGame("success")
                                end, 1 )
                            table.insert( tableTimers, timerEndGame )
                        else
                            -- No questions left for that set(amountQuestionSingleSet) but game is not over yet(amountQuestionSingleGame)
                            local activeGroup, passiveGroup

                            if (frontGroup.numChildren > 0) then
                                activeGroup, passiveGroup = frontGroup, backGroup
                            else
                                activeGroup, passiveGroup = backGroup, frontGroup
                            end

                            -- Load break card in the background. Will be visible after hideActiveCard
                            createSpecialCard(passiveGroup, "breakCard")

                            -- Save questions asked before clearing the table
                            -- Used for auto-save and 'save and exit' function
                            -- If player leaves the game for something else, game uses this save to continue
                            saveQuestionsAsked()
                            clearTableQuestions()

                            questionCurrentSet = questionCurrentSet + 1
                            initQuestions(amountQuestionSingleSet)

                            local timerHide = timer.performWithDelay(1000, function () 
                                    hideActiveCard("hideBeforeSpecialCard", activeGroup, passiveGroup)
                                    
                                    audio.setVolume( composer.getVariable("soundLevel"), {channel = 3} )
                                    audio.play( tableSoundFiles["campfire"], {channel = 3, loops = -1} )

                                    savePlayerProgress()
                                end, 1)
                            table.insert( tableTimers, timerHide )
                        end
                    end
                else
                    -- Chosen answer is wrong
                    -- Audio and visual feedback is provided to the player
                    -- There is also a chance of 'revival'
                    audio.play( tableSoundFiles["answerWrong"], {channel = 2} )


                    textCoinAward:setFillColor( unpack(colorButtonFillWrong) )

                    local timeTransAward = 1500

                    transition.to( textCoinAward, {time = timeTransAward, y = contentHeightSafe, alpha = 0} )
                    transition.to( textCoinAward.imageCoin, {time = timeTransAward, y = contentHeightSafe, alpha = 0} )
                    transition.to( textCoinAward.symbolCurrency, {time = timeTransAward, y = contentHeightSafe, alpha = 0} )


                    choiceSelected:setFillColor( unpack(colorButtonFillWrong) )
                    choiceSelected.textLabel:setFillColor( unpack(colorTextWrong) )
                    choiceSelected:setStrokeColor( unpack(colorButtonFillWrong) )

                    for i = 1, #choices do
                        if (choices[i].isAnswer) then
                            choices[i]:setFillColor( unpack(colorButtonFillTrue) )
                            choices[i].textLabel:setFillColor( unpack(colorTextTrue) )
                            choices[i]:setStrokeColor( unpack(colorButtonFillTrue) )
                        end
                    end

                    -- See if player can be revived
                    decideContinueEnd()
                end
            end
        end
    else
        -- If the player didn't choose any answer, highlight the correct choice
        if (frontGroup.numChildren > 0) then
            hideSettingsMenu(frontGroup)
            hideQuitConfirmationMenu(frontGroup)
        else
            hideSettingsMenu(backGroup)
            hideQuitConfirmationMenu(backGroup)
        end

        audio.play( tableSoundFiles["answerWrong"], {channel = 2} )

        for i = 1, #choices do
            if (choices[i].isAnswer) then
                choices[i]:setFillColor( unpack(colorButtonFillTrue) )
                choices[i].textLabel:setFillColor( unpack(colorTextTrue) )
                choices[i]:setStrokeColor( unpack(colorButtonFillTrue) )
            end
        end
        
        -- See if player can be revived
        decideContinueEnd()
    end
end

-- Handle in-game menu touches like settings related and quit buttons
function handleUITouch(event)
    if (event.phase == "began") then
        if (event.target.id == "controlSound" or "controlMusic" == event.target.id) then
            display.getCurrentStage( ):setFocus( event.target )

            event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
        elseif (event.target.id == "muteSound") then
            event.target.buttonControl.x = event.target.buttonControl.line.x

            -- Quick mute/unmute
            if (event.target.buttonControl.levelCurrent <= 0) then
                event.target.buttonControl.levelCurrent = event.target.buttonControl.levelBeforeMute
            else
                event.target.buttonControl.levelBeforeMute = event.target.buttonControl.levelCurrent
                event.target.buttonControl.levelCurrent = 0
            end

            event.target.buttonControl.x = event.target.buttonControl.line.x + (event.target.buttonControl.line.width * event.target.buttonControl.levelCurrent)

            for i = 2, audio.totalChannels do
                audio.setVolume( event.target.buttonControl.levelCurrent, {channel = i} )
            end

            composer.setVariable( "soundLevel", event.target.buttonControl.levelCurrent )
        elseif (event.target.id == "muteMusic") then
            event.target.buttonControl.x = event.target.buttonControl.line.x

            -- Quick mute/unmute
            if (event.target.buttonControl.levelCurrent <= 0) then
                event.target.buttonControl.levelCurrent = event.target.buttonControl.levelBeforeMute
            else
                event.target.buttonControl.levelBeforeMute = event.target.buttonControl.levelCurrent
                event.target.buttonControl.levelCurrent = 0
            end

            event.target.buttonControl.x = event.target.buttonControl.line.x + (event.target.buttonControl.line.width * event.target.buttonControl.levelCurrent)

            audio.setVolume( event.target.buttonControl.levelCurrent, {channel = channelMusicBackground} )

            composer.setVariable( "musicLevel", event.target.buttonControl.levelCurrent )
        end
    elseif (event.phase == "moved") then
        if (event.target.id == "controlSound" or "controlMusic" == event.target.id) then
            if (event.x >= event.target.line.x and event.x <= event.target.line.x + event.target.line.width) then
                event.target.x = event.x

                event.target.levelBeforeMute = event.target.levelCurrent
                event.target.levelCurrent = (event.target.x - event.target.line.x) / event.target.line.width

                if (event.target.levelCurrent < 0.05) then
                    event.target.levelCurrent = 0
                end
                

                if (event.target.id == "controlSound") then
                    -- Only channels 2 and 3 are actively used in this scene
                    -- We will set volume for other channels in "ended" phase
                    audio.setVolume( event.target.levelCurrent, {channel = 2} )
                    audio.setVolume( event.target.levelCurrent, {channel = 3} )

                    if (not audio.isChannelPlaying( 2 )) then
                        audio.play( tableSoundFiles["answerChosen"], {channel = 2} ) 
                    end
                elseif (event.target.id == "controlMusic") then
                    audio.setVolume( event.target.levelCurrent, {channel = channelMusicBackground} )
                end
            end
        end
    elseif (event.phase == "ended") then
        if (event.target.id == "buttonBack") then
            -- Show an "Are you sure?" dialog box when quit / back button is pressed
            if (not event.target.isActivated) then
                event.target.isActivated = true

                if (frontGroup.numChildren > 0) then
                    hideSettingsMenu(frontGroup)
                    showQuitConfirmationMenu(frontGroup)
                else
                    hideSettingsMenu(backGroup)
                    showQuitConfirmationMenu(backGroup)
                end
            else
                event.target.isActivated = false

                if (frontGroup.numChildren > 0) then
                    hideQuitConfirmationMenu(frontGroup)
                else
                    hideQuitConfirmationMenu(backGroup)
                end
            end
        elseif (event.target.id == "quitAccept") then
            resetPlayerProgress()

            local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "gameScreen"}}
            composer.gotoScene( "screens.menuScreen", optionsChangeScene )
        elseif (event.target.id == "quitDecline") then
            if (frontGroup.numChildren > 0) then
                hideQuitConfirmationMenu(frontGroup)
            else
                hideQuitConfirmationMenu(backGroup)
            end
        elseif (event.target.id == "settings") then
            if (not event.target.isActivated) then
                event.target.isActivated = true

                if (frontGroup.numChildren > 0) then
                    hideQuitConfirmationMenu(frontGroup)
                    showSettingsMenu(frontGroup)
                else
                    hideQuitConfirmationMenu(backGroup)
                    showSettingsMenu(backGroup)
                end
            else
                event.target.isActivated = false

                if (frontGroup.numChildren > 0) then
                    hideSettingsMenu(frontGroup)
                else
                    hideSettingsMenu(backGroup)
                end
            end
        elseif (event.target.id == "closeSettings") then
            event.target.isActivated = false

            if (frontGroup.numChildren > 0) then
                hideSettingsMenu(frontGroup, frontGroup.buttonSettings.isActivated)
            else
                hideSettingsMenu(backGroup, backGroup.buttonSettings.isActivated)
            end
        elseif (event.target.id == "controlMusic") then
            display.getCurrentStage( ):setFocus( nil )

            event.target:setFillColor( unpack(themeData.colorButtonFillWrong) )

            composer.setVariable( "musicLevel", event.target.levelCurrent )
        elseif (event.target.id == "controlSound") then
            display.getCurrentStage( ):setFocus( nil )

            for i = 2, audio.totalChannels do
                audio.setVolume( event.target.levelCurrent, {channel = i} )
            end

            event.target:setFillColor( unpack(themeData.colorButtonFillWrong) )

            composer.setVariable( "soundLevel", event.target.levelCurrent )
        end
    end
end

-- Handle touch events related to in-game stuff
function handleGameTouch(event)
    if (event.phase == "ended") then
        if (isInteractionAvailable) then
            if ((event.target.id == "breakCardContinue" or "revivalCardContinue" == event.target.id) and event.target.isActive) then
                -- Handle continue buttons on break(campfire) and revival cards

                event.target.isActive = false
                isInteractionAvailable = false

                local activeGroup, passiveGroup

                if (frontGroup.numChildren > 0) then
                    activeGroup, passiveGroup = frontGroup, backGroup
                else
                    activeGroup, passiveGroup = backGroup, frontGroup
                end

                -- Create next question card in the background before player goes on
                createGameArea(passiveGroup)

                activeGroup.emitterFX:stop()

                if (event.target.id == "revivalCardContinue") then
                    isRevived = true
                end

                -- I chose NOT to play audio feedback for buttons in special cards
                -- I wanted to give player a break from those choosing and approving sounds
                audio.fadeOut( { channel = 3, time = 1000 } )
                --audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(themeData.colorTextOver) )
                event.target:setStrokeColor( unpack(themeData.colorButtonOver) )


                local timerAnswer
                timerAnswer = timer.performWithDelay(1000, function () 
                        event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
                        event.target.textLabel:setFillColor( unpack(themeData.colorTextTrue) )
                        event.target:setStrokeColor( unpack(themeData.colorButtonFillTrue) )

                        --audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                        local timeWaitChoice = 1000
                        transition.to( activeGroup.emitterFX, { time = timeWaitChoice, alpha = 0 } )

                        local timerHide = timer.performWithDelay(1500, function () 
                                hideActiveCard("hideSpecialCard", activeGroup, passiveGroup )
                            end, 1)
                        table.insert( tableTimers, timerHide )
                    end, 1)
                table.insert( tableTimers, timerAnswer )
            elseif (event.target.id == "breakCardSaveExit") then
                -- Handle save and exit button
                -- Save player progress here so they can continue that session later

                event.target.isActive = false
                isInteractionAvailable = false

                local activeGroup, passiveGroup

                if (frontGroup.numChildren > 0) then
                    activeGroup, passiveGroup = frontGroup, backGroup
                else
                    activeGroup, passiveGroup = backGroup, frontGroup
                end

                activeGroup.emitterFX:stop()

                -- I chose to play audio feedback for this option because scene changes back to menu
                audio.fadeOut( { channel = 3, time = 1000 } )
                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(themeData.colorTextOver) )
                event.target:setStrokeColor( unpack(themeData.colorButtonOver) )

                savePlayerProgress()

                local timerAnswer
                timerAnswer = timer.performWithDelay(1000, function () 
                        event.target:setFillColor( unpack(themeData.colorButtonFillTrue) )
                        event.target.textLabel:setFillColor( unpack(themeData.colorTextTrue) )
                        event.target:setStrokeColor( unpack(themeData.colorButtonFillTrue) )

                        audio.play( tableSoundFiles["answerRight"], {channel = 2} )

                        local timeWaitChoice = 1000
                        transition.to( activeGroup.emitterFX, { time = timeWaitChoice, alpha = 0 } )

                        local timerChangeScene = timer.performWithDelay(1500, function () 
                                local optionsChangeScene = {effect = "tossLeft", time = timeTransitionScene, params = {callSource = "gameScreen"}}
                                composer.gotoScene( "screens.menuScreen", optionsChangeScene )
                            end, 1)
                        table.insert( tableTimers, timerChangeScene )
                    end, 1)
                table.insert( tableTimers, timerAnswer )
            elseif (event.target.id == "choice" and event.target.isActive) then
                -- Handle touches related to choices / answers

                isInteractionAvailable = false

                -- If player made a choice before closing the settings menu, close it before showing the answer
                if (frontGroup.numChildren > 0) then
                    hideSettingsMenu(frontGroup, frontGroup.buttonSettings.isActivated)
                else
                    hideSettingsMenu(backGroup, backGroup.buttonSettings.isActivated)
                end                


                -- Stop the music. Start building up the tension
                audio.fadeOut( {channel = channelMusicBackground, time = 500} )

                audio.play( tableSoundFiles["answerChosen"], {channel = 2} )

                event.target:setFillColor( unpack(themeData.colorButtonOver) )
                event.target.textLabel:setFillColor( unpack(themeData.colorTextOver) )
                event.target:setStrokeColor( unpack(themeData.colorButtonOver) )

                tableQuestions[questionIndex].choiceSelected = event.target.textLabel.text
                event.target.isSelected = true


                local activeGroup, passiveGroup

                if (frontGroup.numChildren > 0) then
                    activeGroup, passiveGroup = frontGroup, backGroup                
                else
                    activeGroup, passiveGroup = backGroup, frontGroup
                end

                
                -- Calculate coin multiplier based on time left and multiplierScore(number of question sets available)
                local multiplierCoinAward = 1
                if (#activeGroup.timerElements <= numElementsTimer / 3) then
                    multiplierCoinAward = 0.5 * multiplierScore
                elseif (#activeGroup.timerElements <= (numElementsTimer * 2) / 3) then
                    multiplierCoinAward = 1 * multiplierScore
                elseif (#activeGroup.timerElements <= numElementsTimer) then
                    multiplierCoinAward = 1.5 * multiplierScore
                end
                local coinAward = roundNumber(#activeGroup.timerElements * multiplierCoinAward) + tableQuestions[questionIndex].numChoices

                local optionsCoinAward = { text = coinAward, font = fontLogo, fontSize = fontSizeQuestion }
                local textCoinAward = display.newText( optionsCoinAward )
                --textCoinAward:setFillColor( unpack(themeData.colorButtonOver) )
                textCoinAward:setFillColor( unpack(themeData.colorTextDefault) )
                textCoinAward.x = display.contentCenterX + textCoinAward.width / 2
                textCoinAward.y = activeGroup.timerElements[1].y
                activeGroup:insert(textCoinAward)

                textCoinAward.imageCoin = display.newCircle( activeGroup, 0, textCoinAward.y, fontSizeQuestion / 2 )
                --textCoinAward.imageCoin:setFillColor( unpack( themeData.colorButtonDefault ) )
                textCoinAward.imageCoin:setFillColor( unpack( themeData.colorButtonOver ) )
                textCoinAward.imageCoin.x = textCoinAward.x - textCoinAward.width / 2 - textCoinAward.imageCoin.width

                textCoinAward.symbolCurrency = display.newRect( activeGroup, textCoinAward.imageCoin.x, textCoinAward.imageCoin.y, textCoinAward.imageCoin.width / 3, textCoinAward.imageCoin.height / 3 )
                textCoinAward.symbolCurrency:setFillColor( unpack( themeData.colorBackground ) )
                textCoinAward.symbolCurrency.rotation = 45


                stopGameTimer(activeGroup)

                -- Deactivate buttons so player can't press another while waiting for the answer
                for i = 1, #activeGroup.choices do
                    activeGroup.choices[i].isActive = false
                end

                -- Wait some time to build up tension
                local timerShow
                timerShow = timer.performWithDelay(tableQuestions[questionIndex].timePause, function () 
                        showAnswer(activeGroup, event.target, textCoinAward)
                    end, 1)
                table.insert( tableTimers, timerShow )
            end
        end
    end
    return true
end

local function compare(a, b)
    if (questionCurrentSet % 2 == 0) then
        return a.numChoices > b.numChoices
    else
        return a.numChoices < b.numChoices
    end
end

local function handleGameData()
    questionIndex = 1

    -- Sort questions considering the question loop(Number of choices): 2-3-4-3-2
    table.sort( tableQuestions, compare )

    if (questionCurrent == 1 or isSaveAvailable) then
        local waitingTime = 500

        createGameArea(backGroup)

        -- Probably unnecessary but kept for integrity
        -- Removing waiting time breaks sound effects
        local timerHide = timer.performWithDelay( waitingTime, function () 
                hideActiveCard("hideLoadingCard", frontGroup, backGroup)
            end, 1)
        table.insert( tableTimers, timerHide )

        -- Set flag to false after game is ready to avoid re-running save related code
        isSaveAvailable = false
    end
end

local function determineMultiplierScore()
    local completedQuestionSets = composer.getVariable( "completedQuestionSets" )

    -- Check if any set was completed before
    -- If no set was registered as completed before, start registering
    if (#completedQuestionSets > 0) then
        -- Check completed sets to see if current question set is completed before
        -- If question set is completed before score multiplier will be set to one(1)
        local counterSetCheck = 1
        while (counterSetCheck <= #completedQuestionSets) do
            if (questionSetSelected == completedQuestionSets[counterSetCheck]) then
                isSetCompletedBefore = true
                multiplierScore = 1
                print "set completed before, set multiplierScore to 1"

                counterSetCheck = #completedQuestionSets + 1    -- exit loop
            else
                counterSetCheck = counterSetCheck + 1
            end
        end
    end
end

-- Pick questions from the loaded set
function initQuestions(amountQuestionsRequested)
    for i = 1, amountQuestionsRequested do
        local dataQuestion = {}

        local indexQuestionPicked = rng.random(#questionData.questions)
        dataQuestion.id = questionData.questions[indexQuestionPicked].id
        dataQuestion.textQuestion = questionData.questions[indexQuestionPicked].textQuestion

        -- Question loop(Number of choices): 2-3-4-3-2
        -- This is the loop that player will see throughout the game, in packs of 5
        -- Start with questions with 2 choices, then 3, then 4 and 3, then 2 again.
        -- Repeat it 4 times and you get 20 questions, a single run
        if (i == 1 or i == amountQuestionsRequested) then
            dataQuestion.numChoices = 2
        elseif (i == 2 or i == amountQuestionsRequested - 1) then
            dataQuestion.numChoices = 3
        elseif (i == 3) then
            dataQuestion.numChoices = 4
        end

        -- .timeRemaining is the time player got to answer that question
        -- .timePause is used for suspense before correct answer is shown
        if (dataQuestion.numChoices == 2) then
            dataQuestion.timeRemaining = 15
            dataQuestion.timePause = 1000
        elseif (dataQuestion.numChoices == 3) then
            dataQuestion.timeRemaining = 20
            dataQuestion.timePause = 1000
            --dataQuestion.timePause = 2000
        elseif (dataQuestion.numChoices == 4) then
            dataQuestion.timeRemaining = 25
            dataQuestion.timePause = 1000
            --dataQuestion.timePause = 3000
        end

        -- Initialize choice data
        dataQuestion.choices = {}
        for j = 1, 4 do
            dataQuestion.choices[j] = {}

            dataQuestion.choices[j].textChoice = questionData.questions[indexQuestionPicked].choices[j].textChoice

            -- Mark the answer(right choice)
            if (questionData.questions[indexQuestionPicked].choices[j].isAnswer) then
                dataQuestion.choices[j].isAnswer = true
            else
                dataQuestion.choices[j].isAnswer = false
            end
        end

        dataQuestion.choiceSelected = ""

        table.insert( tableQuestions, dataQuestion )


        -- Remove questions from loaded data set so they won't be picked up later
        -- Out of 100 questions, picked 5 questions so next time there are 95 questions to pick from
        for k = #questionData.questions[indexQuestionPicked].choices, 1, -1 do
            questionData.questions[indexQuestionPicked].choices[i] = {}
        end
        questionData.questions[indexQuestionPicked] = {}

        table.remove( questionData.questions, indexQuestionPicked )
    end

    handleGameData()
end

local function loadQuestionSet(indexSetRequested)
    local currentLanguage = composer.getVariable( "currentLanguage" )
    local fileQuestions = require ("questions." .. currentLanguage .. ".questionSet" .. indexSetRequested)
    questionData = fileQuestions.getData()

    for i = 1, #questionData.questions do
        questionData.questions[i].id = i
    end

    if (isSaveAvailable) then
        -- Label questions(by id) as asked in previous session so they are not shown again in any case
        for i = #savedQuestionsAsked, 1, -1 do
            local counterQuestions = 1
            while (savedQuestionsAsked[i] ~= questionData.questions[counterQuestions].id) do
                counterQuestions = counterQuestions + 1
            end

            table.remove( questionData.questions, counterQuestions )
        end
    end
end

-- Transition from menu theme to ingame music
local function handleAudioTransition()
    audio.stop()
    audio.dispose( streamMusicBackground )

    streamMusicBackground = audio.loadStream("assets/music/intro.wav")
    channelMusicBackground = audio.play(streamMusicBackground, {channel = channelMusicBackground, loops = -1})
    audio.setVolume(composer.getVariable( "musicLevel" ), {channel = channelMusicBackground})
end

function onSystemEvent(event)
    if( event.type == "applicationResume" ) then
        -- Calculate time spent between suspending(backgrounding) and resuming the game
        -- This is done to prevent cheating over web search
        local timeSuspend = composer.getVariable( "timeSuspend" )

        local timeElapsed = os.difftime( os.time(), timeSuspend )
        adjustGameTimer(timeElapsed)

        utils.resumeTimers(tableTimers)
        transition.resume()
    elseif( event.type == "applicationSuspend" ) then
        composer.setVariable( "timeSuspend", os.time() )

        utils.pauseTimers(tableTimers)
        transition.pause( )
    elseif( event.type == "applicationExit" ) then
        
    end
end

function scene:create( event )
    mainGroup = self.view

    local isSetLocked = false
    if (event.params) then
        if (event.params["isSetLocked"]) then
            -- If player locks the set, game will use the latest saved seed to get same questions
            -- Also, we silently take away the possibility of revival (This can be made visible in later builds)
            isSetLocked = event.params["isSetLocked"]
            isRevived = true

            seedSelected = composer.getVariable( "lastRandomSeed" )
            rng.randomseed( seedSelected )
        elseif (event.params["isSaveAvailable"]) then
            -- If player left the game in an interval(campfire) there must be a save file
            -- If a save is available, load:
            -- revival status, number of question(x/20), saved score, questions asked in last session, saved seed
            -- Getting isRevived is included to prevent multiple resurrection possibility
            isSaveAvailable = true
            isRevived = composer.getVariable( "savedIsRevived" )

            -- Calculate current question set
            -- Omit 1 from questionCurrent to get integer result
            -- Add 1 to result to get current set that player will continue
            questionCurrent = composer.getVariable( "savedQuestionCurrent" )
            questionCurrentSet = ((questionCurrent - 1) / amountQuestionSingleSet) + 1
            coinsEarned = composer.getVariable( "savedPlayerScore" )

            -- Initialize asked questions
            savedQuestionsAsked = composer.getVariable( "savedQuestionsAsked" )

            seedSelected = composer.getVariable( "savedRandomSeed" )
            rng.randomseed( seedSelected )

            composer.setVariable( "lastRandomSeed", seedSelected )
        else
            -- Generate completely new seed for random
            math.randomseed( os.time() )
            seedSelected = random( os.time() )
            rng.randomseed( seedSelected )

            composer.setVariable( "lastRandomSeed", seedSelected )
        end

        savePreferences()
    end

    frontGroup = display.newGroup( )
    backGroup = display.newGroup( )

    local tableFileNames = { "warning.wav", "answerChosen.wav", "answerRight.wav", "answerWrong.wav", "campfire.mp3", "revival.mp3" }
    tableSoundFiles = utils.loadSoundFX(tableSoundFiles, "assets/soundFX/", tableFileNames)


    if (isSetLocked) then
        -- Load the question set on the last failed run(saved)
        local lastQuestionSet = composer.getVariable( "lastQuestionSet" )
        questionSetSelected = lastQuestionSet
    elseif (isSaveAvailable) then
        -- Load the question set on the last incomplete run(saved)
        questionSetSelected = composer.getVariable( "savedQuestionSet" )
    else
        if (#availableQuestionSets <= 1) then
            -- That's the starting set. It's always the first set.
            questionSetSelected = availableQuestionSets[1]

            local lockedQuestionSets = composer.getVariable( "lockedQuestionSets" )
        else
            -- Select random question set from available sets

            -- Amplify range for better randomization
            -- It seemed to give better results when range is increased
            local rangeRandom = 25
            local rangeAmplified = rangeRandom * #availableQuestionSets
            local randomSelected = random(rangeAmplified)

            -- Check if random number in range
            -- If in range, exit loop
            -- If not in range, increment counter and check with next interval
            local counterRandomCheck = 1
            while (counterRandomCheck <= #availableQuestionSets) do
                if (randomSelected <= counterRandomCheck * rangeRandom) then
                    questionSetSelected = availableQuestionSets[counterRandomCheck]
                    counterRandomCheck = #availableQuestionSets + 1     -- exit loop
                else
                    counterRandomCheck = counterRandomCheck + 1
                end
            end

            composer.setVariable( "lastQuestionSet", questionSetSelected )

            --questionSetSelected = availableQuestionSets[random(#availableQuestionSets)]
        end
    end


    -- Calculate score multiplier and load the questions
    determineMultiplierScore()
    loadQuestionSet(questionSetSelected)
    initQuestions(amountQuestionSingleSet)

    mainGroup:insert( backGroup )
    mainGroup:insert( frontGroup )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        if (event.params) then
            -- Make the transition to ingame theme when scene becomes visible
            if (event.params["callSource"] == "menuScreen" or "endScreen" == event.params["callSource"]) then
                handleAudioTransition()
            end
        end

        composer.removeHidden()
        composer.setVariable("currentAppScene", "gameScreen")

        Runtime:addEventListener( "system", onSystemEvent )

        -- Prevent device from going to sleep while user is thinking
        system.setIdleTimer( false )
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        cleanUp()
    elseif ( phase == "did" ) then
        tableSoundFiles = utils.unloadSoundFX(tableSoundFiles)
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