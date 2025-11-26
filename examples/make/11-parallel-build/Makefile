CC = gcc
CFLAGS = -Wall
SOURCES = $(wildcard src/*.c)
OBJECTS = $(SOURCES:.c=.o)
TARGET = app

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "Linking..."
	$(CC) -o $@ $^

%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJECTS)

# 使用: make -j4 或 make -j$(nproc)
.PHONY: all clean
