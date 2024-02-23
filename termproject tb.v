`define False 1'b0
`define True 1'b1
module sts;
wire [2:0] M1;
wire [1:0] M2;
wire E,TL,RH,LH;
reg key,brake,acc,clk,clr;
reg [1:0] s;
parameter stop=3'd0;
parameter slow=3'd1;
parameter med=3'd2;
parameter high=3'd3;
parameter rev=3'd4;
parameter straight=2'd0;
parameter right=2'd1;
parameter left=2'd2;
Control_Car c1(E,TL,RH,LH,M1,M2,key,brake,acc,clk,clr,s);

initial 
begin 
 clk= `False; 
 forever #5 clk = ~clk; 
end

initial
begin 
 clr = `True; 
 repeat (0.5) @(negedge clk); 
 clr = `False; 
end 

initial  begin

key=0;
#10 key=1; 
#10 brake=1;
#10 brake = 0; acc=0;
#10 acc=1; 
#10 acc=0; brake=1;
#10 brake=0;acc=0;
#10 acc=1;
#10 acc=0; 
#30 s=1;
#30 s=0;
end
endmodule


