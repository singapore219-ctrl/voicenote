@echo off
title AI Voice Note - local server (close this window to quit)
cd /d "%~dp0"

set PY=python
where python >nul 2>nul || set PY="%LOCALAPPDATA%\Programs\Python\Python313\python.exe"

echo.
echo   AI Voice Note is starting...
echo   Browser will open at http://localhost:8765/
echo   Keep this window open while using the app.
echo.

start "" http://localhost:8765/
%PY% -m http.server 8765 --bind 127.0.0.1
pause
