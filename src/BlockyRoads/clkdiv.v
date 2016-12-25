`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:07:13 12/10/2016 
// Design Name: 
// Module Name:    clkdiv 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clkdiv(
    input wire clk,
	input wire clr,
	output wire clk25m,
	output wire clk100
	);
	
	reg [31:0] cnt;
	
	initial begin
		cnt <= 32'b0;
	end
	
	always @ (posedge clk or posedge clr)
	begin
		if (clr == 1'b1)
		begin
			cnt <= 32'b0;
		end
		else
		begin
			cnt <= cnt + 1'b1;
		end
	end
	
	assign clk25m = cnt[1];
	assign clk100 = cnt[19];

endmodule
