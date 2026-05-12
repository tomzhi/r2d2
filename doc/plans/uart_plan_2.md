---
name: UART RTL 与 UVM/VCS（备份 uart_plan_2）
overview: 在空仓库中从零实现符合 .cursor/rules.mdc 的分层 UART RTL，并搭建标准 UVM agent/env/test 与 VCS 编译仿真流程；默认采用 8N1、可编程波特分频、主机侧并行握手接口，验证以回环与随机激励为主。
note: 本文件为计划全文快照（对应主计划加入「编译门禁/回归汇总」迭代之前的状态可对照 uart_plan_1）；最新内容以 .cursor/plans 为准。
todos:
  - id: rtl-baud-tx-rx
    content: 实现 rtl/uart_baud_gen.sv、uart_tx.sv、uart_rx.sv、uart.sv，遵循 rules.mdc 命名与时序风格
  - id: rtl-sva
    content: 为 TX/RX 帧与 baud_tick 行为添加 SVA（内联或 bind）
  - id: tb-if-pkg
    content: 添加 sim/tb/uart_if.sv、uart_pkg.sv 与 filelist 顺序
  - id: uvm-agent
    content: 实现 seq_item、sequencer、driver、monitor、agent（get_next_item/item_done、analysis_port）
  - id: uvm-env-sb
    content: 实现 scoreboard、env、base_test、sanity/rand 序列与 tb_top + config_db
  - id: vcs-makefile
    content: 编写 sim/Makefile（或脚本）：VCS+UVM 编译、UVM_TESTNAME、回归入口
  - id: run-guide
    content: 提供单一入口 sim/run.sh（或 make help）与 sim/README 中的运行向导（变量、示例命令）
  - id: err-inject-neg
    content: 增加负向/错误注入用例；对预期 UVM_ERROR 使用 report_catcher 降级或文档化 ignore 模式
---

# UART RTL 编码计划与 UVM/VCS 验证计划

**备份**：更早快照见同目录 [uart_plan_1.md](uart_plan_1.md)。

## 问答（相对 uart_plan_1 的补充说明）

### Q1）RTL 是否为可综合代码风格？

**是。** 计划中的 RTL 主体按 `.cursor/rules.mdc` 编写，意图为 **ASIC/FPGA 可综合**：

- 时序用 `always_ff`、组合用 `always_comb`，`logic`，异步低有效 `rstn` 显式复位。
- 避免 `#delay`、`initial`（RTL 内）、锁存推断及不可综合构造。

**需注意**：**SVA / `bind` 断言模块** 通常仅用于仿真；若需形式验证或带断言综合，要按目标工具链将断言约束在支持范围内（否则保持 `ifdef` 或独立 bind 文件，不混入必须综合的核心 RTL）。TB 侧 `initial`、`#delay` 仅出现在 testbench，不影响 DUT 可综合性。

### Q2）验证是否有一个入口脚本或清晰运行向导？

**uart_plan_1 仅概括了 Makefile；迭代后要求在交付物中明确「单一入口 + 文档」。**

实现阶段将包含：

- **推荐**：`sim/run.sh`（可执行）内部调用 `make` 或 `vcs`/`simv`，支持参数如 `TEST=`、`GUI=`；同一目录下 `sim/README.md` 写明：环境变量（`UVM_HOME`、`VCS_*`）、**一条命令跑默认用例**、常见变体（换 test、开 Verdi、清理）。
- **Makefile**：`make sim`、`make clean`、`make help` 列出目标与变量。

这样 CI 与本地都只需记「进 `sim/` → `./run.sh` 或 `make sim`」。

### Q3）验证计划是否包含「错误注入」及预期错误的 ignore 模式？

**uart_plan_1 未单独展开；当前计划已纳入负向场景与预期报错处理策略。**

- **错误注入用例（示例方向，实现时与 DUT 能力对齐）**：
  - 串行线 **停止位非高**（framing）或 **起始位毛刺**，若 scoreboard / 参考模型判定应丢弃或报错，则 test 预期 **不匹配次数** 或 **DUT 状态机回到 idle**。
  - **波特不匹配**：TX 与 RX 使用不同分频（通过配置或第二个 agent）时，scoreboard 预期 **误码或超时**，用例标记为 negative。
  - **Scoreboard 故意注入**：对 `uart_scoreboard` 注入已知 bad 比对，触发 **预期** 的 `uvm_error`（仅在该 test 内启用）。
- **「符合预期的错误」与 ignore / 过滤**（择一或组合，实现时写进 `sim/README`）：
  1. **UVM `uvm_report_catcher`**：在 negative test 的 `build_phase` 注册 catcher，对 **固定 ID/消息子串** 的 `UVM_ERROR` **降级为 UVM_INFO** 或丢弃，使该用例仍以 0 真实 error 退出； catcher 内用 `uvm_info` 打印「expected error suppressed」便于日志审计。
  2. **+UVM_MAX_QUIT_COUNT**：仅当希望允许 N 次 error 后仍结束仿真时使用；需与团队规范一致，**不如 catcher 精确**。
  3. **回归脚本层 ignore**：若使用外部日志检查（如 `grep` CI），为 negative test 配置 **per-test 允许的 pattern 列表**（文档中给出示例正则）；与 1 相比，维护在 shell/yml 中。

**验收**：正向用例必须 0 UVM_ERROR；负向用例要么通过 catcher 抑制预期报错，要么回归脚本对**该用例**单独声明允许的 error 条数/模式，并在 README 中列出，避免与真实失败混淆。

---

## 前提与默认规格（可在实现前调整）

- **功能范围**：全双工 UART，**8 数据位、无校验、1 停止位（8N1）**；**可编程波特分频**（基于 `i_clk` 的整数分频计数器，产生 `baud_tick`）。
- **DUT 边界（主机侧并行接口）**：
  - **TX**：`i_tx_data[7:0]`、`i_tx_valid`、`o_tx_ready`，输出 `o_tx_serial`（空闲为高）。
  - **RX**：`i_rx_serial`、`o_rx_data[7:0]`、`o_rx_valid`（单周期或握手由设计固定一种并在 TB 对齐）。
- **复位**：异步低有效 `i_rstn`，所有时序逻辑在 `always_ff` 内显式复位（与规则一致）。
- **验证策略**：TB 顶层将 **`o_tx_serial` 回环到 `i_rx_serial`**，Scoreboard 比对「经 TX 发送的字节」与「RX 收到的字节」；另加负向/错误注入用例（见上文「Q3」与 §2.2）。

若你后续需要 **APB/AHB 寄存器接口、FIFO 深度>1、校验位、多停止位**，可在 RTL 计划中追加一层 `uart_reg_if` 或参数化扩展，本计划按最小可综合、可验证闭环实现。

---

## 一、RTL 编码计划

### 1.1 目录与文件

建议布局（实现阶段创建）：

- `rtl/uart_baud_gen.sv` — 波特 tick 生成（参数或输入配置分频值）。
- `rtl/uart_tx.sv` — 发送移位与状态机：空闲 → 起始位 → 8 数据位 → 停止位；仅在 `baud_tick` 推进。
- `rtl/uart_rx.sv` — 接收：起始位检测、中点采样、8 位组装、停止位检查；同样在 `baud_tick` 上采样/移位。
- `rtl/uart.sv` — 顶层例化 baud、tx、rx，引出端口与 **可写分频寄存器**（简单内部寄存器即可，避免一上来就上总线协议）。

### 1.2 编码约束（对齐 .cursor/rules.mdc）

- 命名：`i_`/`o_`/`r_`/`w_`，小写+下划线；常量/参数大写。
- 仅 `logic`；`always_ff`（时序）+ `always_comb`（组合）；FSM 采用双 always 或三 always，**case 带 `default`**。
- **无**可综合代码中的 `#delay`、`initial`、锁存器推断；TX/RX 分模块便于断言挂载。
- **SVA**：在 `uart_tx`/`uart_rx` 内或 `bind` 模块中，对「帧长度、空闲电平、在 baud_tick 上状态迁移」等加局部断言（与规则「断言与逻辑共置」一致）。

### 1.3 微架构要点

- **Baud**：`i_div` 或寄存器装载值 → 每计数归零产生一个 `w_baud_tick`（TX/RX 共用，避免两套不一致）。
- **TX FSM**：`i_tx_valid && o_tx_ready` 取数后锁存数据再发；发送期间 `o_tx_ready` 拉低。
- **RX**：下降沿判起始后，**半位延迟再按 tick 中点采样**（经典 16×过采样若资源允许可后续迭代；首版可用「每 bit 一个 tick」+ 起始对齐逻辑，规则允许的前提下保持可综合、时序清晰）。

---

## 二、模块验证计划（UVM + VCS）

### 2.1 Testbench 目录与类（每类单文件，文件名=类名）

建议 `sim/tb/` 下：

| 文件 | 职责 |
|------|------|
| `uart_if.sv` | `interface`：clk、rstn、DUT 并行口、串行线；可含 `clocking block` 供 driver/monitor |
| `uart_pkg.sv` | `package`：typedef、参数、公共宏；**RTL 侧禁用 `import pkg::*`**，TB 允许 |
| `uart_seq_item.sv` | `uvm_sequence_item`：`rand` 数据、事务类型（TX 写、可选延迟）、constraint |
| `uart_sequencer.sv` | `uvm_sequencer#(uart_seq_item)` |
| `uart_driver.sv` | `get_next_item` / `item_done`，通过 modport 驱动并行口；按 DUT 握手规则 |
| `uart_monitor.sv` | 在有效完成边界采样并行 TX/RX 事务，`analysis_port.write()` |
| `uart_agent.sv` | 组合 driver/monitor/sequencer，`uvm_analysis_port` 引出 |
| `uart_scoreboard.sv` | `uvm_subscriber` 或双 `analysis_imp`：维护期望队列，比对 TX→RX 回环数据 |
| `uart_env.sv` | 例化 agent、scoreboard，`connect_phase` 连接 analysis |
| `uart_base_test.sv` | `build_phase` 建 env，`run_phase` 起 default_sequence |
| `uart_sanity_seq.sv` / `uart_rand_seq.sv` | 定向若干字节 + 随机长度/间隔 |
| `tb_top.sv` | 产生 clk/rstn，例化 DUT + `uvm_config_db#(virtual uart_if)::set`，`run_test()` |

规范要点：`m_` 成员、`uvm_*_utils`、`uvm_info` 替代 `$display`、**objection 仅在 sequence/test 中**、关键参数在 `end_of_elaboration_phase` 打印。

### 2.2 功能覆盖与用例

- **Covergroup**（放在 `uart_monitor` 或独立 subscriber）：覆盖数据字节分布、背靠背事务、随机间隔、不同分频值（在合法范围内若干 bin）。
- **测试用例**：
  1. **sanity**：固定分频、固定模式 `0x55`/`0xAA`，回环比对全通过。
  2. **rand_stress**：随机数据、随机 valid 间隙、随机分频（约束在仿真时间可承受范围）。
  3. **reset**：发送中途复位，检查无挂死、恢复后首包正确（可选，视 DUT 行为定预期）。
  4. **neg_err_inject**（负向）：串行线破坏（停止位错误、毛刺）、波特不一致等；预期行为与 scoreboard/SVA 对齐；预期 `uvm_error` 通过 **report_catcher** 或 **回归脚本 per-test ignore 列表**处理（见 Q3）。

### 2.3 VCS 仿真流程

- 新增 `sim/filelist.f`（或分 `rtl.f` / `tb.f`）：列出 RTL、TB、UVM 相关文件顺序（package/interface 在前）。
- 新增 `sim/Makefile`，并加 **入口** `sim/run.sh` + `sim/README.md`（运行向导）：
  - 使用本机 **Synopsys VCS** 的 UVM 选项（常见组合如 `-full64 -sverilog` + `-ntb_opts uvm-1.2` 或安装文档推荐的 `-uvm`，以你环境 `vcs -help` / 站点脚本为准）。
  - `+UVM_TESTNAME=...`、`+UVM_VERBOSITY=UVM_MEDIUM`。
  - 依赖 **`UVM_HOME`** 或工具自带 UVM 库路径（Makefile 中变量化，便于 CI/本机切换）。
- **回归**：`./run.sh` 或 `make sim` 默认跑 sanity；`make sim TEST=uart_rand_test` 等扩展（测试类名与 `run_test` 一致）；`make help` 列出变量与示例。

### 2.4 验收标准

- VCS 编译无 error；UVM 报告 **0 UVM_ERROR**（及你团队要求的 **FATAL** 规则）。
- Scoreboard 在全部计划用例中比对一致；覆盖报告中有合理 bin 命中（若启用 `-cm` 等覆盖选项则另列）。

---

## 三、建议实施顺序

1. 实现 `uart_baud_gen` → `uart_tx` → `uart_rx` → `uart` 顶层，并做基础波形自查。
2. 搭建 `uart_if` + `tb_top` + 简单 `initial` 非 UVM 冒烟（可选极短脚本）确认连线；再迁入 UVM package/agent。
3. 完成 scoreboard + sanity/rand 序列 + Makefile/VCS 命令固化。
4. 补 SVA、覆盖与 reset 用例。

---

## 风险与依赖

- **VCS/UVM 版本**与编译开关因安装而异；计划以「可配置 Makefile 变量」落地，避免写死路径。
- 若 RX 采用「单 tick 每位」而非 16× 过采样，抗噪/skew 较弱，但对 **功能仿真 + 回环** 足够；后续若上 FPGA/ASIC 可再增强采样策略。
