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

    translationData["startGame"] = "Başla"
    translationData["continueGame"] = "Devam et"
    translationData["settings"] = "Ayarlar"
    translationData["credits"] = "Hakkımızda"
    translationData["termsRequest"] = "Uygulamayı kullanmadan önce şartlarımızı kabul etmeniz gerekmektedir."
    translationData["termsRequestAccept"] = "Kabul ediyorum."
    translationData["termsUse"] = "Kullanım Şartları"
    translationData["privacyPolicy"] = "Gizlilik Politikası"
    translationData["restart"] = "Tekrar oyna"
    translationData["continue"] = "Devam et"
    translationData["mainMenu"] = "Ana menü"
    translationData["themeSelected"] = "Tema:"
    translationData["themeLight"] = "Açık"
    translationData["themeDark"] = "Koyu"
    translationData["reduceMotion"] = "Hareketi azalt:"
    translationData["fullScreen"] = "Tam ekran:"
    translationData["settingOn"] = "Açık"
    translationData["settingOff"] = "Kapalı"
    translationData["languageSelected"] = "Dil:"
    translationData["languageTurkish"] = "Türkçe"
    translationData["languageEnglish"] = "English"
    translationData["bestScore"] = "rekor"
    translationData["gamesPlayed"] = "kere oynadın"
    translationData["questionsAnsweredTotal"] = "soru cevapladın"
    translationData["runsCompleted"] = "oyunu tamamladın"
    translationData["locksUsed"] = "kilit kullandın"
    translationData["coinsTotal"] = "altın kazandın"
    translationData["percentageRevival"] = "ikinci şans oranı"
    translationData["resetStats"] = "İstatistikleri sıfırla"
    translationData["resetStatsAsk"] = "Oynanış istatistiklerini sıfırlamak istediğine emin misin? (Oyundaki ilerlemen korunacak.)"
    translationData["resetStatsConfirm"] = "Onayla"
    translationData["resetStatsDeny"] = "Vazgeç"
    translationData["resetQuestions"] = "Soruları sıfırla"
    translationData["resetQuestionsAsk"] = "Soruları sıfırlamak istediğine emin misin? (Geri kalan her şey korunacak.)"
    translationData["resetQuestionsConfirm"] = "Onayla"
    translationData["resetQuestionsDeny"] = "Vazgeç"
    translationData["loadingLeaderboard"] = "Puan tablosu yükleniyor..."
    translationData["lockInformation"] = "Bir kilit karşılığında son oyunda cevapladığın soruları -aynı sırayla- tekrar cevaplama hakkı elde edersin."
    translationData["lockInformationNA"] = "Soruları sabitlemek için yeterli kilidin bulunmuyor."
    translationData["lockInformationHide"] = "Bir daha gösterme"
    translationData["currencyThousand"] = "b"
    translationData["shareStoreQR"] = "QR kodu göster"
    translationData["shareStoreLink"] = "Bağlantı paylaş"
    translationData["breakCardLabel"] = "Biraz nefeslen..."
    translationData["breakCardContinue"] = "Devam et"
    translationData["breakCardSaveExit"] = "Kaydet ve çık"
    translationData["revivalCardContinue"] = "İkinci şans"
    translationData["successCongrats"] = "TEBRİKLER!"
    translationData["successSetCompletedBefore"] = "Seti başarıyla tamamladın!\n\nOynamaya devam ederek diğer setleri görebilirsin."
    translationData["successSetUnlocked"] = "Seti başarıyla tamamladın!\n\nYeni sorular karışıma eklendi."
    translationData["successSetNA"] = "Bütün setleri başarıyla tamamladın ve tüm soruları açtın.\n\nOynamaya devam ederek görmediğin soruların peşine düşebilirsin!"
    translationData["successEndgame"] = "Seti başarıyla tamamladın!\n\nAncak hala görmediğin sorular olabilir!"
    translationData["quitAsk"] = "Ana menüye dönmek istiyor musunuz?\nOyuna baştan başlaman gerekecek."
    translationData["quitAccept"] = "Evet"
    translationData["quitDecline"] = "Hayır"
    translationData["ratingAsk"] = "Oyuna puan vermek ister misin?"
    translationData["ratingOK"] = "Evet!"
    translationData["ratingLater"] = "Belki daha sonra..."
    translationData["ratingFeedback"] = "Bize ulaşın"
    translationData["sendFeedback"] = "Gönder"
    translationData["placeholderFeedback"] = "Önerilerini buraya\nyazabilirsin."
    translationData["openURLQuestion"] = "Bu bağlantı sizi uygulama dışına, aşağıdaki adrese yönlendirecek."
    translationData["openURLConfirm"] = "Onayla"
    translationData["openURLDeny"] = "Vazgeç"
    translationData["languageNotificationInformation"] = "Ayarlar ekranından dil tercihinizi değiştirebilir, oyunu İngilizce oynayabilirsiniz."
    translationData["languageNotificationConfirm"] = "Ayarlar'a git"
    translationData["languageNotificationDeny"] = "Tamam"
    translationData["score"] = "Puan"
    translationData["highScore"] = "Rekor!"
    translationData["developedBy"] = "Geliştirici"
    translationData["testedBy"] = "Test"
    translationData["serverSideBy"] = "Backend"
    translationData["prev04"] = "v0.4 öncesi"
    translationData["music"] = "Müzik"
    translationData["soundFX"] = "Ses efektleri"
    translationData["font"] = "Yazı tipi"
    translationData["shortenedUse"] = "(kısaltılmış sürümdür.)"
    translationData["disclaimerSoundLicense"] = "Bu oyundaki müzik ve ses efektleri farklı lisanslarla koruma altındadır. Daha fazla bilgi için ilgili siteleri ziyaret edin."
    translationData["disclaimerFont"] = "SIL Open Font License version 1.1. Daha fazla bilgi için https://scripts.sil.org/OFL adresini ziyaret edin."
    translationData["disclaimerCopyright"] = "Tüm ticari markalar, logolar ve marka isimleri ilgili sahiplerine aittir."
    translationData["poweredBy"] = "Oyun motoru"
    translationData["sendSupportMailSubject"] = "Öneri - OpenBilgi"
    translationData["sendSupportMailVersionInformation"] = "Sürüm bilgisi"
    translationData["sendSupportMailBody"] = "Mesajınızı buraya yazabilirsiniz."

    return translationData
end

return translationSetup