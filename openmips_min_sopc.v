`include "defines.h"

module openmips_min_sopc (
	input wire clk,
	input wire rst
);

wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

wire data_ram_ce_i;
wire data_ram_we_i;
wire[`DataAddrBus] data_ram_addr_i;
wire[3:0] data_ram_sel_i;
wire[`DataBus] data_ram_data_i;
wire[`DataBus] data_ram_data_o;

openmips openmips0(
	.clk       (clk),
	.rst       (rst),
	.rom_addr_o(inst_addr),
	.rom_data_i(inst),
	.rom_ce_o  (rom_ce),
    .ram_data_i(data_ram_data_o),
    .ram_data_o(data_ram_data_i),
    .ram_addr_o(data_ram_addr_i),
    .ram_we_o(data_ram_we_i),
    .ram_sel_o(data_ram_sel_i),
    .ram_ce_o(data_ram_ce_i)
);

inst_rom inst_rom0(
	.ce  (rom_ce),
	.addr(inst_addr),
	.inst(inst)
);

data_ram data_ram0(
    .clk(clk),
    .ce(data_ram_ce_i),
    .we(data_ram_we_i),
    .addr(data_ram_addr_i),
    .sel(data_ram_sel_i),
    .data_i(data_ram_data_i),
    .data_o(data_ram_data_o)
);

endmodule
