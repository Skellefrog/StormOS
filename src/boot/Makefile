bin_dir = ../../bin

stage_1 := ./stage1/stage1.asm
stage_1_bin := $(bin_dir)/stage1
stage_2 := ./$(boot_dir)/stage2/stage2.asm
stage_2_bin := $(bin_dir)/stage2
bootloader_files := $(stage_1) $(stage_2)

asm := nasm
asm_flags := -f bin

stage_1: $(stage_1)
	$(asm) $(asm_flags) $(stage_1) -o $(stage_1_bin)

stage_2: $(stage_2)
	$(asm) $(asm_flags) $(stage_2) -o $(stage_2_bin)

boot_stages:
	make stage_1
	make stage_2
