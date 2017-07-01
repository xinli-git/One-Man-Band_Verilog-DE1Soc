module FinalProjectFSM (
	input CLOCK_50,
	input [7:0] keyboard_data,
	input data_received_en,
	input resetn,
	
   output [31:0] Amplitude
);

	main u0(
        .CLOCK_50(CLOCK_50),
        .resetn(resetn),
        .keyboard_data(keyboard_data),
        .data_received_en(data_received_en),
        .Amplitude(Amplitude)
    );

endmodule

module main (

	input CLOCK_50,
	input resetn,
	input [7:0] keyboard_data,
	input data_received_en,
	output [31:0] Amplitude

);

    
    wire ld_a, ld_b, ld_c, ld_d;


    control C0(
        .CLOCK_50(CLOCK_50),
        .resetn(resetn),
        .keyboard_data(keyboard_data),
		  .data_received_en(data_received_en),

        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c),
		  .ld_d(ld_d)
    );

    datapath D0(
        .CLOCK_50(CLOCK_50),
        .resetn(resetn),

        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c), 
		  .ld_d(ld_d),
        .Amplitude(Amplitude)
    );



endmodule

module control (
	input CLOCK_50,
	input [7:0] keyboard_data,
	input data_received_en,
	input resetn,
	
	output reg  ld_a, ld_b, ld_c, ld_d
);

	reg [3:0] current_state, next_state; 
    
    localparam  S_INITIAL     = 4'd3,
					 S_MAKE        = 4'd0,	// when the keyboard is pressed and data loaded in periodically
                S_BREAK_ONE   = 4'd1,	// Break is first inputted
                S_BREAK_TWO   = 4'd2;	// The signal that follows immediately is loaded
	
	
	always @(*)
    begin: state_table 
            case (current_state)
					 S_INITIAL: next_state = data_received_en ? S_MAKE : S_INITIAL;
                S_MAKE: next_state = (keyboard_data == 8'hF0) ? S_BREAK_ONE : S_MAKE;
                S_BREAK_ONE: next_state = (keyboard_data == 8'hF0) ? S_BREAK_ONE : S_BREAK_TWO; 
					 S_BREAK_TWO: next_state = data_received_en ? S_INITIAL : S_BREAK_TWO;
            default:     next_state = S_INITIAL;
        endcase
    end // state_table
   

    
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_a = 1'b0;
		  ld_b = 1'b0;
		  ld_c = 1'b0;
		  ld_d = 1'b0;
		
        case (current_state)
            S_MAKE: begin
                ld_a = 1'b1; 
					 ld_b = 1'b0;
		          ld_c = 1'b0;
                end
				S_BREAK_ONE: begin
                ld_a = 1'b0; 
					 ld_b = 1'b1;
		          ld_c = 1'b0;
					 end 
            S_BREAK_TWO: begin	
                ld_a = 1'b0; 
					 ld_b = 1'b0;
		          ld_c = 1'b1;
					 end   
			   S_INITIAL: begin
				    ld_a = 1'b0; 
					 ld_b = 1'b0;
		          ld_c = 1'b0;
					 ld_d = 1'b1;
					 end   
				
				
        endcase
    end // enable_signals

	 // current_state registers
    always@(posedge CLOCK_50)
    begin: state_FFs
        if(!resetn)
            current_state <= S_INITIAL;
        else
            current_state <= next_state;
    end // state_FFS
	
endmodule



module datapath (

	 input CLOCK_50,
    input resetn,
    
    input ld_a, ld_b, ld_c, ld_d,
    
	 output reg [31:0] Amplitude

);


    always@(posedge CLOCK_50) begin
        if(!resetn) begin
            Amplitude<= 32'd0; 
        end
        else begin
            if(ld_a)
                Amplitude <= 32'd5000000; 
            if(ld_b)
                Amplitude <= 32'd0; 
            if(ld_c)
                Amplitude <= 32'd0; 
				if(ld_d)
                Amplitude <= 32'd0; 	 
			end
end
endmodule
