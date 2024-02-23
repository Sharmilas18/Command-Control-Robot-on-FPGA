`define toLR 3
`define speedUD 3
`define False 1'b0
`define True 1'b1

module Control_Car(E,TL,RH,LH,M1,M2,key,brake,acc,RG,clk,clr,s);
output reg[2:0] M1;
output reg[1:0] M2;
output reg E,TL,RH,LH;

input key,brake,acc,RG,clk,clr;
input [1:0] s;

parameter stop=3'd0;
parameter slow=3'd1;
parameter med=3'd2;
parameter high=3'd3;
parameter rev=3'd4;
parameter straight=2'd0;
parameter right=2'd1;
parameter left=2'd2;

parameter s0=3'd0; 
parameter s1=3'd1; 
parameter s2=3'd2; 
parameter s3=3'd3; 
parameter s4=3'd4; 
parameter s5=3'd5; 
parameter s6=3'd6; 
parameter s7=3'd7;

reg [2:0] state, next_state,prvs_state;
initial begin
	state=s0;
	E=`False;
	M1=stop;
	M2=straight;
end

always @(posedge clk)
	if(clr)
		begin prvs_state=state;state=s0; end
	else
		begin prvs_state=state;state=next_state;end

always @(state)
	begin
	case(state)
		s0: begin
			E<=`False;
			M1<=stop;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s1: begin
			E<=`True;
			M1<=stop;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s2: begin
			E<=`True;
			M1<=slow;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s3: begin
			E<=`True;
			M1<=med;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s4: begin
			E<=`True;
			M1<=high;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s5: begin
			E<=`True;
			M1<=rev;
			M2<=straight;
			TL<=`False;
			RH<=`False;
			LH<=`False;
		    end
		s6: begin
			E<=`True;
			RH<=`False;
			LH<=`True;
			if (prvs_state==s2)
				M1<=slow;
			else
				M1<=med;
			M2<=left;
			TL<=`False;
		    end
		s7: begin
			E<=`True;
			
			RH<=`True;
			LH<=`False;
			if (prvs_state==s2)
				M1<=slow;
			else
				M1<=med;
			M2<=right;
			TL<=`False;
		    end
	endcase
	end

always @(state or key or brake or acc or RG or s)
 begin 
	case (state)
		s0: if(key)
			next_state<=s1;
		    else
			next_state<=s0;
		s1: if(key)
			if(brake) 
				begin TL=`True; next_state=s1; end
			else if (!acc) begin	
				if(RG)
					begin repeat(`speedUD)@(posedge clk); next_state=s5; end
				else
					next_state=s1; end
			else
				begin next_state=s2; end

		s2: if(brake)
				begin TL=`True; next_state=s1; end
			else if (acc==0)
				begin if(s==0) 	
					next_state=s2;
				else if(s==1) 
					begin repeat(`toLR)@(posedge clk); next_state=s7;end
				else if(s==2)
					begin repeat(`toLR)@(posedge clk); next_state=s6;end end
			else 
				begin next_state=s3;end 
		s3: if(brake)
			begin TL=`True; repeat(`speedUD)@(posedge clk);next_state=s2; end
		    else if(acc==0)
			begin if(s==0)
				next_state=s3;
			else if(s==1)
				begin repeat(`toLR)@(posedge clk); next_state=s7; end
			else if(s==2)
				begin repeat(`toLR)@(posedge clk); next_state=s6; end end
		    else 
			begin next_state=s4;end 
		s4: if(brake) 
			begin TL=`True; repeat(`speedUD)@(posedge clk);next_state=s3; end
		    else if(s==0) 	
					next_state=s4;
				else if(s==1 || s==2) 
					begin repeat(`toLR)@(posedge clk); next_state=s3;end
		s5: if(acc && RG)
				begin next_state=s5; end
		    else if(acc==0 && RG) 
				M1=stop;
		    else 
			next_state=s1;
		s6: if(s==0)
			next_state=prvs_state;
		    else
			next_state=s6;
		s7: if(s==0)
			next_state=prvs_state;
		    else
			next_state=s7;
		
		//default: next_state=s0;
	endcase
end


endmodule
`define False 1'b0
`define True 1'b1
module sts;
wire [2:0] M1;
wire [1:0] M2;
wire E,TL,RH,LH;
reg key,brake,acc,RG,clk,clr;
reg [2:0] s;
Control_Car c1(E,TL,RH,LH,M1,M2,key,brake,acc,RG,clk,clr,s);

initial 
begin 
 clk= `False; 
 forever #2 clk = ~clk; 
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
#10 brake = 0; acc=0; RG = 1;
#10 acc=1; 
#10 acc=0;
#10 acc=1;
#10 RG=0; acc=0;
#10 acc=1;
#10 brake=1;
#10 brake =0;
#5 $stop;
end
endmodule

