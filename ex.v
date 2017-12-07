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
reg[`RegBus] shiftRes;

always @(*) begin //logic
	if(rst == `RstEnable) begin
		logicOut <= `ZeroWord;
	end else begin
		case (aluop_i)
			`EXE_OR_OP :begin
				logicOut <= reg1_i | reg2_i;
			end
			`EXE_AND_OP :begin 
				logicOut <= reg1_i & reg2_i;
			end
			`EXE_NOR_OP :begin 
				logicOut <= ~(reg1_i | reg2_i);
			end
			`EXE_XOR_OP :begin 
				logicOut <= reg1_i ^ reg2_i;
			end
			default : begin 
				logicOut <= `ZeroWord;
			end
		endcase
	end //if
end // always

always @(*) begin
	if(rst == `RstEnable) begin 
		shiftRes <= `ZeroWord;
	end else begin 
		case (aluop_i)
			`EXE_SLL_OP :begin 
				shiftRes <= reg2_i << reg1_i[4:0];
			end
			`EXE_SRL_OP :begin 
				shiftRes <= reg2_i >> reg1_i[4:0];
			end
			`EXE_SRA_OP :begin 
				shiftRes <= ({32{reg2_i[31]}}<<(6'd32-{1'b0, reg1_i[4:0]})) 
				| reg2_i >> reg1_i[4:0];
			end
			default : begin 
				shiftRes <= `ZeroWord;
			end
		endcase
	end

end

always @(*) begin //alusel_i
	wd_o <= wd_i;
	wreg_o <= wreg_i;
	case (alusel_i)
		`EXE_RES_LOGIC: begin
			wdata_o <= logicOut;
		end
		`EXE_RES_SHIFT :begin 
			wdata_o <= shiftRes;
		end
		default :begin 
			wdata_o <= `ZeroWord;
		end
	endcase
end

endmodule
