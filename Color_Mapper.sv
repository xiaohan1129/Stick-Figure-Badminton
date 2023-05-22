//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper (	input logic Clk,
								input logic [2:0]background_data,
								input logic [2:0]figure1_data, figure2_data, ball_data, //basket_data,
								input       is_figure1, is_figure2, //is_basket,    // Whether current pixel belongs to figure	
								input			is_background,
								input			is_ball,
								input        [9:0] DrawX, DrawY,       // Current pixel coordinates
								output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );	
    
    logic [7:0] Red, Green, Blue;
	 logic [23:0] background_color,figure1_color, figure2_color, ball_color;//basket_color, 
	 logic [23:0] color;
	 
	 //----------------color palette----------------//
	 logic [23:0] background_palette [0:7];
	 logic [23:0] figure1_palette[0:7];
	 
	 assign background_palette = '{24'hffffff, 24'h78837b, 24'h474d4b, 24'h454b47, 
											 24'h986120, 24'he6aa54, 24'h297ba2, 24'h00537e};
											 // '0xffffff', '0x78837b', '0x474d4b', '0x454b47', '0x986120', '0xe6aa54', '0x297ba2', '0x00537e'
	 
	 
	 assign figure1_palette = '{24'h000000, 24'hffffff, 24'hdcddd8, 24'h545e5f, 
										 24'h5b6161, 24'heae9e5, 24'h973b2e, 24'ha2272c};
										   //  black       white       grey                                             red
										   // '0x000000', '0xffffff', '0xdcddd8', '0x545e5f', '0x5b6161', '0xeae9e5' , '0x973b2e', '0xa2272c'

	 assign background_color = background_palette[background_data];
	 assign figure1_color = figure1_palette[figure1_data];
	 assign figure2_color = figure1_palette[figure2_data];
	 assign ball_color = figure1_palette[ball_data];
    
    // Output colors to VGA
    assign VGA_R = color[23:16];
    assign VGA_G = color[15:8];
    assign VGA_B = color[7:0];
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_figure1 == 1'b1 && figure1_color != 24'hFFFFFF ) 
        begin
				color = figure1_color;
        end
        else if (is_figure2 == 1'b1 && figure2_color != 24'hFFFFFF ) 
        begin
				color = figure2_color;
        end	
		  else if ( is_ball == 1'b1 && ball_color != 24'hFFFFFF)
		  begin
				color = ball_color;
		  end
		  else if ( is_background == 1'b1)
		  begin
				color = background_color;
		  end
        else 
        begin
				color = 24'h00FF00;				
        end
    end    
endmodule
