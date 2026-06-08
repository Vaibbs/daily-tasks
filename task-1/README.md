\# Windows Server Health Check (Git Bash)



\## Overview



This script provides a lightweight automated server health check for Windows systems running Git Bash.



On first execution, the script automatically creates a Windows Task Scheduler job that runs every hour and generates a timestamped health report.



\## Features



The health check collects:



\* Disk usage and free space

\* Physical memory (RAM) usage

\* List of running Windows services

\* Disk health status (where supported)

\* Top memory-consuming processes

\* Timestamped report logging



\## Requirements



\* Windows 10 / Windows Server

\* Git Bash installed

\* PowerShell available

\* Permission to create Scheduled Tasks



\## Installation



1\. Copy `server\_health.sh` to a desired directory.

2\. Open Git Bash.

3\. Make the script executable:



```bash

chmod +x server\_health.sh

```



4\. Run the script once:



```bash

./server\_health.sh

```



The first run will:



\* Generate an initial health report

\* Create an hourly Scheduled Task named:



```text

HourlyServerHealthCheck

```



\## Log Files



Reports are stored in:



```text

./logs/

```



Example:



```text

logs/health\_SERVER01\_2026-06-08\_14-00-00.log

```



Each report contains:



\* Hostname

\* Timestamp

\* Disk utilization

\* Memory statistics

\* Running services

\* Disk health information

\* Top memory-consuming processes



\## Scheduled Task Management



View the task:



```cmd

schtasks /query /tn "HourlyServerHealthCheck"

```



Delete the task:



```cmd

schtasks /delete /tn "HourlyServerHealthCheck" /f

```



Run the task manually:



```cmd

schtasks /run /tn "HourlyServerHealthCheck"

```



\## Troubleshooting



\### Task Scheduler creation fails



Git Bash may rewrite Windows command arguments.



If this occurs, invoke `schtasks` using:



```bash

MSYS\_NO\_PATHCONV=1 schtasks ...

```



or



```bash

cmd.exe /c schtasks ...

```



\### SMART status unavailable



Some storage controllers do not expose SMART data through PowerShell. In this case the script will continue running and report that SMART information is unavailable.



\## Future Improvements



Potential enhancements include:



\* Email alerts

\* Threshold-based warnings

\* CSV metric export

\* Log retention and cleanup

\* Event Viewer monitoring

\* Service watchlists

\* SMART attribute reporting via smartctl



\## Author



Internal SysAdmin Utility – Git Bash Edition



