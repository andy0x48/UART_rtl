library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- wait_cycles(clk, n)
--		Waits 'n' number of clock cycles on the rising edge.
 
-- set_seed(s1, s2)
--		Set integer number seeds for pseudorandom number generator.

-- rand_int(min, max)
--		Inclusive range for random integer numbers.

-- to_hex_char(n)
--      Converts an integer (0-15) to its corresponding hex character (0-F).

-- slv_to_hex(slv)
--      Converts a std_logic_vector to a hex string representation. 
--      The length of the input vector should be a multiple of 4.


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
	
	function to_hex_char(
		n : integer
	) return character;
	
	function slv_to_hex(
		slv : std_logic_vector
	) return string;
	
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
	
	-- hex chars
	function to_hex_char(
		n : integer
	) return character is
		constant hex_chars : string := "0123456789ABCDEF";
	begin
		return hex_chars(n + 1);
	end function;
	
	-- convert slv to hex
	function slv_to_hex(
		slv : std_logic_vector
	) return string is
		variable hex_len 	: integer := slv'length / 4;
		variable result 	: string(1 to hex_len);
		variable nibble 	: std_logic_vector(3 downto 0);
	begin
		for i in 0 to hex_len - 1 loop
			nibble := slv((slv'high - (i * 4)) downto (slv'high - (i * 4) - 3));
			result(hex_len - i) := to_hex_char(to_integer(unsigned(nibble)));
		end loop;
		return result;
	end function;

end package body;