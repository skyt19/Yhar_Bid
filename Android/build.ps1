# Yharbid Android Build Script (v2)
#
# Usage:
#   .\build.ps1                              # debug APK
#   .\build.ps1 release                      # release APK
#   .\build.ps1 release -Clean               # clean first
#   .\build.ps1 release -SplitPerAbi         # one APK per CPU architecture (smaller)
#   .\build.ps1 release -Bundle              # AAB for Google Play
#   .\build.ps1 debug -Install               # build, then install on connected device
#   .\build.ps1 debug -JavaHome "C:\Program Files\Java\jdk-17"
#   .\build.ps1 debug -SkipFirebaseCheck
#
# Note: save this file as UTF-8 with BOM if you edit it in Windows PowerShell 5.1.

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug",

    [switch]$Clean,
    [switch]$SkipFirebaseCheck,
    [switch]$SplitPerAbi,
    [switch]$Bundle,
    [switch]$Install,

    [string]$JavaHome
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
$PROJECT_ROOT = $PSScriptRoot
$DEFAULT_JDK  = "C:\Program Files\Java\jdk-23"
$FIREBASE_PATH = Join-Path $PROJECT_ROOT "android\app\google-services.json"
$KEYPROPS_PATH = Join-Path $PROJECT_ROOT "android\key.properties"
$APK_DIR = Join-Path $PROJECT_ROOT "build\app\outputs\flutter-apk"
$AAB_DIR = Join-Path $PROJECT_ROOT "build\app\outputs\bundle\$BuildType"

# Logs live OUTSIDE build\ so "flutter clean" does not delete them mid-run
$LOG_DIR  = Join-Path $PROJECT_ROOT ".build-logs"
$LOG_FILE = Join-Path $LOG_DIR ("build-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

$STOPWATCH = [System.Diagnostics.Stopwatch]::StartNew()
$TranscriptStarted = $false

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host ">> $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message)   { Write-Host "[OK]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }

function Invoke-Checked {
    param(
        [Parameter(Mandatory)][string]$Command,
        [string[]]$Arguments = @()
    )

    Write-Host "> $Command $($Arguments -join ' ')" -ForegroundColor DarkGray
    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "'$Command $($Arguments -join ' ')' failed with exit code $LASTEXITCODE"
    }
}

function Resolve-JavaHome {
    # Priority: -JavaHome parameter > default JDK > JAVA_HOME env > Android Studio JBR > any installed JDK
    $candidates = @()

    if ($JavaHome) { $candidates += $JavaHome }
    $candidates += $DEFAULT_JDK
    if ($env:JAVA_HOME) { $candidates += $env:JAVA_HOME }
    $candidates += "C:\Program Files\Android\Android Studio\jbr"

    $javaRoot = "C:\Program Files\Java"
    if (Test-Path $javaRoot) {
        $candidates += Get-ChildItem $javaRoot -Directory -Filter "jdk*" -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object { $_.FullName }
    }

    foreach ($path in $candidates) {
        if ($path -and (Test-Path (Join-Path $path "bin\java.exe"))) {
            return $path
        }
    }
    return $null
}

function Get-JavaMajorVersion([string]$JdkPath) {
    # java -version prints to stderr; relax error handling just for this call
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & (Join-Path $JdkPath "bin\java.exe") -version 2>&1 | ForEach-Object { "$_" }
    }
    finally {
        $ErrorActionPreference = $previous
    }

    $first = $output | Select-Object -First 1
    if ($first -match '"(\d+)(?:\.(\d+))?') {
        if ($Matches[1] -eq "1") { return [int]$Matches[2] }   # "1.8.0" -> 8
        return [int]$Matches[1]
    }
    return $null
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
try {
    if (-not (Test-Path $LOG_DIR)) { New-Item -ItemType Directory -Path $LOG_DIR | Out-Null }
    Start-Transcript -Path $LOG_FILE | Out-Null
    $TranscriptStarted = $true

    Set-Location $PROJECT_ROOT

    $outputKind = if ($Bundle) { "AAB (App Bundle)" } elseif ($SplitPerAbi) { "APK (split per ABI)" } else { "APK" }

    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   Yharbid Android Build System"        -ForegroundColor Cyan
    Write-Host "   Mode:   $BuildType"                  -ForegroundColor Cyan
    Write-Host "   Output: $outputKind"                 -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan

    # Sanity check: are we really in a Flutter project?
    if (-not (Test-Path (Join-Path $PROJECT_ROOT "pubspec.yaml"))) {
        throw "pubspec.yaml not found in $PROJECT_ROOT. Put build.ps1 in the Flutter project root."
    }

    if ($Bundle -and $SplitPerAbi) {
        Write-Warn "-SplitPerAbi is ignored when -Bundle is used (AAB already splits per device)."
        $SplitPerAbi = $false
    }

    # ---- Java ----
    Write-Step "Checking Java..."

    $jdk = Resolve-JavaHome
    if (-not $jdk) {
        throw "No JDK found. Install JDK 17, or pass one with -JavaHome 'C:\path\to\jdk'."
    }

    $env:JAVA_HOME = $jdk
    $env:Path = "$jdk\bin;$env:Path"

    $javaMajor = Get-JavaMajorVersion $jdk
    Write-Ok "JAVA_HOME = $jdk (Java $javaMajor)"

    if ($javaMajor -and $javaMajor -gt 21) {
        Write-Warn "JDK $javaMajor is very new for Gradle/Android. If you hit strange Gradle errors, try JDK 17 with -JavaHome."
    }
    elseif ($javaMajor -and $javaMajor -lt 17) {
        Write-Warn "JDK $javaMajor is old. Recent Android Gradle Plugin versions need JDK 17+."
    }

    # ---- Flutter ----
    Write-Step "Checking Flutter..."

    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw "'flutter' not found in PATH."
    }
    Invoke-Checked "flutter" @("--version")

    # ---- Firebase ----
    Write-Step "Checking Firebase configuration..."

    if ($SkipFirebaseCheck) {
        Write-Warn "Firebase check skipped."
    }
    elseif (Test-Path $FIREBASE_PATH) {
        Write-Ok "google-services.json found."
    }
    else {
        Write-Warn "google-services.json not found: $FIREBASE_PATH"
        $answer = Read-Host "Continue anyway? (y/n)"
        if ($answer -ne "y") { throw "Build cancelled by user." }
    }

    # ---- Release signing ----
    if ($BuildType -eq "release") {
        Write-Step "Checking release signing..."
        if (Test-Path $KEYPROPS_PATH) {
            Write-Ok "android\key.properties found."
        }
        else {
            Write-Warn "android\key.properties not found. The release build may be signed with debug keys (not valid for Play Store)."
        }
    }

    # ---- Clean ----
    if ($Clean) {
        Write-Step "Cleaning build artifacts..."
        Invoke-Checked "flutter" @("clean")
    }

    # ---- Dependencies ----
    Write-Step "Getting dependencies..."
    Invoke-Checked "flutter" @("pub", "get")

    # ---- Remove stale outputs so an old file can never fake a success ----
    Write-Step "Preparing build..."
    if (Test-Path $APK_DIR) {
        Get-ChildItem $APK_DIR -Filter "app-*$BuildType*.apk" -ErrorAction SilentlyContinue |
            Remove-Item -Force
    }
    if (Test-Path $AAB_DIR) {
        Get-ChildItem $AAB_DIR -Filter "*.aab" -ErrorAction SilentlyContinue |
            Remove-Item -Force
    }

    # ---- Build ----
    Write-Step "Building $outputKind ($BuildType)..."

    $buildArgs = @("build")
    if ($Bundle) { $buildArgs += "appbundle" } else { $buildArgs += "apk" }
    $buildArgs += "--$BuildType"
    if ($SplitPerAbi) { $buildArgs += "--split-per-abi" }

    Invoke-Checked "flutter" $buildArgs

    # ---- Verify ----
    Write-Step "Verifying output..."

    if ($Bundle) {
        $outputs = @(Get-ChildItem $AAB_DIR -Filter "*.aab" -ErrorAction SilentlyContinue)
    }
    else {
        $outputs = @(Get-ChildItem $APK_DIR -Filter "app-*$BuildType.apk" -ErrorAction SilentlyContinue)
    }

    if ($outputs.Count -eq 0) { throw "No output file was generated." }

    foreach ($f in $outputs) {
        if ($f.Length -eq 0) { throw "Output file is empty: $($f.FullName)" }
    }

    # ---- Success ----
    $STOPWATCH.Stop()

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "          BUILD SUCCESSFUL"             -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Mode: $BuildType" -ForegroundColor Cyan

    foreach ($f in $outputs) {
        $size = [math]::Round($f.Length / 1MB, 2)
        Write-Host "File: $($f.FullName)  ($size MB)" -ForegroundColor Cyan
    }

    Write-Host ("Time: {0:mm\:ss}" -f $STOPWATCH.Elapsed) -ForegroundColor Cyan
    Write-Host "Log:  $LOG_FILE" -ForegroundColor DarkGray

    # ---- Optional install ----
    if ($Install) {
        Write-Step "Installing on device..."

        if ($Bundle) {
            Write-Warn "An AAB cannot be installed directly. Build an APK instead."
        }
        elseif ($outputs.Count -gt 1) {
            Write-Warn "Multiple split APKs were produced. Install one manually, e.g.: adb install -r <file>"
        }
        elseif (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
            Write-Warn "'adb' not found in PATH. Install manually: adb install -r `"$($outputs[0].FullName)`""
        }
        else {
            $devices = @(& adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\sdevice$" })
            if ($devices.Count -eq 0) {
                Write-Warn "No authorized device connected (check USB debugging)."
            }
            else {
                Invoke-Checked "adb" @("install", "-r", $outputs[0].FullName)
                Write-Ok "Installed."
            }
        }
    }
    else {
        Write-Host ""
        Write-Host "Install with:" -ForegroundColor Yellow
        if ($Bundle) {
            Write-Host "  Upload the .aab to Google Play Console" -ForegroundColor White
        }
        else {
            Write-Host "  adb install -r `"$($outputs[0].FullName)`"" -ForegroundColor White
            Write-Host "  (or re-run with -Install)" -ForegroundColor DarkGray
        }
    }
}
catch {
    $STOPWATCH.Stop()

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Red
    Write-Host "             BUILD FAILED"              -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ("Time: {0:mm\:ss}" -f $STOPWATCH.Elapsed) -ForegroundColor DarkGray
    Write-Host "Log:  $LOG_FILE" -ForegroundColor DarkGray

    $script:ExitCode = 1
}
finally {
    if ($TranscriptStarted) {
        try { Stop-Transcript | Out-Null } catch { }
    }
}

if ($script:ExitCode) { exit $script:ExitCode }
