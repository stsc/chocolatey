﻿<#
.SYNOPSIS

Backend for chocolatey wrapper scripts.

.PARAMETER install

Specifies the mode (install/uninstall).

.PARAMETER script_name

Filename of wrapper script which called the backend.

.PARAMETER pkgs

Package(s) to install/uninstall.
#>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
  [bool]$install,

  [Parameter(Mandatory=$True,Position=1)]
  [string]$script_name,

  [Parameter(Mandatory=$True,ValueFromRemainingArguments=$True)]
  [AllowEmptyCollection()]
  [string[]]$pkgs
)
function warn {
  Param([string]$msg,[bool]$fatal)
  Write-Output "${script_name}: $msg"
  if ($fatal -eq $True) {
    exit 1
  }
}
function print_box {
  Param([string]$text)
  $line = "-" * ($text.Length + 2)
  Write-Output @"
+${line}+
¦ ${text} ¦
+${line}+
"@
}
function print_state {
  Param([string]$var,[string]$val)
  $state = "$var = "
  switch ($val) {
    $True  { $state += '$True';  Break }
    $False { $state += '$False'; Break }
    $null  {                     Break }
  }
  Write-Output $state
}
function print_init {
  $mode = If ($install -eq $True) {"install"} Else {"uninstall"}
  $count = $pkgs.count
  if ($count -eq 0) {
    warn -msg "no package(s)" -fatal $True
  }
  $suffix = If ($count -gt 1) {"s"} Else {""}
  Write-Output "Going to $mode $count package${suffix}..."
}
function print_exit_code {
  Write-Output "Exit Code: $LastExitCode"
}
function process_pkgs {
  foreach ($pkg in $pkgs) {
    if (-not (Test-Path $pkg -PathType Container)) {
      warn -msg "'$pkg' is not a directory" -fatal $False
      continue
    }
    $bar = "*" * $pkg.Length
    Write-Output @"
$bar
$($pkg.ToUpper())
$bar
"@
    $pwd_save = $pwd
    Write-Output "Changing current working directory..."
    cd $pkg 2>$null
    if ($? -eq $False) {
      warn -msg "cannot cd to '$pkg'" -fatal $True
    }
    if ($install -eq $True) {
      Write-Output @"
choco pack
==========
"@
      choco pack
      print_exit_code
      Write-Output "----------"
      Write-Output @"
choco install
=============
"@
      choco install $pkg -s . -my
      print_exit_code
      Write-Output "-------------"
    } else {
      Write-Output @"
choco uninstall
===============
"@
      choco uninstall $pkg -s . -my
      print_exit_code
      Write-Output "---------------"
    }
    Write-Output "Restoring current working directory..."
    cd $pwd_save 2>$null
    if ($? -eq $False) {
      warn -msg "cannot cd to '$pwd_save'" -fatal $True
    }
  }
}
if (($env:Choco_Clear -ne $null) -and
    ($env:Choco_Clear -ne $False -and $env:Choco_Clear -ne $True)
) {
  warn -msg '$env:Choco_Clear must be either $True or $False' -fatal $True
}
if ($env:Choco_Clear -eq $True) {
  Clear-Host
}
print_box -text $script_name
print_state -var '$env:Choco_Clear' -val $env:Choco_Clear
print_init
process_pkgs