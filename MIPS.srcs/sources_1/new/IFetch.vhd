library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           En : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           Instruction : out STD_LOGIC_VECTOR (31 downto 0);
           PC_plus_4 : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

    signal PC_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal next_pc : std_logic_vector(31 downto 0);
    signal pc_inc : std_logic_vector(31 downto 0);
    signal branch_mux : std_logic_vector(31 downto 0);

    type rom_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal ROM : rom_type := (
    -- 00: LW $1, 4($0) -> Incarca N din memorie
    -- Hex: 8C010004
    0 => B"100011_00000_00001_0000000000000100", 
    
    -- 01: ADDI $2, $0, 8 -> Adresa de start a sirului
    -- Hex: 20020008
    1 => B"001000_00000_00010_0000000000001000",
    
    -- 02: ADDI $3, $0, 0 -> Contor rezultat (count) = 0
    -- Hex: 20030000
    2 => B"001000_00000_00011_0000000000000000",
    
    -- 03: BEQ $1, $0, 9 -> Daca N=0, sari la SW (sari peste 9 instr)
    -- Hex: 10200009
    3 => B"000100_00001_00000_0000000000001001",
    
    -- 04: LW $4, 0($2) -> Incarca element curent
    -- Hex: 8C440000
    4 => B"100011_00010_00100_0000000000000000",
    
    -- 05: SLT $5, $4, $0 -> $5 = 1 daca elementul e negativ
    -- Hex: 0080282A
    5 => B"000000_00100_00000_00101_00000_101010",
    
    -- 06: BNE $5, $0, 3 -> Daca e negativ, sari 3 instr (la NEXT: adresa 10)
    -- Hex: 14A00003
    6 => B"000101_00101_00000_0000000000000011",
    
    -- 07: ANDI $5, $4, 1 -> $5 = 1 daca e impar
    -- Hex: 30850001
    7 => B"001100_00100_00101_0000000000000001",
    
    -- 08: BEQ $5, $0, 1 -> Daca e par, sari peste incrementare (la NEXT: adresa 10)
    -- Hex: 10A00001
    8 => B"000100_00101_00000_0000000000000001",
    
    -- 09: ADDI $3, $3, 1 -> Incrementare count (doar pozitive & impare)
    -- Hex: 20630001
    9 => B"001000_00011_00011_0000000000000001",
    
    -- 10: ADDI $2, $2, 4 -> NEXT: adresa sir += 4
    -- Hex: 20420004
    10 => B"001000_00010_00010_0000000000000100",
    
    -- 11: ADDI $1, $1, -1 -> N = N - 1
    -- Hex: 2021FFFF
    11 => B"001000_00001_00001_1111111111111111",
    
    -- 12: J 3 -> Sari inapoi la inceputul buclei (Adresa 3)
    -- Hex: 08000003
    12 => B"000010_00000_00000_0000000000000011",
    
    -- 13: SW $3, 0($0) -> Scrie rezultatul la adresa 0
    -- Hex: AC030000
    13 => B"101011_00000_00011_0000000000000000",
    
    -- 14: J 14 -> Stop (bucla infinita)
    -- Hex: 0800000E
    14 => B"000010_00000_00000_0000000000001110",
    
    others => X"00000000"
);

begin

    process(Clk)
    begin
        if rising_edge(Clk) then
            if Rst = '1' then
                PC_reg <= (others => '0');
            elsif En = '1' then
                PC_reg <= next_pc;
            end if;
        end if;
    end process;

    pc_inc <= PC_reg + 4;
    PC_plus_4 <= pc_inc;

    branch_mux <= BranchAddress when PCSrc = '1' else pc_inc;
    
    next_pc <= JumpAddress when Jump = '1' else branch_mux;

    Instruction <= ROM(conv_integer(PC_reg(6 downto 2)));

end Behavioral;