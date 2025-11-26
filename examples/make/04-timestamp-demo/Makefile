CC = gcc
CFLAGS = -Wall -g

program: main.o utils.o
	@echo "==> Linking $@"
	$(CC) -o $@ $^

main.o: main.c utils.h
	@echo "==> Compiling $@"
	$(CC) $(CFLAGS) -c $<

utils.o: utils.c utils.h
	@echo "==> Compiling $@"
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f program *.o

.PHONY: clean
