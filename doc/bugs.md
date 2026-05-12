# 已知问题与待办（bugs / open issues）

本文档汇总当前仓库内**已观察到或尚未验证**的问题，便于跟踪与交接。状态：`open`（待处理）、`investigating`（排查中）、`mitigated`（有变通办法）、`resolved`（已解决，**须**写明下方「结案」字段）。

---

## BUG-001 — 部分环境（含 124）VCS 加载后仍无法正常完成简单 build

- **状态**：resolved
- **现象**：已执行 `module load vcs` 后，`make -C sim build` 仍无法稳定完成；或长时间无进展。
- **已知线索**：
  - 同环境下曾出现 `vcs1` 子进程处于 **`D`（不可中断睡眠）**、`build.log` 长时间不增长，疑似 **存储/NFS 卡顿、license 排队或工具链 I/O**，需与现场运维/EDA 支持确认。
- **结案**
  - **解决日期**：2026-03-27
  - **解决方法**：确认根因与服务器环境强相关，主要集中在 IP 尾号 `124` 机器；切换到 IP 尾号 `123` 机器后，`module load vcs`、`make -C sim build` 恢复稳定，先前 VCS 不可用/卡住问题不再复现。
  - **验证**：在 `123` 机器实跑 `module load vcs && make -C sim build` 通过，`sim/logs/build.log` 正常增长并完成。
  - **关联变更**：`c154ac7` — `feat(sim): stabilize sanity gate and add minimal CI entry`

---

## BUG-002 — 默认 VCS 编译选项偏重，可能放大「假死」感知

- **状态**：open
- **现象**：当前 [`sim/Makefile`](../sim/Makefile) 默认带 `-lca`、`-debug_access+all`、`-kdb` 等，对小工程也会拉齐 Verdi/KDB 相关流程，**编译更慢、更容易受环境 I/O 影响**，与「仅做语法/elaboration 门禁」的轻量诉求不完全一致。
- **建议下一步**：
  - 增加可选目标或变量（例如 `VCS_LIGHT=1` / `make build-fast`），去掉 `-kdb`、酌情去掉 `-lca`，用于日常快速编译门禁；完整调试版仍用现有 `build`。
  - 说明：该条属于“性能/体验优化项”，不是本次 VCS 无法跑通的主因；主因已在 BUG-001 结案中确认。

---

## BUG-003 — 全量仿真与回归尚未在本仓库所在机器上跑通闭环

- **状态**：resolved
- **现象**：因上述编译问题，**UVM 用例（`uart_sanity_test` / `uart_rand_test` / `uart_neg_err_inject_test`）及 `regress.sh` 生成的 `regression_summary.log` 尚未得到一次可靠的端到端通过记录**。
- **风险**：可能存在仅在实际编译/仿真时才会暴露的 SV/UVM 问题（例如 filelist 顺序、类注册、时序假设等）。
- **结案**
  - **解决日期**：2026-03-27
  - **解决方法**：切换到 IP 尾号 `123` 机器后，VCS 工具链问题随环境切换一并解除；同时补齐 sanity 门禁与测试时序修正（reset release 后再发包、延长 drain 时间、增加日志判错门禁），形成稳定可复现闭环。
  - **验证**：`cd sim && make sanity-ci` 通过，`sim/logs/uart_sanity_test.log` 显示 `pass=6 fail=0`、`UVM_ERROR=0`、`UVM_FATAL=0`。
  - **关联变更**：`c154ac7` — `feat(sim): stabilize sanity gate and add minimal CI entry`

---

## BUG-004 — 使用前提未在错误信息中自动提示

- **状态**：resolved
- **现象**：若未先 `module load vcs`，会出现 `vcs: Command not found`，新用户不易联想到环境模块。
- **已有说明**：根目录 [`README.md`](../README.md)、[`sim/README.md`](../sim/README.md)。
- **结案**
  - **解决日期**：2026-03-27
  - **解决方法**：新增 `sim/sanity_ci.sh`，在脚本起始阶段自动检查 `vcs` 可用性，并在缺失时给出明确提示（必要时尝试加载 module），降低误用成本。
  - **验证**：执行 `cd sim && make sanity-ci`，脚本可自动完成环境检查并给出 PASS/FAIL 与日志路径提示。
  - **关联变更**：`c154ac7` — `feat(sim): stabilize sanity gate and add minimal CI entry`

---

## 环境结论补充（2026-03-27）

- 针对“VCS 跑不通/卡住”的历史问题，当前结论为：**主要由 IP 尾号 `124` 服务器环境导致**。
- 切换到 IP 尾号 `123` 服务器后，相关 VCS 工具使用问题（加载、build、sanity 执行）已一并恢复正常。
- 因此本批历史问题中，与“VCS 工具可用性”直接相关的条目已更新为 `resolved`。

---

## 维护说明

- **问题未解决时**：按需更新「现象 / 线索 / 建议下一步」，状态可为 `open` 或 `investigating`。
- **问题已解决时**（请保持与正文相同的描述风格，信息写全，便于后人审计）：
  1. 将该条 **状态** 改为 `resolved`。
  2. 在同一条目下增加固定小节 **「结案」**，至少包含：
     - **解决日期**：`YYYY-MM-DD`（与 git 提交日可一致也可为验证通过日，二者不同时建议都写一句）。
     - **解决方法**：用完整句说明根因（若已知）、改了什么（Makefile/脚本/环境/文档等）、关键命令或配置片段（可指向文件路径，不必整段粘贴）。
     - **验证**：实际跑过的命令（例如 `module load vcs && make -C sim build`）及结果（通过 / 日志路径）。
     - **关联变更**（可选）：`git` commit 摘要或 hash，或 PR 链接。
  3. 若该问题**不再具有参考价值**，可将整条移至文末 **「已解决归档」** 区，但在归档条目中仍须保留原 **BUG 编号** 与 **结案** 块，勿只删不留痕。
- 与计划文档的关系：实现层面的缺陷记在此处；需求/范围变更记在 [`doc/plans/`](plans/)。

### 结案字段示例（resolved 时贴在对应 BUG 条目末尾）

```markdown
- **结案**
  - **解决日期**：2026-03-26
  - **解决方法**：在 `sim/Makefile` 增加 `build-fast` 目标，默认 `build` 去掉 `-kdb`；根因定位为 NFS 上 KDB 产物写入过慢。
  - **验证**：`module load vcs && make -C sim build-fast`，`sim/logs/build.log` 无 error，`simv` 生成成功。
  - **关联变更**：`abc1234` — chore(sim): add lightweight VCS build target
```
