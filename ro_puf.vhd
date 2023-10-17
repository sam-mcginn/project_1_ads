library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- ring oscillator physical unclonable function
entity ro_puf is
	generic (
		-- RO chain length
		ro_length: natural := 12;
		-- Number of RO chains
		ro_count: natural := 16		-- FIX - check that ro_count = power of two
	);
	port (
		-- Asynchronous active-low reset for counters
		reset: in std_logic;
		-- Active-high enable signal for counters
		enable: in std_logic;
		-- PUF challenge input:
		-- lower bits select a counter from first group of ROs, upper bits select from second group
		challenge: in std_logic_vector(7 downto 0); -- FIX - need ro_count/2 -1 downto 0?
		-- PUF response output:
		-- returns 1 if value of first group counter is less than second, 0 if second < first
		response: out std_logic
	);
end entity ro_puf;

architecture ro_puf_arch of ro_puf is
 -- FIX - need signal for each ro output to connect to count input
	signal ro_value: std_logic_vector(0 to ro_count-1);
	signal count_value: counter_value_type(0 to ro_count-1);
begin
	ro_chain: for i in 0 to ro_count-1 generate
		ro0: ring_oscillator
			generic map (
				num_stages => ro_length
			)
			port map (
				ro_enable => enable,
				ro_out => ro_value(i)
			);
		count0: counter
			port map (
				count_reset => reset,
				count_enable => enable,
				count_input => ro_value(i),
				count_output => count_value(i)
			);
	end generate ro_chain;
end architecture ro_puf_arch;