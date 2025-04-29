`timescale 1ns / 1ps

module top_module_tb;

  reg clk;
  reg rst;
  reg [31:0] instr;
  reg [31:0] reg_file_from_mem;
  reg [2:0] memtoreg;
  reg pcsrc;
  reg [1:0] alusrc;
  reg [1:0] regdst;
  reg regwrite;
  reg jump;
  reg [4:0] alucontrol;
  reg [1:0] zero_sign;
  reg [1:0] lo_src;
  reg [1:0] hi_src;
  reg lo_write;
  reg hi_write;
  reg jr;
  reg srca_c;
  reg mult_sign;
  reg div_sign;

  wire [31:0] pc_val;
  wire [31:0] alu_result;
  wire [31:0] mem_write_data;
  wire zero_flag;
  wire [5:0] funct;
  wire [5:0] op_code;
  wire rt0;
  wire gt;
  wire lt;
  wire lt_sign;
  wire overflow;

  datapath uut (
    .clk(clk),
    .rst(rst),
    .memtoreg(memtoreg),
    .pcsrc(pcsrc),
    .alusrc(alusrc),
    .regdst(regdst),
    .regwrite(regwrite),
    .jump(jump),
    .alucontrol(alucontrol),
    .reg_file_from_mem(reg_file_from_mem),
    .instr(instr),
    .zero_sign(zero_sign),
    .lo_src(lo_src),
    .hi_src(hi_src),
    .lo_write(lo_write),
    .hi_write(hi_write),
    .jr(jr),
    .srca_c(srca_c),
    .mult_sign(mult_sign),
    .div_sign(div_sign),
    .pc_val(pc_val),
    .alu_result(alu_result),
    .mem_write_data(mem_write_data),
    .zero_flag(zero_flag),
    .funct(funct),
    .op_code(op_code),
    .rt0(rt0),
    .gt(gt),
    .lt(lt),
    .lt_sign(lt_sign),
    .overflow(overflow)
  );

  initial begin
    $display("Starting Simulation");
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    #10;
    rst = 0;

    // Example Test Case 1: ADD instruction
    instr = 32'b000000_00001_00010_00011_00000_100000; // add $3, $1, $2
    reg_file_from_mem = 0;
    memtoreg = 3'b000;
    pcsrc = 0;
    alusrc = 2'b00;
    regdst = 2'b01;
    regwrite = 1;
    jump = 0;
    alucontrol = 5'b00010;
    zero_sign = 2'b00;
    lo_src = 2'b00;
    hi_src = 2'b00;
    lo_write = 0;
    hi_write = 0;
    jr = 0;
    srca_c = 0;
    mult_sign = 0;
    div_sign = 0;

    #20;

    // Example Test Case 2: SUB instruction
    instr = 32'b000000_00001_00010_00100_00000_100010; // sub $4, $1, $2
    alucontrol = 5'b00101;

    #20;

    // Example Test Case 3: MUL instruction
    instr = 32'b000000_00001_00010_00101_00000_011000; // mult $1, $2 (lo and hi registers)
    lo_src = 2'b01;
    hi_src = 2'b01;
    lo_write = 1;
    hi_write = 1;
    alucontrol = 5'b00100;

    #20;

    $finish;
  end

endmodule