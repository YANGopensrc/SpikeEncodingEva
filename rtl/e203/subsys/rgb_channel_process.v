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

//----------------------------------------------//
assign per_ram_data_lenth = {2'b0,image_data_lenth[31:2]};
assign wr_ram_data = load_img_state ? data_in[7:0] : 'h0;

//generate imag_in_ram wr_en & wr_addr
assign ram_mux = load_img_state ? (image_data_load_cnt % 4) : 'h0;
assign ram0_wr_en = (ram_mux=='h0) & load_img_state & data_in_valid ? 1'b1 : 1'b0;
assign ram1_wr_en = (ram_mux=='h1) & load_img_state & data_in_valid ? 1'b1 : 1'b0;
assign ram2_wr_en = (ram_mux=='h2) & load_img_state & data_in_valid ? 1'b1 : 1'b0;
assign ram3_wr_en = (ram_mux=='h3) & load_img_state & data_in_valid ? 1'b1 : 1'b0;

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    ram0_wr_addr <= 'd0;
    ram1_wr_addr <= 'd0;
    ram2_wr_addr <= 'd0;
    ram3_wr_addr <= 'd0;
  end
  else if(ram0_wr_en) begin
    ram0_wr_addr <= ram0_wr_addr + 1'b1;
  end
  else if(ram1_wr_en) begin
    ram1_wr_addr <= ram1_wr_addr + 1'b1;
  end
  else if(ram2_wr_en) begin
    ram2_wr_addr <= ram2_wr_addr + 1'b1;
  end
  else if(ram3_wr_en) begin
    ram3_wr_addr <= ram3_wr_addr + 1'b1;
  end
  else;
end

//generate imag_in_ram rd_en & rd_addr
always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    per_ram_data_cnt <= 'h0;
  end
  else if((per_ram_data_cnt < per_ram_data_lenth) & spike_encode_state & isi_mode_en) begin
    per_ram_data_cnt <= per_ram_data_cnt + 1'b1;
  end
  else if((per_ram_data_cnt < per_ram_data_lenth) & spike_encode_state & (poiss_time_step_cnt==TIME_STEP_TH) & spike_code_en) begin
    per_ram_data_cnt <= per_ram_data_cnt + 1'b1;
  end
  else ;
end

always @(posedge nice_clk or negedge nice_rst_n) begin 
  if(!nice_rst_n) begin
    per_ram_data_cnt_d1 <= 'd0;
  end
  else begin
    per_ram_data_cnt_d1 <= per_ram_data_cnt;
  end
end    

assign ram0_rd_addr = ttfs_mode_en & image_input_type[0] ? guiss_rd_adddr : per_ram_data_cnt[11:0];
assign ram1_rd_addr = ttfs_mode_en & image_input_type[0] ? guiss_rd_adddr : per_ram_data_cnt[11:0];
assign ram2_rd_addr = ttfs_mode_en & image_input_type[0] ? guiss_rd_adddr : per_ram_data_cnt[11:0];
assign ram3_rd_addr = ttfs_mode_en & image_input_type[0] ? guiss_rd_adddr : per_ram_data_cnt[11:0];

assign ram0_rd_addr_mux = ~isi_ttfs_ram0_ren ? ram0_rd_addr : spike_gen_rdata_cnt_ch_0[11:0];
assign ram1_rd_addr_mux = ~isi_ttfs_ram1_ren ? ram1_rd_addr : spike_gen_rdata_cnt_ch_1[11:0];
assign ram2_rd_addr_mux = ~isi_ttfs_ram2_ren ? ram2_rd_addr : spike_gen_rdata_cnt_ch_2[11:0];
assign ram3_rd_addr_mux = ~isi_ttfs_ram3_ren ? ram3_rd_addr : spike_gen_rdata_cnt_ch_3[11:0];

assign ram0_ren = ttfs_mode_en & image_input_type[0] ? guiss_differ_ren0 : spike_encode_state & (per_ram_data_cnt < per_ram_data_lenth) | isi_ttfs_ram0_ren;
assign ram1_ren = ttfs_mode_en & image_input_type[0] ? guiss_differ_ren1 : spike_encode_state & (per_ram_data_cnt < per_ram_data_lenth) | isi_ttfs_ram1_ren;
assign ram2_ren = ttfs_mode_en & image_input_type[0] ? guiss_differ_ren2 : spike_encode_state & (per_ram_data_cnt < per_ram_data_lenth) | isi_ttfs_ram2_ren;
assign ram3_ren = ttfs_mode_en & image_input_type[0] ? guiss_differ_ren3 : spike_encode_state & (per_ram_data_cnt < per_ram_data_lenth) | isi_ttfs_ram3_ren;

//-------------image_in_ram_inst-------------//
//use for store the image_in_data
block_ram #(.DATA_WIDTH(8),
            .ADDR_WIDTH(12))
 image_in_ram0 (
  .clk       (nice_clk),
  //wr_option
  .wr_en     (ram0_wr_en),
  .wr_addr   (ram0_wr_addr),
  .wr_data   (wr_ram_data),
  //rd_option
  .r_en      (ram0_ren),   
  .rd_addr   (ram0_rd_addr_mux),  
  .rd_data   (image_rdata[0])
);

block_ram #(.DATA_WIDTH(8),
            .ADDR_WIDTH(12))
 image_in_ram1 (
  .clk       (nice_clk),
  //wr_option
  .wr_en     (ram1_wr_en),
  .wr_addr   (ram1_wr_addr),
  .wr_data   (wr_ram_data),
  //rd_option
  .r_en      (ram1_ren),   
  .rd_addr   (ram1_rd_addr_mux),  
  .rd_data   (image_rdata[1])
);

block_ram #(.DATA_WIDTH(8),
            .ADDR_WIDTH(12))
 image_in_ram2 (
  .clk       (nice_clk),
  //wr_option
  .wr_en     (ram2_wr_en),
  .wr_addr   (ram2_wr_addr),
  .wr_data   (wr_ram_data),
  //rd_option
  .r_en      (ram2_ren),   
  .rd_addr   (ram2_rd_addr_mux),  
  .rd_data   (image_rdata[2])
);

block_ram #(.DATA_WIDTH(8),
            .ADDR_WIDTH(12))
 image_in_ram3 (
  .clk       (nice_clk),
  //wr_option
  .wr_en     (ram3_wr_en),
  .wr_addr   (ram3_wr_addr),
  .wr_data   (wr_ram_data),
  //rd_option
  .r_en      (ram3_ren),   
  .rd_addr   (ram3_rd_addr_mux),  
  .rd_data   (image_rdata[3])
);

assign isi_ttfs_spike_image_rdata_ch_0 = isi_ttfs_ram0_ren ? image_rdata[0] : 'h0;
assign isi_ttfs_spike_image_rdata_ch_1 = isi_ttfs_ram1_ren ? image_rdata[1] : 'h0;
assign isi_ttfs_spike_image_rdata_ch_2 = isi_ttfs_ram2_ren ? image_rdata[2] : 'h0;
assign isi_ttfs_spike_image_rdata_ch_3 = isi_ttfs_ram3_ren ? image_rdata[3] : 'h0;


//*******************************************************************************//
//----------------------------poiss spike Gen---------------------------------//
//*******************************************************************************//
poiss_spike_encoder poiss_spike_encoder_inst(
  //input
  .nice_clk             (nice_clk                ),
  .nice_rst_n           (nice_rst_n              ),
  .spike_encoder_cfgdone(spike_encoder_cfgdone   ),
  .poiss_mode_en        (poiss_mode_en           ),
  .max_spike_num        (max_spike_num           ),
  .spike_code_en        (spike_code_en           ),
  .spike_encode_state   (spike_encode_state      ),
  .ram0_ren             (ram0_ren                ),
  .image_rdata_ch_0     (image_rdata[0]          ),    //connect to image_rdata[0]
  .image_rdata_ch_1     (image_rdata[1]          ),    //connect to image_rdata[1]
  .image_rdata_ch_2     (image_rdata[2]          ),    //connect to image_rdata[2]
  .image_rdata_ch_3     (image_rdata[3]          ),    //connect to image_rdata[3]
  //output
  .poiss_time_step_cnt  (poiss_time_step_cnt     ),
  .poiss_spike          (poiss_spike_gen         ),
  .TIME_STEP_TH         (TIME_STEP_TH            )
);

assign poiss_spike = poiss_spike_gen;

//*******************************************************************************//
//----------------------------ttfs_isi spike Gen---------------------------------//
//*******************************************************************************//
ttfs_isi_encoder_share ttfs_isi_encoder_share_inst(
  //input
  .nice_clk                      (nice_clk                      ),
  .nice_rst_n                    (nice_rst_n                    ),
  .ttfs_mode_en                  (ttfs_mode_en                  ),
  .isi_mode_en                   (isi_mode_en                   ),
  .spike_encode_state            (spike_encode_state            ),
  .image_input_type              (image_input_type              ),
  .Tmax                          (Tmax                          ),
  .Tmin                          (Tmin                          ),
  .guiss_res                     (guiss_res[7:0]                ),
  .image_rdata_ch_0              (image_rdata[0]                ),    //connect to image_rdata[0]
  .image_rdata_ch_1              (image_rdata[1]                ),    //connect to image_rdata[1]
  .image_rdata_ch_2              (image_rdata[2]                ),    //connect to image_rdata[2]
  .image_rdata_ch_3              (image_rdata[3]                ),    //connect to image_rdata[3]
  .spike_gen_ram_waddr           (spike_gen_ram_waddr           ),
  .per_ram_data_lenth            (per_ram_data_lenth            ),
  .per_ram_image_data_guiss_lenth(per_ram_image_data_guiss_lenth),
  .ram_ttfs_ren                  (ram_ttfs_ren                  ),
  .spike_gen_ram0_ren            (spike_gen_ram0_ren            ),
  .spike_gen_ram1_ren            (spike_gen_ram1_ren            ),
  .spike_gen_ram2_ren            (spike_gen_ram2_ren            ),
  .spike_gen_ram3_ren            (spike_gen_ram3_ren            ),
  //output
  .tmp_ch_0                      (tmp[0]                        ),    //connect to tmp[0],guiss_differ ttfs_encode output
  .tmp_ch_1                      (tmp[1]                        ),    //connect to tmp[1],guiss_differ ttfs_encode output
  .tmp_ch_2                      (tmp[2]                        ),    //connect to tmp[2],guiss_differ ttfs_encode output
  .tmp_ch_3                      (tmp[3]                        ),    //connect to tmp[3],guiss_differ ttfs_encode output
  .load_val_done                 (load_val_done                 ),
  .spike_gen_ram_rdata_ch_0      (spike_gen_ram_rdata[0]        ),    //connect to spike_gen_ram_rdata[0]    
  .spike_gen_ram_rdata_ch_1      (spike_gen_ram_rdata[1]        ),    //connect to spike_gen_ram_rdata[1]      
  .spike_gen_ram_rdata_ch_2      (spike_gen_ram_rdata[2]        ),    //connect to spike_gen_ram_rdata[2]  
  .spike_gen_ram_rdata_ch_3      (spike_gen_ram_rdata[3]        ),    //connect to spike_gen_ram_rdata[3]  
  .spike_gen_rdata_cnt_ch_0      (spike_gen_rdata_cnt_ch_0      ),
  .spike_gen_rdata_cnt_ch_1      (spike_gen_rdata_cnt_ch_1      ),
  .spike_gen_rdata_cnt_ch_2      (spike_gen_rdata_cnt_ch_2      ),
  .spike_gen_rdata_cnt_ch_3      (spike_gen_rdata_cnt_ch_3      ),
  .spike_gen_rdata_cnt_d_ch_0    (spike_gen_rdata_cnt_d_ch_0    ),
  .spike_gen_rdata_cnt_d_ch_1    (spike_gen_rdata_cnt_d_ch_1    ),
  .spike_gen_rdata_cnt_d_ch_2    (spike_gen_rdata_cnt_d_ch_2    ),
  .spike_gen_rdata_cnt_d_ch_3    (spike_gen_rdata_cnt_d_ch_3    ),
  .time_step_cnt_ch_0            (time_step_cnt_ch_0            ),
  .time_step_cnt_ch_1            (time_step_cnt_ch_1            ),
  .time_step_cnt_ch_2            (time_step_cnt_ch_2            ),
  .time_step_cnt_ch_3            (time_step_cnt_ch_3            ),
  .time_step_cnt_d_ch_0          (time_step_cnt_d_ch_0          ), 
  .time_step_cnt_d_ch_1          (time_step_cnt_d_ch_1          ), 
  .time_step_cnt_d_ch_2          (time_step_cnt_d_ch_2          ), 
  .time_step_cnt_d_ch_3          (time_step_cnt_d_ch_3          ) 
);

//------------------------isi_encoder---------------------//
isi_spike_encoder isi_spike_encoder_inst(
  .nice_clk                         (nice_clk                       ),
  .nice_rst_n                       (nice_rst_n                     ),
  .isi_mode_en                      (isi_mode_en                    ),
  .Tmax                             (Tmax                           ),
  .spike_encode_state               (spike_encode_state             ),
  .time_step_cnt_d_ch_0             (time_step_cnt_d_ch_0           ), 
  .time_step_cnt_d_ch_1             (time_step_cnt_d_ch_1           ), 
  .time_step_cnt_d_ch_2             (time_step_cnt_d_ch_2           ), 
  .time_step_cnt_d_ch_3             (time_step_cnt_d_ch_3           ),
  .load_val_done                    (load_val_done                  ),
  .spike_gen_ram_rdata_ch_0         (spike_gen_ram_rdata[0]         ),      //connect to spike_gen_ram_rdata[0]    
  .spike_gen_ram_rdata_ch_1         (spike_gen_ram_rdata[1]         ),      //connect to spike_gen_ram_rdata[1]      
  .spike_gen_ram_rdata_ch_2         (spike_gen_ram_rdata[2]         ),      //connect to spike_gen_ram_rdata[2]  
  .spike_gen_ram_rdata_ch_3         (spike_gen_ram_rdata[3]         ),      //connect to spike_gen_ram_rdata[3]   
  .per_ram_data_lenth               (per_ram_data_lenth             ),
  .isi_ttfs_ram0_ren_d              (isi_ttfs_ram0_ren_d            ),
  .isi_ttfs_ram1_ren_d              (isi_ttfs_ram1_ren_d            ),
  .isi_ttfs_ram2_ren_d              (isi_ttfs_ram2_ren_d            ),
  .isi_ttfs_ram3_ren_d              (isi_ttfs_ram3_ren_d            ),
  .spike_gen_rdata_cnt_ch_0         (spike_gen_rdata_cnt_ch_0[9:0]  ),
  .spike_gen_rdata_cnt_ch_1         (spike_gen_rdata_cnt_ch_1[9:0]  ),
  .spike_gen_rdata_cnt_ch_2         (spike_gen_rdata_cnt_ch_2[9:0]  ),
  .spike_gen_rdata_cnt_ch_3         (spike_gen_rdata_cnt_ch_3[9:0]  ),
  .spike_gen_rdata_cnt_d_ch_0       (spike_gen_rdata_cnt_d_ch_0     ),
  .spike_gen_rdata_cnt_d_ch_1       (spike_gen_rdata_cnt_d_ch_1     ),
  .spike_gen_rdata_cnt_d_ch_2       (spike_gen_rdata_cnt_d_ch_2     ),
  .spike_gen_rdata_cnt_d_ch_3       (spike_gen_rdata_cnt_d_ch_3     ),
  .isi_ttfs_spike_image_rdata_ch_0  (isi_ttfs_spike_image_rdata_ch_0),
  .isi_ttfs_spike_image_rdata_ch_1  (isi_ttfs_spike_image_rdata_ch_1),
  .isi_ttfs_spike_image_rdata_ch_2  (isi_ttfs_spike_image_rdata_ch_2),
  .isi_ttfs_spike_image_rdata_ch_3  (isi_ttfs_spike_image_rdata_ch_3),
  .isi_spike                        (isi_spike_gen                  ),
  .isi_spike_encode_finish          (isi_spike_encode_finish        )
);

assign isi_spike = isi_spike_gen;

//------------------------ttfs_encoder---------------------//
ttfs_spike_encoder ttfs_spike_encoder_inst(
  //input
  .ttfs_mode_en                    (ttfs_mode_en                     ),
  .image_input_type                (image_input_type[0]              ),
  .Tmax                            (Tmax                             ),
  .isi_ttfs_ram0_ren_d             (isi_ttfs_ram0_ren_d              ),
  .isi_ttfs_ram1_ren_d             (isi_ttfs_ram1_ren_d              ),
  .isi_ttfs_ram2_ren_d             (isi_ttfs_ram2_ren_d              ),
  .isi_ttfs_ram3_ren_d             (isi_ttfs_ram3_ren_d              ),
  .spike_gen_rdata_cnt_d_ch_0      (spike_gen_rdata_cnt_d_ch_0       ),
  .spike_gen_rdata_cnt_d_ch_1      (spike_gen_rdata_cnt_d_ch_1       ),
  .spike_gen_rdata_cnt_d_ch_2      (spike_gen_rdata_cnt_d_ch_2       ),
  .spike_gen_rdata_cnt_d_ch_3      (spike_gen_rdata_cnt_d_ch_3       ),
  .per_ram_data_lenth              (per_ram_data_lenth               ), 
  .per_ram_image_data_guiss_lenth  (per_ram_image_data_guiss_lenth   ),
  .spike_gen_ram_rdata_ch_0        (spike_gen_ram_rdata[0]           ),      //connect to spike_gen_ram_rdata[0]    
  .spike_gen_ram_rdata_ch_1        (spike_gen_ram_rdata[1]           ),      //connect to spike_gen_ram_rdata[1]      
  .spike_gen_ram_rdata_ch_2        (spike_gen_ram_rdata[2]           ),      //connect to spike_gen_ram_rdata[2]  
  .spike_gen_ram_rdata_ch_3        (spike_gen_ram_rdata[3]           ),      //connect to spike_gen_ram_rdata[3]   
  .time_step_cnt_ch_0              (time_step_cnt_ch_0               ),
  .time_step_cnt_ch_1              (time_step_cnt_ch_1               ),
  .time_step_cnt_ch_2              (time_step_cnt_ch_2               ),
  .time_step_cnt_ch_3              (time_step_cnt_ch_3               ),
  //read_image_data
  .isi_ttfs_spike_image_rdata_ch_0 (isi_ttfs_spike_image_rdata_ch_0  ),
  .isi_ttfs_spike_image_rdata_ch_1 (isi_ttfs_spike_image_rdata_ch_1  ),
  .isi_ttfs_spike_image_rdata_ch_2 (isi_ttfs_spike_image_rdata_ch_2  ),
  .isi_ttfs_spike_image_rdata_ch_3 (isi_ttfs_spike_image_rdata_ch_3  ),
  //output
  .ttfs_spike                      (ttfs_spike_gen                   ),
  .ttfs_spike_encode_finish        (ttfs_spike_encode_finish         )
);

assign ttfs_spike = ttfs_spike_gen;

//*******************************************************************************//
//-----------------------------guiss_differ_inst---------------------------------//
//*******************************************************************************//
guiss_differ guiss_differ_inst(
  //input
  .nice_clk                      (nice_clk                          ),
  .nice_rst_n                    (nice_rst_n                        ),
  .rows                          (rows                              ),
  .cols                          (cols                              ), 
  .g1                            (g1                                ),
  .g2                            (g2                                ),
  .g3                            (g3                                ),
  .s1                            (s1                                ),
  .s2                            (s2                                ),
  .s3                            (s3                                ),
  .image_data_guiss_lenth        (image_data_guiss_lenth            ),
  .spike_encode_state            (spike_encode_state                ),
  .ttfs_mode_en                  (ttfs_mode_en & image_input_type[0]), 
  .image_rdata_ch_0              (image_rdata[0]                    ),   //connect to image_rdata[0]
  .image_rdata_ch_1              (image_rdata[1]                    ),   //connect to image_rdata[1]
  .image_rdata_ch_2              (image_rdata[2]                    ),   //connect to image_rdata[2]
  .image_rdata_ch_3              (image_rdata[3]                    ),   //connect to image_rdata[3]
  //output
  .per_ram_image_data_guiss_lenth(per_ram_image_data_guiss_lenth    ),
  .guiss_rd_adddr                (guiss_rd_adddr                    ),
  .guiss_differ_ren0             (guiss_differ_ren0                 ),
  .guiss_differ_ren1             (guiss_differ_ren1                 ),
  .guiss_differ_ren2             (guiss_differ_ren2                 ),
  .guiss_differ_ren3             (guiss_differ_ren3                 ),
  .guiss_res                     (guiss_res                         ),
  .guiss_op_finish               (guiss_op_finish                   ),
  .guiss_window_done_d3          (guiss_window_done_d3              ),
  .guiss_op_cnt                  (guiss_op_cnt                      )

);

//*******************************************************************************//
//-----------------------------isi_ttfs_ram_inst---------------------------------//
//*******************************************************************************//
always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    spike_gen_ram_wen <= 1'b0;
  end
  else begin
    spike_gen_ram_wen <= ram0_ren;
  end
end

assign ram0_ttfs_wen = (guiss_op_cnt[1:0]=='h0)&guiss_window_done_d3 ? 1'b1 : 1'b0;
assign ram1_ttfs_wen = (guiss_op_cnt[1:0]=='h1)&guiss_window_done_d3 ? 1'b1 : 1'b0;
assign ram2_ttfs_wen = (guiss_op_cnt[1:0]=='h2)&guiss_window_done_d3 ? 1'b1 : 1'b0;
assign ram3_ttfs_wen = (guiss_op_cnt[1:0]=='h3)&guiss_window_done_d3 ? 1'b1 : 1'b0;

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    ram0_ttfs_waddr <= 'h0;
    ram1_ttfs_waddr <= 'h0;
    ram2_ttfs_waddr <= 'h0;
    ram3_ttfs_waddr <= 'h0;
  end
  else if(ram0_ttfs_wen) begin
    ram0_ttfs_waddr <= ram0_ttfs_waddr + 1'b1;
  end
  else if(ram1_ttfs_wen) begin
    ram1_ttfs_waddr <= ram1_ttfs_waddr + 1'b1;
  end
  else if(ram2_ttfs_wen) begin
    ram2_ttfs_waddr <= ram2_ttfs_waddr + 1'b1;
  end
  else if(ram3_ttfs_wen) begin
    ram3_ttfs_waddr <= ram3_ttfs_waddr + 1'b1;
  end
  else ;
end

assign ram_ttfs_ren = guiss_op_finish && (ram0_ttfs_waddr==per_ram_image_data_guiss_lenth)
                                      && (ram1_ttfs_waddr==per_ram_image_data_guiss_lenth)
                                      && (ram2_ttfs_waddr==per_ram_image_data_guiss_lenth)
                                      && (ram3_ttfs_waddr==per_ram_image_data_guiss_lenth);

assign spike_gen_ram_waddr = per_ram_data_cnt_d1;
assign spike_gen_ram0_ren = load_val_done & (spike_gen_ram0_raddr < per_ram_data_lenth);
assign spike_gen_ram1_ren = load_val_done & (spike_gen_ram1_raddr < per_ram_data_lenth);
assign spike_gen_ram2_ren = load_val_done & (spike_gen_ram2_raddr < per_ram_data_lenth);
assign spike_gen_ram3_ren = load_val_done & (spike_gen_ram3_raddr < per_ram_data_lenth);

assign spike_gen_ram0_raddr = spike_gen_rdata_cnt_ch_0;
assign spike_gen_ram1_raddr = spike_gen_rdata_cnt_ch_1;
assign spike_gen_ram2_raddr = spike_gen_rdata_cnt_ch_2;
assign spike_gen_ram3_raddr = spike_gen_rdata_cnt_ch_3;

assign isi_ttfs_ram0_wen = ttfs_mode_en & image_input_type[0] ? ram0_ttfs_wen : spike_gen_ram_wen & (spike_gen_ram_waddr < per_ram_data_lenth);
assign isi_ttfs_ram1_wen = ttfs_mode_en & image_input_type[0] ? ram1_ttfs_wen : spike_gen_ram_wen & (spike_gen_ram_waddr < per_ram_data_lenth);
assign isi_ttfs_ram2_wen = ttfs_mode_en & image_input_type[0] ? ram2_ttfs_wen : spike_gen_ram_wen & (spike_gen_ram_waddr < per_ram_data_lenth);
assign isi_ttfs_ram3_wen = ttfs_mode_en & image_input_type[0] ? ram3_ttfs_wen : spike_gen_ram_wen & (spike_gen_ram_waddr < per_ram_data_lenth);

assign isi_ttfs_ram0_waddr = ttfs_mode_en & image_input_type[0] ? ram0_ttfs_waddr : spike_gen_ram_waddr[11:0]; 
assign isi_ttfs_ram1_waddr = ttfs_mode_en & image_input_type[0] ? ram1_ttfs_waddr : spike_gen_ram_waddr[11:0];
assign isi_ttfs_ram2_waddr = ttfs_mode_en & image_input_type[0] ? ram2_ttfs_waddr : spike_gen_ram_waddr[11:0];
assign isi_ttfs_ram3_waddr = ttfs_mode_en & image_input_type[0] ? ram3_ttfs_waddr : spike_gen_ram_waddr[11:0];

assign isi_ttfs_ram0_wdata = ttfs_mode_en & image_input_type[0] ? tmp[0] : tmp[0];
assign isi_ttfs_ram1_wdata = ttfs_mode_en & image_input_type[0] ? tmp[0] : tmp[1];
assign isi_ttfs_ram2_wdata = ttfs_mode_en & image_input_type[0] ? tmp[0] : tmp[2];
assign isi_ttfs_ram3_wdata = ttfs_mode_en & image_input_type[0] ? tmp[0] : tmp[3]; 

assign isi_ttfs_ram0_ren   = ttfs_mode_en & image_input_type[0] ? ram_ttfs_ren : spike_gen_ram0_ren;
assign isi_ttfs_ram1_ren   = ttfs_mode_en & image_input_type[0] ? ram_ttfs_ren : spike_gen_ram1_ren;
assign isi_ttfs_ram2_ren   = ttfs_mode_en & image_input_type[0] ? ram_ttfs_ren : spike_gen_ram2_ren;
assign isi_ttfs_ram3_ren   = ttfs_mode_en & image_input_type[0] ? ram_ttfs_ren : spike_gen_ram3_ren;

assign isi_ttfs_ram0_raddr = spike_gen_ram0_raddr[11:0];
assign isi_ttfs_ram1_raddr = spike_gen_ram1_raddr[11:0];
assign isi_ttfs_ram2_raddr = spike_gen_ram2_raddr[11:0];
assign isi_ttfs_ram3_raddr = spike_gen_ram3_raddr[11:0];

always @(posedge nice_clk or negedge nice_rst_n) begin 
  if(!nice_rst_n) begin
    isi_ttfs_ram0_ren_d <= 1'b0;
    isi_ttfs_ram1_ren_d <= 1'b0;
    isi_ttfs_ram2_ren_d <= 1'b0;
    isi_ttfs_ram3_ren_d <= 1'b0;
  end
  else begin
    isi_ttfs_ram0_ren_d <= isi_ttfs_ram0_ren;
    isi_ttfs_ram1_ren_d <= isi_ttfs_ram1_ren;
    isi_ttfs_ram2_ren_d <= isi_ttfs_ram2_ren;
    isi_ttfs_ram3_ren_d <= isi_ttfs_ram3_ren;
  end
end  


block_ram #(.DATA_WIDTH(10),
            .ADDR_WIDTH(12))
 isi_ttfs_ram0 (
  .clk       (nice_clk),
  //wr_op
  .wr_en     (isi_ttfs_ram0_wen),
  .wr_addr   (isi_ttfs_ram0_waddr),
  .wr_data   (isi_ttfs_ram0_wdata),
  //rd_op
  .r_en      (isi_ttfs_ram0_ren),
  .rd_addr   (isi_ttfs_ram0_raddr),  
  .rd_data   (spike_gen_ram_rdata[0])
);

block_ram #(.DATA_WIDTH(10),
            .ADDR_WIDTH(12))
 isi_ttfs_ram1 (
  .clk       (nice_clk),
  //wr_op
  .wr_en     (isi_ttfs_ram1_wen),
  .wr_addr   (isi_ttfs_ram1_waddr),
  .wr_data   (isi_ttfs_ram1_wdata),
  //rd_op
  .r_en      (isi_ttfs_ram1_ren),
  .rd_addr   (isi_ttfs_ram1_raddr),  
  .rd_data   (spike_gen_ram_rdata[1])
);

block_ram #(.DATA_WIDTH(10),
            .ADDR_WIDTH(12))
 isi_ttfs_ram2 (
  .clk       (nice_clk),
  //wr_op
  .wr_en     (isi_ttfs_ram2_wen),
  .wr_addr   (isi_ttfs_ram2_waddr),
  .wr_data   (isi_ttfs_ram2_wdata),
  //rd_op
  .r_en      (isi_ttfs_ram2_ren),
  .rd_addr   (isi_ttfs_ram2_raddr),    
  .rd_data   (spike_gen_ram_rdata[2])
);

block_ram #(.DATA_WIDTH(10),
            .ADDR_WIDTH(12))
 isi_ttfs_ram3 (
  .clk       (nice_clk),
  //wr_op
  .wr_en     (isi_ttfs_ram3_wen),
  .wr_addr   (isi_ttfs_ram3_waddr),
  .wr_data   (isi_ttfs_ram3_wdata),
  //rd_op
  .r_en      (isi_ttfs_ram3_ren),
  .rd_addr   (isi_ttfs_ram3_raddr),     
  .rd_data   (spike_gen_ram_rdata[3])
);

//------spike_encode_finish-----//
assign ch_poiss_spike_encode_finish = poiss_mode_en & spike_encode_state & (per_ram_data_cnt == per_ram_data_lenth);
assign ch_isi_spike_encode_finish   = isi_spike_encode_finish;
assign ch_ttfs_spike_encode_finish  = spike_encode_state & ttfs_spike_encode_finish;
assign ch_spike_encode_finish = ch_poiss_spike_encode_finish | ch_isi_spike_encode_finish | ch_ttfs_spike_encode_finish;

endmodule
