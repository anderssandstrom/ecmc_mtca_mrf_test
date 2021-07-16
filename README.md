# ecmc_mtca_mrf_test

## Notes from call with Jerzy
After call with Jerzy we concluded that one maybe better way would be to syncronize the 1kHz cloc (to get timestamps directlly from evr in 1khz).
So basically there are two solutions:

1. time2ntp 

2. direct (would be best)

Test both!

Jerzy could help to setup system in end of aug if I give him the host name.

Link to repository with examples (test those):
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/tree/master/cmds

Exacute these ones:
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/IocExamples/IocEvrLb/st.cmd
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/IocExamples/IocEvrLb/iocrc.iocsh

Not sure:
https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2/-/blob/master/cmds/evr-mtca.cmd

