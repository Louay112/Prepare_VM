
$Global:name = Read-Host -Prompt "Enter the client name"

$Global:username = "Username"   # change the username to anything

$Global:password = "P@ssw0rd#123"   # change the password to anything

$Global:kaliuser = "kali"


function CheckRunAsAdministrator {

    if (Get-Module -Name 7Zip4PowerShell -ListAvailable) {
        Write-Warning "7Zip4PowerShell module is installed."
 }  else {
    
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This script requires administrator privileges. Restarting with elevated privileges..."
        Start-Process -FilePath "powershell.exe" -ArgumentList "Install-Module -Name 7Zip4PowerShell -Force -Confirm:`$false" -Verb RunAs -Wait
    } else {
    
    Install-Module -Name 7Zip4PowerShell -Force -Confirm:$false
    
    }}
}


function CreateFolder{

New-Item -ItemType Directory -Path "C:\Users\$Env:UserName\Desktop\$Global:name" | Out-Null

}


function DownloadingKali{

$response = Invoke-WebRequest -Uri "https://www.kali.org/get-kali/#kali-virtual-machines"
$content = $response.Content
$regex = 'https://cdimage\.kali\.org/kali-\d+\.\d+/kali-linux-\d+\.\d+-vmware-amd64\.7z(?!.*\.torrent)'
$matches = [regex]::Matches($content, $regex)
$URL = $matches.Value

$Location = "C:\Users\$Env:UserName\Desktop\$Global:name\kali-linux.7z"

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFileAsync($URL, $Location)
$webClient.Dispose()

Write-Warning "If You Want to Kill The Download, Close Powershell or Kill The Process!!"

while ($webClient.IsBusy) {
    $progress = 0
    $retry = $true

    while ($retry) {
        try {
            if ($webClient.ResponseHeaders['Content-Length']) {
                $totalBytes = [long]$webClient.ResponseHeaders['Content-Length']
                $bytesDownloaded = (Get-Item $Location).Length
                $progress = [int]($bytesDownloaded / $totalBytes * 100)
            }
            $retry = $false
        }
        catch {
            Start-Sleep -Milliseconds 100
            $retry = $true
        }
    }
    
    Write-Progress -Activity "Downloading Kali Linux" -Status "$progress% complete" -PercentComplete $progress
    Start-Sleep -Milliseconds 100
}

Write-Progress -Activity "Downloading Kali Linux" -Status "Download complete" -PercentComplete 100 -Completed

if (Test-Path $Location) {
    Write-Warning "Kali downloaded successfully !!!"
    $Location2 = "C:\Users\$Env:UserName\Desktop\$Global:name\"
    Expand-7Zip -ArchiveFileName $Location -TargetPath $Location2
    Remove-Item $Location
    $folder = Get-ChildItem -Path $Location2 -Directory
    Rename-Item -Path "$Location2$folder" -NewName "$Global:name-Kali"
    $folder2 = Get-ChildItem -Path "$Location2$Global:name-Kali" -Filter *.vmx
    Rename-Item -Path "$Location2$Global:name-Kali\$folder2" -NewName "$Global:name-Kali.vmx"
    $folder3 = Get-ChildItem -Path "$Location2$Global:name-Kali" -Filter *.vmx
    $Global:LastNaming = "$Location2$Global:name-Kali\$folder3"
    $vmxContent = Get-Content -Path $Global:LastNaming
    $updatedContent = $vmxContent -replace 'displayName = ".*?"', "displayName = `"$Global:name`""
    Set-Content -Path $Global:LastNaming -Value $updatedContent
} else {
    Write-Warning "Failed to download the file."
    exit
}


}


function RunAPI{

Write-Warning "!!!! Don't Touch Keyboard and Mouse Till The Black CMD Closed !!!!"

$APILocation = "C:\Program Files (x86)\VMware\VMware Workstation\vmrest.exe"

$arg = "-C"

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Start-Process -FilePath $APILocation -ArgumentList $arg 

 
Start-Sleep -m 1000
 

[System.Windows.Forms.SendKeys]::SendWait($Global:username)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -m 1000

[System.Windows.Forms.SendKeys]::SendWait($Global:password)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -m 1000

[System.Windows.Forms.SendKeys]::SendWait($Global:password)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Start-Sleep -m 3000
Start-Process -FilePath $APILocation -WindowStyle Hidden

}

function ImportVM{

$Global:vmware = "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"

$arg2 = $Global:LastNaming


if (Get-Process -Name "vmware" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "vmware" -Force
    Start-Process -FilePath $Global:vmware -ArgumentList $arg2
} else {
    Start-Process -FilePath $Global:vmware -ArgumentList $arg2
}
Start-Sleep -m 10000
}

function EditConfig{

$creds = $Global:username + ":" + $Global:password

$base64String = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($creds))


$uri = 'http://127.0.0.1:8697/api/vms'

$headers = @{
    'Content-Type' = 'application/vnd.vmware.vmw.rest-v1+json'
    'Accept' = 'application/vnd.vmware.vmw.rest-v1+json'
    'Authorization' = "Basic $base64String"
}

$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$kaliId = $null

foreach ($vm in $response) {
 
    if ($vm.path -like "*$Global:name*") {
       
        $kaliId = $vm.id
        break  
    }
}
$uri2 = "http://127.0.0.1:8697/api/vms/$kaliId/power"

$response2 = Invoke-RestMethod -Uri $uri2 -Method Get -Headers $headers

$powerState = $response.power_state

if ($powerState -eq 'poweredOn') {
    $body = 'off'
    Invoke-RestMethod -Uri $uri2 -Method Put -Headers $headers -Body $body
    break
}

$uri3 = "http://127.0.0.1:8697/api/vms/$kaliId"

$requestBody = @{
    processors = 6
    memory = 8000
}

$jsonBody = $requestBody | ConvertTo-Json

Invoke-RestMethod -Uri $uri3 -Method Put -Headers $headers -Body $jsonBody | Out-Null
Start-Sleep -Milliseconds 300   
Stop-Process -Name "vmware" -Force
Start-Sleep -Milliseconds 500
Start-Process -FilePath $Global:vmware
Start-Sleep -Milliseconds 500


Invoke-RestMethod -Uri $uri2 -Method Put -Headers $headers -Body 'on' | Out-Null
Start-Sleep -m 30000
}

function PrepareKali{

$RunLocation = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

$arg1 = "-gu $Global:kaliuser -gp $Global:kaliuser copyFileFromHostToGuest $Global:LastNaming `"$PSScriptRoot\kali-build`" /home/$Global:kaliuser/kali-build"

Start-Process -FilePath $RunLocation -ArgumentList $arg1 -Wait -WindowStyle Hidden

$arg2 = "-gu $Global:kaliuser -gp $Global:kaliuser runProgramInGuest `"$Global:LastNaming`" /usr/bin/python3 -c `"import subprocess; subprocess.run(['/bin/bash', '/home/$Global:kaliuser/kali-build/remove_login.sh'])`""

Start-Process -FilePath $RunLocation -ArgumentList $arg2 -Wait -WindowStyle Hidden

$arg3 = "-T ws reset `"$Global:LastNaming`""

Start-Process -FilePath $RunLocation -ArgumentList $arg3 -Wait -WindowStyle Hidden

Start-Sleep -m 30000

$arg4 = "-gu $Global:kaliuser -gp $Global:kaliuser runProgramInGuest `"$Global:LastNaming`" -interactive `"/usr/bin/qterminal`" `"-e `"/bin/sh -c /home/$Global:kaliuser/kali-build/setup.sh`"`""

Write-Warning "Now Just Keep an Eye on The Kali VM Till Finish!!!!"

Start-Process -FilePath $RunLocation -ArgumentList $arg4 -WindowStyle Hidden

Write-Warning "Still Not Finished, Check Till Ansible Finish!"

$vmrestProcess = Get-Process -Name "vmrest" -ErrorAction SilentlyContinue

if ($vmrestProcess) {
    Stop-Process -Name "vmrest" -Force
}
}

CheckRunAsAdministrator
CreateFolder
DownloadingKali
RunAPI
ImportVM
EditConfig
PrepareKali