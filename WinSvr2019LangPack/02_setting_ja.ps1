# Overwrite UI language with Japanese
Set-WinUILanguageOverride -Language ja-JP
# Same time / date format as Windows language
Set-WinCultureFromLanguageListOptOut -OptOut $False
# Location setting Japan
# Get-WinHomeLocation
# GeoId HomeLocation Hex
# ----- ------------ ------
# 122 japan            0x7A
Set-WinHomeLocation -GeoId 0x7A
# System locale japan.
Set-WinSystemLocale -SystemLocale ja-JP
# Time zone is Tokyo
Set-TimeZone -Id "Tokyo Standard Time"
# Reboot
# Restart-Computer
