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
	output wire hsync, vsync, video_on,
	output wire [9:0] pixel_x, pixel_y
    );

	// constant declaration
	// VGA 640-by-480 sync parameters
	localparam HD = 640; // horizontal display area
	localparam HF = 48;  // h.front(left) border
	localparam HB = 16;  // h.back(right) border
	localparam HR = 96;  // h.retrace
	localparam VD = 480; // vertical display area
	localparam VF = 10;  // v.front(top) border
	localparam VB = 33;  // v.back(bottom) border
	localparam VR = 2;   // v.retrace

	// sync counters
	reg [9:0] h_count_reg, h_count_next;
	reg [9:0] v_count_reg, v_count_next;
	// output buffer
	reg h_sync_reg, v_sync_reg;
	wire h_sync_next, v_sync_next;
	// status signal
	wire h_end, v_end;

	// body
	// registers
	always @ (posedge clk, posedge clr)
		if (clr)
		begin
			v_count_reg <= 0;
			h_count_reg <= 0;
			v_sync_reg <= 1'b0;
			h_sync_reg <= 1'b0;
		end
		else begin
			v_count_reg <= v_count_next;
			h_count_reg <= h_count_next;
			v_sync_reg <= v_sync_next;
			h_sync_reg <= h_sync_next;
		end

	// status signals
	// end of horizontal counter (799)
	assign h_end = (h_count_reg == (HD + HF + HB + HR - 1));
	// end of vertical counter (524)
	assign v_end = (v_count_reg == (VD + VF + VB + VR - 1));

	// next-state logic of mod-800 horizontal sync counter
	always @*
		if (clk)	// 25MHz pulse
			if (h_end)
				h_count_next = 0;
			else
				h_count_next = h_count_reg + 1;
		else
			h_count_next = h_count_reg;

	// next-state logic of mod-525 vertical syns counter
	always @*
		if (clk & h_end)	// 25MHz pulse
			if (v_end)
				v_count_next = 0;
			else
				v_count_next = v_count_reg + 1;
		else
			v_count_next = v_count_reg;

	// horizontal and vertical sync, buffered to avoid glich
	// h_sync_next asserted between 656 and 751
	assign h_sync_next = (h_count_reg >= (HD + HB) && h_count_reg <= (HD + HB + HR - 1));
	// v_sync_next asserted between 490 and 491
	assign v_sync_next = (v_count_reg >= (VD + VB) && v_count_reg <= (VD + VB + VR - 1));

	// video on/off
	assign video_on = (h_count_reg < HD) && (v_count_reg < VD);

	// output
	assign hsync = h_sync_reg;
	assign vsync = v_sync_reg;
	assign pixel_x = h_count_reg;
	assign pixel_y = v_count_reg;

endmodule
