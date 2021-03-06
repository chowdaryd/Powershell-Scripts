<#

.SYNOPSIS
This is a Powershell script to start WinAFL fuzzing instances.

.DESCRIPTION
This Powershell script will start WinAFL fuzzing instances and bind each instance to a CPU core. 
Run this script from the same directory as the WinAFL binaries

.PARAMETER FuzzApplication
Application to fuzz with WinAFL.

.PARAMETER FuzzInput
Fuzzing Input Directories.

.PARAMETER FuzzOutput
Fuzzing Output Directories.

.PARAMETER DynamoRIODir
DynamoRIO Binaries for WinAFL.

.PARAMETER CoverageModule
WinAFL Parameter - coverage_module.

.PARAMETER TargetModule
WinAFL Parameter - target_module.

.PARAMETER TargetMethodOrOffset
WinAFL Parameter - target_method or target_offset.

.PARAMETER nargs
WinAFL Parameter - nargs.

.PARAMETER NumberofCores
Number of CPU cores to assign to the fuzzer. [Atleast one core]

#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$FuzzApplication,
    [Parameter(Mandatory=$true)]
    [string]$FuzzInput,
    [Parameter(Mandatory=$true)]
    [string]$FuzzOutput,
    [Parameter(Mandatory=$true)]
    [string]$DynamoRIODir,
    [Parameter(Mandatory=$true)]
    [string]$TargetModule,
    [Parameter(Mandatory=$true)]
    [string]$CoverageModule,
    [Parameter(Mandatory=$true)]
    [string]$TargetMethodOrOffset,
    [Parameter(Mandatory=$true)]
    [string]$nargs,
    [Parameter(Mandatory=$true)]
    [string]$NumberOfCores

)

$x = 1
foreach ($i in 1..$NumberOfCores){

	$core = [Convert]::ToString([Convert]::ToInt32($x.ToString("#"),2), 16)
	$x = $x * 10

	$command = "start /affinity $core"
	$command = $command + " afl-fuzz.exe -i $FuzzInput -o $FuzzOutput -D $DynamoRIODir -t 100000"

	if ($i -like 1){
		$command = $command + " -M Fuzzer$i"
	}
	else{
		$command = $command + " -S Fuzzer$i"
	}

	$command = $command + " -- -covtype edge -fuzz_iterations 50 -coverage_module $CoverageModule -target_module $TargetModule"
	
	if ($TargetMethodOrOffset -like '0x*'){
		$command = $command + " -target_offset $TargetMethodOrOffset"
	}
	else{
		$command = $command + " -target_method $TargetMethodOrOffset"
	}
	$command = $command + " -nargs $nargs -- $FuzzApplication @@"

	cmd /c $command
	
}
