# 在 shell 中执行，需要 redis-server 在 PATH 中，且三个端口未被占用
labdir=$(mktemp -d "${TMPDIR:-/tmp}/redis-replication.XXXXXX")
for port in 7001 7002 7003; do
  mkdir -p "$labdir/$port"
  cat > "$labdir/$port/redis.conf" <<EOF
bind 127.0.0.1
port $port
daemonize yes
pidfile $labdir/$port/redis.pid
logfile $labdir/$port/redis.log
dir $labdir/$port
save ""
appendonly no
EOF
  redis-server "$labdir/$port/redis.conf"
  # daemonize 返回时监听端口可能尚未就绪
  for attempt in {1..50}; do
    redis-cli -p "$port" PING >/dev/null 2>&1 && break
    sleep 0.1
  done
  redis-cli -p "$port" PING >/dev/null || exit 1
done
