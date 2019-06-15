
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Multicycle_MIPS is
port(
	Clk       : in  std_logic;
	Reset     : in  std_logic;
	Addr      : out std_logic_vector(31 downto 0);
	RdStb     : out std_logic;
	WrStb     : out std_logic;
	DataOut   : out std_logic_vector(31 downto 0); -- DataIn en la memoria
	DataIn    : in  std_logic_vector(31 downto 0) -- DataOut en la memoria
);
end Multicycle_MIPS; 

architecture Multicycle_MIPS_arch of Multicycle_MIPS is 



signal sign_ext: std_logic_vector (31 downto 0); -- senal para la extension de signo
signal jump_addr: std_logic_vector (31 downto 0); -- senal de direccion de salto

--Entradas y salidas del PC

signal PC_In: std_logic_vector(31 downto 0); --entrada PC
signal PC_Out: std_logic_vector(31 downto 0); --salida PC
signal PC_Enable: std_logic; --senal de escritura PC


-- Entradas y salidas Instruccion Register

--Entra MemData (instruccion)
signal Inst_High: std_logic_vector (5 downto 0); -- 6 bits mas altos de la instruccion
signal Inst_Low: std_logic_vector (25 downto 0); -- resto de bits de la instruccion

-- Salidas UC () 
signal PCWrite: STD_LOGIC;
signal PCWriteCond: STD_LOGIC;
signal IorD: STD_LOGIC;
signal MemRead: STD_LOGIC;
signal MemWrite: STD_LOGIC;
signal IRWrite: STD_LOGIC;
signal MemToReg: STD_LOGIC;
signal PCSource: STD_LOGIC;
signal TargetWrite: STD_LOGIC;
signal ALUOp: STD_LOGIC_VECTOR (1 downto 0); 
signal ALUSelA: STD_LOGIC;
signal ALUSelB: STD_LOGIC_VECTOR (1 downto 0);
signal RegWrite: STD_LOGIC;
signal RegDst: STD_LOGIC;

constant espera  : time := 500 ns;
--COMPONENTES

-- ENTRADAS Y SALIDAS BANCO DE REGISTROS
Component Registers is
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
end component;

--clk, reset universales
--wr = RegWrite
signal reg_wr: STD_LOGIC_VECTOR(4 downto 0);
signal reg1_rd: STD_LOGIC_VECTOR (4 downto 0);
signal reg2_rd: STD_LOGIC_VECTOR (4 downto 0);
signal data_wr: STD_LOGIC_VECTOR (31 downto 0);
signal data1_rd: STD_LOGIC_VECTOR (31 downto 0); 
signal data2_rd: STD_LOGIC_VECTOR (31 downto 0);




-- ENTRADAS Y SALIDAS ALU

Component ALU is
Port(
	a,b: IN std_logic_vector (31 downto 0);
	control: IN std_logic_vector (2 downto 0);
	result: OUT std_logic_vector (31 downto 0);
	zero: OUT std_logic
);
end component;

signal a: std_logic_vector(31 downto 0);
signal b: std_logic_vector(31 downto 0);
signal ALU_Result: std_logic_vector(31 downto 0);
signal control: std_logic_vector (2 downto 0);
signal zero: std_logic;



-- ENTRADAS Y SALIDAS DEL RI
Component Reg is
Port(
	d: IN std_logic_vector (31 downto 0);
	clk: IN std_logic;
	reset: IN std_logic;
	ce: IN std_logic;
	q: OUT std_logic_vector ( 31 downto 0)
);
end Component;

-- signal d: std_logic_vector (31 downto 0); -- MemData
-- signal ce: std_logic; --IRWrite
signal instr: std_logic_vector ( 31 downto 0);

-- ENTRADAS Y SALIDAS DE LA UNIDAD DE CONTROL

Component ControlUnit is
Port(
    clk : in STD_LOGIC;
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
    MemToReg: out STD_LOGIC
);
End Component;



--*********************************************************************************************

BEGIN



--Instancicion de la ALU
ALU_Inst: ALU
Port map(   
        a => a,
        b => b,
        control => control,
        result => ALU_Result,
        zero => zero
 );
 
-- Instanciacion del Banco de Registros
bank: Registers
Port map(
       clk => Clk,
       reset =>  Reset,
       wr =>  RegWrite,
       reg_wr =>  reg_wr,
       reg1_rd =>  reg1_rd,
       reg2_rd =>  reg2_rd,
       data_wr =>  data_wr,
       data1_rd =>  data1_rd,
       data2_rd =>  data2_rd
);

-- Instanciacion de un registro (Registro de Instruccion)
reg_inst: Reg
Port map(
	d => DataIn,
	clk => Clk,
	reset => Reset,
	ce => IRWrite,
	q => instr
);


-- Instanciacion de un registro (Registro Target)
target: Reg
Port map(
	d => ALU_Result,
	clk => Clk,
	reset => Reset,
	ce => TargetWrite,
	q => jump_addr
);



--Instanciacion de la unidad de control
cu: ControlUnit
Port map(
    clk => Clk,
    Reset => Reset,
    OpCode => instr(31 downto 26),
    PCSource => PCSource,
    TargetWrite => TargetWrite,
    AluOp => AluOp,
    AluSelA => AluSelA,
    AluSelB => AluSelB,
    RegWrite => RegWrite,
    RegDst => RegDst,
    PCWrite => PCWrite,
    PCWriteCond => PCWriteCond,
    IorD => IorD,
    MemRead => RdStb,
    MemWrite => WrStb,
    IRWrite => IRWrite,
    MemToReg => MemToReg 
    
);



process (reset,PCSource,PC_enable, Clk)
begin
    if (reset = '1') then
        PC_In <= x"00000000";
    elsif PC_enable = '1' then
        if PCSource = '1' then 
            PC_In <= jump_addr;
        else
            if (falling_edge(Clk)) then 
                PC_In <= ALU_Result;
            end if;
        end if;
    end if;
end process;


PC_Out <= PC_In;

-- logica extra de control PC
PC_enable <= (PCWriteCond and zero) or PCWrite;


-- Entrada de direccion de memoria (Mux)
--Mem_Address <= PC_Out when IorD = '0' else Alu_Result when IorD = '1'; -- Esto estaba antes
Addr <= PC_Out when IorD = '0' else Alu_Result when IorD = '1'; -- Esto es lo nuevo!!

-- Entradas al banco de registros
reg1_rd <= instr(25 downto 21);
reg2_rd <= instr(20 downto 16);
reg_wr <= instr(20 downto 16) when RegDst = '0' else 
          instr(15 downto 11) when RegDst = '1';
data_wr <= ALU_Result when MemToReg = '0' else 
           DataIn when MemToReg = '1';



-- Entradas de la ALU
a <= PC_Out when ALUSelA = '0' else 
     data1_rd when ALUSelA = '1';

sign_ext <= x"0000" & instr(15 downto 0) when instr(15) = '0' else
            x"1111" & instr(15 downto 0) when instr(15) = '1';
b <= data2_rd when ALUSelB = "00" else 
     x"00000004" when ALUSelB = "01" else
     sign_ext when ALUSelB = "10" else
     sign_ext(29 downto 0) & "00" when ALUSelB = "11"; 
     
-- ALU Control (no me gusta mucho este, tendria que cambiarlo)
alu_control: process(instr(5 downto 0), aluOp)
begin
    if aluOp = "00" then 
        control <= "010";
    elsif aluOp = "01" then 
        control <= "110";
    elsif ((aluOp = "10") and (instr(5 downto 0) = "100100")) then 
        control <= "000";
    elsif ((aluOp = "10") and (instr(5 downto 0) = "100101")) then 
        control <= "001";
    elsif ((aluOp = "10") and (instr(5 downto 0) = "101010")) then 
        control <= "111";
    end if;
end process;




-- Mux de entrada al PC
-- PC_In <= jump_addr when TargetWrite = '1' else 
--         ALU_Result when TargetWrite = '0';


-- Parche de conexion banco - memoria
DataOut <= data2_rd;


end Multicycle_MIPS_arch;
