library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity matrix_compute is
    port (

        clk   : in STD_LOGIC;
        rst   : in STD_LOGIC;
        start : in STD_LOGIC;

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

        C11 : out STD_LOGIC_VECTOR(17 downto 0);
        C12 : out STD_LOGIC_VECTOR(17 downto 0);
        C13 : out STD_LOGIC_VECTOR(17 downto 0);

        C21 : out STD_LOGIC_VECTOR(17 downto 0);
        C22 : out STD_LOGIC_VECTOR(17 downto 0);
        C23 : out STD_LOGIC_VECTOR(17 downto 0);

        C31 : out STD_LOGIC_VECTOR(17 downto 0);
        C32 : out STD_LOGIC_VECTOR(17 downto 0);
        C33 : out STD_LOGIC_VECTOR(17 downto 0);

        done : out STD_LOGIC
    );

end matrix_compute;


architecture RTL of matrix_compute is

    signal C11_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C12_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C13_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');

    signal C21_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C22_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C23_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');

    signal C31_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C32_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal C33_reg : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');

    signal done_reg : STD_LOGIC := '0';


    function mac3(
        a1 : STD_LOGIC_VECTOR(7 downto 0);
        b1 : STD_LOGIC_VECTOR(7 downto 0);

        a2 : STD_LOGIC_VECTOR(7 downto 0);
        b2 : STD_LOGIC_VECTOR(7 downto 0);

        a3 : STD_LOGIC_VECTOR(7 downto 0);
        b3 : STD_LOGIC_VECTOR(7 downto 0)
    )
    return STD_LOGIC_VECTOR is

        variable p1 : UNSIGNED(15 downto 0);
        variable p2 : UNSIGNED(15 downto 0);
        variable p3 : UNSIGNED(15 downto 0);

        variable sum : UNSIGNED(17 downto 0);

    begin

        p1 := UNSIGNED(a1) * UNSIGNED(b1);
        p2 := UNSIGNED(a2) * UNSIGNED(b2);
        p3 := UNSIGNED(a3) * UNSIGNED(b3);

        sum :=
            RESIZE(p1, 18) +
            RESIZE(p2, 18) +
            RESIZE(p3, 18);

        return STD_LOGIC_VECTOR(sum);

    end function;

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if rst = '1' then

                C11_reg <= (others => '0');
                C12_reg <= (others => '0');
                C13_reg <= (others => '0');

                C21_reg <= (others => '0');
                C22_reg <= (others => '0');
                C23_reg <= (others => '0');

                C31_reg <= (others => '0');
                C32_reg <= (others => '0');
                C33_reg <= (others => '0');

                done_reg <= '0';

            else

                done_reg <= '0';

                if start = '1' then

                    C11_reg <= mac3(
                        A11, B11,
                        A12, B21,
                        A13, B31
                    );

                    C12_reg <= mac3(
                        A11, B12,
                        A12, B22,
                        A13, B32
                    );

                    C13_reg <= mac3(
                        A11, B13,
                        A12, B23,
                        A13, B33
                    );


                    C21_reg <= mac3(
                        A21, B11,
                        A22, B21,
                        A23, B31
                    );

                    C22_reg <= mac3(
                        A21, B12,
                        A22, B22,
                        A23, B32
                    );

                    C23_reg <= mac3(
                        A21, B13,
                        A22, B23,
                        A23, B33
                    );


                    C31_reg <= mac3(
                        A31, B11,
                        A32, B21,
                        A33, B31
                    );

                    C32_reg <= mac3(
                        A31, B12,
                        A32, B22,
                        A33, B32
                    );

                    C33_reg <= mac3(
                        A31, B13,
                        A32, B23,
                        A33, B33
                    );

                    done_reg <= '1';

                end if;

            end if;

        end if;

    end process;


    C11 <= C11_reg;
    C12 <= C12_reg;
    C13 <= C13_reg;

    C21 <= C21_reg;
    C22 <= C22_reg;
    C23 <= C23_reg;

    C31 <= C31_reg;
    C32 <= C32_reg;
    C33 <= C33_reg;

    done <= done_reg;

end RTL;