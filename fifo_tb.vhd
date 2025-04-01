library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tb_utils_pkg.all;

entity fifo_tb is
end fifo_tb;

architecture tb of fifo_tb is

	constant DWIDTH : integer := 8;
	constant ADDR   : integer := 4;
	 
	signal clk   : std_logic := '0';
	signal rst   : std_logic := '1';
   
	signal wr, rd    	: std_logic := '0';
	signal w_data    	: std_logic_vector(DWIDTH - 1 downto 0) := (others => '0');
	signal r_data    	: std_logic_vector(DWIDTH - 1 downto 0);
	signal empty, full 	: std_logic;

	constant CLK_PERIOD : time := 20 ns;
	
	-- sim report
   signal test_phase    : string(1 to 30) := (others => ' '); -- col 55

begin	

	uut: entity work.fifo
      generic map(
			DWIDTH => DWIDTH, 
			ADDR => ADDR
		)
      port map(
         clk   => clk,
         rst   => rst,
         wr    => wr,
         rd    => rd,
         w_data => w_data,
			r_data => r_data,
			empty => empty,
			full  => full
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
			
			assert empty = '1' or full = '0'
				report "test_reset: empty=" & std_logic'image(empty)
					& " full=" & std_logic'image(full) 
				severity error;
		end procedure;
		
		procedure test_write_to_fifo is
		begin
			test_phase <= "test_write_to_fifo            ";
			for i in 0 to (2 ** ADDR - 1) loop
				wr <= '1';
				w_data <= std_logic_vector(to_unsigned(i, DWIDTH));
				wait_cycles(clk, 1);
				
				assert not ((i < 2 ** ADDR - 1) and (full = '1'))
					report "test_write_to_fifo: early full flag @ addr=" & integer'image(i) 
					severity error;
			end loop;
			
			wr <= '0';
			wait_cycles(clk, 1);
			
			assert full = '1'
				report "write to FIFO triggered no full flag" 
				severity error;
		end procedure;
		
		procedure test_read_from_fifo is
		begin
			test_phase <= "test_read_from_fifo           ";
			for i in 0 to (2 ** ADDR - 1) loop
				rd <= '1';
				wait_cycles(clk, 1);
				
				assert r_data = std_logic_vector(to_unsigned(i, DWIDTH))
					report "test_read_from_fifo: data mismatch @ addr=" & integer'image(i)
						& " val: " & integer'image(to_integer(unsigned(r_data)))
						& " exp: " & integer'image(i) 
					severity error;
			end loop;
			
			rd <= '0';
			wait_cycles(clk, 1);
			
			assert empty = '1'
				report "read from FIFO triggered no empty flag" 
			severity error;
		end procedure;
		
		procedure test_write_read_fifo is
		begin
			test_phase <= "test_write_read_fifo          ";
			for i in 0 to 20 loop
				wr <= '1';
				w_data <= std_logic_vector(to_unsigned(i, DWIDTH));
				if i > 2 then
					rd <= '1';
				end if;
				wait_cycles(clk, 1);
			end loop;
			
			wr <= '0';
			rd <= '0';
		end procedure;
		
		procedure test_overflow is
		begin
			test_phase <= "test_overflow                 ";
			for i in 0 to (2 ** ADDR - 1) loop
				wr <= '1';
				w_data <= x"B5";
				wait_cycles(clk, 1);
			end loop;
				
			wr <= '0';
			wait_cycles(clk, 1);
			
			wr <= '1';
			w_data <= x"F3";
			wait_cycles(clk, 3);
			
			assert full = '1'
				report "attempt to write when FIFO full" 
			severity error;
			wr <= '0';
		end procedure;		
		
		procedure test_random_stim_fifo is
		begin
			for i in 1 to 500 loop
				-- 5% rand reset
				if (rand_int(0, 19) = 0) then
					test_reset;
				end if;
				
				-- rand write if FIFO not full
				if (not full = '1') and (rand_int(0, 1) = 1) then
					wr <= '1';
					w_data <= std_logic_vector(to_unsigned(rand_int(0, 255), DWIDTH));
				else
					wr <= '0';
				end if;
				
				-- rand read if FIFO not full
				if (not full = '1') and (rand_int(0, 1) = 1) then
					rd <= '1';
				else
					rd <= '0';
				end if;
				
				wait_cycles(clk, 1);
			end loop;
		end procedure;
		----------------
		
	begin
		set_seed(12, 34);
	
		test_reset;
		
		test_write_to_fifo;
		wait_cycles(clk, 5);
		
		test_read_from_fifo;
		wait_cycles(clk, 5);
		
		test_write_read_fifo;
		wait_cycles(clk, 5);
		
		test_reset;
		
		test_overflow;
		
		test_random_stim_fifo;
		
      -- End simulation
		wait_cycles(clk, 5);
		report "PASS: Simulation Complete" severity note;
      wait;
   end process;

end tb;
