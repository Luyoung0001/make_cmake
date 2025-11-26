# 编译器配置
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2
TARGET = calculator

# 默认目标
all: $(TARGET)

# 编译规则
$(TARGET): calculator.c
	$(CC) $(CFLAGS) -o $@ $<

# 运行程序
run: $(TARGET)
	./$(TARGET)

# 清理
clean:
	rm -f $(TARGET)

# 重新编译
rebuild: clean all

# 声明伪目标
.PHONY: all run clean rebuild
