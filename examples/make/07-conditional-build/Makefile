# 编译配置：debug 或 release
BUILD_TYPE ?= debug

CC = gcc
TARGET = app

# 根据配置设置不同的标志
ifeq ($(BUILD_TYPE),debug)
    CFLAGS = -Wall -g -O0 -DDEBUG -DVERSION='"1.0-debug"'
    BUILD_DIR = build/debug
else ifeq ($(BUILD_TYPE),release)
    CFLAGS = -Wall -O2 -DRELEASE -DVERSION='"1.0"'
    BUILD_DIR = build/release
else
    $(error Invalid BUILD_TYPE: $(BUILD_TYPE). Use 'debug' or 'release')
endif

# 源文件
SOURCES = $(wildcard src/*.c)
OBJECTS = $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SOURCES))

all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/$(TARGET): $(OBJECTS)
	@echo "Building $(BUILD_TYPE) version..."
	$(CC) -o $@ $^

$(BUILD_DIR)/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf build

# 快捷目标
debug:
	$(MAKE) BUILD_TYPE=debug

release:
	$(MAKE) BUILD_TYPE=release

# 运行
run: all
	$(BUILD_DIR)/$(TARGET)

# 显示当前配置
info:
	@echo "Build Type: $(BUILD_TYPE)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "Build Dir: $(BUILD_DIR)"

.PHONY: all clean debug release run info
