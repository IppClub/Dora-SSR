param(
    [Parameter(Mandatory=$true)][string]$Installer,
    [Parameter(Mandatory=$true)][string]$InstallRoot,
    [int]$DoraProcessId = 0,
    [string]$LogPath = "$env:TEMP\dora-msi-update.log",
    [switch]$NoLaunch
)
$ErrorActionPreference = 'Stop'
if (-not [IO.Path]::IsPathRooted($Installer) -or -not (Test-Path -LiteralPath $Installer -PathType Leaf) -or [IO.Path]::GetExtension($Installer) -ne '.msi') { throw 'Expected an absolute MSI package path' }
if (-not [IO.Path]::IsPathRooted($InstallRoot)) { throw 'Expected an absolute installation directory' }
if ($DoraProcessId -gt 0) { Wait-Process -Id $DoraProcessId -ErrorAction SilentlyContinue }
$arguments = @('/i', ('"'+$Installer+'"'), '/passive', '/norestart', '/L*v', ('"'+$LogPath+'"'), ('INSTALLFOLDER="'+$InstallRoot+'"'))
# A redownload of an identical MSI repairs/recaches its existing product.
# New payloads have a different ProductCode and use the normal major upgrade.
$installerService = New-Object -ComObject WindowsInstaller.Installer
$database = $installerService.OpenDatabase($Installer, 0)
$view = $database.OpenView("SELECT Value FROM Property WHERE Property='ProductCode'")
$view.Execute(); $record=$view.Fetch(); $productCode=$record.StringData(1); $view.Close()
if ($installerService.ProductState($productCode) -eq 5) { $arguments += @('REINSTALL=ALL','REINSTALLMODE=vomus') }
$process = Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList $arguments -PassThru -Wait
$ok = $process.ExitCode -in @(0,3010)
if (-not $NoLaunch) {
    if (-not $ok) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Dora update failed (Windows Installer $($process.ExitCode)). See $LogPath", 'Dora SSR') | Out-Null
    }
    $dora = Join-Path $InstallRoot 'Dora.exe'
    if (Test-Path -LiteralPath $dora) { Start-Process -FilePath $dora -WorkingDirectory $InstallRoot }
}
if (-not $ok) { exit $process.ExitCode }
# Called with &, a script otherwise leaves the caller's $LASTEXITCODE unchanged.
# Normalize both successful MSI codes (0 and reboot-required 3010) to success.
exit 0
