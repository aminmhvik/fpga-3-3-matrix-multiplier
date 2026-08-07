library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity matrix_rtl_top is

    generic (
        CLK_FREQ_HZ : positive := 50000000
    );

    port (

        clk : in STD_LOGIC;
        rst : in STD_LOGIC;

        keypad_row : in STD_LOGIC_VECTOR(3 downto 0);
        keypad_col : out STD_LOGIC_VECTOR(2 downto 0);

        lcd_data : out STD_LOGIC_VECTOR(7 downto 0);
        lcd_rs   : out STD_LOGIC;
        lcd_rw   : out STD_LOGIC;
        lcd_en   : out STD_LOGIC

    );

end matrix_rtl_top;


architecture RTL of matrix_rtl_top is


    ----------------------------------------------------------------
    -- KEYPAD
    ----------------------------------------------------------------

    signal key_valid :
        STD_LOGIC;

    signal key_code :
        STD_LOGIC_VECTOR(3 downto 0);


    ----------------------------------------------------------------
    -- INPUT REGISTERS
    ----------------------------------------------------------------

    signal A_R1_D :
        STD_LOGIC_VECTOR(31 downto 0);

    signal A_R2_D :
        STD_LOGIC_VECTOR(31 downto 0);

    signal A_R3_D :
        STD_LOGIC_VECTOR(31 downto 0);


    signal B_R1_D :
        STD_LOGIC_VECTOR(31 downto 0);

    signal B_R2_D :
        STD_LOGIC_VECTOR(31 downto 0);

    signal B_R3_D :
        STD_LOGIC_VECTOR(31 downto 0);


    signal A_R1_Q :
        STD_LOGIC_VECTOR(31 downto 0);

    signal A_R2_Q :
        STD_LOGIC_VECTOR(31 downto 0);

    signal A_R3_Q :
        STD_LOGIC_VECTOR(31 downto 0);


    signal B_R1_Q :
        STD_LOGIC_VECTOR(31 downto 0);

    signal B_R2_Q :
        STD_LOGIC_VECTOR(31 downto 0);

    signal B_R3_Q :
        STD_LOGIC_VECTOR(31 downto 0);


    signal A_R1_EN :
        STD_LOGIC := '0';

    signal A_R2_EN :
        STD_LOGIC := '0';

    signal A_R3_EN :
        STD_LOGIC := '0';

    signal B_R1_EN :
        STD_LOGIC := '0';

    signal B_R2_EN :
        STD_LOGIC := '0';

    signal B_R3_EN :
        STD_LOGIC := '0';


    ----------------------------------------------------------------
    -- INPUT FSM
    ----------------------------------------------------------------

    type input_state_type is (
        INPUT_A,
        INPUT_B,
        WAIT_ENTER,
        RESULT_STATE
    );

    signal input_state :
        input_state_type := INPUT_A;


    signal entry_index :
        integer range 0 to 8 := 0;

    signal first_digit :
        integer range 0 to 9 := 0;

    signal have_first_digit :
        STD_LOGIC := '0';


    signal A_count :
        integer range 0 to 9 := 0;

    signal B_count :
        integer range 0 to 9 := 0;


    ----------------------------------------------------------------
    -- COMPUTATION
    ----------------------------------------------------------------

    signal compute_start :
        STD_LOGIC := '0';

    signal compute_done :
        STD_LOGIC;


    signal C11 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C12 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C13 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C21 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C22 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C23 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C31 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C32 :
        STD_LOGIC_VECTOR(17 downto 0);

    signal C33 :
        STD_LOGIC_VECTOR(17 downto 0);


    ----------------------------------------------------------------
    -- PASSER
    ----------------------------------------------------------------

    signal C_R1_IN :
        STD_LOGIC_VECTOR(63 downto 0);

    signal C_R2_IN :
        STD_LOGIC_VECTOR(63 downto 0);

    signal C_R3_IN :
        STD_LOGIC_VECTOR(63 downto 0);


    signal C_R1_Q :
        STD_LOGIC_VECTOR(63 downto 0);

    signal C_R2_Q :
        STD_LOGIC_VECTOR(63 downto 0);

    signal C_R3_Q :
        STD_LOGIC_VECTOR(63 downto 0);


    signal passer_read :
        STD_LOGIC := '0';


    ----------------------------------------------------------------
    -- LCD
    ----------------------------------------------------------------

    signal lcd_input_start :
        STD_LOGIC := '0';

    signal lcd_result_start :
        STD_LOGIC := '0';


    signal result_stage1 :
        STD_LOGIC := '0';

    signal result_stage2 :
        STD_LOGIC := '0';


begin


    ----------------------------------------------------------------
    -- KEYPAD
    ----------------------------------------------------------------

    keypad_inst : entity work.keypad_controller

        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            SCAN_HZ     => 1000
        )

        port map (

            clk => clk,
            rst => rst,

            row => keypad_row,
            col => keypad_col,

            key_valid => key_valid,
            key_code  => key_code

        );


    ----------------------------------------------------------------
    -- HOLDERS
    ----------------------------------------------------------------

    holder_A1 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => A_R1_EN,
            input => A_R1_D,
            q     => A_R1_Q
        );


    holder_A2 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => A_R2_EN,
            input => A_R2_D,
            q     => A_R2_Q
        );


    holder_A3 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => A_R3_EN,
            input => A_R3_D,
            q     => A_R3_Q
        );


    holder_B1 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => B_R1_EN,
            input => B_R1_D,
            q     => B_R1_Q
        );


    holder_B2 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => B_R2_EN,
            input => B_R2_D,
            q     => B_R2_Q
        );


    holder_B3 : entity work.holder
        generic map (WIDTH => 32)
        port map (
            clk   => clk,
            rst   => rst,
            en    => B_R3_EN,
            input => B_R3_D,
            q     => B_R3_Q
        );


    ----------------------------------------------------------------
    -- COMPUTE
    ----------------------------------------------------------------

    compute_inst : entity work.matrix_compute

        port map (

            clk   => clk,
            rst   => rst,
            start => compute_start,


            A11 => A_R1_Q(7 downto 0),
            A12 => A_R1_Q(15 downto 8),
            A13 => A_R1_Q(23 downto 16),

            A21 => A_R2_Q(7 downto 0),
            A22 => A_R2_Q(15 downto 8),
            A23 => A_R2_Q(23 downto 16),

            A31 => A_R3_Q(7 downto 0),
            A32 => A_R3_Q(15 downto 8),
            A33 => A_R3_Q(23 downto 16),


            B11 => B_R1_Q(7 downto 0),
            B12 => B_R1_Q(15 downto 8),
            B13 => B_R1_Q(23 downto 16),

            B21 => B_R2_Q(7 downto 0),
            B22 => B_R2_Q(15 downto 8),
            B23 => B_R2_Q(23 downto 16),

            B31 => B_R3_Q(7 downto 0),
            B32 => B_R3_Q(15 downto 8),
            B33 => B_R3_Q(23 downto 16),


            C11 => C11,
            C12 => C12,
            C13 => C13,

            C21 => C21,
            C22 => C22,
            C23 => C23,

            C31 => C31,
            C32 => C32,
            C33 => C33,

            done => compute_done

        );


    ----------------------------------------------------------------
    -- RESULT REGISTER PACKING
    ----------------------------------------------------------------

    C_R1_IN <=
        "0000000000" &
        C13 &
        C12 &
        C11;

    C_R2_IN <=
        "0000000000" &
        C23 &
        C22 &
        C21;

    C_R3_IN <=
        "0000000000" &
        C33 &
        C32 &
        C31;


    ----------------------------------------------------------------
    -- PASSERS
    ----------------------------------------------------------------

    passer_C1 : entity work.passer
        generic map (WIDTH => 64)
        port map (
            clk   => clk,
            rst   => rst,
            read  => passer_read,
            input => C_R1_IN,
            q     => C_R1_Q
        );


    passer_C2 : entity work.passer
        generic map (WIDTH => 64)
        port map (
            clk   => clk,
            rst   => rst,
            read  => passer_read,
            input => C_R2_IN,
            q     => C_R2_Q
        );


    passer_C3 : entity work.passer
        generic map (WIDTH => 64)
        port map (
            clk   => clk,
            rst   => rst,
            read  => passer_read,
            input => C_R3_IN,
            q     => C_R3_Q
        );


    ----------------------------------------------------------------
    -- LCD
    ----------------------------------------------------------------

    lcd_inst : entity work.lcd_controller

        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ
        )

        port map (

            clk => clk,
            rst => rst,

            input_start  => lcd_input_start,
            result_start => lcd_result_start,


            A11 => A_R1_Q(7 downto 0),
            A12 => A_R1_Q(15 downto 8),
            A13 => A_R1_Q(23 downto 16),

            A21 => A_R2_Q(7 downto 0),
            A22 => A_R2_Q(15 downto 8),
            A23 => A_R2_Q(23 downto 16),

            A31 => A_R3_Q(7 downto 0),
            A32 => A_R3_Q(15 downto 8),
            A33 => A_R3_Q(23 downto 16),


            B11 => B_R1_Q(7 downto 0),
            B12 => B_R1_Q(15 downto 8),
            B13 => B_R1_Q(23 downto 16),

            B21 => B_R2_Q(7 downto 0),
            B22 => B_R2_Q(15 downto 8),
            B23 => B_R2_Q(23 downto 16),

            B31 => B_R3_Q(7 downto 0),
            B32 => B_R3_Q(15 downto 8),
            B33 => B_R3_Q(23 downto 16),


            A_count => A_count,
            B_count => B_count,


            C11 => C_R1_Q(17 downto 0),
            C12 => C_R1_Q(35 downto 18),
            C13 => C_R1_Q(53 downto 36),

            C21 => C_R2_Q(17 downto 0),
            C22 => C_R2_Q(35 downto 18),
            C23 => C_R2_Q(53 downto 36),

            C31 => C_R3_Q(17 downto 0),
            C32 => C_R3_Q(35 downto 18),
            C33 => C_R3_Q(53 downto 36),


            lcd_data => lcd_data,
            lcd_rs   => lcd_rs,
            lcd_rw   => lcd_rw,
            lcd_en   => lcd_en

        );


    ----------------------------------------------------------------
    -- HOLDER WRITE DATA
    ----------------------------------------------------------------

    process(
        key_valid,
        key_code,
        input_state,
        entry_index,
        have_first_digit,
        first_digit,
        A_R1_Q,
        A_R2_Q,
        A_R3_Q,
        B_R1_Q,
        B_R2_Q,
        B_R3_Q
    )

        variable value_int : integer range 0 to 99;

        variable new_value :
            STD_LOGIC_VECTOR(7 downto 0);

    begin

        A_R1_D <= A_R1_Q;
        A_R2_D <= A_R2_Q;
        A_R3_D <= A_R3_Q;

        B_R1_D <= B_R1_Q;
        B_R2_D <= B_R2_Q;
        B_R3_D <= B_R3_Q;


        A_R1_EN <= '0';
        A_R2_EN <= '0';
        A_R3_EN <= '0';

        B_R1_EN <= '0';
        B_R2_EN <= '0';
        B_R3_EN <= '0';


        if key_valid = '1' then

            -- CLEAR
            if key_code = "1011" then

                A_R1_D <= (others => '0');
                A_R2_D <= (others => '0');
                A_R3_D <= (others => '0');

                B_R1_D <= (others => '0');
                B_R2_D <= (others => '0');
                B_R3_D <= (others => '0');

                A_R1_EN <= '1';
                A_R2_EN <= '1';
                A_R3_EN <= '1';

                B_R1_EN <= '1';
                B_R2_EN <= '1';
                B_R3_EN <= '1';


            elsif key_code <= "1001" and
                  have_first_digit = '1' then

                value_int :=
                    first_digit * 10 +
                    TO_INTEGER(UNSIGNED(key_code));

                new_value :=
                    STD_LOGIC_VECTOR(
                        TO_UNSIGNED(value_int, 8)
                    );


                if input_state = INPUT_A then

                    case entry_index is

                        when 0 =>
                            A_R1_D(7 downto 0) <= new_value;
                            A_R1_EN <= '1';

                        when 1 =>
                            A_R1_D(15 downto 8) <= new_value;
                            A_R1_EN <= '1';

                        when 2 =>
                            A_R1_D(23 downto 16) <= new_value;
                            A_R1_EN <= '1';


                        when 3 =>
                            A_R2_D(7 downto 0) <= new_value;
                            A_R2_EN <= '1';

                        when 4 =>
                            A_R2_D(15 downto 8) <= new_value;
                            A_R2_EN <= '1';

                        when 5 =>
                            A_R2_D(23 downto 16) <= new_value;
                            A_R2_EN <= '1';


                        when 6 =>
                            A_R3_D(7 downto 0) <= new_value;
                            A_R3_EN <= '1';

                        when 7 =>
                            A_R3_D(15 downto 8) <= new_value;
                            A_R3_EN <= '1';

                        when others =>
                            A_R3_D(23 downto 16) <= new_value;
                            A_R3_EN <= '1';

                    end case;


                elsif input_state = INPUT_B then

                    -- B IS ENTERED COLUMN-WISE

                    case entry_index is

                        when 0 =>
                            B_R1_D(7 downto 0) <= new_value;
                            B_R1_EN <= '1';

                        when 1 =>
                            B_R2_D(7 downto 0) <= new_value;
                            B_R2_EN <= '1';

                        when 2 =>
                            B_R3_D(7 downto 0) <= new_value;
                            B_R3_EN <= '1';


                        when 3 =>
                            B_R1_D(15 downto 8) <= new_value;
                            B_R1_EN <= '1';

                        when 4 =>
                            B_R2_D(15 downto 8) <= new_value;
                            B_R2_EN <= '1';

                        when 5 =>
                            B_R3_D(15 downto 8) <= new_value;
                            B_R3_EN <= '1';


                        when 6 =>
                            B_R1_D(23 downto 16) <= new_value;
                            B_R1_EN <= '1';

                        when 7 =>
                            B_R2_D(23 downto 16) <= new_value;
                            B_R2_EN <= '1';

                        when others =>
                            B_R3_D(23 downto 16) <= new_value;
                            B_R3_EN <= '1';

                    end case;

                end if;

            end if;

        end if;

    end process;


    ----------------------------------------------------------------
    -- MAIN CONTROL FSM
    ----------------------------------------------------------------

    process(clk)

        variable digit_value : integer range 0 to 9;

    begin

        if rising_edge(clk) then

            if rst = '1' then

                input_state <= INPUT_A;

                entry_index <= 0;

                first_digit <= 0;

                have_first_digit <= '0';

                A_count <= 0;
                B_count <= 0;

                compute_start <= '0';

                passer_read <= '0';

                lcd_input_start <= '0';
                lcd_result_start <= '0';

                result_stage1 <= '0';
                result_stage2 <= '0';

            else

                compute_start <= '0';
                passer_read <= '0';

                lcd_input_start <= '0';
                lcd_result_start <= '0';


                ------------------------------------------------
                -- RESULT PIPELINE
                ------------------------------------------------

                if compute_done = '1' then

                    passer_read <= '1';
                    result_stage1 <= '1';

                else

                    result_stage1 <= '0';

                end if;


                if result_stage1 = '1' then

                    result_stage2 <= '1';

                else

                    result_stage2 <= '0';

                end if;


                if result_stage2 = '1' then

                    lcd_result_start <= '1';

                    input_state <= RESULT_STATE;

                    result_stage2 <= '0';

                end if;


                ------------------------------------------------
                -- KEYPAD
                ------------------------------------------------

                if key_valid = '1' then

                    ------------------------------------------------
                    -- CLEAR
                    ------------------------------------------------

                    if key_code = "1011" then

                        input_state <= INPUT_A;

                        entry_index <= 0;

                        first_digit <= 0;

                        have_first_digit <= '0';

                        A_count <= 0;
                        B_count <= 0;

                        lcd_input_start <= '1';


                    ------------------------------------------------
                    -- ENTER = STAR + 1
                    ------------------------------------------------

                    elsif key_code = "1100" then

                        if input_state = WAIT_ENTER then

                            compute_start <= '1';

                        end if;


                    ------------------------------------------------
                    -- DIGIT
                    ------------------------------------------------

                    elsif key_code <= "1001" then

                        digit_value :=
                            TO_INTEGER(
                                UNSIGNED(key_code)
                            );


                        if have_first_digit = '0' then

                            first_digit <= digit_value;

                            have_first_digit <= '1';


                        else

                            have_first_digit <= '0';

                            lcd_input_start <= '0';


                            if input_state = INPUT_A then

                                if entry_index = 8 then

                                    A_count <= 9;

                                    entry_index <= 0;

                                    input_state <= INPUT_B;

                                else

                                    A_count <= entry_index + 1;

                                    entry_index <= entry_index + 1;

                                end if;


                                -- display is updated one cycle later
                                lcd_input_start <= '1';


                            elsif input_state = INPUT_B then

                                if entry_index = 8 then

                                    B_count <= 9;

                                    input_state <= WAIT_ENTER;

                                    entry_index <= 8;

                                else

                                    B_count <= entry_index + 1;

                                    entry_index <= entry_index + 1;

                                end if;


                                lcd_input_start <= '1';

                            end if;

                        end if;

                    end if;

                end if;

            end if;

        end if;

    end process;

end RTL;