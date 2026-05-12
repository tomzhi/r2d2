# RTL 生成文件一览

目录：[`rtl/`](../rtl/)

| 文件 | 说明 |
|------|------|
| `uart_baud_gen.sv` | 由 `i_divider` 产生 `o_baud_tick` 与 `o_half_baud_tick`（供 RX 半位对齐） |
| `uart_tx.sv` | 8N1 发送：握手取数 → 起始位 → 8 数据位 → 停止位 |
| `uart_rx.sv` | 8N1 接收：起始检测 → 半位对齐 → 按波特采样 → `o_rx_valid` 脉冲、`o_rx_framing_error` |
| `uart.sv` | 顶层：例化 baud、TX、RX；端口含 `i_baud_divider` 与主机侧并行口 |

**风格**：与 [编码规范](conventions.md) 一致（`always_ff` / `always_comb`、`logic`、异步低复位等）。
