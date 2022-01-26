# The language used by the user has been changed to Japanese
Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force
# The language entered by the user has been changed to Japanese(InputMethodTips : Get-WinUserLanguageList{0411:{03B5835F-F03C-411B-9CE2-AA23E1171E36}{A76C93D9-5523-4E90-AAFA-4DB112F9AC76}})
Set-WinDefaultInputMethodOverride -InputTip "0411:00000411"
# MS-IME input method settings
Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar
# Reboot
#Restart-Computer -Force
