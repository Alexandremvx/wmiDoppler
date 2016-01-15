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
 $titulo = "Wmi-Doppler"
 $sim = New-Object System.Management.Automation.Host.ChoiceDescription "&Sim", "Sim"
 $nao = New-Object System.Management.Automation.Host.ChoiceDescription "&Não", "Não"
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

foreach ($c in $cred) {
$ses =  New-PSSession -ComputerName 192.168.0.9 -Credential $c -ErrorVariable ssErr -ErrorAction SilentlyContinue
if ($ses) {
 return $ses
} elseif($($ssErr[0].Exception.ErrorCode) -ne 5) {
 Write-Warning "servidor não acessivel"
 return $null
}
}

Write-Warning "    check/alter credentials (if err)"
Write-Warning "list targets"
Write-Warning "check if can reach without jump (wmi)"
Write-Warning "   check jumps acess target (if err)"
Write-Warning "runs wmi command and store exit"
