<#
 Continuous "Live" CPU Monitor (Script) 
If you want a loop that updates every few seconds to track fluctuations, use this script:
#>

while ($true) {
    Clear-Host
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    Write-Host "Current CPU Usage: $([math]::Round($cpuUsage, 2))%" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
