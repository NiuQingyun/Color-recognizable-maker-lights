`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2020 07:05:59 PM
// Design Name: 
// Module Name: Key_Test_Color
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Key_Test_Color(
    input i_clk,
    input i_rst,
    input i_key,
    input [23:0]i_rgb_data,
    input [7:0]i_rgb_r,
    input [7:0]i_rgb_b,
    input [7:0]i_rgb_g,
    output [5:0]o_period_100ms,
    output [23:0]o_rgb_data_0,
    output [23:0]o_rgb_data_1
    );
    //��ɫ����
    localparam COLOR_RED=24'hff0000;
    localparam COLOR_RED_DEEP=24'hd20000;
    localparam COLOR_ORINGE=24'hff277f;
    localparam COLOR_ORINGE_DEEP=24'ha20041;
    localparam COLOR_YELLOW=24'hff00ff;
    localparam COLOR_YELLOW_DEEP=24'h8c008c;
    localparam COLOR_GREEN=24'h0000c8;
    localparam COLOR_GREEN_DEEP=24'h00006f;
    localparam COLOR_BLUE=24'h00ff80;
    localparam COLOR_BLUE_DEEP=24'h00b55a;
    localparam COLOR_PURPLE=24'h80ff00;
    localparam COLOR_PURPLE_DEEP=24'h50a000;
    localparam COLOR_BLACK=24'h555555;
    localparam COLOR_BLACK_DEEP=24'h323232;
    localparam COLOR_PINK=24'hffff53;
    localparam COLOR_PINK_DEEP=24'ha2a200;
    
    //��ɫ����
    reg [2:0]color_cnt=0;
    
    //����
    reg [1:0]key_i=0;
    
    //���
    reg [5:0]period_100ms_o=6'd5;
    reg [23:0]rgb_data_0=0;
    reg [23:0]rgb_data_1=0;
    
    //�������
    assign o_period_100ms=period_100ms_o;
    assign o_rgb_data_0=rgb_data_0;
    assign o_rgb_data_1=rgb_data_1;
    
    //�������
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            period_100ms_o<=6'd10;
        end else if(key_i==2'b01&period_100ms_o<6'd20)begin
            period_100ms_o<=period_100ms_o+2;
        end else if(key_i==2'b01)begin
            period_100ms_o<=6'd5;
        end else begin
            period_100ms_o<=period_100ms_o;
        end
    end
    
    //��ɫ���
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            rgb_data_0<=24'd0;
            rgb_data_1<=24'd0;
        end else begin
            rgb_data_0<=i_rgb_data;
            rgb_data_1<=i_rgb_data;
            //case(color_cnt)
                //3'd0:begin rgb_data_0<=COLOR_RED;rgb_data_1<=COLOR_RED_DEEP;end
                //3'd1:begin rgb_data_0<=COLOR_ORINGE;rgb_data_1<=COLOR_ORINGE_DEEP;end
                //3'd2:begin rgb_data_0<=COLOR_YELLOW;rgb_data_1<=COLOR_YELLOW_DEEP;end
                //3'd3:begin rgb_data_0<=COLOR_GREEN;rgb_data_1<=COLOR_GREEN_DEEP;end
                //3'd4:begin rgb_data_0<=COLOR_BLUE;rgb_data_1<=COLOR_BLUE_DEEP;end
                //3'd5:begin rgb_data_0<=COLOR_PURPLE;rgb_data_1<=COLOR_PURPLE_DEEP;end
                //3'd6:begin rgb_data_0<=COLOR_BLACK;rgb_data_1<=COLOR_BLACK_DEEP;end
                //3'd7:begin rgb_data_0<=COLOR_PINK;rgb_data_1<=COLOR_PINK_DEEP;end
            //endcase
        end
    end
    
    //��ɫ����
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            color_cnt<=3'd0;
        end else if(key_i==2'b10)begin
            color_cnt<=color_cnt+1;
        end else begin
            color_cnt<=color_cnt;
        end
    end
    
    //���뻺��
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            key_i<=2'd0;
        end else begin
            key_i<={key_i[0],i_key};
        end
    end
endmodule
