Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot |
    Select-Object -Property KB, Title, Description, SupportUrl |
    Sort-Object -Property KB -Unique
