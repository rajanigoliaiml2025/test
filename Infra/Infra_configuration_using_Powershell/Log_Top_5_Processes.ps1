Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | 
    Select-Object @{Name="Time";Expression={(Get-Date)}}, Name, CPU, Id | 
    Export-Csv -Path "$HOME\Desktop\Process_Log.csv" -Append -NoTypeInformation
