module HA(a, b, cout1, cout2);
	input a, b;
	output cout1, cout2;
	
	xor inst1(cout1, a, b);
	and inst2(cout2, a, b);
	
endmodule

module FA(a, b, cin, s, cout);
	input a, b, cin;
	output s, cout;
	wire w1, w2, w3;
	
	HA inst3(a, b, w1, w2);
	HA inst4(w1, cin, s, w3);
	or inst5(cout, w2, w3);
	
	/*xor ab1(w1, a, b);
	xor cins(s, w1, cin);
	and w1ci(w2, w1, cin);
	and ab2(w3, a, b);
	or w2w3(cout, w2, w3);*/

endmodule

module AddSub4(A, B, Cin, SUM, ovf);
	input [3:0] A, B;
	wire [3:0] Btemp;
	input Cin;
	output [3:0]SUM;
	output ovf;
	wire w1, w2, w3, w4;
	
	assign Btemp[0] = B[0] ^ Cin;
	assign Btemp[1] = B[1] ^ Cin;
	assign Btemp[2] = B[2] ^ Cin;
	assign Btemp[3] = B[3] ^ Cin;
	
	FA a1(A[0], Btemp[0], Cin, SUM[0], w1);
	FA a2(A[1], Btemp[1], w1, SUM[1], w2);
	FA a3(A[2], Btemp[2], w2, SUM[2], w3);
	FA a4(A[3], Btemp[3], w3, SUM[3], w4);
	
	assign ovf = w3 ^ w4;	
	
endmodule

module hexdisplay(num, hex, hexsign);
  input [3:0]num;
  output [6:0]hex, hexsign;
  reg [6:0]hexdisp[0:15];
  
  initial
  begin
    hexdisp[0] = 7'b1000000; //0
    hexdisp[1] = 7'b1111001; //1
    hexdisp[2] = 7'b0100100; //2
    hexdisp[3] = 7'b0110000; //3
	 hexdisp[4] = 7'b0011001; //4
    hexdisp[5] = 7'b0010010; //5
    hexdisp[6] = 7'b0000010; //6
    hexdisp[7] = 7'b1111000; //7
	 
	 hexdisp[8] = 7'b0000000; //-8
    hexdisp[9] = 7'b1111000; //-7
    hexdisp[10] = 7'b0000010; //-6
    hexdisp[11] = 7'b0010010; //-5
	 hexdisp[12] = 7'b0011001; //-4
    hexdisp[13] = 7'b0110000; //-3
    hexdisp[14] = 7'b0100100; //-2
    hexdisp[15] = 7'b1111001; //-1
  end
  assign hex = hexdisp[num];
  assign hexsign = (num[3]) ? 7'b0111111 : 7'b1111111;
  
endmodule


module calc(SW, KEY, HEX0, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
	input [7:0] SW;
	input [2:0] KEY;
	output [6:0] HEX0, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	wire [3:0] tempL, tempR, SUM, abs, inv, cout;
	wire ovfSUM, ovfINV, ovf1;
	
	hexdisplay displayA(SW[7:4], HEX6, HEX7);
	hexdisplay displayB(SW[3:0], HEX4, HEX5);
	
	assign tempR = KEY[2] ? SW[3:0] : SW[7:4];
	assign tempL = KEY[2] ? SW[7:4] : SW[3:0];
	
	AddSub4 addition(tempL, tempR, ~KEY[0], SUM, ovfSUM);
	AddSub4 inverse(7'b0000000, tempR, 1, inv, ovfINV);
	
	assign abs = tempR[3] ? inv : tempR;
	
	assign cout = KEY[1] ? SUM : abs;
	
	assign ovf1 = KEY[1] ? ovfSUM : ovfINV;
	
	hexdisplay out(cout, HEX2, HEX3);
	
	assign HEX0 = ovf1 ? 7'b0000011 : 7'b1111111;
	
endmodule