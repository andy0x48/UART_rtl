library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity uart_tx is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		baud_tick	: in std_logic;
		data_in		: in std_logic_vector(7 downto 0);
		data_ready	: in std_logic;
		tx				: out std_logic;
		tx_ready		: out std_logic
		);
end uart_tx;
	
architecture rtl of uart_tx is

	type uart_tx_states is (IDLE, START, DATA, STOP);
	signal next_state : uart_tx_states;
	
	signal counter			: std_logic_vector(3 downto 0);
	signal counter_en		: std_logic;
	signal shift_en		: std_logic;
	signal shift_load		: std_logic;
	signal tx_buffer_in	: std_logic_vector(9 downto 0);
	signal tx_serial 		: std_logic;

begin

	counter_c : LPM_COUNTER
		generic map (
			LPM_WIDTH => 4,
			LPM_MODULUS => 10
			)
		port map (
			clock => baud_tick,
			aclr => rst,
			cnt_en => counter_en,
			q => counter
			);
			
	tx_piso_c : LPM_SHIFTREG
		generic map (
			LPM_WIDTH => 10,
			LPM_DIRECTION => "RIGHT"
			)
		port map (
			clock => clk,
			aclr => rst,
			enable => baud_tick,
			load => shift_load,
			data => tx_buffer_in,
			shiftout => tx_serial
			);
			
	process(clk, baud_tick)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				counter_en <= '0';
				shift_load <= '1';
				tx_buffer_in <= (others => '1');
				tx_ready <= '0';
				next_state <= IDLE;
			else
				case next_state is
					-- IDLE
					when IDLE =>
						if data_ready = '1' then
							if baud_tick = '1' then
								counter_en <= '1';
								tx_buffer_in(8 downto 1) <= data_in;
								next_state <= START;
							end if;
						else
							next_state <= IDLE;
						end if;
					-- START
					when START =>
						if baud_tick = '1' then
							tx_buffer_in(0) <= '0';
							shift_load <= '0';
							next_state <= DATA;
						end if;
					-- DATA
					when DATA =>
						if baud_tick = '1' then
							if counter = "1001" then
								shift_load <= '1';
								next_state <= STOP;
							end if;
						end if;
					-- STOP
					when STOP =>
						if baud_tick = '1' then
							tx_buffer_in(9) <= '1';
							next_state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	tx <= '1' when rst = '1' else tx_serial;
	
end rtl;