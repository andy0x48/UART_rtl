library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity uart_tx is
	generic(
		DBIT	: integer := 8	-- # of data bits
	);
	port(
		clk, rst		: in std_logic;
		baud_tick	: in std_logic;
		data_ready 	: in std_logic;
		data_in		: in std_logic_vector(7 downto 0);
		tx_ready		: out std_logic;
		tx				: out std_logic
	);
end uart_tx ;

architecture rtl of uart_tx is

	type uart_tx_states is (IDLE, START, DATA, STOP);
	signal state_reg, state_next : uart_tx_states;
	
	signal s_reg, s_next 	: unsigned(3 downto 0);
	signal n_reg, n_next 	: unsigned(2 downto 0);
	signal b_reg, b_next 	: std_logic_vector(7 downto 0);
	signal tx_reg, tx_next 	: std_logic;
	
begin

	-- FSM state and data registers
	process(clk, rst)
	begin
		if rst = '1' then
			state_reg <= IDLE;
			s_reg <= (others => '0');
			n_reg <= (others => '0');
			b_reg <= (others => '0');
			tx_reg <= '1';
		elsif rising_edge(clk) then
			state_reg <= state_next;
			s_reg <= s_next;
			n_reg <= n_next;
			b_reg <= b_next;
			tx_reg <= tx_next;
		end if ;
	end process;
	
	-- next_state logic & data path functional units/routing
	process(state_reg, s_reg, n_reg, b_reg, baud_tick, tx_reg, data_ready, data_in)
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		n_next <= n_reg;
		b_next <= b_reg;
		tx_next <= tx_reg; 
		tx_ready <= '0';
		
		case state_reg is
			-- IDLE
			when IDLE =>
				tx_next <= '1' ;
				if data_ready = '1' then
					state_next <= START;
					s_next <= (others => '0');
					b_next <= data_in;
				end if;
			-- START
			when START =>
				tx_next <= '0';
				if (baud_tick = '1') then
					if s_reg = 15 then
						state_next <= DATA;
						s_next <= (others => '0');
						n_next <= (others => '0');
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			-- DATA
			when DATA =>
				tx_next <= b_reg(0);
				if (baud_tick = '1') then
					if s_reg = 15 then
						s_next <= (others => '0');
						b_next <= '0' & b_reg(7 downto 1); --concat
						if n_reg = (DBIT - 1) then
							state_next <= STOP;
						else
							n_next <= n_reg + 1;
						end if;
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			-- STOP
			when STOP =>
				tx_next <= '1';
				if (baud_tick = '1') then
					if s_reg = 15 then
						state_next <= IDLE;
						tx_ready <= '1';
					else
						s_next <= s_reg + 1;
					end if;
				end if;
		end case;
	end process;
	
	tx <= tx_reg;
	
end rtl; 