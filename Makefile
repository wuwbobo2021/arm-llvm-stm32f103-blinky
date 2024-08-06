# output name
TARGET = arm-llvm-stm32f103-blinky

# debug build?
DEBUG = 0
# optimization
OPT = -O3 -flto

ASM_SOURCES = stm32f10x/startup_stm32f10x_md.s
LD_SCRIPT = stm32f103c8tx_flash.ld

C_DIRS = arm \
         stm32f10x \
         .

C_DEFS = -DUSE_STDPERIPH_DRIVER \
         -DSTM32F10X_MD


# it must be set for libc and libm, like
# <LLVM Embedded Toolchain for Arm>/lib/clang-runtimes/arm-none-eabi/armv7a_soft_nofp/lib
ARM_LIB_DIR =

# leave empty if the original llvm/clang should be used
ARM_LLVM_PATH =

CC = $(ARM_LLVM_PATH)clang
AS = $(ARM_LLVM_PATH)clang
CP = $(ARM_LLVM_PATH)llvm-objcopy
SZ = $(ARM_LLVM_PATH)llvm-size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

OPENOCD = openocd \
	      -f /usr/share/openocd/scripts/interface/stlink.cfg \
	      -f /usr/share/openocd/scripts/target/stm32f1x.cfg
GDB = gdb-multiarch

ifeq '$(findstring ;,$(PATH))' ';'
# Windows
RM = del /Q
else
RM = rm -f
endif

FLAGS = -mthumb -mcpu=cortex-m3 --target=thumbv7m-none-unknown-eabi -mfpu=none

C_INCLUDES = $(foreach d, $(C_DIRS), -I$(d))
C_SOURCES = $(foreach d, $(C_DIRS), $(foreach c, $(wildcard $(d)/*.c), $(c)))
CFLAGS = $(C_DEFS) $(C_INCLUDES) $(FLAGS) -std=c99 -fdata-sections -ffunction-sections

OBJS = $(C_SOURCES:.c=.o) $(ASM_SOURCES:.s=.o)
LD_FLAGS = $(FLAGS) -Wl,--gc-sections -T$(LD_SCRIPT) -nostdlib -lc -lm -L $(ARM_LIB_DIR)

ifeq ($(DEBUG), 1)
C_DEFS += -DDEBUG
CFLAGS += -g -gdwarf-2
else
CFLAGS += $(OPT)
LD_FLAGS += $(OPT)
endif

$(TARGET).bin: $(TARGET).elf
	$(BIN) $< $@

$(TARGET).elf: $(OBJS)
	$(CC) $(LD_FLAGS) $(OBJS) -o $@
	$(SZ) $@

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o: %.s
	$(AS) -c $(FLAGS) $< -o $@

.PHONY: clean flash debug

clean:
	$(RM) $(foreach d, $(C_DIRS), $(d)/*.o) *.elf *.bin

flash: $(TARGET).bin
	$(OPENOCD) -c "program $(TARGET).bin preverify verify reset exit 0x08000000"

debug: $(TARGET).elf
	$(GDB) -iex "target extended | $(OPENOCD) -c 'gdb_port pipe'" \
	-iex 'monitor reset halt' -ex 'break main' -ex 'c' -ex '-' $<
