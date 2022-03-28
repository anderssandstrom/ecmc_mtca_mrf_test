#!/usr/bin/env iocsh.bash
# ### Generic EVR (Do not modify this file)
# More details: https://gitlab.esss.lu.se/icshwi/evr-ess

## Common envs
epicsEnvSet "ENGINEER" "MCAG_ECMC"
epicsEnvSet "TOP" "$(E3_CMD_TOP)/"

# [localhost]
## [CHESS] configuration (https://chess.esss.lu.se) and node specific settings
iocshLoad "$(TOP)/iocrc.iocsh"

# [common] e3 modules
## pre-settings
epicsEnvSet "IOCNAME" "$(PEVR)"
epicsEnvSet "IOCDIR" "$(DIREVR)"
epicsEnvSet "AS_TOP" "$(E3_CMD_TOP)/autosave"
epicsEnvSet "LOG_SERVER_NAME" "172.16.107.59"
# All ro and experts rw
#epicsEnvSet "PATH_TO_ASG_FILES" "$(auth_DIR)"
#epicsEnvSet "ASG_FILENAME" "allro_exprw.acf"
## body
#$(CMNEN=)require essioc
#$(CMNEN=)iocshLoad("$(essioc_DIR)/common_config.iocsh")

# [IOC] core
iocshLoad "$(mrfioc2_DIR)/evr.iocsh"      "P=$(PEVR),PCIID=$(PCIID),EVRDB=$(EVRDB=evr-mtca-300-univ.db)"
dbLoadRecords "evr-databuffer-ess.db"     "P=$(PEVR)"
iocshLoad "$(mrfioc2_DIR)/evrevt.iocsh"   "P=$(PEVR),$(EVREVTARGS=)"

# [SIT] plugins
## ICSHWI-6250: SIT: ISrc-010Row:CnPw-U-005 FBIS-DLN01:Ctrl-EVR-01
$(SITMPSPLC="#")dbLoadRecords "evr-mps-plc-ess.db" "P=$(PEVR)"

# [user] settings - use this file to apply local customization
iocshLoad "$(TOP)/user.iocsh" "P=$(PEVR)"

iocInit

iocshLoad "$(mrfioc2_DIR)/evr.r.iocsh" "P=$(PEVR)"
$(EVRAMC2CLKEN=)iocshLoad "$(mrfioc2_DIR)/evrtclk.r.iocsh" "P=$(PEVR)"
iocshLoad "$(mrfioc2_DIR)/evrdlygen.r.iocsh" "P=$(PEVR),$(EVRDLYGENARGS=)"
iocshLoad "$(mrfioc2_DIR)/evrout.r.iocsh" "P=$(PEVR),$(EVROUTARGS=)"
iocshLoad "$(mrfioc2_DIR)/evrin.r.iocsh" "P=$(PEVR),$(EVRINARGS=)"

#- Get current time from system clock
dbpf $(PEVR):TimeSrc-Sel "Sys. Clock"
#- Set delay compensation to 70 ns, needed to avoid timesptamp issue
dbpf $(PEVR):DC-Tgt-SP 70
#- Set up the prescaler that will trigger the sequencer at 14 Hz
dbpf $(PEVR):PS-0-Div-SP 6289464
#- Set up the sequencer
#- Set the runmode to normal, so that the sequencer re-arms after it finishes running
dbpf $(PEVR):SoftSeq-0-RunMode-Sel "Normal"
#- Set the trigger of the sequencer as prescaler 0
dbpf $(PEVR):SoftSeq-0-TrigSrc-2-Sel "Prescaler 0"
#- Set the EGU (msec) for the delay
dbpf $(PEVR):SoftSeq-0-TsResolution-Sel "uSec"
#- Attach the soft sequence to a specific hardware sequence
dbpf $(PEVR):SoftSeq-0-Load-Cmd 1
#- Enable the sequencer
dbpf $(PEVR):SoftSeq-0-Enable-Cmd 1
#-
system("/bin/bash $(E3_CMD_TOP)/configure14Hz.sh $(PEVR)"



