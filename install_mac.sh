#!/bin/bash

set -euo pipefail

export LANG=ru_RU.UTF-8
cd "$(dirname "$0")"

overlay_dir="overlay apk"
target_dir="/vendor/overlay"
packages=(
  "ru.voyah.overlay.vehiclesetting"
  "ru.voyah.overlay.vehicle"
  "ru.voyah.overlay.setting"
  "ru.voyah.overlay.launcher"
  "ru.voyah.overlay.dvr"
  "ru.voyah.overlay.bluetoothphone"
  "ru.voyah.overlay.hiboard"
)

echo "====================================================="
echo "  Установка русификации VOYAH FREE"
echo "====================================================="
echo ""

if [ ! -f "adb" ]; then
    echo "Не найден adb. Убедитесь, что скрипт лежит в одной папке с adb."
    read -r -p "Нажмите Enter для выхода..."
    exit 1
fi

chmod +x adb

for package in "${packages[@]}"; do
    if [ ! -f "$overlay_dir/$package.apk" ]; then
        echo "Не найден файл \"$package.apk\" в папке \"$overlay_dir\"."
        read -r -p "Нажмите Enter для выхода..."
        exit 1
    fi
done

echo "Ожидание устройства..."
./adb wait-for-device

echo "Перезапускаем adb в режим root..."
./adb root
sleep 3

echo "Монтируем системный раздел..."
./adb remount
sleep 3

echo "Копирование overlays..."
for package in "${packages[@]}"; do
    ./adb push "$overlay_dir/$package.apk" "$target_dir/$package.apk"
done
sleep 2

echo "Установка прав на overlays..."
for package in "${packages[@]}"; do
    ./adb shell chown root:root "$target_dir/$package.apk"
    ./adb shell chmod 644 "$target_dir/$package.apk"
done

echo "Очистка кеша шрифтов..."
./adb shell rm -rf /data/system/font_cache
./adb shell rm -rf /data/fonts_cache
sleep 2

echo "Перезагрузка для применения overlays..."
./adb reboot

echo "Дождитесь полной загрузки системы и нажмите Enter."
read -r -p ""

echo "Ожидание устройства после перезагрузки..."
./adb wait-for-device

echo "Перезапускаем adb в режим root..."
./adb root
sleep 3
./adb wait-for-device

echo "Активация overlays..."
for package in "${packages[@]}"; do
    ./adb shell cmd overlay enable --user 0 "$package"
done
sleep 2

echo "Переключение UI режима для обновления интерфейса..."
./adb shell cmd uimode night no
./adb shell cmd uimode night yes

echo "=============================================="
echo "Установка завершена!"
echo "=============================================="
echo ""
read -r -p "Нажмите Enter для выхода..."
exit 0
