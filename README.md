# arm-llvm-stm32f103-blinky
Template for building firmware for STM32F103 with the LLVM toolchain instead of gcc-arm-none-eabi without LTO support. LTO is available here, and linking with Rust code might be possible.

## Preparation
If LLVM/Clang is installed on your host environment, it is already capable of cross-compiling. But prebuilt `libc` and `libm` for the target CPU can be found here: <https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases>, `lib/clang-runtimes/arm-none-eabi/armv7m_soft_nofp`. Note: this is not the best choice for Cortex-M4F core MCUs like STM32F3xx, STM32F4xx.

Startup program file and linker script for STM32F1xx: <https://github.com/STMicroelectronics/cmsis_device_f1>, `Source/Templates/gcc`. `startup_stm32f103xb.s` is for medium-density devices. In case of the startup program here causes problem, use an older one from `gcc_ride7` (found elsewhere).

In the linker script file, mark section `._user_heap_stack` (and probably `.bss`) with `(NOLOAD)` to solve the 384 MiB (0x20000000 - 0x08000000) bin file problem.

Try change the flag `-O3` to `-O1` in `Makefile` if strange problem occurred after the migration, because optimization in LLVM is more aggressive.

## Flashing
```
make flash ARM_LIB_DIR=<armv7m_soft_nofp>
```

`<armv7m_soft_nofp>` can be `<toolchain>/lib/clang-runtimes/arm-none-eabi/armv7m_soft_nofp`.

## Debugging
If `make` has been executed without `DEBUG=1`, do `make clean`.

```
make flash DEBUG=1 ARM_LIB_DIR=<armv7m_soft_nofp>
make debug
```

Or do it manually:

```
make flash DEBUG=1 ARM_LIB_DIR=<armv7m_soft_nofp>
openocd -f /usr/share/openocd/scripts/interface/stlink.cfg -f /usr/share/openocd/scripts/target/stm32f1x.cfg

gdb-multiarch arm-llvm-stm32f103-blinky.elf -iex 'target remote localhost:3333' -iex 'monitor reset halt' -ex 'break main' -ex 'c'
```
