@echo off
REM 日付
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
 set year=%%i
 set month=%%j
 set day=%%k
)
REM 時間
set time_tmp=%time: =0%
set hh=%time_tmp:~0,2%
set mi=%time_tmp:~3,2%
set ss=%time_tmp:~6,2%
set sss=%time_tmp:~9,2%

echo %year%
echo %month%
echo %day%
set datestr=%year%_%month%_%day%
echo datestr is %datestr%

set datetimestr=%year%%month%%day%_%hh%%mi%%ss%%sss%
echo datetimestr = %datetimestr%
