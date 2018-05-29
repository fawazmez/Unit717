-----------------------------------------------------------------------------------------
--
-- MenuScene.lua
--
-- Created By: Fawaz Mezher
-- Created On: May 2018
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
 
local scene = composer.newScene()

function onButtonClicked( event )

    local options = {
        effect = 'fade',
        time = 750
    }

    composer.gotoScene( "scene.gameScene", options )
end

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        local sceneText = display.newText( 'Menu Scene', display.contentCenterX , display.contentCenterY + 200, native.systemFont, 128 )
        sceneText:setFillColor( 0, 0, 1 )
        sceneGroup:insert( sceneText )
        
        local button = display.newRect( display.contentCenterX, display.contentCenterY, 400, 200 )
        button:setFillColor( 1, 0, 0 )
        sceneGroup:insert( button )

        local clickText = display.newText( "Play Game!", display.contentCenterX, display.contentCenterY, native.systemFont, 64 )
        clickText:setFillColor( 0, 0, 0 )
        sceneGroup:insert( clickText )

        button:addEventListener( "touch", onButtonClicked )
        
    elseif ( phase == "did" ) then

        
 
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