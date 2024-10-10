local infoCredits = {}

function infoCredits.getData()
	local creditsData = {}
	creditsData.entries = {}

	----------------------------
    -- START OF EDITABLE AREA

	creditsData.entries[1] = {
		imagePath = { dark = "assets/other/logoSleepyBug.png", light = "assets/other/logoSleepyBug.png", width = contentHeightSafe / 3, height = contentHeightSafe / 3 }
	}

	creditsData.entries[2] = {
		title = sozluk.getString("developedBy"),
		people = { { fullName = "Serkan Aksit" } }
	}

	creditsData.entries[3] = {
		title = sozluk.getString("testedBy"),
		people = { { fullName = "Bilge Kol" } }
	}

	creditsData.entries[4] = {
		title = sozluk.getString("serverSideBy") .. "\n" .. sozluk.getString("prev04"),
		people = { { fullName = "Can Ertong" } }
	}

	creditsData.entries[5] = {
		title = sozluk.getString("music"),
		people = { 
			{ fullName = "Automation", author = "Eric Matyas", hyperlink = "https://soundimage.org/looping-music/" },
			{ fullName = "Safe Cracking", author = "Eric Matyas", hyperlink = "https://soundimage.org/city-urban-2/" },
		}
	}

	creditsData.entries[6] = {
		title = sozluk.getString("soundFX"),
		people = { 
			{ fullName = "freesound.org/404151/", author = "Mattias 'MATTIX' Lahoud", hyperlink = "https://freesound.org/people/MATTIX/sounds/404151/" },
			{ fullName = "freesound.org/216090/", author = "RICHERlandTV", hyperlink = "https://freesound.org/people/RICHERlandTV/sounds/216090/" },
			{ fullName = "freesound.org/264981/", author = "renatalmar", hyperlink = "https://freesound.org/people/renatalmar/sounds/264981/" },
			{ fullName = "freesound.org/387713/", author = "Jagadamba", hyperlink = "https://freesound.org/people/Jagadamba/sounds/387713/" },
			{ fullName = "freesound.org/80600/", author = "severaltimes", hyperlink = "https://freesound.org/people/severaltimes/sounds/80600/" },
			{ fullName = "freesound.org/392465/\n" .. sozluk.getString("shortenedUse"), author = "ModulationStation", hyperlink = "https://freesound.org/people/ModulationStation/sounds/392465/" },
			{ fullName = ".", author = sozluk.getString("disclaimerSoundLicense") }, 
		}
	}

	creditsData.entries[7] = {
		title = sozluk.getString("font"),
		people = { 
			{ fullName = "Russo One", author = "Jovanny Lemonad", hyperlink = "https://www.dafont.com/russo-one.font" },
			{ fullName = ".", author = sozluk.getString("disclaimerFont"), hyperlink = "https://scripts.sil.org/OFL" }, 
		}
	}

	creditsData.entries[8] = {
		title = sozluk.getString("poweredBy"),
		imagePath = { dark = "assets/other/logoSolar2D.png", light = "assets/other/logoSolar2D-light.png", 
		width = 572, height = 200, hyperlink = "https://solar2d.com/", }
	}

	creditsData.entries[9] = {
		people = { { fullName = "***", author = sozluk.getString("disclaimerCopyright") } }
	}

	-- END OF EDITABLE AREA
    ----------------------------

	return creditsData
end


return infoCredits