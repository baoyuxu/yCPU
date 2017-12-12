`include "defines.h"

module mem_wb (
	input wire rst,
	input wire clk,
    //From MEM
	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
    input wire[`RegBus] mem_hi,
    input wire[`RegBus] mem_lo,
    input wire mem_whilo,
    //To WB 
	output reg[`RegAddrBus] wb_wd,
	output reg[`RegBus] wb_wdata,
	output reg wb_wreg,
    output reg [`RegBus] wb_hi,
    output reg [`RegBus] wb_lo,
    output reg wb_whilo
);

always @(*) begin 
	if(rst == `RstEnable) begin 
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
		wb_wd <= `NOPRegAddr;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
	end else begin 
		wb_wreg <= mem_wreg;
		wb_wd <= mem_wd;
		wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;
	end

end

endmodule

