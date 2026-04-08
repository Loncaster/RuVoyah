#!/bin/sh

# Функция для запроса подтверждения с обработкой Y/N
confirm_action() {
    local prompt="$1"
    local default="$2"
    local response
    
    while true; do
        if [ "$default" = "Y" ]; then
            read -p "$prompt [Y/n] " response
        elif [ "$default" = "N" ]; then
            read -p "$prompt [y/N] " response
        else
            read -p "$prompt [y/n] " response
        fi
        
        response=${response:-$default}
        
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Пожалуйста, ответьте Y (да) или N (нет).";;
        esac
    done
}

chmod +x ./adb > /dev/null 2>&1
xattr com.apple.quarantine ./adb > /dev/null 2>&1
export PATH=$PATH:.

export LANG=ru_RU.UTF-8

echo Подготовливаем adb к работе
echo .
echo Если на этом этапе зависло:
echo .
echo 1. Ознакомьтесь с инструкцией https://voyahtweaks.ru/instruction
echo .
echo 2. Проверьте включен ли USB Debugging
echo Иногда помогает включить/выключить USB Debugging несколько раз
echo .
echo 3. Проверьте подходит ли кабель, наиболее рабочий вариант кабель A-A
echo Кабель C-A не работает на Маке, нужно использовать кабель A-A и переходник C-A
echo Сначала вставляется переходник C-A в Мак, потом в него вставляется кабель A-A и вставляется в машину
echo .
echo 4. Перезагрузите компьютер и запустите скрипт заново
echo Проверьте, что у вас не держит adb соединение что-то другое, например, установка Cunba
echo .
adb -d wait-for-device
if [ $? -ne 0 ]; then
    echo Не удалось выполнить adb соединение с машиной
    echo Возможно у вас уже запущено какое-то другое adb соединение
    echo Перезагрузите компьютер и запустите скрипт заново
    exit 2
fi

echo Начинаем отключение dm-verity
echo .
echo Переключение adb в режим root
echo .
adb -d root
sleep 10

echo Ожидание устройства
echo .
adb -d wait-for-device

echo Отключение verity
echo .
adb -d disable-verity
sleep 1

echo Машина сейчас перезагрузится
echo .
adb -d reboot
echo Дождитесь, пока устройство перезагрузится
echo .
read -p "После полной загрузки мультимедиа нажмите Enter для продолжения "

echo .
echo Ожидание устройства
echo .
adb -d wait-for-device
echo Переключение adb в режим root
echo .
adb -d root
sleep 5

echo Ожидание устройства
echo .
adb -d wait-for-device

echo Перемонтирование файловой системы
echo .
adb -d remount
sleep 5

echo Отключение SELinux
echo .
adb -d shell setenforce 0