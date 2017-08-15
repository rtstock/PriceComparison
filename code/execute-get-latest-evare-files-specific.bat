::  This gets all files needed
::  set %1 = to the 8 character date on the evare filename
call C:\Batches\AutomationProjects\PriceComparison\code\get-latest-evare-file-specific.bat PershingIPCPrice %1
call C:\Batches\AutomationProjects\PriceComparison\code\get-latest-evare-file-specific.bat ComericaIPCPrice %1
call C:\Batches\AutomationProjects\PriceComparison\code\get-latest-evare-file-specific.bat WFAIPCPrice %1
:: don't run this call E:\DATA\Batches\development\projects\Price_Comparison\code\get-file-Price_Comparison.bat
