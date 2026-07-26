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

assign isi_ttfs_ram_ren_d[0] = isi_ttfs_ram0_ren_d;
assign isi_ttfs_ram_ren_d[1] = isi_ttfs_ram1_ren_d;
assign isi_ttfs_ram_ren_d[2] = isi_ttfs_ram2_ren_d;
assign isi_ttfs_ram_ren_d[3] = isi_ttfs_ram3_ren_d;

assign spike_gen_rdata_cnt_d[0] = spike_gen_rdata_cnt_d_ch_0;
assign spike_gen_rdata_cnt_d[1] = spike_gen_rdata_cnt_d_ch_1;
assign spike_gen_rdata_cnt_d[2] = spike_gen_rdata_cnt_d_ch_2;
assign spike_gen_rdata_cnt_d[3] = spike_gen_rdata_cnt_d_ch_3;

assign time_step_cnt[0] = time_step_cnt_ch_0;
assign time_step_cnt[1] = time_step_cnt_ch_1;
assign time_step_cnt[2] = time_step_cnt_ch_2;
assign time_step_cnt[3] = time_step_cnt_ch_3;

assign spike_gen_ram_rdata[0] = spike_gen_ram_rdata_ch_0;
assign spike_gen_ram_rdata[1] = spike_gen_ram_rdata_ch_1;
assign spike_gen_ram_rdata[2] = spike_gen_ram_rdata_ch_2;
assign spike_gen_ram_rdata[3] = spike_gen_ram_rdata_ch_3;

assign isi_ttfs_spike_image_rdata[0] = isi_ttfs_spike_image_rdata_ch_0;
assign isi_ttfs_spike_image_rdata[1] = isi_ttfs_spike_image_rdata_ch_1;
assign isi_ttfs_spike_image_rdata[2] = isi_ttfs_spike_image_rdata_ch_2;
assign isi_ttfs_spike_image_rdata[3] = isi_ttfs_spike_image_rdata_ch_3;

genvar ch_i;

generate 
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin
    always @(*) begin
      if(isi_ttfs_ram_ren_d[ch_i] && (spike_gen_rdata_cnt_d[ch_i] < per_ram_image_data_guiss_lenth) & ttfs_mode_en & image_input_type) begin
        if((spike_gen_ram_rdata[ch_i]==time_step_cnt[ch_i]) && (spike_gen_ram_rdata[ch_i]<Tmax))  
          ttfs_spike[ch_i] <= 1'b1;
        else
          ttfs_spike[ch_i] <= 1'b0;
      end
      else if(isi_ttfs_ram_ren_d[ch_i] && (spike_gen_rdata_cnt_d[ch_i] < per_ram_data_lenth) & ttfs_mode_en & (!image_input_type)) begin
        if((spike_gen_ram_rdata[ch_i]==time_step_cnt[ch_i]) & (isi_ttfs_spike_image_rdata[ch_i]!='h0))  
          ttfs_spike[ch_i] <= 1'b1;
        else
          ttfs_spike[ch_i] <= 1'b0;
      end
      else begin
        ttfs_spike[ch_i] <= 1'b0;
      end
    end
  end
endgenerate

assign ttfs_spike_encode_finish_src = ttfs_mode_en & (!image_input_type) & ((spike_gen_rdata_cnt_d[0]==per_ram_data_lenth)
                                                                                              & (spike_gen_rdata_cnt_d[1]==per_ram_data_lenth)
                                                                                              & (spike_gen_rdata_cnt_d[2]==per_ram_data_lenth)
                                                                                              & (spike_gen_rdata_cnt_d[3]==per_ram_data_lenth));

assign ttfs_spike_encode_finish_guiss = ttfs_mode_en & image_input_type  & ((spike_gen_rdata_cnt_d[0]==per_ram_image_data_guiss_lenth)
                                                                                                & (spike_gen_rdata_cnt_d[1]==per_ram_image_data_guiss_lenth)
                                                                                                & (spike_gen_rdata_cnt_d[2]==per_ram_image_data_guiss_lenth)
                                                                                                & (spike_gen_rdata_cnt_d[3]==per_ram_image_data_guiss_lenth));

assign ttfs_spike_encode_finish = ttfs_spike_encode_finish_src|ttfs_spike_encode_finish_guiss;

endmodule


