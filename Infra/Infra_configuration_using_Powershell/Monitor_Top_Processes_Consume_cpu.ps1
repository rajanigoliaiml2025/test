<#

Monitor Top Processes by CPU Usage 
This script displays the top 10 processes consuming the most CPU at this exact moment:

#>

Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 -Property Name, CPU, Id
