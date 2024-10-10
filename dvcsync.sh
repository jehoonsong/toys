#!/bin/bash

DAEMON_NAME="dvcsync"
LOGFILE="/content/.config/dvcsync.log"
PIDFILE="/var/run/${DAEMON_NAME}.pid"
MONITORING_PATH="/dvcstore/"
RSYNC_SOURCE="/dvcstore/"
RSYNC_TARGET="/dvc_drive/"

mkdir -p /content/.config

start() {
    if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
        echo "$DAEMON_NAME is already running"
        exit 0
    fi
    echo "Starting $DAEMON_NAME..."
    nohup inotifywait -m -r $MONITORING_PATH -e modify -e create -e delete | \
    while read path action file; do
        echo "Event detected: $action on $file"
        sleep 5
        rsync -avz $RSYNC_SOURCE $RSYNC_TARGET
    done > $LOGFILE 2>&1 &
    echo $! > $PIDFILE
    echo "$DAEMON_NAME started"
}

stop() {
    if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
        echo "Stopping $DAEMON_NAME..."
        kill -9 $(cat $PIDFILE)
        rm -f $PIDFILE
        echo "$DAEMON_NAME stopped"
    else
        echo "$DAEMON_NAME is not running"
    fi
}

status() {
    if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
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
