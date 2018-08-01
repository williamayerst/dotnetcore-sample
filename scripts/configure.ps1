

write-host "Setting WorkingDir Variable"
$workingdir = $env:System_DefaultWorkingDirectory

write-host "Creating drop directory"
New-Item -Path "C:\" -Name "drop" -ItemType "directory" 

Write-Host "Copying to local drop directory"
Copy-Item -Path "$workingdir\drop\*" -Destination "c:\drop" -recurse -Force -Verbose

write-host "Getting drop directory contents"
get-childitem -Path "c:\drop" -Include *.dll | Write-Host


write-host "Installing chocolatey"
$chocoExePath = 'C:\ProgramData\Chocolatey\bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
  echo "Chocolatey found in PATH, skipping install..."
  Exit
}

# Add to system PATH
$systemPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
$systemPath += ';' + $chocoExePath
[Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)

# Update local process' path
$userPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::User)
if($userPath) {
  $env:Path = $systemPath + ";" + $userPath
} else {
  $env:Path = $systemPath
}

# Run the installer
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

write-host "Installing DotNetCore bits"
choco install dotnetcore dotnetcore-sdk webdeploy --yes
# choco install ddotnetcore-windowshosting --yes
# Install-WindowsFeature -Name Web-Server  -IncludeAllSubFeature -IncludeManagementTools
