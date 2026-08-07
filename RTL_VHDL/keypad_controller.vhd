library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keypad_controller is

    generic (
        CLK_FREQ_HZ : positive := 50000000;
        SCAN_HZ     : positive := 1000
    );

    port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;

        row : in STD_LOGIC_VECTOR(3 downto 0);
        col : out STD_LOGIC_VECTOR(2 downto 0);

        key_valid : out STD_LOGIC;
        key_code  : out STD_LOGIC_VECTOR(3 downto 0)
    );

end keypad_controller;


architecture RTL of keypad_controller is

    constant SCAN_TICKS :
        integer := CLK_FREQ_HZ / SCAN_HZ;

    signal counter :
        integer range 0 to SCAN_TICKS-1 := 0;

    signal col_reg :
        STD_LOGIC_VECTOR(2 downto 0) := "110";

    signal key_valid_reg :
        STD_LOGIC := '0';

    signal key_code_reg :
        STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

    signal key_latched :
        STD_LOGIC := '0';

    signal frame_has_key :
        STD_LOGIC := '0';

begin

    col <= col_reg;

    key_valid <= key_valid_reg;
    key_code  <= key_code_reg;


    process(clk)

        variable detected :
            STD_LOGIC;

    begin

        if rising_edge(clk) then

            if rst = '1' then

                counter <= 0;

                col_reg <= "110";

                key_valid_reg <= '0';
                key_code_reg <= (others => '0');

                key_latched <= '0';
                frame_has_key <= '0';

            else

                key_valid_reg <= '0';

                if counter = SCAN_TICKS-1 then

                    counter <= 0;

                    detected := '0';


                    case col_reg is

                        -- COLUMN 1
                        when "110" =>

                            -- 1 + * simultaneously = ENTER
                            if row(0) = '0' and row(3) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "1100";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(0) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0001";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(1) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0100";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(2) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0111";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(3) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "1010";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            end if;

                            col_reg <= "101";


                        -- COLUMN 2
                        when "101" =>

                            if row(0) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0010";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(1) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0101";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(2) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "1000";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(3) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0000";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            end if;

                            col_reg <= "011";


                        -- COLUMN 3
                        when others =>

                            if row(0) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0011";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(1) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "0110";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(2) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "1001";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            elsif row(3) = '0' then

                                detected := '1';

                                if key_latched = '0' then
                                    key_code_reg <= "1011";
                                    key_valid_reg <= '1';
                                    key_latched <= '1';
                                end if;

                            end if;

                            col_reg <= "110";

                    end case;


                    if detected = '1' then
                        frame_has_key <= '1';
                    end if;


                    if col_reg = "011" then

                        if frame_has_key = '0' and detected = '0' then
                            key_latched <= '0';
                        end if;

                        frame_has_key <= '0';

                    end if;

                else

                    counter <= counter + 1;

                end if;

            end if;

        end if;

    end process;

end RTL;