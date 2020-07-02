@{
            Severity     = @(
                'Information',
                'Warning',
                'Error'
            )
            IncludeRules = @()
            ExcludeRules = @(
                'PSAvoidUsingConvertToSecureStringWithPlainText',
                'PSAvoidUsingInvokeExpression',
                'PSAvoidUsingPlainTextForPassword',
                'PSAvoidUsingUsernameAndPasswordParams',
                'PSAvoidUsingWriteHost',
                'PSUseShouldProcessForStateChangingFunctions'
            )
            Rules        = @{
                # Rules that are added to the default set of tests, or support custom configuration
                PSAlignAssignmentStatement = @{
                    Enable         = $true
                    CheckHashtable = $true
                }
                PSAvoidLongLines           = @{
                    Enable     = $true
                    LineLength = 115
                }
                PSAvoidUsingCmdletAliases  = @{
                    Whitelist = @()
                }
                PSPlaceCloseBrace          = @{
                    Enable             = $true
                    NoEmptyLineBefore  = $true
                    IgnoreOneLineBlock = $true
                    NewLineAfter       = $true
                }
                PSPlaceOpenBrace           = @{
                    Enable             = $true
                    OnSameLine         = $true
                    NewLineAfter       = $true
                    IgnoreOneLineBlock = $true
                }
                PSProvideCommentHelp       = @{
                    Enable                  = $true
                    ExportedOnly            = $false
                    BlockComment            = $true
                    VSCodeSnippetCorrection = $false
                    Placement               = "before"
                }
                PSUseConsistentIndentation = @{
                    # Doesn't handle parens mixed with pipeline/backtick indentation well
                    Enable              = $false
                    IndentationSize     = 4
                    PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
                    Kind                = 'space'
                }
                PSUseConsistentWhitespace  = @{
                    Enable                          = $true
                    CheckInnerBrace                 = $true
                    CheckOpenBrace                  = $false
                    CheckOpenParen                  = $true
                    CheckOperator                   = $false
                    CheckPipe                       = $true
                    CheckPipeForRedundantWhitespace = $true
                    CheckSeparator                  = $true
                    CheckParameter                  = $false
                }
            }
        }