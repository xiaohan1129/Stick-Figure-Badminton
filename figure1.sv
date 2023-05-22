/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module figure1(
	input Clk,                // 50 MHz clock	
	input logic [9:0] DrawX, DrawY,
	input logic [9:0] figure1_x, figure1_y,	// from figure1Motion output
	input logic [9:0] figure2_x, figure2_y,	// from figure2Motion output
	input logic [5:0] figure1_state, figure2_state,	// from figure1FSM and figure2FSM
	output logic [2:0] figure1_data, figure2_data,
   output logic  is_figure1, is_figure2      // Whether current pixel belongs to figure1/2 or background
);
		
	// screen size
	parameter [9:0] SCREEN_WIDTH =  10'd480;	// Y
   parameter [9:0] SCREEN_LENGTH = 10'd640;	// X
	parameter [9:0] FIGURE1_WIDTH =  10'd424;	// Y
	parameter [9:0] FIGURE1_LENGTH =  10'd502;// X
	
	//--------------------load memory-----------------//
	logic [18:0] read_address1, read_address2;
	logic [9:0] CenterX1, CenterX2;		// figure1 center in the collection graph
	logic [9:0] CenterY1, CenterY2;
	logic [9:0] CornerX1, CornerX2;		// the frame left up corner
	logic [9:0] CornerY1, CornerY2;
	logic [9:0] FrameX1, FrameX2;		// the frame size
	logic [9:0] FrameY1, FrameY2;
	logic [5:0] state1, state2;
	figure1_RAM figure1_RAM(.*);
//	figure2_RAM figure2_RAM(.*);
	
		// use state as index to find the center of saber
	logic [9:0] figureStateCenterX[0:16];
	logic [9:0] figureStateCenterY[0:16];
	logic [9:0] figureStateCornerX[0:16];
	logic [9:0] figureStateCornerY[0:16];
	logic [9:0] figureStateFrameX[0:16];
	logic [9:0] figureStateFrameY[0:16];
	
	assign figureStateCenterX = '{10'd69,10'd155 ,10'd219 ,10'd278 ,10'd343 ,
										  10'd21  ,10'd123 ,10'd222 ,10'd270 ,10'd320 ,
										  10'd412 ,10'd69  ,10'd162 ,10'd259 ,10'd463 ,
										  10'd352 ,10'd465};//TODO 
											
	assign figureStateCenterY = '{10'd22,10'd22  ,10'd21  ,10'd21  ,10'd21  ,
										  10'd198 ,10'd198 ,10'd198 ,10'd198 ,10'd198 ,
										  10'd198 ,10'd332 ,10'd332 ,10'd333 ,10'd72 ,
										  10'd334 ,10'd334};//TODO
	
	assign figureStateCornerX = '{10'd0 ,10'd106 ,10'd194 ,10'd257 ,10'd321 ,
										  10'd0   ,10'd103 ,10'd151 ,10'd248 ,10'd299 ,
										  10'd387 ,10'd0   ,10'd92  ,10'd188 ,10'd394 ,
										  10'd286 ,10'd396};//TODO

	assign figureStateCornerY = '{10'd0 ,10'd0   ,10'd0   ,10'd0   ,10'd0   ,
										  10'd160 ,10'd107 ,10'd145 ,10'd122 ,10'd142 ,
										  10'd172 ,10'd283 ,10'd283 ,10'd283 ,10'd49  ,
										  10'd306 ,10'd311};//TODO
										
	assign figureStateFrameX = '{10'd106,10'd88  ,10'd63  ,10'd64  ,10'd112 ,
										 10'd103  ,10'd48  ,10'd97  ,10'd51  ,10'd85  ,
										 10'd115  ,10'd92  ,10'd96  ,10'd98  ,10'd108 ,
										 10'd101  ,10'd106};//TODO
									
	assign figureStateFrameY = '{10'd108,10'd107 ,10'd114 ,10'd114 ,10'd106 ,
										 10'd123  ,10'd176 ,10'd138 ,10'd161 ,10'd141 ,
										 10'd111  ,10'd137 ,10'd137 ,10'd138 ,10'd107 ,
										 10'd116  ,10'd110};//TODO
									
	assign CenterX1 = figureStateCenterX[state1];	// Center position
	assign CenterY1 = figureStateCenterY[state1];
	assign CornerX1 = figureStateCornerX[state1];	// left up corner
	assign CornerY1 = figureStateCornerY[state1];
	assign FrameX1 = figureStateFrameX[state1];	// the frame size
	assign FrameY1 = figureStateFrameY[state1];
	
	assign CenterX2 = figureStateCenterX[state2];	// Center position
	assign CenterY2 = figureStateCenterY[state2];
	assign CornerX2 = figureStateCornerX[state2];	// left up corner
	assign CornerY2 = figureStateCornerY[state2];
	assign FrameX2 = figureStateFrameX[state2];	// the frame size
	assign FrameY2 = figureStateFrameY[state2];

	// Compute whether the pixel corresponds to figure1/2 or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
	always_comb begin
		state1 = figure1_state;
		state2 = figure2_state;
		read_address1 = 19'b0;
		is_figure1 = 1'b0;
		read_address2 = 19'b0;
		is_figure2 = 1'b0;
		if ((DrawX >= figure1_x - (CenterX1-CornerX1) || figure1_x < (CenterX1-CornerX1)) && DrawX <= figure1_x + (CornerX1+FrameX1-CenterX1) &&
			 (DrawY >= figure1_y - (CenterY1-CornerY1) || figure1_y < (CenterY1-CornerY1)) && DrawY <= figure1_y + (CornerY1+FrameY1-CenterY1))begin
				is_figure1 = 1'b1;
				read_address1 = CenterX1-(figure1_x - DrawX) + (CenterY1-(figure1_y - DrawY))*FIGURE1_LENGTH;
				//             x position in figure1          y position in figure1
		 end	 
		if ((DrawX >= figure2_x - (CornerX2+FrameX2-CenterX2) || figure2_x < (CenterX2-CornerX2)) && DrawX <= figure2_x + (CenterX2-CornerX2) &&
			 (DrawY >= figure2_y - (CenterY2-CornerY2) || figure2_y < (CenterY2-CornerY2)) && DrawY <= figure2_y + (CornerY2+FrameY2-CenterY2))begin
				is_figure2 = 1'b1;
				read_address2 = CenterX2+(figure2_x - DrawX) + (CenterY2-(figure2_y - DrawY))*FIGURE1_LENGTH;
				//             x position in figure2          y position in figure2
		 end
     end   
endmodule


	
module figure1_RAM(		
	input [18:0] read_address1, read_address2,//write_address, 
	input Clk,
	
	output logic [2:0] figure1_data, figure2_data
);

// mem has width of n bits and a total of xxx addresses
logic [2:0] mem [0:1]; // 424x502 = 212848  212847
initial
begin
	 $readmemh("figure1.txt", mem);// read into mem
end


always_ff @ (posedge Clk) begin
	figure1_data<= mem[read_address1];// get data accroding to read_address computed above
	figure2_data<= mem[read_address2];
	end

endmodule

