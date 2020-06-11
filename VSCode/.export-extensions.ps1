Start-Process `
    -FilePath code `
    -ArgumentList '--list-extensions' `
    -RedirectStandardOutput "$PSScriptRoot\.extensions" `
    -NoNewWindow `
    -Wait
