library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
component MPG
    Port(enable: out STD_LOGIC;
    btn: in STD_LOGIC;
    clk: in STD_LOGIC);
end component;

component SSD 
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port(
        Clk           : in std_logic;
        Rst           : in std_logic;
        En            : in std_logic;
        PCSrc         : in std_logic;
        Jump          : in std_logic;
        JumpAddress   : in std_logic_vector(31 downto 0);
        BranchAddress : in std_logic_vector(31 downto 0);
        Instruction   : out std_logic_vector(31 downto 0);
        PC_plus_4     : out std_logic_vector(31 downto 0)
        );
    end component;
    
component InstructionDecode
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
    end component;


signal mux_out : std_logic_vector(31 downto 0);
signal en : STD_LOGIC;
signal PC_plus_4 : std_logic_vector(31 downto 0);
signal Instruction : std_logic_vector(31 downto 0);
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal Rd1, Rd2, Ext_Imm : std_logic_vector(31 downto 0);
signal func, sa : std_logic_vector(5 downto 0);

begin
    monopulse: MPG port map(en, btn(0), clk);
    comp_ssd: SSD port map(clk, mux_out, an, cat);
    fetch: IFetch port map(clk, btn(1), en, sw(1), sw(0), X"00000000", X"00000010", Instruction, PC_plus_4);
    UC: entity work.UnitateControl port map(
        Instr => Instruction(31 downto 26),
        RegDst => RegDst,
        ExtOp => ExtOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        Jump => Jump,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        MemtoReg => MemtoReg,
        RegWrite => RegWrite
    );
    decode: InstructionDecode port map(
        clk => clk,
        RegWrite => RegWrite,
        Instr => Instruction(25 downto 0),
        RegDst => RegDst,
        En => en,
        ExtOp => ExtOp,
        Wd => mux_out,
        Rd1 => Rd1,
        Rd2 => Rd2,
        Ext_Imm => Ext_Imm,
        func => func,
        sa => sa
    );
    
    process(sw(7 downto 5), Instruction, PC_plus_4, Rd1, Rd2, Ext_Imm)
    begin
    case sw(7 downto 5) is
        when "000" => mux_out <= Instruction;
        when "001" => mux_out <= PC_plus_4;
        when "010" => mux_out <= Rd1;
        when "011" => mux_out <= Rd2;
        when "100" => mux_out <= Ext_Imm;
        when others => mux_out <= (others => '0');
    end case;
end process;
end Behavioral;
