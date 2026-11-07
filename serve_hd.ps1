$root = 'D:\Trae-CN\temp_20261105_01'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:8777/')
try { $listener.Start() } catch { Write-Host "start failed: $_"; exit 1 }

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.svg'  = 'image/svg+xml'
  '.zip'  = 'application/zip'
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  try {
    $path = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath)
    if ($path -eq '/') { $path = '/drive3d.html' }
    $file = Join-Path $root ($path.TrimStart('/').Replace('/', '\'))
    if (Test-Path -LiteralPath $file -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $type = $mime[$ext]
      if (-not $type) { $type = 'application/octet-stream' }
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $res.ContentType = $type
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $body = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
      $res.ContentType = 'text/plain; charset=utf-8'
      $res.OutputStream.Write($body, 0, $body.Length)
    }
  } catch {
  } finally {
    $res.Close()
  }
}
