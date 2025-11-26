CC = gcc
CFLAGS = -Wall -g -Iinclude

# 源文件目录
SRC_DIR = src
BUILD_DIR = build
INC_DIR = include

# 自动查找所有源文件
SOURCES = $(wildcard $(SRC_DIR)/*.c)
# 生成目标文件路径
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SOURCES))

TARGET = $(BUILD_DIR)/calculator

all: $(BUILD_DIR) $(TARGET)

# 创建 build 目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 链接
$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

# 模式规则：编译源文件到 build 目录
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

# 打印变量（调试用）
print:
	@echo "SOURCES: $(SOURCES)"
	@echo "OBJECTS: $(OBJECTS)"

run: $(TARGET)
	$(TARGET)

.PHONY: all clean print run
