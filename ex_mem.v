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
	output reg mem_wreg,
    output reg[`RegBus] mem_hi,
    output reg[`RegBus] mem_lo,
    output reg mem_whilo,
    //HI LO from EX
    input wire[`RegBus] ex_hi,
    input wire[`RegBus] ex_lo,
    input wire ex_whilo
);

always @(posedge clk) begin
	if(rst == `RstEnable) begin 
		mem_wd <= `NOPRegAddr;
		mem_wreg <= `WriteDisable;
		mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
	end else begin 
		mem_wdata <= ex_wdata;
		mem_wd <= ex_wd;
		mem_wreg <= ex_wreg;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
	end
end

endmodule

