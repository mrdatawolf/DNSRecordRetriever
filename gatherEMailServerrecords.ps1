<#
.SYNOPSIS
   gatherEMailServerrecords.ps1 - Gathers email server records and displays them in a user-friendly format.

.DESCRIPTION
   This script gathers SPF, DMARC, and DKIM records for a given domain and formats the results for clear readability.

.PARAMETER Hostname
   Domain name of the server.

.EXAMPLE
   .\gatherEMailServerrecords.ps1 gmail.com

   This example displays the email server records for gmail.com in a user-friendly format.

.NOTES
   Author: Patrick
#>
param (
   [Parameter(Mandatory=$true)]
   [string]$Hostname
)

# Function to display DNS records
function Get-DnsRecords {
    param (
        [string]$Type,
        [string]$Hostname
    )
    try {
        $records = Resolve-DnsName -Name $Hostname -Type $Type -ErrorAction Stop
        if ($records) {
            Write-Host "`n$Type records for $Hostname`n" -ForegroundColor Cyan
            $records | ForEach-Object {
                $_.Strings | ForEach-Object { Write-Host "  $_" }
            }
        } else {
            Write-Host "No $Type records found for $Hostname." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to retrieve $Type records for $Hostname. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display SPF Info
Get-DnsRecords -Type TXT -Hostname $Hostname

# Display DMARC Info
Get-DnsRecords -Type TXT -Hostname "_dmarc.$Hostname"

# Display DKIM Info
Get-DnsRecords -Type TXT -Hostname "selector1._domainkey.$Hostname"
