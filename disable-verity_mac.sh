#!/bin/bash

export LANG=ru_RU.UTF-8
cd "$(dirname "$0")"

echo "====================================================="
echo "  ОТДЕЛЬНЫЙ disable-verity БОЛЬШЕ НЕ НУЖЕН"
echo "====================================================="
echo ""
echo "Теперь подготовка verity выполняется прямо внутри install_mac.sh."
echo "Для обычной установки запустите install_mac.sh из этой же папки."
echo ""
read -r -p "Нажмите Enter для выхода..."
exit 0
