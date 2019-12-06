module frameROM(
	input logic[15:0] addr,
	output logic[23:0] data_out,
	input in_range,
	input is_plane,
	input is_missle,
	input logic[9:0]DrawX,DrawY,
	input logic[15:0] plane_addr,
	input logic[15:0] missle_addr,
	output logic[19:0] SRAM_ADDR,
	inout wire[15:0] SRAM_DQ,
	input logic[15:0] bg_position,
	input logic[15:0] enemy_addr,
	input logic is_enemy1,
	input logic is_bullet1,is_bullet2,is_bullet3,
	input logic is_rz,
	input logic[15:0] rz_addr,
	input logic is_plane_last1,is_p2,is_missle_last,is_p2_miss,
	input logic[15:0] last_plane_addr,p2_addr,last_missle_addr,p2_miss_addr,
	input logic start_pic,win_end,dead_end
);

logic [4:0] mem[34371];
//logic [4:0] mem[37612];

logic [23:0] pal[32];
//assign pal[0] = 24'hFF0000;
//assign pal[1] = 24'hF83800;
//assign pal[2] = 24'hF0D0B8;
//assign pal[3] = 24'h503000;
//assign pal[4] = 24'hFFE0A8;
//assign pal[5] = 24'h0058F8;
//assign pal[6] = 24'hFCFCFC;
//assign pal[7] = 24'hBCBCBC;
//assign pal[8] = 24'hA40000;
//assign pal[9] = 24'hD82800;
//assign pal[10] = 24'hFC7460;
//assign pal[11] = 24'hFCBCB0;
//assign pal[12] = 24'hF0BC3C;
//assign pal[13] = 24'hAEACAE;
//assign pal[14] = 24'h363301;
//assign pal[15] = 24'h6C6C01;
assign pal[0] = 24'h050505;
assign pal[1] = 24'h92817E;
assign pal[2] = 24'h4B352B;
assign pal[3] = 24'h7B6B58;
assign pal[4] = 24'h503615;
assign pal[5] = 24'hD3CDC9;
assign pal[6] = 24'h3C2002;
assign pal[7] = 24'h96876C;
assign pal[8] = 24'hB5AEA3;
assign pal[9] = 24'h584413;
assign pal[10] = 24'h553F0B;
assign pal[11] = 24'h6C5312;
assign pal[12] = 24'h60460C;
assign pal[13] = 24'hA08928;
assign pal[14] = 24'h5A400A;
assign pal[15] = 24'hBDA533;
assign pal[16] = 24'h9F9F6B;
assign pal[17] = 24'hB8B8A8;
assign pal[18] = 24'hD4D4AA;
assign pal[19] = 24'h46433F;
assign pal[20] = 24'h7A7773;
assign pal[21] = 24'h3A393A;
assign pal[22] = 24'h2F2B26;
assign pal[23] = 24'h39301F;
assign pal[24] = 24'hF8F8FA;
assign pal[25] = 24'h6A5C50;
assign pal[26] = 24'hF1B55C;
assign pal[27] = 24'hA19B77;
assign pal[28] = 24'hF6DD95;
assign pal[29] = 24'hF9EFB5;
assign pal[30] = 24'hCB4D15;
assign pal[31] = 24'hF3BC2E;
logic[7:0] index;

initial
begin
		$readmemh("./final.txt",mem);
end

logic[19:0] temp,temp1;
//always_comb
//begin
//if(start_pic == 1'b1 || win_end == 1'b1 || dead_end == 1'b1)
//SRAM_ADDR = DrawX + DrawY*20'd300;
//end
assign temp = DrawX + DrawY*20'd2000 + bg_position;
//logic[18:0] char_addr;
//assign char_addr = addr; //+ 19'd300800;
assign SRAM_ADDR = temp;
always_comb// @ (posedge Clk)
begin
	if(start_pic == 1'b1)
	index = 8'd0;
	else if(win_end == 1'b1)
	index = 8'd31;
	else if(dead_end == 1'b1)
	index = 8'd22;
	else if(in_range && (mem[addr] != 8'd22))
	index = mem[addr];
	else if(is_plane && mem[plane_addr+16'd28444] != 8'd22)
	index= mem[plane_addr+16'd28444];
	else if(is_missle && mem[missle_addr+16'd24624] != 8'd22)
	index = mem[missle_addr+16'd24624];
	else if(is_enemy1)
	index = 8'd5;
	else if(is_bullet1)
	index = 8'd0;
	else if(is_bullet2)
	index = 8'd0;
	else if(is_bullet3)
	index = 8'd0;
	else if(is_rz && mem[rz_addr] != 8'd22)
	index = mem[rz_addr];
	else if(is_plane_last1 && mem[last_plane_addr+16'd28444] != 8'd22)
	index = mem[last_plane_addr+16'd28444];
	else if(is_p2 && mem[p2_addr+16'd28444] != 8'd22)
	index = mem[p2_addr+16'd28444];
	else if(is_missle_last && mem[last_missle_addr+16'd24624] != 8'd22)
	index = mem[last_missle_addr+16'd24624];
	else if(is_p2_miss && mem[p2_miss_addr+16'd24624] != 8'd22)
	index = mem[p2_miss_addr+16'd24624];
	else
	index = SRAM_DQ[7:0];
end


//always_comb// @ (posedge Clk)
//begin
//	if(start_pic == 1'b1)
//	index = 8'd0;
//	else if(win_end == 1'b1)
//	index = 8'd31;
//	else if(dead_end == 1'b1)
//	index = 8'd22;
//	else if(in_range)
//	index = 8'd2;
//	else if(is_plane)
//	index= 8'd3;
//	else if(is_missle)
//	index = 8'd4;
//	else if(is_enemy1)
//	index = 8'd19;
//	else if(is_bullet1)
//	index = 8'd0;
//	else if(is_bullet2)
//	index = 8'd0;
//	else if(is_bullet3)
//	index = 8'd0;
//	else if(is_rz)
//	index = 8'd22;
//	else if(is_plane_last1)
//	index = 8'd25;
//	else if(is_p2)
//	index = 8'd27;
//	else if(is_missle_last)
//	index = 8'd29;
//	else if(is_p2_miss)
//	index = 8'd31;
//	else
//	index = SRAM_DQ[7:0];
//end





assign data_out = pal[index];

endmodule
