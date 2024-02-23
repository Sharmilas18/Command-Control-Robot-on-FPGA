module Control_CC(
output reg[1:0] M2,
output reg E,TL,RH,LH,HL,AL,
output reg [3:0] AN,//activelow
output reg[6:0] LED,
input key,brake,acc,r,l,clk,hl,gear);

parameter stop=3'd0,g1=3'd1,g2=3'd2,g3=3'd3,g4=3'd4,g5=3'd5,rg=3'd6;
parameter T=1'b1, F=1'b0;
parameter straight=2'd0, right=2'd1, left=2'd2;

reg sec,f,rst;
reg [2:0] M1;
reg [26:0] ct;
reg [6:0] count;


initial {f,count,M1}<={T,4'd0,3'd0};

always@(posedge clk) begin
    {ct,sec} <= (ct == 27'd50_000_000)?{27'd0,~sec}:{ct + 1'b1,sec};
    E <=  key?1'b1:1'b0;
    AN<=  key?(gear?(sec?4'b0000:4'b1111):4'b1110):4'b1111;
    TL <= (!gear)?((brake&&key)? 1'b1:1'b0):((sec&&gear&&key)?1'b1:1'b0);
    HL <= (hl&&key)? 1'b1:1'b0;
    AL <= (acc&&key)? 1'b1:1'b0;     
end

always@(posedge clk) begin
    case({l,r,key,brake})
        {left,T,F}: if(M1<g4) {LH,RH,M2}<=sec?{left,left}:{straight,left};
        {right,T,F}:if(M1<g4) {LH,RH,M2}<=sec?{right,right}:{straight,right};
    default: {LH,RH,M2} <={straight,straight};
    endcase
end
  
always@(posedge sec) begin
    if(count<6'd3) M1<=stop; 
    if(6'd10>count&&count>6'd5) M1<=g1;  
    if(6'd15>count&&count>6'd10) M1<=g2;  
    if(6'd20>count&&count>6'd15) M1<=g3;
    if(6'd25>count&&count>6'd20) M1<=g4;  
    if(6'd30>count&&count>6'd25) M1<=g5;
    if(gear&&key) M1<=rg; 
end

always @(posedge sec) begin 
	casex ({gear,key,brake,acc})
        {F,T,F,T}: count<=(M1<g5)?count+6'd3:count; 
        {F,T,F,F}: count<=(M1>g1)?count-6'd1:count;
        {F,T,T,F}: count<=(M1>stop)?count-6'd3:count;
	endcase
end
	
always @(posedge clk) begin
    case(M1)
        stop: LED <= 7'b0000001; // "0"  
        g1:   LED <= 7'b1001111; // "1" 
        g2:   LED <= 7'b0010010; // "2" 
        g3:   LED <= 7'b0000110; // "3" 
        g4:   LED <= 7'b1001100; // "4" 
        g5:   LED <= 7'b0100100; // "5" 
        rg:   LED <= LED; // "6"  
    default:  LED <= 7'b0000001; // "0"
    endcase
end		
endmodule