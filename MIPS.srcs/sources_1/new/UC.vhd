library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR (2 downto 0);
           JmpR : out STD_LOGIC;
           BNE : out STD_LOGIC);
end UC;

architecture Behavioral of UC is
begin

    process(Instr)
    begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
        Branch <= '0'; Jump <= '0'; MemWrite <= '0'; 
        MemtoReg <= '0'; RegWrite <= '0'; JmpR <= '0'; 
        ALUOp <= "000";
        BNE <= '0';

        case Instr is
            when "000000" => -- R-Type (ADD, SUB, SLT)
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "000"; -- codR

            when "001000" => -- ADDI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "001"; -- cod+

            when "100011" => -- LW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "001"; -- cod+

            when "101011" => -- SW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "001"; -- cod+

            when "000100" => -- BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "010"; -- cod-

            when "001100" => -- ANDI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "100"; -- cod&

            when "001101" => -- ORI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "101"; -- cod|

            when "000010" => -- J (Jump)
                Jump <= '1';

            when "001010" => -- SLTI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "110"; -- cod<
            
            when "000101" => -- BNE
                ExtOp <= '1';
                Branch <= '1';
                BNE <= '1'; 
                ALUOp <= "010"; -- cod-

            when others =>
                null;
        end case;
    end process;

end Behavioral;