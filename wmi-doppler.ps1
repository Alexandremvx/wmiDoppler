<#
Wmi-Doppler = sends wmi command accross the network using remote sessions when needed to reach the target machine
list jumps
create session
    check/alter credentials (if err)
list targets
check if can reach without jump (wmi)
    check jumps acess target (if err)
runs wmi command and store exit
#>

#if (-not $PSScriptRoot) {$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition}

## GLOBAL VARIABLES ##
$ErrorActionPreference = "Silentlycontinue"
$logfile = ".\wmi_log.log"

## LOAD FUNCTIONS LIB ##
. .\lib-doppler.ps1 #Caminho do arquivos de funções


Write-Warning " # # # load-files # # # "
 $wAuth = Load-AuthCsv
 $wJumps = Load-JumperFile
 $wTargets = Load-TargetList


Write-Warning " # # # create session # # #"

 $wSessions = create-JumpSessions $wJumps $wAuth


Write-Warning " # # # check target connectivity and call job by session # # # "
 
 $wJobs = @()


$reportFile = "report.csv"
if (-not (ls $reportFile -ErrorAction SilentlyContinue)) {
 Write-Output "HOSTNAME;CONFIGURAÇÃO HV;TIME ZONE;DLBIAS;DATA ATUAL;HORA ATUAL;DIFERENÇA EM MINUTOS;INÍCIO HV;TERMINHO HV" | Out-File $reportFile
}


 foreach ($target in $wTargets) {
  $targetJump = find-TargetJump $target $wSessions
  #if ((($wJobs | ? State -eq "Running").count) -ge 20){sleep -Milliseconds 500}
  $msg = if ($targetJump) { "@_ $target online via $($targetJump.computername)"} else { "X_ $target não acessivel"}
  $msg | Out-File -FilePath $logfile -Append
  echo $msg
  if (-not $targetJump) { "$target" | Out-File -FilePath ".\err_hosts.txt" -Append}
  if ($targetJump) {
   #$wJobs += Invoke-Command -Session $targetJump -ArgumentList $target,$wAuth -FilePath .\HV4.ps1 #-AsJob -JobName $target
            Invoke-Command -Session $targetJump -ArgumentList $target,$wAuth -FilePath .\HV4.ps1 | % {$_ | Out-File $reportFile -Append}
   #Invoke-Command -Session $targetJump -ArgumentList $target,$wAuth -FilePath .\HV4.ps1
  }
 }

#if ((($wJobs | ? State -eq "Running").count) -ge 1){sleep -Milliseconds 500}

Write-Warning " # # # wait jobs finish and save report # # # "
#$wJobs #| Out-File $reportFile -Append

 #if ((($wJobs | ? State -eq "Running").count) -gt 0){sleep -Milliseconds 500}

# Receive-Job $wJobs | Receive-Job #| Out-File -FilePath "WMI_report.csv"

#return $null

