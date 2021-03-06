# -----------------------------------------------------------------------------
# Detector Readout DEV-01
# -----------------------------------------------------------------------------
require mrfioc2
require evr_seq_calc

# -----------------------------------------------------------------------------
# Environment settings
# -----------------------------------------------------------------------------

epicsEnvSet("TOP", "$(E3_CMD_TOP)/..")

#iocshLoad("./iocsh/env-init.iocsh")
iocshLoad("$(mrfioc2_DIR)/env-init.iocsh")

epicsEnvSet("IOC", "Utg-Ymir:TS")
epicsEnvSet("SYS",          "$(IOC)")
epicsEnvSet("DEV",          "EVR-01")
epicsEnvSet("EPICS_CMDS",   "/opt/iocs")
epicsEnvSet("MRF_HW_DB",    "evr-pcie-300dc-ess.db")
epicsEnvSet("PCI_SLOT",     "1:0.0")
epicsEnvSet("PCIID",        "$(PCI_SLOT)")
epicsEnvSet("DEVICE",       "$(DEV)")
epicsEnvSet("EVR",          "$(DEV)")
epicsEnvSet("CHOP_SYS",     "Utg-Ymir:")
epicsEnvSet("CHOP_DRV",     "Chop-Drv-01")
epicsEnvSet("CHOP_EVR",     "TS-$(DEV):")
epicsEnvSet("BASEEVTNO",    "17")


# -----------------------------------------------------------------------------
# e3 Common databases, autosave, etc.
# -----------------------------------------------------------------------------
iocshLoad("$(E3_COMMON_DIR)/e3-common.iocsh")

# -----------------------------------------------------------------------------
# EVR PCI setup
# -----------------------------------------------------------------------------
iocshLoad("$(mrfioc2_DIR)/evr-pcie-300dc-init-tsbuf.iocsh", "S=$(IOC)-, DEV=$(DEV), PCIID=$(PCIID)")

# Make the EVR the time sources for the machine
time2ntp("$(EVR)", 2)

dbLoadRecords("mrmevrtsbuf.db","SYS=$(IOC)-, D=$(DEV)-00:, EVR=$(EVR), CODE=90, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
dbLoadRecords("mrmevrtsbuf.db","SYS=$(IOC)-, D=$(DEV)-01:, EVR=$(EVR), CODE=91, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
dbLoadRecords("mrmevrtsbuf.db","SYS=$(IOC)-, D=$(DEV)-02:, EVR=$(EVR), CODE=92, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")
dbLoadRecords("mrmevrtsbuf.db","SYS=$(IOC)-, D=$(DEV)-03:, EVR=$(EVR), CODE=93, TRIG=14, FLUSH=TimesRelPrevFlush, NELM=1000")

# Load the sequencer configuration script
iocshLoad("$(evr_seq_calc_DIR)/evr_seq_calc.iocsh", "P=$(CHOP_SYS), R=$(CHOP_DRV), EVR=$(CHOP_EVR), BASEEVTNO=$(BASEEVTNO)")

iocInit()

#iocshLoad("./iocsh/evr-run.iocsh", "IOC=$(IOC), DEV=$(DEV)")
iocshLoad("$(mrfioc2_DIR)/evr-run-tsbuf.iocsh", "IOC=$(IOC)-, DEV=$(DEV)")

dbpf $(SYS)-$(DEVICE):FracNsecDelta-SP 88052500

#fpgaevr
dbpf $(SYS)-$(DEVICE):DlyGen1-Evt-Trig0-SP 140
dbpf $(SYS)-$(DEVICE):DlyGen1-Width-SP 100
dbpf $(SYS)-$(DEVICE):OutFPUV06-Src-Pulse-SP "Pulser 1"
dbpf $(SYS)-$(DEVICE):EvtH-SP.OUT "@OBJ=EVR-01,Code=140"

##### mini chopper i/o ######

dbpf $(IOC)-$(DEV):EvtA-SP.OUT "@OBJ=$(EVR),Code=90" 
dbpf $(IOC)-$(DEV):EvtA-SP.VAL 90 
dbpf $(IOC)-$(DEV):EvtB-SP.OUT "@OBJ=$(EVR),Code=91" 
dbpf $(IOC)-$(DEV):EvtB-SP.VAL 91 
dbpf $(IOC)-$(DEV):EvtC-SP.OUT "@OBJ=$(EVR),Code=92" 
dbpf $(IOC)-$(DEV):EvtC-SP.VAL 92
dbpf $(IOC)-$(DEV):EvtD-SP.OUT "@OBJ=$(EVR),Code=93"
dbpf $(IOC)-$(DEV):EvtD-SP.VAL 93
dbpf $(IOC)-$(DEV):EvtE-SP.OUT "@OBJ=$(EVR),Code=14"
dbpf $(IOC)-$(DEV):EvtE-SP.VAL 14
dbpf $(IOC)-$(DEV):EvtF-SP.OUT "@OBJ=$(EVR),Code=140"
dbpf $(IOC)-$(DEV):EvtF-SP.VAL 15
dbpf $(IOC)-$(DEV):EvtG-SP.OUT "@OBJ=$(EVR),Code=125"
dbpf $(IOC)-$(DEV):EvtG-SP.VAL 16
dbpf $(IOC)-$(DEV):EvtH-SP.OUT "@OBJ=$(EVR),Code=17"
dbpf $(IOC)-$(DEV):EvtH-SP.VAL 17

# Trig-Ext-Sel changed from "Off" to "Edge", Code-Ext-SP changed from 0 to 10
# Trig-Ext-Sel changed from "Off" to "Edge", Code-Ext-SP changed from 0 to 10
dbpf $(SYS)-$(DEV):In0-Lvl-Sel "Active High"
dbpf $(SYS)-$(DEV):In0-Edge-Sel "Active Falling"
dbpf $(SYS)-$(DEV):OutFPUV00-Src-SP 61
dbpf $(SYS)-$(DEV):In0-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEV):In0-Code-Ext-SP 90

dbpf $(SYS)-$(DEV):In1-Lvl-Sel "Active High"
dbpf $(SYS)-$(DEV):In1-Edge-Sel "Active Rising"
dbpf $(SYS)-$(DEV):OutFPUV01-Src-SP 61
dbpf $(SYS)-$(DEV):In1-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEV):In1-Code-Ext-SP 91

dbpf $(SYS)-$(DEV):In2-Lvl-Sel "Active High"
dbpf $(SYS)-$(DEV):In2-Edge-Sel "Active Rising"
dbpf $(SYS)-$(DEV):OutFPUV02-Src-SP 61
dbpf $(SYS)-$(DEV):In2-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEV):In2-Code-Ext-SP 92

dbpf $(SYS)-$(DEV):In3-Lvl-Sel "Active Low"
dbpf $(SYS)-$(DEV):In3-Edge-Sel "Active Falling"
dbpf $(SYS)-$(DEV):OutFPUV03-Src-SP 61
dbpf $(SYS)-$(DEV):In3-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEV):In3-Code-Ext-SP 93


#dbpf $(SYS)-$(DEV):UnivIn0-Lvl-Sel "Active High"
#dbpf $(SYS)-$(DEV):UnivIn0-Edge-Sel "Active Rising"
#dbpf $(SYS)-$(DEV):OutFPUV00-Src-SP 61
#dbpf $(SYS)-$(DEV):UnivIn0-Trig-Ext-Sel "Edge"
#dbpf $(SYS)-$(DEV):UnivIn0-Trig-Back-Sel "Off"
#dbpf $(SYS)-$(DEV):UnivIn0-Code-Ext-SP 10
#dbpf $(SYS)-$(DEV):UnivIn0-Code-Back-SP 0
#
#dbpf $(SYS)-$(DEV):UnivIn2-Lvl-Sel "Active High"
#dbpf $(SYS)-$(DEV):UnivIn2-Edge-Sel "Active Rising"
#dbpf $(SYS)-$(DEV):OutFPUV02-Src-SP 61
#dbpf $(SYS)-$(DEV):UnivIn2-Trig-Ext-Sel "Edge"
#dbpf $(SYS)-$(DEV):UnivIn2-Trig-Back-Sel "Off"
#dbpf $(SYS)-$(DEV):UnivIn2-Code-Ext-SP 92
#dbpf $(SYS)-$(DEV):UnivIn2-Code-Back-SP 0
#
#dbpf $(SYS)-$(DEV):UnivIn3-Lvl-Sel "Active Low"
#dbpf $(SYS)-$(DEV):UnivIn3-Edge-Sel "Active Falling"
#dbpf $(SYS)-$(DEV):OutFPUV03-Src-SP 61
#dbpf $(SYS)-$(DEV):UnivIn3-Trig-Ext-Sel "Edge"
#dbpf $(SYS)-$(DEV):UnivIn3-Trig-Back-Sel "Off"
#dbpf $(SYS)-$(DEV):UnivIn3-Code-Ext-SP 93
#dbpf $(SYS)-$(DEV):UnivIn3-Code-Back-SP 0



#Set up delay generator 0 to trigger on event 14
dbpf $(IOC)-$(DEV):DlyGen0-Width-SP 2860 
dbpf $(IOC)-$(DEV):DlyGen0-Delay-SP 0 #0ms
dbpf $(IOC)-$(DEV):DlyGen0-Evt-Trig0-SP 14

#Set up delay generator 2 to trigger on event 17
dbpf $(SYS)-$(DEV):DlyGen2-Width-SP 1000 #1ms
dbpf $(SYS)-$(DEV):DlyGen2-Delay-SP 0 #0ms
dbpf $(SYS)-$(DEV):DlyGen2-Evt-Trig0-SP 17
dbpf $(SYS)-$(DEV):OutFPUV04-Src-SP 2

#Set up delay generator 3 to trigger on event 125
dbpf $(SYS)-$(DEV):DlyGen3-Width-SP 1000 #1ms
dbpf $(SYS)-$(DEV):DlyGen3-Delay-SP 0 #0ms
dbpf $(SYS)-$(DEV):DlyGen3-Evt-Trig0-SP 125
dbpf $(SYS)-$(DEV):OutFPUV05-Src-SP 3


######## Sequencer #########
#dbpf $(IOC)-$(DEV):Base-Freq 14.00000064
dbpf $(IOC)-$(DEV):End-Event-Ticks 4
# Load sequencer setup
dbpf $(IOC)-$(DEV):SoftSeq0-Load-Cmd 1
# Enable sequencer
dbpf $(IOC)-$(DEV):SoftSeq0-Enable-Cmd 1
# Select run mode, "Single" needs a new Enable-Cmd every time, "Normal" needs Enable-Cmd once
dbpf $(IOC)-$(DEV):SoftSeq0-RunMode-Sel "Normal"
# Use ticks or microseconds
dbpf $(IOC)-$(DEV):SoftSeq0-TsResolution-Sel "Ticks"
# Select trigger source for soft seq 0, trigger source 0, delay gen 0
dbpf $(IOC)-$(DEV):SoftSeq0-TrigSrc-0-Sel 0
# Commit all the settings for the sequnce
# commit-cmd by evrseq!!! 
epicsThreadSleep 2
dbpf $(IOC)-$(DEV):SoftSeq0-Commit-Cmd "1"

