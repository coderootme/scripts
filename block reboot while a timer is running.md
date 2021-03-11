==== test.timer: ====

     [Unit]
     Description=test timer
     Wants=multi-user.target
     After=multi-user.target

     [Timer]
     OnCalendar=*:0/1

     [Install]
     WantedBy=timers.target


==== test.service: ====

      [Unit]
      Description=test service

      [Service]
      Type=simple
      ExecStart=/root/test.sh
      #this should specify how long we wait to kill it:
      TimeoutStopSec=60


==== test.sh: ====

      #!/bin/bash

      trap '' SIGTERM SIGINT

      ... rest of script ...
