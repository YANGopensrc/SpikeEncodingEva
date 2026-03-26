//=====================================================================
//
// Designer   : Zhipeng Yang, SIAT, CAS
//
// Description:
//  The Module to realize a simple NICE Core used for spiking encode
//
// ====================================================================
`include "e203_defines.v"

`ifdef E203_HAS_NICE//{
module e203_subsys_nice_core (
    // System	
    input                         nice_clk             ,
    input                         nice_rst_n	          ,
    output                        nice_active	      ,
    output                        nice_mem_holdup	  ,
    // Control cmd_req
    input                         nice_req_valid       ,
    output                        nice_req_ready       ,
    input  [`E203_XLEN-1:0]       nice_req_inst        ,
    input  [`E203_XLEN-1:0]       nice_req_rs1         ,
    input  [`E203_XLEN-1:0]       nice_req_rs2         ,
    // Control cmd_rsp	
    output                        nice_rsp_valid       ,
    input                         nice_rsp_ready       ,
    output [`E203_XLEN-1:0]       nice_rsp_rdat       ,
    output                        nice_rsp_err    	  ,
    // Memory lsu_req	
    output                        nice_icb_cmd_valid   ,
    input                         nice_icb_cmd_ready   ,
    output [`E203_ADDR_SIZE-1:0]  nice_icb_cmd_addr    ,
    output                        nice_icb_cmd_read    ,
    output [`E203_XLEN-1:0]       nice_icb_cmd_wdata   ,
    output [1:0]                  nice_icb_cmd_size    ,
    // Memory lsu_rsp	
    input                         nice_icb_rsp_valid   ,
    output                        nice_icb_rsp_ready   ,
    input  [`E203_XLEN-1:0]       nice_icb_rsp_rdata   ,
    input                         nice_icb_rsp_err     	   
);

////////////////////////////////////////////////////////////
// decode
////////////////////////////////////////////////////////////
wire [6:0] opcode      = {7{nice_req_valid}} & nice_req_inst[6:0];
wire [2:0] rv32_func3  = {3{nice_req_valid}} & nice_req_inst[14:12];
wire [6:0] rv32_func7  = {7{nice_req_valid}} & nice_req_inst[31:25];

wire opcode_custom3 = (opcode == 7'b1111011); 
wire rv32_func3_010 = (rv32_func3 == 3'b010); 

wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000); 
wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001); 
wire rv32_func7_0000010 = (rv32_func7 == 7'b0000010); 
 
wire custom3_cfg_spike_encoder = opcode_custom3 & rv32_func3_010 & rv32_func7_0000000;
wire custom3_load_img          = opcode_custom3 & rv32_func3_010 & rv32_func7_0000001;
wire custom3_spike_finish_rd   = opcode_custom3 & rv32_func3_010 & rv32_func7_0000010;
wire custom3_image_op          = custom3_cfg_spike_encoder||custom3_load_img||custom3_spike_finish_rd;

//**************variable definition*****************************//
parameter IDLE_STATE         = 4'b0000;
parameter CFG_SPIKE_ENCODER  = 4'b0001;
parameter LOAD_IMG           = 4'b0010;
parameter SPIKE_ENCODE       = 4'b0011;

wire        idle_state;
wire        cfg_spike_encoder_state;
wire        load_img_state;
wire        spike_encode_state;
wire        go_cfg_spike_encoder_state;
wire        go_load_img_state;
wire        cfg_spike_encoder_start,load_img_start;
wire        spike_encoder_cfgdone,load_img_done;
wire        cfg_encoder_state_finish,load_img_state_finish;
wire        poiss_mode_en;
wire        ttfs_mode_en;
wire        isi_mode_en;
wire        spike_code_en;
wire [9:0]  sigma1,sigma2,threshold;                                 //config gussian conv kernel,only used for TTFS encode mode
wire [9:0]  encode_mode,image_input_type,Tmax,Tmin,max_spike_num;    //config Encode Mode for spike_encoder
wire [9:0]  batch_size,rgb_channel,rows,cols;                        //config image_input_size
wire [3:0]  poiss_spike_r;
wire [3:0]  poiss_spike_g;
wire [3:0]  poiss_spike_b;
wire [3:0]  ttfs_spike_r;
wire [3:0]  ttfs_spike_g;
wire [3:0]  ttfs_spike_b;
wire [3:0]  isi_spike_r;
wire [3:0]  isi_spike_g;
wire [3:0]  isi_spike_b;
wire [7:0]  nice_icb_rsp_rdata_r;
wire [7:0]  nice_icb_rsp_rdata_g;
wire [7:0]  nice_icb_rsp_rdata_b;
wire        nice_icb_rsp_valid_r;
wire        nice_icb_rsp_valid_g;
wire        nice_icb_rsp_valid_b;
wire [31:0] image_r_data_load_cnt;
wire        ch_r_spike_encode_finish;
wire        ch_g_spike_encode_finish;
wire        ch_b_spike_encode_finish;
wire        resu_spike_encode_finish;

reg [3:0]  image_process_fsm;
reg [31:0] nice_req_rs1_reg; 
reg [4:0]  cfg_spike_encoder_cnt;
reg [31:0] load_img_cnt;
reg [31:0] maddr;
reg [9:0]  spike_encoder_rf [0:11];
reg [4:0]  j;
reg [31:0] image_data_load_cnt;
reg [31:0] image_g_data_load_cnt;
reg [31:0] image_b_data_load_cnt;
reg [7:0]  g1,g2,g3,s1,s2,s3;
reg [31:0] image_data_lenth;
reg [31:0] rgb_per_channel_image_data_lenth;
reg [9:0]  rgb_per_channel_image_data_guiss_lenth;
reg        nice_rsp_valid_cfg_encoder,nice_rsp_valid_load_img;
reg        spike_encoder_cfgdone_d1,load_img_done_d1;


//**********************************************************************************************//
//------------------------------code available after paper acceptance---------------------------//
//**********************************************************************************************//




rgb_channel_process ch_process_red(       
  .nice_clk                (nice_clk                              ),
  .nice_rst_n              (nice_rst_n                            ),
  .image_data_lenth        (rgb_per_channel_image_data_lenth      ),    //i,[31:0]
  .image_data_guiss_lenth  (rgb_per_channel_image_data_guiss_lenth),    //i,[31:0]
  .load_img_state          (load_img_state                        ),    //i             
  .spike_encode_state      (spike_encode_state                    ),    //i
  .image_data_load_cnt     (image_r_data_load_cnt                 ),    //i,[31:0]
  .data_in                 (nice_icb_rsp_rdata_r                  ),    //i,[7:0],connect to nice_icb_rsp_rdata[7:0]
  .data_in_valid           (nice_icb_rsp_valid_r                  ),    //i,connect to nice_icb_rsp_valid
  .poiss_mode_en           (poiss_mode_en                         ),    //i
  .ttfs_mode_en            (ttfs_mode_en                          ),    //i
  .isi_mode_en             (isi_mode_en                           ),    //i
  .spike_code_en           (spike_code_en                         ),    //i
  .spike_encoder_cfgdone   (spike_encoder_cfgdone                 ),    //i
  .image_input_type        (image_input_type                      ),    //i
  .Tmax                    (Tmax                                  ),    //i,[9:0]
  .Tmin                    (Tmin                                  ),    //i,[9:0]
  .max_spike_num           (max_spike_num                         ),    //i,[9:0]
  .cols                    (cols                                  ),
  .rows                    (rows                                  ),
  .g1                      (g1                                    ),
  .g2                      (g2                                    ),
  .g3                      (g3                                    ),
  .s1                      (s1                                    ),
  .s2                      (s2                                    ),
  .s3                      (s3                                    ),
  //spike_output
  .poiss_spike             (poiss_spike_r                         ),     //o,[3:0]
  .ttfs_spike              (ttfs_spike_r                          ),     //o,[3:0]
  .isi_spike               (isi_spike_r                           ),     //o,[3:0]
  .ch_spike_encode_finish  (ch_r_spike_encode_finish              )
);

rgb_channel_process ch_process_green(
  .nice_clk                (nice_clk                              ),
  .nice_rst_n              (nice_rst_n                            ),
  .image_data_lenth        (rgb_per_channel_image_data_lenth      ),    //i,[31:0]
  .image_data_guiss_lenth  (rgb_per_channel_image_data_guiss_lenth),    //i,[31:0]
  .load_img_state          (load_img_state                        ),    //i             
  .spike_encode_state      (spike_encode_state                    ),    //i
  .image_data_load_cnt     (image_g_data_load_cnt                 ),    //i,[31:0]
  .data_in                 (nice_icb_rsp_rdata_g                  ),    //i,[7:0],connect to nice_icb_rsp_rdata[7:0]
  .data_in_valid           (nice_icb_rsp_valid_g                  ),    //i,connect to nice_icb_rsp_valid
  .poiss_mode_en           (poiss_mode_en                         ),    //i
  .ttfs_mode_en            (ttfs_mode_en                          ),    //i
  .isi_mode_en             (isi_mode_en                           ),    //i
  .spike_code_en           (spike_code_en                         ),    //i
  .spike_encoder_cfgdone   (spike_encoder_cfgdone                 ),    //i
  .image_input_type        (image_input_type                      ),    //i
  .Tmax                    (Tmax                                  ),    //i,[9:0]
  .Tmin                    (Tmin                                  ),    //i,[9:0]
  .max_spike_num           (max_spike_num                         ),    //i,[9:0]
  .cols                    (cols                                  ),
  .rows                    (rows                                  ),
  .g1                      (g1                                    ),
  .g2                      (g2                                    ),
  .g3                      (g3                                    ),
  .s1                      (s1                                    ),
  .s2                      (s2                                    ),
  .s3                      (s3                                    ),
  //spike_output
  .poiss_spike             (poiss_spike_g                         ),    //o,[3:0]
  .ttfs_spike              (ttfs_spike_g                          ),    //o,[3:0]
  .isi_spike               (isi_spike_g                           ),    //o,[3:0]
  .ch_spike_encode_finish  (ch_g_spike_encode_finish              )

);

rgb_channel_process ch_process_blue(
  .nice_clk                (nice_clk                              ),
  .nice_rst_n              (nice_rst_n                            ),
  .image_data_lenth        (rgb_per_channel_image_data_lenth      ),    //i,[31:0]
  .image_data_guiss_lenth  (rgb_per_channel_image_data_guiss_lenth),    //i,[31:0]
  .load_img_state          (load_img_state                        ),    //i             
  .spike_encode_state      (spike_encode_state                    ),    //i
  .image_data_load_cnt     (image_b_data_load_cnt                 ),    //i,[31:0]
  .data_in                 (nice_icb_rsp_rdata_b                  ),    //i,[7:0],connect to nice_icb_rsp_rdata[7:0]
  .data_in_valid           (nice_icb_rsp_valid_b                  ),    //i,connect to nice_icb_rsp_valid
  .poiss_mode_en           (poiss_mode_en                         ),    //i
  .ttfs_mode_en            (ttfs_mode_en                          ),    //i
  .isi_mode_en             (isi_mode_en                           ),    //i
  .spike_code_en           (spike_code_en                         ),    //i
  .spike_encoder_cfgdone   (spike_encoder_cfgdone                 ),    //i
  .image_input_type        (image_input_type                      ),    //i
  .Tmax                    (Tmax                                  ),    //i,[9:0]
  .Tmin                    (Tmin                                  ),    //i,[9:0]
  .max_spike_num           (max_spike_num                         ),    //i,[9:0]
  .cols                    (cols                                  ),
  .rows                    (rows                                  ),
  .g1                      (g1                                    ),
  .g2                      (g2                                    ),
  .g3                      (g3                                    ),
  .s1                      (s1                                    ),
  .s2                      (s2                                    ),
  .s3                      (s3                                    ),
  //spike_output
  .poiss_spike             (poiss_spike_b                         ),    //o,[3:0]
  .ttfs_spike              (ttfs_spike_b                          ),    //o,[3:0]
  .isi_spike               (isi_spike_b                           ),    //o,[3:0]
  .ch_spike_encode_finish  (ch_b_spike_encode_finish              )
);

  
endmodule



