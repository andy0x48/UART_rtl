library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library LPM;
use LPM.LPM_COMPONENTS.ALL;

entity uart_top is
	port(
		clk		: in std_logic;
		rst		: in std_logic;
		--data		: in std_logic_vector(7 downto 0); -- not needed at the moment
		tx			: out std_logic
	);
	end uart_top;
	
architecture rtl of uart_top is

	signal data_ready 	: std_logic := '0';
	signal tx_ready 		: std_logic := '0';
	signal baud_tick 		: std_logic := '0';
	
	-- temp signals
	signal temp_data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal send_pulse    : std_logic := '0';

	signal char_index  : integer range 0 to 11 := 0;
	type char_array is array (0 to 11) of std_logic_vector(7 downto 0);
	constant message : char_array := (
		x"48",  -- H
      x"65",  -- e
		x"6C",  -- l
		x"6C",  -- l
		x"6F",  -- o
		x"20",  -- 
		x"57",  -- W
		x"6F",  -- o
		x"72",  -- r
		x"6C",  -- l
		x"64",  -- d
		x"21"   -- !
	);
	
	-- Baud Gen
	component baud_generator
		port(
			clk       : in std_logic;
			rst       : in std_logic;
			baud_tick : out std_logic
		);
	end component;
	
	-- UART TX
	component uart_tx
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

begin

	c_uart_tx : uart_tx
		generic map(
			DBIT    => 8
		)
		port map(
			clk         => clk,
			rst       	=> rst,
			data_ready  => data_ready,
			baud_tick   => baud_tick,
			data_in     => temp_data_in,
			tx_ready 	=> tx_ready,
			tx          => tx
		);
		  
	c_baud_gen: baud_generator
		port map(
			clk       => clk,
			rst       => rst,
			baud_tick => baud_tick
		);

	-- Load next character after each transmission
process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                char_index <= 0;
                data_ready <= '0';
                send_pulse <= '1';
                temp_data_in <= (others => '0');
            else
                -- Default state
                data_ready <= '0';
                
                -- Handle initial priming (first character after reset)
                if send_pulse = '1' then
                    data_ready <= '1';
                    temp_data_in <= message(char_index);
                    send_pulse <= '0';
                
                -- Normal operation (handshake with transmitter)
                elsif tx_ready = '1' then
                    data_ready <= '1';
                    temp_data_in <= message(char_index);
                    
                    -- Increment index (with wrap-around)
                    if char_index < 11 then
                        char_index <= char_index + 1;
                    else
                        char_index <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;

end rtl;