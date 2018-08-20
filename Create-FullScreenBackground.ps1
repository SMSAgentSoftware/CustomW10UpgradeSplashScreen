# Creates a full screen 'background' and hides the task bar

Param($DeviceName)

# Add required assemblies
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Find screen by DeviceName
$Screens = [System.Windows.Forms.Screen]::AllScreens
$Screen = $Screens | Where {$_.DeviceName -eq $DeviceName}

# Add custom type to hide the taskbar
# Thanks to https://stackoverflow.com/questions/25499393/make-my-wpf-application-full-screen-cover-taskbar-and-title-bar-of-window
$Source = @"
using System;
using System.Runtime.InteropServices;

public class Taskbar
{
    [DllImport("user32.dll")]
    private static extern int FindWindow(string className, string windowText);
    [DllImport("user32.dll")]
    private static extern int ShowWindow(int hwnd, int command);

    private const int SW_HIDE = 0;
    private const int SW_SHOW = 1;

    protected static int Handle
    {
        get
        {
            return FindWindow("Shell_TrayWnd", "");
        }
    }

    private Taskbar()
    {
        // hide ctor
    }

    public static void Show()
    {
        ShowWindow(Handle, SW_SHOW);
    }

    public static void Hide()
    {
        ShowWindow(Handle, SW_HIDE);
    }
}
"@
Add-Type -ReferencedAssemblies 'System', 'System.Runtime.InteropServices' -TypeDefinition $Source -Language CSharp

# Create a WPF window
$Window = New-Object System.Windows.Window
$window.Background = [System.Windows.Media.Brushes]::MidnightBlue
$Window.WindowStyle = [System.Windows.WindowStyle]::None
$Window.ResizeMode = [System.Windows.ResizeMode]::NoResize
$Window.Foreground = [System.Windows.Media.Brushes]::White

# Get the bounds of the primary screen
$Bounds = $Screen.Bounds

# Create a stackpanel container
$Stackpanel = New-Object System.Windows.Controls.Stackpanel
$Stackpanel.VerticalAlignment = "Center"
$Stackpanel.Margin = "0,$($Bounds.Height / 100 * 40),0,0"

# Add a textblock
$TextBlock = New-Object System.Windows.Controls.TextBlock
$TextBlock.Text = "Windows is being upgraded. Do not turn off your computer."
$TextBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
$TextBlock.MaxWidth = $Bounds.Width
$TextBlock.Padding = 10
$TextBlock.FontSize = 50
$TextBlock.VerticalAlignment = "Center"
$TextBlock.HorizontalAlignment = "Center"
$Stackpanel.AddChild($TextBlock)

# Add a progress bar
$ProgressBar = New-object System.Windows.Controls.ProgressBar
$ProgressBar.Margin = "0,50,0,0"
$ProgressBar.IsIndeterminate = $True
$ProgressBar.Width = ($Bounds.Width / 100 * 70)
$ProgressBar.Height = 20
$Stackpanel.AddChild($ProgressBar)

# Add to window
$Window.AddChild($Stackpanel)

# Event: Window loaded
$Window.Add_Loaded({
    
    # Activate the window to bring it to the fore
    $This.Activate()

    # Fill the screen
    $Bounds = $screen.Bounds
    $Window.Left = $Bounds.Left
    $Window.Top = $Bounds.Top
    $Window.Height = $Bounds.Height
    $Window.Width = $Bounds.Width

    # Hide the taskbar
    [TaskBar]::Hide()

})

# Event: Window closing (for testing)
#$Window.Add_Closing({
#
    # Restore the taskbar
#    [Taskbar]::Show()
#
#})

# Event: Close the window on right-click (for testing)
#$Window.Add_MouseRightButtonDown({
#
#    $This.Close()
#
#})

# Display the window
$Window.ShowDialog()