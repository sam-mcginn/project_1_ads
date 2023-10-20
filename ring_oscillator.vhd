library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project1_pkg.all;

-- ring oscillator
entity ring_oscillator is
	generic (
		-- one NAND gate + (num_stages-1) inverters
		num_stages: natural := 13
	);
	port (
		ro_enable: in std_logic;
		ro_out: out std_logic
	);
end entity ring_oscillator;

architecture ro_arch of ring_oscillator is
	signal ro_nodes: std_logic_vector(0 to num_stages-1);
	attribute keep: boolean;
	attribute keep of ro_nodes: signal is true;
begin
	-- Check for invalid num_stages input
	assert num_stages mod 2 = 1
		report "ro_length must be an odd number"
		severity failure;
	
	-- Drive output from output of last inverter
	ro_out <= ro_nodes(num_stages-1);
	
	-- one NAND gate
	nand_stage: my_nand2
		port map (
			a => ro_enable,
			b => ro_nodes(num_stages-1), -- output of last inverter
			output => ro_nodes(0) -- input to first inverter
		);
	
	-- Num_stages-1 inverters
	inverter_chain: for num in 0 to num_stages-2 generate
		u0: my_inverter
			port map (
				input => ro_nodes(num),
				output => ro_nodes(num+1)
			);
	end generate inverter_chain;
	
end architecture ro_arch;