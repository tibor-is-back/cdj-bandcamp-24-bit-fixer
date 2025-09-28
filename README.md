# Bandcamp 24 Bit wav format fix for CDJs

Did you run into the issue that you prepared a nice set but then when you put the USB into the CDJ it gave an error? 

Some WAV files from Bandcamp don’t play on Pioneer (AlphaTheta) CDJs. The issue isn’t bit depth but format: these files use enhanced multichannel audio instead of standard PCM. CDJs check the wFormatTag at the start of the file to decide how to read it, and when it’s set to the extended format, they fail.

Older workarounds involved converting to 16-bit, but that’s unnecessary—CDJs handle 24-bit just fine. The real fix is simply flipping that format flag. This repository provides a script that does exactly that.

The fix works for all CDJ players supporting 24 bit (CDJ 2000 / 900 and onwards).

## Overview

This script checks WAV files in the specified directory to determine if they are in the right format and it optionally fixes them.

## Installation

### 1. Download the Script

Save the `check.sh` file to your desired location.

### 2. Make the Script Executable in the terminal

```bash
chmod +x check.sh
```

This command gives the script execute permissions, allowing you to run it directly.

## Usage

### Basic Syntax

```bash
./check.sh [--fix] [directory]
```

### Parameters

- `--fix` (optional): Automatically convert wav files to correct format
- `directory` (optional): Target directory to scan (defaults to current directory)

### Examples

#### Check files in current directory (read-only)
```bash
./check.sh
```

#### Check files in a specific directory
```bash
./check.sh /path/to/your/audio/files
```

#### Check and fix files in current directory
```bash
./check.sh --fix
```

#### Check and fix files in a specific directory
```bash
./check.sh --fix /path/to/your/audio/files
```

## How It Works

### 1. File Discovery
The script uses `find` to locate all `.wav` files (case-insensitive) in the target directory.

### 2. Format Analysis
For each WAV file, the script:
- Extracts bytes 20-21 from the WAV header (the `wFormatTag` field)
- Converts the little-endian bytes to decimal
- Checks if the value equals 1 (PCM format)

### 3. Reporting
- **PCM files**: Reports "Already PCM"
- **Non-PCM files**: Reports "Non-PCM format detected"

### 4. Fixing (when `--fix` is used)
- Uses `dd` to overwrite bytes 20-21 with `\x01\x00` (little-endian 0x0001)
- Converts the file to PCM format

## Sample Output

```
Scanning WAV files in: ./audio
Fix mode: false

File: ./audio/sample1.wav
  wFormatTag = 1 (0x0001)
  -> Already PCM.

File: ./audio/sample2.wav
  wFormatTag = 3 (0x0003)
  -> Non-PCM format detected.
```

## Technical Details

### WAV Header Format
The script specifically checks the `wFormatTag` field at offset 20-21 in the WAV header:
- **Offset 20-21**: Format tag (2 bytes, little-endian)
- **Value 1 (0x0001)**: PCM format
- **Other values**: Non-PCM formats (e.g., 3 = IEEE float, 6 = A-law, 7 = μ-law)

### Safety Features
- Uses `conv=notrunc` to prevent file truncation during fixes
- Only modifies the format tag, preserving audio data
- Provides clear feedback about all operations

## Troubleshooting

### Permission Issues
If you get "Permission denied" errors:
```bash
chmod +x check.sh
```

### Script Not Found
If you get "command not found":
```bash
./check.sh
```
Make sure you're in the correct directory and use `./` prefix.

### No WAV Files Found
The script will complete silently if no `.wav` files are found in the target directory.

## Windows Alternative

A Windows batch script equivalent (`check.bat`) is also available for Windows users. See the `check.bat` file for Windows-specific usage instructions. 

## License

This script is provided as-is for educational and utility purposes.
