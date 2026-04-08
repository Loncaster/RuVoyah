@echo off
setlocal EnableExtensions
chcp 65001 > nul
pushd "%~dp0" > nul

set "PACKAGES=ru.voyah.overlay.vehiclesetting ru.voyah.overlay.vehicle ru.voyah.overlay.setting ru.voyah.overlay.launcher ru.voyah.overlay.dvr ru.voyah.overlay.bluetoothphone ru.voyah.overlay.hiboard"

echo ====================================================
echo   Удаление русификации VOYAH FREE
echo ====================================================
echo.

if not exist "adb.exe" (
    echo Не найден adb.exe. Убедитесь, что скрипт лежит в одной папке с adb.
    pause
    exit /b 1
)

echo Ожидание устройства...
adb wait-for-device

echo Перезапускаем adb в режим root...
adb root
timeout /t 3 > nul

echo Монтируем системный раздел...
adb remount
timeout /t 3 > nul
adb wait-for-device

echo Деактивация overlays...
for %%P in (%PACKAGES%) do (
    adb shell cmd overlay disable --user 0 %%P
)
timeout /t 2 > nul

echo Удаление overlays...
for %%P in (%PACKAGES%) do (
    adb shell rm -f /vendor/overlay/%%P.apk
    adb shell rm -f /system/product/overlay/%%P.apk
)
timeout /t 2 > nul

echo Перезагрузка для восстановления оригинального интерфейса...
adb reboot

echo ==============================================
echo Русификация удалена!
echo ==============================================
echo.
pause
exit /b 0
