# Basic Makefile for Fortran 90/95 projects
SHELL:=/bin/bash
SUFFIXES:=.f90

.SUFFIXES: # clear the suffixes
.SUFFIXES: $(SUFFIXES) .o

PROGRAM:=main
BIN_DIR:=bin
SRC_DIR:=src
OBJ_DIR:=obj
MOD_DIR:=src


# Compiler Flags
LDFLAGS:= -fbacktrace -Wall -Wextra -Wno-maybe-uninitialized -Wno-unused-function -pedantic -std=f2008ts
ifeq ($(FC),gfortran)
    # do nothing
else ifeq ($(FC),ifort)
    LDFLAGS:= -std15 -static-intel
else
    $(info Unknown Compiler "$(FC)", set default 'gfortran')
    FC=gfortran
endif

ifndef $(DDBUG)
    OPTIMIZE:= -O2
endif
ifeq ($(DDBUG),debug)
    ifeq ($(FC),gfortran)
        OPTIMIZE:= -O0 -g3 -Warray-bounds -Wcharacter-truncation -Wline-truncation -Wimplicit-interface -Wimplicit-procedure -Wunderflow -fcheck=all -ffree-line-length-132 -fimplicit-none -fbacktrace -fdump-core -finit-real=nan -std=f2008ts -fall-intrinsics
    else
        OPTIMIZE:= -O0 -debug all -check all -warn all -extend-source 132 -traceback -gen-interfaces -fpe-all=0 -fp-stack-check -fstack-protector-all -ftrapuv -no-ftz -std15
    endif
else
    DDBUG:=release
    OPTIMIZE:= -O2
endif
ifeq ($(FC),gfortran)
    FCFLAGS:=-I$(OBJ_DIR) -J$(OBJ_DIR)
else
    FCFLAGS:=-L$(OBJ_DIR)
endif

# Getting the .o file name from source code
MOD_OBJECTS:=	$(patsubst $(MOD_DIR)/%,$(OBJ_DIR)/%,\
			$(patsubst %.f90,%.o,$(shell ./tools/make_depends_tree.sh $(MOD_DIR)))\
		)

# Getting the .o file name from source code
OBJECTS:=	$(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,\
			$(patsubst %.f90,%.o,$(wildcard $(SRC_DIR)/*.f90))\
		)

.PHONY: clean all info depend

VPATH:=$(OBJ_DIR) $(MOD_DIR) $(SRC_DIR)

# Default rule
# Display info, create $(OBJ_DIR),
# make dependancies and the main program

all: info depend $(PROGRAM)

# Display some info
info:
	@echo "make: Compiler options:"
	@echo "make: Compiler = $(FC)"
	@echo "make: DDBUG = $(DDBUG)"
	@echo "make: OPTIMIZE = $(OPTIMIZE)"
	@echo "make: FCFLAGS = $(FCFLAGS)"
	@echo "make: LDFLAGS = $(LDFLAGS)"
		
# Rule for the $(BIN_DIR) directory
$(BIN_DIR):
	@if [ ! -d $(BIN_DIR) ]; then \
		echo 'make: Creating $(BIN_DIR)/';\
		mkdir $(BIN_DIR) ;	fi

# Rule for the $(OBJ_DIR) directory
$(OBJ_DIR):
	@if [ ! -d $(OBJ_DIR) ]; then \
		echo 'make: Creating $(OBJ_DIR)/';\
		mkdir $(OBJ_DIR) ;	fi

# Getting the dependencies of the modules. This produces a file to include
depend: $(BIN_DIR) $(OBJ_DIR) $(MOD_OBJECTS)
	@echo 'make: Dependancies built'

# Rule for all file. Look at VPATH variable
$(OBJ_DIR)/%.o: %.f90
	@echo 'make: Compiling' $<
	@$(FC) $(LDFLAGS) $(OPTIMIZE) $(FCFLAGS) -o $@ -c $<

# Creating the executable file
$(PROGRAM): $(OBJECTS)
	@echo 'make: Stacticly linking objects'
	@$(FC) $(LDFLAGS) $(OPTIMIZE) $(FCFLAGS) -o $(BIN_DIR)/$@ $^
	@echo 'make: Program '$@' successfuly created.'

clean:
	@echo 'make: rm -rf $(BIN_DIR) $(OBJ_DIR)'
	@-rm -rf $(BIN_DIR) $(OBJ_DIR)
