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

local translationSetup = {}

function translationSetup.getData()
    local translationData = {}

    translationData["startGame"] = "Play"
    translationData["continueGame"] = "Continue"
    translationData["settings"] = "Settings"
    translationData["credits"] = "About us"
    translationData["termsRequest"] = "You need to accept our terms & conditions before you start using the app."
    translationData["termsRequestAccept"] = "I accept."
    translationData["termsUse"] = "Terms of Use"
    translationData["privacyPolicy"] = "Privacy Policy"
    translationData["restart"] = "Play again"
    translationData["continue"] = "Continue"
    translationData["mainMenu"] = "Main menu"
    translationData["themeSelected"] = "Theme:"
    translationData["themeLight"] = "Light"
    translationData["themeDark"] = "Dark"
    translationData["reduceMotion"] = "Reduce motion:"
    translationData["fullScreen"] = "Full screen:"
    translationData["settingOn"] = "On"
    translationData["settingOff"] = "Off"
    translationData["languageSelected"] = "Language:"
    translationData["languageTurkish"] = "Türkçe"
    translationData["languageEnglish"] = "English"
    translationData["bestScore"] = "best score"
    translationData["gamesPlayed"] = "games played"
    translationData["questionsAnsweredTotal"] = "questions answered"
    translationData["runsCompleted"] = "runs completed"
    translationData["locksUsed"] = "locks used"
    translationData["coinsTotal"] = "coins earned"
    translationData["percentageRevival"] = "chance of revival"
    translationData["resetStats"] = "Reset statistics"
    translationData["resetStatsAsk"] = "Are you sure you want to reset your gameplay statistics? (Your progress will be preserved.)"
    translationData["resetStatsConfirm"] = "Confirm"
    translationData["resetStatsDeny"] = "Deny"
    translationData["resetQuestions"] = "Reset questions"
    translationData["resetQuestionsAsk"] = "Are you sure you want to reset questions? (Everything else will be preserved.)"
    translationData["resetQuestionsConfirm"] = "Confirm"
    translationData["resetQuestionsDeny"] = "Deny"
    translationData["loadingLeaderboard"] = "Loading leaderboard..."
    translationData["lockInformation"] = "You can lock down your latest session to answer the same questions in the same order."
    translationData["lockInformationNA"] = "You don't have enough locks."
    translationData["lockInformationHide"] = "Don't show again"
    translationData["currencyThousand"] = "k"
    translationData["shareStoreQR"] = "Show QR code"
    translationData["shareStoreLink"] = "Share link"
    translationData["breakCardLabel"] = "Take a break..."
    translationData["breakCardContinue"] = "Continue"
    translationData["breakCardSaveExit"] = "Save and quit"
    translationData["revivalCardContinue"] = "Second chance"
    translationData["successCongrats"] = "CONGRATULATIONS!"
    translationData["successSetCompletedBefore"] = "You have successfully completed the question set!\n\nKeep playing to see other sets."
    translationData["successSetUnlocked"] = "You have successfully completed the question set!\n\nNew questions added to the mix."
    translationData["successSetNA"] = "You have successfully completed every set and unlocked all questions.\n\nYou can continue playing to answer every question available!"
    translationData["successEndgame"] = "You have successfully completed the question set!\n\nThere may still be some questions you haven't seen, yet."
    translationData["quitAsk"] = "Do you want to go to main menu?\nYou'll need to start over."
    translationData["quitAccept"] = "Yes"
    translationData["quitDecline"] = "Not now"
    translationData["ratingAsk"] = "Would you like to rate the game?"
    translationData["ratingOK"] = "Yes!"
    translationData["ratingLater"] = "Maybe later"
    translationData["ratingFeedback"] = "Contact us"
    translationData["sendFeedback"] = "Send"
    translationData["placeholderFeedback"] = "You can type\nyour suggestions here."
    translationData["openURLQuestion"] = "This link will take you outside of the application to the following address:"
    translationData["openURLConfirm"] = "Confirm"
    translationData["openURLDeny"] = "Deny"
    translationData["languageNotificationInformation"] = "You can change your language preferences through Settings and try the game in Turkish."
    translationData["languageNotificationConfirm"] = "Go to Settings"
    translationData["languageNotificationDeny"] = "OK"
    translationData["score"] = "Score"
    translationData["highScore"] = "High score!"
    translationData["developedBy"] = "Developer"
    translationData["testedBy"] = "Testing"
    translationData["serverSideBy"] = "Backend"
    translationData["prev04"] = "pre-v0.4"
    translationData["music"] = "Music"
    translationData["soundFX"] = "Sound effects"
    translationData["font"] = "Font"
    translationData["shortenedUse"] = "(short version)"
    translationData["disclaimerSoundLicense"] = "Music and sound effects in this game are licensed under different licenses. For more information, please visit related addresses."
    translationData["disclaimerFont"] = "SIL Open Font License version 1.1. For more information, please visit https://scripts.sil.org/OFL."
    translationData["disclaimerCopyright"] = "All trademarks, logos and brand names are the property of their respective owners."
    translationData["poweredBy"] = "Powered by"
    translationData["sendSupportMailSubject"] = "Feedback - OpenBilgi"
    translationData["sendSupportMailVersionInformation"] = "Version information"
    translationData["sendSupportMailBody"] = "You can type your message here."

    return translationData
end

return translationSetup