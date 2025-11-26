CC = gcc
CFLAGS = -Wall -g
TARGET = myapp
SOURCES = $(wildcard src/*.c)
OBJECTS = $(SOURCES:.c=.o)
INSTALL_DIR = /usr/local/bin

# 默认目标
all: $(TARGET)

# 编译
$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 清理所有生成的文件
clean:
	rm -f $(TARGET) $(OBJECTS) *.d

# 清理并重新编译
rebuild: clean all

# 安装（需要 root 权限）
install: $(TARGET)
	@echo "Installing $(TARGET) to $(INSTALL_DIR)..."
	install -m 755 $(TARGET) $(INSTALL_DIR)/

# 卸��
uninstall:
	@echo "Removing $(TARGET) from $(INSTALL_DIR)..."
	rm -f $(INSTALL_DIR)/$(TARGET)

# 运行
run: $(TARGET)
	./$(TARGET)

# 测试
test: $(TARGET)
	@echo "Running tests..."
	@./$(TARGET)
	@echo "Tests passed!"

# 代码格式化（需要 clang-format）
format:
	@command -v clang-format >/dev/null 2>&1 || { echo "clang-format not installed"; exit 1; }
	clang-format -i $(SOURCES)

# 静态分析（需要 cppcheck）
lint:
	@command -v cppcheck >/dev/null 2>&1 || { echo "cppcheck not installed"; exit 1; }
	cppcheck --enable=all --suppress=missingIncludeSystem $(SOURCES)

# 打包
dist: clean
	tar czf $(TARGET)-1.0.tar.gz *

# 帮助信息
help:
	@echo "Available targets:"
	@echo "  all      - Build the program (default)"
	@echo "  clean    - Remove generated files"
	@echo "  rebuild  - Clean and build"
	@echo "  install  - Install to $(INSTALL_DIR)"
	@echo "  uninstall- Remove from $(INSTALL_DIR)"
	@echo "  run      - Build and run"
	@echo "  test     - Run tests"
	@echo "  format   - Format source code"
	@echo "  lint     - Run static analysis"
	@echo "  dist     - Create distribution tarball"
	@echo "  help     - Show this help"

# 声明伪目标
.PHONY: all clean rebuild install uninstall run test format lint dist help
