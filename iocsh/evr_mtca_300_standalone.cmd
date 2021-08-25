require mrfioc2,2.2.1rc3

#- Channel Access environment configuration
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","10000000")

#- Example MACROS
epicsEnvSet("SYSSUB", "LAB-010")
epicsEnvSet("DISDEVID", "Ctrl-EVR-001")
epicsEnvSet("PREFIX", "$(SECSUB):$(DISDEVID):")

#- EVR PCI address
epicsEnvSet("PCIID", "08:00.0")

# Not use in this script, but it is needed for the expansion. 
epicsEnvSet("MainEvtCODE" "14")

#
# Record names follows the template "$(P)$(R=)$(S=:)Signal-SD"
# "P" is mandatory, "R" is optional (default empty), "S" is optional (defaul separator ":")
# "DEV" is a unique identifier of the EVR card used by mrfioc2 device support layer
#
iocshLoad("$(mrfioc2_DIR)/evr-mtca-300.iocsh", "P=$(PREFIX), S=, DEV=$(DISDEVID), PCIID=$(PCIID)")

# Make the EVR the time sources for the machine
time2ntp("$(DISDEVID)", 2)

iocInit()

# The following script should be called after iocInit()
iocshLoad("$(mrfioc2_DIR)/evr-standalone-mode.iocsh", "PREFIX=$(PREFIX)")

#dbpf TEST:Ctrl-EVR-001:TimeSrc-Sel 1

