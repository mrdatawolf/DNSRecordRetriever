# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main window
$form = New-Object System.Windows.Forms.Form
$form.Text = 'DNS Record Retriever'
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = 'CenterScreen'

# Create labels and textboxes for SPF, DMARC, and DKIM results
$labels = 'SPF', 'DMARC', 'DKIM'
$textBoxes = @()

for ($i = 0; $i -lt $labels.Length; $i++) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, (80 + $i * 100))
    $label.Size = New-Object System.Drawing.Size(480,20)
    $label.Text = "$($labels[$i]) Info:"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, (100 + $i * 100))
    $textBox.Size = New-Object System.Drawing.Size(480,60)
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Vertical'
    $textBox.ReadOnly = $true 
    $form.Controls.Add($textBox)
    $textBoxes += $textBox
}

function Get-DnsRecords {
    param (
        [string]$Hostname
    )
    $types = 'TXT', 'TXT', 'TXT' # Set all types to 'TXT'
    $queries = $Hostname, "_dmarc.$Hostname", "selector1._domainkey.$Hostname" # Define the queries

    for ($i = 0; $i -lt $types.Length; $i++) {
        $records = Resolve-DnsName -Name $queries[$i] -Type $types[$i] -ErrorAction SilentlyContinue
        if ($records) {
            foreach ($record in $records) {
                $textBoxes[$i].Text += $record.Strings -join "`n"
            }
        } else {
            $textBoxes[$i].Text += "No records found for $($queries[$i]).`n"
        }
    }
    $isValidSpf = Validate-SpfRecord $textBoxes[0].Text
    $spfValidCheckbox.Checked = $isValidSpf
    $isValidDmarc = Validate-DmarcRecord $textBoxes[1].Text
    $dmarcValidCheckbox.Checked = $isValidDmarc
    $isValidDkim = Validate-DkimRecord $textBoxes[2].Text
    $dkimValidCheckbox.Checked = $isValidDkim
}
function Validate-SpfRecord {
    param (
        [string]$SpfRecord
    )
    # Basic pattern matching to check for a valid SPF record
    $spfPattern = "v=spf1\s+.*all"
    if ($SpfRecord -match $spfPattern) {
        return $true
    } else {
        return $false
    }
}
function Validate-DmarcRecord {
    param (
        [string]$DmarcRecord
    )
    # Basic pattern matching to check for a valid DMARC record
    $dmarcPattern = "v=DMARC1; p=(none|quarantine|reject);?"
    if ($DmarcRecord -match $dmarcPattern) {
        return $true
    } else {
        return $false
    }
}
function Validate-DkimRecord {
    param (
        [string]$DkimRecord
    )
    # Basic pattern matching to check for a valid DKIM record
    $dkimPattern = "v=DKIM1; k=rsa; p=[a-zA-Z0-9+/=]+"
    if ($DkimRecord -match $dkimPattern) {
        return $true
    } else {
        return $false
    }
}


# Create a read-only checkbox for SPF validation
$spfValidCheckbox = New-Object System.Windows.Forms.CheckBox
$spfValidCheckbox.Location = New-Object System.Drawing.Point(500, 80) 
$spfValidCheckbox.Size = New-Object System.Drawing.Size(20, 20)
$spfValidCheckbox.Enabled = $false 
$spfValidCheckbox.BackColor = [System.Drawing.Color]::Red 
$form.Controls.Add($spfValidCheckbox)
$spfValidCheckbox.add_CheckedChanged({
    if ($spfValidCheckbox.Checked) {
        $spfValidCheckbox.BackColor = [System.Drawing.Color]::Green 
    } else {
        $spfValidCheckbox.BackColor = [System.Drawing.Color]::Red   
    }
})
# Create a read-only checkbox for DMARC validation
$dmarcValidCheckbox = New-Object System.Windows.Forms.CheckBox
$dmarcValidCheckbox.Location = New-Object System.Drawing.Point(500, 180) 
$dmarcValidCheckbox.Size = New-Object System.Drawing.Size(20, 20)
$dmarcValidCheckbox.Enabled = $false 
$dmarcValidCheckbox.BackColor = [System.Drawing.Color]::Red
$form.Controls.Add($dmarcValidCheckbox)
$dmarcValidCheckbox.add_CheckedChanged({
    if ($dmarcValidCheckbox.Checked) {
        $dmarcValidCheckbox.BackColor = [System.Drawing.Color]::Green 
    } else {
        $dmarcValidCheckbox.BackColor = [System.Drawing.Color]::Red   
    }
})
# Create a read-only checkbox for DKIM validation
$dkimValidCheckbox = New-Object System.Windows.Forms.CheckBox
$dkimValidCheckbox.Location = New-Object System.Drawing.Point(500, 280) 
$dkimValidCheckbox.Size = New-Object System.Drawing.Size(20, 20)
$dkimValidCheckbox.Enabled = $false 
$dkimValidCheckbox.BackColor = [System.Drawing.Color]::Red
$form.Controls.Add($dkimValidCheckbox)
$dkimValidCheckbox.add_CheckedChanged({
    if ($dkimValidCheckbox.Checked) {
        $dkimValidCheckbox.BackColor = [System.Drawing.Color]::Green 
    } else {
        $dkimValidCheckbox.BackColor = [System.Drawing.Color]::Red   # Red background if unchecked
    }
})
# Create input field for hostname
$hostnameLabel = New-Object System.Windows.Forms.Label
$hostnameLabel.Location = New-Object System.Drawing.Point(10,10) # Moved to the top
$hostnameLabel.Size = New-Object System.Drawing.Size(480,20)
$hostnameLabel.Text = 'Enter the domain name:'
$form.Controls.Add($hostnameLabel)
$hostnameTextBox = New-Object System.Windows.Forms.TextBox
$hostnameTextBox.Location = New-Object System.Drawing.Point(10,30) # Moved to the top, below the label
$hostnameTextBox.Size = New-Object System.Drawing.Size(540,20) # 50% wider
$form.Controls.Add($hostnameTextBox)
# Create button to trigger DNS lookup
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(560,28) # Moved to the top, next to the textbox
$button.Size = New-Object System.Drawing.Size(150,25) # 50% wider
$button.Text = 'Retrieve'
$button.Add_Click({
    foreach ($textBox in $textBoxes) {
        $textBox.Text = ''
    }
    Get-DnsRecords -Hostname $hostnameTextBox.Text
})
$form.Controls.Add($button)
# Adjust the main window size to accommodate the new button and textbox positions
$form.Size = New-Object System.Drawing.Size(750,450) # Increased width by 50%
$form.AcceptButton = $button
$hostnameTextBox.Select()
# Show the form
$form.ShowDialog()
