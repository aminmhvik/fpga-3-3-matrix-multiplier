library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity passer is
    generic (
        WIDTH : positive := 64
    );
    port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        read  : in  STD_LOGIC;
        input : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end passer;

architecture RTL of passer is

    signal q_reg : STD_LOGIC_VECTOR(WIDTH-1 downto 0)
                   := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                q_reg <= (others => '0');

            elsif read = '1' then
                q_reg <= input;

            end if;

        end if;
    end process;

    q <= q_reg;

end RTL;