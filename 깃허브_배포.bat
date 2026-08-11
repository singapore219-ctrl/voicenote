@echo off
chcp 65001 >nul
title GitHub Pages deploy - AI Voice Note
cd /d "%~dp0"
setlocal enabledelayedexpansion

echo.
echo  ============================================
echo   AI Voice Note - GitHub Pages Deploy
echo  ============================================
echo.
echo   STEP 1. Create an EMPTY *public* repository:
echo           https://github.com/new
echo           - Repository name : voicenote
echo           - Public
echo           - Do NOT tick README / .gitignore / license
echo.
echo   Your GitHub ID is the name shown in your
echo   profile URL:  https://github.com/[ID]
echo   It is NOT your email address.
echo.

:ASKUSER
set "GHUSER="
set /p GHUSER=GitHub ID (not email):
if "%GHUSER%"=="" goto ASKUSER

echo %GHUSER%| findstr /C:"@" >nul
if not errorlevel 1 (
  echo.
  echo   [X] "%GHUSER%" looks like an email address.
  echo       Enter the GitHub ID only, e.g. hong-gildong
  echo.
  goto ASKUSER
)

echo %GHUSER%| findstr /C:"/" >nul
if not errorlevel 1 (
  echo.
  echo   [X] Do not include slashes. Enter the ID only.
  echo.
  goto ASKUSER
)

set "GHREPO="
set /p GHREPO=Repository name [voicenote]:
if "%GHREPO%"=="" set "GHREPO=voicenote"

echo.
echo   Checking github.com/%GHUSER% ...
set "UCODE=000"
for /f %%i in ('curl -s -o nul -m 15 -w "%%{http_code}" https://api.github.com/users/%GHUSER%') do set "UCODE=%%i"

if "%UCODE%"=="404" (
  echo.
  echo   [X] GitHub user "%GHUSER%" does not exist.
  echo       Open https://github.com and check the ID under your
  echo       profile picture, then run this script again.
  echo.
  pause
  exit /b 1
)
if not "%UCODE%"=="200" (
  echo   [!] Could not verify the ID ^(network/proxy^). Continuing anyway.
)

set "RCODE=000"
for /f %%i in ('curl -s -o nul -m 15 -w "%%{http_code}" https://api.github.com/repos/%GHUSER%/%GHREPO%') do set "RCODE=%%i"
if "%RCODE%"=="404" (
  echo.
  echo   [!] Repository "%GHUSER%/%GHREPO%" was not found.
  echo       If you have not created it yet, do STEP 1 first.
  echo       ^(A private repo also shows up as not found.^)
  echo.
  set "GO="
  set /p GO=Push anyway? [y/N]:
  if /i not "!GO!"=="y" (
    start "" https://github.com/new
    echo   Opened https://github.com/new - create the repo, then re-run.
    pause
    exit /b 1
  )
)

echo.
echo   Pushing to https://github.com/%GHUSER%/%GHREPO%
echo   A GitHub login window may open - please sign in.
echo.

git remote remove origin >nul 2>nul
git remote add origin https://github.com/%GHUSER%/%GHREPO%.git
git branch -M main
git push -u origin main

if errorlevel 1 (
  echo.
  echo   [FAILED] Push did not complete.
  echo     - Is the repository created and empty?
  echo     - Did the login window succeed?
  echo   Fix the issue and run this script again.
  echo.
  pause
  exit /b 1
)

echo.
echo  ============================================
echo   Push done. Two steps left, in the browser:
echo.
echo   1^) Settings ^> Pages  ^(opening now^)
echo      Source : Deploy from a branch
echo      Branch : main   folder: / ^(root^)   then Save
echo.
echo   2^) Wait about 1 minute, then open on the tablet:
echo      https://%GHUSER%.github.io/%GHREPO%/
echo  ============================================
echo.
start "" https://github.com/%GHUSER%/%GHREPO%/settings/pages
pause
