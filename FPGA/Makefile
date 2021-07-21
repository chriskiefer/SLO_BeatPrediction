# Project setup
PROJ      = iceSLOtest
BUILD     = ./build


# Files
FILES = iceSloTop.v ffnet.v lutNode.v

.PHONY: all clean burn

all:$(BUILD)/$(PROJ).bin

$(BUILD)/$(PROJ).bin: $(FILES) Makefile
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys for arachne
#	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	#yosys command for nextpnr
	yosys -p "synth_ice40 -top ffnet_top; write_json $(BUILD)/$(PROJ).json" $(FILES)
	# Place and route using arachne
#	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p pinmap_$(FOOTPRINT).pcf $(BUILD)/$(PROJ).blif
	# Place and route using nextpnr
	nextpnr-ice40 --hx8k --package ct256 --asc $(BUILD)/$(PROJ).asc --pcf ice40hx8k.pcf --json $(BUILD)/$(PROJ).json
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

burn:   $(BUILD)/$(PROJ).bin
	 iceprog $(BUILD)/$(PROJ).bin
	# source ./liveburn.sh
clean:
	rm -f build/*
