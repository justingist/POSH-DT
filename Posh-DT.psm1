$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

Function Save-DTConfig {
Param([parameter(Mandatory=$false)]$pscredential,
        [parameter(Mandatory=$true)]$dturl,
        [parameter(Mandatory=$true)]$apikeyname)
    if (-not($pscredential)){$pscredential = get-credential -Message 'Enter API Key as Password' -UserName $apikeyname}

    $saveable = [pscustomobject]@{'url' = $dturl ; 'username'=$pscredential.UserName;'password'= ($pscredential.Password | ConvertFrom-SecureString)}
    $identifiername = (($dturl | Select-String -Pattern 'https:\/\/(\w+)' -AllMatches).Matches.Groups[1].Value) + $apikeyname
    $saveable | ConvertTo-Json | Out-File ~\Documents\DTLogin.$identifiername.json

}

Function Load-DTConfig {
Param([parameter(Mandatory=$true)]$dturl,
        [parameter(Mandatory=$true)]$apikeyname)

    if ($dturl -match 'http'){
        $identifiername = (($dturl | Select-String -Pattern 'https:\/\/(\w+)' -AllMatches).Matches.Groups[1].Value) + $apikeyname
    }else{
        $identifiername = $dturl + $apikeyname
    }
    $baseinfo = get-content  ~\Documents\DTLogin.$identifiername.json | ConvertFrom-Json
    $baseinfo.Password = ($baseinfo.Password | ConvertTo-SecureString)
    $dtcreds = New-Object System.Management.Automation.PSCredential ($baseinfo.url, $baseinfo.password)
    $dtcreds 
}

Function Write-DTLog  {
Param([parameter(Mandatory=$true)]$message,
      [parameter(Mandatory=$true)][ValidateSet("Failure","Error","Alert","Critical","Severe","Warning","Notice","Information","Debug","Verbose")]$level,
        [parameter(Mandatory=$false)]$dturl,
        [parameter(Mandatory=$true)]$apikeyname)


$dtconfig = Load-DTConfig -dturl $dturl -apikeyname $apikeyname
$logkey = $dtconfig.GetNetworkCredential().Password

$headersdtlog = [ordered]@{
    "Authorization" = "Api-Token $logkey"
}
$loguri = ($dtconfig.username -replace '\/$','') +"/api/v2/logs/ingest"

Write-Host $loguri

    $logmessage = [pscustomobject]@{'content' = $message
                                    'status' = $level
                                    'log.source' = $PSScriptRoot
                                    'dt.entity.host' = hostname
                                    'dt.source_entity' = 'api.smartthings.com'
                                    'service.name' = 'powershell-smartthings-ingest'
                                    'service.namespace' = 'justin-ps-lab' } | ConvertTo-Json

    Invoke-RestMethod -Uri $loguri -Headers $headersdtlog -ContentType 'application/json; charset=utf-8' -Method Post -Body $logmessage
    write-host "DTLOG.$level : $message"
}
