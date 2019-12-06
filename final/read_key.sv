// reference from kttech https://kttechnology.wordpress.com/2017/04/26/ece-385-final-project-notes-reading-multiple-4-keycode-at-the-same-time/
module read_key(
input logic[31:0] keycode,
output logic[5:0] key_status, //w a s d spacce h
output logic enter_on
);
//w
assign key_status[5] = (keycode[31:24] == 8'h1A | keycode[23:16] == 8'h1A | keycode[15:8] == 8'h1A | keycode[7:0] == 8'h1A);
//a
assign key_status[4] = (keycode[31:24] == 8'd4 | keycode[23:16] == 8'd4 | keycode[15:8] == 8'd4 | keycode[7:0] == 8'd4);
//s
assign key_status[3] = (keycode[31:24] == 8'd22 | keycode[23:16] == 8'd22 | keycode[15:8] == 8'd22 | keycode[7:0] == 8'd22);
//d
assign key_status[2] = (keycode[31:24] == 8'd7 | keycode[23:16] == 8'd7 | keycode[15:8] == 8'd7 | keycode[7:0] == 8'd7);
//space
assign key_status[1] = (keycode[31:24] == 8'd44 | keycode[23:16] == 8'd44 | keycode[15:8] == 8'd44 | keycode[7:0] == 8'd44);
//h
assign key_status[0] = (keycode[31:24] == 8'd11 | keycode[23:16] == 8'd11 | keycode[15:8] == 8'd11 | keycode[7:0] == 8'd11);

assign enter_on = (keycode[31:24] == 8'd40 | keycode[23:16] == 8'd40 | keycode[15:8] == 8'd40 | keycode[7:0] == 8'd40);
endmodule
