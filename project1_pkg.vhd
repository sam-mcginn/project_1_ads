library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package project1_pkg is
	type counter_value_type is array(natural range <>) of natural;

	component my_inverter is
		port (
			input: in std_logic;
			output: out std_logic
		);
	end component my_inverter;
	
	component my_nand2 is
	port (
		a: in std_logic;
		b: in std_logic;
		output: out std_logic
	);
	end component my_nand2;

	component ring_oscillator is
		generic (
			-- one NAND gate + (num_stages-1) inverters
			num_stages: natural := 13
		);
		port (
			ro_enable: in std_logic;
			ro_out: out std_logic
		);
	end component ring_oscillator;
	
	-- ring oscillator physical unclonable function
	component ro_puf is
		generic (
			-- RO chain length
			ro_length: natural := 12;
			-- Number of RO chains
			ro_count: natural := 16		-- FIX - check that ro_count = power of two
		);
		port (
			-- Asynchronous active-low reset for counters
			reset: in std_logic;
			-- Active-high counters enable signal
			enable: in std_logic;
			-- PUF challenge input
			challenge: in std_logic_vector(7 downto 0); -- FIX - need ro_count/2 -1 downto 0?
			-- PUF response output
			response: out std_logic
		);
	end component ro_puf;	
	
	component counter is
		port (
			-- Active-low reset
			count_reset: in std_logic;
			-- Active-high enable
			count_enable: in std_logic;
			-- Input signal
			count_input: in std_logic;
			-- Count output
			count_output: out natural
		);
	end component counter;
	
	
	
end package project1_pkg;

package body project1_pkg is
end package body project1_pkg;