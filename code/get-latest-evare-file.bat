echo off

:: usage get-latest-evare-file.bat PershingIPCPrice
:: usage get-latest-evare-file.bat ComericaIPCPrice
:: usage get-latest-evare-file.bat WFAIPCPrice

::-----------------------------
:: First Set the main variables
Set AppDir=c:\Batches\AutomationProjects\PriceComparison\code
Set DestDir=c:\Batches\AutomationProjects\PriceComparison\get-destination

echo AppDir set to: %AppDir%
echo DestDir set to: %DestDir%

::---------------------------------------
:: Get today's date in 8 character format
set datetoday8=%date:~10,4%%date:~4,2%%date:~7,2%

	:: ====================
	:: For testing only
	::set datetoday8=20150420
	:: ====================
echo Today in 8 characters is %datetoday8%

::-------------------------------------------
:: Get yesterday's date in 8 character format
echo off
call"%AppDir%\get-yesterday-date8.bat">>"%AppDir%\tmpFile.txt"
FOR /F "tokens=* USEBACKQ" %%F IN ("%AppDir%\tmpFile.txt") DO (
SET dateyesterday8=%%F
)
del "%AppDir%\tmpFile.txt"

ECHO info: yesterday was %dateyesterday8%


::-----------------------------------------------------------------
:: Copy all files with certain prefixe in dest directory to archive
copy "%DestDir%\%1*.csv" "%DestDir%\archive"

::-------------------------------------------------------------------
:: Delete all files with certain prefixe in dest directory to archive
del "%DestDir%\"%1*.csv"

::---------------------------------------------
:: run batch file to GET the data file from FTP
call "%AppDir%\ftp_get_file_from_sscgateway_usr_ssc519_evare.bat" "%1%datetoday8%*.csv" "%DestDir%"

echo waiting 3 secs to ensure ftp completes...
PING 1.1.1.1 -n 1 -w 3000 >NUL

::-------------------------------------------------
:: check whether todays file was retrieved properly
if exist %DestDir%\%1%datetoday8%*.csv (
    echo success: today's file %1%datetoday8%*.csv was retrieved successfully
    goto success_exit
) else (
    echo fail: Today's file %1%datetoday8%*.csv was not retrieved
    goto fail_ftp
)

::::----------------------------------------------------------
::echo test: Checking if yesterdays file was archived properly
::echo test: "%DestDir%\archive\%1%dateyesterday8%*.txt"
::
::::-----------------------------------------------------
:::: check whether yesterday's file was archived properly
::if exist "%DestDir%\archive\%1%dateyesterday8%*.txt" (
::    echo success: yesterday's file was archived properly.  
::) else (
::    echo fail: yesterday file was not archived properly
::)
::
::if exist "%DestDir%\%1%dateyesterday8%*.txt" (
::    del "%DestDir%\%1%dateyesterday8%*.txt"
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
echo Exited for failing to retrieve %1%datetoday8%.csv from FTP site

::--------------------
:: Exit on success
:success_exit