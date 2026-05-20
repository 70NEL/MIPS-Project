library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( clk       : in  STD_LOGIC;
           en        : in  STD_LOGIC;
           MemWrite  : in  STD_LOGIC;
           ALURes_in : in  STD_LOGIC_VECTOR (31 downto 0);
           RD2       : in  STD_LOGIC_VECTOR (31 downto 0);
           MemData   : out STD_LOGIC_VECTOR (31 downto 0);
           ALURes_out: out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is
    type mem_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal DATA_MEM : mem_type := (
        0 => x"00000000",
        
        1 => x"00000003", -- N = 3 elemente
        
        2 => x"00000005", -- Element 1: 5 (Pozitiv, Impar)
        3 => x"00000004", -- Element 2: 4 (Pozitiv, Par)
        4 => x"FFFFFFF1", -- Element 3: -15 (Negativ)
        others => x"00000000"
    );
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                DATA_MEM(conv_integer(ALURes_in(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;

    MemData <= DATA_MEM(conv_integer(ALURes_in(7 downto 2)));

    ALURes_out <= ALURes_in;

end Behavioral;