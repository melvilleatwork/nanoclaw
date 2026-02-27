#!/bin/bash
# NanoClaw management script

PLIST=~/Library/LaunchAgents/com.nanoclaw.plist
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$PROJECT_DIR/logs/nanoclaw.log"
ERR_LOG="$PROJECT_DIR/logs/nanoclaw.error.log"

case "${1:-help}" in
  start)
    launchctl load "$PLIST" 2>/dev/null
    echo "NanoClaw started"
    ;;
  stop)
    launchctl unload "$PLIST" 2>/dev/null
    echo "NanoClaw stopped"
    ;;
  restart)
    launchctl kickstart -k "gui/$(id -u)/com.nanoclaw"
    echo "NanoClaw restarted"
    ;;
  status)
    pid=$(launchctl list 2>/dev/null | grep com.nanoclaw | awk '{print $1}')
    if [ "$pid" != "" ] && [ "$pid" != "-" ]; then
      echo "NanoClaw is running (PID $pid)"
    else
      echo "NanoClaw is not running"
    fi
    ;;
  logs)
    tail -f "$LOG"
    ;;
  errors)
    tail -f "$ERR_LOG"
    ;;
  dev)
    launchctl unload "$PLIST" 2>/dev/null
    echo "Service stopped. Starting dev mode..."
    cd "$PROJECT_DIR" && npm run dev
    ;;
  build)
    cd "$PROJECT_DIR" && npm run build
    ;;
  rebuild-container)
    cd "$PROJECT_DIR" && ./container/build.sh
    ;;
  help|*)
    echo "Usage: nc <command>"
    echo ""
    echo "Commands:"
    echo "  start              Start the service"
    echo "  stop               Stop the service"
    echo "  restart            Restart the service"
    echo "  status             Check if running"
    echo "  logs               Tail the live logs"
    echo "  errors             Tail the error logs"
    echo "  dev                Stop service and run in dev mode"
    echo "  build              Compile TypeScript"
    echo "  rebuild-container  Rebuild the agent container image"
    ;;
esac
