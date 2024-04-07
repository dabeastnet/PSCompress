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
