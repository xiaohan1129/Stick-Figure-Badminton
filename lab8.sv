//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [7:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6,
				 //output logic [7:0]  LEDG,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
				input AUD_ADCDAT,
				input AUD_DACLRCK,
				input AUD_ADCLRCK,
				input AUD_BCLK,
				output logic AUD_DACDAT,
				output logic AUD_XCK,
				output logic I2C_SCLK,
				output logic I2C_SDAT
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
	 logic [9:0] DrawX,DrawY;
	 //logic is_ball;
    //logic [2047:0] game_file;
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  Reset_game <= ~(KEY[1]);     // Reset the game
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
	logic INIT,data_over,INIT_FINISH;
  logic [16:0]Add;
  logic [16:0]music_content;
  logic adc_full;
	 //------------background------------//
	 logic [2:0]background_data;
    logic is_background;//,background_exist;
	 
	 
	 //------------figure1------------//
	 //logic figure1_exist;
	 logic [9:0]figure1_x,figure1_y;
	 logic [9:0]figure2_x,figure2_y;
	 logic [5:0]figure1_state;
	 logic [5:0]figure2_state;
    logic [2:0]figure1_data;
	 logic [2:0]figure2_data;
    logic is_figure1,is_figure2;
	 
	 logic ball_exist1, ball_shoot1, ball_hit1;
	 logic ball_exist2, ball_shoot2, ball_hit2;	
		//-----------ball------------// 
	 logic is_ball;
	 logic [2:0]ball_data;
	 
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk), 
									  //.game_export_readdata(game_file),
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance( .Clk(Clk),
                                            .Reset(Reset_h),
                                            .VGA_HS(VGA_HS),
                                            .VGA_VS(VGA_VS),
                                            .VGA_CLK(VGA_CLK),
                                            .VGA_BLANK_N(VGA_BLANK_N),
                                            .VGA_SYNC_N(VGA_SYNC_N),
                                            .DrawX(DrawX),
                                            .DrawY(DrawY)
														  );

													
										
	 //------------ball-----------//   
    ball ball( .Clk(Clk),
                        .Reset(Reset_game),
                        .frame_clk(VGA_VS),
                        .keycode(keycode),
                        .DrawX(DrawX),
                        .DrawY(DrawY),
                        .is_ball(is_ball),
								.figure1_x,
								.figure1_y,
								.ball_exist1,
								.ball_shoot1,
								.ball_hit1,
								.ball_data);


	 //------------figure1------------//
	 figure1Motion figure1Motion( .Clk(Clk),
                        .Reset(Reset_game),
                        .frame_clk(VGA_VS),
                        .keycode(keycode),
                        .DrawX(DrawX),
                        .DrawY(DrawY),
                        .figure1_x,
								.figure1_y);	

	 figure1FSM figure1FSM (.Clk,
									.Reset(Reset_h),
									.frame_clk(VGA_VS),
									.keycode,
									.figure1_state,
									.ball_exist1,
									.ball_shoot1,
									.ball_hit1);	//output	
									
	 //------------figure2------------//
	 figure2Motion figure2Motion( .Clk(Clk),
                        .Reset(Reset_game),
                        .frame_clk(VGA_VS),
                        .keycode(keycode),
                        .DrawX(DrawX),
                        .DrawY(DrawY),
                        .figure2_x,
								.figure2_y);	

	 figure2FSM figure2FSM (.Clk,
									.Reset(Reset_h),
									.frame_clk(VGA_VS),
									.keycode,
									.figure2_state,
									.ball_exist2,
									.ball_shoot2,
									.ball_hit2);	//output	



	  figure1 figure1		(.Clk,
                        .DrawX,
                        .DrawY,
								.figure1_x,
								.figure1_y,
								.figure2_x,
								.figure2_y,
								.figure1_state,
								.figure2_state,
								.figure1_data,//output
								.figure2_data,//output
                        .is_figure1, //output
								.is_figure2);//output

//	 //------------basket------------//
//
//	  basket basket (.Clk,
//                        .DrawX,
//                        .DrawY,
//								.basket_x(figure2_x),
//								.basket_y(figure2_y),
//								.basket_data,
//								.is_basket);
								
	 //------------background------------//								
    background background(.Clk,
                        //.background_exist,
                        .DrawX,
                        .DrawY,
                        .background_data, //output
                        .is_background); 		 //output    

									
    color_mapper color_instance(.is_figure1,
								.is_figure2,
								.is_background,
								.figure1_data,
								.figure2_data,
								.ball_data,
                        .background_data,
								.is_ball,
                        .DrawX,
                        .DrawY,
                        .VGA_R,
                        .VGA_G,
                        .VGA_B);		
     
  audio Audio_istance (.*, .Reset(Reset_h));
  
  music music_instance(.*);
  
  audio_interface music ( .LDATA (music_content),
          .RDATA (music_content),
          .Clk(Clk),
          .Reset(Reset_h),
          .INIT(INIT),
          .INIT_FINISH(INIT_FINISH),
          .adc_full (adc_full),
          .data_over(data_over),
          .AUD_MCLK(AUD_XCK),
          .AUD_BCLK(AUD_BCLK),
          .AUD_ADCDAT(AUD_ADCDAT),
          .AUD_DACDAT(AUD_DACDAT),
          .AUD_DACLRCK(AUD_DACLRCK),
          .AUD_ADCLRCK(AUD_ADCLRCK),
          .I2C_SDAT(I2C_SDAT),
          .I2C_SCLK(I2C_SCLK),
          .ADCDATA(ADCDATA),
          
  );								
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule



//module lab8( input               CLOCK_50,
//             input        [3:0]  KEY,          //bit 0 is set up as Reset
//             output logic [6:0]  HEX0, HEX1,
//				 output logic [7:0]  LEDG,
//             // VGA Interface 
//             output logic [7:0]  VGA_R,        //VGA Red
//                                 VGA_G,        //VGA Green
//                                 VGA_B,        //VGA Blue
//             output logic        VGA_CLK,      //VGA Clock
//                                 VGA_SYNC_N,   //VGA Sync signal
//                                 VGA_BLANK_N,  //VGA Blank signal
//                                 VGA_VS,       //VGA virtical sync signal
//                                 VGA_HS,       //VGA horizontal sync signal
//             // CY7C67200 Interface
//             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
//             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
//             output logic        OTG_CS_N,     //CY7C67200 Chip Select
//                                 OTG_RD_N,     //CY7C67200 Write
//                                 OTG_WR_N,     //CY7C67200 Read
//                                 OTG_RST_N,    //CY7C67200 Reset
//             input               OTG_INT,      //CY7C67200 Interrupt
//             // SDRAM Interface for Nios II Software
//             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
//             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
//             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
//             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
//             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
//                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
//                                 DRAM_CKE,     //SDRAM Clock Enable
//                                 DRAM_WE_N,    //SDRAM Write Enable
//                                 DRAM_CS_N,    //SDRAM Chip Select
//                                 DRAM_CLK      //SDRAM Clock
//                    );
//    
//    logic Reset_h, Clk;
//    logic [7:0] keycode;
//	 logic [7:0] led;
//    
//    assign Clk = CLOCK_50;
//    always_ff @ (posedge Clk) begin
//        Reset_h <= ~(KEY[0]);        // The push buttons are active low
//		  LEDG <= led;
//    end
//    
//    logic [1:0] hpi_addr;
//    logic [15:0] hpi_data_in, hpi_data_out;
//    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
//    
//	 logic is_ball;
//	 logic [9:0] DrawX, DrawY;
//    // Interface between NIOS II and EZ-OTG chip
//    hpi_io_intf hpi_io_inst(
//                            .Clk(Clk),
//                            .Reset(Reset_h),
//                            // signals connected to NIOS II
//                            .from_sw_address(hpi_addr),
//                            .from_sw_data_in(hpi_data_in),
//                            .from_sw_data_out(hpi_data_out),
//                            .from_sw_r(hpi_r),
//                            .from_sw_w(hpi_w),
//                            .from_sw_cs(hpi_cs),
//                            .from_sw_reset(hpi_reset),
//                            // signals connected to EZ-OTG chip
//                            .OTG_DATA(OTG_DATA),    
//                            .OTG_ADDR(OTG_ADDR),    
//                            .OTG_RD_N(OTG_RD_N),    
//                            .OTG_WR_N(OTG_WR_N),    
//                            .OTG_CS_N(OTG_CS_N),
//                            .OTG_RST_N(OTG_RST_N)
//    );
//     
//     // You need to make sure that the port names here match the ports in Qsys-generated codes.
//     lab8_soc nios_system(
//                             .clk_clk(Clk),         
//                             .reset_reset_n(1'b1),    // Never reset NIOS
//                             .sdram_wire_addr(DRAM_ADDR), 
//                             .sdram_wire_ba(DRAM_BA),   
//                             .sdram_wire_cas_n(DRAM_CAS_N),
//                             .sdram_wire_cke(DRAM_CKE),  
//                             .sdram_wire_cs_n(DRAM_CS_N), 
//                             .sdram_wire_dq(DRAM_DQ),   
//                             .sdram_wire_dqm(DRAM_DQM),  
//                             .sdram_wire_ras_n(DRAM_RAS_N),
//                             .sdram_wire_we_n(DRAM_WE_N), 
//                             .sdram_clk_clk(DRAM_CLK),
//                             .keycode_export(keycode),  
//                             .otg_hpi_address_export(hpi_addr),
//                             .otg_hpi_data_in_port(hpi_data_in),
//                             .otg_hpi_data_out_port(hpi_data_out),
//                             .otg_hpi_cs_export(hpi_cs),
//                             .otg_hpi_r_export(hpi_r),
//                             .otg_hpi_w_export(hpi_w),
//                             .otg_hpi_reset_export(hpi_reset)
//    );
//
//// Modified :=================================================================================
//    // Use PLL to generate the 25MHZ VGA_CLK.
//    // You will have to generate it on your own in simulation.
//    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
//    
//    // TODO: Fill in the connections for the rest of the modules 
//
//
//    VGA_controller vga_controller_instance(.*, 
//														 .Reset(Reset_h),);
//    // Which signal should be frame_clk?
//    ball ball_instance(.*,
//							  .Reset(Reset_h),
//							  .frame_clk(VGA_VS));	// VGA_VS should be frame_clk
//    
//    color_mapper color_instance(.*); // ".*" means that all the ports' names and the variable names they connects are the same
//										  
//										  
//    // Display keycode on hex display
//    HexDriver hex_inst_0 (keycode[3:0], HEX0);
//    HexDriver hex_inst_1 (keycode[7:4], HEX1);
//	 
//	 always_comb
//    begin
//	   // default case
//	   led = 8'b0000;
//		case(keycode)
//					// key A, use h04 to represent
//					8'h04: 
//					begin
//						led = 8'b0010;
//					end
//							
//					// key D, use h07 to represent
//					8'h07: 
//					begin
//						led = 8'b0001;
//					end
//					
//					// key W, use h1a to represent
//					8'h1a: 
//					begin
//						led = 8'b1000;
//					end
//					
//					// key S, use h16 to represent
//					8'h16: 
//					begin
//						led = 8'b0100;
//					end
//					default:;
//					// The sequence of the LED will be WSAD.
//		endcase
//    end
//// Modified :=================================================================================
//    /**************************************************************************************
//        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//        Hidden Question #1/2:
//        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
//             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
//    **************************************************************************************/
//endmodule
