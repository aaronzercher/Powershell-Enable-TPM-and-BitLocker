$wmiInfo = Get-wmiobject Win32_Bios
Start-Transcript -Path "c:\corp\bitlocker\$($env:COMPUTERNAME).$($wmiInfo.SerialNumber).$(get-date -uformat '%Y-%m-%d-%H-%M-%S-%p').log"
Get-Tpm
Get-BitLockerVolume
manage-bde.exe -status c: | find "Protection On"
if($lastexitcode -eq 0)
    {
        Finished
    }
manage-bde.exe -status c: | find "Encryption in Progress"
if($lastexitcode -eq 0)
    {
        Finished
    }

if ((Get-Tpm | Select-Object -Property TpmReady).TpmReady -eq $False)
    {
        $clear = Initialize-Tpm -AllowClear -AllowPhysicalPresence | Select-Object -Property RestartRequired, ClearRequired
        if($clear.ClearRequired)
        {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Clear TPM required, contact support.",0,"OK",0x1) 
        }
        if($clear.RestartRequired)
        {
            $wshell = New-Object -ComObject Wscript.Shell
            Stop-Transcript
            & .\LogUpload.ps1
            $wshell.Popup("Reboot Required to initialize TPM, Ok to continue. Note: Computer will reboot immediately, save your work. Durring reboot when prompted press F1 to continue.",0,"OK",0x0)
            Restart-Computer
        }
    }
