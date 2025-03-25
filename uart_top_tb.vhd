library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_top_tb is
end uart_top_tb;

architecture tb of uart_top_tb is
    -- Component declaration
    component uart_top
        port(
            clk  : in std_logic;
            rst  : in std_logic;
            tx   : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk_tb  : std_logic := '0';
    signal rst_tb  : std_logic := '1';
    signal tx_tb   : std_logic;

    constant CLK_PERIOD : time := 20 ns;  -- Adjust based on your FPGA clock speed

begin
    -- Instantiate UART Top
    uut: uart_top
        port map(
            clk  => clk_tb,
            rst  => rst_tb,
            tx   => tx_tb
        );

    -- Clock Process
    clk_process: process
	 begin
		clk_tb <= '0';
		wait for CLK_PERIOD / 2;
		clk_tb <= '1';
		wait for CLK_PERIOD / 2;
	 end process;

    -- Test Process
    test_process: process
    begin
        -- Initial Reset
        rst_tb <= '1';
        wait for 100 ns;
        rst_tb <= '0';
        wait for 10 ns;

        -- Allow UART transmission to start
        wait for 10 ms;  -- Allow enough time for transmission
        report "Simulation completed." severity note;

        wait;
    end process;

end tb;
