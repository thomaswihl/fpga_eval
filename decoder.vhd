----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:29:21 10/13/2013 
-- Design Name: 
-- Module Name:    QDEC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QDEC is
    generic ( VALUE_BIT_WIDTH: natural );
    port    ( CLK: in std_logic;
              A: in std_logic;
              B: in std_logic;
              VALUE: out std_logic_vector(VALUE_BIT_WIDTH - 1 downto 0) );
end QDEC;

architecture Structure of QDEC is
    signal As: std_logic := '0';
    signal Bs: std_logic := '0';
    --signal A: std_logic := '0';
    --signal B: std_logic := '0';
    signal counter: unsigned(VALUE_BIT_WIDTH - 1 downto 0) := (others => '0');
begin
    decoder: process(CLK) is
	begin
		if rising_edge(CLK) then
            if As = '0' and A = '1' then
                if B = '0' then
                    counter <= counter + 1;
                elsif B = '1' then
                    counter <= counter - 1;
                end if;
            elsif As = '1' and A = '0' then
                if B = '1' then
                    counter <= counter + 1;
                elsif B = '0' then
                    counter <= counter - 1;
                end if;
            elsif Bs = '0' and B = '1' then
                if A = '1' then
                    counter <= counter + 1;
                elsif A = '0' then
                    counter <= counter - 1;
                end if;
            elsif Bs = '1' and B = '0' then
                if A = '0' then
                    counter <= counter + 1;
                elsif A = '1' then
                    counter <= counter - 1;
                end if;
            end if;
            As <= A;
            Bs <= B;
        end if;
    end process;
    VALUE <= std_logic_vector(counter);
end Structure;