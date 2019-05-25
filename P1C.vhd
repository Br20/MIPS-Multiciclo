library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;


ENTITY ALU is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0);
           zero : out STD_LOGIC
        );
end ALU;

architecture PRACTICA of ALU is
signal aux: std_logic_vector(31 downto 0);
begin

process(A,B,control)
begin

case(control) is
    
    when "000" => aux <= A and B;
    when "001" => aux <= A or B;
    when "010" => aux <= A + B;
    when "110" => aux <= A - B;
    when "111" => IF (A < B) THEN aux <= x"00000001"; ELSE aux <= x"00000000"; END IF;    
    when "100" => aux <= B(15 downto 0) & x"0000";
    when others => aux <= x"00000000";

end case;

end process;

zero <= '1' when (aux = x"00000000") else '0';
result <= aux;
 
end PRACTICA;