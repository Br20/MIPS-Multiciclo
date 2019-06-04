library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY Reg IS
PORT(
	d: IN std_logic_vector (31 downto 0);
	clk: IN std_logic;
	reset: IN std_logic;
	ce: IN std_logic;
	q: OUT std_logic_vector ( 31 downto 0)
);
END Reg;


ARCHITECTURE PRACTICA OF Reg IS
	signal valor: std_logic_vector(31 downto 0);
BEGIN

	process(clk,d,reset,ce)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				valor <= (others => '0');
			elsif (ce = '0')then
				valor <= (d);
			end if;
		end if;
		q <= valor;
	end process;
END PRACTICA;
		
		
		