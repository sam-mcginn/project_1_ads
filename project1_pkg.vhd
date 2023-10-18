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
			ro_count: natural := 16;
			-- Challenge bit width
			challenge_bit_width: natural := 8
		);
		port (
			-- Asynchronous active-low reset for counters
			reset: in std_logic;
			-- Active-high counters enable signal
			enable: in std_logic;
			-- PUF challenge input
			challenge: in std_logic_vector(challenge_bit_width downto 0); -- FIX - need ro_count/2 -1 downto 0?
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
	
	component control_unit is
		generic (
			-- Frequency of FPGA's clock (in MHz):
			clock_freq: natural := 50;
			-- Time to pass before probing response  of ro_puf entity (in us):
			probe_delay: positive := 500;
			-- Challenge input size
			challenge_bits: positive := 6
		);
		port (
			-- System reset:
			sys_reset: in std_logic;
			-- System enable:
			sys_enable: in std_logic;
			-- FPGA clock:
			clock: in std_logic;
			-- Active-high done signal:
			done: out std_logic;
			-- Asynchronous active-low reset from control unit to counters:
			puf_reset: out std_logic;
			-- Enable signal from control unit to counters:
			puf_enable: out std_logic;
			-- Count output from control unit to counters:
			challenge_out: out std_logic_vector(0 to challenge_bits);
			-- Response output to store
			store_response: out std_logic
		);
	end component control_unit;
	
end package project1_pkg;

package body project1_pkg is
end package body project1_pkg;