# 项目文档索引

本目录汇总 **UART 工程** 的计划、设计与验证相关说明；**RTL 与 testbench 源码**仍分别位于仓库根下 [`rtl/`](../rtl/) 与 [`sim/`](../sim/)。

## 分类导航

| 类别 | 文档 | 说明 |
|------|------|------|
| 计划与迭代 | [plans/](plans/) | UART RTL + UVM/VCS 计划快照（v1 / v2 / go） |
| RTL 清单 | [rtl.md](rtl.md) | 可综合 UART 模块文件列表与职责摘要 |
| 仿真与验证 | [simulation.md](simulation.md) | UVM TB、VCS 入口、回归与「编译是否 hang」判定要点 |
| Sanity 实跑记录 | [sanity_case_run_2026-03-26.md](sanity_case_run_2026-03-26.md) | 本机实跑、故障定位、修复动作与复盘结论 |
| 编码规范 | [conventions.md](conventions.md) | RTL/UVM 风格规则入口（`.cursor/rules.mdc`） |
| 已知问题 | [bugs.md](bugs.md) | 环境/VCS 编译、轻量门禁与全量仿真回归等待办 |

## 仓库内其他重要入口（非 doc 内）

- 仿真快速上手：[`sim/README.md`](../sim/README.md)
- Cursor 项目规则：[`../.cursor/rules.mdc`](../.cursor/rules.mdc)
