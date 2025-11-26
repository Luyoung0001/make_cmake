CC = gcc
CFLAGS = -Wall -g

# 获取所有源文件
SOURCES = $(wildcard *.c)
# 生成对应的目标文件列表
OBJECTS = $(SOURCES:.c=.o)

TARGET = app

# 默认目标
all: $(TARGET)

# 链接
$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

# 模式规则：编译 .c 到 .o
%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

# 自动生成依赖关系
%.d: %.c
	@$(CC) -MM $(CFLAGS) $< > $@

# 包含依赖文件
-include $(SOURCES:.c=.d)

clean:
	rm -f $(TARGET) $(OBJECTS) *.d

.PHONY: all clean
