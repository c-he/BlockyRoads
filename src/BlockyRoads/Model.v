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
	output reg  [3:0] status,
	output reg  [3:0] direction
	);
	
	wire clk25m;
	wire [15:0] xkey;
	wire [ 6:0] a_to_g;
	wire dp;
	reg  flag;
	
	initial 
	begin
		flag <= 1'b0;
	end
	
	// Game status signal declaration
	localparam [3:0]
		load      = 4'b1000,
		activate  = 4'b0100,
		pause     = 4'b0010,
		terminate = 4'b0001,
		none      = 4'b0000;

	assign segment = {dp, a_to_g};
	
	clkdiv div_key (.clk(clk), .clr(clr), .clk25m(clk25m));
	ps2_receiver keyboard (.clk(clk25m), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .xkey(xkey));
	
	// Use segment tube to display the scan code of keyboard
	x7segbc seg_disp (.x({16'b0, xkey}), .clk(clk), .clr(clr), .a_to_g(a_to_g), .an(an), .dp(dp));
	
	//========================================================================
	// Keyboard
	//========================================================================
	// Output the signals we need according to the shift register
	always @ (posedge clk25m)
	begin
		if (clr == 1'b1)
		begin
			status    <= none;
			direction <= 4'b0000;
			flag      <= 1'b0;
		end
		if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29 && flag == 1'b0)
		begin
			status <= load;
		end
		else if ((xkey[15: 8] == 8'hF0 && xkey[ 7: 0] == 8'h29) || flag == 1'b1)
		begin
			status <= activate;
			flag   <= 1'b1;
		end	
		else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1D)
		begin
			direction <= 4'b1000;	// Up
		end
		else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1B)
		begin
			direction <= 4'b0100;	// Down
		end
		else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1C)
		begin
			direction <= 4'b0010;	// Left
		end
		else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h23)
		begin
			direction <= 4'b0001;	// Right
		end
		else
		begin
			direction <= 4'b0000;
			status    <= none;
		end
	end

endmodule
