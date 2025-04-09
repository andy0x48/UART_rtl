library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tb_utils_pkg.all;

entity uart_rx is
	generic(
		DBIT	: integer := 8	-- # of data bits
	);
	port(
		clk, rst		: in std_logic;
		baud_tick	: in std_logic;
		rx				: in std_logic;
		rx_ready		: out std_logic;
		data_out		: out std_logic_vector(7 downto 0)
	);
end uart_rx ;

architecture rtl of uart_rx is

	type uart_rx_states is (IDLE, START, DATA, STOP);
	signal state_reg, state_next : uart_rx_states;
	
	signal s_reg, s_next 	: unsigned(3 downto 0);
	signal n_reg, n_next 	: unsigned(2 downto 0);
	signal b_reg, b_next 	: std_logic_vector(7 downto 0);
	
begin

	-- FSM state and data registers
	process(clk, rst)
	begin
		if rst = '1' then
			state_reg <= IDLE;
			s_reg <= (others => '0');
			n_reg <= (others => '0');
			b_reg <= (others => '0');
		elsif rising_edge(clk) then
			state_reg <= state_next;
			s_reg <= s_next;
			n_reg <= n_next;
			b_reg <= b_next;
		end if ;
	end process;
	
	-- next_state logic & data path functional units/routing
	process(state_reg, s_reg, n_reg, b_reg, baud_tick, rx)
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		n_next <= n_reg;
		b_next <= b_reg;
		rx_ready <= '0';
		
		case state_reg is
			-- IDLE
			when IDLE =>
				if rx = '0' then
					state_next <= START;
					s_next <= (others => '0');
				end if;
			-- START
			when START =>
				if (baud_tick = '1') then
					if s_reg = 7 then
						state_next <= DATA;
						s_next <= (others => '0');
						n_next <= (others => '0');
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			-- DATA
			when DATA =>
				if (baud_tick = '1') then
					if s_reg = 15 then
						s_next <= (others => '0');
						b_next <= rx & b_reg(7 downto 1); --concat
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
				if (baud_tick = '1') then
					if s_reg = 15 then		-- one SB
						state_next <= IDLE;
						rx_ready <= '1';
					else
						s_next <= s_reg + 1;
					end if;
				end if;
		end case;
	end process;
	
	data_out <= b_reg;
	
end rtl; 