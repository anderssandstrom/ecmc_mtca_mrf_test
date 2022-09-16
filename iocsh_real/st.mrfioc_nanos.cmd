#!/usr/bin/env iocsh.bash
#require(essioc)
#require mrfioc2 asm_add_nanos
require mrfioc2 nano

require(evr_seq_calc)
require(mcoreutils)

epicsEnvSet "PCIID" "8:00.0"

mcoreThreadRuleAdd mrf * * 2 EVRFIFO

epicsEnvSet("TOP", "$(E3_CMD_TOP)/..")

epicsEnvSet("IOC", "mcag-evr-01")
epicsEnvSet("SYS", "MCAG:")
epicsEnvSet("EVR", "EVR-01")
epicsEnvSet("DEV", "TS-$(EVR)")
epicsEnvSet("SYSPV", "$(SYS)$(DEV)")
epicsEnvSet("MRF_HW_DB", "evr-mtca-300-univ.db")
epicsEnvSet("BASEEVTNO", "21")
epicsEnvSet("BASEEVTNO", "21")
epicsEnvSet("CHOP_DRV", "ECMC")

# -----------------------------------------------------------------------------
# loading databases
# -----------------------------------------------------------------------------
# E3 Common databases
iocshLoad("$(essioc_DIR)/essioc.iocsh")
iocshLoad("$(mrfioc2_DIR)/evr.iocsh", "EVRDB=$(MRF_HW_DB), P=$(SYSPV), EVR=EVR, PCIID=$(PCIID)")
iocshLoad("$(mrfioc2_DIR)/evrevt.iocsh", "P=$(SYSPV)")

time2ntp("EVR", 2)
iocshLoad("$(cntpstats_DIR)/cntpstats.iocsh","SYS=$(SYS), DEV=$(DEV)")

iocInit()

iocshLoad("$(mrfioc2_DIR)/evr.r.iocsh", "P=$(SYSPV), EVR=EVR")
iocshLoad("$(mrfioc2_DIR)/evrdlygen.r.iocsh", "P=$(SYSPV), EVR=EVR")
iocshLoad("$(mrfioc2_DIR)/evrout.r.iocsh", "P=$(SYSPV), EVR=EVR")
iocshLoad("$(mrfioc2_DIR)/evrin.r.iocsh", "P=$(SYSPV), EVR=EVR")


######### OUTPUTS #########
#Set up delay generator 0 to trigger on event 14
dbpf $(SYSPV):DlyGen-0-Width-SP 1000 #1ms
dbpf $(SYSPV):DlyGen-0-Delay-SP 0 #0ms
dbpf $(SYSPV):DlyGen-0-Evt-Trig0-SP 125

