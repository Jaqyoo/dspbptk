ifeq ($(OS),Windows_NT)
	SHLIB_SUFFIX = .dll
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		SHLIB_SUFFIX = .dylib
	else
		SHLIB_SUFFIX = .so
	endif
endif

CC := gcc
OBJ_opt := app/opt.o
OBJ_vec := app/vec.o
OBJ_IFL := app/IFL.o
OBJ_LIBDSPBPTK = $(patsubst %.c, %.o, $(wildcard lib/*.c lib/libdeflate/lib/*.c lib/libdeflate/lib/*/*.c lib/chromiumbase64/*.c))

CFLAGS := -fexec-charset=GBK -Wall -lm
CFLAGS += -O3 -static -s -march=x86-64 -mtune=generic -mavx2 -flto
# CFLAGS += -g -fsanitize=address -fno-omit-frame-pointer
CFLAGS_APP := -Ilib

APPS = opt vec IFL

.PHONY: clean

.SECONDEXPANSION:
$(APPS): $$(OBJ_$$@) libdspbptk.a
	$(CC) -o $@ $(CFLAGS) $(CFLAGS_APP) $^

$(OBJ_opt): %.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(CFLAGS_APP) $<

$(OBJ_vec): %.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(CFLAGS_APP) $<

$(OBJ_IFL): %.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(CFLAGS_APP) $<

$(OBJ_LIBDSPBPTK): %.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $<

libdspbptk.a: $(OBJ_LIBDSPBPTK)
	$(AR) -rc $@ $^

libdspbptk$(SHLIB_SUFFIX): $(OBJ_LIBDSPBPTK)
	$(CC) -o $@ $(CFLAGS) -shared -fpic $^

all: $(APPS) libdspbptk.a libdspbptk$(SHLIB_SUFFIX)

clean:
	rm -f $(OBJ_LIBDSPBPTK) opt* vec* IFL* libdspbptk.a libdspbptk$(SHLIB_SUFFIX) app/*.o
