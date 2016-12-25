`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:46 12/12/2016 
// Design Name: 
// Module Name:    Renderer 
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
module Renderer(
    input wire clk, clr,
	input wire [3:0] status, direction,
	output wire hsync, vsync,
	output reg  [3:0] red, green, blue
	);
	//============================================================================
	// vga_test module
	//============================================================================
	// vga_test debug_unit ( .clk(clk), .clr(clr), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue) );
	
	//============================================================================
	// Signal declaration
	//============================================================================
	wire clk25m, clk100;
	wire video_on;
	wire btn_pos;
	wire back_pos;
	wire road_pos;
	wire [9:0] pixel_x, pixel_y;
	wire [9:0] back_x, back_y, btn_x, btn_y, road_x, road_y;
	wire [10:0] back_xrom, back_yrom, btn_xrom, btn_yrom, road_xrom, road_yrom;
	wire [15:0] back_addr;
	wire [12:0] btn_addr;
	wire [16:0] road_addr;
	wire [11:0] back_data, btn_data, road_data;
	reg signed [31:0] scroll;
	
	// Game status signal declaration
	localparam [3:0]
		load      = 4'b1000,
		activate  = 4'b0100,
		pause     = 4'b0010,
		terminate = 4'b0001,
		none      = 4'b0000;
	//============================================================================
	// Instantiation
	//============================================================================
	// Instantiate vga_sync circuit
	clkdiv div_unit (.clk(clk), .clr(clr), .clk25m(clk25m), .clk100(clk100));
	vga_sync sync_unit (
	 	.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y)
	);

	// Instantiate bmp's pixel data
	background P1 (.clka(clk), .addra(back_addr), .douta(back_data));
	startBtn   P2 (.clka(clk), .addra(btn_addr), .douta(btn_data));
	road       P3 (.clka(clk), .addra(road_addr), .douta(road_data));
	
	//============================================================================
	// Object's properity
	//============================================================================
	// Background's properities
	assign back_x      = pixel_x;
	assign back_y      = pixel_y - 60;
	assign back_xrom   = {1'b0, back_x[9:1]};
	assign back_yrom   = {1'b0, back_y[9:1]};
	assign back_addr   = back_yrom * 320 + back_xrom;
	assign back_pos    = (pixel_y >=60) && (pixel_y < 420);
	// Start Button's properities
	assign btn_x       = pixel_x - 340;
	assign btn_y       = pixel_y - 340;
	assign btn_xrom    = {1'b0, btn_x[9:1]};
	assign btn_yrom    = {1'b0, btn_y[9:1]};
	assign btn_addr    = btn_yrom * 160 + btn_xrom;
	assign btn_pos     = (pixel_x > 340) && (pixel_x <= 660) && (pixel_y >= 340) && (pixel_y < 420);
	// Road's properities
	assign road_x      = back_x;
	assign road_y      = back_y;
	assign road_xrom   = {1'b0, road_x[9:1]};
	assign road_yrom   = ({1'b0, road_y[9:1]} + scroll) % 310;
	assign road_addr   = road_yrom * 320 + road_xrom;
	assign road_pos    = back_pos;
	
	//==========================================================================
	// Move
	//==========================================================================
	// Scrolling the road
	always @ (posedge clk100)
	begin
		scroll <= scroll - 1'b1;
	end
	
	//===========================================================================
	// Render
	// Layer 0: background
	// Layer 1: static objects
	// Layer 2: moving objects
	//===========================================================================
	always @*
	begin
	 	if (video_on)
	 	begin
			// Use FSM to render differnet status
			case (status)
				load:
				begin
					if (btn_pos) 							// Render the button
					begin
						if (btn_data == 12'hfff)			// Filter the background color
						begin
							if (back_pos)
							begin
								red   <= back_data[ 3: 0];
								green <= back_data[ 7: 4];
								blue  <= back_data[11: 8];
							end
							else
							begin
								red   <= 4'b0;
								green <= 4'b1000;
								blue  <= 4'b1111;
							end
						end
						else
						begin
							red   <= btn_data[ 3: 0];
							green <= btn_data[ 7: 4];
							blue  <= btn_data[11: 8];
						end
					end
					else if (back_pos)
					begin
							red   <= back_data[ 3: 0];
							green <= back_data[ 7: 4];
							blue  <= back_data[11: 8];
					end
					else
					begin
						red   <= 4'b0;
						green <= 4'b1000;
						blue  <= 4'b1111;
					end
				end
				activate:									// Render the activate status
				begin
					if (road_pos)
					begin
						red   <= road_data[ 3: 0];
						green <= road_data[ 7: 4];
						blue  <= road_data[11: 8];
					end
					else
					begin
						red   <= 4'b0;
						green <= 4'b1000;
						blue  <= 4'b1111;
					end
				end
				none:										// Render the default status
				begin
					if (back_pos)							// Render the background
					begin
						red   <= back_data[ 3: 0];
						green <= back_data[ 7: 4];
						blue  <= back_data[11: 8];
					end
					else
					begin
						red   <= 4'b0;
						green <= 4'b1000;
						blue  <= 4'b1111;
					end
				end
			endcase
		end
		else
	 	begin
	 		red   <= 4'b0;
	 		green <= 4'b0;
	 		blue  <= 4'b0;
	 	end
	 end

endmodule
