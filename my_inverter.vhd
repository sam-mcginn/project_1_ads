library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_inverter is
	port (
		input: in std_logic;
		output: out std_logic
	);
end entity my_inverter;

architecture inverter_arch of my_inverter is
begin
	invert_val: process(input) is
	begin
		if input='0' then
			output <= '1';
		else
			output <= '0';
		end if;
	end process invert_val;
end architecture inverter_arch;