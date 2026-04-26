@echo off
title Ali-Smart Cleaner
color 0A

:: --- Auto Admin Elevation ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: --- Log File ---
set logFile=%~dp0cleaner_log.txt

:menu
cls
color 0B
echo =================================================
echo              ALI SMART CLEANER
echo =================================================
echo.
echo   [1] Normal Clean   (Fast ^& Safe)
echo   [2] Deep Clean     (Full Junk Clean)
echo   [3] Selective Clean
echo   [4] Show Disk Space
echo   [5] View Logs
echo   [6] Exit
echo.
echo -------------------------------------------------
set /p choice=Select option: 

if "%choice%"=="1" goto normal
if "%choice%"=="2" goto deep_confirm
if "%choice%"=="3" goto selective
if "%choice%"=="4" goto disk
if "%choice%"=="5" goto viewlog
if "%choice%"=="6" exit
goto menu

:: -------- Loading --------
:loading
set "msg=%~1"
setlocal EnableDelayedExpansion
for %%a in (.,..,...,....,.....) do (
    cls
    color 0A
    echo =================================================
    echo                 PROCESSING
    echo =================================================
    echo.
    echo         !msg! %%a
    echo.
    echo         Please wait...
    echo.
    echo =================================================
    timeout /t 1 >nul
)
endlocal
goto :eof

:: -------- Logging --------
:log
echo [%date% %time%] %~1 >> "%logFile%"
goto :eof

:: -------- NORMAL CLEAN --------
:normal
color 0A
call :log "Normal Clean Started"

call :loading Cleaning User Temp Files
del /s /f /q "%temp%\*" >nul 2>&1

call :loading Cleaning Windows Temp Files
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1

call :loading Emptying Recycle Bin
PowerShell -Command "Clear-RecycleBin -Force" >nul 2>&1

call :log "Normal Clean Completed"
goto done

:: -------- DEEP CLEAN CONFIRM --------
:deep_confirm
cls
color 0C
echo WARNING: Deep Clean removes system cache files.
echo It is safe but more aggressive.
echo.
set /p confirm=Are you sure? (Y/N): 

if /i "%confirm%"=="Y" goto deep
goto menu

:: -------- DEEP CLEAN --------
:deep
color 0E
call :log "Deep Clean Started"

call :loading Cleaning User Temp Files
del /s /f /q "%temp%\*" >nul 2>&1

call :loading Cleaning Windows Temp Files
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1

call :loading Cleaning Prefetch Files
del /s /f /q "C:\Windows\Prefetch\*" >nul 2>&1

call :loading Cleaning Thumbnail Cache
del /s /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*" >nul 2>&1

call :loading Flushing DNS Cache
ipconfig /flushdns >nul

call :loading Emptying Recycle Bin
PowerShell -Command "Clear-RecycleBin -Force" >nul 2>&1

call :log "Deep Clean Completed"
goto done

:: -------- SELECTIVE CLEAN --------
:selective
cls
color 0D
echo Select what to clean:
echo.
echo  [1] Temp Files
echo  [2] Windows Temp
echo  [3] Prefetch
echo  [4] Recycle Bin
echo  [5] Back
echo.
set /p opt=Choose:

if "%opt%"=="1" (
    call :loading Cleaning Temp Files
    del /s /f /q "%temp%\*" >nul 2>&1
    call :log "Selective Temp Cleaned"
)

if "%opt%"=="2" (
    call :loading Cleaning Windows Temp
    del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
    call :log "Selective Windows Temp Cleaned"
)

if "%opt%"=="3" (
    call :loading Cleaning Prefetch
    del /s /f /q "C:\Windows\Prefetch\*" >nul 2>&1
    call :log "Selective Prefetch Cleaned"
)

if "%opt%"=="4" (
    call :loading Emptying Recycle Bin
    PowerShell -Command "Clear-RecycleBin -Force" >nul 2>&1
    call :log "Selective Recycle Bin Cleared"
)

goto done

:: -------- DISK SPACE --------
:disk
cls
color 09
echo DISK SPACE INFORMATION:
echo.
wmic logicaldisk get size,freespace,caption
echo.
pause
goto menu

:: -------- VIEW LOG --------
:viewlog
cls
color 07
echo CLEANING LOGS:
echo.
if exist "%logFile%" (
    type "%logFile%"
) else (
    echo No logs found.
)
echo.
pause
goto menu

:: -------- DONE --------
:done
cls
color 0A
echo.
echo =================================================
echo        CLEANING COMPLETED SUCCESSFULLY
echo =================================================
echo.
echo Press any key to return to menu...
pause >nul
goto menu