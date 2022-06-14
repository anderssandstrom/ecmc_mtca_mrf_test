#!/usr/bin/env iocsh.bash
#require(essioc)
require(mrfioc2)
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


mcoreThreadRuleAdd ecmc * * 2 EVRFIFO

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


######### INPUTS #########
# Trig-Ext-Sel changed from "Off" to "Edge", Code-Ext-SP changed from 0 to 10
dbpf $(SYSPV):UnivIn-0-Lvl-Sel "Active High"
dbpf $(SYSPV):UnivIn-0-Edge-Sel "Active Rising"
dbpf $(SYSPV):Out-RB00-Src-SP 61
dbpf $(SYSPV):UnivIn-0-Trig-Ext-Sel "Edge"
dbpf $(SYSPV):UnivIn-0-Trig-Back-Sel "Off"
dbpf $(SYSPV):UnivIn-0-Code-Ext-SP 21
dbpf $(SYSPV):UnivIn-0-Code-Back-SP 0

dbpf $(SYSPV):UnivIn-1-Lvl-Sel "Active High"
dbpf $(SYSPV):UnivIn-1-Edge-Sel "Active Rising"
dbpf $(SYSPV):Out-RB01-Src-SP 61
dbpf $(SYSPV):UnivIn-1-Trig-Ext-Sel "Edge"
dbpf $(SYSPV):UnivIn-1-Trig-Back-Sel "Off"
dbpf $(SYSPV):UnivIn-1-Code-Ext-SP 22
dbpf $(SYSPV):UnivIn-1-Code-Back-SP 0

dbpf $(SYSPV):UnivIn-2-Lvl-Sel "Active High"
dbpf $(SYSPV):UnivIn-2-Edge-Sel "Active Rising"
dbpf $(SYSPV):Out-RB02-Src-SP 61
dbpf $(SYSPV):UnivIn-2-Trig-Ext-Sel "Edge"
dbpf $(SYSPV):UnivIn-2-Trig-Back-Sel "Off"
dbpf $(SYSPV):UnivIn-2-Code-Ext-SP 23
dbpf $(SYSPV):UnivIn-2-Code-Back-SP 0

dbpf $(SYSPV):UnivIn-3-Lvl-Sel "Active High"
dbpf $(SYSPV):UnivIn-3-Edge-Sel "Active Rising"
dbpf $(SYSPV):Out-RB03-Src-SP 61
dbpf $(SYSPV):UnivIn-3-Trig-Ext-Sel "Edge"
dbpf $(SYSPV):UnivIn-3-Trig-Back-Sel "Off"
dbpf $(SYSPV):UnivIn-3-Code-Ext-SP 24
dbpf $(SYSPV):UnivIn-3-Code-Back-SP 0

dbpf $(SYSPV):EvtA-SP.OUT "@OBJ=EVR,Code=10" 
dbpf $(SYSPV):EvtA-SP.VAL 10 
dbpf $(SYSPV):EvtB-SP.OUT "@OBJ=EVR,Code=11" 
dbpf $(SYSPV):EvtB-SP.VAL 11 
dbpf $(SYSPV):EvtC-SP.OUT "@OBJ=EVR,Code=12" 
dbpf $(SYSPV):EvtC-SP.VAL 12
dbpf $(SYSPV):EvtD-SP.OUT "@OBJ=EVR,Code=13"
dbpf $(SYSPV):EvtD-SP.VAL 13
dbpf $(SYSPV):EvtE-SP.OUT "@OBJ=EVR,Code=14"
dbpf $(SYSPV):EvtE-SP.VAL 14
dbpf $(SYSPV):EvtF-SP.OUT "@OBJ=EVR,Code=15"
dbpf $(SYSPV):EvtF-SP.VAL 15
dbpf $(SYSPV):EvtG-SP.OUT "@OBJ=EVR,Code=16"
dbpf $(SYSPV):EvtG-SP.VAL 16
dbpf $(SYSPV):EvtH-SP.OUT "@OBJ=EVR,Code=17"
dbpf $(SYSPV):EvtH-SP.VAL 17
dbpf $(SYSPV):EvtH-SP.OUT "@OBJ=EVR,Code=18"
dbpf $(SYSPV):EvtH-SP.VAL 18
dbpf $(SYSPV):EvtH-SP.OUT "@OBJ=EVR,Code=19"
dbpf $(SYSPV):EvtH-SP.VAL 19
dbpf $(SYSPV):EvtH-SP.OUT "@OBJ=EVR,Code=20"
dbpf $(SYSPV):EvtH-SP.VAL 20



######### OUTPUTS #########
#Set up delay generator 0 to trigger on event 14
dbpf $(SYSPV):DlyGen-0-Width-SP 1000 #1ms
dbpf $(SYSPV):DlyGen-0-Delay-SP 0 #0ms
dbpf $(SYSPV):DlyGen-0-Evt-Trig0-SP 14

dbpf $(SYSPV):DlyGen-1-Evt-Trig0-SP 14
dbpf $(SYSPV):DlyGen-1-Width-SP 2860 #1ms
dbpf $(SYSPV):DlyGen-1-Delay-SP 0 #0ms

dbpf $(SYSPV):DlyGen-2-Width-SP 1000 #1ms
dbpf $(SYSPV):DlyGen-2-Delay-SP 0 #0ms
dbpf $(SYSPV):DlyGen-2-Evt-Trig0-SP 14

dbpf $(SYSPV):DlyGen-3-Width-SP 1000 #1ms
dbpf $(SYSPV):DlyGen-3-Delay-SP 0 #0ms
dbpf $(SYSPV):DlyGen-3-Evt-Trig0-SP 18

# 88052496/11073=7952Hz
dbpf $(SYSPV):PS-0-Div-SP 11073 
#dbpf $(SYSPV):Out-RB04-Src-SP "Pulser 2"
#dbpf $(SYSPV):Out-RB05-Src-SP "Pulser 2"
#dbpf $(SYSPV):Out-RB06-Src-SP "Pulser 2"
#dbpf $(SYSPV):Out-RB07-Src-SP "Pulser 2"
dbpf $(SYSPV):Out-RB04-Src-Scale-SP "Prescaler 0"
dbpf $(SYSPV):Out-RB05-Src-Scale-SP "Prescaler 0"
dbpf $(SYSPV):Out-RB06-Src-Scale-SP "Prescaler 0"
dbpf $(SYSPV):Out-RB07-Src-Scale-SP "Prescaler 0"


######## Sequencer #########
dbpf $(SYSPV):EndEvtTicks 4

# Load sequencer setup
dbpf $(SYSPV):SoftSeq-0-Load-Cmd 1

# Enable sequencer
dbpf $(SYSPV):SoftSeq-0-Enable-Cmd 1

# Select run mode, "Single" needs a new Enable-Cmd every time, "Normal" needs Enable-Cmd once
dbpf $(SYSPV):SoftSeq-0-RunMode-Sel "Normal"


# Use ticks or microseconds
dbpf $(SYSPV):SoftSeq-0-TsResolution-Sel "Ticks"

# Select trigger source for soft seq 0, trigger source 0, delay gen 0
dbpf $(SYSPV):SoftSeq-0-TrigSrc-0-Sel 0

# Commit all the settings for the sequnce
# commit-cmd by evrseq!!! 
dbpf $(SYSPV):SoftSeq-0-Commit-Cmd "1"

# Route 1 hz to ouput 0 instead of 14Hz (asm)
dbpf MCAG:TS-EVR-01:DlyGen-0-Evt-Trig0-SP 125
