library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity matrix_rtl_tb is
end matrix_rtl_tb;


architecture SIM of matrix_rtl_tb is

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal start : STD_LOGIC := '0';


    signal A11 : STD_LOGIC_VECTOR(7 downto 0) := x"01";
    signal A12 : STD_LOGIC_VECTOR(7 downto 0) := x"02";
    signal A13 : STD_LOGIC_VECTOR(7 downto 0) := x"03";

    signal A21 : STD_LOGIC_VECTOR(7 downto 0) := x"04";
    signal A22 : STD_LOGIC_VECTOR(7 downto 0) := x"05";
    signal A23 : STD_LOGIC_VECTOR(7 downto 0) := x"06";

    signal A31 : STD_LOGIC_VECTOR(7 downto 0) := x"07";
    signal A32 : STD_LOGIC_VECTOR(7 downto 0) := x"08";
    signal A33 : STD_LOGIC_VECTOR(7 downto 0) := x"09";


    signal B11 : STD_LOGIC_VECTOR(7 downto 0) := x"09";
    signal B12 : STD_LOGIC_VECTOR(7 downto 0) := x"08";
    signal B13 : STD_LOGIC_VECTOR(7 downto 0) := x"07";

    signal B21 : STD_LOGIC_VECTOR(7 downto 0) := x"06";
    signal B22 : STD_LOGIC_VECTOR(7 downto 0) := x"05";
    signal B23 : STD_LOGIC_VECTOR(7 downto 0) := x"04";

    signal B31 : STD_LOGIC_VECTOR(7 downto 0) := x"03";
    signal B32 : STD_LOGIC_VECTOR(7 downto 0) := x"02";
    signal B33 : STD_LOGIC_VECTOR(7 downto 0) := x"01";


    signal C11 : STD_LOGIC_VECTOR(17 downto 0);
    signal C12 : STD_LOGIC_VECTOR(17 downto 0);
    signal C13 : STD_LOGIC_VECTOR(17 downto 0);

    signal C21 : STD_LOGIC_VECTOR(17 downto 0);
    signal C22 : STD_LOGIC_VECTOR(17 downto 0);
    signal C23 : STD_LOGIC_VECTOR(17 downto 0);

    signal C31 : STD_LOGIC_VECTOR(17 downto 0);
    signal C32 : STD_LOGIC_VECTOR(17 downto 0);
    signal C33 : STD_LOGIC_VECTOR(17 downto 0);

    signal done : STD_LOGIC;


begin

    clk <= not clk after 5 ns;


    DUT : entity work.matrix_compute

        port map (

            clk   => clk,
            rst   => rst,
            start => start,

            A11 => A11,
            A12 => A12,
            A13 => A13,

            A21 => A21,
            A22 => A22,
            A23 => A23,

            A31 => A31,
            A32 => A32,
            A33 => A33,


            B11 => B11,
            B12 => B12,
            B13 => B13,

            B21 => B21,
            B22 => B22,
            B23 => B23,

            B31 => B31,
            B32 => B32,
            B33 => B33,


            C11 => C11,
            C12 => C12,
            C13 => C13,

            C21 => C21,
            C22 => C22,
            C23 => C23,

            C31 => C31,
            C32 => C32,
            C33 => C33,

            done => done

        );


    stimulus : process
    begin

        ------------------------------------------------
        -- RESET
        ------------------------------------------------

        rst <= '1';

        wait for 30 ns;

        rst <= '0';

        wait for 20 ns;


        ------------------------------------------------
        -- START
        ------------------------------------------------

        start <= '1';

        wait for 10 ns;

        start <= '0';


        ------------------------------------------------
        -- WAIT
        ------------------------------------------------

        wait for 30 ns;


        ------------------------------------------------
        -- CHECK
        ------------------------------------------------

        assert TO_INTEGER(UNSIGNED(C11)) = 30
            report "C11 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C12)) = 24
            report "C12 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C13)) = 18
            report "C13 ERROR"
            severity error;


        assert TO_INTEGER(UNSIGNED(C21)) = 84
            report "C21 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C22)) = 69
            report "C22 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C23)) = 54
            report "C23 ERROR"
            severity error;


        assert TO_INTEGER(UNSIGNED(C31)) = 138
            report "C31 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C32)) = 114
            report "C32 ERROR"
            severity error;

        assert TO_INTEGER(UNSIGNED(C33)) = 90
            report "C33 ERROR"
            severity error;


        assert done = '1'
            report "DONE SIGNAL ERROR"
            severity error;


        report "====================================";
        report "3x3 MATRIX MULTIPLICATION PASSED";
        report "====================================";


        wait;

    end process;

end SIM;