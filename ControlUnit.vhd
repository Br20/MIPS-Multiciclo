---------------------------------------------------------------------------------------------------
--
-- Title       : ControlUnit.vhd
-- Design      : Control Unit Template for Multicycle MIPS
-- Author      : L. Leiva
-- Company     : UNICEN
--
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlUnit is
    Port ( clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           OpCode:  in STD_LOGIC_VECTOR(5 downto 0);
           PCSource: out STD_LOGIC;
           TargetWrite: out STD_LOGIC;
           AluOp: out STD_LOGIC_VECTOR(1 downto 0);
           AluSelA: out STD_LOGIC;
           AluSelB: out STD_LOGIC_VECTOR(1 downto 0);
           RegWrite: out STD_LOGIC;
           RegDst: out STD_LOGIC;
           PCWrite: out STD_LOGIC;
           PCWriteCond: out STD_LOGIC;
           IorD: out STD_LOGIC;
           MemRead: out STD_LOGIC;
           MemWrite: out STD_LOGIC;
           IRWrite: out STD_LOGIC;
           MemToReg: out STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is
    signal state, next_state: std_logic_vector(3 downto 0); 
begin

comb_process: process(OpCode, state)
begin
    case state is 
        when "0000" =>
               PCSource <=  '0',
               TargetWrite <= '0', 
               AluOp <=  "00",
               AluSelA <=  '0',
               AluSelB <=   "01",
               RegWrite <= '0',
               RegDst <= '0', 
               PCWrite <= '0', 
               PCWriteCond <= '0',
               IorD <=  '0',
               MemRead <= '1',
               MemWrite <= '0',
               IRWrite <= '1',
               MemToReg <= '0',
			   next_state <= "0001"	
        when "0001" =>
               PCSource <= '1',
               TargetWrite <= '1',
               AluOp <= "00",
               AluSelA <= '0',
               AluSelB <= "11",
               RegWrite <= '0',
               RegDst <= '0',
               PCWrite <= '0',
               PCWriteCond <= '0',
               IorD <= '0',
               MemRead <= '0',
               MemWrite <= '0',
               IRWrite <= '0',
               MemToReg <= '0'
			   next_state <= "0010" when opCode = "100011" else -- es un LW o SW
			                 "0110" when opCode = "000000" else -- es una Operacion
			                 "0111" when opCode = "000100") -- es un BEQ
        when "0010" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <= 
	    when "0011" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <= 
	    when "0100" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <=
		when "0101" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <= 
	    when "0110" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <=
	    when "0111" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <= 
		when "1000" =>
               PCSource <= 
               TargetWrite <= 
               AluOp <= 
               AluSelA <= 
               AluSelB <= 
               RegWrite <= 
               RegDst <= 
               PCWrite <= 
               PCWriteCond <=
               IorD <=
               MemRead <=
               MemWrite <=
               IRWrite <=
               MemToReg <=
			   next_state <= 
        when others =>
               PCSource <= '0'; 
               TargetWrite <='0';  
               AluOp <= "00"; 
               AluSelA <= '0'; 
               AluSelB <= "00"; 
               RegWrite <= '0'; 
               RegDst <= '0'; 
               PCWrite <= '0'; 
               PCWriteCond <= '0'; 
               IorD <= '0'; 
               MemRead <= '0'; 
               MemWrite <= '0'; 
               IRWrite <= '0'; 
               MemToReg <= '0'; 
			   next_state <= "0000"; 
    end case;  
 end process; 

seq_process: process(clk, reset)
begin
    if reset = '1' then
        state <= (others => '0'); 
    elsif rising_edge(clk) then 
        state <= next_state; 
    end if; 
end process; 


end Behavioral;
