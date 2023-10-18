library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- top-level ring oscillator system
entity project1_ads is
	generic (
		-- Frequency of FPGA's clock (in MHz)
		clock_freq: natural := 50;
		-- Time to pass before probing response  of ro_puf entity (in us)
		probe_delay: positive := 500;
		-- RO chain length
		ro_length: natural := 12;
		-- number of RO chains
		ro_count: natural := 16
	);
	port (
		-- Asynchronous active-low reset from control unit
		reset: out std_logic;			-- FIX ?
		-- FPGA clock
		clock: in std_logic;
		-- Active-high done signal
		done: out std_logic;
		-- Enable signal from control unit
		top_enable: out std_logic;		-- FIX ?
		-- Enable signal to counters
		counts_en: in std_logic;		-- FIX ?
		-- Active-low reset to counters
		counts_reset: in std_logic			-- FIX ?
	);
end entity project1_ads;

architecture top_level of project1_ads is
	signal top_level_en: std_logic := '0';		-- FIX
	signal counter_selects: std_logic_vector(ro_count/2 -1 downto 0) := (others => '0');
	signal compare_result: std_logic;
begin
	my_ro_puf: ro_puf
		generic map (
			ro_length => ro_length,
			ro_count => ro_count,
			challenge_bit_width => ro_count/2 -1
		)
		port map (
			reset => counts_reset,
			enable => counts_en, -- FIX need to get enable output from control --> enable input to ro_puf
			-- lower bits select a counter from first group of ROs, upper bits select from second group
			challenge => counter_selects, -- FIX - need ro_count/2 -1 downto 0?
			-- returns 1 if value of first group counter is less than second, 0 if second < first
			response => compare_result
		);
	
	-- FIX - control unit instance
	
	
	-- FIX - BRAM ?
	
	
end architecture top_level;