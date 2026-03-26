//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================


module ttfs_spike_encoder(
  input            image_input_type,
  input            ttfs_mode_en,
  input [9:0]      Tmax,
  input            isi_ttfs_ram0_ren_d,
  input            isi_ttfs_ram1_ren_d,
  input            isi_ttfs_ram2_ren_d,
  input            isi_ttfs_ram3_ren_d,
  input [31:0]     spike_gen_rdata_cnt_d_ch_0,
  input [31:0]     spike_gen_rdata_cnt_d_ch_1,
  input [31:0]     spike_gen_rdata_cnt_d_ch_2,
  input [31:0]     spike_gen_rdata_cnt_d_ch_3,
  input [31:0]     per_ram_data_lenth,
  input [9:0]      per_ram_image_data_guiss_lenth,
  input [9:0]      spike_gen_ram_rdata_ch_0,      //connect to spike_gen_ram_rdata[0]    
  input [9:0]      spike_gen_ram_rdata_ch_1,      //connect to spike_gen_ram_rdata[1]      
  input [9:0]      spike_gen_ram_rdata_ch_2,      //connect to spike_gen_ram_rdata[2]  
  input [9:0]      spike_gen_ram_rdata_ch_3,      //connect to spike_gen_ram_rdata[3]   
  input [10:0]     time_step_cnt_ch_0,
  input [10:0]     time_step_cnt_ch_1,
  input [10:0]     time_step_cnt_ch_2,
  input [10:0]     time_step_cnt_ch_3,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_0,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_1,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_2,
  input [7:0]      isi_ttfs_spike_image_rdata_ch_3,
  output reg [3:0] ttfs_spike,
  output           ttfs_spike_encode_finish
);


wire [9:0]  spike_gen_ram_rdata [3:0];
wire [3:0]  isi_ttfs_ram_ren_d;
wire [31:0] spike_gen_rdata_cnt_d [3:0];
wire [10:0] time_step_cnt [3:0];
wire [7:0]  isi_ttfs_spike_image_rdata [3:0];
wire        ttfs_spike_encode_finish_src;
wire        ttfs_spike_encode_finish_guiss;
//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//



endmodule


