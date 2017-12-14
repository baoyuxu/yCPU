`include "defines.h"

module openmips (
	input wire rst,
	input wire clk,

	input wire[`RegBus] rom_data_i,

	//DIFF 
	output wire[`RegBus] rom_addr_o,
	output wire rom_ce_o
);
// IF/ID - ID
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
// ID - ID/EX
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

// ID/EX - EX
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

//EX - EX/MEM
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;

wire ex_whilo_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;

wire[1:0] ex_cnt_o;
wire[`DoubleRegBus] ex_hilo_temp_o;

//EX/MEM - MEM
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;

wire mem_whilo_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;

wire[1:0] ex_cnt_i;
wire[`DoubleRegBus] ex_hilo_temp_i;

//MEM - MEM/WB
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;

wire mem_whilo_o;
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;

//MEM/WB
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

wire wb_whilo_i;
wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;

//HILO
wire[`RegBus] hilo_hi_o;
wire[`RegBus] hilo_lo_o;

//ID - Regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
//CTRL in&&out
wire[5:0] stall;
wire stallreq_from_id;
wire stallreq_from_ex;
//DIV
wire signed_div;
wire[`RegBus] div_opdata1;
wire[`RegBus] div_opdata2;
wire div_start;
wire[`DoubleRegBus] div_result;
wire div_ready;
//DelaySlot
wire[`RegBus] id_link_addr_o;
wire id_is_in_delayslot_o;
wire id_next_inst_in_delayslot_o;
wire[`RegBus] id_branch_target_address_o;
wire id_branch_flag_o;
wire ex_is_in_delayslot_i;
wire[`RegBus] ex_link_address_i;
wire id_is_in_delayslot_i;
//pc_reg 
pc_reg pc_reg0(
	.clk	  (clk),
	.rst	  (rst),
	.pc 	  (pc),
	.ce 	  (rom_ce_o),
    .stall(stall),
    .branch_flag_i(id_branch_flag_o),
    .branch_target_address_i(id_branch_target_address_o)
);

assign rom_addr_o = pc;

//IF/ID

if_id if_id0(
	.clk	(clk),
	.rst	(rst),
	.if_pc	(pc),
	.if_inst(rom_data_i),
	.id_pc  (id_pc_i),
	.id_inst(id_inst_i),
    .stall(stall)
);

//ID

id id0(
	.rst        (rst),
	.pc_i       (id_pc_i),
	.inst_i     (id_inst_i),

	.reg1_data_i(reg1_data),
	.reg2_data_i(reg2_data),

	.reg1_read_o(reg1_read),
	.reg2_read_o(reg2_read),
	.reg1_addr_o(reg1_addr),
	.reg2_addr_o(reg2_addr),

	.aluop_o    (id_aluop_o),
	.alusel_o   (id_alusel_o),
	.reg1_o     (id_reg1_o),
	.reg2_o     (id_reg2_o),

	.wd_o       (id_wd_o),
	.wreg_o     (id_wreg_o),

	.ex_wreg_i(ex_wreg_o),
	.ex_wdata_i(ex_wdata_o),
	.ex_wd_i(ex_wd_o),

	.mem_wreg_i(mem_wreg_o),
	.mem_wdata_i(mem_wdata_o),
	.mem_wd_i(mem_wd_o),
    .stallReq(stallreq_from_id),
    .is_in_delayslot_i(id_is_in_delayslot_i),
    .is_in_delayslot_o(id_is_in_delayslot_o),
    .link_addr_o(id_link_addr_o),
    .next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
    .branch_target_address_o(id_branch_target_address_o),
    .branch_flag_o(id_branch_flag_o)
);

//Regfile

regfile regfile1(
	.clk   (clk),
	.rst   (rst),
	.we    (wb_wreg_i),
	.waddr (wb_wd_i),
	.wdata (wb_wdata_i),
	.re1   (reg1_read),
	.raddr1(reg1_addr),
	.rdata1(reg1_data),
	.re2   (reg2_read),
	.raddr2(reg2_addr),
	.rdata2(reg2_data)
);

//ID/EX
id_ex id_ex0(
	.clk      (clk),
	.rst      (rst),
	.id_aluop (id_aluop_o),
	.id_alusel(id_alusel_o),
	.id_reg1  (id_reg1_o),
	.id_reg2  (id_reg2_o),
	.id_wd    (id_wd_o),
	.id_wreg  (id_wreg_o),

	.ex_aluop (ex_aluop_i),
	.ex_alusel(ex_alusel_i),
	.ex_reg1  (ex_reg1_i),
	.ex_reg2  (ex_reg2_i),
	.ex_wd    (ex_wd_i),
	.ex_wreg  (ex_wreg_i),
    .stall(stall),
    .id_link_address(id_link_addr_o),
    .id_is_in_delayslot(id_is_in_delayslot_o),
    .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
    .ex_is_in_delayslot(ex_is_in_delayslot_i),
    .ex_link_address(ex_link_address_i),
    .is_in_delayslot_o(id_is_in_delayslot_i)
);
//EX
ex ex0(
	.rst     (rst),
	.aluop_i (ex_aluop_i),
	.alusel_i(ex_alusel_i),
	.reg1_i  (ex_reg1_i),
	.reg2_i  (ex_reg2_i),
	.wd_i    (ex_wd_i),
	.wreg_i  (ex_wreg_i),

	.wd_o    (ex_wd_o),
	.wreg_o  (ex_wreg_o),
	.wdata_o (ex_wdata_o),

    .hi_i    (hilo_hi_o),
    .lo_i(hilo_lo_o),
    .wb_whilo_i(wb_whilo_i),
    .wb_hi_i(wb_hi_i),
    .wb_lo_i(wb_lo_i),
    .mem_hi_i(mem_hi_o),
    .mem_whilo_i(mem_whilo_o),
    .mem_lo_i(mem_lo_o),
    .whilo_o(ex_whilo_o),
    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .stallReq(stallreq_from_ex),
    .hilo_temp_i(ex_hilo_temp_i),
    .cnt_i(ex_cnt_i),
    .cnt_o(ex_cnt_o),
    .hilo_temp_o(ex_hilo_temp_o),

    .div_result_i(div_result),
    .div_ready_i(div_ready),
    .div_opdata1_o(div_opdata1),
    .div_opdata2_o(div_opdata2),
    .div_start_o(div_start),
    .signed_div_o(signed_div),
    .link_address_i(ex_link_address_i),
    .is_in_delayslot_i(ex_is_in_delayslot_i)
);
//EX/MEM

ex_mem ex_mem0(
	.clk      (clk),
	.rst      (rst),

	.ex_wd    (ex_wd_o),
	.ex_wreg  (ex_wreg_o),
	.ex_wdata (ex_wdata_o),

	.mem_wd   (mem_wd_i),
	.mem_wreg (mem_wreg_i),
	.mem_wdata(mem_wdata_i),

    .ex_whilo(ex_whilo_o),
    .ex_hi(ex_hi_o),
    .ex_lo(ex_lo_o),
    .mem_whilo(mem_whilo_i),
    .mem_hi(mem_hi_i),
    .mem_lo(mem_lo_i),
    .stall(stall),
    .hilo_i(ex_hilo_temp_o),
    .cnt_i(ex_cnt_o),
    .cnt_o(ex_cnt_i),
    .hilo_o(ex_hilo_temp_i)

);

//MEM
mem mem0(
	.rst    (rst),

	.wd_i   (mem_wd_i),
	.wreg_i (mem_wreg_i),
	.wdata_i(mem_wdata_i),

	.wd_o   (mem_wd_o),
	.wreg_o (mem_wreg_o),
	.wdata_o(mem_wdata_o),

    .whilo_i(mem_whilo_i),
    .hi_i(mem_hi_i),
    .lo_i(mem_lo_i),
    .whilo_o(mem_whilo_o),
    .hi_o(mem_hi_o),
    .lo_o(mem_lo_o)

);
//MEM/WB

mem_wb mem_wb0(
	.clk      (clk),
	.rst      (rst),
	.mem_wd   (mem_wd_o),
	.mem_wreg (mem_wreg_o),
	.mem_wdata(mem_wdata_o),

	.wb_wd    (wb_wd_i),
	.wb_wreg  (wb_wreg_i),
	.wb_wdata (wb_wdata_i),

    .mem_whilo(mem_whilo_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_whilo(wb_whilo_i),
    .stall(stall)
);

//HILO
hilo_reg hilo0(
    .clk(clk),
    .rst(rst),
    .we(wb_whilo_i),
    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),
    .hi_o(hilo_hi_o),
    .lo_o(hilo_lo_o)
);

//CTRL
ctrl ctrl0(
    .rst(rst),
    .stallreq_from_id(stallreq_from_id),
    .stallreq_from_ex(stallreq_from_ex),
    .stall(stall)
);

div div0(
    .clk(clk),
    .rst(rst),

    .signed_div_i(signed_div),
    .opdata1_i(div_opdata1),
    .opdata2_i(div_opdata2),
    .start_i(div_start),
    .annul_i(1'b0),
    .result_o(div_result),
    .ready_o(div_ready)
);

endmodule

