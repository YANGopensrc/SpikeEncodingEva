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

assign time_step_cnt_d[0] = time_step_cnt_d_ch_0;
assign time_step_cnt_d[1] = time_step_cnt_d_ch_1;
assign time_step_cnt_d[2] = time_step_cnt_d_ch_2;
assign time_step_cnt_d[3] = time_step_cnt_d_ch_3;

assign spike_gen_rdata_cnt[0] = spike_gen_rdata_cnt_ch_0;
assign spike_gen_rdata_cnt[1] = spike_gen_rdata_cnt_ch_1;
assign spike_gen_rdata_cnt[2] = spike_gen_rdata_cnt_ch_2;
assign spike_gen_rdata_cnt[3] = spike_gen_rdata_cnt_ch_3;

assign spike_gen_rdata_cnt_d[0] = spike_gen_rdata_cnt_d_ch_0;
assign spike_gen_rdata_cnt_d[1] = spike_gen_rdata_cnt_d_ch_1;
assign spike_gen_rdata_cnt_d[2] = spike_gen_rdata_cnt_d_ch_2;
assign spike_gen_rdata_cnt_d[3] = spike_gen_rdata_cnt_d_ch_3;

assign spike_gen_ram_rdata[0] = spike_gen_ram_rdata_ch_0;
assign spike_gen_ram_rdata[1] = spike_gen_ram_rdata_ch_1;
assign spike_gen_ram_rdata[2] = spike_gen_ram_rdata_ch_2;
assign spike_gen_ram_rdata[3] = spike_gen_ram_rdata_ch_3;

assign isi_ttfs_ram_ren_d[0] = isi_ttfs_ram0_ren_d;
assign isi_ttfs_ram_ren_d[1] = isi_ttfs_ram1_ren_d;
assign isi_ttfs_ram_ren_d[2] = isi_ttfs_ram2_ren_d;
assign isi_ttfs_ram_ren_d[3] = isi_ttfs_ram3_ren_d;

assign isi_ttfs_spike_image_rdata[0] = isi_ttfs_spike_image_rdata_ch_0;
assign isi_ttfs_spike_image_rdata[1] = isi_ttfs_spike_image_rdata_ch_1;
assign isi_ttfs_spike_image_rdata[2] = isi_ttfs_spike_image_rdata_ch_2;
assign isi_ttfs_spike_image_rdata[3] = isi_ttfs_spike_image_rdata_ch_3;

//stand for once read spike_gen_ram according to time_step finish  
assign time_step_rdata_done[0] = (time_step_cnt_d[0] == Tmax-1'b1) & spike_encode_state & isi_mode_en;
assign time_step_rdata_done[1] = (time_step_cnt_d[1] == Tmax-1'b1) & spike_encode_state & isi_mode_en;
assign time_step_rdata_done[2] = (time_step_cnt_d[2] == Tmax-1'b1) & spike_encode_state & isi_mode_en;
assign time_step_rdata_done[3] = (time_step_cnt_d[3] == Tmax-1'b1) & spike_encode_state & isi_mode_en;

always @(posedge nice_clk or negedge nice_rst_n) begin 
  if(!nice_rst_n) begin
    load_val_done_d <= 1'b0;
  end
  else begin
    load_val_done_d <= load_val_done;
  end
end

//isi_cnt only used for isi_spike_encoder
genvar ch_i;

generate 
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin
    always @(posedge nice_clk or negedge nice_rst_n) begin 
      if(!nice_rst_n) begin
        isi_cnt[ch_i] <= 'd0;
      end
      else if((isi_cnt[ch_i] == spike_gen_ram_rdata[ch_i])||time_step_rdata_done[ch_i]) begin
        isi_cnt[ch_i] <= 'd0;
      end   
      else if(load_val_done_d & (spike_gen_rdata_cnt[ch_i] < per_ram_data_lenth) & isi_mode_en) begin
        isi_cnt[ch_i] <= isi_cnt[ch_i] + 1'b1;
      end
      else ;
    end
  end
endgenerate

generate 
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin
    always @(*) begin
      if(isi_ttfs_ram_ren_d[ch_i] && (spike_gen_rdata_cnt_d[ch_i] < per_ram_data_lenth) & isi_mode_en) begin
        if((spike_gen_ram_rdata[ch_i]==isi_cnt[ch_i]) & (isi_ttfs_spike_image_rdata[ch_i]!='h0))  
          isi_spike[ch_i] <= 1'b1;
        else
          isi_spike[ch_i] <= 1'b0;
      end
      else begin
        isi_spike[ch_i] <= 1'b0;
      end
    end
  end
endgenerate


assign isi_spike_encode_finish = isi_mode_en & spike_encode_state & ((spike_gen_rdata_cnt_d[0] == per_ram_data_lenth) &
                                                                    (spike_gen_rdata_cnt_d[1] == per_ram_data_lenth) & 
                                                                    (spike_gen_rdata_cnt_d[0] == per_ram_data_lenth) & 
                                                                    (spike_gen_rdata_cnt_d[0] == per_ram_data_lenth));   


endmodule
