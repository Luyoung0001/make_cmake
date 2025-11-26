CC = gcc
CFLAGS = -Wall -g

SOURCES = main.c utils.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = app

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(TARGET) $(OBJECTS)

# 调试辅助
debug:
	@echo "SOURCES: $(SOURCES)"
	@echo "OBJECTS: $(OBJECTS)"
	@echo "CFLAGS: $(CFLAGS)"

print-%:
	@echo $* = $($*)

.PHONY: all clean debug
