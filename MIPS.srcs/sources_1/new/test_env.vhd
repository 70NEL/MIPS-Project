library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

    signal en, rst : std_logic;
    signal p_instruction, p_pc_4, p_rd1, p_rd2, p_ext_imm : std_logic_vector(31 downto 0);
    signal p_func : std_logic_vector(5 downto 0);
    signal p_sa : std_logic_vector(4 downto 0);
    signal p_mux_ssd : std_logic_vector(31 downto 0);
    
    signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite, JmpR : std_logic;
    signal ALUOp : std_logic_vector(2 downto 0);
    signal BNE : std_logic;
    signal p_zero, p_gtz : std_logic;
    signal p_alures, p_alures_mem, p_branch_addr : std_logic_vector(31 downto 0);
    signal p_mem_data : std_logic_vector(31 downto 0);
    signal p_wd_final : std_logic_vector(31 downto 0);
    signal p_pcsrc : std_logic;
    signal p_jump_addr : std_logic_vector(31 downto 0);
begin
    
    p_pcsrc <= (Branch and p_zero) when BNE = '0' else (Branch and (not p_zero));
    p_wd_final <= p_mem_data when MemtoReg = '1' else p_alures_mem;
    p_jump_addr <= p_pc_4(31 downto 28) & p_instruction(25 downto 0) & "00";
    
    U_MPG: entity work.MPG port map(en, btn(0), clk);
    
    rst <= btn(1);

    U_IF: entity work.IFetch port map(
        Clk => clk, 
        Rst => rst, 
        En => en,
        PCSrc => p_pcsrc,
        Jump => Jump, 
        JumpAddress => p_jump_addr,
        BranchAddress => p_branch_addr,
        Instruction => p_instruction,
        PC_plus_4 => p_pc_4
    );

    U_ID: entity work.ID port map(
        Clk => clk, 
        En => en,
        Instr => p_instruction(25 downto 0),
        WD => p_wd_final,
        RegWrite => RegWrite, 
        RegDst => RegDst, 
        ExtOp => ExtOp,
        RD1 => p_rd1, 
        RD2 => p_rd2, 
        Ext_Imm => p_ext_imm,
        func => p_func, 
        sa => p_sa
    );

    U_UC: entity work.UC port map(
    Instr => p_instruction(31 downto 26),
    RegDst => RegDst, 
    ExtOp => ExtOp, 
    ALUSrc => ALUSrc,
    Branch => Branch, 
    Jump => Jump, 
    MemWrite => MemWrite,
    MemtoReg => MemtoReg, 
    RegWrite => RegWrite, 
    ALUOp => ALUOp,
    JmpR => JmpR,
    BNE => BNE
);

    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

    process(sw(7 downto 5), p_instruction, p_pc_4, p_rd1, p_rd2, p_ext_imm, p_func, p_sa)
    variable zext_func : std_logic_vector(31 downto 0);
    variable zext_sa : std_logic_vector(31 downto 0);
    begin
        zext_func := (others => '0');
        zext_func(5 downto 0) := p_func;
        
        zext_sa := (others => '0');
        zext_sa(4 downto 0) := p_sa;
    
        case sw(7 downto 5) is
            when "000" => p_mux_ssd <= p_instruction;
            when "001" => p_mux_ssd <= p_pc_4;
            when "010" => p_mux_ssd <= p_rd1;
            when "011" => p_mux_ssd <= p_rd2;
            when "100" => p_mux_ssd <= p_rd1 + p_rd2;
            when "101" => p_mux_ssd <= p_ext_imm;
            when "110" => p_mux_ssd <= zext_func;
            when "111" => p_mux_ssd <= zext_sa;
            when others => p_mux_ssd <= p_pc_4 + p_ext_imm;
        end case;
        
    end process;
    
    U_EX: entity work.EX port map(
        RD1 => p_rd1,
        ALUSrc => ALUSrc,
        RD2 => p_rd2,
        Ext_Imm => p_ext_imm,
        sa => p_sa,
        func => p_func,
        ALUOp => ALUOp,
        PC_plus_4 => p_pc_4,
        Zero => p_zero,
        GTZ => p_gtz,
        ALURes => p_alures,
        BranchAddress => p_branch_addr
    );
    
    U_MEM: entity work.MEM port map(
        clk => clk,
        en => en,
        MemWrite => MemWrite,
        ALURes_in => p_alures,
        RD2 => p_rd2,
        MemData => p_mem_data,
        ALURes_out => p_alures_mem
    );

    U_SSD: entity work.SSD port map(clk, p_mux_ssd, an, cat);

end Behavioral;