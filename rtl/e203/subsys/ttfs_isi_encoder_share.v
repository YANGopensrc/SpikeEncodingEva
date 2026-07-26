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


assign spike_gen_ram_ren[0] = spike_gen_ram0_ren;
assign spike_gen_ram_ren[1] = spike_gen_ram1_ren;
assign spike_gen_ram_ren[2] = spike_gen_ram2_ren;
assign spike_gen_ram_ren[3] = spike_gen_ram3_ren;

assign spike_gen_ram_rdata_ch[0] = spike_gen_ram_rdata_ch_0;
assign spike_gen_ram_rdata_ch[1] = spike_gen_ram_rdata_ch_1;
assign spike_gen_ram_rdata_ch[2] = spike_gen_ram_rdata_ch_2;
assign spike_gen_ram_rdata_ch[3] = spike_gen_ram_rdata_ch_3;

assign ttfs_spike_gen_ram_rdata_ch[0] = (spike_gen_ram_rdata_ch[0]!='h0) ? spike_gen_ram_rdata_ch[0] : 'h1;
assign ttfs_spike_gen_ram_rdata_ch[1] = (spike_gen_ram_rdata_ch[1]!='h0) ? spike_gen_ram_rdata_ch[1] : 'h1;
assign ttfs_spike_gen_ram_rdata_ch[2] = (spike_gen_ram_rdata_ch[2]!='h0) ? spike_gen_ram_rdata_ch[2] : 'h1;
assign ttfs_spike_gen_ram_rdata_ch[3] = (spike_gen_ram_rdata_ch[3]!='h0) ? spike_gen_ram_rdata_ch[3] : 'h1;

assign ttfs_guiss_en  = ttfs_mode_en & (image_input_type[0]==1'b1);
assign ttfs_source_en = ttfs_mode_en & (image_input_type[0]==1'b0);

//ttfs_guiss_differ
assign ina_ttfs_guiss    = ttfs_guiss_en ? 'd255                 : 'd0;
assign inb_ttfs_guiss[0] = ttfs_guiss_en ? {2'b0,guiss_res[7:0]} : 'd0;  //In ttfs_encoder guiss_differ mode, only use the submulshift_inst0
assign inb_ttfs_guiss[1] = ttfs_guiss_en ? 'd0                   : 'd0;
assign inb_ttfs_guiss[2] = ttfs_guiss_en ? 'd0                   : 'd0;
assign inb_ttfs_guiss[3] = ttfs_guiss_en ? 'd0                   : 'd0;

assign inc_ttfs_guiss[0] = ttfs_guiss_en ? Tmax : 'd0;
assign inc_ttfs_guiss[1] = ttfs_guiss_en ? Tmax : 'd0;
assign inc_ttfs_guiss[2] = ttfs_guiss_en ? Tmax : 'd0;
assign inc_ttfs_guiss[3] = ttfs_guiss_en ? Tmax : 'd0;

//ttfs_source
assign ina_ttfs_source    = ttfs_source_en ? 'd255                   : 'd0;
assign inb_ttfs_source[0] = ttfs_source_en ? {2'b0,image_rdata_ch_0} : 'd0;
assign inb_ttfs_source[1] = ttfs_source_en ? {2'b0,image_rdata_ch_1} : 'd0;
assign inb_ttfs_source[2] = ttfs_source_en ? {2'b0,image_rdata_ch_2} : 'd0;
assign inb_ttfs_source[3] = ttfs_source_en ? {2'b0,image_rdata_ch_3} : 'd0;

assign inc_ttfs_source[0] = ttfs_source_en ? Tmax : 'd0;
assign inc_ttfs_source[1] = ttfs_source_en ? Tmax : 'd0;
assign inc_ttfs_source[2] = ttfs_source_en ? Tmax : 'd0;
assign inc_ttfs_source[3] = ttfs_source_en ? Tmax : 'd0;

//isi
assign ina_isi    = isi_mode_en ? Tmax : 'd0;
assign inb_isi[0] = isi_mode_en ? Tmin : 'd0;
assign inb_isi[1] = isi_mode_en ? Tmin : 'd0;
assign inb_isi[2] = isi_mode_en ? Tmin : 'd0;
assign inb_isi[3] = isi_mode_en ? Tmin : 'd0;

assign inc_isi[0] = isi_mode_en ? {2'b0,image_rdata_ch_0} : 'd0;
assign inc_isi[1] = isi_mode_en ? {2'b0,image_rdata_ch_1} : 'd0;
assign inc_isi[2] = isi_mode_en ? {2'b0,image_rdata_ch_2} : 'd0;
assign inc_isi[3] = isi_mode_en ? {2'b0,image_rdata_ch_3} : 'd0;

assign submulshift_input_sel = {isi_mode_en,ttfs_source_en,ttfs_guiss_en};

always @(*) begin
    case(submulshift_input_sel) 
        3'b100: begin
                    ina <= ina_isi;
                    inb[0] <= inb_isi[0];
                    inb[1] <= inb_isi[1];
                    inb[2] <= inb_isi[2];
                    inb[3] <= inb_isi[3];
                    inc[0] <= inc_isi[0];
                    inc[1] <= inc_isi[1];
                    inc[2] <= inc_isi[2];
                    inc[3] <= inc_isi[3];
                end
        3'b010: begin
                    ina <= ina_ttfs_source;
                    inb[0] <= inb_ttfs_source[0];
                    inb[1] <= inb_ttfs_source[1];
                    inb[2] <= inb_ttfs_source[2];
                    inb[3] <= inb_ttfs_source[3];
                    inc[0] <= inc_ttfs_source[0];
                    inc[1] <= inc_ttfs_source[1];
                    inc[2] <= inc_ttfs_source[2];
                    inc[3] <= inc_ttfs_source[3];
                end
        3'b001: begin
                    ina <= ina_ttfs_guiss;
                    inb[0] <= inb_ttfs_guiss[0];
                    inb[1] <= inb_ttfs_guiss[1];
                    inb[2] <= inb_ttfs_guiss[2];
                    inb[3] <= inb_ttfs_guiss[3];
                    inc[0] <= inc_ttfs_guiss[0];
                    inc[1] <= inc_ttfs_guiss[1];
                    inc[2] <= inc_ttfs_guiss[2];
                    inc[3] <= inc_ttfs_guiss[3];
                end
        default:
                begin
                    ina <= ina_isi;
                    inb[0] <= inb_isi[0];
                    inb[1] <= inb_isi[1];
                    inb[2] <= inb_isi[2];
                    inb[3] <= inb_isi[3];
                    inc[0] <= inc_isi[0];
                    inc[1] <= inc_isi[1];
                    inc[2] <= inc_isi[2];
                    inc[3] <= inc_isi[3];
                end
    endcase
end
             
submulshift submulshift_inst0(.ina(ina),.inb(inb[0]),.inc(inc[0]),.out(out_tmp[0]));
submulshift submulshift_inst1(.ina(ina),.inb(inb[1]),.inc(inc[1]),.out(out_tmp[1]));
submulshift submulshift_inst2(.ina(ina),.inb(inb[2]),.inc(inc[2]),.out(out_tmp[2]));
submulshift submulshift_inst3(.ina(ina),.inb(inb[3]),.inc(inc[3]),.out(out_tmp[3]));

//calculate the isi_interval_value
assign cal_isi_interval_val_en = isi_mode_en & spike_encode_state & (spike_gen_ram_waddr < per_ram_data_lenth);

assign isi_tmp[0] = cal_isi_interval_val_en ? Tmax-out_tmp[0]-1'b1 : 'h0; 
assign isi_tmp[1] = cal_isi_interval_val_en ? Tmax-out_tmp[1]-1'b1 : 'h0; 
assign isi_tmp[2] = cal_isi_interval_val_en ? Tmax-out_tmp[2]-1'b1 : 'h0; 
assign isi_tmp[3] = cal_isi_interval_val_en ? Tmax-out_tmp[3]-1'b1 : 'h0; 

assign ttfs_source_tmp[0] = ttfs_source_en ?  out_tmp[0] : 'h0;
assign ttfs_source_tmp[1] = ttfs_source_en ?  out_tmp[1] : 'h0;
assign ttfs_source_tmp[2] = ttfs_source_en ?  out_tmp[2] : 'h0;
assign ttfs_source_tmp[3] = ttfs_source_en ?  out_tmp[3] : 'h0;

assign out_tmp_guiss_differ = (guiss_res[7:0]!='d0) ? out_tmp[0] : 'd1023;

//assign ttfs_guiss_tmp[0] = ttfs_guiss_en ? out_tmp[0] : 'd0;
assign ttfs_guiss_tmp[0] = ttfs_guiss_en ? out_tmp_guiss_differ : 'd0;
assign ttfs_guiss_tmp[1] = ttfs_guiss_en ? 'd0        : 'd0;
assign ttfs_guiss_tmp[2] = ttfs_guiss_en ? 'd0        : 'd0;
assign ttfs_guiss_tmp[3] = ttfs_guiss_en ? 'd0        : 'd0;

always @(*) begin
    case(submulshift_input_sel)
        3'b100: begin 
                    tmp_ch_0 <= isi_tmp[0];
                    tmp_ch_1 <= isi_tmp[1];
                    tmp_ch_2 <= isi_tmp[2];
                    tmp_ch_3 <= isi_tmp[3];
                end
        3'b010: begin
                    tmp_ch_0 <= ttfs_source_tmp[0];                  
                    tmp_ch_1 <= ttfs_source_tmp[1];
                    tmp_ch_2 <= ttfs_source_tmp[2];
                    tmp_ch_3 <= ttfs_source_tmp[3];
                end
        3'b001: begin
                    tmp_ch_0 <= ttfs_guiss_tmp[0];                  
                    tmp_ch_1 <= ttfs_guiss_tmp[1];
                    tmp_ch_2 <= ttfs_guiss_tmp[2];
                    tmp_ch_3 <= ttfs_guiss_tmp[3];
                end
        default: begin
                    tmp_ch_0 <= isi_tmp[0];
                    tmp_ch_1 <= isi_tmp[1];
                    tmp_ch_2 <= isi_tmp[2];
                    tmp_ch_3 <= isi_tmp[3];
                 end
    endcase
end                             

assign load_val_done = (spike_gen_ram_waddr==per_ram_data_lenth) & spike_encode_state & (ttfs_mode_en|isi_mode_en);


//ISI & TTFS encoder share the time_step_cnt/rdata_cnt
genvar ch_i;

generate
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin 
    always @(posedge nice_clk or negedge nice_rst_n) begin 
      if(!nice_rst_n) begin
        time_step_cnt[ch_i] <= 'd0;
      end
      else if((time_step_cnt[ch_i]==Tmax-1'b1) & isi_mode_en) begin
        time_step_cnt[ch_i] <= 'd0;
      end   
      else if(((time_step_cnt[ch_i]==ttfs_spike_gen_ram_rdata_ch[ch_i])|(time_step_cnt[ch_i]== Tmax-1'b1)) & ttfs_guiss_en) begin
        time_step_cnt[ch_i] <= 'd0;
      end
      else if((time_step_cnt[ch_i]==ttfs_spike_gen_ram_rdata_ch[ch_i]) & ttfs_source_en) begin
        time_step_cnt[ch_i] <= 'd0;
      end
      else if(load_val_done & (spike_gen_rdata_cnt[ch_i] < per_ram_data_lenth) & isi_mode_en) begin
        time_step_cnt[ch_i] <= time_step_cnt[ch_i] + 1'b1;
      end
      else if(ram_ttfs_ren & (spike_gen_rdata_cnt[ch_i] < per_ram_image_data_guiss_lenth) & ttfs_guiss_en & (time_step_cnt[ch_i] < Tmax)) begin
        time_step_cnt[ch_i] <= time_step_cnt[ch_i] + 1'b1;
      end
      else if(spike_gen_ram_ren[ch_i] & (spike_gen_rdata_cnt[ch_i] < per_ram_data_lenth) & ttfs_source_en & (time_step_cnt[ch_i] < Tmax)) begin
        time_step_cnt[ch_i] <= time_step_cnt[ch_i] + 1'b1;
      end
      else ;
    end
  end
endgenerate

generate
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin 
    always @(posedge nice_clk or negedge nice_rst_n) begin 
      if(!nice_rst_n) begin
        spike_gen_rdata_cnt[ch_i] <= 'd0;
      end
      else if((time_step_cnt[ch_i]==Tmax-1'b1) & (spike_gen_rdata_cnt[ch_i] < per_ram_data_lenth) & isi_mode_en)  begin
        spike_gen_rdata_cnt[ch_i] <= spike_gen_rdata_cnt[ch_i] + 1'b1;
      end
      else if(((time_step_cnt[ch_i]==ttfs_spike_gen_ram_rdata_ch[ch_i]-1'b1)|(time_step_cnt[ch_i]==Tmax-1'b1)) & (spike_gen_rdata_cnt[ch_i] < per_ram_image_data_guiss_lenth) & ttfs_guiss_en)  begin
        spike_gen_rdata_cnt[ch_i] <= spike_gen_rdata_cnt[ch_i] + 1'b1;
      end
      else if((time_step_cnt[ch_i]==ttfs_spike_gen_ram_rdata_ch[ch_i]-1'b1) & (spike_gen_rdata_cnt[ch_i] < per_ram_data_lenth) & ttfs_source_en)  begin
        spike_gen_rdata_cnt[ch_i] <= spike_gen_rdata_cnt[ch_i] + 1'b1;
      end
      else ;
    end    
  end
endgenerate  

assign spike_gen_rdata_cnt_d[0] = spike_gen_rdata_cnt[0];
assign spike_gen_rdata_cnt_d[1] = spike_gen_rdata_cnt[1];
assign spike_gen_rdata_cnt_d[2] = spike_gen_rdata_cnt[2];
assign spike_gen_rdata_cnt_d[3] = spike_gen_rdata_cnt[3];

assign spike_gen_rdata_cnt_ch_0 = spike_gen_rdata_cnt[0];
assign spike_gen_rdata_cnt_ch_1 = spike_gen_rdata_cnt[1];
assign spike_gen_rdata_cnt_ch_2 = spike_gen_rdata_cnt[2];
assign spike_gen_rdata_cnt_ch_3 = spike_gen_rdata_cnt[3];
assign spike_gen_rdata_cnt_d_ch_0 = spike_gen_rdata_cnt_d[0];
assign spike_gen_rdata_cnt_d_ch_1 = spike_gen_rdata_cnt_d[1];
assign spike_gen_rdata_cnt_d_ch_2 = spike_gen_rdata_cnt_d[2];
assign spike_gen_rdata_cnt_d_ch_3 = spike_gen_rdata_cnt_d[3];

generate
  for(ch_i=0;ch_i<4;ch_i=ch_i+1) begin 
    always @(posedge nice_clk or negedge nice_rst_n) begin 
      if(!nice_rst_n) begin
        time_step_cnt_d[ch_i] <= 'd0;
      end
      else begin
        time_step_cnt_d[ch_i] <= time_step_cnt[ch_i];
      end
    end
  end
endgenerate

assign time_step_cnt_ch_0 = time_step_cnt[0];
assign time_step_cnt_ch_1 = time_step_cnt[1];
assign time_step_cnt_ch_2 = time_step_cnt[2];
assign time_step_cnt_ch_3 = time_step_cnt[3];

assign time_step_cnt_d_ch_0 = time_step_cnt_d[0];
assign time_step_cnt_d_ch_1 = time_step_cnt_d[1];
assign time_step_cnt_d_ch_2 = time_step_cnt_d[2];
assign time_step_cnt_d_ch_3 = time_step_cnt_d[3];


endmodule
