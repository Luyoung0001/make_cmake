CC = gcc
CFLAGS = -Wall -g
TARGET = main

# 自动化变量示例
$(TARGET): main.o utils.o
	@echo "Linking: $@"
	@echo "Dependencies: $^"
	$(CC) -o $@ $^

main.o: main.c utils.h
	@echo "Compiling: $@"
	@echo "First dependency: $<"
	$(CC) $(CFLAGS) -c $<

utils.o: utils.c utils.h
	@echo "Compiling: $@"
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(TARGET) *.o

.PHONY: clean
