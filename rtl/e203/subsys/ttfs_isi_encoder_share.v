//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================


module ttfs_isi_encoder_share(
  input             nice_clk,
  input             nice_rst_n,
  input             ttfs_mode_en,
  input             isi_mode_en,
  input             spike_encode_state,
  input [9:0]       image_input_type,
  input [9:0]       Tmax,
  input [9:0]       Tmin,
  input [7:0]       guiss_res,
  input [7:0]       image_rdata_ch_0,             //connect to image_rdata[0]
  input [7:0]       image_rdata_ch_1,             //connect to image_rdata[1]
  input [7:0]       image_rdata_ch_2,             //connect to image_rdata[2]
  input [7:0]       image_rdata_ch_3,             //connect to image_rdata[3]
  input [31:0]      spike_gen_ram_waddr,
  input [31:0]      per_ram_data_lenth,
  input [9:0]       per_ram_image_data_guiss_lenth,
  input             ram_ttfs_ren,
  input             spike_gen_ram0_ren,
  input             spike_gen_ram1_ren,
  input             spike_gen_ram2_ren,
  input             spike_gen_ram3_ren,
  input [9:0]       spike_gen_ram_rdata_ch_0,      //connect to spike_gen_ram_rdata[0]    
  input [9:0]       spike_gen_ram_rdata_ch_1,      //connect to spike_gen_ram_rdata[1]      
  input [9:0]       spike_gen_ram_rdata_ch_2,      //connect to spike_gen_ram_rdata[2]  
  input [9:0]       spike_gen_ram_rdata_ch_3,      //connect to spike_gen_ram_rdata[3]  
  output reg [9:0]  tmp_ch_0,                      //connect to tmp[0]
  output reg [9:0]  tmp_ch_1,                      //connect to tmp[1]
  output reg [9:0]  tmp_ch_2,                      //connect to tmp[2]
  output reg [9:0]  tmp_ch_3,                      //connect to tmp[3]
  output            load_val_done,
  output  [31:0]    spike_gen_rdata_cnt_ch_0,
  output  [31:0]    spike_gen_rdata_cnt_ch_1,
  output  [31:0]    spike_gen_rdata_cnt_ch_2,
  output  [31:0]    spike_gen_rdata_cnt_ch_3,
  output  [31:0]    spike_gen_rdata_cnt_d_ch_0,
  output  [31:0]    spike_gen_rdata_cnt_d_ch_1,
  output  [31:0]    spike_gen_rdata_cnt_d_ch_2,
  output  [31:0]    spike_gen_rdata_cnt_d_ch_3,
  output  [10:0]    time_step_cnt_ch_0,
  output  [10:0]    time_step_cnt_ch_1,
  output  [10:0]    time_step_cnt_ch_2,
  output  [10:0]    time_step_cnt_ch_3,
  output  [10:0]    time_step_cnt_d_ch_0,
  output  [10:0]    time_step_cnt_d_ch_1,
  output  [10:0]    time_step_cnt_d_ch_2,
  output  [10:0]    time_step_cnt_d_ch_3
);

//**************variable definition*****************************//
//ttfs_guiss_differ
wire [9:0]  ina_ttfs_guiss;
wire [9:0]  inb_ttfs_guiss [3:0];
wire [9:0]  inc_ttfs_guiss [3:0];
//ttfs_source
wire [9:0]  ina_ttfs_source;
wire [9:0]  inb_ttfs_source [3:0];
wire [9:0]  inc_ttfs_source [3:0];
//isi
wire [9:0]  ina_isi;
wire [9:0]  inb_isi [3:0];
wire [9:0]  inc_isi [3:0];

wire [9:0]  out_tmp [3:0];
wire [9:0]  out_tmp_guiss_differ;
wire        cal_isi_interval_val_en;
wire [9:0]  isi_tmp [3:0];
wire [9:0]  ttfs_source_tmp [3:0];
wire [9:0]  ttfs_guiss_tmp [3:0];
wire [31:0] spike_gen_rdata_cnt_d [3:0];
wire        ttfs_guiss_en;
wire        ttfs_source_en;
wire [2:0]  submulshift_input_sel;
wire [9:0]  spike_gen_ram_rdata_ch [3:0];
wire [9:0]  ttfs_spike_gen_ram_rdata_ch [3:0];
wire [3:0]  spike_gen_ram_ren;

reg [9:0]   ina;
reg [9:0]   inb [3:0];
reg [9:0]   inc [3:0];
reg [10:0]  time_step_cnt [3:0];
reg [10:0]  time_step_cnt_d [3:0];
reg [31:0]  spike_gen_rdata_cnt [3:0];
//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//



endmodule
