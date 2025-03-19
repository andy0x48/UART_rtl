library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity uart_tx_tb is
end uart_tx_tb;
	
architecture tb of uart_tx_tb is

	component uart_tx
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			baud_clk		: in std_logic;
			data_in		: in std_logic_vector(7 downto 0);
			data_ready	: in std_logic;
			tx				: out std_logic;
			tx_ready		: out std_logic
			);
	end component;
	
	component baud_generator
		port(
			clk       : in std_logic;
			rst       : in std_logic;
			baud_rate : out std_logic
		);
	end component;
	
	signal clk_tb			: std_logic := '0';
	signal rst_tb			: std_logic := '0';
	signal baud_clk_tb	: std_logic := '0';
	signal data_in_tb		: std_logic_vector(7 downto 0) := (others => '0');
	signal data_ready_tb	: std_logic := '0';
	signal tx_tb			: std_logic := '0';
	signal tx_ready_tb	: std_logic := '0';
	
	constant CLK_PERIOD : time := 20 ns;

begin

	uut: uart_tx
		port map(
			clk			=> clk_tb,
			rst			=> rst_tb,
			baud_clk		=> baud_clk_tb,
			data_in		=> data_in_tb,
			data_ready	=> data_ready_tb,
			tx				=> tx_tb,
			tx_ready		=> tx_ready_tb
			);
			
	baud_gen_inst: baud_generator
		port map(
			clk       => clk_tb,
			rst       => rst_tb,
			baud_rate => baud_clk_tb
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
		data_ready_tb <= '0';
		data_in_tb <= "11001011";
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