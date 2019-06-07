Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;


entity Registers is
    Port (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;   
           wr : in STD_LOGIC;
           reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
           reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           data1_rd : OUT STD_LOGIC_VECTOR (31 downto 0); 
           data2_rd : OUT STD_LOGIC_VECTOR (31 downto 0)
);
end Registers;

architecture PRACTICA of Registers is
TYPE T_Registros IS Array(0 to 31) OF STD_LOGIC_VECTOR(31 downto 0);
SIGNAL registros: T_Registros;
begin

-- LECTURA DE DATOS
   data1_rd <= x"00000000" when reg2_rd = "00000" else
   registros(conv_integer(reg1_rd));
   data2_rd <= x"00000000" when reg2_rd = "00000" else
   registros(conv_integer(reg2_rd));

--ESCRITURA DE DATOS

PROCESS (clk, reset)
BEGIN
    if (reset = '1') then
        registros <= (others => x"00000000");
    elsif falling_edge(clk) THEN
        if (wr = '1') then
            registros(conv_integer(reg_wr)) <= data_wr;
        end if;
    end if;
END PROCESS;


end PRACTICA;