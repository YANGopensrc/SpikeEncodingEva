//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================

module guiss_differ(
  input        nice_clk,
  input        nice_rst_n,
  input [9:0]  rows,
  input [9:0]  cols, 
  input [7:0]  g1,
  input [7:0]  g2,
  input [7:0]  g3,
  input [7:0]  s1,
  input [7:0]  s2,
  input [7:0]  s3,
  input [9:0]  image_data_guiss_lenth,
  input        spike_encode_state,
  input        ttfs_mode_en,
  input [7:0]  image_rdata_ch_0,   //connect to image_rdata[0]
  input [7:0]  image_rdata_ch_1,   //connect to image_rdata[1]
  input [7:0]  image_rdata_ch_2,   //connect to image_rdata[2]
  input [7:0]  image_rdata_ch_3,   //connect to image_rdata[3]

  output     [9:0]  per_ram_image_data_guiss_lenth,
  output     [9:0]  guiss_rd_adddr,
  output            guiss_differ_ren0,
  output            guiss_differ_ren1,
  output            guiss_differ_ren2,
  output            guiss_differ_ren3,
  output     [31:0] guiss_res,
  output reg        guiss_op_finish,
  output reg        guiss_window_done_d3,
  output reg [31:0] guiss_op_cnt
);

wire [9:0] guiss_cols,guiss_rows;
wire guiss_window_done;
wire [31:0] win_start_addr;
wire [31:0] G1,G2,G3;
wire [10:0] double_rows;

reg [3:0]  guiss_win_cnt,guiss_win_cnt_d;
reg        guiss_window_done_d,guiss_window_done_d1,guiss_window_done_d2;
reg [9:0]  cnt_i,cnt_j;
reg [31:0] guiss_win_rd_addr;
reg        guiss_differ_ren0_d,guiss_differ_ren1_d,guiss_differ_ren2_d,guiss_differ_ren3_d;
reg [7:0]  guiss_rdata;
reg [7:0]  win_data_0,win_data_1,win_data_2;
reg [7:0]  win_data_3,win_data_4,win_data_5;
reg [7:0]  win_data_6,win_data_7,win_data_8;
reg [9:0]  sum1,sum2,sum3;
reg [31:0] mult_g1,mult_g2,mult_g3;
//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//




endmodule
