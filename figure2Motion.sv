module  figure2Motion ( 
					input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [7:0]	  keycode,				 // keyboard press
					output logic [9:0] figure2_x,
					output logic [9:0] figure2_y
              );


	parameter [9:0] figure2_X_Center = 10'd480;  // Start X position
   parameter [9:0] figure2_Y_Center = 10'd360;  // Start Y position
	// motion range
   parameter [9:0] figure2_X_Min = 10'd340;       // Leftmost point on the X axis
   parameter [9:0] figure2_X_Max = 10'd639;     // Rightmost point on the X axis	
   parameter [9:0] figure2_Y_Min = 10'd0;       // Topmost point on the Y axis
   parameter [9:0] figure2_Y_Max = 10'd440;     // Bottommost point on the Y axis
	// motion step
   parameter [9:0] figure2_X_Step = 10'd1;      // Step size on the X axis
   parameter [9:0] figure2_Y_Step = 10'd1;      // Step size on the Y axis
	
    logic [9:0] figure2_X_Pos, figure2_X_Motion, figure2_Y_Pos, figure2_Y_Motion;
    logic [9:0] figure2_X_Pos_in, figure2_Y_Pos_in; 


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
            figure2_X_Pos <= figure2_X_Center;
            figure2_Y_Pos <= figure2_Y_Center;
        end
        else
        begin
            figure2_X_Pos <= figure2_X_Pos_in;
            figure2_Y_Pos <= figure2_Y_Pos_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.	 
	 
	 always_comb
    begin
        // By default, keep motion and position unchanged
        figure2_X_Pos_in = figure2_X_Pos;
        figure2_Y_Pos_in = figure2_Y_Pos;
		  figure2_x = figure2_X_Pos;
		  figure2_y = figure2_Y_Pos; 
		  figure2_X_Motion = 10'd0;
        figure2_Y_Motion = 10'd0;
		  
     // Update position and motion only at rising edge of frame clockv
        if (frame_clk_rising_edge)
        begin
			 case(keycode)
				8'h50: // <-: Go left
					begin
					   figure2_X_Motion = (~(figure2_X_Step) + 1'b1);
						figure2_Y_Motion = 10'h000;
					end 
				8'h4F: // ->: Go right
					begin
						figure2_X_Motion = figure2_X_Step;
						figure2_Y_Motion = 10'h000;
					end
				8'h52: // ^: Jump not use now
					begin
						figure2_Y_Motion = 10'h000;//(~(figure2_Y_Step) + 1'b1);
						figure2_X_Motion = 10'h000;
					end
				8'h51: // V: Hit
					begin
						figure2_Y_Motion = 10'h000;//figure2_Y_Step;
						figure2_X_Motion = 10'h000;
					end
				default:
					begin
					end			 
				endcase  
   
            // Update the figure2's position with its motion
            figure2_X_Pos_in = figure2_X_Pos + figure2_X_Motion;
            figure2_Y_Pos_in = figure2_Y_Pos + figure2_Y_Motion;
			end
    end
endmodule

