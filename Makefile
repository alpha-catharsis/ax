SOURCE_DIR := ./src
SOURCE_SCRIPTS := $(wildcard $(SOURCE_DIR)/*.sh)

PROGRAM_DIR := ./bin
TARGET_PROGRAM := ax
TARGET_PROGRAM_PATH := $(PROGRAM_DIR)/$(TARGET_PROGRAM)

.PHONY: clean run

all: $(TARGET_PROGRAM_PATH)

$(TARGET_PROGRAM_PATH) : $(SOURCE_SCRIPTS)
	mkdir -p $(PROGRAM_DIR)
	cat $^ > $@
	chmod +x $@
	shellcheck $@

clean:
	rm -rfv $(PROGRAM_DIR)

run: | $(TARGET_PROGRAM_PATH)
	@printf "\n"
	@$(TARGET_PROGRAM_PATH)
