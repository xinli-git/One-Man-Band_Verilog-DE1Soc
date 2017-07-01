//last visit 6 57 26th
module FinalProject (SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5  , LEDR,KEY, CLOCK_50, 
PS2_CLK, PS2_DAT,
VGA_CLK,         // VGA Clock
VGA_HS,       // VGA H_SYNC
VGA_VS,       // VGA V_SYNC
VGA_BLANK_N,     // VGA BLANK
VGA_SYNC_N,      // VGA SYNC
VGA_R,         // VGA Red[9:0]
VGA_G,        // VGA Green[9:0]
VGA_B,        	// VGA Blue[9:0]

AUD_ADCDAT,
AUD_BCLK,
AUD_ADCLRCK,
AUD_DACLRCK,
I2C_SDAT,
AUD_XCK,
AUD_DACDAT,
I2C_SCLK
);


	/*	
Audio_Final A1 (

// Inputs
	.CLOCK_50(CLOCK_50),
	.KEY(KEY[2]),

	.AUD_ADCDAT(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),
	
	
	
	//We don't have left or right channel_audio_out; This is neede to input from the RAM.

	.I2C_SDAT(I2C_SDAT),

	// Outputs
	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT),

	.I2C_SCLK(I2C_SCLK),
	.SW(SW[3:0])
); 

*/




//Conventional inputs&outputs
input [9:0] SW;
input [3:0] KEY;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
output [9:0] LEDR;
input CLOCK_50;

//VGA inputs&outputs
output   VGA_CLK;       // VGA Clock
output   VGA_HS;      // VGA H_SYNC
output   VGA_VS;      // VGA V_SYNC
output   VGA_BLANK_N;    // VGA BLANK
output   VGA_SYNC_N;    // VGA SYNC
output [9:0]VGA_R;        // VGA Red[9:0]
output [9:0]VGA_G;       // VGA Green[9:0]
output [9:0]VGA_B;        // VGA Blue[9:0]

//Audio inputs&outputs
input				AUD_ADCDAT;
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;
inout				I2C_SDAT;
output				AUD_XCK;
output				AUD_DACDAT;
output				I2C_SCLK;

//Keyboard inputs&outputs
inout PS2_CLK;
inout PS2_DAT;

hex_decoder h0 (keyboard_data[3:0], HEX0);
hex_decoder h1 (keyboard_data[7:4], HEX1);

hex_decoder h2 (audio_address[15:12], HEX2); //This is used to display the time progression of the 16seconds counter
hex_decoder h3 (0, HEX3);

reg [7:0] loopcount;
hex_decoder h4 (loopcount [3:0],HEX4);
hex_decoder h5 ( loopcount[7:4] ,HEX5); 



assign LEDR[9]=1;
assign LEDR[8]=(audio_address>16'd8192*0)? 1:0;
assign LEDR[7]=(audio_address>16'd8192*1)? 1:0;
assign LEDR[6]=(audio_address>16'd8192*2)? 1:0;
assign LEDR[5]=(audio_address>16'd8192*3)? 1:0;
assign LEDR[4]=(audio_address>16'd8192*4)? 1:0;
assign LEDR[3]=(audio_address>16'd8192*5)? 1:0;
assign LEDR[2]=(audio_address>16'd8192*6)? 1:0;
assign LEDR[1]=(audio_address>16'd8192*7)? 1:0;
assign LEDR[0]=0;
//PS2_Controller should be instantiated in the toplevel function

wire [7:0] the_command;
wire send_command, command_was_sent, error_communication_timed_out, received_data_en;
wire [7:0] keyboard_data;

PS2_Controller ps0(.CLOCK_50(CLOCK_50),
						.reset(~KEY[0]),
						.the_command(the_command),
						.send_command(send_command),
						.command_was_sent(command_was_sent),
						.error_communication_timed_out(error_communication_timed_out),
						.received_data_en(received_data_en),
						.received_data(keyboard_data),
						.PS2_CLK(PS2_CLK),
						.PS2_DAT(PS2_DAT));				

	
//VGAdisplay should be in the top level module
	
wire [2:0] color;
wire [7:0] coord_x; 
wire [7:0] coord_y;
wire writeEn;  







							
					
			
//////////////////////////

wire Activation; //good stuff

////////////////////////////
							wire [31:0]    to_audio;
							wire 				read_audio_in;
							wire				audio_in_available;
							wire				write_audio_out;
							wire				audio_out_allowed;


							wire [31:0] left_channel_audio_in;
							wire [31:0] right_channel_audio_in;

							wire [31:0]	left_channel_audio_out; 
							wire[31:0]	right_channel_audio_out;

							wire [19:0] delay;
							reg  [19:0] delaycount=0;
							reg   turn=0;


							prepare_frequency pf0(keyboard_data, delay); //Transfers different keyboard input into different frequencies of sounds

							assign read_audio_in			= audio_in_available & audio_out_allowed;
							assign write_audio_out			= audio_in_available & audio_out_allowed;

							
							
							assign left_channel_audio_out	= (Activation == 1 /*&&left_channel_audio_out>32'd5000000*/) ? left_channel_audio_in + AudioLeft : 0;
							assign right_channel_audio_out = (Activation == 1/*&&right_channel_audio_out>32'd000000*/) ? right_channel_audio_in+ AudioRight : 0;
					
				
				
							Audio_Controller Audio_Controller (		
							// Inputs
							.CLOCK_50						(CLOCK_50),
							.reset						(~KEY[2]),

							.clear_audio_in_memory		(),
							.read_audio_in				(read_audio_in),
	
							.clear_audio_out_memory		(),
							.left_channel_audio_out		(left_channel_audio_out),
							.right_channel_audio_out	(right_channel_audio_out),
							.write_audio_out			(write_audio_out),

							.AUD_ADCDAT					(AUD_ADCDAT),

							// Bidirectionals
							.AUD_BCLK					(AUD_BCLK),
							.AUD_ADCLRCK				(AUD_ADCLRCK),
							.AUD_DACLRCK				(AUD_DACLRCK),


							// Outputs
							.audio_in_available			(audio_in_available),
							.left_channel_audio_in		(left_channel_audio_in),
							.right_channel_audio_in		(right_channel_audio_in),

							.audio_out_allowed			(audio_out_allowed),
	
							.AUD_XCK						(AUD_XCK),
							.AUD_DACDAT					(AUD_DACDAT)

							);  
					
					
							//***************************responsible for play balck constantly******************************


							wire record_clock;
							reg storeEn = 0;
							reg storeEnK = 0;
							reg [1:0] muxSignal;
							reg [15:0] audio_address ;

							record_clock c1 (~KEY[2], CLOCK_50, record_clock);
							always @ (posedge CLOCK_50 && Activation)
							begin

							if (!KEY[2] )
							begin
							audio_address<=0;
							loopcount<=0;
							
							end
							
							else if (audio_address == 16'b1111111111111111)
							begin
							loopcount<=loopcount+1;
							audio_address<=0;
							end
							else if (record_clock)

							begin

							audio_address<=audio_address+1;
							end

							else

							begin
							audio_address<=audio_address;

							end

							end




							wire [31:0] playback_audio;

							reg [33:0] counter32;
							always @ (posedge CLOCK_50 && Activation)  //32 sec counter
							begin

							if (!KEY[2])
							begin
							counter32<=0;
							storeEn<=0;
							storeEnK <=1;
							muxSignal <= 2'b00;
							
							end

							 else if( counter32==34'd800000000)

							begin
							storeEn<=1;
							storeEnK <=0;
							muxSignal <= 2'b01;
							counter32 <= counter32 + 1;
						

							end


							else if( counter32 ==34'd1600000000)
							begin
							storeEn <=0;
							storeEnK <=0;
							counter32 <= counter32;
							muxSignal <= 2'b10;

							end

							else
							begin

							counter32 <= counter32 + 1;
							muxSignal <= muxSignal;

							end

							end


							reg [2:0] threeBitAmplitude;

							always @ (*) begin
								case (to_audio)


									32'd5000000: threeBitAmplitude = 3'b000;
									-32'd5000000: threeBitAmplitude = 3'b001;
									32'd10000000: threeBitAmplitude = 3'b010;
									-32'd10000000: threeBitAmplitude = 3'b011;
									32'd0: threeBitAmplitude = 3'b111;
									default: threeBitAmplitude = 3'b111;
								endcase
							end



							audio_bank mic_music (audio_address, CLOCK_50, right_channel_audio_out, storeEn, playback_audio);

							Keyboard_bank keyboard_music (audio_address, CLOCK_50, threeBitAmplitude, storeEnK, threeBitPlayback_audio);


							wire [2:0] threeBitPlayback_audio;

							reg [31:0] leftChannelPlayBack;


							always @ (*) begin
								case (threeBitPlayback_audio)

									3'b000: leftChannelPlayBack = 32'd5000000;
									3'b001: leftChannelPlayBack = -32'd5000000;
									3'b010: leftChannelPlayBack = 32'd10000000;
									3'b011: leftChannelPlayBack = -32'd10000000;
									3'b111: leftChannelPlayBack = 32'd0;
									default:leftChannelPlayBack = 32'd0;

								endcase
							end
						
					
							FinalProjectFSM FSM(CLOCK_50, keyboard_data, received_data_en, KEY[2], Amplitude);
							
							 wire [31:0] Amplitude;
							 
							 
							 assign to_audio =  turn ? volume : -volume;

							reg [32:0] volume;
							always @ (*)
							begin 
							if (keyboard_data==8'h1A ||keyboard_data==8'h22 ||keyboard_data==8'h29 || keyboard_data==8'h21)
							volume = Amplitude+Amplitude;

							else if (  keyboard_data==8'h15 ||keyboard_data==8'h1D  ||keyboard_data==8'h24 ||keyboard_data==8'h2D||keyboard_data==8'h2C
										||keyboard_data==8'h35||keyboard_data==8'h3C||keyboard_data==8'h43||keyboard_data==8'h44||keyboard_data==8'h4D
										||keyboard_data==8'h54||keyboard_data==8'h4B||keyboard_data==8'h42||keyboard_data==8'h3B||keyboard_data==8'h33
										||keyboard_data==8'h5B||keyboard_data==8'h71||keyboard_data==8'h69||keyboard_data==8'h7A||keyboard_data==8'h52
										||keyboard_data==8'h4C||keyboard_data==8'h34||keyboard_data==8'h2B||keyboard_data==8'h23||keyboard_data==8'h1B
										||keyboard_data==8'h1C||keyboard_data==8'h5A)
													

							 volume =Amplitude;
							 else volume =0;
							end


							reg [31:0] AudioLeft;
							reg [31:0] AudioRight;



							always @ (*)
							begin
								case (muxSignal)
								
								2'b00: begin
										 AudioLeft = to_audio;
										 AudioRight = to_audio;
										 end
								2'b01: begin
										 AudioLeft = leftChannelPlayBack;
										 AudioRight = to_audio;
										 end
								2'b10: begin
										 AudioLeft = leftChannelPlayBack;
										 AudioRight = playback_audio;
										 end
								default:begin
											AudioLeft = AudioLeft;
											AudioRight = AudioRight;
											end


								endcase
							end
												
							always @ (posedge CLOCK_50) begin 
							  
							 
							  
							  if (delaycount==delay || !KEY[2])
							  begin

							  delaycount<=0;
							  turn <= !turn;
							  
							  end
							  
							  else
							 
							  delaycount<=delaycount + 1'b1;
							  
							  end				





//This if the VGA for the display
vgaDisplay v0 (keyboard_data, received_data_en, coord_x, coord_y, color, CLOCK_50, KEY[1], writeEn);


vga_adapter VGA(
   .resetn(KEY[1]),
   .clock(CLOCK_50),
   .colour(color),
   .x(coord_x),
   .y(coord_y),
   .plot(writeEn),
   /* Signals for the DAC to drive the monitor. */
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_BLANK(VGA_BLANK_N),
   .VGA_SYNC(VGA_SYNC_N),
   .VGA_CLK(VGA_CLK));
			
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
  defparam VGA.BACKGROUND_IMAGE = "back.mif";
  


mainControl (
	.CLOCK_50(CLOCK_50),
	.keyboard_data(keyboard_data),
	.data_received_en(received_data_en),
	.resetn(KEY[2]),
	
	.ld_a(ld_a),
   .ld_b(ld_b),
   .ld_c(ld_c), 
	.ld_d(ld_d),
	.ld_e(ld_e),
   .ld_f(ld_f), 
	.ld_g(ld_g)
	

);
  
wire ld_a, ld_b, ld_c, ld_d,ld_e, ld_f, ld_g;


mainDatapath (
	.CLOCK_50(CLOCK_50),

	.resetn(KEY[2]),


	.ld_a(ld_a),
   .ld_b(ld_b),
   .ld_c(ld_c), 
	.ld_d(ld_d),
	.ld_e(ld_e),
   .ld_f(ld_f), 
	.ld_g(ld_g),
	
	.Activation(Activation)


); 
endmodule



module mainDatapath (

	 input CLOCK_50,
    input resetn,

    input ld_a, ld_b, ld_c, ld_d, ld_e, ld_f, ld_g,
	
		output reg Activation
);


    always@(posedge CLOCK_50) begin
        if(!resetn) 
			
		  begin
            Activation <=0;
				
        end
		  
		  
        else begin
            if(ld_a)
					begin
					Activation <=0;
					end
            if(ld_b)
                begin
					Activation <=0;
					end
            if(ld_c)
                 begin
					Activation <=0;
					end
				if(ld_d)
				begin
					Activation <=0;
					end
				if(ld_e)
                begin
					Activation <=0;
					end
            if(ld_f)
                 begin
					Activation <=0;
					end
            if(ld_g) /*This is when the official function of the One Man Band machine commences */
					
					begin 
							
							
					Activation <=1;		
					
					end
                	 
			end
end
endmodule



module mainControl (
	input CLOCK_50,
	input [7:0] keyboard_data,
	input data_received_en,
	input resetn,
	
	output reg  ld_a, ld_b, ld_c, ld_d,ld_e, ld_f, ld_g
);

	reg [3:0] current_state, next_state; 
    
    localparam  S_START       = 4'd0,
					 S_STARTWAITONE= 4'd1,	
					 S_STARTWAITTWO= 4'd2,
                S_INTRO       = 4'd3,	
                S_INTROWAITONE  = 4'd4,
					 S_INTROWAITTWO  = 4'd5,
					 S_NOTEPLAY    = 4'd6;//Heading into the playing notes section 
	
	always @(*)
    begin: state_table 
            case (current_state)
				
					 S_START: next_state = data_received_en ? S_STARTWAITONE : S_START;
                S_STARTWAITONE: next_state = (keyboard_data == 8'hF0) ? S_STARTWAITTWO : S_STARTWAITONE;
					 S_STARTWAITTWO: next_state = data_received_en ? S_INTRO : S_STARTWAITTWO;
					 
                S_INTRO: next_state = data_received_en ? S_INTROWAITONE : S_INTRO; 
					 S_INTROWAITONE: next_state = (keyboard_data == 8'hF0) ? S_INTROWAITTWO : S_INTROWAITONE;
					 S_INTROWAITTWO: next_state = data_received_en ? S_NOTEPLAY : S_INTROWAITTWO;
					 
					 S_NOTEPLAY: next_state = !resetn ? S_START : S_NOTEPLAY;
					 
            default:     next_state = S_START;
        endcase
    end // state_table
   

    
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_a = 1'b0;
		  ld_b = 1'b0;
		  ld_c = 1'b0;
		  ld_d = 1'b0;
		  ld_e = 1'b0;
		  ld_f = 1'b0;
		  ld_g = 1'b0;
		
        case (current_state)
            S_START: begin
                ld_a = 1'b1; 
                end
				S_STARTWAITONE: begin
   
					 ld_b = 1'b1;
		       
					 end 
            S_STARTWAITTWO: begin	
                
		          ld_c = 1'b1;
					 end   
			   S_INTRO: begin
				    
					 ld_d = 1'b1;
					 end   
			   S_INTROWAITONE: begin
				    
					 ld_e = 1'b1;
					 end 
				S_INTROWAITTWO: begin
				    
					 ld_f = 1'b1;
					 end 
				S_NOTEPLAY: begin
				    
					 ld_g = 1'b1;
					 end
				
				
        endcase
    end // enable_signals

	 // current_state registers
    always@(posedge CLOCK_50)
    begin: state_FFs
        if(!resetn)
            current_state <= S_START;
        else
            current_state <= next_state;
    end // state_FFS
	
endmodule















module record_clock (reset, CLOCK_50, out_clock);
input reset;
input CLOCK_50;
output  out_clock;
reg [25:0] count1=0;
assign out_clock=(count1==26'd12207) ? 1'b1 : 1'b0;
always @ (posedge CLOCK_50)
begin
//if (reset)
//count1<=0;
 if (out_clock)
count1<=0;
else 
count1<=count1+1;
end



endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule


