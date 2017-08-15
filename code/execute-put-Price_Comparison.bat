echo off

:: usage get-latest-evare-file.bat PershingIPCPrice
:: usage get-latest-evare-file.bat ComericaIPCPrice
:: usage get-latest-evare-file.bat WFAIPCPrice
:: %SourceDir%\Price_Comparison.csv


::---------------------------------------
:: Get today's date in 8 character format
set datetoday8=%date:~10,4%%date:~4,2%%date:~7,2%

	:: ====================
	:: For testing only
	::set datetoday8=20150420
	:: ====================
echo Today in 8 characters is %datetoday8%

::-----------------------------
:: First Set the main variables
Set AppDir=D:\ClientData\Commands\projects\price_comparison\code
Set SourceDir="\\SSC519CIT2\PagesNetwork\Docs\ssc519pages_692\Price_Comparison\DOC\Price_Comparison"

echo AppDir set to: %AppDir%
echo SourceDir set to: %SourceDir%


::-------------------------------------------
:: Get yesterday's date in 8 character format
echo off
call"%AppDir%\get-yesterday-date8.bat">>"%AppDir%\tmpFile.txt"
FOR /F "tokens=* USEBACKQ" %%F IN ("%AppDir%\tmpFile.txt") DO (
SET dateyesterday8=%%F
)
echo deleting tmpfile.txt...
del "%AppDir%\tmpFile.txt"

ECHO info: yesterday was %dateyesterday8%


::---------------------------------------------
:: run batch file to GET the data file from FTP
call "%AppDir%\ftp_put_file_from_sscgateway_usr_ssc519_evare.bat" %SourceDir%\Price_Comparison-*.csv %SourceDir%

echo waiting 3 secs to ensure ftp completes...
PING 1.1.1.1 -n 1 -w 3000 >NUL

