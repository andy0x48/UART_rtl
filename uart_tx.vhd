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
		baud_clk		: in std_logic;
		data_in		: in std_logic_vector(7 downto 0);
		data_ready	: in std_logic;
		tx				: out std_logic;
		tx_ready		: out std_logic
		);
end uart_tx;
	
architecture rtl of uart_tx is

	type uart_tx_states is (IDLE, START, DATA, STOP);
	signal next_state : uart_tx_states;
	
	signal frame_cnt		: std_logic_vector(3 downto 0);
	signal tx_buffer_in	: std_logic_vector(9 downto 0);
	signal tx_shift_out	: std_logic_vector(9 downto 0);
	signal tx_serial 		: std_logic;

begin

	counter_c : LPM_COUNTER
		generic map (
			LPM_WIDTH => 4,
			LPM_MODULUS => 10
			)
		port map (
			clock => baud_clk,
			aclr => rst,
			q => frame_cnt
			);
			
	tx_piso_c : LPM_SHIFTREG
		generic map (
			LPM_WIDTH => 10
			)
		port map (
			clock => baud_clk,
			aclr => rst,
			data => tx_buffer_in,
			shiftout => tx_serial
			);
			
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				next_state <= IDLE;
				tx_shift_out <= (others => '1');	-- IDLE default init
				tx_buffer_in <= (others => '1');	-- IDLE default init
				tx_ready <= '0';
			elsif baud_clk = '1' then
				case next_state is
					-- IDLE
					when IDLE =>
						if data_ready = '1' then
							tx_buffer_in(8 downto 1) <= data_in;
							next_state <= START;
						end if;
					when START =>
						next_state <= DATA;
					when DATA =>
						next_state <= STOP;
					when STOP =>
						next_state <= IDLE;
				end case;
			end if;
		end if;
	end process;
	
end rtl;