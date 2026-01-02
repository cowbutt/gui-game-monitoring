function GamingDiag_Form{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

    # Set the size of your form
    $Form = New-Object System.Windows.Forms.Form
    $Form.width = 500
    $Form.height = 300
    $Form.Text = "Start Gaming Diagnostics"
 
    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Times New Roman",12)
    $Form.Font = $Font

    $checkBox1 = New-Object System.Windows.Forms.CheckBox
    $checkBox1.Location = New-Object System.Drawing.Point(10,50)
    $checkBox1.AutoSize = $true
    $checkBox1.Text = "Start GPU-Z?"
    $checkBox1.Checked = $true

    $checkBox2 = New-Object System.Windows.Forms.CheckBox
    $checkBox2.Location = New-Object System.Drawing.Point(10,70)
    $checkBox2.AutoSize = $true
    $checkBox2.Text = "Start HWiNFO64?"
    $checkBox2.Checked = $true

    $checkBox3 = New-Object System.Windows.Forms.CheckBox
    $checkBox3.Location = New-Object System.Drawing.Point(10,90)
    $checkBox3.AutoSize = $true
    $checkBox3.Text = "Start MSIAfterburner?"
    $checkBox3.Checked = $false

    $checkBox4 = New-Object System.Windows.Forms.CheckBox
    $checkBox4.Location = New-Object System.Drawing.Point(10,110)
    $checkBox4.AutoSize = $true
    $checkBox4.Text = "Start PresentMon?"
    $checkBox4.Checked = $true

	$checkBox5 = New-Object System.Windows.Forms.CheckBox
    $checkBox5.Location = New-Object System.Drawing.Point(10,130)
    $checkBox5.AutoSize = $true
    $checkBox5.Text = "Start Lossless Scaling?"
    $checkBox5.Checked = $false

	$checkBox6 = New-Object System.Windows.Forms.CheckBox
    $checkBox6.Location = New-Object System.Drawing.Point(10,150)
    $checkBox6.AutoSize = $true
    $checkBox6.Text = "Enable DLSS Indicator?"
    $checkBox6.Checked = $false

    # Add an OK button
    # Thanks to J.Vierra for simplifing the use of buttons in forms
    $OKButton = new-object System.Windows.Forms.Button
    $OKButton.Location = '130,200'
    $OKButton.Size = '100,40' 
    $OKButton.Text = 'OK'
    $OKButton.DialogResult=[System.Windows.Forms.DialogResult]::OK
 
    #Add a cancel button
    $CancelButton = new-object System.Windows.Forms.Button
    $CancelButton.Location = '255,200'
    $CancelButton.Size = '100,40'
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult=[System.Windows.Forms.DialogResult]::Cancel

    # Add all the Form controls on one line 
    $form.Controls.AddRange(@($OKButton,$CancelButton,$checkBox1,$checkBox2,$checkBox3,$checkBox4,$checkBox5,$checkBox6))

    # Assign the Accept and Cancel options in the form to the corresponding buttons
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton
 
    # Activate the form
    $Form.Add_Shown({$form.Activate()})    
    
    # Get the results from the button click
    $dialogResult = $Form.ShowDialog()
 
    # If the OK button is selected
    if ($dialogResult -eq "OK"){
        write-output "OK"
        # Check the current state of each checkbox
        if ($checkBox1.Checked){
           $global:startgpuz=$true
        }
        if ($checkBox2.Checked){
           $global:starthwinfo=$true
        }
        if ($checkBox3.Checked){
           $global:startafterburner=$true
        }
        if ($checkBox4.Checked){
           $global:startpresentmon=$true
        }
        if ($checkBox5.Checked){
           $global:startlosslessscaling=$true
        }
        if ($checkBox6.Checked){
           $global:showdlss=$true
        }		
        #Write-Output $startgpuz
        #Write-Output $starthwinfo
        #Write-Output $startafterburner
        #Write-Output $startpresentmon
    }
}
 
$global:startgpuz=$false
$global:starthwinfo=$false
$global:startafterburner=$false
$global:startpresentmon=$false
$global:startlosslessscaling=$false
$global:showdlss=$false
$global:currentuseridentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$global:currentuserprincipal=New-Object System.Security.Principal.WindowsPrincipal($currentuseridentity)
$global:currentusername=$currentuseridentity.Name
$global:currentdesktopusername=(Get-CimInstance Win32_ComputerSystem).username
#$global:adminuser=$(Get-Credential -Credential "Owner")

if ($currentuserprincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host -F Green 'Administrator'
} else {
    Write-Host -F Red 'Non-Administrator: please run this script as an Administrator'
    Start-Sleep -m 2500
    exit
}

# Call the function
GamingDiag_Form
if ($startgpuz) {
    start-process "C:\Program Files (x86)\GPU-Z\GPU-Z.exe" #-Credential $adminuser
    Start-Sleep -m 500
}
if ($starthwinfo) {
    start-process "C:\Program Files\HWiNFO64\HWiNFO64.EXE" #-Credential $adminuser
    Start-Sleep -m 500
}
if ($startafterburner) {
    start-process "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe" #-Credential $adminuser
    Start-Sleep -m 500
}
if ($startlosslessscaling) {
    start-process "E:\SteamLibrary\steamapps\common\Lossless Scaling\LosslessScaling.exe" #-Credential $adminuser
    Start-Sleep -m 500
}
if ($showdlss) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Name "Installed" -Value 0x1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Name "ShowDlssIndicator" -Value 0x400
}
if (!$showdlss) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Name "Installed" -Value 0x1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Name "ShowDlssIndicator" -Value 0x0
}
if ($startpresentmon) {
# PresentMon 2.4.0 UI doesn't start if run as Administrator from non-Administrator desktop
#    start-process -WorkingDirectory "C:\Program Files\Intel\PresentMon\PresentMonApplication\" "C:\Program Files\Intel\PresentMon\PresentMonApplication\PresentMon.exe"

start-process -Verb RunAsUser -WorkingDirectory "C:\Program Files\Intel\PresentMon\PresentMonApplication\" "C:\Program Files\Intel\PresentMon\PresentMonApplication\PresentMon.exe"
#start-process -WorkingDirectory "C:\Program Files\Intel\PresentMon\PresentMonApplication\" "C:\Program Files\Intel\PresentMon\PresentMonApplication\PresentMon.exe"
    Start-Sleep -m 50000
}
