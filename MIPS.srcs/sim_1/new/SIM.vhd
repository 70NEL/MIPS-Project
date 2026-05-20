library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_test_env is
end sim_test_env;

architecture Behavioral of sim_test_env is

    signal clk : std_logic := '0';
    signal btn : std_logic_vector(4 downto 0) := (others => '0');
    signal sw  : std_logic_vector(15 downto 0) := (others => '0');
    signal led : std_logic_vector(15 downto 0);
    signal an  : std_logic_vector(7 downto 0);
    signal cat : std_logic_vector(6 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantierea procesorului
    UUT: entity work.test_env port map (
        clk => clk,
        btn => btn,
        sw  => sw,
        led => led,
        an  => an,
        cat => cat
    );

    -- Generarea ceasului (100 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Proces pentru simularea apasarii butonului de EN (btn(0))
    -- Proces pentru simularea apasarii butonului de EN (btn(0))
stim_proc: process
begin
    btn <= (others => '0');
    wait for 100 ns;
    
    btn(0) <= '1';
    wait for 10 ms; -- M?re?te acest timp!
    btn(0) <= '0';
    wait for 10 ms;

    -- Execut?m 10 instruc?iuni (10 ap?s?ri de buton)
    for i in 0 to 10 loop
        btn(0) <= '1';          -- Ap?s?m butonul
        wait for 100 ns;        -- ?inem ap?sat (MPG are timp s? vad? trecerea)
        btn(0) <= '0';          -- Eliber?m butonul
        wait for 200 ns;        -- A?tept?m între instruc?iuni
    end loop;

    wait;
end process;

end Behavioral;