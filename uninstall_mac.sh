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

echo "===================================================="
echo "  Удаление русификации VOYAH FREE"
echo "===================================================="
echo ""

if [ ! -f "adb" ]; then
    echo "Не найден adb. Убедитесь, что скрипт лежит в одной папке с adb."
    read -r -p "Нажмите Enter для выхода..."
    exit 1
fi

chmod +x adb

echo "Ожидание устройства..."
./adb wait-for-device

echo "Перезапускаем adb в режим root..."
./adb root
sleep 3

echo "Монтируем системный раздел..."
./adb remount
sleep 3
./adb wait-for-device

echo "Деактивация overlays..."
for package in "${packages[@]}"; do
    ./adb shell cmd overlay disable --user 0 "$package"
done
sleep 2

echo "Удаление overlays..."
for package in "${packages[@]}"; do
    ./adb shell rm -f "/vendor/overlay/$package.apk"
    ./adb shell rm -f "/system/product/overlay/$package.apk"
done
sleep 2

echo "Перезагрузка для восстановления оригинального интерфейса..."
./adb reboot

echo "=============================================="
echo "Русификация удалена!"
echo "=============================================="
echo ""
read -r -p "Нажмите Enter для выхода..."
exit 0
