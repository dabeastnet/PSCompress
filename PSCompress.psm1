<#
.SYNOPSIS
Compresses and Base64-encodes a string.

.DESCRIPTION
The Compress-String function takes a large string input, such as the content of a file, compresses it using GZIP compression, 
and then encodes the compressed data in Base64. This process is particularly useful for preparing text data for safe 
transmission over networks or for storage in systems that may not handle binary data well.

.PARAMETER InputContent
The text to be compressed and encoded. This parameter accepts input directly or through the pipeline, enabling 
flexibility in how content is provided to the function.

.EXAMPLE
Compress-String -InputContent "This is a test string to compress"

Description
-----------
Compresses the provided string and outputs the compressed data in Base64-encoded format.

.EXAMPLE
Get-Content "D:\path\to\file.txt" -Raw | Compress-String

Description
-----------
Reads the entire content of 'file.txt' as a single string and pipes it to the Compress-String function. The 
function outputs the content compressed and Base64-encoded. Note: the -Raw parameter ensures the file being read as 1 string

.INPUTS
String
You can pipe a string to Compress-String.

.OUTPUTS
String
The function outputs a Base64-encoded string representing the compressed input.

.NOTES
This function is useful for preparing large text data for environments that require text-only formats or 
for reducing the size of text for storage and transmission.
https://github.com/dabeastnet/PSCompress
#>

function Compress-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputContent
    )

    Begin {
        # Initialize a memory stream for the entire process
        $outputStream = New-Object System.IO.MemoryStream
    }

    Process {
        try {
            # Convert the input content (entire file content) to byte array
            $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputContent)

            # Use GzipStream for compression
            $gzipStream = New-Object System.IO.Compression.GzipStream $outputStream, ([System.IO.Compression.CompressionMode]::Compress), $true
            $gzipStream.Write($inputBytes, 0, $inputBytes.Length)
            $gzipStream.Close()
        }
        catch {
            Write-Error "An error occurred during compression: $_"
        }
    }

    End {
        # Convert the compressed bytes back to a base64 string and output
        $compressedString = [Convert]::ToBase64String($outputStream.ToArray())
        $outputStream.Dispose()

        Write-Output $compressedString
    }
}

Export-ModuleMember -Function Compress-String

<#
.SYNOPSIS
Decompresses a Base64-encoded and GZIP-compressed string.

.DESCRIPTION
The Expand-String function takes a string input that has been compressed using GZIP compression and then encoded in Base64,
and reverses the process to restore the original text. This is particularly useful for decoding data that was prepared for
safe transmission or storage using the Compress-String function.

.PARAMETER InputContent
The Base64-encoded and compressed text to be decompressed. This parameter accepts input directly or through the pipeline,
allowing for flexibility in how content is provided to the function.

.EXAMPLE
$compressedString = Compress-String -InputContent "This is a test string to compress"
Expand-String -InputContent $compressedString

Description
-----------
Decompresses the Base64-encoded and compressed string back to its original form, "This is a test string to compress".

.EXAMPLE
$compressedContent = Get-Content "D:\path\to\compressedFile.txt" -Raw
Expand-String -InputContent $compressedContent

Description
-----------
Reads the entire content of a file containing Base64-encoded and compressed text, and decompresses it back to its original form.

.INPUTS
String
You can pipe a Base64-encoded string to Expand-String.

.OUTPUTS
String
The function outputs the decompressed string, restoring the original input of the Compress-String function.

.NOTES
This function is intended to be used with data that was compressed and encoded using the Compress-String function, allowing
for the safe reversal of the compression and encoding process.
https://github.com/dabeastnet/PSCompress
#>

function Expand-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputContent
    )

    process {
        try {
            # Decode the Base64-encoded input to get the compressed bytes
            $compressedBytes = [Convert]::FromBase64String($InputContent)

            # Initialize a memory stream with the compressed bytes
            $inputStream = New-Object System.IO.MemoryStream $compressedBytes, 0, $compressedBytes.Length

            # Prepare a GzipStream for decompression
            $gzipStream = New-Object System.IO.Compression.GzipStream $inputStream, ([System.IO.Compression.CompressionMode]::Decompress)

            # Initialize a buffer and memory stream to read the decompressed bytes
            $buffer = New-Object byte[] 1024
            $outputStream = New-Object System.IO.MemoryStream

            # Read the decompressed bytes into the buffer and write them to the output stream
            while (($read = $gzipStream.Read($buffer, 0, $buffer.Length)) -ne 0) {
                $outputStream.Write($buffer, 0, $read)
            }

            # Convert the decompressed bytes back to a string and output
            $decompressedString = [System.Text.Encoding]::UTF8.GetString($outputStream.ToArray())
            Write-Output $decompressedString
        }
        catch {
            Write-Error "An error occurred during decompression: $_"
        }
        finally {
            $gzipStream.Dispose()
            $inputStream.Dispose()
            $outputStream.Dispose()
        }
    }
}

Export-ModuleMember -Function Expand-String