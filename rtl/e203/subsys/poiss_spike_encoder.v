//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// ====================================================================


module poiss_spike_encoder(
  input        nice_clk,
  input        nice_rst_n,
  input        spike_encoder_cfgdone,
  input        poiss_mode_en,
  input [9:0]  max_spike_num,
  input        spike_code_en,
  input        spike_encode_state,
  input        ram0_ren,
  input [7:0]  image_rdata_ch_0,    //connect to image_rdata[0]
  input [7:0]  image_rdata_ch_1,    //connect to image_rdata[1]
  input [7:0]  image_rdata_ch_2,    //connect to image_rdata[2]
  input [7:0]  image_rdata_ch_3,    //connect to image_rdata[3]
  output reg [9:0] poiss_time_step_cnt,
  output reg [3:0] poiss_spike,
  output     [9:0] TIME_STEP_TH
);

wire [7:0] rand_num;
wire [7:0] image_rdata [3:0];


reg [7:0] LFSR;

//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//



endmodule



