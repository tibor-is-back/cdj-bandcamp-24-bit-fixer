@echo off
setlocal enabledelayedexpansion

REM Check all WAV files in the given folder (default: current folder)
REM Usage:
REM   check.bat [--fix] [directory]

set FIX=false
set TARGET_DIR=.

REM Parse command line arguments
if "%1"=="--fix" (
    set FIX=true
    if not "%2"=="" set TARGET_DIR=%2
) else if not "%1"=="" (
    set TARGET_DIR=%1
)

echo Scanning WAV files in: %TARGET_DIR%
echo Fix mode: %FIX%
echo.

REM Find all WAV files and process them
for /r "%TARGET_DIR%" %%f in (*.wav) do (
    call :check_wav_file "%%f"
)

echo.
echo Done.
goto :eof

:check_wav_file
set "file=%~1"
echo File: %file%

REM Use PowerShell to read bytes 20-21 and convert to decimal
for /f "delims=" %%i in ('powershell -command "& {$bytes = [System.IO.File]::ReadAllBytes('%file%'); $byte20 = $bytes[20]; $byte21 = $bytes[21]; $value = $byte21 * 256 + $byte20; Write-Output $value}"') do set "dec_value=%%i"

echo   wFormatTag = !dec_value! (0x%dec_value:~-4,4%)

if !dec_value! neq 1 (
    echo   -^> Non-PCM format detected.
    if "%FIX%"=="true" (
        echo   -^> Fixing to PCM (0x0001).
        REM Use PowerShell to fix the file
        powershell -command "& {$bytes = [System.IO.File]::ReadAllBytes('%file%'); $bytes[20] = 1; $bytes[21] = 0; [System.IO.File]::WriteAllBytes('%file%', $bytes)}"
    )
) else (
    echo   -^> Already PCM.
)
echo.
goto :eof
