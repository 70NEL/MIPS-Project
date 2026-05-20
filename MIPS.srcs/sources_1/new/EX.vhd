library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           ALUSrc : in STD_LOGIC;
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (2 downto 0);
           PC_plus_4 : in STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC;
           GTZ : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0));
end EX;

architecture Behavioral of EX is
    signal B : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal ALURes_i : STD_LOGIC_VECTOR(31 downto 0);
begin

    B <= RD2 when ALUSrc = '0' else Ext_Imm;

    BranchAddress <= PC_plus_4 + (Ext_Imm(29 downto 0) & "00");

    process(ALUOp, func)
begin
    case ALUOp is
        when "000" => -- R-Type
            case func is
                when "100000" => ALUCtrl <= "000"; -- ADD
                when "100010" => ALUCtrl <= "001"; -- SUB
                when "100100" => ALUCtrl <= "100"; -- AND
                when "100101" => ALUCtrl <= "101"; -- OR
                when "101010" => ALUCtrl <= "110"; -- SLT
                when others => ALUCtrl <= "111";
            end case;
        when "001" => ALUCtrl <= "000"; -- ADDI / LW / SW (Addition)
        when "010" => ALUCtrl <= "001"; -- BEQ / BNE (Subtraction)
        when "100" => ALUCtrl <= "100"; -- ANDI (AND)
        when "101" => ALUCtrl <= "101"; -- ORI (OR)
        when "110" => ALUCtrl <= "110"; -- SLTI (SLT)
        when others => ALUCtrl <= "111";
    end case;
end process;

    process(ALUCtrl, RD1, B, sa)
    begin
        case ALUCtrl is
            when "000" => ALURes_i <= RD1 + B;
            when "001" => ALURes_i <= RD1 - B;
            when "010" => ALURes_i <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));
            when "011" => ALURes_i <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa));
            when "100" => ALURes_i <= RD1 and B;
            when "101" => ALURes_i <= RD1 or B;
            when "110" => 
                if signed(RD1) < signed(B) then 
                    ALURes_i <= x"00000001"; 
                else 
                    ALURes_i <= x"00000000"; 
                end if;
            when others => ALURes_i <= (others => '0');
        end case;
    end process;

    ALURes <= ALURes_i;
    Zero <= '1' when ALURes_i = x"00000000" else '0';
    GTZ <= '1' when signed(ALURes_i) > 0 else '0';

end Behavioral;