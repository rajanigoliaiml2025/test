# Define the file path
$filePath = "$HOME\Desktop\CPU_Log.csv"

Write-Host "Logging CPU usage to $filePath. Press Ctrl+C to stop." -ForegroundColor Cyan

while ($true) {
    # Get current timestamp and CPU load
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuLoad = (Get-CimInstance Win32_Processor).LoadPercentage

    # Create a custom object to represent the row
    $logEntry = [PSCustomObject]@{
        Time    = $timestamp
        CPU_Load_Percent = $cpuLoad
    }

    # Append the object to the CSV file
    $logEntry | Export-Csv -Path $filePath -Append -NoTypeInformation

    # Wait before the next sample
    Start-Sleep -Seconds 5
}
