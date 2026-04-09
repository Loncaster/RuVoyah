#!/bin/bash

set -euo pipefail

export LANG=ru_RU.UTF-8
cd "$(dirname "$0")"

packages=(
    "ru.voyah.overlay.vehiclesetting"
    "ru.voyah.overlay.vehicle"
    "ru.voyah.overlay.setting"
    "ru.voyah.overlay.launcher"
    "ru.voyah.overlay.dvr"
    "ru.voyah.overlay.bluetoothphone"
    "ru.voyah.overlay.hiboard"
)
target_dirs=(
    "/vendor/overlay"
    "/system/product/overlay"
)

pause_for_exit() {
    read -r -p "Нажмите Enter для выхода..."
}

echo "===================================================="
echo "  Удаление русификации VOYAH"
echo "===================================================="
echo ""

if [ ! -f "adb" ]; then
    echo "Не найден adb. Поместите скрипт в папку с adb!"
    pause_for_exit
    exit 1
fi

chmod +x adb

echo "Ожидание устройства..."
./adb -d wait-for-device

echo "Переключение adb в режим root..."
./adb -d root
sleep 3

echo "Разрешение записи в system..."
./adb -d remount
sleep 3
./adb -d wait-for-device

echo "Деактивация overlays..."
for package in "${packages[@]}"; do
    ./adb -d shell cmd overlay disable --user 0 "$package"
done
sleep 2

echo "Удаление overlays из системных разделов..."
for target_dir in "${target_dirs[@]}"; do
    for package in "${packages[@]}"; do
        ./adb -d shell rm -f "$target_dir/$package.apk"
    done
done
sleep 2

echo "Перезагрузка для восстановления оригинальной прошивки..."
./adb -d reboot

echo "=============================================="
echo "Русификация удалена!"
echo "=============================================="
echo ""
pause_for_exit
exit 0
