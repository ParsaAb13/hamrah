@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
title hamrah
set PORT=8080

if not exist "index.html" (
  echo index.html was not found next to start.bat.
  pause
  exit /b 1
)

rem Find a working Python. The Microsoft Store "python" stub fails this test, which is what we want.
set "PYCMD="
python -c "pass" >nul 2>nul && set "PYCMD=python"
if not defined PYCMD (
  py -3 -c "pass" >nul 2>nul && set "PYCMD=py -3"
)

echo.
echo   hamrah  -  http://localhost:%PORT%
echo   Keep this window open while you use hamrah. Close it to stop.
echo.

rem Open the browser after the server has had a moment to start.
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://localhost:%PORT%/index.html'"

if defined PYCMD (
  %PYCMD% -m http.server %PORT% --bind 127.0.0.1
) else (
  echo   Python not found - using the built-in PowerShell server instead.
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port %PORT%
)

echo.
echo   The server stopped. If you see an error above, the port %PORT% may be in use.
pause
