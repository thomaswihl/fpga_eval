----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:59:20 10/13/2013 
-- Design Name: 
-- Module Name:    simpleIO - Behavioral 
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
use ieee.numeric_std;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simpleIO is 
port(
	external_clk: in std_logic;
	BTN2: in std_logic;
	BTN3: in std_logic;
    IN0: in std_logic;
    IN1: in std_logic;
    IN2: in std_logic;
    IN3: in std_logic;
    IN4: in std_logic;
    IN5: in std_logic;
    IN6: in std_logic;
    IN7: in std_logic;
	LED1: out std_logic;
	LED2: out std_logic;
	LED3: out std_logic;
	LED4: out std_logic;
    UART_TX: out std_logic
);
end simpleIO;

architecture Behavioral of simpleIO is
	COMPONENT CLOCK_200M is
	PORT(
		CLKIN_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic
		);
	END COMPONENT;
    
	COMPONENT CLOCK_UART
	PORT(
		CLKIN_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic
		);
	END COMPONENT;

    COMPONENT DEBOUNCE is
	generic	(	DEBOUNCE_COUNT: integer );
	port		(	INPUT: in std_logic;
					CLK: in std_logic;
					DEBOUNCED_OUPUT: out std_logic );
	end COMPONENT;

	COMPONENT QDEC is
	generic ( VALUE_BIT_WIDTH: natural );
    port    ( CLK: in std_logic;
              A: in std_logic;
              B: in std_logic;
              VALUE: out std_logic_vector(VALUE_BIT_WIDTH - 1 downto 0) );
    END COMPONENT;

    COMPONENT RAM
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT SERIAL is
        port( CLK: in std_logic;
              DIN: in std_logic_vector(7 downto 0);
              START: in std_logic;
              DOUT: out std_logic;
              READY: out std_logic );
    end COMPONENT;

    COMPONENT LOGIC_ANALYSER is
        generic( INPUT_COUNT : natural := 8;
            PRECISION_BIT : natural := 24
            );
        port ( CLK : in std_logic;
            INPUT : in std_logic_vector(INPUT_COUNT - 1 downto 0);
            OUTPUT: out std_logic_vector(INPUT_COUNT + PRECISION_BIT - 1 downto 0);
            OUT_VALID: out std_logic
            );
    end COMPONENT;

    constant enable: std_logic_vector(0 downto 0) := (others => '1');
	constant divider_clk_1k: natural := 12500;
	signal cnt_clk_1k: natural := 1;
	
	signal btn2_debounced: std_logic;
	signal btn3_debounced: std_logic;
	
	signal clk_200M: std_logic;
	signal clk_1k: std_logic;
	
    signal decoder_value: std_logic_vector(3 downto 0);
    
    signal uart_data: std_logic_vector(7 downto 0) := "01000001";
    signal uart_start: std_logic;
    signal uart_ready: std_logic;
    signal clk_uart_fast: std_logic;
    signal clk_uart_slow: std_logic;
    signal clk_uart: std_logic;
	constant divider_clk_uart: natural := 21;-- * 921600; --25MHz * 24 / 31 = 19354838.7096774 / 921600 = 21.00134409
    constant baudrate: natural := 921600;-- / 921600;
    signal cnt_clk_uart: natural := 1;
    signal cnt_clk_uart_slow: natural := 1;


    signal addra : STD_LOGIC_VECTOR(8 DOWNTO 0);
    signal la_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal addrb : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal logic_data_available: std_logic;
    signal la_in: std_logic_vector(7 downto 0);
    type uart_state_t is (INIT, IDLE, WAIT_SEND, WAIT_READY);
    signal uart_state: uart_state_t := IDLE;

begin
	dcm0: CLOCK_200M port map(CLKIN_IN => external_clk, CLKFX_OUT => clk_200M);
    dcm1: CLOCK_UART PORT MAP(CLKIN_IN => external_clk, CLKFX_OUT => clk_uart_fast);
    --btn2_debouncer: DEBOUNCE generic map(10) port map(INPUT => not BTN2, CLK => clk_1k, DEBOUNCED_OUPUT => btn2_debounced);
	--btn3_debouncer: DEBOUNCE generic map(10) port map(INPUT => not BTN3, CLK => clk_1k, DEBOUNCED_OUPUT => btn3_debounced);
	--decoder: QDEC generic map(4) port map(CLK => clk_1k, A => btn2_debounced, B => btn3_debounced, VALUE => decoder_value);
    memory : RAM port map (clka => clk_200M, wea => enable, addra => addra, dina => la_data, clkb => clk_200M, addrb => addrb, doutb => uart_data);
    uart: SERIAL port map ( CLK => clk_uart, DIN => uart_data, START => uart_start, DOUT => UART_TX, READY => uart_ready);
    la0: LOGIC_ANALYSER generic map(8, 24) port map(CLK => clk_200M, INPUT => la_in, OUTPUT => la_data, OUT_VALID => logic_data_available);
    la_in <= IN0 & IN1 & IN2 & IN3 & IN4 & IN5 & IN6 & IN7;
	generate_clk_1k: process(external_clk)
	begin
		if rising_edge(external_clk) then
			if cnt_clk_1k = divider_clk_1k then
				clk_1k <= not clk_1k;
				cnt_clk_1k <= 1;
			else
				cnt_clk_1k <= cnt_clk_1k + 1;
			end if;
		end if;
	end process generate_clk_1k;
	
	generate_clk_uart: process(clk_uart_fast)
	begin
		if rising_edge(clk_uart_fast) then
			if cnt_clk_uart = divider_clk_uart then
				clk_uart <= '1';
				cnt_clk_uart <= 1;
                if cnt_clk_uart_slow = baudrate then
                    clk_uart_slow <= not clk_uart_slow;
                    cnt_clk_uart_slow <= 1;
                else
                    cnt_clk_uart_slow <= cnt_clk_uart_slow + 1;
                end if;
			else
                clk_uart <= '0';
				cnt_clk_uart <= cnt_clk_uart + 1;
			end if;
		end if;
	end process generate_clk_uart;
    
    in_addr_changer: process(clk_200M)
    begin
        if falling_edge(clk_200M) then
            if logic_data_available = '1' then
                addra <= std_logic_vector(unsigned(addra) + 1);
            end if;
            if uart_state = INIT then
                if uart_ready = '1' then
                    uart_state <= IDLE;
                end if;
            elsif uart_state = IDLE then
                if addra & "00" /= addrb then
                    uart_start <= '1';
                    uart_state <= WAIT_SEND;
                end if;
            elsif uart_state = WAIT_SEND then
                if uart_ready <= '0' then
                    uart_start <= '0';
                    uart_state <= WAIT_READY;
                end if;
            elsif uart_state = WAIT_READY then
                if uart_ready = '1' then
                    uart_state <= IDLE;
                    addrb <= std_logic_vector(unsigned(addrb) + 1);
                end if;
            end if;
        end if;
    end process in_addr_changer;
	
	LED1 <= clk_uart;
	LED2 <= uart_ready;
	LED3 <= uart_start;
	LED4 <= clk_uart_slow;
end Behavioral;

