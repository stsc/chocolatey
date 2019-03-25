<#
.SYNOPSIS

Wrapper script for installing one or more chocolatey packages.

.EXAMPLE

.\install.ps1 <package(s)>

.EXAMPLE

$env:Choco_Clear = $True

.EXAMPLE

$env:Choco_Clear = $False
#>
Invoke-Expression "& `"$(Split-Path $MyInvocation.MyCommand.Path -Parent)\choco.ps1`" -install 1 -script_name $($MyInvocation.MyCommand.Name) $args"