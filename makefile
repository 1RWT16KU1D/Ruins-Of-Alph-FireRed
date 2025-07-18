default_target: bpre
.PHONY : default_target

TARGET = $@
TOOLS := ./tools

ifdef offset
INSERT=$(shell printf "%d" 0x$(offset))
endif

PATH      := /opt/devkitpro/devkitARM/bin:$(PATH)

LIBS:=-lm -lc -lgcc
LIBPATHS=$(foreach dir,$(wildcard $(DEVKITARM)/lib/gcc/arm-none-eabi/*),-L$(dir)) -L$(DEVKITARM)/arm-none-eabi/lib

OPTS := -O0 -fomit-frame-pointer -mthumb -mthumb-interwork -Dengine=0 -g -c -w -std=gnu99 # TODO: figure out what's blocking optimization

#
#Build for Fire Red
#
bpre : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	$(TOOLS)/arm-none-eabi-gcc ${OPTS} -o main.out main.c
	$(TOOLS)/arm-none-eabi-ld -o main.o -T linker.lsc main.out -lm -lc -lgcc $(LIBPATHS)
	$(TOOLS)/arm-none-eabi-objcopy -O binary main.o main.bin

#Auto-Insert into the ROM
ifdef fname
ifdef INSERT
	dd if=main.bin of="$(fname)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Insertion location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make <version> fname=something.gba offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'fname'?"
	@echo "Ex: make <version> fname=<GBA ROM File> offset=1A2B3C"
endif

.PHONY : bpre

#
#Build for Emerald
#
bpee : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	$(TOOLS)/arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -std=gnu99 -o main.out main.c
	$(TOOLS)/arm-none-eabi-ld -o main.o -T linker.lsc main.out
	$(TOOLS)/arm-none-eabi-objcopy -O binary main.o main.bin

#Auto-Insert into the ROM
ifdef fname
ifdef INSERT
	dd if=main.bin of="$(fname)" conv=notrunc seek=$(INSERT) bs=1
endif
endif

.PHONY : bpee

.PHONY : clean

clean:
	$(RM) main.o
	$(RM) main.out
	$(RM) main.bin
	$(RM) linker.lsc
