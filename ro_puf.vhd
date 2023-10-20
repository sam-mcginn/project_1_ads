library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- ring oscillator physical unclonable function
entity ro_puf is
	generic (
		-- RO chain length
		ro_length: natural := 13;
		-- Number of RO chains
		ro_count: natural := 16;
		-- Challenge bit width
		challenge_bit_width: natural := 6
	);
	port (
		-- Asynchronous active-low reset for counters
		reset: in std_logic;
		-- Active-high enable signal for counters
		enable: in std_logic;
		-- PUF challenge input:
		-- lower bits select a counter from first group of ROs, upper bits select from second group
		challenge: in std_logic_vector(challenge_bit_width - 1 downto 0); -- FIX - need ro_count/2 -1 downto 0?
		-- PUF response output:
		-- returns 1 if value of first group counter is less than second, 0 if second < first
		response: out std_logic
	);
end entity ro_puf;

architecture ro_puf_arch of ro_puf is
 -- FIX - need signal for each ro output to connect to count input
	signal ro_value: std_logic_vector(0 to ro_count-1);
	signal count_value: counter_value_type(0 to ro_count-1);
	signal ro_first_select: std_logic_vector(0 to ro_count/2);
	
	signal select_vect_a: std_logic_vector(challenge_bit_width/2 - 1 downto 0);
	signal select_vect_b: std_logic_vector(challenge_bit_width/2 - 1 downto 0);
	signal counter_val_a: natural;
	signal counter_val_b: natural;
	
	-- Function to check if a number is a power of two
	function is_power_two ( n: in positive ) return boolean
	is
		variable t1: std_logic_vector(31 downto 0);
		variable t2: std_logic_vector(31 downto 0);
		variable t3: std_logic_vector(31 downto 0);
	begin
		t1 := std_logic_vector(to_unsigned(n, 32));
		t2 := std_logic_vector(to_unsigned(n-1, 32));
		-- clear the lowest bit that is set by doing bitwise anding of n and n-1
		t3 := t1 and t2;
		-- if n is a power of 2, then we would clear its only set bit, so t3 should be 0
		return to_integer(unsigned(t3))=0;
	end function is_power_two;
begin
	-- Check if ro_count is a power of two
	assert is_power_two(ro_count)
		report "ro_count must be a power of two"
		severity failure;

	select_vect_a <= challenge(challenge_bit_width/2 - 1 downto 0);
	select_vect_b <= challenge(challenge_bit_width - 1 downto challenge_bit_width/2);
	
	counter_val_a <= count_value(to_integer(unsigned(select_vect_a)));
	counter_val_b <= count_value(ro_count/2 + to_integer(unsigned(select_vect_b)));
	
	response <= '1' when counter_val_a > counter_val_b else '0';
	
	ro_chain: for i in 0 to ro_count-1 generate
	-- first group: ro_count/2 - 1 to 0
	-- second group: ro_count/2 to ro_count-1
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