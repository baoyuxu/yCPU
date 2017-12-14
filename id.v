`include "defines.h"

module id (
	input wire rst,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	//Regfile input
	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,

	//Regfile output
	output reg reg1_read_o,
	output reg reg2_read_o,
	output reg[`RegAddrBus] reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,

	//Convert to EX
	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
    output wire[`RegBus] inst_o,

	//input from EX
	input wire ex_wreg_i,
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,

	//input from MEM
	input wire mem_wreg_i,
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,

    //output to CTRL
    output reg stallReq,
    
    //Branch
    input wire is_in_delayslot_i,
    output reg next_inst_in_delayslot_o,
    output reg branch_flag_o,
    output reg[`RegBus] branch_target_address_o,
    output reg[`RegBus] link_addr_o,
    output reg is_in_delayslot_o
);

assign inst_o = inst_i;

wire[5:0] op = inst_i[31:26]; //inst code
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0]; //func code
wire[4:0] op4 = inst_i[20:16];
reg[`RegBus] imm;
reg instValid;
//Branch
wire[`RegBus] pc_plus_8;
wire[`RegBus] pc_plus_4;
wire[`RegBus] imm_sll2_signedext;
assign pc_plus_8 = pc_i + 8;
assign pc_plus_4 = pc_i + 4;
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
//Decode
always @(*) begin
    stallReq <= `NoStop;
	if(rst == `RstEnable) begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		instValid <= `InstInvalid;
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		reg1_addr_o <= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
	end else begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o <= inst_i[15:11];
		wreg_o <= `WriteDisable;
		instValid <= `InstValid;
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		reg1_addr_o <= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
		case (op)
			`EXE_SPECIAL_INST: begin 
				case(op2)
					5'b00000:begin 
						case (op3)
							`EXE_OR :begin //OR
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_OR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_AND :begin //AND
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_AND_OP; 
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_XOR :begin //XOR
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_XOR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_NOR :begin //NOR
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_NOR_OP; 
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_SLLV :begin //SLLV
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SLL_OP; 
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_SRLV :begin //SRLV
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRL_OP; 
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_SRAV :begin //AND
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRA_OP; 
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_SYNC :begin //SYNC
								wreg_o <= `WriteDisable;
								aluop_o <= `EXE_NOP_OP; 
								alusel_o <= `EXE_RES_NOP;
								reg1_read_o <= `ReadDisable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
							end
							`EXE_MFHI :begin //MFHI
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_MFHI_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadDisable;
								reg2_read_o <= `ReadDisable;
								instValid <= `InstValid;
							end
							`EXE_MFLO :begin //MFLO
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_MFLO_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadDisable;
								reg2_read_o <= `ReadDisable;
								instValid <= `InstValid;
							end
							`EXE_MTHI :begin 
								wreg_o <= `WriteDisable;
								aluop_o <= `EXE_MTHI_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadDisable;
								instValid <= `InstValid;
							end
							`EXE_MTLO :begin 
								wreg_o <= `WriteDisable;
								aluop_o <= `EXE_MTLO_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadDisable;
								instValid <= `InstValid;
							end
							`EXE_MOVN :begin 
								aluop_o <= `EXE_MOVN_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
								if(reg2_o != `ZeroWord)begin 
									wreg_o <= `WriteEnable;
								end else begin 
									wreg_o <= `WriteDisable;
								end
							end
							`EXE_MOVZ :begin 
								aluop_o <= `EXE_MOVZ_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
								instValid <= `InstValid;
								if(reg2_o != `ZeroWord)begin 
									wreg_o <= `WriteEnable;
								end else begin 
									wreg_o <= `WriteDisable;
								end
                            end
                            `EXE_SLT :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLT_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_SLTU :begin 
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLTU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_ADD :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_ADD_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_ADDU :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_ADDU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_SUB :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SUB_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_SUBU :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SUBU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_MULT :begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MULT_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_MULTU :begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MULTU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_DIV :begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_DIV_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_DIVU : begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_DIVU_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instValid <= `InstValid;
                            end
                            `EXE_JR :begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_JR_OP;
                                alusel_o <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                link_addr_o <= `ZeroWord;
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                                instValid <= `InstValid;
                            end
                            `EXE_JALR :begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_JALR_OP;
                                alusel_o <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                wd_o <= inst_i[15:11];
                                link_addr_o <= pc_plus_8;
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                                instValid <= `InstValid;
                            end
							default :
							begin
							end
						endcase // op3
					end // 5'b00000
				endcase //op2

			end //`EXE_SPECIAL_INST

			`EXE_ORI : begin //ORI
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_OR_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= `ReadEnable;
				reg2_read_o <= `ReadDisable;
				imm <= {16'h0, inst_i[15:0]};
				wd_o <= inst_i[20:16];
				instValid <= `InstValid;
			end  //`EXE_ORI
			`EXE_ANDI :begin //ANDI
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_AND_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= `ReadEnable;
				reg2_read_o <= `ReadDisable;
				imm <= {16'h0, inst_i[15:0]};
				wd_o <= inst_i[20:16];
				instValid <= `InstValid;
			end
			`EXE_XORI :begin 
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_XOR_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= `ReadEnable;
				reg2_read_o <= `ReadDisable;
				imm <= {16'h0, inst_i[15:0]};
				wd_o <= inst_i[20:16];
				instValid <= `InstValid;
			end
			`EXE_LUI :begin 
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_OR_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= `ReadEnable;
				reg2_read_o <= `ReadDisable;
				imm <= {inst_i[15:0], 16'h0};
				wd_o <= inst_i[20:16];
				instValid <= `InstValid;
			end
			`EXE_PREF :begin 
				wreg_o <= `WriteDisable;
				aluop_o <= `EXE_NOP_OP;
				alusel_o <= `EXE_RES_NOP;
				reg1_read_o <= `ReadDisable;
				reg2_read_o <= `ReadDisable;
				instValid <= `InstValid;
            end
            `EXE_SLTI :begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLT_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= { {16{inst_i[15]}}, inst_i[15:0] };
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_SLTIU :begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLTU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= { {16{inst_i[15]}}, inst_i[15:0] };
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_ADDI :begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADDI_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= { {16{inst_i[15]}}, inst_i[15:0] };
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_ADDIU :begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADDIU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= { {16{inst_i[15]}}, inst_i[15:0] };
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_SPECIAL2_INST :begin
                case(op3)
                    `EXE_CLZ :begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instValid <= `InstValid;
                    end
                    `EXE_CLO :begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instValid <= `InstValid;
                    end
                    `EXE_MUL :begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_MUL_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instValid <= `InstValid;
                    end
                    `EXE_MADD :begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MADD_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instValid <= `InstValid;
                    end
                    `EXE_MADDU :begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MADDU_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instValid <= `InstValid;
                    end
                    `EXE_MSUB :begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MSUB_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instValid <= `InstValid;
                    end
                    `EXE_MSUBU :begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MSUBU_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instValid <= `InstValid;
                    end
                    default: begin 
                    end
                endcase //op3
            end //EXE_SPECIAL2_INST 
            `EXE_J: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_J_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                link_addr_o <= `ZeroWord;
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instValid <= `InstValid;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0],2'b00};
            end
            `EXE_JAL: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_JAL_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                wd_o <= 5'b11111;
                link_addr_o <= pc_plus_8;
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instValid <= `InstValid;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0],2'b00};
            end
            `EXE_BEQ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BEQ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
                if(reg1_o == reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BGTZ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BGTZ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
                if((reg1_o[31] == 1'b0) &&(reg1_o != `ZeroWord)) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BLEZ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BLEZ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                instValid <= `InstValid;
                if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BNE: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BNE_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
                if(reg1_o != reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_REGIMM_INST: begin
                case(op4) 
                    `EXE_BGEZ: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BGEZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instValid <= `InstValid;
                        if(reg1_o[31] == 1'b0) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BGEZAL: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_BGEZAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        link_addr_o <= pc_plus_8;
                        wd_o <= 5'b11111;
                        instValid <= `InstValid;
                        if(reg1_o[31] == 1'b0) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BLTZ: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BGEZAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instValid <= `InstValid;
                        if(reg1_o == 1'b1) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BLTZAL: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_BLTZAL_OP;//DIFF
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        link_addr_o <= pc_plus_8;
                        wd_o <= 5'b11111;
                        instValid <= `InstValid;
                        if(reg1_o[31] == 1'b1) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    default :begin
                    end
                endcase //op4
            end //EXE_REGIMM_INST
            `EXE_LB: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LBU: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LBU_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LH: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LH_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LHU: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LHU_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LW: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LWL: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LWL_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_LWR: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LWR_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                wd_o <= inst_i[20:16];
                instValid <= `InstValid;
            end
            `EXE_SB: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SB_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
            end
            `EXE_SH: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SH_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
            end
            `EXE_SW: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
            end
            `EXE_SWL: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SWL_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
            end
            `EXE_SWR: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SWR_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instValid <= `InstValid;
            end
			default: 
			begin
			end
		endcase //op

		if(inst_i[31:21] == 11'h0) begin 
			if(op3 == `EXE_SLL) begin 
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_SLL_OP;
				alusel_o <= `EXE_RES_SHIFT;
				reg1_read_o <= `ReadDisable;
				reg2_read_o <= `ReadEnable;
				imm[4:0] <= inst_i[10:6];
				wd_o <= inst_i[15:11];
				instValid <= `InstValid;
			end else if(op3 == `EXE_SRL) begin 
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_SRL_OP;
				alusel_o <= `EXE_RES_SHIFT;
				reg1_read_o <= `ReadDisable;
				reg2_read_o <= `ReadEnable;
				imm[4:0] <= inst_i[10:6];
				wd_o <= inst_i[15:11];
				instValid <= `InstValid;
			end else if(op3 == `EXE_SRA) begin 
				wreg_o <= `WriteEnable;
				aluop_o <= `EXE_SRA_OP;
				alusel_o <= `EXE_RES_SHIFT;
				reg1_read_o <= `ReadDisable;
				reg2_read_o <= `ReadEnable;
				imm[4:0] <= inst_i[10:6];
				wd_o <= inst_i[15:11];
				instValid <= `InstValid;
			end
		end
	end //if
end //always


always@(*) begin
    if(rst == `RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end


//Oprand 1

always @(*) begin
	if(rst == `RstEnable) begin
		reg1_o <= `ZeroWord;
	end else if((reg1_read_o == `ReadEnable)&&
				(ex_wreg_i == `WriteEnable)&&
				(ex_wd_i == reg1_addr_o)) begin 
		reg1_o <= ex_wdata_i;
	end else if((reg1_read_o == `ReadEnable)&&
				(mem_wreg_i == `WriteEnable)&&
				(mem_wd_i == reg1_addr_o)) begin 
		reg1_o <= mem_wdata_i;
	end else if(reg1_read_o == `ReadEnable) begin 
		reg1_o <= reg1_data_i;
	end else if( reg1_read_o == `ReadDisable) begin 
		reg1_o <= imm;
	end else begin 
		reg1_o <= `ZeroWord;
	end
end

//Oprand 2

always @(*) begin 
	if(rst == `RstEnable) 	begin
		reg2_o <= `ZeroWord;
	end else if((reg2_read_o == `ReadEnable)&&
				(ex_wreg_i == `WriteEnable)&&
				(ex_wd_i == reg2_addr_o)) begin 
		reg2_o <= ex_wdata_i;
	end else if((reg2_read_o == `ReadEnable)&&
				(mem_wreg_i == `WriteEnable)&&
				(mem_wd_i == reg2_addr_o)) begin 
		reg2_o <= mem_wdata_i;
	end else if(reg2_read_o == `ReadEnable) begin 
		reg2_o <= reg2_data_i;
	end else if( reg2_read_o == `ReadDisable) begin 
		reg2_o <= imm;
	end else begin 
		reg2_o <= `ZeroWord;
	end
end

endmodule

