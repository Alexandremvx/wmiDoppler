<#
Wmi-Doppler = sends wmi command accros network using remote sessions when needed to reach the target machine

list jumps
create session
    check/alter credentials (if err)
list targets
check if can reach without jump (wmi)
    check jumps acess target (if err)
runs wmi command and store exit

#>

#if (-not $PSScriptRoot) {$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition}
function promptSN($msg) {
 $titulo = "CreateADUser"
 $sim = New-Object System.Management.Automation.Host.ChoiceDescription "&Sim", "Sim / Yes"
 $nao = New-Object System.Management.Automation.Host.ChoiceDescription "&Não", "Não / No"
 $options = [System.Management.Automation.Host.ChoiceDescription[]]($nao,$sim)
 $result = $host.ui.PromptForChoice($titulo, $msg, $options,0) 
 switch ($result){
  1 {return $true}
  0 {return $false}
 }
}
function read-list{param([parameter(mandatory=$true)][String[]]${@}) return ${@}}

Write-Warning " # # # list jumps # # # "
$wJumps = @{filename="jumps.txt"}
if ($wJumps.filename){
  if (ls $wJumps.filename -ErrorAction SilentlyContinue){ 
    $wJumps.file = cat $wJumps.filename; $wJumps.filestr = $wJumps.file -join "`n"
    if (promptSN "usar os seguintes jumps?`n$($wJumps.filestr) ") {$wJumps.machines = $wJumps.file }
  }else{
    echo "Arquivo '$($wJumps.filename)' não encontrado."
  }
}

if (promptSN ""){}

Write-Warning "create session"
Write-Warning "    check/alter credentials (if err)"
Write-Warning "list targets"
Write-Warning "check if can reach without jump (wmi)"
Write-Warning "   check jumps acess target (if err)"
Write-Warning "runs wmi command and store exit"
