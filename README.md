# PSCompress

PSCompress is a PowerShell module that provides easy-to-use functions for compressing and decompressing strings. Utilizing GZIP compression and Base64 encoding, `PSCompress` ensures that your data is compacted for efficient storage or transmission and can be restored to its original state when needed.

## Features

- **Compress-String**: Compresses and Base64-encodes a given string, making it suitable for storage or transmission over text-based protocols.
- **Expand-String**: Decompresses and decodes a Base64-encoded string that was compressed with `Compress-String`, restoring the original text.

These functions are particularly useful in scenarios where you need to reduce the size of textual data for network transmission or when storing large amounts of text in a space-efficient manner. This works best for larger files (smaller files might end up bigger).

## Getting Started

To use PSCompress in your PowerShell sessions, follow these steps:

### Prerequisites

- PowerShell 5.1 or higher.

### Installation

1. Clone this repository or download the source code.
2. Import the module into your PowerShell session:

```powershell
Import-Module .\path\to\PSCompress.psm1
```

Replace `.\path\to\PSCompress.psm1` with the actual path to the `PSCompress.psm1` file.

You can also extract the functions in the seperated files

### Usage

**Compressing a String:**

```powershell
$compressedString = Compress-String -InputContent "This is a test string to compress"
```

**Decompressing a String:**

```powershell
$originalString = Expand-String -InputContent $compressedString
```

## Examples

**Compress and Decompress File Content:**

```powershell
# Compress content of a file
$compressedContent = Get-Content "D:\path\to\file.txt" -Raw | Compress-String

# Decompress the content back to its original form
$decompressedContent = $compressedContent | Expand-String
```

## Contributing

Contributions to PSCompress are welcome. Feel free to fork the repository, make your improvements, and submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the `COPYING` file for more details.