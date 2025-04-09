library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tb_utils_pkg.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture tb of uart_rx_tb is

	signal clk	: std_logic := '0';
   signal rst	: std_logic := '1';
	
   signal baud_tick    	: std_logic := '0';
   signal data_out     	: std_logic_vector(7 downto 0) := (others=> '0');
   signal rx_ready 		: std_logic;
	signal rx           	: std_logic;

	constant CLK_PERIOD : time := 20 ns;
	
	-- sim report
   signal test_phase    : string(1 to 30) := (others => ' '); -- col 55

begin

	uut: entity work.uart_rx
      generic map(
         DBIT    => 8
      )
      port map(
			clk         => clk,
			rst       	=> rst,
			baud_tick   => baud_tick,
			data_out    => data_out,
			rx_ready 	=> rx_ready,
			rx          => rx
      );
		
	baud_gen_inst: entity work.baud_generator
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

	-- Stimulus process
	stimulus_process: process
		-- TB Procedures
		----------------
		procedure test_reset is
		begin
			test_phase <= "test_reset                    ";
			rst <= '1';
			wait_cycles(clk, 2);
			rst <= '0';
			wait_cycles(clk, 1);
			
			assert rx_ready = '0'
				report "test_reset: RX_READY not cleared"
				severity error;
				
			assert data_out = "00000000"
				report "test_reset: DATA_OUT not cleared"
				severity error;
		end procedure;
		
		-- needs to be x16 less than baud tick *oversample* rate
		procedure tb_send_byte(
			tb_data_in : std_logic_vector(7 downto 0)
		) is
		begin
			-- start
			rx <= '0';
			for i in 0 to 15 loop
				wait until baud_tick = '1';
			end loop;
			
			-- data
			for i in 0 to 7 loop
				rx <= tb_data_in(i);
				for i in 0 to 15 loop
					wait until baud_tick = '1';
				end loop;
			end loop;
			
			-- stop
			rx <= '1';
			for i in 0 to 15 loop
				wait until baud_tick = '1';
			end loop;
		end procedure;
		
		variable random_val : std_logic_vector(7 downto 0);
		
		procedure test_rx_byte(
			exp_data : std_logic_vector(7 downto 0)
		) is
		begin
			test_phase <= "test_rx_byte                  ";
			tb_send_byte(exp_data);
			
			assert data_out = exp_data
				report "Byte rx'd mismatch; exp= 0x" 
					& slv_to_hex(exp_data) & " rxd= 0x"
					& slv_to_hex(data_out)
				severity error;
		end procedure;
		----------------
	
	begin
		set_seed(12, 34);
		
		test_reset;
		
		-- send random bytes
		for i in 0 to 15 loop
			random_val := std_logic_vector(to_unsigned(rand_int(0, 255), 8));
			test_rx_byte(random_val);
			--wait_cycles(clk, 5);
		end loop;

      -- End simulation
		wait_cycles(clk, 5);
		report "PASS: Simulation Complete" severity note;
      wait;
	end process;

end tb;
