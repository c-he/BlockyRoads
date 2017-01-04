`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:13:29 12/17/2016 
// Design Name: 
// Module Name:    ps2_receiver 
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
module ps2_receiver(
    input wire clk, clr,
	input wire ps2c, ps2d,
	output wire [15:0] xkey
	);
	
	reg PS2Cf, PS2Df;
	reg [ 7:0] ps2c_filter, ps2d_filter;
	reg [10:0] shift1, shift2;
	
	assign xkey = {shift2[8:1], shift1[8:1]};
	
	// Filter for PS2 clock and data
	
	always @ (posedge clk or posedge clr)
	begin
		if (clr == 1)
		begin
			ps2c_filter <= 0;
			ps2d_filter <= 0;
			PS2Cf       <= 1;
			PS2Df       <= 1;
		end
		else
		begin
			ps2c_filter <= {ps2c, ps2c_filter[7:1]};
			ps2d_filter <= {ps2d, ps2d_filter[7:1]};
			if (ps2c_filter == 8'b1111_1111)
				PS2Cf <= 1;
			else if (ps2c_filter == 8'b0000_0000)
				PS2Cf <= 0;
			if (ps2d_filter == 8'b1111_1111)
				PS2Df <= 1;
			else if (ps2d_filter == 8'b0000_0000)
				PS2Df <= 0;
		end
	end
	
	// Shift register used to clock in scan codes from PS2
	always @ (negedge PS2Cf or posedge clr)
	begin
		if (clr == 1)
		begin
			shift1 <= 0;
			shift2 <= 1;
		end
		else
		begin
			shift1 <= {PS2Df, shift1[10:1]};
			shift2 <= {shift1[0], shift2[10:1]};
		end
	end

endmodule
