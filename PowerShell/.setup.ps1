Get-Item -Path $profile | Remove-Item -Force -WhatIf -ErrorAction SilentlyContinue
( pwsh -Command 'Get-Item -Path $profile' ) | Remove-Item -Force -WhatIf -ErrorAction SilentlyContinue
