@echo off
chcp 65001 >nul
title GitHub Pages deploy - AI Voice Note
cd /d "%~dp0"

echo.
echo  ============================================
echo   AI Voice Note - GitHub Pages Deploy
echo  ============================================
echo.
echo   Before running this, create an EMPTY public
echo   repository at https://github.com/new
echo   (no README, no .gitignore, no license)
echo.

set /p GHUSER=GitHub username:
set /p GHREPO=Repository name [voicenote]:
if "%GHREPO%"=="" set GHREPO=voicenote

echo.
echo   Pushing to https://github.com/%GHUSER%/%GHREPO%
echo   A browser login window may open - sign in to GitHub.
echo.

git remote remove origin >nul 2>nul
git remote add origin https://github.com/%GHUSER%/%GHREPO%.git
git branch -M main
git push -u origin main

if errorlevel 1 (
  echo.
  echo   [FAILED] Check that the repository exists and is empty.
  echo.
  pause
  exit /b 1
)

echo.
echo  ============================================
echo   Push done. Two steps left, in the browser:
echo.
echo   1) https://github.com/%GHUSER%/%GHREPO%/settings/pages
echo      Source: "Deploy from a branch"
echo      Branch: main  /  folder: / (root)  -^> Save
echo.
echo   2) Wait ~1 minute, then open on the tablet:
echo      https://%GHUSER%.github.io/%GHREPO%/
echo  ============================================
echo.
start "" https://github.com/%GHUSER%/%GHREPO%/settings/pages
pause
