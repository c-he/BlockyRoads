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
	output wire [7:0] an,
	output wire [1:0] status
	);
	
	wire clk25m;
	wire [15:0] xkey;
	wire [6:0] a_to_g;
	wire dp;
	
	// game status signal declaration
	localparam [1:0]
		load      = 2'b00,
		activate  = 2'b01,
		pause     = 2'b10,
		terminate = 2'b11;
	
	assign segment = {dp, a_to_g};
	
	clkdiv div_key (.clk(clk), .clr(clr), .clk25m(clk25m));
	ps2_receiver keyboard (.clk(clk25m), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .xkey(xkey));
	// Use segment tube to display the scan code of keyboard
	x7segbc seg_disp (.x({16'b0, xkey}), .clk(clk), .clr(clr), .a_to_g(a_to_g), .an(an), .dp(dp));
	
	// Output the signals we need according to the shift register
	assign status = (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29) ? load : activate;
	/*
	always @ (posedge clk25m)
	begin
		if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29)
		begin
			status <= load;
		end
	end
	*/

endmodule
