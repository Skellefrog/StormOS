bin_dir = ./bin
boot_dir = ./src/boot

stage_1_bin = $(bin_dir)/stage1
stage_2_bin = $(bin_dir)/stage2

img := $(bin_dir)/stormos.img

block_size := 1048576
block_count := 128

build_boot:
	cd $(boot_dir) && make boot_stages
	cd ..
	ls

build_img:
	make clean
	make build_boot
	dd if=/dev/zero of=$(img) bs=$(block_size) count=$(block_count)
	dd if=$(stage_1_bin) of=$(img) bs=512 count=1
	dd if=$(stage_2_bin) of=$(img) bs=512 count=2 seek=1

clean:
	rm -r $(bin_dir)
	mkdir $(bin_dir)
