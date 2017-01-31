""
function Write-Cyan($str) {
    Write-Host -ForegroundColor Cyan -NoNewLine $str
}

$script:progress = 0

function step($step) {
  $script:progress = $script:progress + 12.5
  Write-Progress -Activity "Reading" -Percent $script:progress -Status $step
}

step "OS"
$osInstance = Get-CimInstance Win32_OperatingSystem
$os = $osInstance.Caption
step "Uptime"
$uptime = New-TimeSpan -Start $osInstance.LastBootUpTime
step "CPU"
$cpu = (Get-WmiObject Win32_Processor).Name
step "GPU"
$gpuInstance = Get-WmiObject Win32_VideoController
$gpu = $gpuInstance.Caption
$resolution = $gpuInstance.VideoModeDescription
step "OSVersion"
$kernel = [System.Environment]::OSVersion.VersionString
step "Packages"
$packages = (dir hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Measure).Count
step "PS"
$shell = "PowerShell $($PSVersionTable.PSVersion.ToString())"
step "Memory"
$totalRam = [Math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1MB)
$freeRam = (Get-Counter -Counter "\Memory\Available MBytes").Readings.Split("`r`n")[1]
$usedRam = [Math]::Round($totalRam-$freeRam)

$model = @(
    @("${env:USERNAME}@${env:COMPUTERNAME}"),
    @("OS", $os),
    @("Kernel", $kernel),
    @("Uptime", $uptime),
    @("Packages", $packages),
    @("Shell", $shell),
    @("Resolution", $resolution),
    @("DE", "Windows"),
    @("WM", "Windows"),
    @("WM Theme", "Aero"),
    @("CPU", $cpu),
    @("GPU", $gpu),
    @("RAM", "$usedRam MiB / $totalRam MiB")
)

$logo = "                                  .., 
                      ....,,:;+ccllll 
        ...,,+:;  cllllllllllllllllll 
  ,cclllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
                                      
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  llllllllllllll  lllllllllllllllllll 
  ``'ccllllllllll  lllllllllllllllllll 
         ``'`"`"*::  :ccllllllllllllllll 
                        ````````''`"*::cll 
                                   ```` ".Split("`r")
$i = 0
$logo | % {
    Write-Cyan $_.Replace("`n", "").PadRight(40)
    if ($i -lt $model.Length) {
        $line = $model[$i]
        Write-Cyan $line[0]
        if ($line.Length -gt 1) {
            Write-Cyan ": "
            Write-Host $line[1]
        } else {
            Write-Host ""
        }
    } else {
        Write-Host ""
    }
    $i = $i + 1
}

