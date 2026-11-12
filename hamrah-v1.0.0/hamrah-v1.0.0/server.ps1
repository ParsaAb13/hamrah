# Minimal local web server for hamrah (no Python needed).
# It serves ONLY index.html, and only on localhost.
param([int]$Port = 8080)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$file = Join-Path $root 'index.html'
if (-not (Test-Path $file)) {
    Write-Host 'index.html was not found next to server.ps1'
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
try {
    $listener.Start()
} catch {
    Write-Host "Could not start the server on port ${Port}: $($_.Exception.Message)"
    exit 1
}
Write-Host "hamrah is running at http://localhost:$Port/  (close this window to stop)"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $path = $ctx.Request.Url.AbsolutePath
        if ($path -eq '/' -or $path -eq '/index.html') {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ctx.Response.ContentType = 'text/html; charset=utf-8'
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $ctx.Response.StatusCode = 404
        }
    } catch {
        # ignore broken connections
    } finally {
        $ctx.Response.Close()
    }
}
