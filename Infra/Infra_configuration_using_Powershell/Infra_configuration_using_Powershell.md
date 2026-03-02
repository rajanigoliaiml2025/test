# ############## Infra_configuration_using_Powershell ###################

PowerShell is a cross-platform task automation solution consisting of a command-line shell, a scripting language, and a configuration management framework. Unlike traditional shells that process text, PowerShell is built on the .NET Framework and handles objects, allowing for sophisticated data manipulation and seamless integration with system resources.

# ################### Core Components ########################
Cmdlets (Command-lets): Specialized .NET classes appearing as native commands in the format Verb-Noun (e.g., Get-Service, Stop-Process).
Pipelines: The | operator passes complete objects—not just text—from one cmdlet to another, enabling complex workflows with minimal code.
Scripts: Plain-text files with a .ps1 extension containing a series of commands for automation.
Variables: Identified by the $ prefix (e.g., $MyVariable), they store strings, numbers, or complex objects and are case-insensitive.


# ###################  Setting Up Your Environment ###############
Tools: Use Visual Studio Code with the PowerShell extension for the best development experience. Alternatively, use the built-in PowerShell ISE (Windows-only, legacy).
Execution Policy: By default, Windows prevents script execution for security. To enable it for your local scripts, run PowerShell as Administrator and use:

Set-ExecutionPolicy RemoteSigned

This allows local scripts to run while requiring remote scripts to be digitally signed.


# ################ Basic Scripting Concepts ##############
Control Flow: Supports standard logic like if/else, foreach loops for collections, and try/catch for error handling.
Comparison Operators: Uses unique flags instead of symbols: -eq (equals), -ne (not equals), -gt (greater than), and -lt (less than).
Discovery: Use Get-Help to see documentation, Get-Command to find cmdlets, and Get-Member to inspect an object's properties and methods.


# ################ Common Use Cases ##########
System Administration: Managing Active Directory, Exchange, and IIS.
Cloud Management: Automating resources in Azure and AWS.
Configuration: Using Desired State Configuration (DSC) to enforce system settings as code.# #

# ########### Here are two essential starter scripts for common administrative tasks in PowerShell.
1. Bulk File Renaming
This script adds a "Backup_" prefix to all .txt files in a specific folder. It uses the ( ) grouping operator to "freeze" the file list, preventing the script from renaming the same file multiple times. 


# Define the target folder
$path = "C:\YourFolder\Path"

# Get files and rename them with a prefix
# The parentheses around Get-ChildItem ensure the list is loaded before renaming starts
(Get-ChildItem -Path $path -Filter *.txt) | ForEach-Object {
    $newName = "Backup_" + $_.Name
    Rename-Item -Path $_.FullName -NewName $newName -WhatIf
}


Tip: I included the -WhatIf parameter so you can test it safely. Remove it to actually rename the files.
Alternative: To replace text within filenames (e.g., changing "Old" to "New"), use:
Get-ChildItem | Rename-Item -NewName { $_.Name -replace 'Old','New' }.


2. System Health Monitoring
This script provides a quick snapshot of CPU, Memory, and Disk usage. It calculates the percentage of used RAM based on the total visible memory.

# Get CPU Load
$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

# Get Memory Usage
$os = Get-CimInstance Win32_OperatingSystem
$totalRAM = $os.TotalVisibleMemorySize
$freeRAM = $os.FreePhysicalMemory
$usedRAMPercent = [Math]::Round((($totalRAM - $freeRAM) / $totalRAM) * 100, 2)

# Get Disk Usage (C: Drive)
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeDiskGB = [Math]::Round($disk.FreeSpace / 1GB, 2)

# Output Results
Write-Host "--- System Health Report ---" -ForegroundColor Cyan
Write-Host "CPU Usage:      $cpu%"
Write-Host "RAM Usage:      $usedRAMPercent%"
Write-Host "Free Disk (C:): $freeDiskGB GB"


Customization: You can wrap this in a while($true) loop with Start-Sleep -Seconds 5 to create a live dashboard.
Verification: Use the Microsoft Learn Documentation for Get-CimInstance to find additional system properties you can monitor.


2. System Health with Email Alerts
To send alerts, use the Send-MailMessage cmdlet (note: legacy/obsolete for some secure modern environments) or modern

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
