.PHONY: build_encoder run_encoder_86 run_encoder_64
build_encoder:
	cd b_encoder && cargo build --release

run_encoder_86:
	cd b_encoder && cargo run --release -- -a x86

run_encoder_64:
	cd b_encoder && cargo run --release -- -a x64