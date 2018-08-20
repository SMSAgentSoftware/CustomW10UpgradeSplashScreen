# Displays a full screen background on each active screen

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms

# Get active screens
$Screens = [System.Windows.Forms.Screen]::AllScreens

# Create a runspace to initiate powershell for each screen and call the main script (otherwise each window will only open when the first closes due to the .ShowDialog() method)
Foreach ($Screen in $screens)
{
    $PowerShell = [Powershell]::Create()
    $PowerShell.AddScript({Param($ScriptLocation, $DeviceName); powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "$ScriptLocation\Create-FullScreenBackground.ps1" -DeviceName $DeviceName})
    $PowerShell.AddArgument($PSScriptRoot)
    $PowerShell.AddArgument($Screen.DeviceName)
    $PowerShell.BeginInvoke()
}

# Wait for runspace execution
Start-Sleep -Seconds 5