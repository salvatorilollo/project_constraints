make bin/hyperbench.elf
riscv64-unknown-elf-objcopy -O verilog bin/hyperbench.elf bin/hyperbench.hex
make bin/car_animation.elf
riscv64-unknown-elf-objcopy -O verilog bin/car_animation.elf bin/car_animation.hex
make bin/rocket_animation.elf
riscv64-unknown-elf-objcopy -O verilog bin/rocket_animation.elf bin/rocket_animation.hex
make bin/test_pattern.elf
riscv64-unknown-elf-objcopy -O verilog bin/test_pattern.elf bin/test_pattern.hex