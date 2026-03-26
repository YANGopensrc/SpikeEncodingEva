//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================


module isi_spike_encoder(
  input            nice_clk,
  input            nice_rst_n,
  input            isi_mode_en,
  input [9:0]      Tmax,
  input            spike_encode_state,
  input [10:0]     time_step_cnt_d_ch_0,
  input [10:0]     time_step_cnt_d_ch_1,
  input [10:0]     time_step_cnt_d_ch_2,
  input [10:0]     time_step_cnt_d_ch_3,
  input            load_val_done,
  input [9:0]      spike_gen_ram_rdata_ch_0,      //connect to spike_gen_ram_rdata[0]    
  input [9:0]      spike_gen_ram_rdata_ch_1,      //connect to spike_gen_ram_rdata[1]      
  input [9:0]      spike_gen_ram_rdata_ch_2,      //connect to spike_gen_ram_rdata[2]  
  input [9:0]      spike_gen_ram_rdata_ch_3,      //connect to spike_gen_ram_rdata[3]   
  input [31:0]     per_ram_data_lenth,
  input            isi_ttfs_ram0_ren_d,
  input            isi_ttfs_ram1_ren_d,
  input            isi_ttfs_ram2_ren_d,
  input            isi_ttfs_ram3_ren_d,
  input [9:0]      spike_gen_rdata_cnt_ch_0,
  input [9:0]      spike_gen_rdata_cnt_ch_1,
  input [9:0]      spike_gen_rdata_cnt_ch_2,
  input [9:0]      spike_gen_rdata_cnt_ch_3,
  input [31:0]     spike_gen_rdata_cnt_d_ch_0,
  input [31:0]     spike_gen_rdata_cnt_d_ch_1,
  input [31:0]     spike_gen_rdata_cnt_d_ch_2,
  input [31:0]     spike_gen_rdata_cnt_d_ch_3,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_0,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_1,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_2,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_3,
  output reg [3:0] isi_spike,
  output           isi_spike_encode_finish
);

wire [3:0]  time_step_rdata_done;
wire [9:0]  spike_gen_ram_rdata [3:0];
wire [10:0] time_step_cnt_d [3:0];
wire [11:0] spike_gen_rdata_cnt [3:0];
wire [31:0] spike_gen_rdata_cnt_d [3:0];
wire [3:0]  isi_ttfs_ram_ren_d;
wire [7:0]  isi_ttfs_spike_image_rdata [3:0];


reg          load_val_done_d;
reg [10:0]   isi_cnt [3:0];
//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//



endmodule
