# R2D2 UART RTL

这是一个使用 SystemVerilog 编写的简单 UART（Universal Asynchronous
Receiver/Transmitter）设计。项目可以通过 Verilator 编译，并提供了一个自检式
autosmoke test，用于快速确认 UART 的基本发送和接收功能是否正常。

## 快速开始

### 环境要求

运行测试需要以下工具：

- GNU Make
- Verilator（当前已使用 Verilator 5.020 验证）
- 支持 C++17 的 C++ 编译器，例如 `g++`

可以先确认工具是否可用：

```bash
verilator --version
make --version
g++ --version
```

### 运行 autosmoke test

进入本目录后执行：

```bash
make autosmoke
```

该命令会完成以下操作：

1. 使用 Verilator 编译 UART RTL 和 SystemVerilog 测试平台。
2. 在 `obj_dir/autosmoke/` 中生成仿真程序 `Vuart_tb`。
3. 自动启动仿真并检查测试结果。

测试通过时，在构建信息末尾附近可以看到：

```text
AUTOSMOKE PASS: UART loopback received A5 and 3C
- uart_tb.sv:72: Verilog $finish
```

其中第一行是项目定义的 PASS 标志。只要 `make` 返回状态为 0，且日志中出现
`AUTOSMOKE PASS`，即可认为 autosmoke test 通过。Verilator 可能同时打印
`w_half_baud_tick` 未使用等非致命警告；这些警告不会使本测试失败。

构建完成后，也可以直接再次运行已经生成的仿真程序：

```bash
./obj_dir/autosmoke/Vuart_tb
```

清理全部 Verilator 构建产物：

```bash
make clean
```

## 项目结构

| 文件 | 作用 |
| --- | --- |
| `uart.sv` | UART 顶层，连接波特率生成器、发送器和接收器 |
| `uart_baud_gen.sv` | 根据分频值产生发送所需的波特率 tick |
| `uart_tx.sv` | UART 发送器 |
| `uart_rx.sv` | UART 接收器 |
| `uart_tb.sv` | 自检式 SystemVerilog 回环测试平台 |
| `Makefile` | 提供 `autosmoke` 和 `clean` 命令 |

## 进一步了解该设计

### UART RTL 完成了什么

本项目实现了一个基础的 8N1 UART：

- 8 个数据位；
- 无奇偶校验位（No parity）；
- 1 个停止位；
- 数据低位优先发送；
- 低电平起始位和高电平停止位；
- 可通过 16 位 `i_baud_divider` 配置波特率分频值；
- TX 使用 `i_tx_valid`/`o_tx_ready` 接口接收待发送字节；
- RX 使用单周期 `o_rx_valid` 指示新字节到达；
- RX 可以通过 `o_rx_framing_error` 报告停止位错误；
- 使用低有效异步复位 `i_rstn`。

`uart_baud_gen` 根据输入分频值产生周期性 tick。`uart_tx` 状态机依次输出空闲、
起始位、8 个数据位和停止位。`uart_rx` 在检测到下降沿后的低电平起始位后，于
位周期中部确认起始位，随后按完整位周期采样数据位和停止位。

### 测试平台的工作原理

测试平台将 UART 的串行发送输出直接连接到串行接收输入：

```text
uart_tx.o_tx_serial ────────> uart_rx.i_rx_serial
```

这种连接称为数字回环（loopback）。测试平台自行产生时钟和复位，驱动 TX
握手接口发送测试字节，然后等待 RX 给出 `o_rx_valid`。收到数据后，测试平台
自动比较发送值和接收值，并检查 framing error。

测试发送操作安排在波特率 tick 之后开始，使当前基于全局 tick 的 TX 实现获得
完整的起始位周期。测试中使用的分频值为 8，因此每个 UART 位保持 8 个系统
时钟周期。

测试平台使用 `$fatal` 实现自检。如果出现接收超时、数据不一致或帧错误，仿真
会立即以失败状态结束，`make autosmoke` 也会返回非零状态；全部检查通过时才会
打印 `AUTOSMOKE PASS`。

### autosmoke test 覆盖了什么

当前 autosmoke test 依次发送并接收：

- `8'hA5`（二进制位交替模式）；
- `8'h3C`（包含连续的 0 和连续的 1）。

它验证了：

- Verilator 能成功解析并构建全部 RTL；
- 顶层模块及 TX、RX、波特率生成器可以正确连接；
- TX ready/valid 基本握手能够发起传输；
- 起始位、8 个数据位和停止位能够通过回环路径传输；
- RX 能恢复两个不同的数据字节；
- 接收完成指示 `o_rx_valid` 能够产生；
- 正常停止位不会触发 framing error；
- 接收操作可以在规定时限内完成；
- RTL 中已有的 SystemVerilog assertions 在测试期间不会失败。

这是一个快速健康检查，并不是完整的 UART 验证环境。目前尚未覆盖错误停止位、
无效起始位、不同分频值、连续无间隔传输、复位中断传输以及随机数据等边界场景。
