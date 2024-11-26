Param (
    [Parameter(Mandatory = $true)]
    [string]$OutputDir,
    [Parameter(Mandatory = $false)]
    [string]$BaseSourceDir = "."
)

if (-Not (Test-Path -Path $BaseSourceDir)) {
    "BaseSourceDir $BaseSourceDir doesn't exist.";
    exit 1;
}

if (-Not (Test-Path -Path $OutputDir)) {
    "OutputDir $OutputDir doesn't exist.";
    exit 2;
}

$3rdparty_basepath = Join-Path -Path $BaseSourceDir -ChildPath "src\3rdparty";
$3rdparty_filepathes = @(
    "mysql\dll\libmariadb.dll"
);

foreach ($filepath in $3rdparty_filepathes)
{
    $filepath_to_copy = Join-Path -Path $3rdparty_basepath -ChildPath $filepath
    if (-Not (Test-Path -Path $filepath_to_copy -PathType Leaf)) {
        "File $filepath_to_copy doesn't exist.";
        exit 3;
    }
    "Copy $filepath_to_copy to $OutputDir.";
    Copy-Item -Path $filepath_to_copy -Destination $OutputDir;
}

exit 0;
