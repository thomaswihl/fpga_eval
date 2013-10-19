----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:50 10/18/2013 
-- Design Name: 
-- Module Name:    LOGIC_ANALYSER - Behavioral 
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

entity LOGIC_ANALYSER is
    generic( INPUT_COUNT : natural := 8;
        PRECISION_BIT : natural := 24
        );
    port ( CLK : in std_logic;
        INPUT : in std_logic_vector(INPUT_COUNT - 1 downto 0);
        OUTPUT: out std_logic_vector(INPUT_COUNT + PRECISION_BIT - 1 downto 0);
        OUT_VALID: out std_logic
        );
end LOGIC_ANALYSER;

architecture Behavioral of LOGIC_ANALYSER is
    signal counter: unsigned(PRECISION_BIT - 1 downto 0) := (others => '0');
    signal last_state: std_logic_vector(INPUT_COUNT - 1 downto 0) := (others => '0');
begin
    check_change: process(CLK)
    begin
        if falling_edge(CLK) then
            if last_state /= INPUT or counter = (counter'range => '1') then
                OUTPUT <= INPUT & std_logic_vector(counter);
                OUT_VALID <= '1';
                last_state <= INPUT;
                counter <= (0 => '1', others => '0');
            else
                OUT_VALID <= '0';
                counter <= counter + 1;
            end if;
        end if;
    end process check_change;
end Behavioral;

