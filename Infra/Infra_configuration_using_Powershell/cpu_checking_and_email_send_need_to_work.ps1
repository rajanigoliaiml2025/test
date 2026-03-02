$CPUThreshold = 90
$SMTPServer = "smtp.yourserver.com"    # e.g., smtp.office365.com
$To = "admin@example.com"
$From = "monitoring@example.com"

# Check CPU Load
$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

if ($cpu -gt $CPUThreshold) {
    $body = "Warning: High CPU usage detected on $(hostname). Current load: $cpu%"
    
    # Sending email (Requires valid SMTP server configuration)
    Send-MailMessage -To $To -From $From -Subject "High CPU Alert" -Body $body -SmtpServer $SMTPServer -Port 587 -UseSsl
}