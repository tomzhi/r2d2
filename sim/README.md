# UART UVM/VCS 运行向导

## 目录说明
- `filelist.f`：VCS 编译文件列表。
- `Makefile`：统一入口（build/sim/regress）。
- `run.sh`：命令包装脚本。
- `regress.sh`：回归执行与 pass rate 汇总。
- `tb/`：UVM testbench。
- `logs/`：构建、单测和回归汇总日志输出目录。

## 环境依赖
- 推荐工具：Synopsys VCS（支持 `-ntb_opts uvm-1.2`）。
- 可选环境变量：
  - `UVM_HOME`：若需要显式指定 UVM include 路径。
  - `VERBOSITY`：默认 `UVM_MEDIUM`。

## 常用命令
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
