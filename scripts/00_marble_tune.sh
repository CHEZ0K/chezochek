#!/system/bin/sh
# ==============================================================================
# Poco F5 (marble) - Ultimate Runtime Optimization Script for Evolution X & KSU
# Location: /data/adb/service.d/00_marble_tune.sh
# Permissions: chmod +x (755)
# ==============================================================================

# Подождать 15 секунд после старта системы, пока Android полностью загрузится
sleep 15

# ------------------------------------------------------------------------------
# 1. Сетевой стек: BBR, очереди пакетов, ускорение TCP
# ------------------------------------------------------------------------------
sysctl -w net.core.default_qdisc=fq_codel
sysctl -w net.ipv4.tcp_congestion_control=bbr
sysctl -w net.ipv4.tcp_fastopen=3
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_fin_timeout=15

# ------------------------------------------------------------------------------
# 2. Виртуальная память (VM) и кэширование под ZRAM
# ------------------------------------------------------------------------------
# Агрессивно вытесняем спящие процессы в ZRAM (ОЗУ остается свободной)
sysctl -w vm.swappiness=100

# Отключаем блочное чтение страниц ZRAM (разжатие без задержек по 1 странице)
sysctl -w vm.page-cluster=0

# Быстрее очищаем кэши дескрипторов файлов вместо выгрузки приложений
sysctl -w vm.vfs_cache_pressure=150

# Пакетный сброс грязных страниц: убирает микрофризы UI при записи на UFS
sysctl -w vm.dirty_ratio=40
sysctl -w vm.dirty_background_ratio=5
sysctl -w vm.dirty_expire_centisecs=2000
sysctl -w vm.dirty_writeback_centisecs=1000

# ------------------------------------------------------------------------------
# 3. Накопитель UFS 3.1: минимизация задержек очередей ввода-вывода
# ------------------------------------------------------------------------------
for queue in /sys/block/sd*/queue; do
    if [ -d "$queue" ]; then
        # Выбираем легковесный планировщик под UFS (kyber или mq-deadline)
        if grep -q "kyber" "$queue/scheduler"; then
            echo kyber > "$queue/scheduler"
        elif grep -q "mq-deadline" "$queue/scheduler"; then
            echo mq-deadline > "$queue/scheduler"
        fi

        # Завершение I/O прерывания строго на том же ядре, где начато
        echo 2 > "$queue/rq_affinity"

        # Отключаем паразитные замеры и генерацию энтропии
        echo 0 > "$queue/add_random" 2>/dev/null || true
        echo 0 > "$queue/iostats" 2>/dev/null || true

        # Оптимальный буфер упреждающего чтения под размер страниц UFS
        echo 128 > "$queue/read_ahead_kb"
    fi
done

# ------------------------------------------------------------------------------
# 4. Графический стек SurfaceFlinger (снижение инпут-лага)
# ------------------------------------------------------------------------------
resetprop debug.sf.latch_unsignaled 1 2>/dev/null || true
