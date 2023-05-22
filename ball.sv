//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [7:0]	  keycode,				 // keyboard press
					input logic   ball_exist1,	ball_shoot1, ball_hit1,	 // figure1 output
//					input logic   ball_exist2,	ball_shoot2, ball_hit2,	 // figure2 output
					input logic [9:0] figure1_x, 		 // position of figure1
					input logic [9:0] figure1_y,
//					input logic [9:0] figure2_x, 		 // position of figure2
//					input logic [9:0] figure2_y,
//					output logic  round_end,			 // one round finish
//					output logic  win_1, win_2,		 // winner
               output logic  is_ball,             // Whether current pixel belongs to ball or background
					output logic [2:0] ball_data
              );
    
    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd30;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd610;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd440;     // Bottommost point on the Y axis -- ground
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis -- speed in x direction
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis -- only when hit the ball
	 parameter [9:0] Ball_X_Serve = 10'd3; 	 // Serve speed
	 parameter [9:0] Ball_Y_Serve = 10'd3; 
	 parameter [9:0] Ball_Size = 10'd19;
    parameter [9:0] Ball_LENGTH = 10'd19;        // Ball size
	 parameter [9:0] circle_min = 13'd2000;
	 parameter [9:0] circle_max = 13'd6725;
    parameter [9:0] range_min = 10'd70;
	 parameter [9:0] range_max = 10'd60;
	 parameter [9:0] CenterX = 10'd14;
	 parameter [9:0] CenterY = 10'd16;
	 parameter [9:0] FrameX = 10'd18;
	 parameter [9:0] FrameY = 10'd19;
	 logic [18:0] read_address;
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic [9:0] range1_p, range1_n, range2_p, range2_n, square1, square2;
    ball_RAM ball_RAM(.*);
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (ball_exist1 == 1'b1 && ball_shoot1 == 1'b1)// both figures don't hold the ball  && ball_exist2 == 1'b1
        begin
//				if (ball_shoot1 == 1'b1) // when figure1 shoot the ball
//				begin
					Ball_X_Pos <= figure1_x + 10'd33;	// ball exist at the relative position to figure1
					Ball_Y_Pos <= figure1_y + 10'd51;
					Ball_X_Motion <= Ball_X_Serve;				// start speed
					Ball_Y_Motion <= (~(Ball_Y_Serve) + 1'b1);
//				end
//				else if (ball_shoot2 == 1'b1)
//				begin
//					Ball_X_Pos <= figure2_x - 10'd33;	// ball exist at the relative position to figure2
//					Ball_Y_Pos <= figure2_y + 10'd51;
//					Ball_X_Motion <= (~(Ball_X_Serve) + 1'b1);// start speed
//					Ball_Y_Motion <= (~(Ball_Y_Serve) + 1'b1);
//				end				
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion + 10'd3;	// v'=v0+gt  ball flying, speed in y direction increase by gravity
		  range1_p = Ball_X_Pos - figure1_x;
		  range1_n = figure1_x - Ball_X_Pos;
//		  range2_p = Ball_X_Pos - figure2_x;
//		  range2_n = figure2_x - Ball_X_Pos;
		  square1 = (Ball_X_Pos - figure1_x) * (Ball_X_Pos - figure1_x) + (Ball_Y_Pos - figure1_y) * (Ball_Y_Pos - figure1_y);
//		  square2 = (Ball_X_Pos - figure1_x) * (Ball_X_Pos - figure2_x) + (Ball_Y_Pos - figure1_y) * (Ball_Y_Pos - figure2_y);

        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
		  if (ball_exist1 == 1'b1 )	//&& ball_exist2 == 1'b1
				// when ball is flying, speed in y direction increase by gravity
				if ( ball_shoot1 == 1'b0 ) //&& ball_shoot2 == 1'b0
					begin
					Ball_X_Motion_in = Ball_X_Motion;
					Ball_Y_Motion_in = Ball_Y_Motion + 10'd3;	// v'=v0+gt
					end
					
				
				// when ball hit the bats, change the direction of movement
				if (ball_hit1 == 1'b1 && square1 >= circle_min && square1 <= circle_max && range1_p <= range_max && range1_n <= range_min)	// when figure1 try to hit the ball and ball is in the hitting range 
					begin
						Ball_X_Motion_in = Ball_X_Step;
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
					end
//				if (ball_hit2 == 1'b1 && square2 >= circle_min && square2 <= circle_max && range2_p <= range_max && range2_n <= range_min)	// when figure2 try to hit the ball and ball is in the hitting range 	
//					begin
//						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  
//						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
//					end
					
					
				// when ball hit wall or ground, change the direction of movement
            if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, round end
					begin
						Ball_Y_Motion_in = 1'b0;	//v_y=0
						Ball_X_Motion_in = 1'b0;	//v_x=0
					end
            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, should never happened. code haven't editted
					begin
						Ball_Y_Motion_in = Ball_Y_Motion + 10'd3;	// gravity
						Ball_X_Motion_in = 1'b0;
					end
					 
            else if( Ball_X_Pos + Ball_Size >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
					begin
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  
						Ball_Y_Motion_in = Ball_Y_Motion + 10'd3;	// gravity
					end
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the left edge, BOUNCE!
					begin
						Ball_X_Motion_in = Ball_X_Step;
						Ball_Y_Motion_in = Ball_Y_Motion + 10'd3;	// gravity
					end
			end				
					 
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion_in;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;

        end
        
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
	always_comb begin
		read_address = 19'b0;
		is_ball = 1'b0;
		if ((DrawX >= (Ball_X_Pos - CenterX) || Ball_X_Pos < CenterX )&& DrawX <= (Ball_X_Pos + FrameX-CenterX) &&
			 (DrawY >= (Ball_Y_Pos - CenterY) || Ball_Y_Pos < CenterY )&& DrawY <= (Ball_Y_Pos + FrameY-CenterY))begin
				is_ball = 1'b1;
				read_address = CenterX-(Ball_X_Pos- DrawX) + (CenterY-(Ball_Y_Pos - DrawY))*Ball_LENGTH;
				//             x position in ball         y position in ball
		 end 
     end
endmodule
	 
 module ball_RAM(	
	
	input [18:0] read_address, //write_address, 
	input Clk,
	
	output logic [2:0] ball_data
);

// mem has width of n bits and a total of xxx addresses
logic [2:0] mem [0:1]; // 18x19 = 342  341
initial
begin
	 $readmemh("ball.txt", mem);// read into mem
end


always_ff @ (posedge Clk) begin
	ball_data<= mem[read_address];// get data accroding to read_address computed above
	end
 
endmodule


