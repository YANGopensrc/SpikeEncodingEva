(*DONT_TOUCH = "yes"*)
module block_ram #(parameter DATA_WIDTH = 8,
                   parameter ADDR_WIDTH = 10)
(
  input clk,
  input r_en,
  input [ADDR_WIDTH-1:0] wr_addr,
  input [DATA_WIDTH-1:0] wr_data,
  input wr_en,
  input [ADDR_WIDTH-1:0] rd_addr,
  output reg [DATA_WIDTH-1:0] rd_data
);

localparam DEPTH = 1 << ADDR_WIDTH;

//(*ram_style = "block"*)reg [DATA_WIDTH-1:0] memory[0:DEPTH-1];
reg [DATA_WIDTH-1:0] memory[0:DEPTH-1];

always @ (posedge clk)begin
  if(wr_en) begin
    memory[wr_addr] <= wr_data;
  end
end

always @ (posedge clk) begin
  if(r_en) begin
    rd_data<=memory[rd_addr];
  end
  else begin
    rd_data<=32'bz;
  end
end
endmodule

