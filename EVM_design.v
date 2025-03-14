`timescale 1ns/1ps
module button_control(clk,rst,button,valid_vote);
input clk,rst,button;
output reg valid_vote;
reg [30:0]counter;
always@(posedge clk)begin 
	if(rst) counter<=0;
	else begin 
		if(button && counter<11) counter<=counter+1;
		else if(button!=0) counter<=0;
	end
end

always@(posedge clk)begin 
	if(rst) valid_vote<=1'b0;
	else begin 
		if(counter==10) valid_vote<=1'b1;
		else valid_vote<=1'b0;
	end
end
endmodule

module mode_control(
input clk,rst,mode,valid_vote_casted,
input [7:0] cand1_vote,cand2_vote,cand3_vote,cand4_vote,
input cand1_button_press,cand2_button_press,cand3_button_press,cand4_button_press,
output reg [7:0] leds);
reg [30:0]counter;

always@(posedge clk)begin 
	if(rst) counter<=0;
	else if(valid_vote_casted) counter<=counter+1;
	else if(counter!=0 && counter<10) counter=counter+1;
	else counter<=0;
end

always@(posedge clk)begin 
	if(rst) leds <=0;
	else begin 
		if(mode==0 && counter>0) leds <=8'hFF;
		else if(mode==0) leds <=8'h00;
		else if(mode==1) begin 
			if(cand1_button_press) leds<=cand1_vote;
			else if(cand2_button_press) leds<=cand2_vote;
			else if(cand3_button_press) leds<=cand3_vote;
			else if(cand4_button_press) leds<=cand4_vote;
		end
	end
end
endmodule


module Voter_Logger( clk,rst,mode,cand1_valid_vote,cand2_valid_vote,cand3_valid_vote,cand4_valid_vote, cand1_vote_rcvd,cand2_vote_rcvd,cand3_vote_rcvd,cand4_vote_rcvd);
input clk,rst,mode;
input cand1_valid_vote;
input cand2_valid_vote;
input cand3_valid_vote;
input cand4_valid_vote;

output reg  [7:0] cand1_vote_rcvd,cand2_vote_rcvd,cand3_vote_rcvd,cand4_vote_rcvd;

always@(posedge clk)begin 
	if(rst) begin 
		cand1_vote_rcvd <=0;
		cand2_vote_rcvd <=0;
		cand3_vote_rcvd <=0;
		cand4_vote_rcvd <=0;
	end
	else begin 
		if(cand1_valid_vote && mode==0) cand1_vote_rcvd<=cand1_vote_rcvd+1;
		else if(cand2_valid_vote && mode==0) cand2_vote_rcvd<=cand2_vote_rcvd+1;
		else if(cand3_valid_vote && mode==0) cand3_vote_rcvd<=cand3_vote_rcvd+1;
		else if(cand4_valid_vote && mode==0) cand4_vote_rcvd<=cand4_vote_rcvd+1;
	end
end
endmodule


module voting_machine(clk,rst,mode,button1,button2,button3,button4,led);
input clk,rst,mode,button1,button2,button3,button4;
output  [7:0] led;

wire [7:0]cand1_vote_rcvd;
wire [7:0]cand2_vote_rcvd;
wire [7:0]cand3_vote_rcvd;
wire [7:0]cand4_vote_rcvd;
wire valid_vote1;
wire valid_vote2;
wire valid_vote3;
wire valid_vote4;
wire any_valid_vote;

assign any_valid_vote=valid_vote1|valid_vote2|valid_vote3|valid_vote4;

button_control bc1(.clk(clk),.rst(rst),.button(button1),.valid_vote(valid_vote1));
button_control bc2(.clk(clk),.rst(rst),.button(button2),.valid_vote(valid_vote2));
button_control bc3(.clk(clk),.rst(rst),.button(button3),.valid_vote(valid_vote3));
button_control bc4(.clk(clk),.rst(rst),.button(button4),.valid_vote(valid_vote4));

Voter_Logger vl(.clk(clk),
.rst(rst),
.mode(mode),
.cand1_valid_vote(valid_vote1),
.cand2_valid_vote(valid_vote2),
.cand3_valid_vote(valid_vote3),
.cand4_valid_vote(valid_vote4),
.cand1_vote_rcvd(cand1_vote_rcvd),
.cand2_vote_rcvd(cand2_vote_rcvd),
.cand3_vote_rcvd(cand3_vote_rcvd),
.cand4_vote_rcvd(cand4_vote_rcvd));

mode_control mc(.clk(clk),
.rst(rst),
.mode(mode),
.valid_vote_casted(any_valid_vote),
.cand1_vote(cand1_vote_rcvd),
.cand2_vote(cand2_vote_rcvd),
.cand3_vote(cand3_vote_rcvd),
.cand4_vote(cand4_vote_rcvd),
.cand1_button_press(valid_vote1),
.cand2_button_press(valid_vote2),
.cand3_button_press(valid_vote3),
.cand4_button_press(valid_vote4),
.leds(led));


endmodule
