#
# bspc Makefile
#
# GNU Make required
#
COMPILE_PLATFORM=$(shell uname | sed -e 's/_.*//' | tr '[:upper:]' '[:lower:]' | sed -e 's/\//_/g')
COMPILE_ARCH=$(shell uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')

ifeq ($(COMPILE_PLATFORM),sunos)
  # Solaris uname and GNU uname differ
  COMPILE_ARCH=$(shell uname -p | sed -e 's/i.86/x86/')
endif

#############################################################################
#
# If you require a different configuration from the defaults below, create a
# new file named "Makefile.local" in the same directory as this file and define
# your parameters there. This allows you to change configuration without
# causing problems with keeping up to date with the repository.
#
#############################################################################
-include Makefile.local

ifeq ($(COMPILE_PLATFORM),cygwin)
  PLATFORM=mingw32
endif

ifndef PLATFORM
PLATFORM=$(COMPILE_PLATFORM)
endif

ifeq ($(PLATFORM),mingw32)
  MINGW=1
endif
ifeq ($(PLATFORM),mingw64)
  MINGW=1
endif


CC=gcc
CFLAGS=\
	-Dstricmp=strcasecmp -DCom_Memcpy=memcpy -DCom_Memset=memset \
	-DMAC_STATIC= -DQDECL= -DBSPC -D_FORTIFY_SOURCE=2 \
	-fno-common \
	-I. -Ideps -Wall $(EXPAT_CFLAGS)

ifneq (,$(findstring "$(PLATFORM)", "linux" "gnu_kfreebsd" "kfreebsd-gnu" "gnu"))
  CFLAGS += -DHAVE_GETRANDOM -DLINUX
endif
ifeq ($(PLATFORM),darwin)
  CFLAGS += -DHAVE_ARC4RANDOM -DLINUX
endif

RELEASE_CFLAGS=-O3 -ffast-math
DEBUG_CFLAGS=-g -O0 -ffast-math
LDFLAGS=-lm -lpthread -fno-common

DO_CC=$(CC) $(CFLAGS) -o $@ -c $<

#############################################################################
# SETUP AND BUILD BSPC
#############################################################################

.c.o:
	$(DO_CC)

GAME_OBJS = \
	_files.o\
	aas_areamerging.o\
	aas_cfg.o\
	aas_create.o\
	aas_edgemelting.o\
	aas_facemerging.o\
	aas_file.o\
	aas_gsubdiv.o\
	aas_map.o\
	aas_prunenodes.o\
	aas_store.o\
	be_aas_bspc.o\
	deps/botlib/be_aas_bspq3.o\
	deps/botlib/be_aas_cluster.o\
	deps/botlib/be_aas_move.o\
	deps/botlib/be_aas_optimize.o\
	deps/botlib/be_aas_reach.o\
	deps/botlib/be_aas_sample.o\
	brushbsp.o\
	bspc.o\
	deps/qcommon/cm_load.o\
	deps/qcommon/cm_patch.o\
	deps/qcommon/cm_test.o\
	deps/qcommon/cm_trace.o\
	csg.o\
	glfile.o\
	l_bsp_ent.o\
	l_bsp_hl.o\
	l_bsp_q1.o\
	l_bsp_q2.o\
	l_bsp_q3.o\
	l_bsp_sin.o\
	l_cmd.o\
	deps/botlib/l_libvar.o\
	l_log.o\
	l_math.o\
	l_mem.o\
	l_poly.o\
	deps/botlib/l_precomp.o\
	l_qfiles.o\
	deps/botlib/l_script.o\
	deps/botlib/l_struct.o\
	l_threads.o\
	l_utils.o\
	leakfile.o\
	map.o\
	map_hl.o\
	map_q1.o\
	map_q2.o\
	map_q3.o\
	map_sin.o\
	deps/qcommon/md4.o\
	nodraw.o\
	portals.o\
	textures.o\
	tree.o\
	deps/qcommon/unzip.o

        #tetrahedron.o

EXEC = bspc
ifdef MINGW
  BINEXT=.exe
endif


all: release

debug: CFLAGS += $(DEBUG_CFLAGS)
debug: $(EXEC)_g$(BINEXT)

release: CFLAGS += $(RELEASE_CFLAGS)
release: $(EXEC)$(BINEXT)

$(EXEC)$(BINEXT): $(GAME_OBJS)
	$(CC) -o $@ $(GAME_OBJS) $(LDFLAGS)
	strip $@

$(EXEC)_g$(BINEXT): $(GAME_OBJS)
	$(CC) -o $@ $(GAME_OBJS) $(LDFLAGS)

#############################################################################
# MISC
#############################################################################
.PHONY: clean depend

clean:
	-rm -f $(GAME_OBJS) $(EXEC) $(EXEC)_g

depend:
	$(CC) $(CFLAGS) -MM $(GAME_OBJS:.o=.c) > .deps

include .deps
