#!/bin/bash

DAEMON_NAME="dvcsync"
LOGFILE="/content/.config/dvcsync.log"
PIDFILE="/var/run/${DAEMON_NAME}.pid"
MONITORING_PATH="/opt/dvcstore/"
RSYNC_SOURCE="/opt/dvcstore/"
RSYNC_TARGET="/content/dvcstore/"
SYNC_INTERVAL=5

mkdir -p /content/.config

function is_running() {
    [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE) &> /dev/null
}

function sync_files() {
    rsync -avz $RSYNC_SOURCE $RSYNC_TARGET
}

function start() {
    if is_running; then
        echo "$DAEMON_NAME is already running"
        exit 0
    fi
    echo "Starting $DAEMON_NAME..."
    sync_files
    nohup inotifywait -m -r $MONITORING_PATH -e modify -e create -e delete | \
    while read path action file; do
        echo "Event detected: $action on $file"
        sleep $SYNC_INTERVAL
        sync_files
    done > $LOGFILE 2>&1 &
    echo $! > $PIDFILE
    echo "$DAEMON_NAME started"
}

function stop() {
    if is_running; then
        echo "Stopping $DAEMON_NAME..."
        kill -9 $(cat $PIDFILE)
        rm -f $PIDFILE
        echo "$DAEMON_NAME stopped"
    else
        echo "$DAEMON_NAME is not running"
    fi
}

function status() {
    if is_running; then
        echo "$DAEMON_NAME is running"
    else
        echo "$DAEMON_NAME is not running"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
