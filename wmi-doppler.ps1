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


## GENERIC FUNCTIONS ##
function promptSN($msg,$def=0) {
 $titulo = "Wmi-Doppler"
 $sim = New-Object System.Management.Automation.Host.ChoiceDescription "&Sim", "Sim"
 $nao = New-Object System.Management.Automation.Host.ChoiceDescription "&Não", "Não"
 $options = [System.Management.Automation.Host.ChoiceDescription[]]($nao,$sim)
 $result = $host.ui.PromptForChoice($titulo, $msg, $options,$def) 
 switch ($result){
  1 {return $true}
  0 {return $false}
 }
}
function read-list{param([parameter(mandatory=$true)][String[]]${@}) return ${@}}


## AUTH MANAGEMENT FUNCTIONS ##
function Read-AuthList(){
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

function Save-AuthCsv($Auth, $csvFile="Credentials.csv"){
 $Auth.getnetworkcredential() |
  select Username,Domain,@{N="SecurePassword";E={$_.securepassword | ConvertFrom-SecureString}} |
   ConvertTo-Csv -Delimiter ";" -NoTypeInformation |
    Out-File -FilePath $csvFile -Append 
}

function Load-AuthCsv($csvFile="Credentials.csv"){
 $creds = @()
 if (-not $(ls $csvFile)) { Write-Warning "Arquivo não encontrado $csvFile"; return $null}
 $csvPass = cat $csvFile | Convertfrom-Csv -Delimiter ";"
 $csvAuth = $csvPass | % { New-Object System.Management.Automation.PSCredential ("$($_.domain)\$($_.Username)",$($_.SecurePassword | ConvertTo-SecureString)) }
 return $csvAuth
}


## JUMPER LIST MANAGEMENT FUNCTIONS ##
function Read-JumperList(){
 $jumps = @()
 do{
  $jump = Read-Host -Prompt "Jumper"
  if ($jump) {    $jumps += $jump   }
 }while($jump)
 if ($jumps.length -eq 0) {
  Write-Warning "Nenhum servidor fornecido"
  return $null
 }else{
  return $jumps
 }
}

function Save-JumperFile($Jumps, $jumpFile="jumps.txt"){
 $Jumps | Out-File -FilePath $jumpFile -Append
}

function Load-JumperFile($jumpFile="jumps.txt"){
 #$jumps = @()
 if (-not $(ls $jumpFile)) { Write-Warning "Arquivo não encontrado $jumpFile"; return $null}
 $jumps = cat $jumpFile
 return $jumps
}

## JUMPER SESSIONS FUNCTIONS ##
function create-JumpSessions($Jumps,$Auth){
 $Sess = @()
 foreach ($j in $Jumps) {
  foreach ($a in $auth) {
   $s = New-PSSession -Name "******" -ComputerName $j -Credential $a -ErrorVariable sErr
   if ($s) {
    $Sess += $s
    break
   }elseif($($sErr[0].Exception.ErrorCode) -ne 5){
    Write-Warning "Servidor de Jump inacessivel [$j]"
    break
   }
  }
 }
 if ($Sess.length -eq 0) {
  Write-Warning "Nenhuma sessão criada."
  return $null
 }else{
  return $Sess
 }
}



Write-Warning " # # # list jumps # # # "
$wJumps = @{filename="jumps.txt"}
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

function Save-AuthCsv($Auth, $csvFile){
 $Auth.getnetworkcredential() | select Username,Domain,@{N="SecurePassword";E={$_.securepassword | ConvertFrom-SecureString}} | ConvertTo-Csv | Out-File -FilePath "WMI-credentials.csv"
}

