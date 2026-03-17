#!/bin/bash
# gpu_snapshot.sh — Save and restore GPU process state for learning sessions
# Usage:
#   bash gpu_snapshot.sh save              # snapshot current state
#   bash gpu_snapshot.sh stop              # stop non-system GPU processes
#   bash gpu_snapshot.sh restore [file]    # restore from latest (or specified) snapshot
#   bash gpu_snapshot.sh status            # show current GPU processes

SNAP_DIR="$HOME/ai-engineer-2026/gpu_states"
mkdir -p "$SNAP_DIR"

# Processes that should NEVER be killed
PROTECTED_PROCS="Xorg|gnome-shell"

save_state() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snap_file="$SNAP_DIR/gpu_state_${timestamp}.txt"

    echo "=== GPU State Snapshot: $(date) ===" > "$snap_file"
    echo "" >> "$snap_file"

    echo "--- nvidia-smi output ---" >> "$snap_file"
    nvidia-smi >> "$snap_file" 2>&1
    echo "" >> "$snap_file"

    echo "--- Process Details ---" >> "$snap_file"
    # For each GPU process, save PID, command, working dir, and env
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null | while IFS=, read -r pid proc_name mem; do
        pid=$(echo "$pid" | xargs)
        proc_name=$(echo "$proc_name" | xargs)
        mem=$(echo "$mem" | xargs)

        echo "PID: $pid" >> "$snap_file"
        echo "  Process: $proc_name" >> "$snap_file"
        echo "  GPU Memory: $mem" >> "$snap_file"

        # Get full command line
        if [ -f "/proc/$pid/cmdline" ]; then
            cmdline=$(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null)
            echo "  Cmdline: $cmdline" >> "$snap_file"
        fi

        # Get working directory
        if [ -L "/proc/$pid/cwd" ]; then
            cwd=$(readlink /proc/$pid/cwd 2>/dev/null)
            echo "  CWD: $cwd" >> "$snap_file"
        fi

        # Get key environment variables
        if [ -f "/proc/$pid/environ" ]; then
            env_vars=$(tr '\0' '\n' < /proc/$pid/environ 2>/dev/null | grep -E '^(CUDA|PYTHON|VIRTUAL_ENV|CONDA|PATH=)' | head -10)
            if [ -n "$env_vars" ]; then
                echo "  Env:" >> "$snap_file"
                echo "$env_vars" | sed 's/^/    /' >> "$snap_file"
            fi
        fi

        # Check if it's a systemd service
        service=$(systemctl status "$pid" 2>/dev/null | head -1 | grep -oP '● \K\S+' || echo "none")
        echo "  Service: $service" >> "$snap_file"

        echo "" >> "$snap_file"
    done

    echo "--- Restart Commands (manual reference) ---" >> "$snap_file"
    echo "# Paste the exact restart commands for each service below:" >> "$snap_file"
    echo "# e.g.: cd /path/to/service && conda activate env && python script.py &" >> "$snap_file"
    echo "" >> "$snap_file"

    echo "Saved: $snap_file"
    echo ""
    echo "IMPORTANT: Review the snapshot and add restart commands manually"
    echo "for any services you plan to stop. Edit:"
    echo "  nano $snap_file"
}

stop_gpu_procs() {
    echo "Current GPU compute processes:"
    echo ""
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null | while IFS=, read -r pid proc_name mem; do
        pid=$(echo "$pid" | xargs)
        proc_name=$(echo "$proc_name" | xargs)
        mem=$(echo "$mem" | xargs)

        if echo "$proc_name" | grep -qE "$PROTECTED_PROCS"; then
            echo "  [PROTECTED] PID $pid  $proc_name  ($mem) — will NOT stop"
        else
            echo "  [STOPPABLE] PID $pid  $proc_name  ($mem)"
        fi
    done

    echo ""
    read -p "Stop all stoppable processes? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        nvidia-smi --query-compute-apps=pid,process_name --format=csv,noheader 2>/dev/null | while IFS=, read -r pid proc_name; do
            pid=$(echo "$pid" | xargs)
            proc_name=$(echo "$proc_name" | xargs)
            if ! echo "$proc_name" | grep -qE "$PROTECTED_PROCS"; then
                echo "Stopping PID $pid ($proc_name)..."
                kill -TERM "$pid" 2>/dev/null
            fi
        done
        sleep 3
        echo ""
        echo "Post-stop GPU state:"
        nvidia-smi
    else
        echo "Aborted."
    fi
}

restore_state() {
    local snap_file="$1"

    # Use latest if not specified
    if [ -z "$snap_file" ]; then
        snap_file=$(ls -t "$SNAP_DIR"/gpu_state_*.txt 2>/dev/null | head -1)
    fi

    if [ -z "$snap_file" ] || [ ! -f "$snap_file" ]; then
        echo "No snapshot found. Check $SNAP_DIR/"
        exit 1
    fi

    echo "=== Restore from: $snap_file ==="
    echo ""
    echo "--- Saved process details ---"
    sed -n '/--- Process Details ---/,/--- Restart Commands ---/p' "$snap_file" | head -60
    echo ""
    echo "--- Restart Commands ---"
    sed -n '/--- Restart Commands ---/,$p' "$snap_file"
    echo ""
    echo "Run the restart commands above manually, then verify with:"
    echo "  nvidia-smi"
    echo "  bash $0 status"
}

show_status() {
    echo "=== Current GPU State ==="
    nvidia-smi
    echo ""
    echo "=== Latest snapshot ==="
    local latest=$(ls -t "$SNAP_DIR"/gpu_state_*.txt 2>/dev/null | head -1)
    if [ -n "$latest" ]; then
        echo "File: $latest"
        echo "Taken: $(head -1 "$latest")"
    else
        echo "No snapshots found"
    fi
}

case "${1:-}" in
    save)    save_state ;;
    stop)    stop_gpu_procs ;;
    restore) restore_state "$2" ;;
    status)  show_status ;;
    *)
        echo "Usage: bash gpu_snapshot.sh {save|stop|restore [file]|status}"
        echo ""
        echo "Workflow:"
        echo "  1. bash gpu_snapshot.sh save      # before learning session"
        echo "  2. bash gpu_snapshot.sh stop       # free up GPUs"
        echo "  3. ... do your learning ..."
        echo "  4. bash gpu_snapshot.sh restore    # after session, see restart commands"
        ;;
esac
