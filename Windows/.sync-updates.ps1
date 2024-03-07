Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot |
    Select-Object -Property Result, KB, Title

Get-WURebootStatus
