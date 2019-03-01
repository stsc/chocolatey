<#
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
  echo "${script_name}: $msg"
  if ($fatal -eq $True) {
    exit 1
  }
}
function print_box {
  Param([string]$text)
  $line = "-" * ($text.Length + 2)
  Write-Host @"
+${line}+
¦ ${text} ¦
+${line}+
"@
}
function print_state {
  Param([string]$var,[string]$val)
  $state = "$var = "
  $state += If ($val -eq $True) {'$True'} Else {'$False'}
  echo $state
}
function print_init {
  $mode = If ($install -eq $True) {"install"} Else {"uninstall"}
  $count = $pkgs.count
  if ($count -eq 0) {
    warn -msg "no package(s)" -fatal $True
  }
  $suffix = If ($count -gt 1) {"s"} Else {""}
  echo "Going to $mode $count package${suffix}..."
}
function process_pkgs {
  foreach ($pkg in $pkgs) {
    if (-not (Test-Path $pkg -PathType Container)) {
      warn -msg "'$pkg' is not a directory" -fatal $False
      continue
    }
    echo $pkg.ToUpper()
    $bar = "*" * $pkg.Length
    echo $bar
    $pwd = pwd
    echo "Changing current working directory..."
    cd $pkg 2>$null
    if ($? -eq $False) {
      warn -msg "cannot cd to '$pkg'" -fatal $True
    }
    if ($install -eq $True) {
      Write-Host @"
choco pack
==========
"@
      choco pack
      echo "----------"
      Write-Host @"
choco install
=============
"@
      choco install $pkg -s . -my
      echo "-------------"
    } else {
      Write-Host @"
choco uninstall
===============
"@
      choco uninstall $pkg -s . -my
      echo "---------------"
    }
    echo "Restoring current working directory..."
    cd $pwd 2>$null
    if ($? -eq $False) {
      warn -msg "cannot cd to '$pwd'" -fatal $True
    }
  }
}
if ($env:Choco_Clear -eq $True) {
  Clear-Host
}
print_box -text $script_name
print_state -var '$env:Choco_Clear' -val $env:Choco_Clear
print_init
process_pkgs