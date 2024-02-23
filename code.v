`define toLR 3
`define speedUD 5
`define False 1'b0
`define True 1'b1

module Control_Car(E,TL,RH,LH,M1,M2,key,brake,acc,clk,clr,s);
output reg[2:0] M1;
output reg[1:0] M2;
output reg E,TL,RH,LH;

input key,brake,acc,clk,clr;
input [1:0] s;

parameter stop=3'd0;
parameter slow=3'd1;
parameter med=3'd2;
parameter high=3'd3;

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
			E=`False;
			M1=stop;
			M2=straight;

		    end
		s1: begin
			E=`True;
			M1=stop;
			M2=straight;

		    end
		s2: begin
			E=`True;
			M1=slow;
			M2=straight;

		    end
		s3: begin
			E=`True;
			M1=med;
			M2=straight;

		    end
		s4: begin
			E=`True;
			M1=high;
			M2=straight;

		    end
		/*s5: begin
			E=`True;
			M1=rev;
			M2=straight;
			TL=`False;
			RH=`False;
			LH=`False;
		    end*/
		s6: begin
			E=`True;

			M2=left;
			if (prvs_state==s3)
				M1=med;
			else
				M1=slow;


		    end
		s7: begin
			E=`True;

			M2=right;
			if (prvs_state==s3)
				M1=med;
			else
				M1=slow;

		    end
	endcase
	end

always @(state or key or brake or acc or s)
 begin 
	case (state)
		s0: if(key)
			next_state=s1;
		    else
			next_state=s0;
		s1: if(key)
			if(brake) 
				begin {RH,TL,LH} = 3'b010; next_state=s1; end
			else if (!acc) begin	
				next_state=s1; 
				{RH,TL,LH} = 3'b000;end
			else
				begin next_state=s2; 
				{RH,TL,LH} = 3'b000;end

		s2: if(brake)
				begin {RH,TL,LH} = 3'b010; next_state=s1; end
			else if (acc==0)
				begin {RH,TL,LH} = 3'b000;
			if(s==0) 	
					next_state=s2; 
			else if(s==1) 
					begin {RH,TL,LH} = 3'b100; next_state=s7;end
				else if(s==2)
					begin {RH,TL,LH} = 3'b001; next_state=s6;end end
			else 
				begin {RH,TL,LH} = 3'b000; next_state=s3;end 
		s3: if(brake)
			begin {RH,TL,LH} = 3'b010; /*repeat(`speedUD)@(posedge clk);*/next_state=s2; end
		    else if(acc==0)
			begin {RH,TL,LH} = 3'b000; if(s==0)
				next_state=s3;
			else if(s==1)
				begin {RH,TL,LH} = 3'b100; next_state=s7; end
			else if(s==2)
				begin {RH,TL,LH} = 3'b001; next_state=s6; end end
		    else 
			begin {RH,TL,LH} = 3'b000; next_state=s4;end 
		s4: if(brake) 
			begin {RH,TL,LH} = 3'b010; /*repeat(`speedUD)@(posedge clk);*/next_state=s3; end
		    else if(s==0) begin	
					{RH,TL,LH} = 3'b000; next_state=s4; end
			else if(s==1 || s==2) 
					begin   TL=`False; next_state=s3;end
		/*s5: if(acc && RG)
				begin next_state=s5; end
		    else if(acc==0 && RG) 
				M1=stop;
		    else 
			begin TL=`False; next_state=s1; end*/
		s6: if(M1==med&&s==0)
			next_state=s3;
		else if(M1==slow&&s==0)
			next_state=s2;
		    else
			next_state=s6;
		s7: if(M1==med&&s==0)
			next_state=s3;
		else if(M1==slow&&s==0)
			next_state=s2;
		    else
			next_state=s7;
		
		default: next_state=s0;
	endcase
end


endmodule