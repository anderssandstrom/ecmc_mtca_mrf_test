# ecmc_mtca_mrf_test

## Notes from call with Jerzy
In the call with Jerzy we concluded that one maybe better way would be to syncronize the 1kHz cloc (to get timestamps directlly from evr in 1khz).
So basically there are two solutions:

1. time2ntp, shared memory, chrony, CLOCK_REALTIME (could also be used with ptp)

2. direct (would be best). Callbacks direct from mrf (over epics or direct from mrf)

Test both!

Jerzy could help to setup system in end of aug if I give him the host name.

Link to repository with examples (test those):
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/tree/master/cmds

Exacute these ones:
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/IocExamples/IocEvrLb/st.cmd
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/IocExamples/IocEvrLb/iocrc.iocsh

Not sure:
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/evr-mtca.cmd

The PCI id needs to be checked withn lspci command.

