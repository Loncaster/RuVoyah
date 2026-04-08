@echo off
setlocal EnableExtensions
chcp 65001 > nul
pushd "%~dp0" > nul

set "OVERLAY_DIR=overlay apk"
set "TARGET_DIR=/vendor/overlay"
set "PACKAGES=ru.voyah.overlay.vehiclesetting ru.voyah.overlay.vehicle ru.voyah.overlay.setting ru.voyah.overlay.launcher ru.voyah.overlay.dvr ru.voyah.overlay.bluetoothphone ru.voyah.overlay.hiboard"

echo =====================================================
echo   Установка русификации VOYAH FREE
echo =====================================================
echo.

if not exist "adb.exe" (
    echo Не найден adb.exe. Убедитесь, что скрипт лежит в одной папке с adb.
    pause
    exit /b 1
)

for %%P in (%PACKAGES%) do (
    if not exist "%OVERLAY_DIR%\%%P.apk" (
        echo Не найден файл "%%P.apk" в папке "%OVERLAY_DIR%".
        pause
        exit /b 1
    )
)

echo Ожидание устройства...
adb wait-for-device

echo Перезапускаем adb в режим root...
adb root
timeout /t 3 > nul

echo Монтируем системный раздел...
adb remount
timeout /t 3 > nul

echo Копирование overlays...
for %%P in (%PACKAGES%) do (
    adb push "%OVERLAY_DIR%\%%P.apk" "%TARGET_DIR%/%%P.apk" || exit /b 1
)
timeout /t 2 > nul

echo Установка прав на overlays...
for %%P in (%PACKAGES%) do (
    adb shell chown root:root "%TARGET_DIR%/%%P.apk" || exit /b 1
    adb shell chmod 644 "%TARGET_DIR%/%%P.apk" || exit /b 1
)

echo Очистка кеша шрифтов...
adb shell rm -rf /data/system/font_cache
adb shell rm -rf /data/fonts_cache
timeout /t 2 > nul

echo Перезагрузка для применения overlays...
adb reboot
echo Дождитесь полной загрузки системы и нажмите Enter.
pause > nul

echo Ожидание устройства после перезагрузки...
adb wait-for-device

echo Перезапускаем adb в режим root...
adb root
timeout /t 3 > nul
adb wait-for-device

echo Активация overlays...
for %%P in (%PACKAGES%) do (
    adb shell cmd overlay enable --user 0 %%P || exit /b 1
)
timeout /t 2 > nul

echo Переключение UI режима для обновления интерфейса...
adb shell cmd uimode night no
adb shell cmd uimode night yes

echo ==============================================
echo Установка завершена!
echo ==============================================
echo.
pause
exit /b 0
