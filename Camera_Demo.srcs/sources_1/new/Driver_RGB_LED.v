`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/18 17:05:32
// Design Name: 
// Module Name: Driver_RGB_LED
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


module Driver_RGB_LED(
    input i_clk,
    input i_rst,
    input i_en,
    input [23:0]i_rgb_data0,
    input [23:0]i_rgb_data1,
    input [5:0]i_period_100ms,
    output o_rgb_bus
    );
    //ʱ��
    wire clk_10MHz;
    
    //RGB����
    wire [47:0]rgb_data;
    
    //����������
    Driver_Breath_LED #(.LED_Bit(6'd48)) Driver_Breath_LED_0
    (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_period_100ms(i_period_100ms),
        .i_data({i_rgb_data0,i_rgb_data1}),
        .o_data(rgb_data)
    );
    
    //RGBLED��IC����
    Driver_SK6805 Driver_SK6805_0(
        .i_clk(clk_10MHz),
        .i_rst(i_rst),
        .i_en(i_en),
        .i_rgb_data_0(rgb_data[47:24]),
        .i_rgb_data_1(rgb_data[23:0]),
        .o_bus(o_rgb_bus) 
    );
    //RGB LED 
    clk_division clock_rgb(.i_clk(i_clk),.i_rst(i_rst),.i_clk_mode(31'd10),.o_clk_out(clk_10MHz));
endmodule


//RGB driver, using SK6805 series RGB.
//The coding method is a rectangular wave signal with a frequency of 1.2 kHz, the 25% duty ratio is 0, and the 75% duty ratio is 1.
//RGB single channel has a total of 8 bits, and the transmission mode is G[7], G[6]...G[0], R[7], R[6]...R[0], B[7], B [6]...B[0], total 24bit
//The SK6805 series allows RGB cascading, four-bit pins, two of which are power supply pins, and two input and output pins. Multiple slices can be cascaded, and the upper output is connected to the next input.
//The cascading transmission mode continues to transmit the cascaded RGB data after a single transmission is completed.
//For example: three-level cascading, only need to send 24*3bit data to the first-level RGBLED, then the last 24*2bit data is forwarded to the second level after the first-level reception is completed, and the last 24-bit data is forwarded after the second-level reception Give the third level.
//After each round of communication is completed (the first stage receives all the level data), it needs to have a reset of 80us or more, that is, a low time. Then it will enter the data transmission of the next cycle.
//This driver has been packaged, just assign the RGB channel value, the hardware uses two-bit cascade, so there are only two RGB inputs (48bit).
module Driver_SK6805(
    input i_clk,
    input i_rst,
    input i_en,
    input [23:0]i_rgb_data_0,
    input [23:0]i_rgb_data_1,
    output o_bus 
);
    //Ƶ�ʲ���
    localparam Default_Factor=10'd1000;
    localparam Default_Freq_Num=10'd12;
    
    //�������
    localparam Default_Code_H_0=10'd3;
    localparam Default_Code_H_1=10'd9;
    
    //���͵�RGB����λ��
    localparam Default_DATA_BIT=6'd48;
    
    //״̬����
    localparam ST_IDLE=2'd0;
    localparam ST_DIVISION=2'd3;
    localparam ST_SEND_0=2'd1;
    localparam ST_SEND_1=2'd2;
    
    //����
    reg [9:0]send_cnt=0;
    reg [5:0]data_cnt=0;
 
    //״̬
    reg [1:0]state_current=0;
    reg [1:0]state_next=0;
    
    //����
    reg en_i=0;
    reg [47:0]rgb_data_i=0;
    
    //���
    reg bus_o=0;
    
    //�������
    assign o_bus=bus_o;
    
    //�������
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            bus_o<=1'b0;
        end else begin
            case(state_current)
                ST_SEND_0:begin
                    if(send_cnt<Default_Code_H_0)bus_o<=1'b1;
                    else bus_o<=1'b0;
                end
                ST_SEND_1:begin
                    if(send_cnt<Default_Code_H_1)bus_o<=1'b1;
                    else bus_o<=1'b0;
                end
                default:bus_o<=1'b0;
            endcase
        end
    end
    
    //��Ƶ����
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            send_cnt<=10'd0;
        end else begin
            case(state_current)
                ST_DIVISION:begin
                    if(send_cnt==Default_Factor)send_cnt<=10'd0;
                    else send_cnt<=send_cnt+1;
                end
                ST_SEND_0,ST_SEND_1:begin
                    if(send_cnt==Default_Freq_Num-1)send_cnt<=10'd0;
                    else send_cnt<=send_cnt+1;
                end
                default:send_cnt<=send_cnt;
            endcase
        end
    end
    
    //�������ݼ���
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            data_cnt<=6'd0;
        end else begin
            case(state_current)
                ST_DIVISION:begin
                    if(send_cnt==Default_Factor)data_cnt<=data_cnt+1;
                    else data_cnt<=6'd0;
                end
                ST_SEND_0,ST_SEND_1:begin
                    if(send_cnt==Default_Freq_Num-1&data_cnt==Default_DATA_BIT)data_cnt<=6'd0;
                    else if(send_cnt==Default_Freq_Num-1)data_cnt<=data_cnt+1;
                    else data_cnt<=data_cnt;
                end
                default:data_cnt<=data_cnt;
            endcase
        end
    end

    //״̬��
    always@(*)begin
        case(state_current)
            ST_IDLE:begin
                if(en_i==1'b1)state_next<=ST_SEND_0;
                else state_next<=ST_IDLE;
            end
            ST_DIVISION:begin
                if(en_i==1'b0)state_next<=ST_IDLE;
                else if(send_cnt==Default_Factor&rgb_data_i[47-data_cnt]==1'b1)state_next<=ST_SEND_1;
                else if(send_cnt==Default_Factor)state_next<=ST_SEND_0;
                else state_next<=ST_DIVISION;
            end
            ST_SEND_0:begin
                if(en_i==1'b0)state_next<=ST_IDLE;
                else if(send_cnt==Default_Freq_Num-1&data_cnt==Default_DATA_BIT)state_next<=ST_DIVISION;
                else if(send_cnt==Default_Freq_Num-1&rgb_data_i[47-data_cnt]==1'b1)state_next<=ST_SEND_1;
                else state_next<=ST_SEND_0;
            end
            ST_SEND_1:begin
                if(en_i==1'b0)state_next<=ST_IDLE;
                else if(send_cnt==Default_Freq_Num-1&data_cnt==Default_DATA_BIT)state_next<=ST_DIVISION;
                else if(send_cnt==Default_Freq_Num-1&rgb_data_i[47-data_cnt]==1'b0)state_next<=ST_SEND_0;
                else state_next<=ST_SEND_1;
            end
        endcase
    end
    
    //״̬��ֵ
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            state_current<=2'd0;
        end else begin
            state_current<=state_next;
        end
    end
    
    //���뻺��
    always@(posedge i_clk or negedge i_rst)begin
        if(!i_rst)begin
            en_i<='b0;
            rgb_data_i<=48'd0;
        end else begin
            en_i<=i_en;
            rgb_data_i<={i_rgb_data_0[15:8],i_rgb_data_0[23:16],i_rgb_data_0[7:0],i_rgb_data_1[15:8],i_rgb_data_1[23:16],i_rgb_data_1[7:0]};
        end
    end
endmodule