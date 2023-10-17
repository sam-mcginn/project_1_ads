library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- control unit for ring oscillator system
entity project1_ads is
	generic (
		-- FIX - default values ?
		
		-- Frequency of FPGA's clock (in Hz)
		clock_freq: natural := 10;
		-- Time to pass before probing response  of ro_puf entity (in us)
		probe_delay: positive := 10;
		-- RO chain length
		ro_length: natural := 12;
		-- number of RO chains
		ro_count: natural := 16
	);
	port (
		-- Asynchronous active-low reset for control unit
		reset: in std_logic;
		-- FPGA clock
		clock: in std_logic;
		-- Active-high done signal
		done: out std_logic
	);
end entity project1_ads;

architecture top_level of project1_ads is
	signal top_level_en: std_logic := '0';
	signal counter_selects: std_logic_vector(7 downto 0); -- FIX - need ro_count/2 -1 downto 0?
	signal compare_result: std_logic;
begin
	my_ro_puf: ro_puf
		generic map (
			ro_length => ro_length,
			ro_count => ro_count		-- FIX - check that ro_count = power of two
		)
		port map (
			reset => reset,
			enable => top_level_en,
			-- lower bits select a counter from first group of ROs, upper bits select from second group
			challenge => counter_selects, -- FIX - need ro_count/2 -1 downto 0?
			-- returns 1 if value of first group counter is less than second, 0 if second < first
			response => compare_result
		);
	
	-- control unit 
	
	-- BRAM ?
	
	
end architecture top_level;