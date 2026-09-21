# 仿真与验证文件一览

项目保留两条验证路径。它们共同编译 [`rtl/`](../rtl/) 中的 DUT，但 testbench 和
工具链相互独立：Verilator 用于快速开源门禁，VCS/UVM 用于完整回归。

## 目录与脚本

| 路径 | 说明 |
|------|------|
| [`sim/README.md`](../sim/README.md) | 双验证路径的依赖、命令和输出说明 |
| [`sim/Makefile`](../sim/Makefile) | Verilator lint/smoke 与 VCS/UVM build/sim/regress 的统一入口 |
| [`sim/run.sh`](../sim/run.sh) | 单入口：`build` / `sim` / `regress` |
| [`sim/regress.sh`](../sim/regress.sh) | 多用例回归，输出 [`sim/logs/regression_summary.log`](../sim/logs/regression_summary.log) |
| [`sim/filelist.f`](../sim/filelist.f) | VCS 编译文件列表（RTL + TB） |
| [`sim/verilator/uart_tb.sv`](../sim/verilator/uart_tb.sv) | Verilator 自检式回环 testbench |

## Verilator 快速门禁

```bash
make -C sim verilator-lint
make -C sim verilator-smoke
```

该路径不依赖 UVM，适合开发时快速检查 RTL。测试发送 `A5`、`3C` 并检查回环数据、
接收超时和 framing error；它不替代下述 VCS/UVM 回归。

## Testbench（`sim/tb/`）

| 文件 | 说明 |
|------|------|
| `uart_if.sv` | DUT 虚拟接口信号 |
| `uart_pkg.sv` | package：内含各 UVM 类 `include` |
| `uart_seq_item.sv` / `uart_sequencer.sv` | 事务与 sequencer |
| `uart_driver.sv` / `uart_monitor.sv` / `uart_agent.sv` | 驱动、监视（含 covergroup）、agent |
| `uart_scoreboard.sv` | TX→RX 回环比对；支持注入预期错（负向） |
| `uart_env.sv` | env 连接 analysis |
| `uart_base_seq.sv` / `uart_sanity_seq.sv` / `uart_rand_seq.sv` | 序列 |
| `uart_expected_error_catcher.sv` | 负向用例中降级预期 `EXP_ERR_INJECT` |
| `uart_base_test.sv` / `uart_sanity_test.sv` / `uart_rand_test.sv` / `uart_neg_err_inject_test.sv` | 测试类 |
| `tb_top.sv` | 顶层：时钟复位、DUT、回环、`run_test()` |

## 如何判断 VCS build 没有 hang

1. **日志在变**：`sim/logs/build.log` 大小或修改时间在约 30–60 s 内有更新。  
2. **进程状态**：`ps -p <vcs_pid> -o stat,etime,pcpu,cmd` — `R`/`S` 且有间歇 CPU 一般为正常；**长时间 `D` 且 0% CPU** 需警惕 I/O 或 NFS。  
3. **产物在变**：`simv.daidir`、`csrc` 等时间戳或文件数在变化。  
4. **硬超时**：外层包一层，例如 `timeout 45m make -C sim build`。

## 服务器选择建议（避免新人踩坑）

- **已验证结论**：历史上 VCS 跑不通/卡住问题主要发生在 IP 尾号 `124` 的服务器；切换到 IP 尾号 `123` 后，`module load vcs`、`make build`、`make sim` 已可稳定执行。  
- **新同学默认建议**：优先在 IP 尾号 `123` 的服务器进行首次环境验证与日常仿真。  
- **124 的使用建议**：若必须在 `124` 上运行，建议先做最小自检再启动长任务，避免长时间等待后失败。  

## 首次上机最小自检（推荐）

1. `cd sim`
2. `module load vcs`
3. `which vcs && vcs -ID`
4. `make clean`
5. `make sanity-ci`

通过标准：
- `make sanity-ci` 退出码为 `0`
- `sim/logs/uart_sanity_test.log` 中 `UVM_ERROR : 0`、`UVM_FATAL : 0`
- 日志出现 `scoreboard summary: pass=6 fail=0`
