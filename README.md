# Marble GKI 5.10 Tuned Kernel Builder (Poco F5 / SM7475)

Автоматическая сборка кастомного ядра для Poco F5 (marble / marblein) на базе Google GKI 5.10.

## Что внутри этой сборки:
1. **Свежайший KernelSU-Next** (актуальная ветка `next`).
2. **Свежайший SuSFS v2.4.0** (ветка `gki-android12-5.10` от simonpunk) со всеми хуками скрытия.
3. **Google Clang Toolchain** (современный AOSP Clang).
4. **Тюнинг-пак из 38 флагов:**
   - 300 Гц тайминг под 120 Гц AMOLED экран.
   - BORE планировщик + PELT 16ms (мгновенный взлет до 2.91 ГГц).
   - Google BBR + FQ_CoDel (минимальный сетевой пинг без скачков).
   - Аппаратный TTL-фикс для бесплатной раздачи интернета на ПК.
   - FUSE-BPF для ускорения чтения накопителя UFS 3.1.
   - Boeffla Wakelock Blocker (0% жора батареи ночью).
   - Сохранение 100% отладочных логов (`DEBUG_INFO`, `BUGVERBOSE`, `KALLSYMS_ALL`, `PRINTK_TIME`, `PSTORE_RAM`, `DEBUG_FS`).
   - Отключение тормозящих костылей `FTRACE` и `SLUB_DEBUG`.

## Как запустить сборку на GitHub за 2 шага:
1. Загрузи содержимое этой папки в свой новый репозиторий на GitHub (например, `marble-kernel-builder`).
2. Перейди во вкладку **Actions** -> выбери воркфлоу **«Build Marble GKI Tuned Kernel»** -> нажми **«Run workflow»**.
3. Через 12-15 минут во вкладке Artifacts появится готовый к прошивке архив:
   `AnyKernel3-Marble-GKI-5.10-Tuned-SuSFS-v2.4.0.zip`.
