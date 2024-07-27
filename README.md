# arm-llvm-stm32f103-blinky
Template for building firmware for STM32F103 with the LLVM toolchain instead of gcc-arm-none-eabi without LTO support. LTO is available here, and linking with Rust code might be possible.

## Preparation
If LLVM/Clang is installed on your host environment, it is already capable of cross-compiling. But prebuilt `libc` and `libm` for the target CPU can be found here: <https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases>, `lib/clang-runtimes/arm-none-eabi/armv7a_soft_nofp/lib`.

Startup program file and linker script for STM32F1xx: <https://github.com/STMicroelectronics/cmsis_device_f1>, `Source/Templates/gcc`. Problem: Somehow the startup program here causes problem, use an older one from `gcc_ride7` (found elsewhere).

In the linker script file, mark section `._user_heap_stack` (and probably `.bss`) with `(NOLOAD)` to solve the 384 MiB (0x20000000 - 0x08000000) bin file problem.

## Flashing
```
make flash ARM_LIB_DIR=<toolchain>/lib/clang-runtimes/arm-none-eabi/armv7a_soft_nofp/lib
```

## Debugging
```
make flash DEBUG=1 ARM_LIB_DIR=<toolchain>/lib/clang-runtimes/arm-none-eabi/armv7a_soft_nofp/lib
openocd -f /usr/share/openocd/scripts/interface/stlink.cfg -f /usr/share/openocd/scripts/target/stm32f1x.cfg

gdb-multiarch arm-llvm-stm32f103-blinky.elf
target remote localhost:3333
```
