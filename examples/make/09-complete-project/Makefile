CC = gcc
CFLAGS = -Wall -g -Iinclude
TARGET = myapp
SRC_DIR = src
LIB_DIR = lib
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.c)
LIB_SOURCES = $(wildcard $(LIB_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SOURCES))
LIB_OBJECTS = $(patsubst $(LIB_DIR)/%.c,$(BUILD_DIR)/%.o,$(LIB_SOURCES))

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(TARGET): $(OBJECTS) $(LIB_OBJECTS)
	$(CC) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(LIB_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
