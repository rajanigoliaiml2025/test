<#
Get Hardware Specifications (Cores & Threads) 
To see how many physical cores and logical processors (threads) your CPU has:


#>

Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
