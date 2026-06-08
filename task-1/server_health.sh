#!/usr/bin/env bash

# Configuration

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

HOSTNAME=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

REPORT_FILE="$LOG_DIR/health_${HOSTNAME}_${TIMESTAMP}.log"

# First Run - Create Scheduled Task

TASK_NAME="HourlyServerHealthCheck"

# msys no path conv just prevents git bash from converting /create or /query to a path and causing everything to fail.
task_exists() {
    MSYS_NO_PATHCONV=1 schtasks /query /tn "$TASK_NAME" >/dev/null 2>&1
}

create_task() {

    SCRIPT_PATH="$(realpath "$0")"
    WIN_PATH=$(cygpath -w "$SCRIPT_PATH")

    MSYS_NO_PATHCONV=1 schtasks /create \
        /tn "$TASK_NAME" \
        /tr "\"C:\Program Files\Git\bin\bash.exe\" \"$WIN_PATH\"" \
        /sc hourly \
        /f

    echo "Scheduled task created: $TASK_NAME"
}

if ! task_exists; then
    echo "Creating hourly scheduled task..."
    create_task
fi

# Report Header

{
echo "========================================================="
echo "SERVER HEALTH REPORT"
echo "========================================================="
echo "Hostname : $HOSTNAME"
echo "Timestamp: $(date)"
echo
} >> "$REPORT_FILE"

# Disk Usage

{
echo "---------------------------------------------------------"
echo "DISK USAGE"
echo "---------------------------------------------------------"
df -h
echo
} >> "$REPORT_FILE"

# RAM Usage

{
echo "---------------------------------------------------------"
echo "MEMORY USAGE"
echo "---------------------------------------------------------"

powershell -NoProfile -Command "
\$os = Get-CimInstance Win32_OperatingSystem
\$total = [math]::Round(\$os.TotalVisibleMemorySize/1024,2)
\$free = [math]::Round(\$os.FreePhysicalMemory/1024,2)
\$used = [math]::Round(\$total-\$free,2)

Write-Output ('Total RAM : ' + \$total + ' MB')
Write-Output ('Used RAM  : ' + \$used + ' MB')
Write-Output ('Free RAM  : ' + \$free + ' MB')
"

echo
} >> "$REPORT_FILE"

# Running Services

{
echo "---------------------------------------------------------"
echo "RUNNING SERVICES"
echo "---------------------------------------------------------"

powershell -NoProfile -Command "
Get-Service |
Where-Object {\$_.Status -eq 'Running'} |
Sort-Object Name |
Select-Object Name,DisplayName |
Format-Table -AutoSize
"

echo
} >> "$REPORT_FILE"

# SMART STATUS

{
echo "---------------------------------------------------------"
echo "DISK HEALTH / SMART"
echo "---------------------------------------------------------"

powershell -NoProfile -Command "
try {
    Get-PhysicalDisk |
    Select-Object FriendlyName,HealthStatus,OperationalStatus |
    Format-Table -AutoSize
}
catch {
    Write-Output 'SMART information unavailable.'
}
"

echo
} >> "$REPORT_FILE"

# Top Processes

{
echo "---------------------------------------------------------"
echo "TOP MEMORY PROCESSES"
echo "---------------------------------------------------------"

powershell -NoProfile -Command "
Get-Process |
Sort-Object WS -Descending |
Select-Object -First 10 Name,Id,
@{N='MemoryMB';E={[math]::Round(\$_.WS/1MB,2)}} |
Format-Table -AutoSize
"

echo
} >> "$REPORT_FILE"

# Finish

{
echo "Report saved to:"
echo "$REPORT_FILE"
echo
} >> "$REPORT_FILE"

echo "Health report generated:"
echo "$REPORT_FILE"