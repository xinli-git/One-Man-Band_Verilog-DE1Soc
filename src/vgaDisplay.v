module vgaDisplay (keyboard, keyboard_en, x, y, colour, CLOCK_50, reset, writeEn);

input CLOCK_50;
input reset;
input [7:0] keyboard;
input keyboard_en;

output [2:0] colour;
output  [7:0] x;
output  [7:0] y;
output writeEn;


wire [4:0] selectRom;


controlvga c0 (keyboard, keyboard_en, writeEn, reset,  CLOCK_50, selectRom);

datapathvga d0 (CLOCK_50, selectRom, reset, colour, x, y);





endmodule





module controlvga (keyboard, keyboard_en, writeEn, reset,  CLOCK_50, selectRom);

input [7:0] keyboard;
input keyboard_en;
input CLOCK_50;
input reset;

output reg writeEn;
//output draw;
output reg [4:0] selectRom;







reg [3:0] current_state, next_state;

localparam 
					START =          4'd0,
					STARTWAIT= 		  4'd4,
					STARTWAITTWO=		  4'd6,
					INTRO =          4'd1,
					INTROWAIT=       4'd5,
					INTROWAITTWO=		  4'd7,
					DRAW_NOTE  =     4'd2,
					DRAW_PLAY =      4'd3,
					//DRAW_NOTE_WAIT = 4'd8;
					DRAW_PLAY_WAIT = 4'd9;
						
always @ (*) begin: statetable
		
		case (current_state)
		
		START: next_state = keyboard_en ? STARTWAIT : START;
               
	  	 STARTWAIT: next_state = (keyboard == 8'hF0) ? STARTWAITTWO : STARTWAIT;
		
    	 STARTWAITTWO: next_state = keyboard_en ? INTRO : STARTWAITTWO;
					 
       INTRO: next_state = keyboard_en ? INTROWAIT : INTRO; 
		
		 INTROWAIT: next_state = (keyboard == 8'hF0) ? INTROWAITTWO : INTROWAIT;
		
		 INTROWAITTWO: next_state = keyboard_en ? DRAW_PLAY : INTROWAITTWO;
		 
		 
		 DRAW_PLAY: next_state = keyboard_en? DRAW_NOTE : DRAW_PLAY;
		
		
		 DRAW_NOTE: next_state = (keyboard==8'hF0)? DRAW_PLAY_WAIT : DRAW_NOTE;
		 
		 DRAW_PLAY_WAIT : next_state = keyboard_en? DRAW_PLAY : DRAW_PLAY_WAIT;
		
		 
		
		
		default: 	next_state= START;
		endcase
		end
		
		
always @ (*)begin: enables

writeEn=0;
selectRom = 0;

case (current_state)

START:
begin
selectRom=5'd0;
writeEn=1; 
end


STARTWAIT:
begin
selectRom=5'd0;
writeEn=1; //nothing to be done
end


STARTWAITTWO:
;

INTRO: begin 
selectRom=5'd1;
writeEn=1;
end

INTROWAIT:begin 
selectRom=5'd1;
writeEn=1;
end


INTROWAITTWO:
begin
selectRom=5'd2;
writeEn=1;
end

DRAW_PLAY:begin 
selectRom=5'd2;
writeEn=1;
end

DRAW_PLAY_WAIT:
begin
writeEn=1;

case (keyboard)
//A to pagedown
 8'h1C:selectRom=5'd3;
 8'h1B:selectRom=5'd4;
 8'h23:selectRom=5'd5;
 8'h2B:selectRom=5'd6;
 8'h34:selectRom=5'd7;
 8'h33:selectRom=5'd8;
 8'h3B:selectRom=5'd9;
 8'h42:selectRom=5'd10;
 8'h4B:selectRom=5'd11;
 8'h4C:selectRom=5'd12;
 8'h52:selectRom=5'd13;
 8'h15:selectRom=5'd14;
 8'h1D:selectRom=5'd15;
 8'h24:selectRom=5'd16;
 8'h2D:selectRom=5'd17;
 8'h2C:selectRom=5'd18;
 8'h35:selectRom=5'd19;
 8'h3C:selectRom=5'd20;
 8'h43:selectRom=5'd21;
 8'h44:selectRom=5'd22;
 8'h4D:selectRom=5'd23;
 8'h54:selectRom=5'd24;
 8'h5B:selectRom=5'd25;
 8'h71:selectRom=5'd26;
 8'h69:selectRom=5'd27;
 8'h7A:selectRom=5'd28;
 
 //zx
 8'h1A:selectRom=5'd29;
 8'h22:selectRom=5'd30;
 
 
 //space
 8'h19:selectRom=5'd31;
 
 default:selectRom=5'd2;

endcase
end


DRAW_NOTE:
begin
writeEn=1;

case (keyboard)
//A to pagedown
 8'h1C:selectRom=5'd3;
 8'h1B:selectRom=5'd4;
 8'h23:selectRom=5'd5;
 8'h2B:selectRom=5'd6;
 8'h34:selectRom=5'd7;
 8'h33:selectRom=5'd8;
 8'h3B:selectRom=5'd9;
 8'h42:selectRom=5'd10;
 8'h4B:selectRom=5'd11;
 8'h4C:selectRom=5'd12;
 8'h52:selectRom=5'd13;
 8'h15:selectRom=5'd14;
 8'h1D:selectRom=5'd15;
 8'h24:selectRom=5'd16;
 8'h2D:selectRom=5'd17;
 8'h2C:selectRom=5'd18;
 8'h35:selectRom=5'd19;
 8'h3C:selectRom=5'd20;
 8'h43:selectRom=5'd21;
 8'h44:selectRom=5'd22;
 8'h4D:selectRom=5'd23;
 8'h54:selectRom=5'd24;
 8'h5B:selectRom=5'd25;
 8'h71:selectRom=5'd26;
 8'h69:selectRom=5'd27;
 8'h7A:selectRom=5'd28;
 
 //zxc
 8'h1A:selectRom=5'd29;
 8'h22:selectRom=5'd30;
 
 
 //space
 8'h29:selectRom=5'd31;
 
 default:selectRom=5'd2;

endcase


end

default: begin
;
end

endcase
end


		
		
		



always@(posedge CLOCK_50)	//JUST STATE FLIP FLOPS
    begin: state_FFs
        if(!reset)
            current_state <= START;
        else
            current_state <= next_state;
    end // state_FFS
	 
	 

endmodule


module datapathvga (CLOCK_50, selectRom, reset, colour, x, y);


input [4:0] selectRom;
input reset;
input CLOCK_50;

output reg [2:0] colour;
output reg  [7:0] x;
output  reg[7:0] y;
 

reg [14:0] VGA_counter;

reg draw;

always @ (posedge CLOCK_50)begin 

if (!reset)
begin

x<=0;
y<=0;
end

else if (x==8'd160)

begin
x<=0;
y<=y+1;
end

else if (y==8'd120)
y<=0;

else 
begin

x<=x+1'b1;

end

end


wire [2:0] colour_start;
wire [2:0] colour_intro;
wire [2:0] colour_play;
wire [2:0] colour_a;
wire [2:0] colour_s;
wire [2:0] colour_d;
wire [2:0] colour_f;
wire [2:0] colour_g;
wire [2:0] colour_h;
wire [2:0] colour_j;
wire [2:0] colour_k;
wire [2:0] colour_l;
wire [2:0] colour_lr1;
wire [2:0] colour_lr2;
wire [2:0] colour_q;
wire [2:0] colour_w;
wire [2:0] colour_e;
wire [2:0] colour_r;
wire [2:0] colour_t;
wire [2:0] colour_y;
wire [2:0] colour_u;
wire [2:0] colour_i;
wire [2:0] colour_o;
wire [2:0] colour_p;
wire [2:0] colour_pr1;
wire [2:0] colour_pr2;
wire [2:0] colour_pr3;
wire [2:0] colour_pr4;
wire [2:0] colour_pr5;
wire [2:0] colour_z;
wire [2:0] colour_x;
wire [2:0] colour_space;


intro i0 ( VGA_counter, CLOCK_50, colour_intro);
play play0(VGA_counter, CLOCK_50, colour_play);
start start0 ( VGA_counter, CLOCK_50, colour_start);

//KEYS
//a a0 ( VGA_counter, CLOCK_50, colour_a);
//s s0 ( VGA_counter, CLOCK_50, colour_s);
//d d0 ( VGA_counter, CLOCK_50, colour_d);
//f f0 ( VGA_counter, CLOCK_50, colour_f);
//g g0 ( VGA_counter, CLOCK_50, colour_g);
//start here
//h h0 ( VGA_counter, CLOCK_50, colour_h);
//j j0 ( VGA_counter, CLOCK_50, colour_j);
k k0 ( VGA_counter, CLOCK_50, colour_k);

l l0 ( VGA_counter, CLOCK_50, colour_l);
lr1 vv0 ( VGA_counter, CLOCK_50, colour_lr1);
lr2 vv1 ( VGA_counter, CLOCK_50, colour_lr2);

q q0 ( VGA_counter, CLOCK_50, colour_q);
w w0 ( VGA_counter, CLOCK_50, colour_w);
e e0 ( VGA_counter, CLOCK_50, colour_e);
r r0 ( VGA_counter, CLOCK_50, colour_r);
t t0 ( VGA_counter, CLOCK_50, colour_t);
y y0 ( VGA_counter, CLOCK_50, colour_y);
u u0 ( VGA_counter, CLOCK_50, colour_u);
//i ikey0 ( VGA_counter, CLOCK_50, colour_i);
//o o0 ( VGA_counter, CLOCK_50, colour_o);
//p p0 ( VGA_counter, CLOCK_50, colour_p);
//pr1 bb0 ( VGA_counter, CLOCK_50, colour_pr1);
//pr2 bb1 ( VGA_counter, CLOCK_50, colour_pr2);
//pr3 bb2 ( VGA_counter, CLOCK_50, colour_pr3);
//pr4 bb3 ( VGA_counter, CLOCK_50, colour_pr4);
//pr5 bb4 ( VGA_counter, CLOCK_50, colour_pr5);
z z0 ( VGA_counter, CLOCK_50, colour_z);
x x0 ( VGA_counter, CLOCK_50, colour_x);
space space0 ( VGA_counter, CLOCK_50, colour_space);


//END KEYS/////////////////////////////


vga_address_translator vga_trans(x,y,VGA_counter);



always @ (*) begin

case (selectRom[4:0])

5'd0:

colour=colour_start;

5'd1: 

colour=colour_intro;

5'd2:

colour=colour_play;

//5'd3:colour=colour_a;
//5'd4:colour=colour_s;
//5'd5:colour=colour_d;
//5'd6:colour=colour_f;
//5'd7:colour=colour_g;
//5'd8:colour=colour_h;
//5'd9:colour=colour_j;
5'd10:colour=colour_k;
5'd11:colour=colour_l;
5'd12:colour=colour_lr1;
5'd13:colour=colour_lr2;

5'd14:colour=colour_q;
5'd15:colour=colour_w;
5'd16:colour=colour_e;
5'd17:colour=colour_r;
5'd18:colour=colour_t;
5'd19:colour=colour_y;
5'd20:colour=colour_u;
//5'd21:colour=colour_i;
//5'd22:colour=colour_o;
//5'd23:colour=colour_p;
//5'd24:colour=colour_pr1;
//5'd25:colour=colour_pr2;
//5'd26:colour=colour_pr3;
//5'd27:colour=colour_pr4;
//5'd28:colour=colour_pr5;
5'd29:colour=colour_z;
5'd30:colour=colour_x;
5'd31:colour=colour_space;

default:

colour=colour_play;

endcase


end



endmodule
