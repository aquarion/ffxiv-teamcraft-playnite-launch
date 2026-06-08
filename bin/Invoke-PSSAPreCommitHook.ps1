#!/usr/bin/env pwsh
$ScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path . -Recurse

if ($null -ne $ScriptAnalyzerResults) {
    foreach ($BrokenRule in $ScriptAnalyzerResults) {
        throw "$($BrokenRule.RuleName) | SEVERITY:$($BrokenRule.Severity) | ScriptPath:$($BrokenRule.ScriptPath) | Message:$($BrokenRule.Message)"
    }
}
