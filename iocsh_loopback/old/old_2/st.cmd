#!/usr/bin/env iocsh.bash

epicsEnvSet "TOP" "$(E3_CMD_TOP)/"

iocshLoad "$(TOP)/iocrc.iocsh"

# [IOC] core
iocshLoad "$(mrfioc2_DIR)/evr.iocsh"      "P=$(PEVR),PCIID=$(PCIID),EVRDB=$(EVRDB=evr-mtca-300-univ.db)"
iocshLoad "$(mrfioc2_DIR)/evrevt.iocsh"   "P=$(PEVR),$(EVREVTARGS=)"
#mrmEvrLoopback EVR,1,1
#time2ntp("EVR", 2)

iocInit

iocshLoad "$(mrfioc2_DIR)/evr.r.iocsh" "P=$(PEVR), INTREF=$(INTREF=)"
iocshLoad "$(mrfioc2_DIR)/evrtclk.r.iocsh" "P=$(PEVR)"
iocshLoad "$(mrfioc2_DIR)/evrdlygen.r.iocsh" "P=$(PEVR),$(EVRDLYGENARGS=)"
iocshLoad "$(mrfioc2_DIR)/evrout.r.iocsh" "P=$(PEVR),$(EVROUTARGS=)"
iocshLoad "$(mrfioc2_DIR)/evrin.r.iocsh" "P=$(PEVR),$(EVRINARGS=)"
iocshLoad "$(TOP)/evrLb.test.r.iocsh" "P=$(PEVR)"
mrmEvrLoopback EVR,1,1
time2ntp("EVR", 2)

