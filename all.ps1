<#
.SYNOPSIS

Wrapper script for installing/uninstalling all chocolatey packages.

.EXAMPLE

.\all.ps1 install

.EXAMPLE

.\all.ps1 uninstall
#>
#-----------------#
# START of Config #
#-----------------#
$Exclude_dir_prefix = '^\!' # exclude directories by prefix (regex)
#---------------#
# END of Config #
#---------------#
if ($args.Count -gt 1) {
  Write-Output "$($MyInvocation.MyCommand.Name): single mode argument only"
  exit 1
} elseif ($args[0] -notmatch '^(?:un)?install$') {
  Write-Output "$($MyInvocation.MyCommand.Name): mode argument '$($args[0])' must be 'install' or 'uninstall'"
  exit 1
}
$mode = $args[0]
$clear = $env:Choco_Clear # save
$env:Choco_Clear = $False
Clear-Host
Get-ChildItem -Recurse -Directory -Depth 0 | ForEach-Object {
  if ($_.Name -notmatch $Exclude_dir_prefix) {
    Write-Output "$($mode.substring(0,1).toupper())$($mode.substring(1))ing $($_.Name)..."
    Invoke-Expression "& .\$($mode).ps1 $($_.Name)"
  }
}
$env:Choco_Clear = $clear # restore