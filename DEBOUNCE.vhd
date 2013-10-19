----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:29:21 10/13/2013 
-- Design Name: 
-- Module Name:    DEBOUNCE - Behavioral 
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

entity DEBOUNCE is
	generic	( DEBOUNCE_COUNT: natural := 4 );
	port	( INPUT: in std_logic;
              CLK: in std_logic;
			  DEBOUNCED_OUPUT: out std_logic );
end DEBOUNCE;

architecture Behavioral of DEBOUNCE is
	constant MAX: natural := DEBOUNCE_COUNT - 1;
	signal counter: natural := MAX;
	signal output: std_logic;
begin
	DEBOUNCER: process(CLK)
	begin
		if rising_edge(CLK)
		then
			if counter = MAX
			then
				if INPUT = not output
				then
					output <= INPUT;
					counter <= 0;
				end if;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process DEBOUNCER;
	DEBOUNCED_OUPUT <= output;

end Behavioral;

