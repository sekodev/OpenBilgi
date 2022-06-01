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

local resWidth, resHeight

if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) then
    resWidth = 768
    resHeight = 1024
elseif ( display.pixelHeight / display.pixelWidth > 2 ) then
    resWidth = 810
    resHeight = 1800
elseif ( display.pixelHeight / display.pixelWidth > 1.72 ) then
    resWidth = 720
    resHeight = 1280
else
    resWidth = 768
    resHeight = 1280
end

application =
{
    content =
    {
        width = resWidth,
        height = resHeight,
        fps = 60,

        imageSuffix =
        {
        	["@2x"] = 1.5,
            ["@4x"] = 3,
        },
    },
}