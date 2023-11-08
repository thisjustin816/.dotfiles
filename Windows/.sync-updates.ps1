Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot |
    Select-Object -Property Result, KB, Title, Description |
    Sort-Object -Property KB -Unique

Get-WURebootStatus
