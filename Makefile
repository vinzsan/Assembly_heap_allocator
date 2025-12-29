ASM = as
LD  = ld

SRC = src/*.s
OBJ = *.o
BIN = test

all: $(BIN)

$(OBJ): $(SRC)
	$(info [info] : compile src files\n)
	$(ASM) $(SRC) -o $(OBJ)

$(BIN): $(OBJ)
	$(info [info] : linking src files\n)
	$(LD) $(OBJ) -o $(BIN)

clean:
	rm -f $(OBJ) $(BIN)