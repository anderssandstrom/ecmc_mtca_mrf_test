ts@Ctrl-EVR-1.service - IOC Ctrl-EVR-1
   Loaded: loaded (/etc/systemd/system/ts@.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-12-02 17:07:16 CET; 5 days ago
 Main PID: 29185 (procServ)
   CGroup: /system.slice/system-ts.slice/ts@Ctrl-EVR-1.service
           ├─29185 /usr/bin/procServ --foreground --logfile=procServ.log --info-file=/run/ioc@Ctrl-EVR-1/info --ignore=^C^D --chdir=/nfs/ts/nbs/Ctrl-EVR-1 --name=Ctrl-EVR-1 --port=unix:/run/ioc@Ctrl-EVR-1/control /nfs/ts/epics/base-7.0.5/require/3.4.1/bin/iocsh.bash /nfs/ts/nbs/Ctrl-EVR-1/st.cmd
           ├─29187 /bin/bash /nfs/ts/epics/base-7.0.5/require/3.4.1/bin/iocsh.bash /nfs/ts/nbs/Ctrl-EVR-1/st.cmd
           └─29222 /nfs/ts/epics/base-7.0.5/bin/linux-x86_64/softIocPVA -D /nfs/ts/epics/base-7.0.5/dbd/softIocPVA.dbd /tmp/systemd-private-e3-iocsh-iocuser/tmp.56uEjpvUYF_iocsh_-PID-29187
systemctl.log (END)

