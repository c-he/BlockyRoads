`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:34 12/12/2016 
// Design Name: 
// Module Name:    Model 
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
module Model(
    input wire clk, clr,
	input wire ps2c, ps2d,
	output wire [7:0] segment,
	output wire [7:0] an
	);
	
	wire clk25m;
	wire [15:0] xkey;
	wire [6:0] a_to_g;
	wire dp;
	
	assign segment = {dp, a_to_g};
	
	clkdiv div_key (.clk(clk), .clr(clr), .clk25m(clk25m));
	ps2_receiver key_debug (.clk(clk25m), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .xkey(xkey));
	x7segbc seg_disp (.x({16'b0, xkey}), .clk(clk), .clr(clr), .a_to_g(a_to_g), .an(an), .dp(dp));

endmodule
