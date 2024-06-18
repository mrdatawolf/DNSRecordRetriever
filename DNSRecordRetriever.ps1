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
    $label.Location = New-Object System.Drawing.Point(10, (20 + $i * 100))
    $label.Size = New-Object System.Drawing.Size(480,20)
    $label.Text = "$($labels[$i]) Info:"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, (40 + $i * 100))
    $textBox.Size = New-Object System.Drawing.Size(480,60)
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Vertical'
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
}


# Create input field for hostname
$hostnameLabel = New-Object System.Windows.Forms.Label
$hostnameLabel.Location = New-Object System.Drawing.Point(10,320)
$hostnameLabel.Size = New-Object System.Drawing.Size(480,20)
$hostnameLabel.Text = 'Enter the domain name:'
$form.Controls.Add($hostnameLabel)

$hostnameTextBox = New-Object System.Windows.Forms.TextBox
$hostnameTextBox.Location = New-Object System.Drawing.Point(10,340)
$hostnameTextBox.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($hostnameTextBox)

# Create button to trigger DNS lookup
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(380,338)
$button.Size = New-Object System.Drawing.Size(100,25)
$button.Text = 'Retrieve'
$button.Add_Click({
    Get-DnsRecords -Hostname $hostnameTextBox.Text
})
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()
