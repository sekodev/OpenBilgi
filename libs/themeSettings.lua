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

local themeSettings = {}

function themeSettings.getData(themeSelected)
	local themeData = {}

	-- themes: dark - light

	if (themeSelected == "dark") then
		themeData.themeSelected = "dark"

		themeData.colorBackground = { 0, 0, 0 }
		themeData.colorBackgroundPopup = { .917, .917, .843 }

		themeData.colorButtonFillDefault = themeData.colorBackground
		themeData.colorButtonFillOver = { .917, .917, .843 }
		themeData.colorButtonDefault = { .917, .917, .843 }
		themeData.colorButtonFillTrue = { .055, .759, .035 }
		themeData.colorButtonFillWrong = { .878, 0, 0 }
		themeData.colorButtonOver = { .99, .82, .009 }
		themeData.colorButtonStroke = { .917, .917, .843 }

		themeData.strokeWidthButtons = 3
		themeData.cornerRadiusButtons = 25

		themeData.colorVisualCue = { .878, 0, 0 }
		themeData.strokeWidthVisualCue = 10

		themeData.colorPadlock = { .878, 0, 0 }

		themeData.colorTextDefault = { .917, .917, .843 }
		themeData.colorTextOver = { 0, 0, 0 }
		themeData.colorTextSelected = { .917, .917, .843 }
		themeData.colorTextTrue = themeData.colorTextSelected
		themeData.colorTextWrong = { 0, 0, 0 }

		themeData.colorTimeLeftLow = themeData.colorButtonFillWrong
		themeData.colorTimeLeftMedium = themeData.colorButtonOver
		themeData.colorTimeLeftHigh =  themeData.colorButtonFillTrue

		themeData.colorHyperlink = { .56, .85, .85 }
		themeData.colorHyperlinkVisited = { .023, .27, .678 }
		themeData.colorHyperlinkPopup = { 0, 0, 1 }
		themeData.colorHyperlinkPopupVisited = { .56, .85, .85 }
	elseif (themeSelected == "light") then
		themeData.themeSelected = "light"

		themeData.colorBackground = { 1, 1, .922 }
		themeData.colorBackgroundPopup = { 0, 0, 0 }

		themeData.colorButtonFillDefault = themeData.colorBackground
		themeData.colorButtonFillOver = { 0, 0, 0 }
		themeData.colorButtonDefault = { 0, 0, 0 }
		themeData.colorButtonFillTrue = { .055, .759, .035 }
		themeData.colorButtonFillWrong = { .878, 0, 0 }
		themeData.colorButtonOver = { .99, .82, .009 }
		themeData.colorButtonStroke = { 0, 0, 0 }

		themeData.strokeWidthButtons = 3
		themeData.cornerRadiusButtons = 25

		themeData.colorVisualCue = { .878, 0, 0 }
		themeData.strokeWidthVisualCue = 10

		themeData.colorPadlock = { .878, 0, 0 }

		themeData.colorTextDefault = { 0, 0, 0 }
		themeData.colorTextOver = { 0, 0, 0 }
		themeData.colorTextSelected = { .917, .917, .843 }
		themeData.colorTextTrue = themeData.colorTextSelected
		themeData.colorTextWrong = { 0, 0, 0 }

		themeData.colorTimeLeftLow = themeData.colorButtonFillWrong
		themeData.colorTimeLeftMedium = themeData.colorButtonOver
		themeData.colorTimeLeftHigh =  themeData.colorButtonFillTrue

		themeData.colorHyperlink = { 0, 0, 1 }
		themeData.colorHyperlinkVisited = { .56, .85, .85 }
		themeData.colorHyperlinkPopup = { .56, .85, .85 }
		themeData.colorHyperlinkPopupVisited = { .023, .27, .678 }
	end

    return themeData
end

return themeSettings