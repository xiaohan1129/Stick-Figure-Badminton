/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */
module background (
	input Clk, 
	//input logic background_exist,
	input logic [9:0] DrawX, DrawY,
	output logic [2:0] background_data,
	output logic is_background
);
	// screen size
	parameter [9:0] SCREEN_WIDTH =  10'd480;
   parameter [9:0] SCREEN_LENGTH = 10'd640;
	parameter [9:0] RESHAPE_LENGTH = 10'd320;
	//--------------------load memory-----------------//
	logic [18:0] read_address;
	assign read_address = DrawX/2 + DrawY/2*RESHAPE_LENGTH;
	background_RAM background_RAM(.*);
	always_comb begin
		is_background = 1'b1;
	end
endmodule

module  background_RAM
(
		input [18:0] read_address,
		input Clk,

		output logic [2:0] background_data
);

// mem has width of 3 bits and a total of 307200(640x480) addresses
//logic [2:0] mem [0:307199]; // 640x480 = 307200
logic [2:0] mem [0:1];// 320x240 = 76800
initial
begin
	 $readmemh("background.txt", mem);// read into mem
end
always_ff @ (posedge Clk) begin
	background_data<= mem[read_address];
	
end

endmodule
