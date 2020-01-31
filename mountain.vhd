library IEEE;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."*";
use IEEE.std_logic_unsigned."/=";
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity Mountain is
  port (
    clk: in std_logic := '0';
    go: in std_logic := '0';
    start: in std_logic_vector(9 downto 0) := (others => '0');
    peak: out std_logic_vector(17 downto 0) := (others => '0');
    len: out std_logic_vector(7 downto 0) := (others => '0');
    continue: out std_logic := '0'
  );
end Mountain;

architecture Main of Mountain is
  signal height_reg: std_logic_vector(17 downto 0) := (others => '0');
  signal peak_reg: std_logic_vector(17 downto 0) := (others => '0');
  signal len_reg: std_logic_vector(7 downto 0) := (others => '0');
  signal odd_start: std_logic_vector(9 downto 0) := (others => '0');

begin
  peak <= peak_reg;
  len <= len_reg;
  continue <= '1' when height_reg = "000000000000000001" else '0';

  process (clk)
    variable current_height: std_logic_vector(17 downto 0) := (others => '0');
    variable current_peak: std_logic_vector(17 downto 0) := (others => '0');
    variable current_len: std_logic_vector(7 downto 0) := (others => '0');
    variable shift: std_logic_vector(4 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      if go = '1' then
        current_height := "00000000" & start;
        current_peak := (others => '0');
        current_len := (others => '0');
      else
        current_height := height_reg;
        current_peak := peak_reg;
        current_len := len_reg;

        if current_height(0) = '1' then
          if current_height(5 downto 0) = "111111" then
            current_height := std_logic_vector(to_unsigned((to_integer(unsigned(current_height * "000000000011110011")) + 211) / 32, 18));
            current_len := current_len + 10;
          elsif current_height(4 downto 0) = "11111" then
            current_height := std_logic_vector(to_unsigned((to_integer(unsigned(current_height * "000000000001010001")) + 65) / 16, 18));
            current_len := current_len + 8;
          elsif current_height(3 downto 0) = "1111" then
            current_height := std_logic_vector(to_unsigned((to_integer(unsigned(current_height * "000000000000011011")) + 19) / 8, 18));
            current_len := current_len + 6;
          elsif current_height(2 downto 0) = "111" then
            current_height := std_logic_vector(to_unsigned((to_integer(unsigned(current_height * "000000000000001001")) + 5) / 4, 18));
            current_len := current_len + 4;
          elsif current_height(1 downto 0) = "11" then
            current_height := std_logic_vector(to_unsigned((to_integer(unsigned(current_height * "000000000000000011")) + 1) / 2, 18));
            current_len := current_len + 2;
          end if;

          current_height := (current_height(16 downto 0) & '1') + current_height;

          if current_peak < current_height then
            current_peak := current_height;
          end if;

          current_len := current_len + 1;
        end if;

        for i in 17 downto 0 loop
          if current_height(i) = '1' then
            shift := std_logic_vector(to_unsigned(i, 5));
          end if;
        end loop;

        for i in 4 downto 0 loop
          if shift(i) = '1' then
            current_height := std_logic_vector(to_unsigned(0, 2 ** i)) & current_height(17 downto 2 ** i);
            current_len := current_len + 2 ** i;
          end if;
        end loop;
      end if;
    end if;

    height_reg <= current_height;
    peak_reg <= current_peak;
    len_reg <= current_len;
  end process;
end Main;
