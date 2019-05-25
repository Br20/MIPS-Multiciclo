---------------------------------------------------------------------------------------------------
--
-- Title       : Pipelined_MIPS.vhd
-- Design      : implementation of pipelined MIPS
-- Author      : L. Leiva
-- Company     : UNICEN
--
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Pipelined_MIPS is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0); 
	I_RdStb     : out std_logic; 
	I_WrStb     : out std_logic; 
	I_DataOut   : out std_logic_vector(31 downto 0); 
	I_DataIn    : in  std_logic_vector(31 downto 0); 
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0); 
	D_RdStb     : out std_logic; 
	D_WrStb     : out std_logic; 
	D_DataOut   : out std_logic_vector(31 downto 0); 
	D_DataIn    : in  std_logic_vector(31 downto 0) 
);
end Pipelined_MIPS; 

architecture Pipelined_MIPS_arch of Pipelined_MIPS is 
   --IF
    signal IF_PcNext: std_logic_vector (31 downto 0);
    signal IF_PcIn : std_logic_vector (31 downto 0);
    signal IF_PcOut: std_logic_vector (31 downto 0);
    --ID
     signal ID_MemToReg : std_logic;
    signal ID_RegWrite : std_logic;
    signal ID_Branch : std_logic;
    signal ID_MemWrite : std_logic;
    signal ID_MemRead : std_logic;
    signal ID_AluOp : std_logic_vector(1 downto 0);
    signal ID_RegDst : std_logic;
    signal ID_AluSrc : std_logic;
    signal ID_Instruction: std_logic_vector(31 downto 0);
    signal ID_PcNext: std_logic_vector(31 downto 0);
    signal ID_SignExt: std_logic_vector(31 downto 0);
    signal ID_RegRd1: std_logic_vector(31 downto 0);
    signal ID_RegRd2: std_logic_vector(31 downto 0);

    component Registers
       Port ( clk : in STD_LOGIC;
              reset : in STD_LOGIC;
              wr : in STD_LOGIC;  
              reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
              reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
              reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
              data_wr : in STD_LOGIC_VECTOR (31 downto 0);
              data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
              data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
        end component;
    
    --Exe
    signal EXE_Rt: std_logic_vector(4 downto 0);
    signal EXE_Rd: std_logic_vector(4 downto 0); 
    signal EXE_MemToReg: std_logic;
    signal EXE_RegWrite: std_logic;
    signal EXE_Branch: std_logic;
    signal EXE_MemWrite: std_logic;
    signal EXE_MemRead: std_logic;
    signal EXE_RegDst : std_logic;
    signal EXE_AluSrc: std_logic;
    signal EXE_AluOp : std_logic_vector(1 downto 0);
    signal EXE_PcNext: std_logic_vector(31 downto 0);
    signal EXE_RegRd1: std_logic_vector(31 downto 0);
    signal EXE_RegRd2: std_logic_vector(31 downto 0);
    signal EXE_SignExt: std_logic_vector(31 downto 0);
    signal EXE_BranchAddress: std_logic_vector(31 downto 0);
    signal EXE_AluMux: std_logic_vector(31 downto 0); 
    signal EXE_RegDestMux: std_logic_vector(4 downto 0);
    signal EXE_Zero: std_logic;
    signal EXE_AluResult: std_logic_vector(31 downto 0);
    signal EXE_AluControl : std_logic_vector(2 downto 0);

   component ALU
                Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
                       b : in STD_LOGIC_VECTOR (31 downto 0);
                       control : in STD_LOGIC_VECTOR (2 downto 0);
                       result : out STD_LOGIC_VECTOR (31 downto 0);
                       zero : out STD_LOGIC);
        end component;
    
    --Mem
    signal MEM_MemToReg: std_logic;
    signal MEM_RegWrite: std_logic;
    signal MEM_Branch : std_logic;
    signal MEM_BranchAddress: std_logic_vector(31 downto 0);
    signal MEM_PcSrc : std_logic; 
    signal MEM_Zero: std_logic;
    signal MEM_AluResult: std_logic_vector(31 downto 0);
    signal MEM_WriteData: std_logic_vector(31 downto 0);
    signal MEM_RegDest: std_logic_vector(4 downto 0);
    signal MEM_MemRead: std_logic;
    signal MEM_MemWrite: std_logic;
    signal MEM_RegRd2: std_logic_vector(31 downto 0);
    --Write back
    signal WB_RegWrite: std_logic;
    signal WB_MemToReg: std_logic;
    signal WB_ReadData: std_logic_vector(31 downto 0);
    signal WB_Address: std_logic_vector(31 downto 0);
    signal WB_MuxWbResult: std_logic_vector (31 downto 0);
    signal WB_RegDest : std_logic_vector(4 downto 0);
begin 
-------------------------------------------------------------------------------------------- 
--   Intruction Fetching 
--------------------------------------------------------------------------------------------
    -- PC REGISTER
    PC_reg: process(Clk,Reset)
    begin
        if Reset = '1' then 
            IF_PcOut <= (others => '0');
        elsif rising_edge(Clk) then
            IF_PcOut <= IF_PcIn;
        end if;
    end process;
     
     IF_PcNext <=IF_PcOut + 4 ;
     IF_PcIn <= IF_PcNext when MEM_PcSrc = '0' else MEM_BranchAddress;
     
     -- Instruction memory interface
     I_Addr <= IF_PcOut;
     I_RdStb <= '1'; 
     I_WrStb <= '0'; 
     I_DataOut <= x"00000000";
        
 -------------------------------------------------------------------------------------------- 
 --  Pipeline Register IF/ID
 --------------------------------------------------------------------------------------------
     IFID_reg: process (Clk,Reset) 
     begin
        if Reset = '1' then 
            ID_Instruction <= (others => '0');
            ID_PcNext <= (others => '0');
        elsif rising_edge(Clk)then
            ID_Instruction <= I_DataIn;
            ID_PcNext <= IF_PcNext;
        end if;
     end process; 
-------------------------------------------------------------------------------------------- 
--   Intruction Decoding
--------------------------------------------------------------------------------------------
-- Control Unit
    Control:process(ID_Instruction(31 downto 26))
    begin
      case ID_Instruction(31 downto 26) is
        when "000000" => -- R-Type
          ID_RegWrite    <= '1';
          ID_MemToReg  <= '0';
          ID_Branch     <= '0';
          ID_MemRead    <= '0';
          ID_MemWrite   <= '0';
          ID_RegDst   <= '1';
          ID_AluOp    <= "11";
          ID_AluSrc   <= '0';
        when "100011" => --LOAD
          ID_RegWrite    <= '1';
          ID_MemToReg <= '1';
          ID_Branch     <= '0';
          ID_MemRead    <= '1';
          ID_MemWrite   <= '0';
          ID_RegDst   <= '0';
          ID_AluOp    <= "00";
          ID_AluSrc   <= '1';
        when "101011" => --STORE
          ID_RegWrite    <= '0';
          ID_MemToReg <= '0';
          ID_Branch     <= '0';
          ID_MemRead    <= '0';
          ID_MemWrite   <= '1';
          ID_RegDst   <= '0';
          ID_AluOp    <= "00";
          ID_AluSrc   <= '1';
        when "000100" => --BEQ
          ID_RegWrite    <= '0';
          ID_MemToReg <= '0';
          ID_Branch     <= '1';
          ID_MemRead    <= '0';
          ID_MemWrite   <= '0';
          ID_RegDst   <= '0';
          ID_AluOp    <= "01";
          ID_AluSrc   <= '0';
        when others => --OTHERS
          ID_RegWrite    <= '0';
          ID_MemToReg <= '0';
          ID_Branch     <= '0';
          ID_MemRead    <= '0';
          ID_MemWrite   <= '0';
          ID_RegDst   <= '0';
          ID_AluOp    <= "00";
          ID_AluSrc   <= '0';
      end case;
    end process;
    
-- Register Instantiation
   Regs : registers PORT MAP(
     clk => Clk ,
     reset => Reset ,
     wr => WB_RegWrite,   
     reg1_rd => ID_Instruction(25 downto 21),
     reg2_rd => ID_Instruction(20 downto 16),
     reg_wr =>WB_RegDest,  
     data_wr => WB_MuxWbResult,   
     data1_rd => ID_RegRd1,
     data2_rd => ID_RegRd2
     ); 
        
--Sign Extend
 ID_SignExt <= x"0000" & ID_Instruction(15 downto 0) when (ID_Instruction(15) = '0') else  (x"FFFF" & ID_Instruction(15 downto 0));
  
 -------------------------------------------------------------------------------------------- 
 --  Pipeline Register ID/EX
 --------------------------------------------------------------------------------------------
 process (Clk,Reset)
 begin
    if (Reset = '1') then 
        EXE_PcNext <= (others => '0');
        EXE_RegRd1 <=(others => '0');
        EXE_RegRd2 <=(others => '0');
        EXE_SignExt <=(others => '0');
        EXE_RegDst <= '0';
        EXE_AluSrc <= '0';
        EXE_AluOp <= "00";
        EXE_Branch <= '0';
        EXE_MemWrite <='0';
        EXE_MemRead <= '0';
        EXE_MemToReg <= '0';
        EXE_RegWrite <='0';
        EXE_Rt <= (others => '0');
        EXE_Rd <= (others => '0');  
    elsif (rising_edge(Clk)) then
        EXE_RegDst <= ID_RegDst;
        EXE_AluSrc <= ID_AluSrc;
        EXE_AluOp <= ID_AluOp;
        EXE_Branch <= ID_Branch;
        EXE_MemWrite <= ID_MemWrite;
        EXE_MemRead <= ID_MemRead;
        EXE_MemToReg <= ID_MemToReg;
        EXE_RegWrite <= ID_RegWrite;
        EXE_PcNext <= ID_PcNext;
        EXE_RegRd1 <= ID_RegRd1;   
        EXE_RegRd2 <= ID_RegRd2;   
        EXE_SignExt <= ID_SignExt;
        EXE_Rt <= ID_Instruction(20 downto 16);
        EXE_Rd <= ID_Instruction(15 downto 11);
    end if;
 end process; 
 
 -------------------------------------------------------------------------------------------- 
 --  Execution
 --------------------------------------------------------------------------------------------
 -- Brach Address
 EXE_BranchAddress <= EXE_PcNext + (EXE_SignExt(29 downto 0) & "00");
 
 --Mux AluSRC
 EXE_AluMux <= EXE_RegRd2 when (EXE_AluSrc = '0') else EXE_SignExt;
         
 --ALU intantiation
     ALUEX : ALU PORT MAP(
     a => EXE_RegRd1,
     b => EXE_AluMux,
     control =>  EXE_AluControl,
     result => EXE_AluResult,
     zero => EXE_Zero
 );
 --Alu Control
 process (EXE_SignExt(5 downto 0), EXE_AluOp)
 begin
      case(EXE_AluOp) is
        when "11" =>
             case (EXE_SignExt(5 downto 0)) is 
                 when "100000"=>  --ADD                  
                       EXE_AluControl <= "010";   
                 when"100010" => --SUB
                       EXE_AluControl <= "110";
                 when "100100" => -- AND
                       EXE_AluControl <= "000";
                 when "100101" => -- OR
                       EXE_AluControl <= "001";
                 when "101010" => -- SLT
                       EXE_AluControl <= "111";
                 when others => 
                       EXE_AluControl <= "000";
             end case;
             when "01" =>  --BEQ
                 EXE_AluControl <= "110";
             when "00" =>  -- MEM
                 EXE_AluControl <= "010";
             when others =>  
                 EXE_AluControl <= "000"; 
     end case;   
 end process;
 
 -- Mux Destino
 EXE_RegDestMux <= EXE_Rt when (EXE_RegDst = '0') else EXE_Rd;
 
 -------------------------------------------------------------------------------------------- 
 --  Pipeline Register EM/MEM
 --------------------------------------------------------------------------------------------
  process (Clk,Reset)
 begin
      if (Reset = '1')then
           MEM_Branch <= '0' ;
           MEM_MemRead <= '0';
           MEM_MemWrite <= '0';
           MEM_MemToReg <= '0'; 
           MEM_RegWrite <= '0';
           MEM_BranchAddress <= (others => '0');
           MEM_Zero <= '0';
           MEM_AluResult <= (others => '0');
           MEM_RegRd2 <= (others => '0');
           MEM_RegDest <= (others => '0');
      elsif (rising_edge(Clk)) then
           MEM_Branch <= EXE_Branch ;
           MEM_MemRead <=EXE_MemRead;
           MEM_MemWrite <= EXE_MemWrite; 
           MEM_MemToReg <= EXE_MemToReg; 
           MEM_RegWrite <= EXE_RegWrite ;
           MEM_BranchAddress <= EXE_BranchAddress;
           MEM_Zero <= EXE_Zero;
           MEM_AluResult <= EXE_AluResult;
           MEM_RegRd2 <= EXE_RegRd2; 
           MEM_RegDest <= EXE_RegDestMux;
      end if;
 end process;
-------------------------------------------------------------------------------------------- 
--  MEMORY
-------------------------------------------------------------------------------------------- 
  --Branch condition
 MEM_PcSrc <= MEM_Branch and MEM_zero;

--Data Memory Interface
 D_Addr <= MEM_AluResult; -- Memoria de datos
 D_DataOut <= MEM_RegRd2;
 D_RdStb <= MEM_MemRead;
 D_WrStb <= MEM_MemWrite;
 
 -------------------------------------------------------------------------------------------- 
 --  Pipeline Register MEM/WB
 --------------------------------------------------------------------------------------------
 process (Clk,Reset)
 begin
    if (Reset = '1') then
        WB_MemToReg <= '0';
        WB_RegWrite <= '0';
        WB_ReadData <= (others => '0');
        WB_Address <= (others => '0');
        WB_RegDest <= (others => '0');
    elsif (rising_edge(Clk)) then
        WB_MemToReg <= MEM_MemToReg;
        WB_RegWrite <= MEM_RegWrite; 
        WB_ReadData <= D_DataIn ;
        WB_Address <= MEM_AluResult;
        WB_RegDest <= MEM_RegDest;
    end if;
 end process;
 
 -------------------------------------------------------------------------------------------- 
 --  Write Back
 --------------------------------------------------------------------------------------------
  WB_MuxWbResult <= WB_ReadData when (WB_MemToReg = '1') else WB_Address;
  
end Pipelined_MIPS_arch;