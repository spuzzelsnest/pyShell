<#
.synopsis 
Create Server Status Report

- user specifies the file containing a list of servers

This Script will create a html file with the online status of a list of servers provided in file Logs/server.lst

.Description
This script collects the online status of a list of servers.

.parameter list
Specifies the locatoin of a file containing a line seperated list of computers or Ip adresses 

.example
./createReport.ps1 -list ./server.lst

#>

# Parameter Definition Section
param(
    [string]$list
)


# START VARS

$dump = "Logs\"
$file = "network-report.html"

if(Test-path $list -PathType Leaf){
    $pcs = Get-Content $list
 }else{
    Write-host "Server list file not found in Directory Logs/server.lst\n setting pc list to local pc"
    $pcs = 127.0.0.1
}

# Make backup 

if (Test-Path $dump\$file){
    copy-item $dump\$file -destination $dump\$file-$(Get-Date -format "yyyy_MM_dd_hh_mm_ss")
}

$tot = ($pcs | Measure-Object -Line).lines
$i = 1

# Iterate Servers

$pcs = Get-Content "Logs\server.lst"
$Complete = @{}

Do {
  $pcs | %{
        $status = (Test-Connection -ComputerName $_ -Buffersize 16 -count 1 -quiet)
        $Complete.Add($_,$status)
      }
      
} While ($Complete.Count -lt $pcs.Count)

# Build the HTML output

  $Head = "
    <title>Status Report</title>
    <meta http-equiv='refresh' content='30' />"

  $Body = @()
  $Body += "<center><table><tr><th>ServerName</th><th>State</th></tr>"
  $Body += $pcs | %{
    If ($Complete.$_ -eq "True") {
    "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
    } Else {
    "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
    }
  }
  $Body += "</table></center>"
  $Html = ConvertTo-Html -Body $Body -Head $Head

# save HTML
  $Html > $dump/$file
