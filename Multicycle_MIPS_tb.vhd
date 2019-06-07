
library ieee;
use ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

	-- Add your library and packages declaration here ...

entity MultiCycle_MIPS_tb is
end MultiCycle_MIPS_tb;

architecture MultiCycle_MIPS_tb_arch  of MultiCycle_MIPS_tb is
	-- Component declaration of the tested unit
	component MultiCycle_MIPS
   port(
   	   Clk       : in  std_logic;
	   Reset     : in  std_logic;
	   Addr      : out std_logic_vector(31 downto 0);
	   RdStb     : out std_logic;
	   WrStb     : out std_logic;
	   DataOut   : out std_logic_vector(31 downto 0);
	   DataIn    : in  std_logic_vector(31 downto 0)
   );
	end component;

	component Memory
    generic(
        C_ELF_FILENAME_LOW    : string;
        C_ELF_FILENAME_HIGH    : string;
        C_MEM_SIZE        : integer;
        C_MEM_HIGH_OFFSET    : integer
     );
	port (
		Clk                : in std_logic;			 
		Addr               : in std_logic_vector(31 downto 0);
		RdStb              : in std_logic;
		WrStb              : in std_logic;
		DataIn             : in std_logic_vector(31 downto 0);
		DataOut            : out std_logic_vector(31 downto 0)
	);
   end component;

	signal Clk         : std_logic;
	signal Reset       : std_logic;
   -- memory
	signal Addr      : std_logic_vector(31 downto 0);
	signal RdStb     : std_logic;
	signal WrStb     : std_logic;
	signal DataOut   : std_logic_vector(31 downto 0);
	signal DataIn    : std_logic_vector(31 downto 0);
	
	constant tper_clk  : time := 50 ns;
	constant tdelay    : time := 120 ns; -- antes 150, sino no enta direccion 0

begin
	  
	-- Unit Under Test port map
	UUT : MultiCycle_MIPS
		port map (
			Clk             => Clk,
			Reset           => Reset,
			-- Instruction memory
	      Addr          => Addr,
  	      RdStb         => RdStb,
	      WrStb         => WrStb,
	      DataOut       => DataOut,
	      DataIn        => DataIn
		);

	Instruction_Mem_inst : memory
	generic map (
	  C_ELF_FILENAME_LOW     => "/home/brian/Escritorio/proyecto/program1",
	  C_ELF_FILENAME_HIGH     => "/home/brian/Escritorio/proyecto/data",
      C_MEM_SIZE         => 2048,
      C_MEM_HIGH_OFFSET => 1024
   )
	port map (
		Clk                => Clk,			 
		Addr               => Addr,
		RdStb              => RdStb,
		WrStb              => WrStb,
		DataIn             => DataOut,
		DataOut            => DataIn
	);
	
	

	process	
	begin		
	   Clk <= '0';
		wait for tper_clk/2;
		Clk <= '1';
		wait for tper_clk/2; 		
	end process;
	
	process
	begin
		Reset <= '1';
		wait for tdelay;
		Reset <= '0';	   
		wait;
	end process;  	 

end MultiCycle_MIPS_tb_arch;