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
target_dir="/system/product/overlay"

pause_for_exit() {
    read -r -p "Нажмите Enter для выхода..."
}

wait_for_reboot() {
    echo "Машина сейчас перезагрузится"
    ./adb -d reboot
    echo "Дождитесь, пока устройство перезагрузится."
    read -r -p "После полной загрузки мультимедиа нажмите Enter для продолжения "
}

echo "====================================================="
echo "  УСТАНОВКА РУССИФИКАЦИИ VOYAH FREE (рестайлинг/318)"
echo "====================================================="
echo ""

if [ ! -f "adb" ]; then
    echo "Не найден adb. Поместите скрипт в папку с adb!"
    pause_for_exit
    exit 1
fi

chmod +x adb

for package in "${packages[@]}"; do
    if [ ! -f "overlay apk/$package.apk" ]; then
        echo "Не найден файл \"$package.apk\" в папке \"overlay apk\"!"
        pause_for_exit
        exit 1
    fi
done

echo "Ожидание устройства..."
./adb -d wait-for-device

echo "Переключение adb в режим root..."
./adb -d root
sleep 5

echo "Ожидание устройства..."
./adb -d wait-for-device

echo "Отключение verity..."
./adb -d disable-verity
sleep 3

wait_for_reboot

echo "Переключение adb в режим root..."
./adb -d root >/dev/null

echo "Ожидание устройства..."
./adb -d wait-for-device

echo "Переключение adb в режим root..."
./adb -d root
sleep 5

echo "Ожидание устройства..."
./adb -d wait-for-device

echo "Разрешение записи в system..."
./adb -d remount
sleep 3

echo "Копирование overlays..."
for package in "${packages[@]}"; do
    ./adb -d push "overlay apk/$package.apk" "$target_dir/$package.apk"
done
sleep 2

echo "Установка прав для overlays..."
for package in "${packages[@]}"; do
    ./adb -d shell chown root:root "$target_dir/$package.apk"
    ./adb -d shell chmod 644 "$target_dir/$package.apk"
done

echo "Очистка кэша шрифтов..."
./adb -d shell rm -rf /data/system/font_cache
./adb -d shell rm -rf /data/fonts_cache
sleep 2

echo "Перезагрузка для регистрации overlays..."
./adb -d reboot
read -r -p "Дождитесь полной загрузки мультимедиа, затем нажмите Enter "

echo "Ожидание устройства после перезагрузки..."
./adb -d wait-for-device

echo "Переключение adb в режим root..."
./adb -d root
sleep 3
./adb -d wait-for-device

echo "Включение overlays..."
for package in "${packages[@]}"; do
    ./adb -d shell cmd overlay enable --user 0 "$package"
done
sleep 2

echo "Принудительное обновление UI ресурсов"
./adb -d shell cmd uimode night no
./adb -d shell cmd uimode night yes

echo "=============================================="
echo "Установка завершена!"
echo "=============================================="
echo ""
pause_for_exit
exit 0
