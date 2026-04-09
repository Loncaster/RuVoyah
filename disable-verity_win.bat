@echo off
setlocal EnableExtensions
chcp 65001 > nul
pushd "%~dp0" > nul

echo =====================================================
echo   ОТДЕЛЬНЫЙ disable-verity БОЛЬШЕ НЕ НУЖЕН
echo =====================================================
echo.
echo Теперь подготовка verity выполняется прямо внутри install_win.bat.
echo Для обычной установки запустите install_win.bat из этой же папки.
echo.
pause
exit /b 0
