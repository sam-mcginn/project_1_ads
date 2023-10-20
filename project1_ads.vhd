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
		ro_length: natural := 13;
		-- number of RO chains
		ro_count: natural := 16
	);
	port (
		-- Asynchronous active-low reset from control unit
		reset: in std_logic;			-- FIX ?
		-- FPGA clock
		clock: in std_logic;
		-- Active-high done signal
		done: out std_logic
		-- Enable signal from control unit
		--top_enable: out std_logic;		-- FIX ?
		-- Enable signal to counters
		--counts_en: in std_logic;		-- FIX ?
		-- Active-low reset to counters
		--counts_reset: in std_logic			-- FIX ?
	);
end entity project1_ads;

architecture top_level of project1_ads is
	signal counter_selects: std_logic_vector(5 downto 0) := (others => '0');
	signal compare_result: std_logic_vector(0 downto 0);
	signal puf_enable: std_logic;
	signal puf_reset: std_logic;
	signal store_response: std_logic;
begin
	my_ro_puf: ro_puf
		generic map (
			ro_length => ro_length,
			ro_count => ro_count,
			challenge_bit_width => 6
		)
		port map (
			reset => puf_reset,
			enable => puf_enable, -- FIX need to get enable output from control --> enable input to ro_puf
			-- lower bits select a counter from first group of ROs, upper bits select from second group
			challenge => counter_selects, -- FIX - need ro_count/2 -1 downto 0?
			-- returns 1 if value of first group counter is less than second, 0 if second < first
			response => compare_result(0)
		);
	
	-- FIX - control unit instance
	ctrl0: control_unit
		generic map (
				clock_freq => 50,
				-- Time to pass before probing response  of ro_puf entity (in us):
				probe_delay => 500,
				-- Challenge input size
				challenge_bits => 3
			)
		port map (
			-- System reset:
			sys_reset => reset,
			-- System enable:
			sys_enable => '1',
			-- FPGA clock:
			clock => clock,
			-- Active-high done signal:
			done => done,
			-- Asynchronous active-low reset from control unit to counters:
			puf_reset => puf_reset,
			-- Enable signal from control unit to counters:
			puf_enable => puf_enable,
			-- Count output from control unit to counters:
			challenge_out => counter_selects,
			-- Response output to store
			store_response => store_response
		);

	
	-- FIX - BRAM ?
	block_memory_inst : block_memory PORT MAP (
		address	 => counter_selects,
		clock	 => clock,
		data	 => compare_result,
		wren	 => store_response,
		q	 => open
	);

	
end architecture top_level;