NASM := nasm
QEMU := qemu-system-i386
DD   := dd

BOOT_SRC   := boot.asm
STAGE2_SRC := stage2.asm
KERNEL_SRC := kernel.asm

BOOT_BIN   := boot.bin
STAGE2_BIN := stage2.bin
KERNEL_BIN := kernel.bin

LAYOUT := layout.inc
IMAGE  := os-image.img

SECTOR_SIZE    := 512
FLOPPY_SECTORS := 2880

STAGE1_LBA     := 0
STAGE1_SECTORS := 1

STAGE2_LBA     := 1
STAGE2_SECTORS := 2

KERNEL_LBA     := 3
KERNEL_SECTORS := 5

.PHONY: all image run clean

all: image

# Generate layout.inc from Makefile constants
$(LAYOUT):
	@printf "%%define SECTOR_SIZE %s\n" "$(SECTOR_SIZE)" > $@
	@printf "%%define STAGE1_LBA %s\n" "$(STAGE1_LBA)" >> $@
	@printf "%%define STAGE1_SECTORS %s\n" "$(STAGE1_SECTORS)" >> $@
	@printf "%%define STAGE2_LBA %s\n" "$(STAGE2_LBA)" >> $@
	@printf "%%define STAGE2_SECTORS %s\n" "$(STAGE2_SECTORS)" >> $@
	@printf "%%define KERNEL_LBA %s\n" "$(KERNEL_LBA)" >> $@
	@printf "%%define KERNEL_SECTORS %s\n" "$(KERNEL_SECTORS)" >> $@

# Assemble Stage 1
$(BOOT_BIN): $(BOOT_SRC) $(LAYOUT)
	$(NASM) -f bin $< -o $@

# Assemble Stage 2
$(STAGE2_BIN): $(STAGE2_SRC) $(LAYOUT)
	$(NASM) -f bin $< -o $@

# Assemble kernel
$(KERNEL_BIN): $(KERNEL_SRC) $(LAYOUT)
	$(NASM) -f bin $< -o $@

# Build disk image
$(IMAGE): $(BOOT_BIN) $(STAGE2_BIN) $(KERNEL_BIN)
	@test "$$(stat -c%s $(BOOT_BIN))" -eq $(SECTOR_SIZE) || \
		(echo "Error: boot.bin must be exactly 512 bytes."; exit 1)

	@test "$$(stat -c%s $(STAGE2_BIN))" -le $$(( $(STAGE2_SECTORS) * $(SECTOR_SIZE) )) || \
		(echo "Error: Stage 2 exceeds its allocation."; exit 1)

	@test "$$(stat -c%s $(KERNEL_BIN))" -le $$(( $(KERNEL_SECTORS) * $(SECTOR_SIZE) )) || \
		(echo "Error: Kernel exceeds its allocation."; exit 1)

	$(DD) if=/dev/zero of=$(IMAGE) bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS) status=none
	$(DD) if=$(BOOT_BIN) of=$(IMAGE) bs=$(SECTOR_SIZE) seek=$(STAGE1_LBA) conv=notrunc status=none
	$(DD) if=$(STAGE2_BIN) of=$(IMAGE) bs=$(SECTOR_SIZE) seek=$(STAGE2_LBA) conv=notrunc status=none
	$(DD) if=$(KERNEL_BIN) of=$(IMAGE) bs=$(SECTOR_SIZE) seek=$(KERNEL_LBA) conv=notrunc status=none

	@echo "Created $(IMAGE)"

image: $(IMAGE)

run: image
	$(QEMU) -drive format=raw,file=$(IMAGE),if=floppy

clean:
	rm -f $(BOOT_BIN) $(STAGE2_BIN) $(KERNEL_BIN) $(LAYOUT) $(IMAGE)
