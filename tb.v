
module systm;
wire [2:0] M1;
wire [1:0] M2;
wire E,TL,RH,LH;
reg key,brake,acc,r,l,clk,clr;
Control_CC c1(E,TL,RH,LH,M1,M2,key,brake,acc,r,l,clk,clr);

endmodule