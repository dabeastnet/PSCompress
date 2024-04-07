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
