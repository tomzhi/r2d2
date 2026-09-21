# UART 仿真与验证运行向导

本目录统一承载两条相互独立、共用同一套 `../rtl/*.sv` 的验证路径：

- `verilator/uart_tb.sv`：轻量自检式回环测试，适合本地快速门禁。
- `tb/`：UVM testbench，由 Synopsys VCS 执行 sanity、随机和负向回归。

## 目录说明
- `filelist.f`：VCS 编译文件列表。
- `Makefile`：Verilator 与 VCS/UVM 的统一入口。
- `run.sh`：命令包装脚本。
- `regress.sh`：回归执行与 pass rate 汇总。
- `tb/`：UVM testbench。
- `verilator/`：不依赖 UVM 的 SystemVerilog testbench。
- `logs/`：构建、单测和回归汇总日志输出目录。

## 环境依赖

- Verilator 快速门禁：GNU Make、Verilator、支持 C++17 的编译器。
- UVM 完整回归：Synopsys VCS（支持 `-ntb_opts uvm-1.2`）。
- 可选环境变量：
  - `UVM_HOME`：若需要显式指定 UVM include 路径。
  - `VERBOSITY`：默认 `UVM_MEDIUM`。

## Verilator 快速门禁

从仓库根目录执行：

```bash
make -C sim verilator-lint
make -C sim verilator-smoke
```

`verilator-smoke` 默认在 `/tmp/r2d2-verilator-<uid>/` 中构建 `Vuart_tb`，避免受限
工作区禁止仿真器写入源码目录。它将 TX 串行输出回环至 RX，依次检查 `8'hA5` 与
`8'h3C`；成功时输出 `AUTOSMOKE PASS`。它用于快速健康检查，不替代 UVM 完整回归。

如需指定其他构建目录，可以覆盖变量：

```bash
make -C sim verilator-smoke VERILATOR_DIR=/path/to/build
```

也可使用 `cd sim && ./run.sh verilator-smoke`。当前已使用 Verilator 5.020 验证。

## VCS/UVM 常用命令
- 编译门禁（语法/elaboration）：
  - `make build`
  - 或 `./run.sh build`
- 默认 sanity 用例：
  - `make sim`
  - 或 `./run.sh sim uart_sanity_test`
- 指定用例：
  - `make sim TEST=uart_rand_test`
- 全量回归与汇总：
  - `make regress`
  - 或 `./run.sh regress`
- 最小回归门禁（推荐日常/CI 快速挡板）：
  - `make sanity-ci`
  - 或 `./run.sh sanity-ci`
  - 行为：自动检查 VCS 可用性、执行 `clean -> build -> uart_sanity_test`，
    并在失败时返回非 0 且提示关键日志路径。

清理两类仿真生成物统一使用 `make -C sim clean`。

## 回归汇总输出
- 汇总文件：`logs/regression_summary.log`
- 关键字段：
  - `total cases`
  - `pass cases`
  - `fail cases`
  - `pass rate`
- 失败摘要：
  - 每个 fail case 输出 `exit_code`、日志路径和关键错误摘要。

## 负向用例与 expected error 处理
- 用例：`uart_neg_err_inject_test`
- 处理策略：
  - 优先在 UVM 里通过 `uart_expected_error_catcher` 将预期 `EXP_ERR_INJECT`
    由 `UVM_ERROR` 降级为 `UVM_INFO`。
  - `regress.sh` 保留 per-test ignore pattern 能力（默认对该 case 生效）。
