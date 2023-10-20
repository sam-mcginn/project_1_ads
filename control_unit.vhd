library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- control unit for ring oscillator system
entity control_unit is
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
			challenge_out: out std_logic_vector(2*challenge_bits - 1 downto 0);
			-- Response output to store
			store_response: out std_logic
		);
end entity control_unit;

architecture fsm of control_unit is
	-- max challenge input (comparing last counters in each group):
	constant max_challenge_input: natural := (4**challenge_bits)-1;
	signal challenge_count: natural range 0 to max_challenge_input := 0;
	signal wait_count: natural range 0 to probe_delay := 0;
	type state_type is (reset_state, enable_state, wait_time, disable, next_challenge, store, all_done);
	signal state, next_state: state_type := reset_state;
	signal last_challenge: boolean := false;
	-- create RAM with enough space for response of all challenge inputs
begin
	-- iterate over all possible challenge inputs:
	-- Assign outputs
	challenge_out <= std_logic_vector( to_unsigned(challenge_count, challenge_out'length) );
	store_response <= '1' when state=store else '0';
	done <= '1' when state=all_done else '0';
	puf_enable <= '1' when (state = enable_state or state = wait_time) else '0';
	puf_reset <= '0' when state=reset_state else '1';
	
	-- Set last challenge logic
	last_challenge <= (challenge_count = max_challenge_input);
	
	-- Set current state to next state, unless reset is asserted
	save_state: process(clock) is
	begin
		if rising_edge(clock) then
			if sys_reset='0' then
				state <= reset_state;
			elsif sys_enable='1' then
				state <= next_state;
			end if;
		end if;
	end process save_state;
	
	-- Wait for probe_delay us
	wait_process: process(clock) is
	begin
		if rising_edge(clock) then
			if sys_reset='0' then
				wait_count <=0;
			elsif  state = wait_time then
				if wait_count < probe_delay then
					wait_count <= wait_count + 1;
				end if;
			end if;
		end if;
	end process wait_process;
	
	-- Set new challenge input to PUF
	challenge_process: process(clock) is
	begin
		if rising_edge(clock) then
			if sys_reset='0' then
				challenge_count <= 0;
			elsif state=next_challenge then
				if challenge_count < max_challenge_input then
					challenge_count <= challenge_count + 1;
				end if;
			end if;
		end if;
	end process challenge_process;
	
	-- Set next state based on current state
	transition_function: process(state, wait_count, last_challenge) is
	begin
		case state is
			when reset_state =>
				next_state <= enable_state;
			when enable_state =>
				next_state <= wait_time;
			when wait_time =>
				if wait_count = probe_delay then
					next_state <= disable;
				else
					next_state <= wait_time;
				end if;
			when disable =>
				next_state <= store;
			when store => next_state <= next_challenge;
			when next_challenge =>
				if last_challenge then
					next_state <= all_done;
				else
					next_state <= store;
				end if;
			when all_done =>
				next_state <= all_done;
			when others =>
				next_state <= reset_state;
		end case;
	end process transition_function;
end architecture fsm;