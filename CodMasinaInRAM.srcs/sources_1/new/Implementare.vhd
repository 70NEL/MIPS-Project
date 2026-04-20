library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProblemaCodMasina is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end ProblemaCodMasina;

architecture Behavioral of ProblemaCodMasina is

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

signal pc : std_logic_vector(5 downto 0) := "000000";
signal en : std_logic;
signal instr_curenta : std_logic_vector(31 downto 0);

type t_mem is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem_program : t_mem := (
    -- Adresa 00: LW $1, 4($0)  -> Incarca N din memoria de date (adresa 4)
    0 => B"100011_00000_00001_0000000000000100", 
    -- Adresa 01: ADDI $2, $0, 8 -> Adresa de start a sirului este 8
    1 => B"001000_00000_00010_0000000000001000",
    -- Adresa 02: ADDI $3, $0, 0 -> Registrul $3 va pastra numarul de valori gasite
    2 => B"001000_00000_00011_0000000000000000",
    
    -- Adresa 03: BEQ $1, $0, 10 -> Daca N=0, sari la instructiunea de la adresa 14
    3 => B"000100_00001_00000_0000000000001010",
    -- Adresa 04: LW $4, 0($2)  -> Incarca elementul curent din sir
    4 => B"100011_00010_00100_0000000000000000",
    
    -- Adresa 05: SLT $5, $4, $0 -> Daca $4 < 0, atunci $5 = 1
    5 => B"000000_00100_00000_00101_00000_101010",
    -- Adresa 06: BNE $5, $0, 4  -> Daca e negativ ($5 != 0), sari peste incrementare la adresa 11
    6 => B"000101_00101_00000_0000000000000100",
    
    -- Adresa 07: ANDI $5, $4, 1 -> $5 = $4 AND 1 (izolam ultimul bit)
    7 => B"001100_00100_00101_0000000000000001",
    -- Adresa 08: BEQ $5, $0, 2  -> Daca e par ($5 == 0), sari la adresa 11
    8 => B"000100_00101_00000_0000000000000010",
    
    -- Adresa 09: ADDI $3, $3, 1 -> INCREMENTARE: am gasit un nr. pozitiv si impar
    9 => B"001000_00011_00011_0000000000000001",
    
    -- Adresa 10: ADDI $2, $2, 4 -> Treci la urmatoarea adresa (presupunem cuvinte de 4 octeti)
    10=> B"001000_00010_00010_0000000000000100",
    -- Adresa 11: ADDI $1, $1, -1 -> N = N - 1
    11=> B"001000_00001_00001_1111111111111111",
    -- Adresa 12: J 3            -> Salt inapoi la inceputul buclei
    12=> B"000010_0000000000000000000000000011",
    
    -- --- FINAL ---
    -- Adresa 13: SW $3, 0($0)  -> Salveaza rezultatul final la adresa 0
    13=> B"101011_00000_00011_0000000000000000",
    -- Adresa 14: J 14           -> Infinite loop (Stop)
    14=> B"000010_0000000000000000000000001110",
    
    others => X"00000000"
);

begin
    monopulse: MPG port map(en, btn(0), clk);
    comp_ssd: SSD port map(clk, instr_curenta, an, cat);
    
    instr_curenta <= mem_program(conv_integer(pc));
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                pc <= pc + 1;
            end if;
        end if;
    end process;

    led(5 downto 0) <= pc;
    led(15 downto 6) <= (others => '0');

end Behavioral;