CC = gcc
CFLAGS = -Wall -g -Iinclude
BUILD_DIR = build
SRC_DIRS = src src/core src/utils

SOURCES = $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(SOURCES)))
TARGET = $(BUILD_DIR)/app

vpath %.c $(SRC_DIRS)

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
