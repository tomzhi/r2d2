# r2d2 — UART RTL 与 UVM/VCS 验证

本仓库包含 **8N1 UART** 可综合 RTL，以及统一放在 `sim/` 下的两层验证能力：
基于 **Verilator** 的轻量回环测试和基于 **Synopsys VCS/UVM** 的完整回归环境。

## 文档入口（`doc/`）

| 文档 | 内容 |
|------|------|
| [doc/README.md](doc/README.md) | **文档总索引**：计划 / RTL / 仿真 / 规范 分类导航 |
| [doc/plans/](doc/plans/) | **计划快照**：`uart_plan_1` / `uart_plan_2` / `uart_plan_3_go` |
| [doc/rtl.md](doc/rtl.md) | **RTL 文件清单**与模块职责摘要 |
| [doc/simulation.md](doc/simulation.md) | **Verilator 与 VCS/UVM 双验证路径**、运行入口及环境排障说明 |
| [doc/environment_assessment_2026-09-08.md](doc/environment_assessment_2026-09-08.md) | **当前环境评估**：工具链检查结果与 Verilator 开源替代路线 |
| [doc/conventions.md](doc/conventions.md) | RTL/UVM 编码约定摘要 |
| [doc/bugs.md](doc/bugs.md) | **已知问题与待办**（环境/VCS、编译选项、仿真闭环等） |

## 源码与运行入口（非 doc）

| 路径 | 说明 |
|------|------|
| [rtl/](rtl/) | 纯 UART RTL（`uart_baud_gen`、`uart_tx`、`uart_rx`、`uart`） |
| [sim/verilator/](sim/verilator/) | 自检式 SystemVerilog 回环 testbench |
| [sim/tb/](sim/tb/) | UVM testbench |
| [sim/](sim/) | 两类验证的统一 Makefile、脚本、VCS filelist 和回归工具 |
| [sim/README.md](sim/README.md) | **统一仿真向导**：Verilator 快速门禁与 VCS/UVM 完整回归 |

## 常用命令（摘要）

```bash
make -C sim verilator-lint
make -C sim verilator-smoke

module load vcs                         # VCS/UVM 路径需要
make -C sim build
make -C sim sim                         # 默认 uart_sanity_test
make -C sim regress                     # 生成 logs/regression_summary.log
```

更完整的变量说明与示例见 [sim/README.md](sim/README.md)。
