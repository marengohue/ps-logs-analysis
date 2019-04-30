function Get-UserFromPath
{
    param([string]$Path)
    $userNamePattern = [regex]"\\Printcom\\(?<userName>.+)\\Jobs\\"
    $Path | Select-String -Pattern $userNamePattern | ForEach-Object { $_.Matches.Captures.Groups["userName"] }
}

# Couldn't think of a better verb than "Ensure"
function Ensure-LogSource
{
    param([string]$Source)
    $log = Get-EventLog -LogName Application -Source $Source -ErrorAction SilentlyContinue
    if ($null -eq $log)
    {
        New-EventLog -LogName Application -Source $Source
    }
}

function Write-MatchToEventLog
{
    param(
        [string]$Message,
        [string]$LogSource
    )
    Ensure-LogSource -Source $LogSource
    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 13 -Message $Message
}

$saveEventPattern = [regex]"Kopien von \[(?<copyCount>[2-9]|1[0-2])\] ver"
$savedFilePattern = [regex]"Speichere Datei: (?<savedFilePath>.+);"

Get-ChildItem "./Logs/**/*.log" -Recurse |` # Among all the *.log files
    Select-String -Pattern $saveEventPattern |` # Find all matches with 2-12 copies
    ForEach-Object { # For each of the matches we further analyse the file

        $copyCount = $_.Matches.Captures.Groups["copyCount"]
        $logPath = $_.Path
        $operationUser = Get-UserFromPath -Path $logPath 
        $currentLineNo = $_.LineNumber

        Get-Content $logPath |` # We search this file again to grab the file path that was saved
            Select-String -Pattern $savedFilePattern |`
            Where-Object { $_.LineNumber -gt $currentLineNo } |`
            Select-Object -First 1 |` # Get the first path following after the save event 
            ForEach-Object {
                $savedFilePath = $_.Matches.Captures.Groups["savedFilePath"]
                $message = "Found save event with $($copyCount) copies. Saved file: $($savedFilePath). Event triggered by: $($operationUser)"
                Write-MatchToEventLog -LogSource "Log Analyzer" -Message $message
            }
    }