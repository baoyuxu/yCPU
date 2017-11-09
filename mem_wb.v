`include "defines.h"

module mem_wb (
	input wire rst,
	input wire clk,

	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,

	output reg[`RegAddrBus] wb_wd,
	output reg[`RegBus] wb_wdata,
	output reg wb_wreg
);

always @(*) begin 
	if(rst == `RstEnable) begin 
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
		wb_wd <= `NOPRegAddr;
	end else begin 
		wb_wreg <= mem_wreg;
		wb_wd <= mem_wd;
		wb_wdata <= mem_wdata;
	end

end

endmodule