`include "defines.h"

module ex (
	input wire rst,
	//input from ID/EX
	input wire[`AluSelBus] alusel_i,
	input wire[`AluOpBus] aluop_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,

	//output
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o
);

reg[`RegBus] logicOut;

always @(*) begin
	if(rst == `RstEnable) begin
		logicOut <= `ZeroWord;
	end else begin
		case (aluop_i)
			`EXE_OR_OP: begin
				logicOut <= reg1_i | reg2_i;
			end
			default : begin 
				logicOut <= `ZeroWord;
			end
		endcase
	end //if
end // always

always @(*) begin
	wd_o <= wd_i;
	wreg_o <= wreg_i;
	case (aluop_i)
		`EXE_OR_OP: begin
			wdata_o <= logicOut;
		end
		default :begin 
			wdata_o <= `ZeroWord;
		end
	endcase
end

endmodule
