library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 
entity RegFile is 
port ( clk : in std_logic;
 en : in std_logic;
 ra1 : in std_logic_vector(4 downto 0);  -- Read Address 1 
 ra2 : in std_logic_vector(4 downto 0);  -- Read Address 2 
 wa : in std_logic_vector(4 downto 0);  -- Write Address 
 wd : in std_logic_vector(31 downto 0); -- Write Data 
 regwr : in std_logic;     -- comanda RegWrite 
 rd1 : out std_logic_vector(31 downto 0); -- Read Data 1 
 rd2 : out std_logic_vector(31 downto 0)); -- Read Data 2 
end RegFile; 
 
architecture Behavioral of RegFile is 
 
type rf_type is array(0 to 31) of std_logic_vector(31 downto 0); 
signal mem : rf_type:= (others =>X"00000000") ; 
 
begin 
 
 process(clk) 
 begin 
  if rising_edge(clk) then 
   if regwr = '1' then 
    mem(conv_integer(wa)) <= wd; -- scriere sincron? 
   end if; 
  end if; 
 end process; 
 
 rd1 <= mem(conv_integer(ra1)); -- citire asincron? 
 rd2 <= mem(conv_integer(ra2)); -- citire asincron? 
 
end Behavioral;