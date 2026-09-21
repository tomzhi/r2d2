# UART RTL

本目录只存放 UART 设计源码。所有测试平台和运行入口统一放在 [`../sim/`](../sim/)；
Verilator 快速测试与 VCS/UVM 回归的使用方法见 [`../sim/README.md`](../sim/README.md)。

## 文件结构

| 文件 | 作用 |
| --- | --- |
| `uart.sv` | UART 顶层，连接波特率生成器、发送器和接收器 |
| `uart_baud_gen.sv` | 根据分频值产生发送所需的波特率 tick |
| `uart_tx.sv` | UART 发送器 |
| `uart_rx.sv` | UART 接收器 |

本设计实现基础的 8N1 UART：

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

更完整的模块职责说明见 [`../doc/rtl.md`](../doc/rtl.md)。
