//=====================================================================
//
// Designer   : YZP
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
//------------------------------------------FSM Controller--------------------------------------//
//**********************************************************************************************//
assign idle_state              = (image_process_fsm == IDLE_STATE);
assign cfg_spike_encoder_state = (image_process_fsm == CFG_SPIKE_ENCODER);
assign load_img_state          = (image_process_fsm == LOAD_IMG);
assign spike_encode_state      = (image_process_fsm == SPIKE_ENCODE);

assign go_cfg_spike_encoder_state = (image_process_fsm==IDLE_STATE) & custom3_cfg_spike_encoder;
assign go_load_img_state          = ((image_process_fsm==IDLE_STATE)||(image_process_fsm==CFG_SPIKE_ENCODER)) & custom3_load_img;

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        image_process_fsm <= IDLE_STATE;
    end
    else begin
        case(image_process_fsm)
            IDLE_STATE: 
                if(go_cfg_spike_encoder_state) begin
                    image_process_fsm <= CFG_SPIKE_ENCODER;
                end
                else if(go_load_img_state) begin
                    image_process_fsm <= LOAD_IMG;
                end 
                else ;  
            CFG_SPIKE_ENCODER: 
                if(go_load_img_state) begin
                    image_process_fsm <= LOAD_IMG;
                end
                else if(cfg_encoder_state_finish) begin
                    image_process_fsm <= IDLE_STATE;    
                end
                else ;
            LOAD_IMG: 
                if(load_img_state_finish) begin
                    image_process_fsm <= SPIKE_ENCODE;    
                end
                else ;
            SPIKE_ENCODE:
                image_process_fsm <= SPIKE_ENCODE;
            default: image_process_fsm <= IDLE_STATE;
        endcase
    end
end
              
assign nice_icb_cmd_valid = (cfg_spike_encoder_state||load_img_state) ? 1'b1 : 1'b0;  
assign nice_icb_cmd_addr = ((cfg_spike_encoder_state & cfg_spike_encoder_start)||(load_img_state & load_img_start)) ? nice_req_rs1_reg : maddr;
assign nice_icb_cmd_read  = (cfg_spike_encoder_state||load_img_state) ? 1'b1 : 1'b0;
assign nice_icb_cmd_wdata = (cfg_spike_encoder_state||load_img_state) ? 32'b0 : 32'b0; 
assign nice_icb_cmd_size  = 2'b10;
assign nice_icb_rsp_ready = 1'b1;
assign nice_req_ready = idle_state & (custom3_image_op ? nice_icb_cmd_ready : 1'b1);
assign nice_mem_holdup = nice_req_valid||nice_icb_cmd_valid||nice_icb_rsp_valid;   
assign nice_active = idle_state ? nice_req_valid : 1'b1;
assign nice_rsp_valid = nice_rsp_valid_cfg_encoder||nice_rsp_valid_load_img;

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        nice_rsp_valid_cfg_encoder <= 1'b0;
    end
    else if(cfg_spike_encoder_state==1'b1) begin
        nice_rsp_valid_cfg_encoder <= 1'b1;
    end
    else begin
        nice_rsp_valid_cfg_encoder <= 1'b0;
    end
end

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        nice_rsp_valid_load_img <= 1'b0;
    end
    else if(load_img_state==1'b1) begin
        nice_rsp_valid_load_img <= 1'b1;
    end
    else begin
        nice_rsp_valid_load_img <= 1'b0;
    end
end

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        nice_req_rs1_reg <= 'h0;
    end
    else begin
        nice_req_rs1_reg <= nice_req_rs1;
    end
end

//-------------------config spike_encoder cnt value--------------//
always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        cfg_spike_encoder_cnt <= 'd0;                     //sigma_cnt,sigma_state have two periods
    end
    else if(custom3_cfg_spike_encoder) begin
        cfg_spike_encoder_cnt <= 'd11;
    end
    else if(cfg_spike_encoder_cnt > 'd0)begin
        cfg_spike_encoder_cnt <= cfg_spike_encoder_cnt - 1'b1;
    end
    else ;
end

assign cfg_spike_encoder_start = (cfg_spike_encoder_cnt == 'd11);

//------------------load image_data cnt value------------------------//
always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        load_img_cnt <= 'd0;
    end
    else if(custom3_load_img) begin
        load_img_cnt <= image_data_lenth - 1'b1;
    end
    else if(load_img_cnt > 'd0) begin
        load_img_cnt <= load_img_cnt - 1'b1;
    end    
    else ;
end         

assign load_img_start =  (load_img_cnt == (image_data_lenth - 1'b1));

//=================generate access addr========================//
always @(posedge nice_clk or negedge nice_rst_n) begin   
    if(!nice_rst_n) begin
        maddr <= 'h0;
    end
    else if(cfg_spike_encoder_state) begin
        if(cfg_spike_encoder_start) begin
            maddr <= nice_req_rs1_reg + 'h4;        
        end
        else if(cfg_spike_encoder_cnt > 'h0) begin
            maddr <= maddr + 'h4;
        end
        else if(cfg_spike_encoder_cnt == 'h0) begin
            maddr <= 'h0;
        end
        else ;
    end
    else if(load_img_state) begin
        if(load_img_start) begin
            maddr <= nice_req_rs1_reg + 'h4;        
        end
        else if(load_img_cnt > 'h0) begin
            maddr <= maddr + 'h4;
        end
        else if(load_img_cnt == 'h0) begin
            maddr <= 'h0;
        end
        else ;
    end
    else ;
end


//----------------config spike_encoder-------------------------------//
always @(posedge nice_clk or negedge nice_rst_n) begin      
    if(!nice_rst_n) begin
        j <= 'd0;
    end
    else if(cfg_spike_encoder_state & nice_icb_rsp_valid) begin
        if(j < 'd12) begin
            j <= j + 1'b1;
        end
        else ;
    end
    else ;
end

assign spike_encoder_cfgdone = (j=='d12);

always @(posedge nice_clk or negedge nice_rst_n) begin 
    if(!nice_rst_n) begin
        spike_encoder_cfgdone_d1 <= 1'b0;
    end
    else begin
        spike_encoder_cfgdone_d1 <= spike_encoder_cfgdone;
    end
end

assign cfg_encoder_state_finish = spike_encoder_cfgdone & (~spike_encoder_cfgdone_d1);

integer i;
always @(posedge nice_clk or negedge nice_rst_n) begin 
    if(!nice_rst_n) begin
        for(i=1'b0;i<'d12;i=i+1'b1) 
            spike_encoder_rf[i] <= 'd0;
    end
    else if(cfg_spike_encoder_state & nice_icb_rsp_valid) begin
        spike_encoder_rf[j] <= nice_icb_rsp_rdata[9:0];
    end
    else ;
end       

//config gussian conv kernel,only used for TTFS encode mode
assign sigma1    = spike_encoder_cfgdone ? spike_encoder_rf[0] : 'd0;
assign sigma2    = spike_encoder_cfgdone ? spike_encoder_rf[1] : 'd0; 
assign threshold = spike_encoder_cfgdone ? spike_encoder_rf[2] : 'd0; 

//config Encode Mode for spike_encoder
assign encode_mode      = spike_encoder_cfgdone ? spike_encoder_rf[3] : 'd0;
assign image_input_type = spike_encoder_cfgdone ? spike_encoder_rf[4] : 'd0;
assign Tmax             = spike_encoder_cfgdone ? spike_encoder_rf[5] : 'd0;
assign Tmin             = spike_encoder_cfgdone ? spike_encoder_rf[6] : 'd0;
assign max_spike_num    = spike_encoder_cfgdone ? spike_encoder_rf[7] : 'd0; 

//config image_input_size
assign batch_size  = spike_encoder_cfgdone ? spike_encoder_rf[8] : 'd0;
assign rgb_channel = spike_encoder_cfgdone ? spike_encoder_rf[9] : 'd0;
assign rows        = spike_encoder_cfgdone ? spike_encoder_rf[10] : 'd0;
assign cols        = spike_encoder_cfgdone ? spike_encoder_rf[11] : 'd0;

assign poiss_mode_en = (encode_mode=='h0);        //poiss_spike_encode
assign ttfs_mode_en  = (encode_mode=='h1);        //ttfs_spike_encode
assign isi_mode_en   = (encode_mode=='h2);        //isi_spike_encode
assign spike_code_en = poiss_mode_en|ttfs_mode_en|isi_mode_en;   //spike_code enable

//---------------------load image data------------------------//
//one channel load_data_cnt
always @(posedge nice_clk or negedge nice_rst_n) begin   
    if(!nice_rst_n) begin
        image_data_load_cnt <= 'd0;
    end
    else if(load_img_state & nice_icb_rsp_valid) begin
        if(image_data_load_cnt < image_data_lenth) begin
            image_data_load_cnt <= image_data_load_cnt + 1'b1;
        end
        else ;
    end
    else ;
end

assign load_img_done = (image_data_load_cnt==image_data_lenth);

always @(posedge nice_clk or negedge nice_rst_n) begin   
    if(!nice_rst_n) begin
        load_img_done_d1 <= 1'b0;
    end
    else begin
        load_img_done_d1 <= load_img_done;
    end
end

assign load_img_state_finish = load_img_done & (~load_img_done_d1);

wire [31:0] image_r_data_load_cnt_th;
wire [31:0] image_g_data_load_cnt_th;
wire [31:0] image_b_data_load_cnt_th;

assign image_r_data_load_cnt_th = rgb_per_channel_image_data_lenth;
assign image_g_data_load_cnt_th = rgb_per_channel_image_data_lenth*'d2;
assign image_b_data_load_cnt_th = rgb_per_channel_image_data_lenth*'d3;

//rgb channels load_data_cnt
assign image_r_data_load_cnt = (image_data_load_cnt < image_r_data_load_cnt_th) ? image_data_load_cnt : rgb_per_channel_image_data_lenth;
always @(*) begin
    if(image_data_load_cnt < image_r_data_load_cnt_th) 
        image_g_data_load_cnt <= 'd0;
    else if(image_data_load_cnt < image_g_data_load_cnt_th)
        image_g_data_load_cnt <= image_data_load_cnt-image_r_data_load_cnt_th;
    else 
        image_g_data_load_cnt <= rgb_per_channel_image_data_lenth;
end

always @(*) begin
    if(image_data_load_cnt < image_g_data_load_cnt_th) 
        image_b_data_load_cnt <= 'd0;
    else if(image_data_load_cnt < image_b_data_load_cnt_th)
        image_b_data_load_cnt <= image_data_load_cnt-image_g_data_load_cnt_th;
    else 
        image_b_data_load_cnt <= rgb_per_channel_image_data_lenth;
end

assign nice_icb_rsp_rdata_r =  (image_r_data_load_cnt < rgb_per_channel_image_data_lenth) ? nice_icb_rsp_rdata[7:0] : 'd0;
assign nice_icb_rsp_rdata_g =  (image_g_data_load_cnt < rgb_per_channel_image_data_lenth)&(image_r_data_load_cnt==rgb_per_channel_image_data_lenth) ? nice_icb_rsp_rdata[7:0] : 'd0;
assign nice_icb_rsp_rdata_b =  (image_b_data_load_cnt < rgb_per_channel_image_data_lenth)&(image_g_data_load_cnt==rgb_per_channel_image_data_lenth) ? nice_icb_rsp_rdata[7:0] : 'd0;

assign nice_icb_rsp_valid_r =  (image_r_data_load_cnt < rgb_per_channel_image_data_lenth) ? nice_icb_rsp_valid : 1'b0;
assign nice_icb_rsp_valid_g =  (image_g_data_load_cnt < rgb_per_channel_image_data_lenth)&(image_r_data_load_cnt==rgb_per_channel_image_data_lenth) ? nice_icb_rsp_valid : 1'b0;
assign nice_icb_rsp_valid_b =  (image_b_data_load_cnt < rgb_per_channel_image_data_lenth)&(image_g_data_load_cnt==rgb_per_channel_image_data_lenth) ? nice_icb_rsp_valid : 1'b0;

//**********************generate gussian conv kernel(3x3)*************************//
always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        g1 <= 'd0;
        g2 <= 'd0;
        g3 <= 'd0;
    end
    else if(spike_encoder_cfgdone==1'b1) begin
        case(sigma1) 
                  'd1    : begin 
                             g1 <= 'd0;    
                             g2 <= 'd255;
                             g3 <= 'd0;
                           end     
                  'd2    : begin 
                             g1 <= 'd0;    
                             g2 <= 'd255;
                             g3 <= 'd0;
                           end     
                  'd3    : begin 
                             g1 <= 'd0;    
                             g2 <= 'd255;
                             g3 <= 'd0;
                           end     
                  'd4    : begin 
                             g1 <= 'd0;    
                             g2 <= 'd214;
                             g3 <= 'd10;
                           end     
                  'd5    : begin 
                             g1 <= 'd2;    
                             g2 <= 'd158;
                             g3 <= 'd20;
                           end     
                  'd6    : begin 
                             g1 <= 'd7;    
                             g2 <= 'd112;
                             g3 <= 'd28;
                           end     
                  'd7    : begin 
                             g1 <= 'd10;    
                             g2 <= 'd86;
                             g3 <= 'd30;
                           end    
                  'd8    : begin 
                             g1 <= 'd15;    
                             g2 <= 'd68;
                             g3 <= 'd30;
                           end     
                  'd9    : begin 
                             g1 <= 'd17;    
                             g2 <= 'd58;
                             g3 <= 'd30;
                           end     
                  'd10   : begin 
                             g1 <= 'd20;    
                             g2 <= 'd51;
                             g3 <= 'd30;
                           end     
                  'd11    : begin 
                             g1 <= 'd20;    
                             g2 <= 'd48;
                             g3 <= 'd30;
                           end     
                  'd12    : begin 
                             g1 <= 'd20;    
                             g2 <= 'd43;
                             g3 <= 'd30;
                           end     
                  'd13    : begin 
                             g1 <= 'd23;    
                             g2 <= 'd40;
                             g3 <= 'd30;
                           end     
                  'd14    : begin 
                             g1 <= 'd23;    
                             g2 <= 'd38;
                             g3 <= 'd30;
                           end     
                  'd15    : begin 
                             g1 <= 'd23;    
                             g2 <= 'd38;
                             g3 <= 'd30;
                           end     
                  'd16    : begin 
                             g1 <= 'd23;    
                             g2 <= 'd35;
                             g3 <= 'd30;
                           end     
                  'd17    : begin 
                             g1 <= 'd25;    
                             g2 <= 'd35;
                             g3 <= 'd28;
                           end    
                  'd18    : begin 
                             g1 <= 'd25;    
                             g2 <= 'd35;
                             g3 <= 'd28;
                           end     
                  'd19    : begin 
                             g1 <= 'd25;    
                             g2 <= 'd33;
                             g3 <= 'd28;
                           end     
                  'd20   : begin 
                             g1 <= 'd25;    
                             g2 <= 'd33;
                             g3 <= 'd28;
                           end     
                  default: begin 
                             g1 <= 'd0;    
                             g2 <= 'd0;
                             g3 <= 'd0;
                           end    
        endcase
    end
    else ;
end 

always @(posedge nice_clk or negedge nice_rst_n) begin
  if(!nice_rst_n) begin
    s1 <= 'd0;
    s2 <= 'd0;
    s3 <= 'd0;
  end
  else if(spike_encoder_cfgdone==1'b1) begin
    case(sigma2) 
              'd1    : begin 
                         s1 <= 'd0;    
                         s2 <= 'd255;
                         s3 <= 'd0;
                       end     
              'd2    : begin 
                         s1 <= 'd0;    
                         s2 <= 'd255;
                         s3 <= 'd0;
                       end     
              'd3    : begin 
                         s1 <= 'd0;    
                         s2 <= 'd255;
                         s3 <= 'd0;
                       end     
              'd4    : begin 
                         s1 <= 'd0;    
                         s2 <= 'd214;
                         s3 <= 'd10;
                       end     
              'd5    : begin 
                         s1 <= 'd2;    
                         s2 <= 'd158;
                         s3 <= 'd20;
                       end     
              'd6    : begin 
                         s1 <= 'd7;    
                         s2 <= 'd112;
                         s3 <= 'd28;
                       end     
              'd7    : begin 
                         s1 <= 'd10;    
                         s2 <= 'd86;
                         s3 <= 'd30;
                       end    
              'd8    : begin 
                         s1 <= 'd15;    
                         s2 <= 'd68;
                         s3 <= 'd30;
                       end     
              'd9    : begin 
                         s1 <= 'd17;    
                         s2 <= 'd58;
                         s3 <= 'd30;
                       end     
              'd10   : begin 
                         s1 <= 'd20;    
                         s2 <= 'd51;
                         s3 <= 'd30;
                       end     
              'd11    : begin 
                         s1 <= 'd20;    
                         s2 <= 'd48;
                         s3 <= 'd30;
                       end     
              'd12    : begin 
                         s1 <= 'd20;    
                         s2 <= 'd43;
                         s3 <= 'd30;
                       end     
              'd13    : begin 
                         s1 <= 'd23;    
                         s2 <= 'd40;
                         s3 <= 'd30;
                       end     
              'd14    : begin 
                         s1 <= 'd23;    
                         s2 <= 'd38;
                         s3 <= 'd30;
                       end     
              'd15    : begin 
                         s1 <= 'd23;    
                         s2 <= 'd38;
                         s3 <= 'd30;
                       end     
              'd16    : begin 
                         s1 <= 'd23;    
                         s2 <= 'd35;
                         s3 <= 'd30;
                       end     
              'd17    : begin 
                         s1 <= 'd25;    
                         s2 <= 'd35;
                         s3 <= 'd28;
                       end    
              'd18    : begin 
                         s1 <= 'd25;    
                         s2 <= 'd35;
                         s3 <= 'd28;
                       end     
              'd19    : begin 
                         s1 <= 'd25;    
                         s2 <= 'd33;
                         s3 <= 'd28;
                       end     
              'd20   : begin 
                         s1 <= 'd25;    
                         s2 <= 'd33;
                         s3 <= 'd28;
                       end     
              default: begin 
                         s1 <= 'd0;    
                         s2 <= 'd0;
                         s3 <= 'd0;
                       end    
    endcase
  end
  else ;
end 

//-----------calculate input_image_data_lenth-----------------//
always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        image_data_lenth <= 'd0;
    end
    else if(spike_encoder_cfgdone==1'b1) begin
        case({rgb_channel,rows,cols}) 
                {10'd1,10'd28,10'd28}:  image_data_lenth <= 'd784;     //MNIST image data lenth
                {10'd3,10'd32,10'd32}:  image_data_lenth <= 'd3072;    //CIFAR10 image data lenth(3 channel)
                {10'd1,10'd128,10'd128}:image_data_lenth <= 'd16384;   //IMAGENET image data lenth(1 channel)
                default:                image_data_lenth <= 'd784;     //image_data_lenth = rgb_channel*rows*cols
        endcase
    end
    else ;
end                          

//per_channel(RGB) image_data_lenth
always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        rgb_per_channel_image_data_lenth <= 'd0;
    end
    else if(spike_encoder_cfgdone==1'b1) begin
        case({rows,cols}) 
                {10'd28,10'd28}:  rgb_per_channel_image_data_lenth <= 'd784;    //MNIST image data lenth
                {10'd32,10'd32}:  rgb_per_channel_image_data_lenth <= 'd1024;   //CIFAR10 image data lenth(per channel)
                {10'd128,10'd128}:rgb_per_channel_image_data_lenth <= 'd16384;  //IMAGENET(per channel)
                default:          rgb_per_channel_image_data_lenth <= 'd784;    //rgb_per_channel_image_data_lenth = rows*cols
        endcase
    end
    else ;
end                          

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n) begin
        rgb_per_channel_image_data_guiss_lenth <= 'd0;
    end
    else if((encode_mode==1'b1) & (spike_encoder_cfgdone==1'b1)) begin
        case({rows,cols})
                {10'd28,10'd28}:  rgb_per_channel_image_data_guiss_lenth <= 'd676;    //MNIST image data lenth
                {10'd32,10'd32}:  rgb_per_channel_image_data_guiss_lenth <= 'd900;    //CIFAR10 image data lenth(per channel)
                default:          rgb_per_channel_image_data_guiss_lenth <= 'd676;    //image_data_guiss_lenth = rgb_channel*(rows-2)*(cols-2)
        endcase
    end
    else ;
end        

//******************************************************************************************************************************//
//---------------------------------------spike_encoder_channel(one rgb channel)-------------------------------------------------//
//******************************************************************************************************************************//
//The spike_encoder can process RGB three channels, 
//MNIST database use the red_channel_process by default  

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

assign resu_spike_encode_finish = ch_r_spike_encode_finish | ch_g_spike_encode_finish | ch_b_spike_encode_finish;

  
endmodule
`endif//}



