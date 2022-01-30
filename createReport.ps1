#--------------------------------------------------------------------------------
#
# NAME:		pShell-Commander.ps1
#
# AUTHOR:	Spuzzelsnest
#
# COMMENT:
#			Check status of services
#
#
#       VERSION HISTORY:
#       1.0     30.01.2022  - initial commit.
#--------------------------------------------------------------------------------
# START VARS

$pcs = Get-Content Logs\server.lst
$dump = "Logs\"
$file = "network-report.html"
$tot = ($pcs | Measure-Object -Line).lines
$i = 1
 
# Make backup 

if (Test-Path $dump\$file){
    copy-item $dump\$file -destination $dump\$file-$(Get-Date -format "yyyy_MM_dd_hh_mm_ss")
}

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
