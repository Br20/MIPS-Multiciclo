LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


ENTITY Mux IS
PORT(
	a,b: IN std_logic_vector (31 downto 0);
	sel : IN std_logic;
	q: OUT std_logic_vector (31 downto 0));              
END Mux;



--	Arquitectura con procesos explicitos
ARCHITECTURE PRACTICA OF Mux IS 
	signal valor: std_logic_vector (31 downto 0);
BEGIN


	
	process(sel,a,b)
	begin
		if (sel = '0') then
			valor <= a;
		elsif (sel = '1') then	
			valor <= b;
		end if;
		q <= valor;
	end process;
         
END PRACTICA;     


-- Arquitectura con asignaciones concurrentes

ARCHITECTURE PRACTICA OF Mux IS 
BEGIN

   q <=  a when sel='0' else 
         b when sel='1';
         
END PRACTICA;     