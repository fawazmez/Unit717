-----------------------------------------------------------------------------------------
--
-- gameScene.lua
--
-- Created By: Fawaz Mezher
-- Created On: May 2018
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local physics = require( "physics" )
local json = require( "json" )
local tiled = require( "com.ponywolf.ponytiled" )

local scene = composer.newScene()

-- Forward reference
local ninjaBoy = nil
local map = nil
local rightArrow = nil
local jumpButton = nil
local shootButton = nil
local playerBullets = {}

-- Function to chaneg sequence 
local function onRightArrowClicked( event )
    if ( event.phase == "began" ) then 
        if ninjaBoy.sequence ~= "run" then 
            ninjaBoy.sequence = "run"
            ninjaBoy:setSequence( "run" )
            ninjaBoy:play()
        end    
    
    elseif ( event.phase == "ended" ) then   
        if ninjaBoy.sequence ~= "idle" then 
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence( "idle" )
            ninjaBoy:play()
        end 
    end 
    
    return true    
end

local function onJumpButtonClicked( event )
    if ( event.phase == "began" ) then 
        if ninjaBoy.sequence ~= "jump" then
            ninjaBoy.sequence = "jump"
            ninjaBoy:setLinearVelocity( 150, -500 )
            ninjaBoy:setSequence( "jump" )
            ninjaBoy:play()
        end
   end  

   return true  
end

-- move ninja
local function moveNinja( event )
    if ninjaBoy.sequence == "run" then
        transition.moveBy( ninjaBoy, {
            x = 10,
            y = 0,
            time = 0
            } )
    end     
    
    if ninjaBoy.sequence == "jump" then
        local linearVelocityX, linearVelocityY = ninjaBoy:getLinearVelocity()

        if linearVelocityX == 0 then
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence( "idle" )
            ninjaBoy:play()
        end
    end

    return true
end


local function resetAfterThrow( event )
    ninjaBoy.sequence = "idle"
    ninjaBoy:setSequence( "idle" )
    ninjaBoy:play()
end

function onthrowButtonClicked( event )
    if ( event.phase == "began" ) then
        if ninjaBoy.sequence ~= "throw" then 
            ninjaBoy.sequence = "throw"
            ninjaBoy:setSequence( "throw" )
            ninjaBoy:play()
            timer.performWithDelay( 800, resetAfterThrow )

        -- use function to delay throw to match animation
            local function delayThrow( event )
                local aSingleBullet = display.newImage( "./assets/sprites/Kunai.png" )
                 -- puts bullet on screen at character postion
                aSingleBullet.x = ninjaBoy.x
                aSingleBullet.y = ninjaBoy.y
                physics.addBody( aSingleBullet, 'dynamic' )
                -- Makes sprite a "bullet" type object
                aSingleBullet.isBullet = true
                aSingleBullet.gravityScale = 0
                aSingleBullet.id = "bullet"
                aSingleBullet:setLinearVelocity( 1500, 0 )
                aSingleBullet.isFixedRotation = true
        
                table.insert(playerBullets,aSingleBullet)
                print("# of bullet: " .. tostring(#playerBullets))    
            end 
        timer.performWithDelay( 200, delayThrow )
        
        
        end
    end

    return true
end

local function checkPlayerBulletsOutOfBounds()
    -- check if bullets are off the screen and rmoves them 
    local bulletCounter

    if #playerBullets > 0 then
        for bulletCounter = #playerBullets, 1 ,-1 do
            if playerBullets[bulletCounter].x > display.contentWidth + 1000 then
                playerBullets[bulletCounter]:removeSelf()
                playerBullets[bulletCounter] = nil
                table.remove(playerBullets, bulletCounter)
                print("remove bullet")
            end
        end
    end
end

-- create()
function scene:create( event )
 
    local sceneGroup = self.view

    physics.start()
    physics.setGravity( 0, 20 )

    -- show map 
    local filename = "assets/maps/level0.json"
    local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
    map = tiled.new( mapData, "assets/maps" )

    local sheetOptionsIdleBoy = require( "assets.spritesheets.ninjaBoy.ninjaBoyIdle" )
    local sheetBoyIdle = graphics.newImageSheet( "./assets/spritesheets/ninjaBoy/ninjaBoyIdle.png", sheetOptionsIdleBoy:getSheet() )

    local sheetOptionsRunBoy = require( "assets.spritesheets.ninjaBoy.ninjaBoyRun" )
    local sheetBoyRun = graphics.newImageSheet( "./assets/spritesheets/ninjaBoy/ninjaBoyRun.png", sheetOptionsRunBoy:getSheet() )

    local sheetOptionsJumpBoy = require( "assets.spritesheets.ninjaBoy.ninjaBoyJump" )
    local sheetBoyJump = graphics.newImageSheet( "./assets/spritesheets/ninjaBoy/ninjaBoyJump.png", sheetOptionsJumpBoy:getSheet() )

    local sheetOptionsThrowBoy = require( "assets.spritesheets.ninjaBoy.ninjaBoyThrow" )
    local sheetBoyThrow = graphics.newImageSheet( "./assets/spritesheets/ninjaBoy/ninjaBoyThrow.png", sheetOptionsThrowBoy:getSheet() )
    
    local sequence_data = {
        {
            name = "idle",
            start = 1, 
            count = 10,
            time = 800, 
            loopCount = 0,
            sheet = sheetBoyIdle
        },
        {
            name = "run",
            start = 1, 
            count = 10,
            time = 800, 
            loopCount = 0,
            sheet = sheetBoyRun
        },
        {
            name = "jump",
            start = 1, 
            count = 10,
            time = 1000, 
            loopCount = 1,
            sheet = sheetBoyJump
        },
        {
            name = "throw",
            start = 1, 
            count = 10,
            time = 750, 
            loopCount = 1,
            sheet = sheetBoyThrow
        }
    }


    -- show ninjaBoy
    ninjaBoy = display.newSprite( sheetBoyIdle, sequence_data )
    ninjaBoy.x = display.contentWidth / 2 
    ninjaBoy.y = 0
    ninjaBoy.sequence = "idle"
    ninjaBoy.isFixedRotation = true
    ninjaBoy.id = "ninja Boy"
    physics.addBody( ninjaBoy, "dynamic", { 
        friction = 0.5, 
        bounce = 0.3 
        } )
    ninjaBoy:setSequence( "idleBoy" )
    ninjaBoy:play()

    rightArrow = display.newImage( "./assets/sprites/rightButton.png" )
    rightArrow.x = 300
    rightArrow.y = 1300
    rightArrow.id = "right Arrow"
    rightArrow.alpha = 0.7

    jumpButton = display.newImage( "./assets/sprites/jumpButton.png" )
    jumpButton.x  = 1500
    jumpButton.y = 1300
    jumpButton.id = "jump Button"
    jumpButton.alpha = 0.7

    throwButton = display.newImage( "./assets/sprites/jumpButton.png" )
    throwButton.x  = 1700
    throwButton.y = 1300
    throwButton.id = "throw Button"
    throwButton.alpha = 0.7

    sceneGroup:insert( map )
    sceneGroup:insert( ninjaBoy )
    sceneGroup:insert( rightArrow )
    sceneGroup:insert( jumpButton )
    sceneGroup:insert( throwButton )

end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
     
    elseif ( phase == "did" ) then
        rightArrow:addEventListener( "touch", onRightArrowClicked )
        jumpButton:addEventListener( "touch", onJumpButtonClicked )
        throwButton:addEventListener( "touch", onthrowButtonClicked )
        Runtime:addEventListener( "enterFrame", moveNinja )
        Runtime:addEventListener( "enterFrame", checkPlayerBulletsOutOfBounds )
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        rightArrow:removeEventListener( "touch", onRightArrowClicked )
        jumpButton:removeEventListener( "touch", onJumpButtonClicked )
        throwButton:removeEventListener( "touch", onthrowButtonClicked )
        Runtime:removeEventListener( "enterFrame", moveNinja )
        Runtime:removeEventListener( "enterFrame", checkPlayerBulletsOutOfBounds )
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene