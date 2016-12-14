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
	output wire clk25m
	);
	
	reg [2:0] p;	// registers to generate 25MHz pulse
	
	initial begin
		p <= 0;
	end
	
	always @ (posedge clk)
	begin
		if (clr)
		begin
			p <= 0;
		end
		else
		begin
			p <= p + 1;
		end
	end
	
	assign clk25m = p[1];

endmodule
