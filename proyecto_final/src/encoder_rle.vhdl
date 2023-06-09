library IEEE;
library utils;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use utils.funciones.all;

entity encoder_rle is
    generic ( WIDTH : natural := 64);
   port(
      input_i               : in std_logic_vector (WIDTH-1 downto 0);
      input_signal_ready_i  : in std_logic;
      clk_i                 : in std_logic;
      reset_i               : in std_logic;
      output_o              : out std_logic_vector ((WIDTH*2)-1 downto 0);
      ready_o               : out std_logic;
      size_o                : out integer
   );
end encoder_rle;

architecture encoder_architecture of encoder_rle is
    constant character_size                 : integer := 8;
    signal character_index                  : integer := (WIDTH/8)-1;
    signal consecutive_characters           : integer := 1;
    signal compresion_size                  : natural := 0;
    signal characters_to_compress           : std_logic_vector (WIDTH-1 downto 0) :=  (others => '0');
    signal where_to_write_in_result         : integer := (WIDTH*2);
    signal compresion_result       : std_logic_vector((WIDTH*2)-1 downto 0) := (others => '0');


begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset_i = '1' then
                character_index <= (WIDTH/character_size)-1;
                compresion_size <= 0;
                consecutive_characters <= 1;
                where_to_write_in_result <= (WIDTH*2);
                compresion_result <= (others => '0');
                characters_to_compress <= (others => '0');
            else
                if input_signal_ready_i = '1' then
                    characters_to_compress <= input_i;
                else
                    if(character_index > 0) then
                        if(get_character_from_array(characters_to_compress, character_index, character_size) = 
                            get_character_from_array(characters_to_compress, character_index -1, character_size)) then
                                consecutive_characters <= consecutive_characters + 1;
                                compresion_result <= compresion_result;    
                        else
                                compresion_result(where_to_write_in_result-1 downto where_to_write_in_result - character_size) <= std_logic_vector(to_unsigned(consecutive_characters, character_size));
                                compresion_result(where_to_write_in_result-1-character_size downto where_to_write_in_result - character_size*2) <= get_character_from_array(characters_to_compress, character_index, character_size);
                                where_to_write_in_result <= where_to_write_in_result - character_size*2;
                                consecutive_characters <= 1;
                                compresion_size <= compresion_size + 2;

                        end if;
                        ready_o <= '0';
                        character_index <= character_index - 1;
                    elsif character_index = 0 then
                        compresion_result(where_to_write_in_result-1 downto where_to_write_in_result - character_size) <= std_logic_vector(to_unsigned(consecutive_characters, character_size));
                        compresion_result(where_to_write_in_result-1-character_size downto where_to_write_in_result - character_size-character_size) <= get_character_from_array(characters_to_compress, character_index, character_size);
                        compresion_size <= compresion_size + 2;
                        character_index <= character_index - 1;
                    else
                    ready_o <= '1';
                    end if;
                    output_o <= compresion_result;
                    size_o <= compresion_size;
                end if;
            end if;
        end if;
    end process;
end architecture;