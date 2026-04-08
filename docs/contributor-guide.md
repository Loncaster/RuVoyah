# Инструкция для переводчиков

## 1. Определите целевое приложение

Если нужно понять, какое приложение сейчас открыто на автомобиле:

```bash
adb shell dumpsys window | grep -E 'mCurrentFocus|mFocusedApp'
```

Если `grep` недоступен, можно выполнить просто:

```bash
adb shell dumpsys window
```

и найти нужный пакет вручную.

## 2. Найдите путь к APK на автомобиле

Зная package name, выполните:

```bash
adb shell pm path com.qinggan.app.setting
```

Пример результата:

```text
package:/system/priv-app/Setting/Setting.apk
```

## 3. Скачайте APK с автомобиля

После того как получили путь, скачайте APK:

```bash
adb pull /system/priv-app/Setting/Setting.apk ./Setting.apk
```

Штатные APK не должны попадать в публичный репозиторий.

## 4. Извлеките строки из APK

Подойдут любые привычные Android-инструменты, например:

- `apktool`
- Android Studio / JADX / другие декомпиляторы ресурсов

Пример с `apktool`:

```bash
apktool d Setting.apk -o Setting_src
```

После этого ищите строки в:

```text
Setting_src/res/values*/strings.xml
```

## 5. Найдите нужный overlay-проект

Overlay-проекты лежат в [`source code`](../source%20code).

Ориентируйтесь по package name:

- `com.qinggan.app.setting` -> `ruvoyahoverlaysetting`
- `com.qinggan.app.launcher` -> `ruvoyahoverlaylauncher`
- `com.qinggan.app.vehicle` -> `ruvoyahoverlayvehicle`
- `com.qinggan.app.vehiclesetting` -> `ruvoyahoverlayvehiclesetting`
- `com.qinggan.app.hiboard` -> `ruvoyahoverlayhiboard`
- `com.qinggan.bluetoothphone` -> `ruvoyahoverlaybluetoothphone`
- `com.qinggan.dvr` -> `ruvoyahoverlaydvr`

## 6. Куда добавлять перевод

Основные места:

- `app/src/main/res/values/strings.xml`
- `app/src/main/res/values-en/strings.xml`
- `app/src/main/res/values-zh/strings.xml`
- `app/src/main/res/xml/overlays.xml`

Обычно:

- в `strings.xml` лежат сами переводы
- в `overlays.xml` задаётся соответствие штатным строкам приложения

Если нужной строки ещё нет, добавьте её в `strings.xml` и привяжите в `overlays.xml`.

## 7. Правило по длине строки

- Новый текст по возможности должен быть не длиннее английского или китайского оригинала.
- Если русский вариант длиннее, вы обязаны проверить его на реальном автомобиле до отправки PR.
- В PR обязательно укажите, что длинные строки были проверены на автомобиле.

Это важно, потому что слишком длинный текст может обрезаться, наезжать на соседние элементы или ломать layout.

## 8. Локальная сборка

Каждый overlay-проект собирается отдельно. Пример:

```powershell
cd "source code\\ruvoyahoverlaysetting"
.\gradlew.bat assembleDebug --no-daemon
```

Или на macOS/Linux:

```bash
cd "source code/ruvoyahoverlaysetting"
./gradlew assembleDebug --no-daemon
```

Готовый APK окажется в:

```text
app/build/outputs/apk/debug/
```

## 9. Preview в рамках PR

- Создайте свой fork репозитория.
- Внесите изменения в своём fork и откройте PR в основной репозиторий.
- В комментарии к PR напишите `/build`.
- После завершения workflow скачайте preview-пакет из artifact.
- Установите пакет на автомобиль и проверьте результат.
- После проверки отметьте checklist в PR.

## 10. Что писать в PR

Минимум:

- для какого штатного приложения сделан перевод
- какие строки добавлены или изменены
- есть ли строки длиннее оригинала
- были ли длинные строки проверены на автомобиле
- собран ли preview-пакет командой `/build` и проверен ли он на автомобиле

## 11. Чего делать не нужно

- не коммитьте штатные APK из автомобиля
- не коммитьте `build/`, `.gradle/`, `local.properties`
- не создавайте релизные архивы внутри репозитория
