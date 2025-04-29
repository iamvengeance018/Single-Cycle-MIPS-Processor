`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2025 08:58:14
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Verilog Code for 50-instruction Single Cycle MIPS Processor

// 3.1.1 Adder
module adder(input [31:0] a, input [31:0] b, output [31:0] c);
  assign c = a + b;
endmodule

// 3.1.2 D Flip Flop
module dff(input clk, input rst, input[31:0] d, output reg[31:0] q);
  always @(posedge clk or posedge rst) begin
    if(rst)    
        q <= 0;
    else
        q <= d;
    end
endmodule

// 3.1.3 D Flip Flop with Enable
module dff_e(input clk, input rst, input[31:0] d, input enable, output reg[31:0] q);
  always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 0;
    else if(enable==1)
        q <= d;
    end
endmodule

// 3.1.4 Shifter by 2
module shift2(input [31:0] a, output [31:0] shifted);
  assign shifted = a << 2;
endmodule

// 3.1.5 Sign Extension
module sign_extend(input [15:0] a, output [31:0] extend);
  assign extend = {{16{a[15]}},a[15:0]};
endmodule

// 3.1.6 Multiplexers (2x1, 4x1, 8x1)
module mux2x1(input [31:0] a, input [31:0] b, input select, output [31:0] c);
  assign c = (select==1) ? b : a;
endmodule

module mux4x1(input [31:0] a0, input [31:0] a1, input [31:0] a2, input [31:0] a3, input [1:0] select, output [31:0] c);
  assign c = (select == 2'b00) ? a0 : (select == 2'b01) ? a1 : (select == 2'b10) ? a2 : a3;
endmodule

module mux8x1(input [31:0] a0, input [31:0] a1, input [31:0] a2, input [31:0] a3,
              input [31:0] a4, input [31:0] a5, input [31:0] a6, input [31:0] a7,
              input [2:0] select, output [31:0] c);
  assign c = (select == 3'b000) ? a0 : (select == 3'b001) ? a1 : (select == 3'b010) ? a2 : (select == 3'b011) ? a3 : 
             (select == 3'b100) ? a4 : (select == 3'b101) ? a5 : (select == 3'b110) ? a6 : a7;
endmodule

// 3.1.7 ALU
module alu(input [31:0] a, input [31:0] b, input [4:0] opcode, output reg [31:0] c,
           output zero_flag, output gt, output lt, output lt_sign, output reg overflow);
  assign zero_flag=(c==0)?1:0;
  assign gt=(a>b)?1:0;
  assign lt=(a<b)?1:0;
  assign lt_sign=($signed(a)<$signed(b))?1:0;
  always @(*) begin
    overflow=0;
    case (opcode)
      5'b00000: c = a & b;
      5'b00001: c = a | b;
      5'b00010: c = a + b;
      5'b00011: c = a ^ b;
      5'b00100: c = a * b;
      5'b00101: c = a - b;
      5'b00111: c = ($signed(a) < $signed(b)) ? 1 : 0;
      5'b01000: c = b<<a[4:0];
      5'b01001: c = b>>a[4:0];
      5'b01010: c = $signed($signed(b)>>>a[4:0]);
      5'b01011: c = ~(a ^ b);
      5'b01100: c = ~(a | b);
      5'b01101: begin
                    c=a+b;
                    overflow=( (a[31]==b[31]) && (a[31]!=c[31]) ) ? 1 : 0;
                end
      5'b01110: begin
                    c=a-b;
                    overflow=( (a[31]!=b[31]) && (a[31]==c[31]) ) ? 1 : 0;
                end
      5'b01111: c = ($unsigned(a) < $unsigned(b)) ? 1 : 0;
      default: c = 0;
    endcase
  end
endmodule

// 3.1.8 Register File
module register_file(input clk, input rst, input we3, input[4:0]a1, input[4:0]a2, input[4:0]a3, 
                     output[31:0]rd1, output[31:0]rd2, input[31:0]wd3);
  reg[31:0]reg_file[31:0];
  integer i;
  // Synchronous read implementation
    reg [31:0] rd1_reg, rd2_reg;
    always @(posedge clk) begin
        rd1_reg <= (a1 != 0) ? reg_file[a1] : 0;
        rd2_reg <= (a2 != 0) ? reg_file[a2] : 0;
    end
    assign rd1 = rd1_reg;
    assign rd2 = rd2_reg;
  always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<32;i=i+1)
            reg_file[i]<=0;
    end else if(we3==1)
        reg_file[a3]<=wd3;
  end
endmodule

// 3.1.9 Datapath Top Module
module datapath(
    input clk,
    input rst,
    input [2:0] memtoreg,
    input pcsrc,
    input [1:0] alusrc,
    input [1:0] regdst,
    input regwrite,
    input jump,
    input [4:0] alucontrol,
    input [31:0] reg_file_from_mem,
    input [31:0] instr,
    input [1:0] zero_sign,
    input [1:0] lo_src,
    input [1:0] hi_src,
    input lo_write,
    input hi_write,
    input jr,
    input srca_c,
    input mult_sign,
    input div_sign,
    output [31:0] pc_val,
    output [31:0] alu_result,
    output [31:0] mem_write_data,
    output zero_flag,
    output [5:0] funct,
    output [5:0] op_code,
    output rt0,
    output gt,
    output lt,
    output lt_sign,
    output overflow
);

    wire [31:0] pcplus4;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;
    wire [31:0] jump_address;
    wire [4:0] write_into_reg;
    wire [31:0] hi_dff, hi_qff, lo_dff, lo_qff;
    wire [31:0] srcb;
    wire [31:0] srca;
    wire [31:0] div, rem;
    wire [31:0] shamt;
    wire [31:0] long_mult;
    wire [31:0] signimmx4;
    wire [31:0] signimm;
    wire [31:0] pc_dff;
    wire [31:0] pcbranch;
    wire [31:0] pc_d1;
    wire [31:0] pc_d2;

    mux2x1 pc_mux1(pcplus4, pcbranch, pcsrc, pc_d1);
    mux2x1 pc_mux2(pc_d1, jump_address, jump, pc_d2);
    mux2x1 pc_mux3(pc_d2, rd1, jr, pc_dff);  // <-- renamed to avoid duplication

    mux4x1 mux_pc_reg_file(instr[20:16], instr[15:11], 5'd31, 5'd0, regdst, write_into_reg);
    mux4x1 hi_mux(rd1, long_mult[31:16], rem, 32'd0, hi_src, hi_dff);
    mux4x1 lo_mux(rd1, long_mult[15:0], div, 32'd0, lo_src, lo_dff);

    mux8x1 write_reg_input(
        alu_result,
        reg_file_from_mem,
        hi_qff,
        lo_qff,
        pcplus4,
        {31'd0, lt},
        signimm,
        {31'd0, lt_sign},
        memtoreg,
        wd3
    );

    mux4x1 srcb_mux(rd2, signimm, 32'd0, 32'd0, alusrc, srcb);
    mux2x1 srca_mux(rd1, shamt, srca_c, srca);

    adder pc_brunch(signimmx4, pcplus4, pcbranch);
    adder pc_4(pc_val, 32'd4, pcplus4);
    shift2 inst_numx4(signimm, signimmx4);
    sign_extend sign_ex(instr[15:0], signimm);  // Only one input; update if needed

    alu alu_cpu(srca, srcb, alucontrol, alu_result, zero_flag, gt, lt, lt_sign, overflow);

    register_file regs(clk, rst, regwrite, instr[25:21], instr[20:16], write_into_reg, rd1, rd2, wd3);
    dff pc_dff_obj(clk, rst, pc_dff, pc_val);
    dff_e hi_dff_obj(clk, rst, hi_dff, hi_write, hi_qff);
    dff_e lo_dff_obj(clk, rst, lo_dff, lo_write, lo_qff);

    assign shamt = {27'd0, instr[10:6]};
    assign op_code = instr[31:26];
    assign funct = instr[5:0];
    assign rt0 = instr[16];
    assign mem_write_data = rd2;
    assign jump_address = {pcplus4[31:28], instr[25:0], 2'b00};
    assign long_mult = (mult_sign==0) ? (rd1 * rd2) : ($signed(rd1) * $signed(rd2));
    // Sequential division implementation
    reg [31:0] div_reg, rem_reg;
    always @(posedge clk) begin
        if (div_sign) begin
            div_reg <= $signed(rd1) / $signed(rd2);
            rem_reg <= $signed(rd1) % $signed(rd2);
        end else begin
            div_reg <= rd1 / rd2;
            rem_reg <= rd1 % rd2;
        end
    end
    assign div = div_reg;
    assign rem = rem_reg;

endmodule

// 3.2.1 Data Memory
module ram(
    input clk, 
    input rst, 
    input [31:0] addr, 
    input [31:0] data_in,
    input write_enable, 
    input [1:0] mem_data_size,
    output reg [31:0] data_out
);

parameter MEM_SIZE = 4096;  // Reduced from 65536 to 4096 (4KB)
(* ram_style = "block" *) reg [7:0] mem [0:MEM_SIZE-1];
wire [31:0] eff_addr = addr & (MEM_SIZE-1);

// Write process
always @(posedge clk) begin
    if (write_enable) begin
        case (mem_data_size)
            2'b00: mem[eff_addr] <= data_in[7:0];
            2'b01: begin
                mem[eff_addr] <= data_in[7:0];
                mem[eff_addr+1] <= data_in[15:8];
            end
            2'b10: begin
                mem[eff_addr] <= data_in[7:0];
                mem[eff_addr+1] <= data_in[15:8];
                mem[eff_addr+2] <= data_in[23:16];
                mem[eff_addr+3] <= data_in[31:24];
            end
        endcase
    end
end

// Read process
always @(posedge clk) begin
    case (mem_data_size)
        2'b00: data_out <= {{24{mem[eff_addr][7]}}, mem[eff_addr]};
        2'b01: data_out <= {{16{mem[eff_addr+1][7]}}, mem[eff_addr+1], mem[eff_addr]};
        2'b10: data_out <= {mem[eff_addr+3], mem[eff_addr+2], mem[eff_addr+1], mem[eff_addr]};
        default: data_out <= 32'b0;
    endcase
end
endmodule


// 3.2.2 Instruction Memory
module instruct_mem(input [31:0] pc, output [31:0] inst);
  reg [31:0] mem[0:255];
  initial begin
    $readmemh("memfile_test1.dat", mem);
  end
  assign inst = mem[pc[31:2]];  // Word aligned access
endmodule

module aludec(
  input [1:0] alu_op,
  input [5:0] opcode,
  input [5:0] funct,
  output reg [4:0] alucontrol
  );
  always@(*) begin
    if (alu_op == 2'b00) begin
      alucontrol = 5'b00010;
    end else if (alu_op == 2'b01) begin
      alucontrol = 5'b00110;
    end else if (alu_op == 2'b10) begin
    // Core operations only
        case(funct)
            6'b100000: alucontrol = 5'b00010;  // ADD
            6'b100010: alucontrol = 5'b00101;  // SUB
            6'b100100: alucontrol = 5'b00000;  // AND
            6'b100101: alucontrol = 5'b00001;  // OR
            6'b000000: alucontrol = 5'b01000;  // SLL
            default:    alucontrol = 5'b00010;  // Default to ADD
        endcase
    end else begin
      if(opcode == 6'd8)
        alucontrol = 5'b01101;
      if(opcode == 6'd12)
        alucontrol = 5'b00000;
      else if(opcode == 6'd13)
        alucontrol = 5'b00001;
      else if(opcode == 6'd14)
        alucontrol = 5'b00011;    
    end
  end
endmodule

module maindec(
  input [5:0] op,
  input [5:0] funct,
  output [2:0] memtoreg,
  output memwrite,
  output [1:0] alusrc,
  output [1:0] regdst,
  output regwrite,
  output branch,
  output jump,
  output [1:0] alu_op,
  output [1:0] zero_sign,
  output [1:0] mem_data_size,
  output [1:0] lo_src,
  output [1:0] hi_src,
  output lo_write,
  output hi_write,
  output jr,
  output srca_c,
  output mult_sign,
  output div_sign
);

reg [26:0] temp;
assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, alu_op, zero_sign, mem_data_size, lo_src, hi_src, lo_write, hi_write, jr, srca_c, mult_sign, div_sign} = temp;
always @(*) begin
  case (op)
    6'b000000: begin
      temp = 27'b1_01_00_0_0_000_0_10_01_10_00_00_0_0_0_0_0_0; 
      if(funct == 6'b101010)
        temp[19:17] = 3'b111;
      if(funct == 6'b101011)
        temp[19:17] = 3'b101;
      if(funct == 6'b000000 || funct == 6'b000010 || funct == 6'b000011)
        temp[2]=1;
      if(funct == 6'b010000)
        temp[19:17]=3'b010;
      if(funct == 6'b010001)begin
        temp[4]=1;
        temp[26]=1;
      end
      if(funct == 6'b010010)
        temp[19:17]=3'b011;
      if(funct == 6'b010011) begin
        temp[5]=1;
        temp[9:8]=2'b00;
        temp[26]=0;
      end
      if(funct == 6'b001000) begin
        temp[3]=1;
        temp[26]=0;
      end
      if(funct == 6'b001001) begin
        temp[3]=1;
        temp[19:17]=3'b100;
        temp[25:24]=2'b10;
      end
      if(funct == 6'b011000) begin
        temp[1]=1;
        temp[5:4]=2'b11;
        temp[7:6]=2'b01;
        temp[9:8]=2'b01;
        temp[26]=0;
      end
      if(funct == 6'b011001) begin
        temp[5:4]=2'b11;
        temp[7:6]=2'b01;
        temp[9:8]=2'b01;
        temp[26]=0;
      end
      if(funct == 6'b011010) begin
        temp[0]=1;
        temp[5:4]=2'b11;
        temp[7:6]=2'b10;
        temp[9:8]=2'b10;
        temp[26]=0;
      end
      if(funct == 6'b011011) begin
        temp[5:4]=2'b11;
        temp[7:6]=2'b10;
        temp[9:8]=2'b10;
        temp[26]=0;
      end  
    end
    6'b000001: temp = 27'b0_00_10_1_0_000_0_01_01_10_00_00_0_0_0_0_0_0;
    6'b000010: temp = 27'b0_00_10_0_0_000_1_00_01_10_00_00_0_0_0_0_0_0;
    6'b000011: temp = 27'b1_10_00_0_0_100_1_00_01_10_00_00_0_0_0_0_0_0;
    6'b000100: temp = 27'b0_00_00_1_0_000_0_01_01_10_00_00_0_0_0_0_0_0;
    6'b000101: temp = 27'b0_00_00_1_0_000_0_01_01_10_00_00_0_0_0_0_0_0;
    6'b000110: temp = 27'b0_00_10_1_0_000_0_01_01_10_00_00_0_0_0_0_0_0;
    6'b000111: temp = 27'b0_00_10_1_0_000_0_01_01_10_00_00_0_0_0_0_0_0;

    6'b001000: temp = 27'b1_00_01_0_0_000_0_11_01_10_00_00_0_0_0_0_0_0;

    6'b001001: temp = 27'b1_00_01_0_0_000_0_00_01_10_00_00_0_0_0_0_0_0;
    6'b001010: temp = 27'b1_00_01_0_0_111_0_01_01_10_00_00_0_0_0_0_0_0;
    6'b001011: temp = 27'b1_00_01_0_0_101_0_01_01_10_00_00_0_0_0_0_0_0;

    6'b001100: temp = 27'b1_00_01_0_0_000_0_11_00_10_00_00_0_0_0_0_0_0;
    6'b001101: temp = 27'b1_00_01_0_0_000_0_11_00_10_00_00_0_0_0_0_0_0;
    6'b001110: temp = 27'b1_00_01_0_0_000_0_11_00_10_00_00_0_0_0_0_0_0;

    6'b001111: temp = 27'b1_00_00_0_0_110_0_00_10_10_00_00_0_0_0_0_0_0;

    6'b100000: temp = 27'b1_00_01_0_0_001_0_00_01_00_00_00_0_0_0_0_0_0;
    6'b100001: temp = 27'b1_00_01_0_0_001_0_00_01_01_00_00_0_0_0_0_0_0;
    6'b100011: temp = 27'b1_00_01_0_0_001_0_00_01_10_00_00_0_0_0_0_0_0;

    6'b101000: temp = 27'b0_00_01_0_1_000_0_00_01_00_00_00_0_0_0_0_0_0;
    6'b101001: temp = 27'b0_00_01_0_1_000_0_00_01_01_00_00_0_0_0_0_0_0;
    6'b101011: temp = 27'b0_00_01_0_1_000_0_00_01_10_00_00_0_0_0_0_0_0;
    6'b011100: temp = 27'b1_01_00_0_0_000_0_10_01_10_00_00_0_0_0_0_0_0;

    default: temp = 27'b0_00_00_0_0_000_0_00_00_10_00_00_0_0_0_0_0_0;
  endcase
end
endmodule

// 3.3 Control Unit
module controller(
  input [5:0] op,funct,
  input rt0,
  input zero,
  input gt,
  input lt,
  input lt_sign,
  output [2:0] memtoreg,
  output mem_write,
  output pcsrc,
  output [1:0] regdst,alusrc,
  output regwrite,
  output jump,
  output [4:0] alucontrol,
  output [1:0] zero_sign,
  output [1:0] mem_data_size,
  output [1:0] lo_src,
  output [1:0] hi_src,
  output lo_write,
  output hi_write,
  output jr,
  output srca_c,
  output mult_sign,
  output div_sign
);

wire [1:0] alu_op;
wire branch;

maindec m(op,funct, memtoreg, mem_write, alusrc, regdst, regwrite, branch, jump, alu_op, zero_sign, mem_data_size, lo_src, hi_src, lo_write, hi_write, jr, srca_c, mult_sign, div_sign);
aludec a(alu_op, op, funct, alucontrol);

assign pcsrc = (branch && zero && (op[2:0]==3'b100))||(branch && ~zero && (op[2:0]==3'b101))||(branch && (op[2:0]==3'b001) && ~rt0 && lt && lt_sign) || (branch && (op[2:0]==3'b001) && ~rt0 && gt && ~lt_sign) || (branch && (op[2:0]==3'b001) && rt0 && lt && lt_sign) || (branch && (op[2:0]==3'b001) && rt0 && gt && ~lt_sign);

endmodule

// 3.5 Top Module
module mips(
    input clk,
    input rst,
    input [31:0] instr,
    input [31:0] read_mem_data,
    output [31:0] pc,
    output [31:0] data_mem_addr,
    output mem_write,
    output [31:0] write_mem_data,
    output [1:0] mem_data_size
);

wire [2:0] memtoreg;
wire pcsrc;
wire [1:0] alusrc, regdst;
wire regwrite;
wire jump;
wire [4:0] alucontrol;
wire [5:0] op = instr[31:26];
wire [5:0] funct = instr[5:0];
wire zeroflag, gt, lt, lt_sign, rt0;
wire [1:0] zero_sign;
wire [1:0] lo_src, hi_src;
wire lo_write, hi_write;
wire jr, srca_c, mult_sign, div_sign;

controller cont_obj(op, funct, rt0, zeroflag, gt, lt, lt_sign, 
                   memtoreg, mem_write, pcsrc, regdst, alusrc, 
                   regwrite, jump, alucontrol, zero_sign, mem_data_size,
                   lo_src, hi_src, lo_write, hi_write, jr, srca_c, 
                   mult_sign, div_sign);

datapath data_obj(
    clk, rst, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, 
    alucontrol, read_mem_data, instr, zero_sign, lo_src, hi_src, 
    lo_write, hi_write, jr, srca_c, mult_sign, div_sign,
    pc, data_mem_addr, mem_write, write_mem_data, zeroflag, 
    op, funct, rt0, gt, lt, lt_sign
);

endmodule

module top_module(
    input clk,
    input rst,
    output [7:0] leds
);
    wire [31:0] data_bus;    // Internal signals
    wire [31:0] address_bus;
    wire write_enable;

    assign leds = {write_enable, address_bus[2:0], data_bus[3:0]};

wire [31:0] instr, pc, data_mem_to_cpu;
wire [1:0] mem_data_size;

instruct_mem inst_obj(pc, instr);
ram ram_obj(clk, rst, address_bus, data_bus, write_enable, mem_data_size, data_mem_to_cpu);

mips mips_obj(
    clk, rst, instr, data_mem_to_cpu, 
    pc, address_bus, write_enable, data_bus, 
    mem_data_size
);

endmodule