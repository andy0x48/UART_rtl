library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx_tb is
end uart_tx_tb;

architecture tb of uart_tx_tb is

    component draft_uart_tx
        generic(
            DBIT	: integer := 8
        );
        port(
            clk         : in std_logic;
            rst        	: in std_logic;
            data_ready 	: in std_logic;
            baud_tick   : in std_logic;
            data_in     : in std_logic_vector(7 downto 0);
            tx_ready 	: out std_logic;
            tx          : out std_logic
        );
    end component;
	 
	 component baud_generator
		port(
			clk       : in std_logic;
			rst       : in std_logic;
			baud_tick : out std_logic
		);
	 end component;

    signal clk          : std_logic := '0';
    signal rst        	: std_logic := '1';
    signal data_ready	: std_logic := '0';
    signal baud_tick    : std_logic := '0';
    signal data_in     	: std_logic_vector(7 downto 0) := (others=> '0');
    signal tx_ready 		: std_logic;
    signal tx           : std_logic;

    constant CLK_PERIOD	: time := 20 ns;

begin

	 uut: draft_uart_tx
        generic map(
            DBIT    => 8
        )
        port map(
            clk         => clk,
            rst       	=> rst,
            data_ready  => data_ready,
            baud_tick   => baud_tick,
            data_in     => data_in,
            tx_ready 	=> tx_ready,
            tx          => tx
        );
		  
	 baud_gen_inst: baud_generator
		port map(
			clk       => clk,
			rst       => rst,
			baud_tick => baud_tick
		);

    clk_process: process
	 begin
		clk <= '0';
		wait for CLK_PERIOD / 2;
		clk <= '1';
		wait for CLK_PERIOD / 2;
	 end process;

    stimulus_process: process
    begin
        -- rst
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Send first byte
        data_in <= "01010001";
        data_ready <= '1';
        wait for CLK_PERIOD;
        data_ready <= '0';

        -- Wait for transmission to complete
        wait until tx_ready = '1';
        wait for 200 ns;

        -- Send second byte
        data_in <= "01011010";
        data_ready <= '1';
        wait for CLK_PERIOD;
        data_ready <= '0';

        -- Wait for transmission to complete
        wait until tx_ready = '1';
        wait for 200 ns;

        -- End simulation
        report "Simulation Complete" severity note;
        wait;
    end process;

end tb;
