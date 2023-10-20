library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_nand2 is
	port (
		a: in std_logic;
		b: in std_logic;
		output: out std_logic
		);
end entity my_nand2;

architecture nand2_arch of my_nand2 is
begin
	nand_gate: process(a,b) is
	begin
		if (a='1' and b='1') then
			output <= '0';
		else
			output <= '1';
		end if;
	end process nand_gate;
end architecture nand2_arch;