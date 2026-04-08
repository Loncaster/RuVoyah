@echo off
setlocal EnableExtensions
chcp 65001 > nul
pushd "%~dp0" > nul

echo =====================================================
echo   УСТАНОВКА РУСИФИКАЦИИ VOYAH FREE (рестайлинг/318)
echo =====================================================
echo.

if not exist "adb.exe" (
    echo Не найден adb.exe. Поместите скрипт в папку с adb!
    pause
    exit /b 1
)

if not exist "overlay apk\ru.voyah.overlay.vehiclesetting.apk" (
    echo Не найден файл "ru.voyah.overlay.vehiclesetting.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.vehicle.apk" (
    echo Не найден файл "ru.voyah.overlay.vehicle.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.setting.apk" (
    echo Не найден файл "ru.voyah.overlay.setting.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.launcher.apk" (
    echo Не найден файл "ru.voyah.overlay.launcher.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.dvr.apk" (
    echo Не найден файл "ru.voyah.overlay.dvr.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.bluetoothphone.apk" (
    echo Не найден файл "ru.voyah.overlay.bluetoothphone.apk" в папке "overlay apk"!
    pause
    exit /b 1
)
if not exist "overlay apk\ru.voyah.overlay.hiboard.apk" (
    echo Не найден файл "ru.voyah.overlay.hiboard.apk" в папке "overlay apk"!
    pause
    exit /b 1
)

adb -d wait-for-device
echo Переключение adb в режим root
adb -d root
timeout /t 5 > nul

echo Ожидание устройства
adb -d wait-for-device

echo Отключение verity
adb -d disable-verity
timeout /t 3 > nul

echo Машина сейчас перезагрузится
adb -d reboot
call :wait-for

echo Переключение adb в режим root
adb -d root > nul

echo Ожидание устройства
adb -d wait-for-device

echo Переключение adb в режим root
adb -d root
timeout /t 5 > nul

echo Ожидание устройства...
adb wait-for-device

echo Переключение adb в режим root...
adb root
timeout /t 3 > nul

echo Разрешение записи в system...
adb remount
timeout /t 3 > nul

echo Копирование overlays...
adb push "overlay apk\ru.voyah.overlay.vehiclesetting.apk" "/system/product/overlay/ru.voyah.overlay.vehiclesetting.apk"
adb push "overlay apk\ru.voyah.overlay.vehicle.apk" "/system/product/overlay/ru.voyah.overlay.vehicle.apk"
adb push "overlay apk\ru.voyah.overlay.setting.apk" "/system/product/overlay/ru.voyah.overlay.setting.apk"
adb push "overlay apk\ru.voyah.overlay.launcher.apk" "/system/product/overlay/ru.voyah.overlay.launcher.apk"
adb push "overlay apk\ru.voyah.overlay.dvr.apk" "/system/product/overlay/ru.voyah.overlay.dvr.apk"
adb push "overlay apk\ru.voyah.overlay.bluetoothphone.apk" "/system/product/overlay/ru.voyah.overlay.bluetoothphone.apk"
adb push "overlay apk\ru.voyah.overlay.hiboard.apk" "/system/product/overlay/ru.voyah.overlay.hiboard.apk"
timeout /t 2 > nul

echo Установка прав для overlays...
adb shell chown root:root /system/product/overlay/ru.voyah.overlay.vehiclesetting.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.vehiclesetting.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.vehicle.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.vehicle.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.setting.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.setting.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.launcher.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.launcher.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.dvr.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.dvr.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.bluetoothphone.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.bluetoothphone.apk

adb shell chown root:root /system/product/overlay/ru.voyah.overlay.hiboard.apk
adb shell chmod 644 /system/product/overlay/ru.voyah.overlay.hiboard.apk

echo Очистка кэша шрифтов...
adb shell rm -rf /data/system/font_cache
adb shell rm -rf /data/fonts_cache
timeout /t 2 > nul

echo Перезагрузка для регистрации overlays...
adb reboot

echo Дождитесь полной загрузки мультимедиа, затем нажмите Enter
pause > nul

echo Ожидание устройства после перезагрузки...
adb wait-for-device

echo Переключение adb в режим root...
adb root
timeout /t 3 > nul
adb wait-for-device

echo Включение overlays...
adb shell cmd overlay enable --user 0 ru.voyah.overlay.vehiclesetting
adb shell cmd overlay enable --user 0 ru.voyah.overlay.vehicle
adb shell cmd overlay enable --user 0 ru.voyah.overlay.setting
adb shell cmd overlay enable --user 0 ru.voyah.overlay.launcher
adb shell cmd overlay enable --user 0 ru.voyah.overlay.dvr
adb shell cmd overlay enable --user 0 ru.voyah.overlay.bluetoothphone
adb shell cmd overlay enable --user 0 ru.voyah.overlay.hiboard
timeout /t 2 > nul

echo Принудительное обновление UI ресурсов
adb shell cmd uimode night no
adb shell cmd uimode night yes

echo ==============================================
echo Установка завершена!
echo ==============================================
echo.
pause
exit /b 0

:wait-for
echo Дождитесь, пока устройство перезагрузится.
echo После полной загрузки мультимедиа нажмите Enter для продолжения.
pause > nul
exit /b 0
