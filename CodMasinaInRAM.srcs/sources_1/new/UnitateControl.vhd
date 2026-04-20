library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UnitateControl is
    Port (
        Instr : in std_logic_vector(5 downto 0);
        RegDst : out std_logic;
        ExtOp : out std_logic;
        ALUSrc : out std_logic;
        Branch : out std_logic;
        Jump : out std_logic;
        ALUOp : out std_logic_vector(2 downto 0);
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic
    );
end UnitateControl;

architecture Behavioral of UnitateControl is
begin
    process(Instr)
    begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
        Branch <= '0'; Jump <= '0'; MemWrite <= '0'; 
        MemtoReg <= '0'; RegWrite <= '0'; ALUOp <= "000";

        case Instr is
            when "000000" => -- Tip R (SLT)
                RegDst <= '1'; RegWrite <= '1'; ALUOp <= "000"; 
            
            when "100011" => -- LW
                ExtOp <= '1'; ALUSrc <= '1'; MemtoReg <= '1'; RegWrite <= '1'; ALUOp <= "001";
                
            when "101011" => -- SW
                ExtOp <= '1'; ALUSrc <= '1'; MemWrite <= '1'; ALUOp <= "001";
                
            when "001000" => -- ADDI
                ExtOp <= '1'; ALUSrc <= '1'; RegWrite <= '1'; ALUOp <= "001";
                
            when "001100" => -- ANDI
                ExtOp <= '0'; ALUSrc <= '1'; RegWrite <= '1'; ALUOp <= "100";

            when "000100" => -- BEQ
                ExtOp <= '1'; Branch <= '1'; ALUOp <= "010";

            when "000101" => -- BNE
                ExtOp <= '1'; Branch <= '1'; ALUOp <= "101";
                
            when "000010" => -- Jump
                Jump <= '1';
                
            when others => 
                null;
        end case;
    end process;
end Behavioral;