# EasyDeamonizer
Simply watches over your application (start, restart, log, monitor, etc). a generic script to make sure that your appliation remains running properly.
Intentionally it uses process name instread of pid/lock file to prevent all its side effects and keep the script as simple and as stirghforward as possible, so it always works even when EasyDaemonizer itself is restarted.

## Features
- Starts the application and optionally a customized delay for each start
- Makes sure that only one instance is running
- Monitors CPU usage and restarts the app automatically when it reaches the defined threshold
- Setting EasyDeamonizer to run via cron to run it again if it's halted for any reason
- Logs its activity

Happy Forking :)
