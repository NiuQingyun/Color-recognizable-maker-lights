-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Wed Jul 29 18:53:02 2020
-- Host        : SecLab running 64-bit Ubuntu 16.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /media/qingyun/Desktop/SEA_Lab/Camera_Demo/Camera_Demo.srcs/sources_1/ip/RAM_Line/RAM_Line_stub.vhdl
-- Design      : RAM_Line
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s15ftgb196-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAM_Line is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 10 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
    clkb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 10 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end RAM_Line;

architecture stub of RAM_Line is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[10:0],dina[7:0],clkb,addrb[10:0],doutb[7:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_2,Vivado 2018.3";
begin
end;
