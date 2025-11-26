# 第二部分：Make 进阶技巧

## 2.1 模式规则与隐式规则

### 模式规则

模式规则使用 `%` 作为通配符，可以匹配多个文件，避免重复编写相似的规则。

**基本语法：**
```makefile
%.o: %.c
	$(CC) $(CFLAGS) -c $<
```

这条规则的含义是：任何 `.o` 文件都可以从对应的 `.c` 文件生成。

### 通配符的使用

```makefile
# % 匹配任意字符串
%.o: %.c
	gcc -c $<

# 可以在目标和依赖中使用不同的模式
obj/%.o: src/%.c
	gcc -c $< -o $@

# 使用 wildcard 函数获取所有匹配的文件
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)
```

### 内置隐式规则

Make 有许多内置的隐式规则，无需显式定义：

```makefile
# Make 内置规则示例：
# %.o: %.c
#     $(CC) $(CPPFLAGS) $(CFLAGS) -c

# %.o: %.cpp
#     $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c

# 查看所有内置规则
# make -p
```

可以通过设置变量来控制内置规则的行为：

```makefile
CC = gcc
CXX = g++
CFLAGS = -Wall -g
CXXFLAGS = -Wall -g -std=c++11
```

### 自定义模式规则

**示例代码见：** `examples/make/05-pattern-rules/`

项目结构：
```
05-pattern-rules/
├── Makefile
├── main.c
├── math_ops.c
├── string_ops.c
└── *.h
```

`Makefile`:
```makefile
CC = gcc
CFLAGS = -Wall -g -Iinclude

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
```

### 案例：批量编译多个源文件

**完整示例见：** `examples/make/06-batch-compile/`

项目结构：
```
src/
├── main.c
├── add.c
├── subtract.c
├── multiply.c
└── divide.c
include/
└── calc.h
build/
```

`Makefile`:
```makefile
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

.PHONY: all clean print
```

**关键技巧：**
1. `wildcard` 自动查找匹配的文件
2. `patsubst` 进行路径替换
3. 模式规则处理目录间的映射
4. 自动创建必要的目录

---

## 2.2 函数与高级变量

### 字符串处理���数

```makefile
# subst - 字符串替换
SOURCES = main.c utils.c
OBJECTS = $(subst .c,.o,$(SOURCES))
# 结果: main.o utils.o

# patsubst - 模式替换
SOURCES = main.c utils.c
OBJECTS = $(patsubst %.c,%.o,$(SOURCES))
# 结果: main.o utils.o

# 简写形式
OBJECTS = $(SOURCES:.c=.o)

# strip - 去除首尾空格
VAR = $(strip   hello   world  )
# 结果: "hello world"

# findstring - 查找子串
RESULT = $(findstring hello,hello world)
# 结果: "hello"

# filter - 过滤
SOURCES = main.c utils.cpp test.c
C_SOURCES = $(filter %.c,$(SOURCES))
# 结果: main.c test.c

# filter-out - 反向过滤
NON_TEST = $(filter-out test%,$(SOURCES))
# 结果: main.c utils.cpp

# sort - 排序并去重
WORDS = foo bar baz foo
SORTED = $(sort $(WORDS))
# 结果: bar baz foo

# word - 取第 n 个词
SECOND = $(word 2,foo bar baz)
# 结果: bar

# words - 统计单词数
COUNT = $(words foo bar baz)
# 结果: 3

# firstword - 取第一个词
FIRST = $(firstword foo bar baz)
# 结果: foo

# lastword - 取最后一个词
LAST = $(lastword foo bar baz)
# 结果: baz
```

### 文件名函数

```makefile
# dir - 提取目录部分
DIRS = $(dir src/main.c src/utils.c)
# 结果: src/ src/

# notdir - 提取文件名部分
FILES = $(notdir src/main.c src/utils.c)
# 结果: main.c utils.c

# suffix - 提取后缀
SUFFS = $(suffix main.c utils.cpp)
# 结果: .c .cpp

# basename - 提取基本名（去除后缀）
BASES = $(basename main.c utils.cpp)
# 结果: main utils

# addsuffix - 添加后缀
SOURCES = main utils
C_SOURCES = $(addsuffix .c,$(SOURCES))
# 结果: main.c utils.c

# addprefix - 添加前缀
FILES = main.c utils.c
SRC_FILES = $(addprefix src/,$(FILES))
# 结果: src/main.c src/utils.c

# join - 连接两个列表
DIRS = src/ build/
FILES = main.c utils.c
PATHS = $(join $(DIRS),$(FILES))
# 结果: src/main.c build/utils.c

# wildcard - 通配符展开
SOURCES = $(wildcard *.c)
ALL_C = $(wildcard src/*.c test/*.c)

# realpath - 获取绝对路径
ABS_PATH = $(realpath ../src/main.c)

# abspath - 获取绝对路径（不解析符号链接）
ABS_PATH = $(abspath ../src/main.c)
```

### 条件判断

```makefile
# ifeq - 相等判断
DEBUG = 1

ifeq ($(DEBUG),1)
    CFLAGS += -g -DDEBUG
else
    CFLAGS += -O2
endif

# ifneq - 不等判断
ifneq ($(CC),gcc)
    $(error This Makefile requires GCC)
endif

# ifdef - 检查变量是否定义
ifdef VERBOSE
    Q =
else
    Q = @
endif

# ifndef - 检查变量是否未定义
ifndef VERSION
    VERSION = 1.0.0
endif

# 三元表达式风格
CFLAGS = $(if $(DEBUG),-g -O0,-O2)
```

### Shell 函数

```makefile
# 执行 shell 命令
CURRENT_DATE = $(shell date +%Y%m%d)
GIT_HASH = $(shell git rev-parse --short HEAD)
FILE_COUNT = $(shell find src -name '*.c' | wc -l)

# 多行 shell 命令
define GENERATE_VERSION
	@echo "#ifndef VERSION_H" > version.h
	@echo "#define VERSION_H" >> version.h
	@echo "#define VERSION \"$(VERSION)\"" >> version.h
	@echo "#define BUILD_DATE \"$(CURRENT_DATE)\"" >> version.h
	@echo "#define GIT_HASH \"$(GIT_HASH)\"" >> version.h
	@echo "#endif" >> version.h
endef
```

### 案例：根据不同配置编译不同版本

**示例代码见：** `examples/make/07-conditional-build/`

`Makefile`:
```makefile
# 编译配置：debug 或 release
BUILD_TYPE ?= debug

CC = gcc
TARGET = app

# 根据配置设置不同的标志
ifeq ($(BUILD_TYPE),debug)
    CFLAGS = -Wall -g -O0 -DDEBUG
    BUILD_DIR = build/debug
else ifeq ($(BUILD_TYPE),release)
    CFLAGS = -Wall -O2 -DNDEBUG
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

# 显示当前配置
info:
	@echo "Build Type: $(BUILD_TYPE)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "Build Dir: $(BUILD_DIR)"

.PHONY: all clean debug release info
```

使用方法：
```bash
make BUILD_TYPE=debug     # 编译 debug 版本
make BUILD_TYPE=release   # 编译 release 版本
make debug                # 快捷方式
make release              # 快捷方式
make info                 # 查看配置
```

---

## 2.3 伪目标与特殊目标

### .PHONY 的作用与使用

`.PHONY` 声明的目标不代表实际文件，Make 总会执行其命令：

```makefile
.PHONY: clean all install test

clean:
	rm -f *.o $(TARGET)

all: $(TARGET)

install: $(TARGET)
	cp $(TARGET) /usr/local/bin/

test: $(TARGET)
	./run_tests.sh
```

**为什么需要 .PHONY：**
```bash
# 如果存在名为 "clean" 的文件
touch clean

# 不使用 .PHONY
make clean
# 输出: make: 'clean' is up to date.

# 使用 .PHONY
.PHONY: clean
make clean
# 正常执行清理命令
```

### 其他特殊目标

```makefile
# .SUFFIXES - 定义后缀列表
.SUFFIXES:              # 清空默认后缀
.SUFFIXES: .c .o .h     # 定义新的后缀列表

# .PRECIOUS - 保护中间文件不被删除
.PRECIOUS: %.o

# .INTERMEDIATE - 标记中间文件（完成后自动删除）
.INTERMEDIATE: %.i

# .SECONDARY - 标记中间文件（不自动删除）
.SECONDARY: %.s

# .DELETE_ON_ERROR - 如果命令失败，删除目标文件
.DELETE_ON_ERROR:

# .IGNORE - 忽略命令的错误
.IGNORE: clean

# .SILENT - 不打印命令
.SILENT: clean

# .EXPORT_ALL_VARIABLES - 导出所有变量到子 make
.EXPORT_ALL_VARIABLES:

# .NOTPARALLEL - 禁止并行执行
.NOTPARALLEL:
```

### 常见伪目标

**示例代码见：** `examples/make/08-phony-targets/`

```makefile
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

# 安装
install: $(TARGET)
	install -m 755 $(TARGET) $(INSTALL_DIR)/

# 卸载
uninstall:
	rm -f $(INSTALL_DIR)/$(TARGET)

# 运行
run: $(TARGET)
	./$(TARGET)

# 测试
test: $(TARGET)
	@echo "Running tests..."
	@./run_tests.sh

# 代码格式化
format:
	clang-format -i $(SOURCES)

# 静态分析
lint:
	cppcheck --enable=all $(SOURCES)

# 生成文档
docs:
	doxygen Doxyfile

# 打包
dist: clean
	tar czf $(TARGET)-$(VERSION).tar.gz *

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
	@echo "  docs     - Generate documentation"
	@echo "  dist     - Create distribution tarball"
	@echo "  help     - Show this help"

.PHONY: all clean rebuild install uninstall run test format lint docs dist help
```

### 案例：完整的项目构建流程

**示例代码见：** `examples/make/09-complete-project/`

这是一个包含完整构建流程的项目示例，展示了实际项目中的最佳实践。

---

## 2.4 多目录项目组织

### 典型项目结构

```
project/
├── Makefile          # 主 Makefile
├── src/              # 源代码
│   ├── Makefile
│   ├── main.c
│   └── utils/
│       ├── Makefile
│       └── utils.c
├── include/          # 头文件
│   └── utils.h
├── lib/              # 库文件
├── build/            # 编译输出
└── test/             # 测试代码
    └── Makefile
```

### 子目录递归编译

**方法 1：递归 Make（传统方法）**

主 `Makefile`:
```makefile
SUBDIRS = src test

all:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

.PHONY: all clean
```

子目录 `src/Makefile`:
```makefile
TARGET = ../build/app
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean
```

**方法 2：非递归 Make（推荐）**

单一 `Makefile`:
```makefile
CC = gcc
CFLAGS = -Wall -g -Iinclude

BUILD_DIR = build
SRC_DIRS = src src/utils src/core

# 查找所有源文件
SOURCES = $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(SOURCES)))

TARGET = $(BUILD_DIR)/app

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

# 模式规则需要指定 vpath
vpath %.c $(SRC_DIRS)

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
```

### 使用 include 包含其他 Makefile

```makefile
# 主 Makefile

# 包含配置文件
include config.mk

# 包含模块定义
include src/module.mk
include test/test.mk

# 可以使用 -include 忽略不存在的文件
-include *.d
```

`config.mk`:
```makefile
CC = gcc
CXX = g++
CFLAGS = -Wall -g
CXXFLAGS = -Wall -g -std=c++11
INSTALL_DIR = /usr/local/bin
```

`src/module.mk`:
```makefile
# 定义此模块的源文件
MODULE_SRC = src/module1.c src/module2.c
MODULE_OBJ = $(MODULE_SRC:.c=.o)

# 将模块添加到全局变量
SOURCES += $(MODULE_SRC)
OBJECTS += $(MODULE_OBJ)
```

### 变量的作用域与导出

```makefile
# 定义变量
VAR1 = value1

# 导出到子 make
export VAR2 = value2

# 一次性导出所有变量
.EXPORT_ALL_VARIABLES:

# 覆盖命令行变量
override CFLAGS += -DEXTRA_FLAG

# 目标特定变量
debug: CFLAGS += -g -DDEBUG
debug: all

# 模式特定变量
%.o: CFLAGS += -fPIC

# 在递归 make 中使用
subdirs:
	$(MAKE) -C subdir VAR=value
```

### 案例：中型项目的 Makefile 结构

**示例代码见：** `examples/make/10-multi-directory/`

项目结构：
```
project/
├── Makefile
├── config.mk
├── rules.mk
├── include/
│   ├── core.h
│   └── utils.h
├── src/
│   ├── main.c
│   ├── core/
│   │   ├── module.mk
│   │   ├── init.c
│   │   └── process.c
│   └── utils/
│       ├── module.mk
│       ├── string_utils.c
│       └── file_utils.c
├── test/
│   ├── test.mk
│   └── test_main.c
└── build/
```

主 `Makefile`:
```makefile
PROJECT_NAME = MyApp
VERSION = 1.0.0

# ��含配置
include config.mk

# 定义目录
BUILD_DIR = build
SRC_DIR = src
INC_DIR = include
TEST_DIR = test

# 包含模块定义
include src/core/module.mk
include src/utils/module.mk
include test/test.mk

# 所有对象文件
ALL_OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(ALL_SOURCES)))

TARGET = $(BUILD_DIR)/$(PROJECT_NAME)

# 包含通用规则
include rules.mk

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	@mkdir -p $@

$(TARGET): $(ALL_OBJECTS)
	@echo "Linking $@..."
	$(CC) -o $@ $^

# vpath 搜索路径
vpath %.c $(SRC_DIR) $(SRC_DIR)/core $(SRC_DIR)/utils

$(BUILD_DIR)/%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
```

`config.mk`:
```makefile
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2
LDFLAGS =
LIBS =

# 检测操作系统
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    CFLAGS += -DLINUX
endif
ifeq ($(UNAME_S),Darwin)
    CFLAGS += -DMACOS
endif
```

`src/core/module.mk`:
```makefile
CORE_SRC = src/core/init.c src/core/process.c
ALL_SOURCES += $(CORE_SRC)
```

`rules.mk`:
```makefile
# 通用规则

# 自动生成依赖
%.d: %.c
	@$(CC) -MM $(CFLAGS) $< > $@

# 包含依赖文件
-include $(ALL_SOURCES:.c=.d)

# 调试规则
print-%:
	@echo $* = $($*)

# 示例: make print-ALL_SOURCES
```

---

## 2.5 并行编译与优化

### make -j 参数的使用

Make 支持并行编译，可以显著减少编译时间：

```bash
# 使用 4 个并行任务
make -j4

# 使用所有可用的 CPU 核心
make -j$(nproc)

# 无限制并行（不推荐，可能过载系统）
make -j

# 在 Makefile 中设置默认并行数
MAKEFLAGS += -j4
```

### 依赖关系对并行编译的影响

**正确的依赖关系至关重要：**

```makefile
# 错误示例：缺少依赖
app: main.o utils.o
	gcc -o app main.o utils.o  # 可能在 .o 文件生成前就执行

main.o: main.c
	gcc -c main.c

utils.o: utils.c
	gcc -c utils.c

# 正确示例：明确依赖
app: main.o utils.o
	gcc -o $@ $^

main.o: main.c utils.h
	gcc -c $<

utils.o: utils.c utils.h
	gcc -c $<
```

**并行安全的 Makefile 设计原则：**

1. **明确所有依赖关系**
2. **避免副作用**��多个规则修改同一文件）
3. **使用目标特定变量而非全局变量**
4. **小心使用递归 make**

### 编译性能优化技巧

**1. 使用预编译头文件**

```makefile
# 生成预编译头
common.h.gch: common.h
	$(CC) $(CFLAGS) -c $< -o $@

# 使用预编译头
%.o: %.c common.h.gch
	$(CC) $(CFLAGS) -include common.h -c $< -o $@
```

**2. 使用 ccache 加速重复编译**

```makefile
# 检测并使用 ccache
CCACHE := $(shell which ccache)
ifdef CCACHE
    CC := ccache $(CC)
endif
```

**3. 最小化头文件依赖**

```makefile
# 自动生成依赖关系
DEPFLAGS = -MMD -MP

%.o: %.c
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

-include $(OBJECTS:.o=.d)
```

**4. 分离接口和实现**

```makefile
# 只在实现文件改变时重新编译
lib.o: lib.c lib_private.h
	$(CC) $(CFLAGS) -c $<

# 客户代码只依赖接口
client.o: client.c lib.h
	$(CC) $(CFLAGS) -c $<
```

### 案例：对比串行与并行编译性能

**示例代码见：** `examples/make/11-parallel-build/`

```makefile
CC = gcc
CFLAGS = -Wall -g

# 生成 100 个测试文件
SOURCES = $(wildcard src/*.c)
OBJECTS = $(SOURCES:.c=.o)

TARGET = app

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "Linking..."
	$(CC) -o $@ $^

%.o: %.c
	@echo "Compiling $<..."
	@sleep 0.1  # 模拟编译时间
	$(CC) $(CFLAGS) -c $< -o $@

# 生成测试文件
generate:
	@mkdir -p src
	@for i in {1..100}; do \
		echo "int func$$i() { return $$i; }" > src/file$$i.c; \
	done
	@echo "int main() { return 0; }" > src/main.c

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all generate clean
```

性能测试：
```bash
# 生成测试文件
make generate

# 串行编译（记录时间）
time make clean && time make

# 并行编译
time make clean && time make -j4
time make clean && time make -j8
time make clean && time make -j$(nproc)

# 比较���果
```

典型结果（4 核 CPU）：
```
串行:   100 files in ~10 seconds
-j2:    100 files in ~5 seconds
-j4:    100 files in ~2.5 seconds
-j8:    100 files in ~2.5 seconds (受限于 CPU 核心数)
```

---

## 2.6 调试与常见问题

### make 调试选项

```bash
# -n (--just-print, --dry-run)
# 只显示命令，不执行
make -n

# -d (--debug)
# 显示所有调试信息
make -d

# --debug=FLAGS
# 选择性调试信息
make --debug=b     # basic
make --debug=v     # verbose
make --debug=i     # implicit rules
make --debug=j     # job control
make --debug=m     # makefile parsing

# -p (--print-data-base)
# 打印所有规则和变量
make -p

# -w (--print-directory)
# 打印工作目录变化
make -w

# --warn-undefined-variables
# 警告未��义的变量
make --warn-undefined-variables

# -B (--always-make)
# 强制重新编译所有目标
make -B

# -t (--touch)
# 只更新时间戳，不执行命令
make -t

# -q (--question)
# 检查目标是否需要更新（用于脚本）
make -q
```

### 常见错误排查

**1. "missing separator" 错误**

```makefile
# 错误：使用了空格而不是 Tab
target: dependency
    gcc -o target dependency.c  # 这里是空格！

# 正确：使用 Tab
target: dependency
	gcc -o target dependency.c  # 这里是 Tab！
```

检查方法：
```bash
cat -A Makefile  # 显示隐藏字符，Tab 显示为 ^I
```

**2. "No rule to make target" 错误**

```makefile
# 检查文件是否存在
main.o: main.c utils.h  # utils.h 可能不存在或路径错误

# 使用 -d 选项调试
make -d main.o
```

**3. 循环依赖**

```makefile
# 错误：循环依赖
a: b
b: a

# Make 会报错：Circular a <- b dependency dropped.
```

**4. 依赖关系不完整**

```makefile
# 问题：缺少头文件依赖
main.o: main.c
	gcc -c main.c

# 当 utils.h 修改时，main.o 不会重新编译！

# 解决：使用自动依赖生成
main.o: main.c
	gcc -MMD -MP -c main.c

-include main.d
```

**5. 并行编译问题**

```makefile
# 问题：多个目标写入同一文件
all:
	echo "line1" > output.txt

test:
	echo "line2" > output.txt

# make -j2 可能导致输出混乱

# 解决：明确依赖或使用 .NOTPARALLEL
.NOTPARALLEL: all test
```

### Linux 知识穿插

**1. Shell 命令**

```makefile
# 使用 @ 隐藏命令
	@echo "This will be shown"
	echo "This command and output will be shown"

# 使用 - 忽略错误
	-rm nonexistent_file
	echo "This will still execute"

# 使用 \ 续行
	gcc -o program \
	    main.c \
	    utils.c \
	    -Wall -g

# 使用 ; 连接命令
	cd src; gcc -c *.c

# 使用 && 条件执行
	mkdir build && cd build && cmake ..

# 使用 || 错误处理
	make || echo "Build failed!"
```

**2. 环境变量**

```makefile
# 读取环境变量
PREFIX ?= $(HOME)/.local

# 设置环境变量
export PATH := $(PWD)/bin:$(PATH)

# 使用环境变量
install:
	cp $(TARGET) $(PREFIX)/bin/

# 检查环境变量
check:
ifndef CC
	$(error CC is not defined)
endif
```

**3. 文件权限**

```makefile
# 设置可执行权限
install:
	install -m 755 $(TARGET) $(DESTDIR)/bin/
	install -m 644 config.conf $(DESTDIR)/etc/

# 等价于
	cp $(TARGET) $(DESTDIR)/bin/
	chmod 755 $(DESTDIR)/bin/$(TARGET)
```

### 案例：排查实际项目中的 Makefile 问题

**示例代码见：** `examples/make/12-debugging/`

故意包含各种问题的 `Makefile`：

```makefile
CC = gcc
CFLAGS = -Wall

# 问题 1: 拼写错误
SORUCES = main.c utils.c
OBJECTS = $(SOURCES:.c=.o)

# 问题 2: 缺少依赖
app: $(OBJECTS)
	$(CC) -o $@ $^

# 问题 3: 使用空格而不是 Tab
main.o: main.c
    $(CC) $(CFLAGS) -c $<

# 问题 4: 循环依赖
utils.o: utils.c config.h
config.h: utils.o
	./generate_config

# 问题 5: 并行问题
log:
	echo "Build started" >> build.log

compile: log
	gcc -c main.c

clean:
	rm -f *.o app
```

调试步骤：

```bash
# 1. 尝试编译
make
# 错误: missing separator

# 2. 检查制表符
cat -A Makefile | grep -A 1 "main.o:"

# 3. 修复后再次尝试
make
# 错误: No rule to make target 'utils.c'

# 4. 检查变量
make print-SOURCES
make print-OBJECTS

# 5. 使用调试选项
make -d | grep "Considering target"

# 6. 检查依赖
make -p | grep "^main.o:"

# 7. 测试并行编译
make -j4
# 观察是否有竞争条件
```

修复后的 `Makefile`:

```makefile
CC = gcc
CFLAGS = -Wall -MMD -MP

SOURCES = main.c utils.c
OBJECTS = $(SOURCES:.c=.o)

app: $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 自动包含依赖
-include $(OBJECTS:.o=.d)

clean:
	rm -f *.o *.d app

# 调试辅助
debug:
	@echo "SOURCES: $(SOURCES)"
	@echo "OBJECTS: $(OBJECTS)"

print-%:
	@echo $* = $($*)

.PHONY: clean debug
```

**调试技巧总结：**

1. **使用 `make -n`** 查看将要执行的命令
2. **使用 `make -d`** 了解 Make 的决策过程
3. **使用 `cat -A`** 检查隐藏字符
4. **使用 `print-%` 规则** 检查变量值
5. **分步构建** 逐步添加功能，及时测试
6. **检查返回值** 确保命令成功执行
7. **记录日志** 使用 `tee` 保存输出

---

## 小结

在这一章中，我们深入学习了 Make 的进阶技巧：

1. **模式规则**：使用 `%` 简化重复规则，批量处理文件
2. **函数**：字符串处理、文件名操作、条件判断等强大功能
3. **伪目标**：组织构建流程，提供常用操作
4. **多目录项目**：递归/非递归 Make，模块化组织
5. **并行编译**：利用多核 CPU 加速构建
6. **调试技巧**：排查各种常见问题

下一章我们将开始学习 CMake，它在 Make 的基础上提供了更高层次的抽象和跨平台能力。
