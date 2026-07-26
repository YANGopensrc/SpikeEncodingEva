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

assign image_rdata[0] = image_rdata_ch_0;
assign image_rdata[1] = image_rdata_ch_1;
assign image_rdata[2] = image_rdata_ch_2;
assign image_rdata[3] = image_rdata_ch_3;

assign TIME_STEP_TH = spike_encoder_cfgdone & poiss_mode_en ? max_spike_num-1'b1 : 'd0;  //default value:POISS_time_step_th

//poiss_time_step_cnt
always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    poiss_time_step_cnt <= 'd0;
  end
  else if((poiss_time_step_cnt==TIME_STEP_TH) & ram0_ren & spike_code_en) begin
    poiss_time_step_cnt <= 'd0;
  end
  else if((poiss_time_step_cnt < TIME_STEP_TH) & ram0_ren & spike_code_en) begin
    poiss_time_step_cnt <= poiss_time_step_cnt + 1'b1;
  end
  else
    poiss_time_step_cnt <= 'd0;
end
  
//generate random_num,range:0~255
always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    LFSR <= 'b1;
  end
  else if(poiss_mode_en & spike_encode_state & ram0_ren) begin 
    LFSR[0] <= LFSR[7];
    LFSR[1] <= LFSR[0];
    LFSR[2] <= LFSR[1];
    LFSR[3] <= LFSR[2];
    LFSR[4] <= LFSR[3]^LFSR[7];
    LFSR[5] <= LFSR[4]^LFSR[7];
    LFSR[6] <= LFSR[5]^LFSR[7];
    LFSR[7] <= LFSR[6];
  end
  else ;
end 

assign rand_num = LFSR;   

//generate poiss_spike
genvar ch_i;

generate for(ch_i='d0;ch_i<'d4;ch_i=ch_i+'d1) 
  begin
    always @(*) begin
      if(image_rdata[ch_i]=='h0) begin
        poiss_spike[ch_i] = 1'b0;
      end
      else if((rand_num <= image_rdata[ch_i]) & poiss_mode_en) begin
        poiss_spike[ch_i] = 1'b1;
      end
      else begin
        poiss_spike[ch_i] = 1'b0;
      end
    end   
  end         
endgenerate


endmodule



