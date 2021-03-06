#!/usr/bin/env iocsh.bash

epicsEnvSet "PEVR" "LAB-MOT:Ctrl-EVR-1"

# [common]
epicsEnvSet "IOCNAME" "$(PEVR)"
epicsEnvSet "IOCDIR" "./"
epicsEnvSet "AS_TOP" "./"
epicsEnvSet "LOG_SERVER_NAME" "172.16.107.59"

require essioc
iocshLoad("$(essioc_DIR)/common_config.iocsh")

# [module]
require "mrfioc2" "2.3.1+1"
iocshLoad "$(mrfioc2_DIR)/evrEss.iocsh"     "P=$(PEVR),PCIID=08:00.0,INTPPS=,EXTPPS=#"
iocshLoad "$(mrfioc2_DIR)/seq0Ess.r.iocsh"  "P=$(PEVR)"
iocshLoad "$(mrfioc2_DIR)/evrGenericEss.load.r.iocsh" "P=$(PEVR)"
