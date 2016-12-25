`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:24:21 12/06/2016
// Design Name:
// Module Name:    vga_sync
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
module vga_sync(
	input wire clk, clr,
	output reg hsync, vsync, 
	output wire video_on,
	output wire [9:0] pixel_x, pixel_y
    );

	parameter hpixels = 800; 
	parameter vlines  = 525; 
	parameter hbp     = 144; 
	parameter hfp     = 784; 
	parameter vbp     = 35; 
	parameter vfp     = 515;
	
	reg [9:0] hc, vc;
	
	assign pixel_x = hc - hbp - 1;
	assign pixel_y = vc - vbp - 1;
	
	always @ (posedge clk or posedge clr)
	begin
		if (clr == 1)
			hc <= 0;
		else
		begin
			if (hc == hpixels - 1)
			begin
				hc <= 0;
			end
			else
			begin
				hc <= hc + 1;
			end
		end
	end
	
	always @*
	begin
		if(hc >= 96)
			hsync = 1;
		else
			hsync = 0;
	end
	
	always @(posedge clk or posedge clr)
	begin
		if (clr == 1)
		begin
			vc <= 0;
		end
		else
		begin
			if (hc == hpixels - 1)
			begin
				if (vc == vlines - 1)
				begin
					vc <= 0;
				end
				else
				begin
					vc <= vc + 1;
				end
			end
		end
	end
	
	always @*
	begin
		if(vc >= 2)
			vsync = 1;
		else
			vsync = 0;
	end

	assign video_on = (hc < hfp) && (hc > hbp) && (vc < vfp) && (vc > vbp);

endmodule
