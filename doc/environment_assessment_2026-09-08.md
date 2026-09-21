# 当前环境运行能力与开源仿真器评估（2026-09-08）

> **2026-09-21 更新**：本文保留 2026-09-08 当时的环境快照。当前工作区已经提供
> Verilator 5.020，仓库也已将轻量回环 testbench 整合至 `sim/verilator/`。
> 现在可执行 `make -C sim verilator-lint` 和 `make -C sim verilator-smoke`；VCS/UVM
> 路径仍需在具有 Synopsys VCS 与有效 license 的环境中运行。

## 目的

- 记录仓库在当前 Codex 工作区中的运行条件与实际检查结果。
- 判断现有 VCS/UVM 流程能否直接运行。
- 评估使用 Verilator 等开源工具替代 VCS 的可行性与迁移边界。

## 项目结构摘要

本仓库实现一个 8N1 UART：

- `rtl/uart_baud_gen.sv`：波特率及半周期 tick 生成。
- `rtl/uart_tx.sv`：发送状态机，发送起始位、8 位数据和停止位。
- `rtl/uart_rx.sv`：接收状态机，在位中心采样并报告停止位错误。
- `rtl/uart.sv`：连接 baud generator、TX 和 RX。
- `sim/tb/tb_top.sv`：UVM 仿真顶层，将 TX 串行输出回环到 RX。
- `sim/tb/`：driver、monitor、sequencer、scoreboard、sequence 和 test。

现有测试包括：

- `uart_sanity_test`：固定数据的基本回环测试。
- `uart_rand_test`：带约束随机激励的测试。
- `uart_neg_err_inject_test`：验证预期错误的负向测试。

统一入口位于 `sim/Makefile`、`sim/run.sh` 和 `sim/sanity_ci.sh`。现有构建命令固定使用 Synopsys VCS，并通过 `-ntb_opts uvm-1.2` 加载 UVM。

## 当前环境检查结果

检查日期：2026-09-08。

| 项目 | 结果 |
|------|------|
| `bash` | 可用，路径 `/usr/bin/bash` |
| GNU Make | 可用，路径 `/usr/bin/make` |
| GCC | 可用，路径 `/usr/bin/gcc` |
| Synopsys VCS | 不可用 |
| Verdi / DVE | 不可用 |
| Verilator | 不可用 |
| Icarus Verilog | 不可用 |
| Environment Modules（`module`） | 不可用 |

已完成的实际验证：

1. `bash -n sim/run.sh sim/sanity_ci.sh sim/regress.sh`：通过，三个脚本没有 Shell 语法错误。
2. `make -C sim help`：通过，Makefile 可以被当前 GNU Make 正常解析。
3. `cd sim && ./sanity_ci.sh`：失败于工具链预检，输出 `ERROR: vcs not found.`。
4. 失败发生在 `make clean`、编译和仿真之前，因此没有生成仿真产物，也没有修改源码。

## 当前结论

当前环境可以查看、分析和修改代码，也可以检查 Shell/Makefile 入口，但**不能编译或运行现有 RTL/UVM 仿真**。直接原因是 VCS 不在 `PATH` 中，系统也没有可用于加载 VCS 的 `module` 命令。

要按仓库原设计运行，需要：

1. 安装或挂载 Synopsys VCS。
2. 配置有效的 VCS license server。
3. 确保 `vcs` 位于 `PATH`，或提供可用的 `module load vcs` 环境。
4. 执行 `cd sim && make sanity-ci`。

仓库中的历史记录表明 sanity 测试曾在另一台已配置 VCS 的机器上通过，但本次检查没有在当前环境独立复现该结果。

## Verilator 替代 VCS 的可行性

### 结论

Verilator 可以作为本项目的开源 RTL 仿真与 lint 后端，但现阶段不应被视为现有 VCS/UVM 1.2 流程的无改动替代品。

原因如下：

- RTL 使用的 `logic`、`always_comb`、`always_ff`、enum、模块层次和基础 SVA 都属于 Verilator 的适用范围。
- 当前 UVM testbench 使用 class inheritance、virtual interface、config DB、analysis port、queue、约束随机、covergroup、report catcher 和 callback。
- Verilator 官方文档将 class 支持描述为“有限但正在积极开发”。
- Verilator 项目维护了适配后的 UVM 源码，但该项目明确说明 UVM 支持仍在开发中。
- 因此，即使最新 Verilator 能够运行部分 UVM 用例，也仍需选择匹配的 Verilator/UVM 版本、调整编译参数，并逐项验证随机化、覆盖率和调度行为。
- Verilator 主要是二态仿真器；它对 X/Z 的处理与 VCS 四态语义不完全相同，不能仅凭 Verilator 通过就证明所有复位、未知态和协议边界行为与 VCS 一致。

官方参考：

- [Verilator 输入语言与限制](https://verilator.org/guide/latest/languages.html)
- [Verilator 命令行与 `--binary`/覆盖率选项](https://verilator.org/guide/latest/exe_verilator.html)
- [Verilator 维护的 UVM 适配仓库](https://github.com/verilator/uvm)

### 推荐路线

建议保留双后端：

1. **Verilator 快速门禁**：用于 RTL lint、编译、UART 定向回环测试、基础断言和代码覆盖率。测试平台可以采用小型 SystemVerilog testbench、C++ harness，或 cocotb。
2. **VCS 完整门禁**：继续运行现有 UVM sanity、随机、负向测试和最终回归，作为兼容性与四态语义的基准。

若目标是彻底移除商业工具依赖，优先新增独立于 UVM 的开源测试层，而不是立即把整套 UVM testbench 强行迁移：

1. 安装 Verilator，并先对 `rtl/*.sv` 执行 `--lint-only`。
2. 添加最小 UART loopback testbench，覆盖复位、握手、典型字节、连续发送和 framing error。
3. 添加 `make verilator-lint`、`make verilator-sim` 和对应日志判错门禁。
4. 将开源测试结果与现有 VCS sanity 的 `pass=6 fail=0` 基线对比。
5. 再单独开展 UVM-on-Verilator 试验；在全部测试等价前，不删除 VCS 后端。

## 后续验证清单

- [ ] 当前环境安装 Verilator。
- [ ] RTL `--lint-only` 通过。
- [ ] 最小 loopback testbench 编译并运行通过。
- [ ] 对比 Verilator 与 VCS 的复位、采样时序和 framing-error 结果。
- [ ] 评估约束随机、covergroup 和 expected-error catcher 在选定 UVM/Verilator 版本上的兼容性。
- [ ] 根据验证结果决定长期采用“双后端”还是“纯开源测试平台”。
