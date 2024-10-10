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

local widthStarting, heightStarting = 720, 1280
local pixelWidth, pixelHeight = display.pixelWidth, display.pixelHeight

local scale = math.max(widthStarting / pixelWidth, heightStarting / pixelHeight)
local widthResolution, heightResolution = pixelWidth * scale, pixelHeight * scale

application =
{
    content =
    {
        width = widthResolution,
        height = heightResolution,
        fps = 60,

        imageSuffix =
        {
        	["@2x"] = 1.5,
            ["@4x"] = 3,
        },
    },
}