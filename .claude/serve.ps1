$port = if ($env:PORT) { $env:PORT } else { 5500 }
$root = Split-Path $PSScriptRoot -Parent
$url  = "http://localhost:$port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()
Write-Host "Serving $root at $url  (Ctrl+C to stop)"

$mimes = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css'
  '.js'   = 'application/javascript'
  '.json' = 'application/json'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.ico'  = 'image/x-icon'
  '.woff2'= 'font/woff2'
  '.woff' = 'font/woff'
}

while ($listener.IsListening) {
  $ctx  = $listener.GetContext()
  $req  = $ctx.Request
  $resp = $ctx.Response

  $path = $req.Url.LocalPath -replace '/', [IO.Path]::DirectorySeparatorChar
  $file = Join-Path $root $path.TrimStart([IO.Path]::DirectorySeparatorChar)
  if (Test-Path $file -PathType Container) { $file = Join-Path $file 'index.html' }

  if (Test-Path $file -PathType Leaf) {
    $ext  = [IO.Path]::GetExtension($file)
    $mime = if ($mimes[$ext]) { $mimes[$ext] } else { 'application/octet-stream' }
    $resp.ContentType = $mime
    $bytes = [IO.File]::ReadAllBytes($file)
    $resp.ContentLength64 = $bytes.Length
    $resp.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $resp.StatusCode = 404
  }
  $resp.OutputStream.Close()
}
