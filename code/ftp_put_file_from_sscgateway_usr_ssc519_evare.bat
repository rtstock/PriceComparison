::::::::::::::::::::::::::::::::::::::::::::::::
::  
::  Description
::      Gets the file in parameter(1) from SS&C's ftp server and places it into directory in parameter(2)
::
::  Usage:
::	get_file_from_sscgateway_usr_ssc519_ipc.bat <remotefilename> <localpath>
::
::  Author: Justin Malinchak
::
::::::::::::::::::::::::::::::::::::::::::::::::


@echo off
@echo open ftp.sscgateway.com> deletethis.txt
@echo ssc519>>deletethis.txt
@echo G2343DRTA>>deletethis.txt
::@echo cd /USR/SSC519/IPC>>deletethis.txt
@echo cd /usr/SSC519/EVARE>>deletethis.txt
::@echo ls>>deletethis.txt
@echo lcd %2 >> deletethis.txt
::@echo binary >> deletethis.txt
@echo put %1 >> deletethis.txt
@echo disconnect >> deletethis.txt
@echo bye >> deletethis.txt

ftp -v -i -s:deletethis.txt
del deletethis.txt