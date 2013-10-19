----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:34:11 10/17/2013 
-- Design Name: 
-- Module Name:    serial - Behavioral 
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

entity serial is
    port( CLK: in std_logic;
          DIN: in std_logic_vector(7 downto 0);
          START: in std_logic;
          DOUT: out std_logic;
          READY: out std_logic );
end serial;

architecture Behavioral of serial is
    signal index: integer;
begin
    shifter: process(CLK)
    begin
        if rising_edge(CLK)
        then
            if START = '1'
            then
                index <= 15;
                READY <= '0';
            else
                if index = 15 then  --start bit
                    DOUT <= '0';
                    index <= 0;
                elsif index < 8 then   -- data bit
                    DOUT <= DIN(index);
                    index <= index + 1;
                elsif index = 8 then   --stop bit
                    DOUT <= '1';
                    index <= index + 1;
                else   --READY
                    READY <= '1';
                end if;
            end if;
        end if;
    end process shifter;

end Behavioral;

