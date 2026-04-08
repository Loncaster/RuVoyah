@echo off
chcp 1251 > nul
pushd "%~dp0" > nul

if not exist "adb.exe" goto :err1
echo .
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
echo .  
echo 4. Перезагрузите компьютер и запустите скрипт заново
echo Проверьте, что у вас не держит adb соединение что-то другое, например, Adb AppControl или установка Cunba
echo .  
echo 5. Установка на Windows 7 часто не работает
echo .  
adb -d wait-for-device
if not errorlevel 0 goto :err2

echo Начинаем отключение dm-verity
echo .
echo Переключение adb в режим root
echo .
adb -d root
timeout 10

echo Ожидание устройства
echo .
adb -d wait-for-device

echo Отключение verity
echo .
adb -d disable-verity
timeout 1

echo Машина сейчас перезагрузится
echo .
adb -d reboot
echo Дождитесь, пока устройство перезагрузится
echo .
echo После полной загрузки мультимедиа нажмите Enter для продолжения
pause >nul

echo .
echo Ожидание устройства
adb -d wait-for-device
echo .
echo Переключение adb в режим root
echo .
adb -d root
timeout 5

echo Ожидание устройства
echo .
adb -d wait-for-device

echo Перемонтирование файловой системы
echo .
adb -d remount
timeout 5

echo Отключение SELinux
echo .
adb -d shell setenforce 0
timeout 1