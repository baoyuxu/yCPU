`include "defines.h"

module ex_mem (

	input wire rst,
	input wire clk,
	//input form EX
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	//output to MEM
	output reg[`RegBus] mem_wdata,
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg
);

always @(posedge clk) begin
	if(rst == `RstEnable) begin 
		mem_wd <= `NOPRegAddr;
		mem_wreg <= `WriteDisable;
		mem_wdata <= `ZeroWord;
	end else begin 
		mem_wdata <= ex_wdata;
		mem_wd <= ex_wd;
		mem_wreg <= ex_wreg;
	end
end

endmodule