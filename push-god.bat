@echo off
:loop
git push
if %ERRORLEVEL% EQU 0 goto success
echo Command failed, retrying...
timeout /t 5 /nobreak >nul
goto loop

:success
echo Command succeeded.
