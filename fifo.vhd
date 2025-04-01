library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tb_utils_pkg.all;

entity fifo is
	generic(
		DWIDTH 	: integer := 8;
		ADDR		: integer := 4
	);
	port(
		clk, rst		: in std_logic;
		rd, wr		: in std_logic;
		w_data		: in std_logic_vector(DWIDTH - 1 downto 0);
		r_data		: out std_logic_vector(DWIDTH - 1 downto 0);
		empty, full : out std_logic
		);
end fifo;
	
architecture rtl of fifo is
	
	type reg_file_type is array (2 ** ADDR - 1 downto 0) of
		std_logic_vector(DWIDTH - 1 downto 0);
	signal array_reg : reg_file_type := (others => (others => '0'));
	
	signal w_ptr_reg, w_ptr_next, w_ptr_succ : unsigned(ADDR - 1 downto 0);
	signal r_ptr_reg, r_ptr_next, r_ptr_succ : unsigned(ADDR - 1 downto 0);
	signal full_reg, empty_reg, full_next, empty_next : std_logic;
	
	signal wr_op : std_logic_vector(1 downto 0);
	signal wr_en : std_logic;
	signal rd_en : std_logic;
	
begin
	
	-- registers for sync write/read
	process(clk)
	begin
		if rising_edge(clk) then 
			if wr_en = '1' then
				array_reg(to_integer(w_ptr_reg)) <= w_data;
			end if;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if rst = '1' then
			r_data <= (others => '0');
		elsif rising_edge(clk) then 
			if rd_en = '1' then
				r_data <= array_reg(to_integer(r_ptr_next));
			end if;
		end if;
	end process;
	
	-- enable w/r when FIFO not full/not empty
	wr_en <= wr and (not full_reg);
	rd_en <= rd and (not empty_reg);
	
	-- FIFO control logic
	-- FF for r/w ptr's
	process(clk, rst)
	begin
		if rst = '1' then
			w_ptr_reg <= (others => '0');
			r_ptr_reg <= (others => '0');
			full_reg <= '0';
			empty_reg <= '1';
		elsif rising_edge(clk) then
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
			full_reg <= full_next;
			empty_reg <= empty_next;
		end if;
	end process;
	
	-- moore state machine with next state logic, and successive ptr vals
	w_ptr_succ <= unsigned(w_ptr_reg + 1);
	r_ptr_succ <= unsigned(r_ptr_reg + 1);
	
	wr_op <= wr & rd; -- w/r states
	
	process(wr_op, w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, full_reg, empty_reg)
	begin
		w_ptr_next <= w_ptr_reg;
		r_ptr_next <= r_ptr_reg;
		full_next <= full_reg;
		empty_next <= empty_reg;
		
		case wr_op is
			-- idle
			when "00" =>
			-- read
			when "01" =>
				if empty_reg = '0' then		-- empty check
					r_ptr_next <= r_ptr_succ;
					full_next <= '0';
					if r_ptr_succ = w_ptr_reg then
						empty_next <= '1';
					end if;
				end if;	
			-- write
			when "10" =>
				if full_reg = '0' then 		-- full check
					w_ptr_next <= w_ptr_succ;
					empty_next <= '0';
					if w_ptr_succ = r_ptr_reg then
						full_next <= '1';
					end if;
				end if;	
			-- w/r
			when others =>
				w_ptr_next <= w_ptr_succ;
				r_ptr_next <= r_ptr_succ;
		end case;
	end process;

	full <= full_reg;
	empty <= empty_reg;
	
end rtl;