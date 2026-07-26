//****TODO by yangyk 2025-01-22
module submulshift (
input [9:0] ina,
input [9:0] inb,
input [9:0] inc,
output [9:0] out
);

wire [9:0]  tmp1;
wire [31:0] tmp2;

assign tmp1  = ina-inb;
assign tmp2  = tmp1*inc;    
assign out   = tmp2[17:8];

//assign out = (ina-inb)*inc>>'d8;



endmodule

