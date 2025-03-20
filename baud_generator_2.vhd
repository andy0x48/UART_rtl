library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity baud_generator_2 is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		baud_tick	: out std_logic
		);
end baud_generator_2;
	
architecture rtl of baud_generator_2 is

	signal cnt_out	: std_logic_vector(3 downto 0);
	signal tick 	: std_logic_vector(0 downto 0);

begin

	counter_c : LPM_COUNTER
		generic map (
			LPM_WIDTH => 4,
			LPM_MODULUS => 4
			)
		port map (
			clock => clk,
			aclr => rst,
			q => cnt_out
			);
			
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tick(0) <= '0';
			else
				tick(0) <= not cnt_out(0) and not cnt_out(1) and not cnt_out(2) and not cnt_out(3);
			end if;
		end if;
	end process;
	
	
	baud_tick <= tick(0);
	
end rtl;