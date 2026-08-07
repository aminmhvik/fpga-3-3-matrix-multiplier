library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller is

    generic (
        CLK_FREQ_HZ : positive := 50000000
    );

    port (

        clk : in STD_LOGIC;
        rst : in STD_LOGIC;

        input_start  : in STD_LOGIC;
        result_start : in STD_LOGIC;

        A11 : in STD_LOGIC_VECTOR(7 downto 0);
        A12 : in STD_LOGIC_VECTOR(7 downto 0);
        A13 : in STD_LOGIC_VECTOR(7 downto 0);

        A21 : in STD_LOGIC_VECTOR(7 downto 0);
        A22 : in STD_LOGIC_VECTOR(7 downto 0);
        A23 : in STD_LOGIC_VECTOR(7 downto 0);

        A31 : in STD_LOGIC_VECTOR(7 downto 0);
        A32 : in STD_LOGIC_VECTOR(7 downto 0);
        A33 : in STD_LOGIC_VECTOR(7 downto 0);


        B11 : in STD_LOGIC_VECTOR(7 downto 0);
        B12 : in STD_LOGIC_VECTOR(7 downto 0);
        B13 : in STD_LOGIC_VECTOR(7 downto 0);

        B21 : in STD_LOGIC_VECTOR(7 downto 0);
        B22 : in STD_LOGIC_VECTOR(7 downto 0);
        B23 : in STD_LOGIC_VECTOR(7 downto 0);

        B31 : in STD_LOGIC_VECTOR(7 downto 0);
        B32 : in STD_LOGIC_VECTOR(7 downto 0);
        B33 : in STD_LOGIC_VECTOR(7 downto 0);


        A_count : in integer range 0 to 9;
        B_count : in integer range 0 to 9;


        C11 : in STD_LOGIC_VECTOR(17 downto 0);
        C12 : in STD_LOGIC_VECTOR(17 downto 0);
        C13 : in STD_LOGIC_VECTOR(17 downto 0);

        C21 : in STD_LOGIC_VECTOR(17 downto 0);
        C22 : in STD_LOGIC_VECTOR(17 downto 0);
        C23 : in STD_LOGIC_VECTOR(17 downto 0);

        C31 : in STD_LOGIC_VECTOR(17 downto 0);
        C32 : in STD_LOGIC_VECTOR(17 downto 0);
        C33 : in STD_LOGIC_VECTOR(17 downto 0);


        lcd_data : out STD_LOGIC_VECTOR(7 downto 0);
        lcd_rs   : out STD_LOGIC;
        lcd_rw   : out STD_LOGIC;
        lcd_en   : out STD_LOGIC

    );

end lcd_controller;


architecture RTL of lcd_controller is

    constant US_TICKS  : integer := CLK_FREQ_HZ / 1000000;
    constant MS_TICKS  : integer := CLK_FREQ_HZ / 1000;

    type state_type is (
        INIT_WAIT,
        INIT1,
        INIT2,
        INIT3,
        INIT4,
        READY,

        SET_LINE1,
        WRITE_LINE1,

        SET_LINE2,
        WRITE_LINE2,

        RESULT_HOLD,

        RESULT_PAGE2
    );

    signal state : state_type := INIT_WAIT;

    signal counter : integer := 0;

    signal char_index : integer range 1 to 32 := 1;

    signal result_page : integer range 0 to 1 := 0;

    signal line1 : string(1 to 32) := (others => ' ');
    signal line2 : string(1 to 32) := (others => ' ');

    signal lcd_data_reg : STD_LOGIC_VECTOR(7 downto 0)
                         := (others => '0');

    signal lcd_rs_reg : STD_LOGIC := '0';
    signal lcd_en_reg : STD_LOGIC := '0';


    function ascii_char(c : character)
        return STD_LOGIC_VECTOR is
    begin
        return STD_LOGIC_VECTOR(
            TO_UNSIGNED(character'pos(c), 8)
        );
    end function;


    function dec2(
        v : STD_LOGIC_VECTOR(7 downto 0)
    )
    return string is

        variable s : string(1 to 2);
        variable n : integer;

    begin

        n := TO_INTEGER(UNSIGNED(v));

        s(1) := character'val(character'pos('0') + (n / 10));
        s(2) := character'val(character'pos('0') + (n mod 10));

        return s;

    end function;


    function dec5(
        v : STD_LOGIC_VECTOR(17 downto 0)
    )
    return string is

        variable s : string(1 to 5);
        variable n : integer;

    begin

        n := TO_INTEGER(UNSIGNED(v));

        s(1) := character'val(character'pos('0') + ((n / 10000) mod 10));
        s(2) := character'val(character'pos('0') + ((n / 1000) mod 10));
        s(3) := character'val(character'pos('0') + ((n / 100) mod 10));
        s(4) := character'val(character'pos('0') + ((n / 10) mod 10));
        s(5) := character'val(character'pos('0') + (n mod 10));

        return s;

    end function;


    function make_input_line(
        v11 : STD_LOGIC_VECTOR(7 downto 0);
        v12 : STD_LOGIC_VECTOR(7 downto 0);
        v13 : STD_LOGIC_VECTOR(7 downto 0);

        v21 : STD_LOGIC_VECTOR(7 downto 0);
        v22 : STD_LOGIC_VECTOR(7 downto 0);
        v23 : STD_LOGIC_VECTOR(7 downto 0);

        v31 : STD_LOGIC_VECTOR(7 downto 0);
        v32 : STD_LOGIC_VECTOR(7 downto 0);
        v33 : STD_LOGIC_VECTOR(7 downto 0);

        valid_count : integer
    )
    return string is

        variable s : string(1 to 32);

        variable d : string(1 to 2);

    begin

        s := "[(--,--,--)(--,--,--)(--,--,--)]";


        if valid_count >= 1 then
            d := dec2(v11);
            s(3 to 4) := d;
        end if;

        if valid_count >= 2 then
            d := dec2(v12);
            s(6 to 7) := d;
        end if;

        if valid_count >= 3 then
            d := dec2(v13);
            s(9 to 10) := d;
        end if;


        if valid_count >= 4 then
            d := dec2(v21);
            s(13 to 14) := d;
        end if;

        if valid_count >= 5 then
            d := dec2(v22);
            s(16 to 17) := d;
        end if;

        if valid_count >= 6 then
            d := dec2(v23);
            s(19 to 20) := d;
        end if;


        if valid_count >= 7 then
            d := dec2(v31);
            s(23 to 24) := d;
        end if;

        if valid_count >= 8 then
            d := dec2(v32);
            s(26 to 27) := d;
        end if;

        if valid_count >= 9 then
            d := dec2(v33);
            s(29 to 30) := d;
        end if;

        return s;

    end function;


    function make_result_line(
        v1 : STD_LOGIC_VECTOR(17 downto 0);
        v2 : STD_LOGIC_VECTOR(17 downto 0);
        v3 : STD_LOGIC_VECTOR(17 downto 0)
    )
    return string is

        variable s : string(1 to 32);

    begin

        s := (others => ' ');

        s(1) := '[';

        s(2 to 6) := dec5(v1);
        s(7) := ',';

        s(8 to 12) := dec5(v2);
        s(13) := ',';

        s(14 to 18) := dec5(v3);

        s(19) := ']';

        return s;

    end function;


begin

    lcd_data <= lcd_data_reg;
    lcd_rs   <= lcd_rs_reg;
    lcd_en   <= lcd_en_reg;

    lcd_rw   <= '0';


    process(clk)

        variable delay_value : integer;

    begin

        if rising_edge(clk) then

            if rst = '1' then

                state <= INIT_WAIT;

                counter <= 0;
                char_index <= 1;

                lcd_data_reg <= (others => '0');

                lcd_rs_reg <= '0';
                lcd_en_reg <= '0';

                result_page <= 0;

            else

                lcd_en_reg <= '0';


                case state is


                    when INIT_WAIT =>

                        if counter >= 20 * MS_TICKS then

                            counter <= 0;
                            state <= INIT1;

                        else

                            counter <= counter + 1;

                        end if;


                    when INIT1 =>

                        lcd_data_reg <= x"38";
                        lcd_rs_reg <= '0';
                        lcd_en_reg <= '1';

                        counter <= 0;
                        state <= INIT2;


                    when INIT2 =>

                        if counter >= 2 * MS_TICKS then

                            counter <= 0;

                            lcd_data_reg <= x"0C";
                            lcd_rs_reg <= '0';
                            lcd_en_reg <= '1';

                            state <= INIT3;

                        else

                            counter <= counter + 1;

                        end if;


                    when INIT3 =>

                        if counter >= 2 * MS_TICKS then

                            counter <= 0;

                            lcd_data_reg <= x"01";
                            lcd_rs_reg <= '0';
                            lcd_en_reg <= '1';

                            state <= INIT4;

                        else

                            counter <= counter + 1;

                        end if;


                    when INIT4 =>

                        if counter >= 2 * MS_TICKS then

                            counter <= 0;

                            lcd_data_reg <= x"06";
                            lcd_rs_reg <= '0';
                            lcd_en_reg <= '1';

                            state <= READY;

                        else

                            counter <= counter + 1;

                        end if;


                    when READY =>

                        if input_start = '1' then

                            line1 <= make_input_line(
                                A11,A12,A13,
                                A21,A22,A23,
                                A31,A32,A33,
                                A_count
                            );

                            line2 <= make_input_line(
                                B11,B12,B13,
                                B21,B22,B23,
                                B31,B32,B33,
                                B_count
                            );

                            char_index <= 1;

                            state <= SET_LINE1;


                        elsif result_start = '1' then

                            line1 <= make_result_line(
                                C11,C12,C13
                            );

                            line2 <= make_result_line(
                                C21,C22,C23
                            );

                            result_page <= 0;

                            char_index <= 1;

                            state <= SET_LINE1;

                        end if;


                    when SET_LINE1 =>

                        lcd_data_reg <= x"80";
                        lcd_rs_reg <= '0';
                        lcd_en_reg <= '1';

                        counter <= 0;
                        char_index <= 1;

                        state <= WRITE_LINE1;


                    when WRITE_LINE1 =>

                        lcd_data_reg <= ascii_char(line1(char_index));
                        lcd_rs_reg <= '1';
                        lcd_en_reg <= '1';

                        if char_index = 32 then

                            char_index <= 1;
                            counter <= 0;

                            state <= SET_LINE2;

                        else

                            char_index <= char_index + 1;

                            counter <= 0;

                        end if;


                    when SET_LINE2 =>

                        if counter >= 100 * US_TICKS then

                            lcd_data_reg <= x"C0";
                            lcd_rs_reg <= '0';
                            lcd_en_reg <= '1';

                            counter <= 0;
                            char_index <= 1;

                            state <= WRITE_LINE2;

                        else

                            counter <= counter + 1;

                        end if;


                    when WRITE_LINE2 =>

                        lcd_data_reg <= ascii_char(line2(char_index));
                        lcd_rs_reg <= '1';
                        lcd_en_reg <= '1';

                        if char_index = 32 then

                            counter <= 0;

                            if result_page = 0 then
                                state <= RESULT_HOLD;
                            else
                                state <= RESULT_HOLD;
                            end if;

                        else

                            char_index <= char_index + 1;

                            counter <= 0;

                        end if;


                    when RESULT_HOLD =>

                        if result_page = 0 then

                            if counter >= 1000 * MS_TICKS then

                                line1 <= make_result_line(
                                    C31,C32,C33
                                );

                                line2 <= (others => ' ');

                                result_page <= 1;

                                counter <= 0;
                                char_index <= 1;

                                state <= SET_LINE1;

                            else

                                counter <= counter + 1;

                            end if;

                        else

                            if counter >= 1000 * MS_TICKS then

                                line1 <= make_result_line(
                                    C11,C12,C13
                                );

                                line2 <= make_result_line(
                                    C21,C22,C23
                                );

                                result_page <= 0;

                                counter <= 0;
                                char_index <= 1;

                                state <= SET_LINE1;

                            else

                                counter <= counter + 1;

                            end if;

                        end if;


                    when others =>

                        state <= READY;

                end case;

            end if;

        end if;

    end process;

end RTL;