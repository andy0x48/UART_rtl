library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity baud_generator_tb is
end baud_generator_tb;
	
architecture tb of baud_generator_tb is

	component baud_generator
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			baud_tick	: out std_logic
			);
	end component;
	
	signal clk_tb			: std_logic := '0';
	signal rst_tb			: std_logic := '0';
	signal baud_tick_tb	: std_logic := '0';
	
	constant CLK_PERIOD : time := 20 ns;

begin

	uut: baud_generator
		port map(
			clk			=> clk_tb,
			rst			=> rst_tb,
			baud_tick	=> baud_tick_tb
			);

	clk_process: process
	begin
		clk_tb <= '0';
		wait for CLK_PERIOD / 2;
		clk_tb <= '1';
		wait for CLK_PERIOD / 2;
	end process;
	
	stim_process: process
	begin
		-- Apply Reset
		rst_tb <= '1';
		wait for 100 ns; 

		-- Release Reset
		rst_tb <= '0';
		wait for 1 us;
		
		-- Apply Reset
		rst_tb <= '1';
		wait for 100 ns;
		
		-- Release Reset
		rst_tb <= '0';
		wait for 1 us;
		
		-- Apply Reset
		rst_tb <= '1';
		wait for 100 ns;
		
		-- Release Reset
		rst_tb <= '0';
		wait for 927 ns;
		
		-- Apply Long Reset
		rst_tb <= '1';
		wait for 334 ns;
		
		-- Release Reset
		rst_tb <= '0';
		wait for 1 us;

		report "Simulation Complete" severity note;
		wait;
	end process;
	
end tb;