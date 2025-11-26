# 第一部分：Make 基础入门

## 1.1 Make 简介与环境准备

### 什么是 Make

Make 是一个自动化构建工具，最初由 Stuart Feldman 于 1976 年在贝尔实验室开发。它通过读取名为 `Makefile` 的文件来确定程序的哪些部分需要重新编译，并执行相应的命令来更新它们。

Make 的核心思想是：
1. **依赖关系管理**：明确源文件之间的依赖关系
2. **增量编译**：只重新编译修改过的文件
3. **自动化构建**：通过简单的命令完成复杂的编译过程

### Make 的应用场景

- **C/C++ 项目编译**：最经典的应��场景
- **文档生成**：从源文件生成 PDF、HTML 等
- **自动化部署**：执行一系列部署任务
- **数据处理**：管理数据处理流水线

### Ubuntu 环境下安装 Make

在 Ubuntu 系统中，Make 通常已经预装。���果没有，可以通过以下命令安装：

```bash
# 检查是否已安装
make --version

# 如果未安装，执行以下命令
sudo apt update
sudo apt install build-essential
```

`build-essential` 包含了 gcc、g++、make 等基本的编译工具。

### 第一个 Makefile 示例

让我们从最简单的 Hello World 程序开始。

**示例代码见：** `examples/make/01-hello-world/`

创建 `hello.c`：
```c
#include <stdio.h>

int main() {
    printf("Hello, Make!\n");
    return 0;
}
```

创建 `Makefile`：
```makefile
hello: hello.c
	gcc -o hello hello.c

clean:
	rm -f hello
```

**注意：** Makefile 中的���令行必须以 **Tab 键**（而不是空格）开头！

运行：
```bash
make        # 编译程序
./hello     # 运行程序
make clean  # 清理生成的文件
```

**工作流程：**
1. Make 读取 Makefile
2. 找到目标 `hello`
3. 检查依赖 `hello.c` 是否存在
4. 如果 `hello` 不存在或 `hello.c` 比 `hello` 新，执行编译命令
5. 生成可执行文件 `hello`

---

## 1.2 Makefile 基本语法

### 规则（Rule）的结构

Makefile 的基本单位是规则（Rule），其结构如下：

```makefile
target: dependencies
	command
	command
	...
```

- **target（目标）**：要生成的文件或伪目标
- **dependencies（依赖）**：生成目标所需的文件
- **command（命令）**：生成目标的 shell 命令，必须以 Tab 开头

### 变量的定义与使用

Makefile 支持变量，可以简化重复的内容：

```makefile
# 定义变量
CC = gcc
CFLAGS = -Wall -g
TARGET = hello
SOURCES = hello.c

# 使用变量
$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)
```

**变量赋值方式：**
- `=`：递归展开，使用时才求值
- `:=`：简单展开，定义时立即求值
- `?=`：如果变量未定义，则赋值
- `+=`：追加内容

示例：
```makefile
# 递归展开
VAR1 = $(VAR2)
VAR2 = Hello

# 简单展开
VAR3 := $(shell date)

# 条件赋值
VAR4 ?= default_value

# 追加
CFLAGS = -Wall
CFLAGS += -g
```

### 自动化变量

Make 提供了一些自动化变量，可以简化 Makefile：

- `$@`：目标文件名
- `$<`：第一个依赖文件名
- `$^`：所有依赖文件名（去重）
- `$?`：所有比目标新的依赖文件
- `$*`：目标模式中 `%` 匹配的部分

**示例代码见：** `examples/make/02-variables/`

```makefile
CC = gcc
CFLAGS = -Wall -g

main: main.o utils.o
	$(CC) -o $@ $^

main.o: main.c utils.h
	$(CC) $(CFLAGS) -c $<

utils.o: utils.c utils.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f main *.o
```

在这个例子中：
- `$@` 代表 `main`、`main.o`、`utils.o`（分别对应各自的规则）
- `$^` 在 `main` 规则中代表 `main.o utils.o`
- `$<` 在 `main.o` 规则中代表 `main.c`

### 案例：编译单个 C 文件

**完整示例见：** `examples/make/03-single-file/`

创建 `calculator.c`：
```c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(5, 3);
    printf("5 + 3 = %d\n", result);
    return 0;
}
```

创建 `Makefile`：
```makefile
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
```

使用方法：
```bash
make           # 编译
make run       # 编译并运行
make clean     # 清理
make rebuild   # 重新编译
```

---

## 1.3 Make 的工作原理

### 依赖关系图的构建

Make 的核心是构建一个有向无环图（DAG），表示文件之间的依赖关系。

考虑以下 Makefile：
```makefile
program: main.o utils.o
	gcc -o program main.o utils.o

main.o: main.c utils.h
	gcc -c main.c

utils.o: utils.c utils.h
	gcc -c utils.c
```

依赖关系图：
```
program
├── main.o
│   ├── main.c
│   └── utils.h
└── utils.o
    ├── utils.c
    └── utils.h
```

Make 按照以下顺序工作：
1. 从目标 `program` 开始
2. 检查其依赖 `main.o` 和 `utils.o`
3. 递归检查 `main.o` 的依赖 `main.c` 和 `utils.h`
4. 递归检查 `utils.o` 的依赖 `utils.c` 和 `utils.h`
5. 从叶子节点开始，按依赖顺序执行命令

### 时间戳检查机制

Make 使用文件的修改时间（mtime）来判断是否需要重新编译：

**规则：** 如果目标不存在，或任何依赖比目标新，则重新生成目标。

在 Linux 中，每个文件都有三个时间戳：
- **atime**（access time）：最后访问时间
- **mtime**（modification time）：最后修改时间
- **ctime**（change time）：最后状态改变时间

Make 只关心 **mtime**。

查看文件时间戳：
```bash
stat filename
ls -l filename  # 显示 mtime
```

### 为什么 Make 能实现增量编译

增量编译的原理：
1. Make 比较目标文件和依赖文件的 mtime
2. 只重新编译那些依赖被修改过的目标
3. 未修改的文件直接使用已有的编译结果

这大大提高了大型项目的编译效率。

### 案例：演示文件修改时间对编译的影响

**示例代码见：** `examples/make/04-timestamp-demo/`

创建示例文件：

`main.c`:
```c
#include <stdio.h>
#include "utils.h"

int main() {
    printf("Result: %d\n", calculate(10, 5));
    return 0;
}
```

`utils.h`:
```c
#ifndef UTILS_H
#define UTILS_H

int calculate(int a, int b);

#endif
```

`utils.c`:
```c
#include "utils.h"

int calculate(int a, int b) {
    return a + b;
}
```

`Makefile`:
```makefile
CC = gcc
CFLAGS = -Wall -g

program: main.o utils.o
	@echo "==> Linking $@"
	$(CC) -o $@ $^

main.o: main.c utils.h
	@echo "==> Compiling $@"
	$(CC) $(CFLAGS) -c $<

utils.o: utils.c utils.h
	@echo "==> Compiling $@"
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f program *.o

.PHONY: clean
```

**实验步骤：**

```bash
# 第一次编译（所有文件都会编译）
make
# 输出：
# ==> Compiling main.o
# ==> Compiling utils.o
# ==> Linking program

# 不修改任何文件，再次执行
make
# 输出：
# make: 'program' is up to date.

# 只修改 utils.c
echo "// comment" >> utils.c
make
# 输出：
# ==> Compiling utils.o
# ==> Linking program
# 注意：main.o 没有重新编译！

# 修改 utils.h（头文件）
echo "// comment" >> utils.h
make
# 输出：
# ==> Compiling main.o
# ==> Compiling utils.o
# ==> Linking program
# 注意：因为 main.o 和 utils.o 都依赖 utils.h，所以都重新编译了！

# 查看文件时间戳
ls -lt
stat utils.o

# 手动修改时间戳
touch -t 202301010000 utils.o  # 将 utils.o 的时间设置为过去
make
# 输出：
# ==> Compiling utils.o
# ==> Linking program
```

**关键观察：**
1. Make 只重新编译必要的文件
2. 修改头文件会导致所有包含它的源文件重新编译
3. 可以用 `touch` 命令修改文件时间戳来影响 Make 的行为
4. `@echo` 中的 `@` 表示不显示命令本身，只显示输出

**调试技巧：**
```bash
# 显示 Make 的执行过程
make -n    # 只显示将要执行的命令，不实际执行
make -d    # 显示详细的调试信息
make -p    # 显示所有规则和变量
```

通过这个案例，我们深入理解了 Make 的工作原理：它通过文件时间戳实现智能的增量编译，避免不必要的重复工作。

---

## 小结

在这一章中，我们学习了：
1. Make 的基本概念和安装方法
2. Makefile 的基本语法：规则、变量、自动化变量
3. Make 的工作原理：依赖关系图和时间戳检查机制
4. 如何实现增量编译

下一章我们将学习 Make 的进阶技巧，包括模式规则、函数、多目录项目等。
