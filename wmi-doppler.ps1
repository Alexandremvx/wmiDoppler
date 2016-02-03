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
$ErrorActionPreference = "Continue"#"silentlycontinue"
$ErrorActionPreference = "Silentlycontinue"

## LOAD FUNCTIONS LIB ##
. .\lib-doppler.ps1 #Caminho do arquivos de funções



Write-Warning " # # # load-files # # # "
 $wAuth = Load-AuthCsv
 $wJumps = Load-JumperFile
 $wTargets = Load-TargetList

Write-Warning " # # # create session # # #"

 $wSessions = create-JumpSessions $wJumps $wAuth

Write-Warning " # # # check target connectivity # # # "
 
 foreach ($target in $wTargets) {
  
  $targetJump = find-TargetJump $target $wSessions
 
  if ($targetJump) { echo "@_ $target online via $($tj.computername)"} else { echo "X_ $target não acessivel"}

 }



return "noop"


foreach ($t in $wTarget) {
 $TargetJob = @{Auth = $wAuth;Sessions=$wSessions;tName=$t}
 $wJobs += Start-Job -Name $t -ArgumentList $TargetJob -ScriptBlock {
  $wAuth = $args[0].Auth;$wSessions=$args[0].Sessions;$t=$args[0].tName
  foreach ($ws in $wSessions){
   $ws
   $ping = new-object system.net.networkinformation.ping
   $ping.Send($t)
  
  
  }


 }
}


Write-Warning "   check jumps acess target (if err)"
Write-Warning "runs wmi command and store exit"

