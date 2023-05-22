module figure1FSM(input      Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					 input [7:0]   keycode,
					 output	[5:0] figure1_state,
					 output logic ball_exist1,
					 output logic ball_shoot1,
					 output logic ball_hit1);
					 
	 //logic frame_clk_delayed, frame_clk_rising_edge;
	 logic [5:0] counter,inner_counter;
	 logic set_zero;
	 
	 
	 enum logic [4:0] { S1, S2, S3, S4, S5, S6, S7,
	                    W, H1, H2, H3, H4, H5, 
							  SR1, SR2, SR3, SL1, SL2, SL3,
							  MR1, MR2, MR3, ML1, ML2, ML3} State, Next_state;   // Internal state logic
	 
	always_ff @ (posedge frame_clk) 
	begin
		counter<=inner_counter;
		if(set_zero)
		counter<=6'b0;
	end 
		
	always_comb
	begin
		inner_counter=counter+1;
	end
	 
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= S1;
		else 
			State <= Next_state;
	end	 

	always_ff @ (posedge frame_clk)
	begin 	 
		set_zero=1'b0;
		// Default next state is staying at current state
		Next_state = State;
		unique case (State)
			S1 : 
				case(keycode)
					8'h04: // A: Go left
						Next_state = SL1;
					8'h07: // D: Go right
						Next_state = SR1;
					8'h16: // S: Hit
						Next_state = S2;						
					default : 
						Next_state = S1;
				endcase
			S2 :
				Next_state = S3;						
			S3 :
				Next_state = S4;
			S4 :
				Next_state = S5;
			S5 :
				Next_state = S6;
			S6 :
				Next_state = S7;
			S7 :
				Next_state = W;
			W :
				case(keycode)
					8'h04: // A: Go left
						Next_state = ML1;
					8'h07: // D: Go right
						Next_state = MR1;
					8'h16: // S: Hit
						Next_state = H1;
					default : 
						Next_state = W;
				endcase
			H1 :
				Next_state = H2;
			H2 :
				Next_state = H3;
			H3 :
				Next_state = H4;
			H4 :
				Next_state = H5;
			H5 :
				Next_state = W;
			SR1 :
				Next_state = SR2;
			SR2 :
				Next_state = SR3;
			SR3 :
				Next_state = S1;
			SL1 :
				Next_state = SL2;		
			SL2 :
				Next_state = SL3;
			SL3 :
				Next_state = S1;
			MR1 :
				Next_state = MR2;
			MR2 :
				Next_state = MR3;
			MR3 :
				Next_state = W;
			ML1 :
				Next_state = ML2;
			ML2 :
				Next_state = ML3;
			ML3 :
				Next_state = W;
			default : 
				Next_state = State; 
		endcase
	
	
		// Assign control signals based on current state
		case (State)
			S1 : 
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd0;
				end			
			S2 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd1;
				end
			S3 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd2;
				end
			S4 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b1;
				figure1_state = 10'd3;
				end
			S5 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd4;
				end
			S6 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd5;
				end
			S7 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd6;
				end
			W :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd7;
				end
			H1 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b1;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd8;
				end
			H2 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b1;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd9;
				end
			H3 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b1;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd10;
				end
			H4 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd9;
				end
			H5 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd8;
				end
			SR1 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd14;
				end
			SR2 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd16;
				end
			SR3 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd15;
				end
			SL1 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd15;
				end
			SL2 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd16;
				end
			SL3 :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd14;
				end
			MR1 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd11;
				end
			MR2 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd12;
				end
			MR3 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd13;
				end
			ML1 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd13;
				end
			ML2 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd12;
				end
			ML3 :
				begin
				ball_exist1 = 1'b1;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd11;
				end
			default :
				begin
				ball_exist1 = 1'b0;
				ball_hit1 = 1'b0;
				ball_shoot1 = 1'b0;
				figure1_state = 10'd0;
				end
		endcase
	end
endmodule
