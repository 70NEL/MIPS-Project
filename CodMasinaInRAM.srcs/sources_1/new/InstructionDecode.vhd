library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity InstructionDecode is
  Port (clk : in std_logic;
        RegWrite : in std_logic;
        Instr : in std_logic_vector(25 downto 0);
        RegDst : in std_logic;
        En : in std_logic;
        ExtOp : in std_logic;
        Wd : in std_logic_vector(31 downto 0);
        Rd1 : out std_logic_vector(31 downto 0);
        Rd2 : out std_logic_vector(31 downto 0);
        Ext_Imm : out std_logic_vector(31 downto 0);
        func : out std_logic_vector(5 downto 0);
        sa : out std_logic_vector(5 downto 0)
        );
end InstructionDecode;

architecture Behavioral of InstructionDecode is
    component RegFile
        port ( clk : in std_logic; 
                 en : in std_logic;
                 ra1 : in std_logic_vector(4 downto 0);  -- Read Address 1 
                 ra2 : in std_logic_vector(4 downto 0);  -- Read Address 2 
                 wa : in std_logic_vector(4 downto 0);  -- Write Address 
                 wd : in std_logic_vector(31 downto 0); -- Write Data 
                 regwr : in std_logic;     -- comanda RegWrite 
                 rd1 : out std_logic_vector(31 downto 0); -- Read Data 1 
                 rd2 : out std_logic_vector(31 downto 0));
    end component;
    
    signal mux_out: std_logic_vector(5 downto 0);
begin
    mux_out <= Instr(15 downto 11) when RegDst = '1' else Instr(20 downto 16);
    
    rgfile : RegFile port map(
        clk => clk,
        en => En,
        ra1 => Instr(25 downto 21),
        ra2 => Instr(20 downto 16),
        wa => mux_out,
        wd => Wd,
        regwr => RegWrite,
        rd1 => Rd1,
        rd2 => Rd2
        );
    
    func <= Instr(5 downto 0);
    sa <= Instr(10 downto 6);
    
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others=>Instr(15)) when ExtOp='1' else (others=>'0'); 
end Behavioral;
