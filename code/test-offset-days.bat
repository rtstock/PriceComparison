echo off

::---------------------------------------
:: Get today's date in 8 character format
set datetoday8=%date:~10,4%%date:~4,2%%date:~7,2%
set myoffset=%date:~7,2%
set myoffset=%myoffset%+1
for /f "delims=" %%a in ('get-offsetdays-date8.bat %myoffset%') do @set theValue=%%a
echo myoffset=%myoffset%
echo theValue=%theValue%


