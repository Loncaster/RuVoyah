# RuVoyah

Русификация Voyah Free через overlay APK для штатных системных приложений.

## Что есть в репозитории

- исходный код overlay-проектов в [`source code`](source%20code)
- скрипты установки и удаления для Windows и macOS
- вспомогательные файлы `adb` для готового установочного архива
- документация для пользователей и переводчиков
- GitHub Actions для проверки pull request и сборки стабильных релизов

## Чего нет в репозитории

- штатных APK из автомобиля
- готовых overlay APK
- локальных `build/`, `.gradle/`, `local.properties`
- пользовательских архивов релиза

Штатные APK каждый переводчик должен извлекать из своего автомобиля самостоятельно.

## Как пользователю установить русификацию

Подробная инструкция: [docs/installation.md](docs/installation.md)

Коротко:

1. Скачайте стабильный релиз из GitHub Releases.
2. Распакуйте архив.
3. Запустите `install_win.bat` или `install_mac.sh`.

## Как внести перевод

Начните с:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [docs/contributor-guide.md](docs/contributor-guide.md)

Коротко:

- редактируйте только `translations/<app>/strings.xml`
- не редактируйте вручную `source code/<project>/app/src/main/res/values*/strings.xml`, эти файлы генерируются скриптами
- для локальной проверки перед установкой на автомобиль используйте `.\scripts\build-overlay.ps1 -App <app>`

## Релизы

- В `main` попадают только изменения после review.
- Каждый merge в `main` автоматически собирает стабильный архив установки.
- Preview-пакеты для проверки на автомобиле собираются по команде `/build` в pull request и не попадают в общие релизы.
- Схема версий: `MAJOR.MINOR`.
- `MINOR` увеличивается автоматически на каждом стабильном релизе.
- `MAJOR` меняется вручную через git-тег вида `major/N` на ветке `main`.

Подробности: [docs/release-process.md](docs/release-process.md)
