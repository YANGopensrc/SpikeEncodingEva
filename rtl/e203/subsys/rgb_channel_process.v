//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================


module rgb_channel_process(
  input            nice_clk,
  input            nice_rst_n,
  input [31:0]     image_data_lenth,
  input [9:0]      image_data_guiss_lenth,
  input            load_img_state,
  input            spike_encode_state,
  input [31:0]     image_data_load_cnt,
  input [7:0]      data_in,            //connect to data_in[7:0]
  input            data_in_valid,      //connect to data_in_valid
  input            poiss_mode_en,
  input            ttfs_mode_en,
  input            isi_mode_en,
  input            spike_code_en,
  input            spike_encoder_cfgdone,
  input [9:0]      image_input_type,
  input [9:0]      Tmax,
  input [9:0]      Tmin,
  input [9:0]      max_spike_num,
  input [9:0]      rows,
  input [9:0]      cols, 
  input [7:0]      g1,
  input [7:0]      g2,
  input [7:0]      g3,
  input [7:0]      s1,
  input [7:0]      s2,
  input [7:0]      s3,
  //spike_output
  output [3:0]     poiss_spike,
  output [3:0]     ttfs_spike,  
  output [3:0]     isi_spike,
  output           ch_spike_encode_finish
);

//--------------variable definition--------------//
wire [1:0]   ram_mux;
wire         ram0_wr_en,ram1_wr_en,ram2_wr_en,ram3_wr_en;
wire         ram0_ren,ram1_ren,ram2_ren,ram3_ren;
wire [11:0]  ram0_rd_addr,ram1_rd_addr,ram2_rd_addr,ram3_rd_addr;
wire [11:0]  ram0_rd_addr_mux,ram1_rd_addr_mux,ram2_rd_addr_mux,ram3_rd_addr_mux;
wire [9:0]   poiss_time_step_cnt;
wire [9:0]   TIME_STEP_TH;
wire [31:0]  per_ram_data_lenth;
wire [9:0]   per_ram_image_data_guiss_lenth;
wire [7:0]   wr_ram_data;
wire [7:0]   image_rdata [3:0];
wire [7:0]   isi_ttfs_spike_image_rdata_ch_0;
wire [7:0]   isi_ttfs_spike_image_rdata_ch_1;
wire [7:0]   isi_ttfs_spike_image_rdata_ch_2;
wire [7:0]   isi_ttfs_spike_image_rdata_ch_3;
wire         guiss_differ_ren0,guiss_differ_ren1,guiss_differ_ren2,guiss_differ_ren3;
wire [9:0]   guiss_rd_adddr;
wire [9:0]   tmp [3:0]; 
wire         load_val_done;
wire         spike_gen_ram0_ren;
wire         spike_gen_ram1_ren;
wire         spike_gen_ram2_ren;
wire         spike_gen_ram3_ren;
wire [31:0]  spike_gen_ram_waddr;
wire [31:0]  spike_gen_ram0_raddr;
wire [31:0]  spike_gen_ram1_raddr;
wire [31:0]  spike_gen_ram2_raddr;
wire [31:0]  spike_gen_ram3_raddr;
wire [9:0]   spike_gen_ram_rdata [3:0];
wire [31:0]  guiss_res;
wire [31:0]  guiss_op_cnt;
wire         guiss_op_finish;
wire         isi_ttfs_ram0_ren;
wire         isi_ttfs_ram1_ren;
wire         isi_ttfs_ram2_ren;
wire         isi_ttfs_ram3_ren;
wire         ram_ttfs_ren;
wire         ram0_ttfs_wen;
wire         ram1_ttfs_wen;
wire         ram2_ttfs_wen;
wire         ram3_ttfs_wen;
wire         isi_ttfs_ram0_wen;
wire         isi_ttfs_ram1_wen;
wire         isi_ttfs_ram2_wen;
wire         isi_ttfs_ram3_wen;
wire [11:0]  isi_ttfs_ram0_waddr;
wire [11:0]  isi_ttfs_ram1_waddr;
wire [11:0]  isi_ttfs_ram2_waddr;
wire [11:0]  isi_ttfs_ram3_waddr;
wire [9:0]   isi_ttfs_ram0_wdata;
wire [9:0]   isi_ttfs_ram1_wdata;
wire [9:0]   isi_ttfs_ram2_wdata;
wire [9:0]   isi_ttfs_ram3_wdata;
wire [11:0]  isi_ttfs_ram0_raddr;
wire [11:0]  isi_ttfs_ram1_raddr;
wire [11:0]  isi_ttfs_ram2_raddr;
wire [11:0]  isi_ttfs_ram3_raddr;
wire         guiss_window_done_d3;
wire [31:0]  spike_gen_rdata_cnt_ch_0;
wire [31:0]  spike_gen_rdata_cnt_ch_1;
wire [31:0]  spike_gen_rdata_cnt_ch_2;
wire [31:0]  spike_gen_rdata_cnt_ch_3;
wire [31:0]  spike_gen_rdata_cnt_d_ch_0;
wire [31:0]  spike_gen_rdata_cnt_d_ch_1;
wire [31:0]  spike_gen_rdata_cnt_d_ch_2;
wire [31:0]  spike_gen_rdata_cnt_d_ch_3;
wire [10:0]  time_step_cnt_ch_0;
wire [10:0]  time_step_cnt_ch_1;
wire [10:0]  time_step_cnt_ch_2;
wire [10:0]  time_step_cnt_ch_3;
wire [10:0]  time_step_cnt_d_ch_0;
wire [10:0]  time_step_cnt_d_ch_1;
wire [10:0]  time_step_cnt_d_ch_2;
wire [10:0]  time_step_cnt_d_ch_3;
wire [3:0]   poiss_spike_gen;
wire [3:0]   ttfs_spike_gen;
wire [3:0]   isi_spike_gen;
wire         isi_spike_encode_finish;
wire         ttfs_spike_encode_finish;
wire         ch_poiss_spike_encode_finish;
wire         ch_isi_spike_encode_finish;
wire         ch_ttfs_spike_encode_finish;

reg [11:0]   ram0_wr_addr,ram1_wr_addr,ram2_wr_addr,ram3_wr_addr;
reg [31:0]   per_ram_data_cnt;
reg [31:0]   per_ram_data_cnt_d1;
reg          spike_gen_ram_wen;
reg          isi_ttfs_ram0_ren_d;
reg          isi_ttfs_ram1_ren_d;
reg          isi_ttfs_ram2_ren_d;
reg          isi_ttfs_ram3_ren_d;
reg [11:0]   ram0_ttfs_waddr;
reg [11:0]   ram1_ttfs_waddr;
reg [11:0]   ram2_ttfs_waddr;
reg [11:0]   ram3_ttfs_waddr;

//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//



endmodule
