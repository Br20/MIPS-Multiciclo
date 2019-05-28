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
    if state = "0000" then
        PCSource <= '0';
        TargetWrite <= '0';
        AluOp <= "01"; --Para realizar la suma PC + 4
        AluSelA <= '0'; --Para seleccionar la entrada del PC
        AluSelB <= "01"; -- para seleccionar la entrada del 4
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '0'; --Para que seleccione el de arriba
        MemRead <= '1'; --Para poder leer la memoria
        MemWrite <= '0';
        IRWrite <= '1'; --para poder escribir en IR
        MemToReg <= '0';
		next_state <= "0001";
	elsif state = "0001" then
        PCSource <= '1';
        TargetWrite <= '1'; --para guardar la dir de salto (si salta)
        AluOp <= "00"; -- para que se haga la suma
        AluSelA <= '0'; -- para seleccionar la entrada del PC
        AluSelB <= "11"; -- para seleccionar Sign_ext(Instr[15..0] << 2)
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '0';
        case OpCode is 
            when "100011"  => next_state <= "0010"; -- Es un LW
            when "101011"  => next_state <= "0010"; -- Es un SW
            when "000000" => next_state <= "0110"; -- Es R-Type
            when "000100" => next_state <= "1000"; -- Es un beq
        end case;
    elsif state = "0010" then -- LW o SW 
        PCSource <= '0';
        TargetWrite <= '0';
        AluOp <= "00"; -- para que se haga la suma
        AluSelA <= '1'; --para seleccionar A (Reg[instr[25..21])
        AluSelB <= "10"; -- para seleccionar sign_ext(instr[15..0])
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '0';
        case OpCode is 
            when "100011"  => next_state <= "0011"; -- Es un LW
            when "101011"  => next_state <= "0101"; -- Es un SW
		end case;
	elsif state = "0011" then --LW 1
        PCSource <= '0';
        TargetWrite <= '0';
        AluOp <= "00";
        AluSelA <= '0';
        AluSelB <= "00";
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '1'; -- Para que tome ALU_Result como direccion a leer de la memoria
        MemRead <= '1'; -- Quiero leer la memoria
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '0';
		next_state <= "0100";
	elsif state = "0100" then --LW 2
        PCSource <= '0';
        TargetWrite <= '0'; 
        AluOp <= "00";
        AluSelA <= '0';
        AluSelB <= "00";
        RegWrite <= '1'; -- Quiero escribir en el banco
        RegDst <= '0'; -- Para que seleccione instr[20-16]
        PCWrite <=  '0';
        PCWriteCond <= '0';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '1'; -- Elijo el dato que viene de la memoria
		next_state <= "0000";
	elsif state = "0101" then -- es un SW
        PCSource <= '0';
        TargetWrite <= '0'; 
        AluOp <= "00";
        AluSelA <= '0';
        AluSelB <= "00";
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '1'; -- Para que tome el valor que viene del registro
        MemRead <= '0';
        MemWrite <= '1'; -- Quiero escribir en la memoria
        IRWrite <= '0';
        MemToReg <= '0';
		next_state <= "0000";
	elsif state = "0110" then -- Es un R-type 1
        PCSource <= '0';
        TargetWrite <= '0';
        AluOp <= "10";
        AluSelA <= '1';
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
		next_state <= "0111";
	elsif state = "0111" then
        PCSource <= '0';
        TargetWrite <= '0'; 
        AluOp <= "00";
        AluSelA <= '0';
        AluSelB <= "00";
        RegWrite <= '1'; -- Quiero escribir en el banco
        RegDst <= '1'; -- Para que seleccione Instr[15-11]
        PCWrite <= '0';
        PCWriteCond <= '0';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '0'; -- Para que seleccione ALU_Result
		next_state <= "0000";
	elsif state = "1000" then
        PCSource <= '1';
        TargetWrite <= '0';
        AluOp <= "00";
        AluSelA <= '0';
        AluSelB <= "00";
        RegWrite <= '0';
        RegDst <= '0';
        PCWrite <= '0';
        PCWriteCond <= '1';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        IRWrite <= '0';
        MemToReg <= '0';
		next_state <= "0000";
	end if;



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
