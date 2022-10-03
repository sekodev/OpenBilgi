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

local questionSetup = {}

function questionSetup.getData()
	local questionData = {}
	questionData.questions = {}

	--[[
		Example:
		questionData.questions[] = { textQuestion = "Set 4 - Soru 0 - Türkçe - TR", 
		choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }
	]]--

	questionData.questions[1] = { textQuestion = "Set 4 - Soru 1 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[2] = { textQuestion = "Set 4 - Soru 2 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[3] = { textQuestion = "Set 4 - Soru 3 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[4] = { textQuestion = "Set 4 - Soru 4 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[5] = { textQuestion = "Set 4 - Soru 5 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[6] = { textQuestion = "Set 4 - Soru 6 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[7] = { textQuestion = "Set 4 - Soru 7 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[8] = { textQuestion = "Set 4 - Soru 8 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[9] = { textQuestion = "Set 4 - Soru 9 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[10] = { textQuestion = "Set 4 - Soru 10 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[11] = { textQuestion = "Set 4 - Soru 11 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[12] = { textQuestion = "Set 4 - Soru 12 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[13] = { textQuestion = "Set 4 - Soru 13 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[14] = { textQuestion = "Set 4 - Soru 14 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[15] = { textQuestion = "Set 4 - Soru 15 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[16] = { textQuestion = "Set 4 - Soru 16 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[17] = { textQuestion = "Set 4 - Soru 17 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[18] = { textQuestion = "Set 4 - Soru 18 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[19] = { textQuestion = "Set 4 - Soru 19 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[20] = { textQuestion = "Set 4 - Soru 20 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[21] = { textQuestion = "Set 4 - Soru 21 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[22] = { textQuestion = "Set 4 - Soru 22 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[23] = { textQuestion = "Set 4 - Soru 23 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[24] = { textQuestion = "Set 4 - Soru 24 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[25] = { textQuestion = "Set 4 - Soru 25 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[26] = { textQuestion = "Set 4 - Soru 26 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[27] = { textQuestion = "Set 4 - Soru 27 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[28] = { textQuestion = "Set 4 - Soru 28 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[29] = { textQuestion = "Set 4 - Soru 29 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[30] = { textQuestion = "Set 4 - Soru 30 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[31] = { textQuestion = "Set 4 - Soru 31 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[32] = { textQuestion = "Set 4 - Soru 32 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[33] = { textQuestion = "Set 4 - Soru 33 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[34] = { textQuestion = "Set 4 - Soru 34 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[35] = { textQuestion = "Set 4 - Soru 35 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[36] = { textQuestion = "Set 4 - Soru 36 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[37] = { textQuestion = "Set 4 - Soru 37 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[38] = { textQuestion = "Set 4 - Soru 38 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[39] = { textQuestion = "Set 4 - Soru 39 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[40] = { textQuestion = "Set 4 - Soru 40 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[41] = { textQuestion = "Set 4 - Soru 41 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[42] = { textQuestion = "Set 4 - Soru 42 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[43] = { textQuestion = "Set 4 - Soru 43 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[44] = { textQuestion = "Set 4 - Soru 44 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[45] = { textQuestion = "Set 4 - Soru 45 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[46] = { textQuestion = "Set 4 - Soru 46 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[47] = { textQuestion = "Set 4 - Soru 47 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[48] = { textQuestion = "Set 4 - Soru 48 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[49] = { textQuestion = "Set 4 - Soru 49 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[50] = { textQuestion = "Set 4 - Soru 50 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[51] = { textQuestion = "Set 4 - Soru 51 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[52] = { textQuestion = "Set 4 - Soru 52 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[53] = { textQuestion = "Set 4 - Soru 53 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[54] = { textQuestion = "Set 4 - Soru 54 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[55] = { textQuestion = "Set 4 - Soru 55 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[56] = { textQuestion = "Set 4 - Soru 56 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[57] = { textQuestion = "Set 4 - Soru 57 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[58] = { textQuestion = "Set 4 - Soru 58 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[59] = { textQuestion = "Set 4 - Soru 59 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[60] = { textQuestion = "Set 4 - Soru 60 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[61] = { textQuestion = "Set 4 - Soru 61 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[62] = { textQuestion = "Set 4 - Soru 62 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[63] = { textQuestion = "Set 4 - Soru 63 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[64] = { textQuestion = "Set 4 - Soru 64 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[65] = { textQuestion = "Set 4 - Soru 65 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[66] = { textQuestion = "Set 4 - Soru 66 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[67] = { textQuestion = "Set 4 - Soru 67 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[68] = { textQuestion = "Set 4 - Soru 68 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[69] = { textQuestion = "Set 4 - Soru 69 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[70] = { textQuestion = "Set 4 - Soru 70 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[71] = { textQuestion = "Set 4 - Soru 71 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[72] = { textQuestion = "Set 4 - Soru 72 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[73] = { textQuestion = "Set 4 - Soru 73 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[74] = { textQuestion = "Set 4 - Soru 74 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[75] = { textQuestion = "Set 4 - Soru 75 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[76] = { textQuestion = "Set 4 - Soru 76 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[77] = { textQuestion = "Set 4 - Soru 77 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[78] = { textQuestion = "Set 4 - Soru 78 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[79] = { textQuestion = "Set 4 - Soru 79 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[80] = { textQuestion = "Set 4 - Soru 80 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[81] = { textQuestion = "Set 4 - Soru 81 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[82] = { textQuestion = "Set 4 - Soru 82 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[83] = { textQuestion = "Set 4 - Soru 83 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[84] = { textQuestion = "Set 4 - Soru 84 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[85] = { textQuestion = "Set 4 - Soru 85 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[86] = { textQuestion = "Set 4 - Soru 86 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[87] = { textQuestion = "Set 4 - Soru 87 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[88] = { textQuestion = "Set 4 - Soru 88 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[89] = { textQuestion = "Set 4 - Soru 89 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[90] = { textQuestion = "Set 4 - Soru 90 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[91] = { textQuestion = "Set 4 - Soru 91 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[92] = { textQuestion = "Set 4 - Soru 92 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[93] = { textQuestion = "Set 4 - Soru 93 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[94] = { textQuestion = "Set 4 - Soru 94 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[95] = { textQuestion = "Set 4 - Soru 95 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[96] = { textQuestion = "Set 4 - Soru 96 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[97] = { textQuestion = "Set 4 - Soru 97 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[98] = { textQuestion = "Set 4 - Soru 98 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[99] = { textQuestion = "Set 4 - Soru 99 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	questionData.questions[100] = { textQuestion = "Set 4 - Soru 100 - Türkçe - TR", 
	choices = { {textChoice = "Seçenek A", isAnswer = true}, {textChoice = "Seçenek B"}, {textChoice = "Seçenek C"}, {textChoice = "Seçenek D"} } }

	return questionData
end

return questionSetup