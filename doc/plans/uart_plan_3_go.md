# uart_plan_3_go

## 说明
- 本文件保存当前讨论版计划快照（go 版本），用于进入实现阶段。
- 详细主计划来源：`/home/tzhi/.cursor/plans/uart_rtl_与_uvm_vcs_0c01e20d.plan.md`。
- 历史快照：同目录 [uart_plan_1.md](uart_plan_1.md)、[uart_plan_2.md](uart_plan_2.md)。

## 本版执行要点
- 实现可综合 UART RTL：`uart_baud_gen`、`uart_tx`、`uart_rx`、`uart`。
- 搭建 UVM 风格 TB：`seq_item`/`sequencer`/`driver`/`monitor`/`agent`/`scoreboard`/`env`/`tests`。
- 提供单入口运行：`sim/run.sh` + `sim/README.md`。
- 提供编译门禁：`make build`（语法/elaboration 快速检查）。
- 提供回归汇总：`make regress` 生成 `logs/regression_summary.log`，
  包含 pass rate 与 failed case 错误摘要。
- 覆盖负向 case：`uart_neg_err_inject_test`，对预期错误支持 ignore/demote 策略。

## 默认规格
- UART 8N1，全双工。
- 可编程波特分频。
- TB 默认回环：`o_tx_serial -> i_rx_serial`。
