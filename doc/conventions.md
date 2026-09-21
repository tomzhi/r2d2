# 编码规范入口

项目当前采用以下 RTL 与 UVM 约定：

- 命名：`i_` / `o_` / `r_` / `w_`；常量与参数大写  
- SystemVerilog：`logic`、`always_ff` / `always_comb`；RTL 内不用 `#delay` / `initial`（TB 除外）  
- UVM：一文件一类、`m_` 成员、`uvm_*_utils`、driver `get_next_item`/`item_done`、monitor `analysis_port` 等  
