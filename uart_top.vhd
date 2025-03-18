library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity uart_top is
	Port(
		clk			: in std_logic;
		rst			: in std_logic;
		baud_rate	: in std_logic;
		data			: in std_logic_vector(7 downto 0);
		data_ready	: in std_logic;
		tx				: out std_logic;
		data_rd_en	: out std_logic
		);
	end uart_top;
	
architecture rtl of uart_top is

	-- FSM
	type state_type is (IDLE, START, DATA, STOP);
	signal state : state_type := IDLE;

	signal counter : std_logic_vector(3 downto 0);
	signal tx_wire : std_logic := '1';	-- IDLE STATE

	
--	ATTRIBUTE
	
	-- lpm counter needed
	-- lpm shift reg needed

begin

	tx <= tx_wire;

	counter : LPM_COUNTER
		generic map (
			LPM_WIDTH => 4,
			LPM_MODULUS => 10
			)
		port map (
			clock => clk,
			q => counter
			);
			
	piso : LPM_SHIFTREG
		generic map (
			LPM_WIDTH => 10,
			LPM_DIRECTION => "LEFT",
			LPM_PVALUE => (others => '1')
			)
		 port map (
			data => data,
			clock => baud_rate,
			shiftout => tx_wire
			);

	process(clk, rst) : uart_asm
	begin
		if rst = '1'; then
			state <= IDLE;
			tx 	<= '1';
			
		
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
				
			end case;
		end if;
	end process;

end rtl;