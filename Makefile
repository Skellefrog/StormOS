bin_dir = bin
boot_dir = boot

asm := nasm
asm_flags := -f bin

stage_1 := ./$(boot_dir)/stage1/stage1.asm
stage_1_bin := $(bin_dir)/stage1
stage_2 := ./$(boot_dir)/stage2/stage2.asm
stage_2_bin := $(bin_dir)/stage2
bootloader_files := $(stage_1) $(stage_2)

img := $(bin_dir)/stormos.img

block_size := 1048576
block_count := 128

stage_1: $(stage_1)
	$(asm) $(asm_flags) $(stage_1) -o $(stage_1_bin)

stage_2: $(stage_2)
	$(asm) $(asm_flags) $(stage_2) -o $(stage_2_bin)

bootloader_stages:
	make stage_1
	make stage_2

build_img:
	make bootloader_stages
	dd if=/dev/zero of=$(img) bs=$(block_size) count=$(block_count)
	dd if=$(stage_1_bin) of=$(img) bs=512 count=1
	dd if=$(stage_2_bin) of=$(img) bs=512 count=64 seek=1
