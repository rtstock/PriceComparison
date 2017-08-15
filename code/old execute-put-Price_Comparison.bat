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
Set SourceDir=\\SSC519CIT2\PagesNetwork\Docs\ssc519pages_692\Price_Comparison\DOC\Price_Comparison

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


::-----------------------------------------------------------------
:: Copy all files with certain prefixe in dest directory to archive
::copy "%SourceDir%\PershingIPCPrice*.csv" "%SourceDir%\archive"

::-------------------------------------------------------------------
:: Delete all files with certain prefixe in dest directory to archive
::del "%SourceDir%\"PershingIPCPrice*.csv"

::---------------------------------------------
:: run batch file to GET the data file from FTP
call "%AppDir%\ftp_put_file_from_sscgateway_usr_ssc519_evare.bat" "%SourceDir%\Price_Comparison-%datetoday8%.csv" "%SourceDir%"

echo waiting 3 secs to ensure ftp completes...
PING 1.1.1.1 -n 1 -w 3000 >NUL

::-------------------------------------------------
:: check whether todays file was retrieved properly
::if exist %SourceDir%\PershingIPCPrice%datetoday8%*.csv (
::    echo success: today's file PershingIPCPrice%datetoday8%*.csv was retrieved successfully
::    goto success_exit
::) else (
::    echo fail: Today's file PershingIPCPrice%datetoday8%*.csv was not retrieved
::    goto fail_ftp
::)

::::----------------------------------------------------------
::echo test: Checking if yesterdays file was archived properly
::echo test: "%SourceDir%\archive\PershingIPCPrice%dateyesterday8%*.txt"
::
::::-----------------------------------------------------
:::: check whether yesterday's file was archived properly
::if exist "%SourceDir%\archive\PershingIPCPrice%dateyesterday8%*.txt" (
::    echo success: yesterday's file was archived properly.  
::) else (
::    echo fail: yesterday file was not archived properly
::)
::
::if exist "%SourceDir%\PershingIPCPrice%dateyesterday8%*.txt" (
::    del "%SourceDir%\PershingIPCPrice%dateyesterday8%*.txt"
::) else (
::    echo info: No yesterday file to archive
::)

::::-------------------------------------------
:::: Executes sql file to load data to database
::sqlcmd -E -S IPC-VSQL01 -i "%AppDir%\AcctMaster.sql"
::goto success_exit

::--------------------
:: Exit on FTP failure
:fail_ftp
::echo Exited for failing to retrieve PershingIPCPrice%datetoday8%.csv from FTP site

::--------------------
:: Exit on success
:success_exit