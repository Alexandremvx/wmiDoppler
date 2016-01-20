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
$ErrorActionPreference = "silentlycontinue"


## LOAD FUNCTIONS LIB ##
. .\lib-doppler.ps1


Write-Warning " # # # list jumps # # # "
$wJumps = @{filename_="jumps.txt"}
if ($wJumps.filename){
  if (ls $wJumps.filename -ErrorAction SilentlyContinue){ 
    $wJumps.file = cat $wJumps.filename; $wJumps.filestr = $wJumps.file -join "`n"
    if (promptSN "usar os seguintes jumps?`n$($wJumps.filestr) " 1) {$wJumps.machines = $wJumps.file }
  }else{
    echo "Arquivo '$($wJumps.filename)' não encontrado."
  }
}

if ($wJumps.machines) {$wJumps.machines}



Write-Warning "create session"
Write-Warning "    check/alter credentials (if err)"
Write-Warning "list targets"
Write-Warning "check if can reach without jump (wmi)"
Write-Warning "   check jumps acess target (if err)"
Write-Warning "runs wmi command and store exit"





Write-Warning "teste area"
function Read-AuthList(){
 #http://blogs.msdn.com/b/koteshb/archive/2010/02/13/powershell-creating-a-pscredential-object.aspx
 $creds = @()
 
 do{
  $cUser = Read-Host -Prompt "User"
  if ($cUser) {
   $cPass = Read-Host -AsSecureString -Prompt "Pass [$cUser]"
   $creds += New-Object System.Management.Automation.PSCredential ($cUser,$cPass)
  }
 }while($cUser)

 if ($creds.length -eq 0) {
  Write-Warning "Nenhuma credencial fornecida"
  return $null
 }else{
  return $creds
 }
}
