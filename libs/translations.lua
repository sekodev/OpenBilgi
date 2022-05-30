------------------------------------------------------------------------------
--
-- This file is part of OpenBilgi, a roguelike trivia game repository
-- For overview and more information on licensing please refer to README.md 
-- Home page: https://github.com/sekodev/OpenBilgi
-- Contact: info.sleepybug@gmail.com
--
------------------------------------------------------------------------------

local languageSetup = {}

function languageSetup.getData()
    local languageData = {}

    languageData.default = "en"		-- add a default translation file. if option is missing, default is first entry

    -- Add available languages
    languageData[1] = "en"         -- enter language file name
    languageData[2] = "tr"

    return languageData
end

return languageSetup