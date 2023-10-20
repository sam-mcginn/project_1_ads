library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

entity counter is
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
end entity counter;

architecture counter_arch of counter is
	signal store: natural := 0;
begin
	count_output <= store;
	
	update_count: process(count_input, count_reset) is
	begin
		if count_reset='0' then
			store <= 0;
		elsif rising_edge(count_input) then
			if count_enable='1' then
				store <= store + 1;
			end if;
		end if;
	end process update_count;
		
end architecture counter_arch;