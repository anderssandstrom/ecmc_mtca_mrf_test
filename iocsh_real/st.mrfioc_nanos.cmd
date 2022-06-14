#!/usr/bin/env iocsh.bash
#require(essioc)
require mrfioc2 asm_add_nanos
require(evr_seq_calc)
#require(cntpstats)
require(mcoreutils)

#require "mrfioc2" "2.3.1-beta.5"
#epicsEnvSet "LOCATION" "MCAG_LAB"
#epicsEnvSet "FBS" "??"
#epicsEnvSet "PEVR" "IOC_MRF_ECMC"
#epicsEnvSet "DIREVR" "/home/anderssandstrom/sources/e3ioc-mebtws-evr/aux/"
#epicsEnvSet "EVREVTARGS" "N0=F14Hz,E0=14,N1=LEBTCSt,E1=6,N2=LEBTCEnd,E2=7,N3=MEBTCSt,E3=8,N4=MEBTCEnd,E4=9,N5=IonMagSt,E5=10,N6=IonMagEnd,E6=11,N7=BPulseSt,E7=12,N8=BPulseEnd,E8=13,N9=RFSt,E9=15,NA=PMortem,EA=40,NB=PMortemSys,EB=41,NC=DoD,EC=42,ND=DoDSys,ED=43"
#epicsEnvSet "EVRDLYGENARGS" "W0=1000,E0T0=14,W1=1000,E1T0=15,W2=10,E2T0=12,W3=10,E3T0=13,W4=1000,E4T0=125,W5=1000,E5T0=40,W7=1000,E7T0=42,W8=10,E8T0=10,W9=10,E9T0=11,W10=10,E10T0=7,W11=10,E11T0=6"
#epicsEnvSet "EVROUTARGS" "BP0=0,BP1=1,BP2=49,BP3=4,BP4=5,BP6=7,FPUV0=52,FP0=53"
#epicsEnvSet "EVRINARGS" "BP5EN=,BPE5=41,BP7EN=,BPE7=43"
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

#time2ntp($(DEV), 2)

# -----------------------------------------------------------------------------
# loading databases
# -----------------------------------------------------------------------------
# E3 Common databases
iocshLoad("$(essioc_DIR)/essioc.iocsh")

iocshLoad("$(mrfioc2_DIR)/evr.iocsh", "EVRDB=$(MRF_HW_DB), P=$(SYSPV), EVR=EVR, PCIID=$(PCIID)")

iocshLoad("$(mrfioc2_DIR)/evrevt.iocsh", "P=$(SYSPV)")

#dbLoadRecords("mrmevrtsbuf-univ.db","P=$(SYSPV), R="", S=":00-", EVR=EVR, CODE=21, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
#dbLoadRecords("mrmevrtsbuf-univ.db","P=$(SYSPV), R="", S=":01-", EVR=EVR, CODE=22, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
#dbLoadRecords("mrmevrtsbuf-univ.db","P=$(SYSPV), R="", S=":02-", EVR=EVR, CODE=23, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
#dbLoadRecords("mrmevrtsbuf-univ.db","P=$(SYSPV), R="", S=":03-", EVR=EVR, CODE=24, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")

time2ntp("EVR", 2)

# Load the sequencer configuration script
#iocshLoad("$(evr_seq_calc_DIR)/evr_seq_calc.iocsh", "P=$(SYS), R=$(CHOP_DRV), EVR=$(DEV):, BASEEVTNO=$(BASEEVTNO)")

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

