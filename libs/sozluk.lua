--[[
	The MIT License (MIT)

	Copyright (c) 2015 Serkan Aksit

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]--

-- Project: sozluk
--
-- Version: 0.1.1
--
-- Author: Serkan Aksit - https://github.com/sekodev
-- Contact: info.sleepybug@gmail.com
-- Sleepy Bug Studio
-- Facebook: https://www.facebook.com/sleepybugstudio
-- Twitter: https://twitter.com/sleepybugstudio
--
-- Update History:
-- 0.1.1 - Update contact information (May 30, 2022)
-- 0.1 - Initial release (April 15, 2015)

-- ########################################################
-- Basic instructions
-- Import library
-- local sozluk = require "sozluk"

-- Initialize sozluk object
-- sozluk.init()

-- Set path of your translations folder
-- sozluk.setTranslationFolder("translations")

-- Set selected translation
-- sozluk.setSelectedTranslation("english")

-- Get string with key value
-- sozluk.getString("start")

-- ########################################################


local sozluk = {}

local availableTranslations = {}
local strings = {}

local folderTranslation = ""
local selectedTranslation = "english"
local defaultTranslation

local pathAvailableTranslations = "translations"


local function checkFileExists()
	local filePath

	if ( folderTranslation == "" ) then
		filePath = system.pathForFile( selectedTranslation .. ".lua", system.ResourceDirectory )
	else
		filePath = system.pathForFile( folderTranslation .. "/" .. selectedTranslation .. ".lua", system.ResourceDirectory )
	end

	if ( filePath ) then
		local theFile = io.open(filePath, "r")

		-- Determine if file exists
		if theFile then
		   theFile:close()

		   return true
		else
		    print( "Translation file '" .. selectedTranslation .. ".lua' does not exist in the defined path! Check file path in '" .. pathAvailableTranslations .. ".lua'" )
		    return false
		end
	else
		print( "Translation file '" .. selectedTranslation .. ".lua' does not exist in the defined path! Check file path in '" .. pathAvailableTranslations .. ".lua'" )
		return false
	end
end

local function loadSelectedTranslation()
	--if ( checkFileExists() == false ) then
	--	print "doesn't exist"
	--	selectedTranslation = defaultTranslation
	--end

	local selectedTranslationSetup

	if ( folderTranslation == "" ) then
		selectedTranslationSetup = require (selectedTranslation)
	else
		selectedTranslationSetup = require (folderTranslation .. "." .. selectedTranslation)
	end

	local selectedTranslationData = selectedTranslationSetup.getData()

	for key, data in pairs (selectedTranslationData) do
		strings[key] = data
	end
end

local function setDefaultTranslation(translationData)
	if ( translationData.default == nil or translationData.default == "" ) then
		defaultTranslation = availableTranslations[1]
		print ("Default translation not defined. Set to '" .. defaultTranslation .. "'")
	else
		defaultTranslation = translationData.default
		print ("Default translation is set to defined value '" .. defaultTranslation .. "'")
	end

	--BU EKLENDİ
	selectedTranslation = defaultTranslation
end

local function setAvailableTranslations(translationData)
	for i = 1, #translationData do
	    availableTranslations[i] = translationData[i]
	end
end

function sozluk.getAvailableTranslations()
	return availableTranslations
end

function sozluk.getString(keyString)
	return strings[keyString]
end

function sozluk.getSelectedTranslation()
	return selectedTranslation
end

function sozluk.setSelectedTranslation(nameTranslation)
	selectedTranslation = nameTranslation

	loadSelectedTranslation()
end

function sozluk.setTranslationFolder(nameFolder)
	folderTranslation = nameFolder
end

function sozluk.getTranslationFolder()
	if ( folderTranslation == "" ) then
		print ("Translation folder is set to root.")
	end

	return folderTranslation
end

function sozluk.getTranslationsPath()
	return pathAvailableTranslations
end

function sozluk.setTranslationsPath(filePath)
	pathAvailableTranslations = filePath
end

function sozluk.init()
	local translationSetup = require(pathAvailableTranslations)
	local translationData = translationSetup.getData()

	setAvailableTranslations(translationData)
	setDefaultTranslation(translationData)
	loadSelectedTranslation()
end

return sozluk