library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- wait_cycles(clk, n)
--		Waits 'n' number of clock cycles on the rising edge.
 
-- set_seed(s1, s2)
--		Set integer number seeds for pseudorandom number generator.

-- rand_int(min, max)
--		Inclusive range for random interger numbers.

package tb_utils_pkg is
	
	procedure wait_cycles(
		signal clk	: in std_logic;
		n	: in natural
	);
	
	procedure set_seed(
		s1, s2	: integer
	);

	impure function rand_int(
		min, max	: integer
	) return integer;
	
end package;

package body tb_utils_pkg is
	
	-- N clk period wait
	procedure wait_cycles(
		signal clk 	: in std_logic;
		n	: in natural
	) is
	begin
		for i in 1 to n loop
			wait until rising_edge(clk);
		end loop;
	end procedure;
	
	-- rand function
	shared variable seed1 : integer := 1;
	shared variable seed2 : integer := 1;
	
	-- set seed
	procedure set_seed(
		s1, s2	: integer
	) is 
	begin
		seed1 := s1;
		seed2 := s2;
	end procedure;
	
	impure function rand_int(
		min, max		: integer
	) return integer is
		variable r : real;
	begin
		uniform(seed1, seed2, r);
		return min + integer(floor(r * (real(max - min + 1) - 0.00001)));
	end function;

end package body;