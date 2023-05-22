module  figure1Motion ( 
					input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [7:0]	  keycode,				 // keyboard press
					output logic [9:0] figure1_x,
					output logic [9:0] figure1_y
              );


	parameter [9:0] figure1_X_Center = 10'd160;  // Start X position
   parameter [9:0] figure1_Y_Center = 10'd360;  // Start Y position
	// motion range
   parameter [9:0] figure1_X_Min = 10'd40;       // Leftmost point on the X axis
   parameter [9:0] figure1_X_Max = 10'd300;     // Rightmost point on the X axis	
   parameter [9:0] figure1_Y_Min = 10'd0;       // Topmost point on the Y axis
   parameter [9:0] figure1_Y_Max = 10'd440;     // Bottommost point on the Y axis
	// motion step
   parameter [9:0] figure1_X_Step = 10'd1;      // Step size on the X axis
   parameter [9:0] figure1_Y_Step = 10'd1;      // Step size on the Y axis
	
    logic [9:0] figure1_X_Pos, figure1_X_Motion, figure1_Y_Pos, figure1_Y_Motion;
    logic [9:0] figure1_X_Pos_in, figure1_Y_Pos_in; 


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
        if (Reset) // back to original place and don't move
        begin
            figure1_X_Pos <= figure1_X_Center;
            figure1_Y_Pos <= figure1_Y_Center;
        end
        else
        begin
            figure1_X_Pos <= figure1_X_Pos_in;
            figure1_Y_Pos <= figure1_Y_Pos_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.	 
	 
	 always_comb
    begin
        // By default, keep motion and position unchanged
        figure1_X_Pos_in = figure1_X_Pos;
        figure1_Y_Pos_in = figure1_Y_Pos;
		  figure1_x = figure1_X_Pos;
		  figure1_y = figure1_Y_Pos; 
		  figure1_X_Motion = 10'd0;
        figure1_Y_Motion = 10'd0;
		  			
        // Update position and motion only at rising edge of frame clockv
        if (frame_clk_rising_edge)
        begin
			 case(keycode)
				8'h04: // A: Go left
					begin
					   figure1_X_Motion = (~(figure1_X_Step) + 1'b1);
						figure1_Y_Motion = 10'h000;
					end 
				8'h07: // D: Go right
					begin
						figure1_X_Motion = figure1_X_Step;
						figure1_Y_Motion = 10'h000;
					end
				8'h1a: // W: Jump not use now
					begin
						figure1_Y_Motion = 10'h000;//(~(figure1_Y_Step) + 1'b1);
						figure1_X_Motion = 10'h000;
					end
				8'h16: // S: Bat not use now
					begin
						figure1_Y_Motion = 10'h000;//figure1_Y_Step;
						figure1_X_Motion = 10'h000;
					end
				default:
					begin
					end			 
				endcase     

            // Update the figure1's position with its motion
            figure1_X_Pos_in = figure1_X_Pos + figure1_X_Motion;
            figure1_Y_Pos_in = figure1_Y_Pos + figure1_Y_Motion;
			end
    end
endmodule

