module IDU(
  input  [31:0] io_inst,
  output [4:0]  io_rs1,
  output [4:0]  io_rs2,
  output [4:0]  io_rd
);
  assign io_rs1 = io_inst[19:15]; // @[IDU.scala 16:27]
  assign io_rs2 = io_inst[24:20]; // @[IDU.scala 17:27]
  assign io_rd = io_inst[11:7]; // @[IDU.scala 18:27]
endmodule
module ImmGen(
  input  [31:0] io_inst,
  output [63:0] io_immI,
  output [63:0] io_immS,
  output [63:0] io_immB,
  output [63:0] io_immU,
  output [63:0] io_immJ
);
  wire  io_immI_signBit = io_inst[31]; // @[BitUtils.scala 8:20]
  wire [51:0] _io_immI_T_2 = io_immI_signBit ? 52'hfffffffffffff : 52'h0; // @[Bitwise.scala 74:12]
  wire [31:0] _io_immU_T_1 = {io_inst[31:12],12'h0}; // @[Cat.scala 31:58]
  wire  io_immU_signBit = _io_immU_T_1[31]; // @[BitUtils.scala 8:20]
  wire [31:0] _io_immU_T_3 = io_immU_signBit ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [11:0] _io_immS_T_2 = {io_inst[31:25],io_inst[11:7]}; // @[Cat.scala 31:58]
  wire  io_immS_signBit = _io_immS_T_2[11]; // @[BitUtils.scala 8:20]
  wire [51:0] _io_immS_T_4 = io_immS_signBit ? 52'hfffffffffffff : 52'h0; // @[Bitwise.scala 74:12]
  wire [12:0] _io_immB_T_4 = {io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[Cat.scala 31:58]
  wire  io_immB_signBit = _io_immB_T_4[12]; // @[BitUtils.scala 8:20]
  wire [50:0] _io_immB_T_6 = io_immB_signBit ? 51'h7ffffffffffff : 51'h0; // @[Bitwise.scala 74:12]
  wire [20:0] _io_immJ_T_4 = {io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[Cat.scala 31:58]
  wire  io_immJ_signBit = _io_immJ_T_4[20]; // @[BitUtils.scala 8:20]
  wire [42:0] _io_immJ_T_6 = io_immJ_signBit ? 43'h7ffffffffff : 43'h0; // @[Bitwise.scala 74:12]
  assign io_immI = {_io_immI_T_2,io_inst[31:20]}; // @[Cat.scala 31:58]
  assign io_immS = {_io_immS_T_4,_io_immS_T_2}; // @[Cat.scala 31:58]
  assign io_immB = {_io_immB_T_6,_io_immB_T_4}; // @[Cat.scala 31:58]
  assign io_immU = {_io_immU_T_3,_io_immU_T_1}; // @[Cat.scala 31:58]
  assign io_immJ = {_io_immJ_T_6,_io_immJ_T_4}; // @[Cat.scala 31:58]
endmodule
module Control(
  input  [31:0] io_inst,
  output [2:0]  io_Imm_sel,
  output        io_B_sel,
  output [3:0]  io_alu_op,
  output        io_wen,
  output [1:0]  io_WB_sel
);
  wire [31:0] _ctrlsignals_T = io_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  ctrlsignals_2 = 32'h13 == _ctrlsignals_T; // @[Lookup.scala 31:38]
  assign io_Imm_sel = ctrlsignals_2 ? 3'h1 : 3'h0; // @[Lookup.scala 34:39]
  assign io_B_sel = 32'h13 == _ctrlsignals_T; // @[Lookup.scala 31:38]
  assign io_alu_op = ctrlsignals_2 ? 4'h0 : 4'hf; // @[Lookup.scala 34:39]
  assign io_wen = 32'h13 == _ctrlsignals_T; // @[Lookup.scala 31:38]
  assign io_WB_sel = ctrlsignals_2 ? 2'h1 : 2'h0; // @[Lookup.scala 34:39]
endmodule
module Alu(
  input  [3:0]  io_alu_op,
  input  [63:0] io_A,
  input  [63:0] io_B,
  output [63:0] io_out
);
  wire [63:0] _io_out_T_1 = io_A + io_B; // @[Alu.scala 28:24]
  wire [63:0] _io_out_T_3 = io_A - io_B; // @[Alu.scala 29:24]
  wire [63:0] _io_out_T_4 = io_A & io_B; // @[Alu.scala 30:24]
  wire [63:0] _io_out_T_5 = io_A | io_B; // @[Alu.scala 31:24]
  wire [63:0] _io_out_T_6 = io_A ^ io_B; // @[Alu.scala 32:24]
  wire [63:0] _io_out_T_8 = 4'h0 == io_alu_op ? _io_out_T_1 : io_B; // @[Mux.scala 81:58]
  wire [63:0] _io_out_T_10 = 4'h1 == io_alu_op ? _io_out_T_3 : _io_out_T_8; // @[Mux.scala 81:58]
  wire [63:0] _io_out_T_12 = 4'h3 == io_alu_op ? _io_out_T_4 : _io_out_T_10; // @[Mux.scala 81:58]
  wire [63:0] _io_out_T_14 = 4'h2 == io_alu_op ? _io_out_T_5 : _io_out_T_12; // @[Mux.scala 81:58]
  assign io_out = 4'h4 == io_alu_op ? _io_out_T_6 : _io_out_T_14; // @[Mux.scala 81:58]
endmodule
module RegisterFile(
  input         clock,
  input         reset,
  input         io_wen,
  input  [4:0]  io_rs1,
  input  [4:0]  io_rs2,
  input  [4:0]  io_dest,
  input  [63:0] io_wdata,
  output [63:0] io_rdata1,
  output [63:0] io_rdata2
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [63:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [63:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [63:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
  reg [63:0] _RAND_20;
  reg [63:0] _RAND_21;
  reg [63:0] _RAND_22;
  reg [63:0] _RAND_23;
  reg [63:0] _RAND_24;
  reg [63:0] _RAND_25;
  reg [63:0] _RAND_26;
  reg [63:0] _RAND_27;
  reg [63:0] _RAND_28;
  reg [63:0] _RAND_29;
  reg [63:0] _RAND_30;
  reg [63:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] regs_0; // @[Regs.scala 15:21]
  reg [63:0] regs_1; // @[Regs.scala 15:21]
  reg [63:0] regs_2; // @[Regs.scala 15:21]
  reg [63:0] regs_3; // @[Regs.scala 15:21]
  reg [63:0] regs_4; // @[Regs.scala 15:21]
  reg [63:0] regs_5; // @[Regs.scala 15:21]
  reg [63:0] regs_6; // @[Regs.scala 15:21]
  reg [63:0] regs_7; // @[Regs.scala 15:21]
  reg [63:0] regs_8; // @[Regs.scala 15:21]
  reg [63:0] regs_9; // @[Regs.scala 15:21]
  reg [63:0] regs_10; // @[Regs.scala 15:21]
  reg [63:0] regs_11; // @[Regs.scala 15:21]
  reg [63:0] regs_12; // @[Regs.scala 15:21]
  reg [63:0] regs_13; // @[Regs.scala 15:21]
  reg [63:0] regs_14; // @[Regs.scala 15:21]
  reg [63:0] regs_15; // @[Regs.scala 15:21]
  reg [63:0] regs_16; // @[Regs.scala 15:21]
  reg [63:0] regs_17; // @[Regs.scala 15:21]
  reg [63:0] regs_18; // @[Regs.scala 15:21]
  reg [63:0] regs_19; // @[Regs.scala 15:21]
  reg [63:0] regs_20; // @[Regs.scala 15:21]
  reg [63:0] regs_21; // @[Regs.scala 15:21]
  reg [63:0] regs_22; // @[Regs.scala 15:21]
  reg [63:0] regs_23; // @[Regs.scala 15:21]
  reg [63:0] regs_24; // @[Regs.scala 15:21]
  reg [63:0] regs_25; // @[Regs.scala 15:21]
  reg [63:0] regs_26; // @[Regs.scala 15:21]
  reg [63:0] regs_27; // @[Regs.scala 15:21]
  reg [63:0] regs_28; // @[Regs.scala 15:21]
  reg [63:0] regs_29; // @[Regs.scala 15:21]
  reg [63:0] regs_30; // @[Regs.scala 15:21]
  reg [63:0] regs_31; // @[Regs.scala 15:21]
  wire [63:0] _GEN_1 = 5'h1 == io_rs1 ? regs_1 : regs_0; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_2 = 5'h2 == io_rs1 ? regs_2 : _GEN_1; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_3 = 5'h3 == io_rs1 ? regs_3 : _GEN_2; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_4 = 5'h4 == io_rs1 ? regs_4 : _GEN_3; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_5 = 5'h5 == io_rs1 ? regs_5 : _GEN_4; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_6 = 5'h6 == io_rs1 ? regs_6 : _GEN_5; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_7 = 5'h7 == io_rs1 ? regs_7 : _GEN_6; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_8 = 5'h8 == io_rs1 ? regs_8 : _GEN_7; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_9 = 5'h9 == io_rs1 ? regs_9 : _GEN_8; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_10 = 5'ha == io_rs1 ? regs_10 : _GEN_9; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_11 = 5'hb == io_rs1 ? regs_11 : _GEN_10; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_12 = 5'hc == io_rs1 ? regs_12 : _GEN_11; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_13 = 5'hd == io_rs1 ? regs_13 : _GEN_12; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_14 = 5'he == io_rs1 ? regs_14 : _GEN_13; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_15 = 5'hf == io_rs1 ? regs_15 : _GEN_14; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_16 = 5'h10 == io_rs1 ? regs_16 : _GEN_15; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_17 = 5'h11 == io_rs1 ? regs_17 : _GEN_16; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_18 = 5'h12 == io_rs1 ? regs_18 : _GEN_17; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_19 = 5'h13 == io_rs1 ? regs_19 : _GEN_18; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_20 = 5'h14 == io_rs1 ? regs_20 : _GEN_19; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_21 = 5'h15 == io_rs1 ? regs_21 : _GEN_20; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_22 = 5'h16 == io_rs1 ? regs_22 : _GEN_21; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_23 = 5'h17 == io_rs1 ? regs_23 : _GEN_22; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_24 = 5'h18 == io_rs1 ? regs_24 : _GEN_23; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_25 = 5'h19 == io_rs1 ? regs_25 : _GEN_24; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_26 = 5'h1a == io_rs1 ? regs_26 : _GEN_25; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_27 = 5'h1b == io_rs1 ? regs_27 : _GEN_26; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_28 = 5'h1c == io_rs1 ? regs_28 : _GEN_27; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_29 = 5'h1d == io_rs1 ? regs_29 : _GEN_28; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_30 = 5'h1e == io_rs1 ? regs_30 : _GEN_29; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_31 = 5'h1f == io_rs1 ? regs_31 : _GEN_30; // @[Regs.scala 17:{19,19}]
  wire [63:0] _GEN_33 = 5'h1 == io_rs2 ? regs_1 : regs_0; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_34 = 5'h2 == io_rs2 ? regs_2 : _GEN_33; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_35 = 5'h3 == io_rs2 ? regs_3 : _GEN_34; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_36 = 5'h4 == io_rs2 ? regs_4 : _GEN_35; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_37 = 5'h5 == io_rs2 ? regs_5 : _GEN_36; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_38 = 5'h6 == io_rs2 ? regs_6 : _GEN_37; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_39 = 5'h7 == io_rs2 ? regs_7 : _GEN_38; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_40 = 5'h8 == io_rs2 ? regs_8 : _GEN_39; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_41 = 5'h9 == io_rs2 ? regs_9 : _GEN_40; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_42 = 5'ha == io_rs2 ? regs_10 : _GEN_41; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_43 = 5'hb == io_rs2 ? regs_11 : _GEN_42; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_44 = 5'hc == io_rs2 ? regs_12 : _GEN_43; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_45 = 5'hd == io_rs2 ? regs_13 : _GEN_44; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_46 = 5'he == io_rs2 ? regs_14 : _GEN_45; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_47 = 5'hf == io_rs2 ? regs_15 : _GEN_46; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_48 = 5'h10 == io_rs2 ? regs_16 : _GEN_47; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_49 = 5'h11 == io_rs2 ? regs_17 : _GEN_48; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_50 = 5'h12 == io_rs2 ? regs_18 : _GEN_49; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_51 = 5'h13 == io_rs2 ? regs_19 : _GEN_50; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_52 = 5'h14 == io_rs2 ? regs_20 : _GEN_51; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_53 = 5'h15 == io_rs2 ? regs_21 : _GEN_52; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_54 = 5'h16 == io_rs2 ? regs_22 : _GEN_53; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_55 = 5'h17 == io_rs2 ? regs_23 : _GEN_54; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_56 = 5'h18 == io_rs2 ? regs_24 : _GEN_55; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_57 = 5'h19 == io_rs2 ? regs_25 : _GEN_56; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_58 = 5'h1a == io_rs2 ? regs_26 : _GEN_57; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_59 = 5'h1b == io_rs2 ? regs_27 : _GEN_58; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_60 = 5'h1c == io_rs2 ? regs_28 : _GEN_59; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_61 = 5'h1d == io_rs2 ? regs_29 : _GEN_60; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_62 = 5'h1e == io_rs2 ? regs_30 : _GEN_61; // @[Regs.scala 18:{19,19}]
  wire [63:0] _GEN_63 = 5'h1f == io_rs2 ? regs_31 : _GEN_62; // @[Regs.scala 18:{19,19}]
  assign io_rdata1 = |io_rs1 ? _GEN_31 : 64'h0; // @[Regs.scala 17:19]
  assign io_rdata2 = |io_rs2 ? _GEN_63 : 64'h0; // @[Regs.scala 18:19]
  always @(posedge clock) begin
    if (reset) begin // @[Regs.scala 15:21]
      regs_0 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h0 == io_dest) begin // @[Regs.scala 20:19]
        regs_0 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_1 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1 == io_dest) begin // @[Regs.scala 20:19]
        regs_1 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_2 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h2 == io_dest) begin // @[Regs.scala 20:19]
        regs_2 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_3 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h3 == io_dest) begin // @[Regs.scala 20:19]
        regs_3 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_4 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h4 == io_dest) begin // @[Regs.scala 20:19]
        regs_4 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_5 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h5 == io_dest) begin // @[Regs.scala 20:19]
        regs_5 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_6 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h6 == io_dest) begin // @[Regs.scala 20:19]
        regs_6 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_7 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h7 == io_dest) begin // @[Regs.scala 20:19]
        regs_7 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_8 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h8 == io_dest) begin // @[Regs.scala 20:19]
        regs_8 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_9 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h9 == io_dest) begin // @[Regs.scala 20:19]
        regs_9 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_10 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'ha == io_dest) begin // @[Regs.scala 20:19]
        regs_10 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_11 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'hb == io_dest) begin // @[Regs.scala 20:19]
        regs_11 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_12 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'hc == io_dest) begin // @[Regs.scala 20:19]
        regs_12 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_13 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'hd == io_dest) begin // @[Regs.scala 20:19]
        regs_13 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_14 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'he == io_dest) begin // @[Regs.scala 20:19]
        regs_14 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_15 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'hf == io_dest) begin // @[Regs.scala 20:19]
        regs_15 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_16 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h10 == io_dest) begin // @[Regs.scala 20:19]
        regs_16 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_17 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h11 == io_dest) begin // @[Regs.scala 20:19]
        regs_17 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_18 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h12 == io_dest) begin // @[Regs.scala 20:19]
        regs_18 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_19 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h13 == io_dest) begin // @[Regs.scala 20:19]
        regs_19 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_20 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h14 == io_dest) begin // @[Regs.scala 20:19]
        regs_20 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_21 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h15 == io_dest) begin // @[Regs.scala 20:19]
        regs_21 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_22 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h16 == io_dest) begin // @[Regs.scala 20:19]
        regs_22 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_23 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h17 == io_dest) begin // @[Regs.scala 20:19]
        regs_23 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_24 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h18 == io_dest) begin // @[Regs.scala 20:19]
        regs_24 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_25 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h19 == io_dest) begin // @[Regs.scala 20:19]
        regs_25 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_26 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1a == io_dest) begin // @[Regs.scala 20:19]
        regs_26 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_27 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1b == io_dest) begin // @[Regs.scala 20:19]
        regs_27 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_28 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1c == io_dest) begin // @[Regs.scala 20:19]
        regs_28 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_29 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1d == io_dest) begin // @[Regs.scala 20:19]
        regs_29 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_30 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1e == io_dest) begin // @[Regs.scala 20:19]
        regs_30 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
    if (reset) begin // @[Regs.scala 15:21]
      regs_31 <= 64'h0; // @[Regs.scala 15:21]
    end else if (io_wen & |io_dest) begin // @[Regs.scala 19:31]
      if (5'h1f == io_dest) begin // @[Regs.scala 20:19]
        regs_31 <= io_wdata; // @[Regs.scala 20:19]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  regs_0 = _RAND_0[63:0];
  _RAND_1 = {2{`RANDOM}};
  regs_1 = _RAND_1[63:0];
  _RAND_2 = {2{`RANDOM}};
  regs_2 = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  regs_3 = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  regs_4 = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  regs_5 = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  regs_6 = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  regs_7 = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  regs_8 = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  regs_9 = _RAND_9[63:0];
  _RAND_10 = {2{`RANDOM}};
  regs_10 = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  regs_11 = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  regs_12 = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  regs_13 = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  regs_14 = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  regs_15 = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  regs_16 = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  regs_17 = _RAND_17[63:0];
  _RAND_18 = {2{`RANDOM}};
  regs_18 = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  regs_19 = _RAND_19[63:0];
  _RAND_20 = {2{`RANDOM}};
  regs_20 = _RAND_20[63:0];
  _RAND_21 = {2{`RANDOM}};
  regs_21 = _RAND_21[63:0];
  _RAND_22 = {2{`RANDOM}};
  regs_22 = _RAND_22[63:0];
  _RAND_23 = {2{`RANDOM}};
  regs_23 = _RAND_23[63:0];
  _RAND_24 = {2{`RANDOM}};
  regs_24 = _RAND_24[63:0];
  _RAND_25 = {2{`RANDOM}};
  regs_25 = _RAND_25[63:0];
  _RAND_26 = {2{`RANDOM}};
  regs_26 = _RAND_26[63:0];
  _RAND_27 = {2{`RANDOM}};
  regs_27 = _RAND_27[63:0];
  _RAND_28 = {2{`RANDOM}};
  regs_28 = _RAND_28[63:0];
  _RAND_29 = {2{`RANDOM}};
  regs_29 = _RAND_29[63:0];
  _RAND_30 = {2{`RANDOM}};
  regs_30 = _RAND_30[63:0];
  _RAND_31 = {2{`RANDOM}};
  regs_31 = _RAND_31[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module top(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  input  [63:0] io_rdata,
  output        io_wen,
  output        io_ren,
  output [63:0] io_addr,
  output [63:0] io_wdata,
  output [63:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire [31:0] idu_io_inst; // @[top.scala 23:19]
  wire [4:0] idu_io_rs1; // @[top.scala 23:19]
  wire [4:0] idu_io_rs2; // @[top.scala 23:19]
  wire [4:0] idu_io_rd; // @[top.scala 23:19]
  wire [31:0] immgen_io_inst; // @[top.scala 25:22]
  wire [63:0] immgen_io_immI; // @[top.scala 25:22]
  wire [63:0] immgen_io_immS; // @[top.scala 25:22]
  wire [63:0] immgen_io_immB; // @[top.scala 25:22]
  wire [63:0] immgen_io_immU; // @[top.scala 25:22]
  wire [63:0] immgen_io_immJ; // @[top.scala 25:22]
  wire [31:0] ctrl_io_inst; // @[top.scala 26:20]
  wire [2:0] ctrl_io_Imm_sel; // @[top.scala 26:20]
  wire  ctrl_io_B_sel; // @[top.scala 26:20]
  wire [3:0] ctrl_io_alu_op; // @[top.scala 26:20]
  wire  ctrl_io_wen; // @[top.scala 26:20]
  wire [1:0] ctrl_io_WB_sel; // @[top.scala 26:20]
  wire [3:0] alu_io_alu_op; // @[top.scala 28:19]
  wire [63:0] alu_io_A; // @[top.scala 28:19]
  wire [63:0] alu_io_B; // @[top.scala 28:19]
  wire [63:0] alu_io_out; // @[top.scala 28:19]
  wire  rf_clock; // @[top.scala 29:18]
  wire  rf_reset; // @[top.scala 29:18]
  wire  rf_io_wen; // @[top.scala 29:18]
  wire [4:0] rf_io_rs1; // @[top.scala 29:18]
  wire [4:0] rf_io_rs2; // @[top.scala 29:18]
  wire [4:0] rf_io_dest; // @[top.scala 29:18]
  wire [63:0] rf_io_wdata; // @[top.scala 29:18]
  wire [63:0] rf_io_rdata1; // @[top.scala 29:18]
  wire [63:0] rf_io_rdata2; // @[top.scala 29:18]
  reg [63:0] pc; // @[top.scala 36:19]
  wire [63:0] pc4 = pc + 64'h4; // @[top.scala 39:16]
  wire [63:0] _imm_T_1 = immgen_io_immI; // @[Mux.scala 81:58]
  wire [63:0] _imm_T_3 = 3'h2 == ctrl_io_Imm_sel ? immgen_io_immS : _imm_T_1; // @[Mux.scala 81:58]
  wire [63:0] _imm_T_5 = 3'h3 == ctrl_io_Imm_sel ? immgen_io_immB : _imm_T_3; // @[Mux.scala 81:58]
  wire [63:0] _imm_T_7 = 3'h4 == ctrl_io_Imm_sel ? immgen_io_immU : _imm_T_5; // @[Mux.scala 81:58]
  wire [63:0] imm = 3'h5 == ctrl_io_Imm_sel ? immgen_io_immJ : _imm_T_7; // @[Mux.scala 81:58]
  IDU idu ( // @[top.scala 23:19]
    .io_inst(idu_io_inst),
    .io_rs1(idu_io_rs1),
    .io_rs2(idu_io_rs2),
    .io_rd(idu_io_rd)
  );
  ImmGen immgen ( // @[top.scala 25:22]
    .io_inst(immgen_io_inst),
    .io_immI(immgen_io_immI),
    .io_immS(immgen_io_immS),
    .io_immB(immgen_io_immB),
    .io_immU(immgen_io_immU),
    .io_immJ(immgen_io_immJ)
  );
  Control ctrl ( // @[top.scala 26:20]
    .io_inst(ctrl_io_inst),
    .io_Imm_sel(ctrl_io_Imm_sel),
    .io_B_sel(ctrl_io_B_sel),
    .io_alu_op(ctrl_io_alu_op),
    .io_wen(ctrl_io_wen),
    .io_WB_sel(ctrl_io_WB_sel)
  );
  Alu alu ( // @[top.scala 28:19]
    .io_alu_op(alu_io_alu_op),
    .io_A(alu_io_A),
    .io_B(alu_io_B),
    .io_out(alu_io_out)
  );
  RegisterFile rf ( // @[top.scala 29:18]
    .clock(rf_clock),
    .reset(rf_reset),
    .io_wen(rf_io_wen),
    .io_rs1(rf_io_rs1),
    .io_rs2(rf_io_rs2),
    .io_dest(rf_io_dest),
    .io_wdata(rf_io_wdata),
    .io_rdata1(rf_io_rdata1),
    .io_rdata2(rf_io_rdata2)
  );
  assign io_wen = 1'h0; // @[top.scala 63:10]
  assign io_ren = 1'h0; // @[top.scala 64:10]
  assign io_addr = alu_io_out; // @[top.scala 65:11]
  assign io_wdata = rf_io_rdata2; // @[top.scala 66:12]
  assign io_pc = pc; // @[top.scala 37:9]
  assign idu_io_inst = io_inst; // @[top.scala 38:15]
  assign immgen_io_inst = io_inst; // @[top.scala 41:18]
  assign ctrl_io_inst = io_inst; // @[top.scala 40:16]
  assign alu_io_alu_op = ctrl_io_alu_op; // @[top.scala 60:17]
  assign alu_io_A = rf_io_rdata1; // @[top.scala 61:18]
  assign alu_io_B = ~ctrl_io_B_sel ? {{59'd0}, rf_io_rs2} : imm; // @[top.scala 62:18]
  assign rf_clock = clock;
  assign rf_reset = reset;
  assign rf_io_wen = ctrl_io_wen; // @[top.scala 71:13]
  assign rf_io_rs1 = idu_io_rs1; // @[top.scala 43:13]
  assign rf_io_rs2 = idu_io_rs2; // @[top.scala 44:13]
  assign rf_io_dest = idu_io_rd; // @[top.scala 72:14]
  assign rf_io_wdata = ctrl_io_WB_sel == 2'h1 ? alu_io_out : io_rdata; // @[top.scala 73:21]
  always @(posedge clock) begin
    if (reset) begin // @[top.scala 36:19]
      pc <= 64'h80000000; // @[top.scala 36:19]
    end else begin
      pc <= pc4; // @[top.scala 59:6]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  pc = _RAND_0[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
