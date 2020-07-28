Install-WindowsUpdate -MicrosoftUpdate -AcceptAll |
    Select-Object -Property KB, Title, Description, SupportUrl
