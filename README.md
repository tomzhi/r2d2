# r2d2 — UART RTL 与 UVM/VCS 验证

本仓库包含 **8N1 UART** 可综合 RTL、**UVM** 风格 testbench，以及基于 **Synopsys VCS** 的编译与回归脚本。使用前请在 shell 中加载工具环境，例如：`module load vcs`。

## 文档入口（`doc/`）

| 文档 | 内容 |
|------|------|
| [doc/README.md](doc/README.md) | **文档总索引**：计划 / RTL / 仿真 / 规范 分类导航 |
| [doc/plans/](doc/plans/) | **计划快照**：`uart_plan_1` / `uart_plan_2` / `uart_plan_3_go` |
| [doc/rtl.md](doc/rtl.md) | **RTL 文件清单**与模块职责摘要 |
| [doc/simulation.md](doc/simulation.md) | **仿真与 TB 清单**、`make`/`run.sh` 相关说明、**VCS build 是否 hang** 的判定要点 |
| [doc/environment_assessment_2026-09-08.md](doc/environment_assessment_2026-09-08.md) | **当前环境评估**：工具链检查结果与 Verilator 开源替代路线 |
| [doc/conventions.md](doc/conventions.md) | **编码规范**入口 → [.cursor/rules.mdc](.cursor/rules.mdc) |
| [doc/bugs.md](doc/bugs.md) | **已知问题与待办**（环境/VCS、编译选项、仿真闭环等） |

## 源码与运行入口（非 doc）

| 路径 | 说明 |
|------|------|
| [rtl/](rtl/) | UART RTL（`uart_baud_gen`、`uart_tx`、`uart_rx`、`uart`） |
| [sim/](sim/) | VCS filelist、Makefile、`run.sh`、`regress.sh`、UVM TB（`sim/tb/`） |
| [sim/README.md](sim/README.md) | **仿真快速向导**：`make build` / `make sim` / `make regress`、日志与汇总文件路径 |

## 常用命令（摘要）

```bash
module load vcs
cd sim
make help
make build          # 编译门禁
make sim            # 默认 uart_sanity_test
make regress        # 生成 logs/regression_summary.log
```

更完整的变量说明与示例见 [sim/README.md](sim/README.md)。
