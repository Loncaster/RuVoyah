@echo off
chcp 1251 > nul
pushd "%~dp0" > nul

echo ====================================================
echo   УДАЛЕНИЕ РУСИФИКАЦИИ VOYAH
echo ====================================================
echo.

if not exist "adb.exe" (
    echo Не найден adb.exe. Поместите скрипт в папку с adb!
    pause
    exit /b
)

echo Ожидание устройства...
adb wait-for-device

echo Переключение adb в режим root...
adb root
timeout 3 > nul

echo Разрешение записи в system...
adb remount
timeout 3 > nul

adb wait-for-device

echo Отключение overlays...
adb shell cmd overlay disable --user 0 ru.voyah.overlay.vehiclesetting
adb shell cmd overlay disable --user 0 ru.voyah.overlay.vehicle
adb shell cmd overlay disable --user 0 ru.voyah.overlay.setting
adb shell cmd overlay disable --user 0 ru.voyah.overlay.launcher
adb shell cmd overlay disable --user 0 ru.voyah.overlay.dvr
adb shell cmd overlay disable --user 0 ru.voyah.overlay.bluetoothphone
adb shell cmd overlay disable --user 0 ru.voyah.overlay.hiboard
timeout 2 > nul

echo Удаление overlays из системного раздела...
adb shell rm -f /vendor/overlay/ru.voyah.overlay.vehiclesetting.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.vehicle.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.setting.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.launcher.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.dvr.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.bluetoothphone.apk
adb shell rm -f /vendor/overlay/ru.voyah.overlay.hiboard.apk

adb shell rm -f /system/product/overlay/ru.voyah.overlay.vehiclesetting.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.vehicle.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.setting.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.launcher.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.dvr.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.bluetoothphone.apk
adb shell rm -f /system/product/overlay/ru.voyah.overlay.hiboard.apk
timeout 2 > nul

echo Перезагрузка для окончательного применения изменений...
adb reboot


echo ==============================================
echo Русификация удалена!
echo ==============================================
echo.
pause
exit /b
