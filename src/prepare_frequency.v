module prepare_frequency(note, delay);
input [7:0] note;

output reg [19:0] delay;
always @ (*) begin 


case (note)

8'h15:  delay=20'd95556;
8'h1D:  delay=20'd85131;
8'h24:  delay=20'd75843;
8'h2D:  delay=20'd71586;
8'h2C:  delay=20'd63775;
8'h35:  delay=20'd56818;
8'h3C:  delay=20'd50319;
8'h43:  delay=20'd47778;
8'h44:  delay=20'd42566;
8'h4D:  delay=20'd37922;
8'h54:  delay=20'd35793;
8'h5B:  delay=20'd31888;
8'h71:  delay=20'd28409;
8'h69:  delay=20'd25310;
8'h7A:  delay=20'd23889;
8'h5A:  delay=20'd107258;

8'h52:  delay=20'd101238;
8'h4C:  delay=20'd113636;
8'h4B:  delay=20'd127551;
8'h42:  delay=20'd143173;
8'h3B:  delay=20'd151686;
8'h33:  delay=20'd170263;
8'h34:  delay=20'd191113;
8'h2B:  delay=20'd202477;
8'h23:  delay=20'd227273;
8'h1B:  delay=20'd255102;
8'h1C:  delay=20'd286345;

8'h1A:  delay=20'd450000;		//z
8'h22:  delay=20'd400000;		//x
8'h21:  delay=20'd350000;		//c
8'h29:  delay=20'd500000; //space

default : delay <= delay;

endcase


end


endmodule