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

assign guiss_cols = ttfs_mode_en ? cols-'d3 : 'd0;
assign guiss_rows = ttfs_mode_en ? rows-'d3 : 'd0;
assign per_ram_image_data_guiss_lenth = {2'b0,image_data_guiss_lenth[9:2]};

always @(posedge nice_clk or negedge nice_rst_n) begin 
  if(!nice_rst_n) begin
    guiss_win_cnt <= 'h0;
  end
  else if(guiss_win_cnt=='h8) begin
    guiss_win_cnt <= 'h0;
  end
  else if(spike_encode_state & (!guiss_op_finish) & ttfs_mode_en) begin   //TODO
    guiss_win_cnt <= guiss_win_cnt + 1'b1;
  end
end
    
assign guiss_window_done = (guiss_win_cnt=='h8);

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    cnt_j <= 'd0;
  end
  else if((cnt_j==guiss_cols)&guiss_window_done) begin
    cnt_j <= 'd0;
  end
  else if(spike_encode_state & ttfs_mode_en & guiss_window_done & (!guiss_op_finish)) begin  //TODO
    cnt_j <= cnt_j+1'b1;
  end
  else ;
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    cnt_i <= 'd0;
  end
  else if((cnt_i > guiss_rows) & guiss_window_done) begin
    cnt_i <= 'd0;
  end
  else if(spike_encode_state & ttfs_mode_en & guiss_window_done &(cnt_j==guiss_rows)) begin
    cnt_i <= cnt_i+1'b1;
  end
  else ;
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    guiss_op_finish <= 1'b0;
  end
  else if(spike_encode_state & ttfs_mode_en & (cnt_i==guiss_rows) & (cnt_j==guiss_cols) & guiss_window_done) begin  //TODO
    guiss_op_finish <= 1'b1;
  end
  else;
end

assign  win_start_addr = rows*cnt_i+cnt_j;
assign double_rows = ttfs_mode_en ? (rows << 1'b1) : 'd0;

always @(*) begin
  if(guiss_win_cnt=='d0) begin
    guiss_win_rd_addr = win_start_addr;
  end
  else if(guiss_win_cnt=='d1) begin
    guiss_win_rd_addr = win_start_addr+'d1;
  end
  else if(guiss_win_cnt=='d2) begin
    guiss_win_rd_addr = win_start_addr+'d2;
  end
  else if(guiss_win_cnt=='d3) begin
    guiss_win_rd_addr = win_start_addr+rows;
  end
  else if(guiss_win_cnt=='d4) begin
    guiss_win_rd_addr = win_start_addr+rows+'d1;
  end
  else if(guiss_win_cnt=='d5) begin
    guiss_win_rd_addr = win_start_addr+rows+'d2;
  end
  else if(guiss_win_cnt=='d6) begin
    guiss_win_rd_addr = win_start_addr+double_rows;
  end
  else if(guiss_win_cnt=='d7) begin
    guiss_win_rd_addr = win_start_addr+double_rows+'d1;
  end
  else if(guiss_win_cnt=='d8) begin
    guiss_win_rd_addr = win_start_addr+double_rows+'d2;
  end
  else begin
    guiss_win_rd_addr = 'd0;
  end
end 

//guiss_win_rd_addr transform to read per_ram_addr
assign guiss_rd_adddr =  {2'b0,guiss_win_rd_addr[9:2]};
assign guiss_differ_ren0 = guiss_op_finish ? 1'b0 : spike_encode_state & (guiss_win_rd_addr[1:0]=='h0);
assign guiss_differ_ren1 = guiss_op_finish ? 1'b0 : spike_encode_state & (guiss_win_rd_addr[1:0]=='h1);
assign guiss_differ_ren2 = guiss_op_finish ? 1'b0 : spike_encode_state & (guiss_win_rd_addr[1:0]=='h2);
assign guiss_differ_ren3 = guiss_op_finish ? 1'b0 : spike_encode_state & (guiss_win_rd_addr[1:0]=='h3);

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    guiss_win_cnt_d <= 'd0;
  end
  else begin
    guiss_win_cnt_d <= guiss_win_cnt;
  end
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    guiss_window_done_d  <= 'd0;
    guiss_window_done_d1 <= 'd0;
    guiss_window_done_d2 <= 'd0;
    guiss_window_done_d3 <= 'd0;
  end
  else begin
    guiss_window_done_d <= guiss_window_done;
    guiss_window_done_d1 <= guiss_window_done_d;
    guiss_window_done_d2 <= guiss_window_done_d1;
    guiss_window_done_d3 <= guiss_window_done_d2;
  end
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    guiss_differ_ren0_d <= 1'b0;
    guiss_differ_ren1_d <= 1'b0;
    guiss_differ_ren2_d <= 1'b0;
    guiss_differ_ren3_d <= 1'b0;
  end
  else begin
    guiss_differ_ren0_d <= guiss_differ_ren0;
    guiss_differ_ren1_d <= guiss_differ_ren1;
    guiss_differ_ren2_d <= guiss_differ_ren2;
    guiss_differ_ren3_d <= guiss_differ_ren3;
  end
end
  
always @(*) begin
  if(guiss_differ_ren0_d)
    guiss_rdata  = image_rdata_ch_0;
  else if(guiss_differ_ren1_d)
    guiss_rdata  = image_rdata_ch_1;
  else if(guiss_differ_ren2_d)
    guiss_rdata  = image_rdata_ch_2;
  else if(guiss_differ_ren3_d)
    guiss_rdata  = image_rdata_ch_3;
  else 
    guiss_rdata  = 'h0;
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    win_data_0 <= 'h0;
    win_data_1 <= 'h0;
    win_data_2 <= 'h0;
    win_data_3 <= 'h0;
    win_data_4 <= 'h0;
    win_data_5 <= 'h0;
    win_data_6 <= 'h0;
    win_data_7 <= 'h0;
    win_data_8 <= 'h0;
  end
  else if(guiss_win_cnt_d=='d0) begin
    win_data_0 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d1) begin
    win_data_1 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d2) begin
    win_data_2 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d3) begin
    win_data_3 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d4) begin
    win_data_4 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d5) begin
    win_data_5 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d6) begin
    win_data_6 <= guiss_rdata;
  end 
  else if(guiss_win_cnt_d=='d7) begin
    win_data_7 <= guiss_rdata;
  end
  else if(guiss_win_cnt_d=='d8) begin
    win_data_8 <= guiss_rdata;
  end 
  else ;
end

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    sum1 <= 'd0;
    sum2 <= 'd0;
    sum3 <= 'd0;
  end
  else if(guiss_window_done_d1) begin
    sum1 <= win_data_0+win_data_2+win_data_6+win_data_8;
    sum2 <= win_data_1+win_data_3+win_data_5+win_data_7;
    sum3 <= win_data_4;
  end
  else ;
end

wire [7:0] guiss_weight1 = g1 > s1 ? g1-s1 : s1-g1;
wire [7:0] guiss_weight2 = g2 > s2 ? g2-s2 : s2-g2;
wire [7:0] guiss_weight3 = g3 > s3 ? g3-s3 : s3-g3; 

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    mult_g1 <= 'd0;
    mult_g2 <= 'd0;
    mult_g3 <= 'd0;
  end
  else begin
    mult_g1 <= sum1*guiss_weight1;
    mult_g2 <= sum2*guiss_weight2;
    mult_g3 <= sum3*guiss_weight3;
  end
end

assign G1 = {8'b0,mult_g1[31:8]};
assign G2 = {8'b0,mult_g2[31:8]};
assign G3 = {8'b0,mult_g3[31:8]};

assign guiss_res = G1 + G2 + G3;

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    guiss_op_cnt <= 'h0;
  end
  else if(guiss_window_done_d3) begin
    guiss_op_cnt <= guiss_op_cnt + 1'b1;
  end
  else;
end


endmodule
