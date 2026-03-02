<# 

1. Check Real-Time CPU Usage
2. To get the current overall CPU load percentage (average across all cores), use: 

Note: Get-CimInstance is the modern replacement for the older Get-WmiObject

#>

Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage


