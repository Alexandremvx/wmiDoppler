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

function read-list{param([parameter(mandatory=$true)][String[]]${@})if(${@}){return ${@}}}


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
  select Username,Domain,@{N="SecurePassword";E={$_.securepassword | ConvertFrom-SecureString -Key (16..31)}} |
   ConvertTo-Csv -Delimiter ";" -NoTypeInformation |
    Out-File -FilePath $csvFile -Append 
}

function Load-AuthCsv($csvFile="Credentials.csv"){
 if (-not $(ls $csvFile)) { Write-Warning "Arquivo não encontrado $csvFile"; return $null}
 $csvPass = cat $csvFile | Convertfrom-Csv -Delimiter ";"
 $csvAuth = $csvPass | % { New-Object System.Management.Automation.PSCredential ("$($_.domain)\$($_.Username)",$($_.SecurePassword | ConvertTo-SecureString -Key (16..31))) }
 return $csvAuth
}


## JUMPER LIST MANAGEMENT FUNCTIONS ##
function Read-JumperList(){
 $jumps = @()
 do{
  $jump = Read-Host -Prompt "Jumper"
  if ($jump) {$jumps+= $jump}
 }while($jump)
 if ($jumps.length -eq 0) {
  Write-Warning "Nenhum servidor fornecido"
  return $null
 }else{
  return $jumps
 }
}

function Save-JumperFile($Jumps, $jumpFile="Jumps.txt"){
 $Jumps | Out-File -FilePath $jumpFile -Append
}

function Load-JumperFile($jumpFile="Jumps.txt"){
 #$jumps = @()
 if (-not $(ls $jumpFile)) { Write-Warning "Arquivo não encontrado $jumpFile"; return $null}
 $jumps = cat $jumpFile
 return $jumps
}


## JUMPER SESSIONS FUNCTIONS ##
function create-JumpSessions($Jumps,$Auth){
 if (-not $Jumps -and -not $Auth) {Write-Warning 'create-JumpSessions <JumpList> <AuthList>'; return $null}
 $Sess = @()
 foreach ($j in $Jumps) {
  foreach ($a in $auth) {
   $s = New-PSSession -Name "$($a.username)@$j" -ComputerName $j -Credential $a -ErrorVariable sErr
   if ($s) {
    $Sess += $s
    break
   }elseif($($sErr[0].Exception.ErrorCode) -ne 5){
    Write-Warning "Servidor de Jump inacessivel [$j]"
    break
   }
  }
  if (-not $s -and $($sErr[0].Exception.ErrorCode) -eq 5) {Write-Warning "Servidor de Jump sem credenciais válidas [$j]"}
 }
 if ($Sess.length -eq 0) {
  Write-Warning "Nenhuma sessão criada."
  return $null
 }else{
  return $Sess
 }
}


## TARGET HOSTS FUNCTIONS ##
function Save-TargetList($Targets, $TargetList="Hosts.txt"){
 $Targets | Out-File -FilePath $TargetList -Append
}

function Load-TargetList($TargetList="Hosts.txt"){
 #$jumps = @()
 if (-not $(ls $TargetList)) { Write-Warning "Arquivo não encontrado $TargetList"; return $null}
 $Targets = cat $TargetList
 return $Targets
}
