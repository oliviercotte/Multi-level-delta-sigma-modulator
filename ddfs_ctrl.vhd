-- Filename: ddfs_ctrl.vhd
-- Author: Olivier Cotte
-- Date: Jan-2017
-- Description:	ddfs state machine

use work.cordic_types.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity ddfs_ctrl is
	port (
		clk, rst_n : in std_logic;
		ddfs_function_type : in std_logic_vector(3 downto 0);
		ddfs_function_sig, ddfs_function_reg : out ddfs_function_t;
		cordic_config_sig, cordic_config_reg : out cordic_config_t;
		mode_reg : out std_logic;
		coordinate_system_reg : out std_logic_vector(2 downto 0);
		re_init, valid : inout std_logic
	);
end ddfs_ctrl;

architecture rtl of ddfs_ctrl is
-- DDFS STATE --
signal ddfs_function_i_next, ddfs_function_i_ff : ddfs_function_t;
-- DDFS PULSE SYNCHRONIZATION --
constant CNT_BIT_WIDTH : positive := integer(ceil(log2(real(SEND_SYNC_PULSE_PIPELINED_EXT_SECH_2))))+1;
signal init_cnt, cnt_ff : unsigned(CNT_BIT_WIDTH-1 downto 0);
signal sync, clear_flag: std_logic := '0';
-- CORDIC CONFIGURATION --
signal cordic_config_i_next, cordic_config_i_ff : cordic_config_t;
signal mode_i_next, mode_i_ff : std_logic;
signal coordinate_system_i_next, coordinate_system_i_ff : std_logic_vector(2 downto 0);
begin
	-- update state --
	mode_reg <= mode_i_next;
	coordinate_system_reg <= coordinate_system_i_next;
	cordic_config_sig <= cordic_config_i_next;
	cordic_config_reg <= cordic_config_i_ff;
	ddfs_function_sig <= ddfs_function_i_next;
	ddfs_function_reg <= ddfs_function_i_ff;
	
	------------------------------------------------------------------------------------------------
	-- init_ddfs_pipeline_delay : 
	------------------------------------------------------------------------------------------------
	init_ddfs_pipeline_delay : process(ddfs_function_i_next) is
	begin
		case ddfs_function_i_next is
			when COSINE | SINE | ARCCOSINE | ARCSINE | COSINE_H | SINE_H | EXPONENTIAL => init_cnt <= to_unsigned(SEND_SYNC_PULSE_PIPELINED_NOMINAL, CNT_BIT_WIDTH);
			when SEC_H  => init_cnt <= to_unsigned(SEND_SYNC_PULSE_PIPELINED_EXT_SECH, CNT_BIT_WIDTH);
			when GEN_SOLITON_SHAPE => init_cnt <= to_unsigned(SEND_SYNC_PULSE_PIPELINED_EXT_SECH_2, CNT_BIT_WIDTH);
			when others =>
		end case;
	end process init_ddfs_pipeline_delay;
	
	------------------------------------------------------------------------------------------------
	-- re_init_ddfs : 
	------------------------------------------------------------------------------------------------ 
	re_init_ddfs : process(cordic_config_i_next, cordic_config_i_ff, ddfs_function_i_next, ddfs_function_i_ff) is
	begin
		if cordic_config_i_ff /= cordic_config_i_next then
			re_init <= '1';
		elsif ddfs_function_i_next = GEN_SOLITON_SHAPE and ddfs_function_i_ff = SEC_H then
			re_init <= '1';
		else
			re_init <= '0';
		end if;
	end process re_init_ddfs;
	
	------------------------------------------------------------------------------------------------
	-- sync_pulse : 
	------------------------------------------------------------------------------------------------
	sync_pulse : process(clk)
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				valid <= '0';
				clear_flag <= '0';
				cnt_ff <= init_cnt;
			else
				if re_init = '1' then
					clear_flag <= '0';
					valid <= '0';
					cnt_ff <= init_cnt;
				elsif clear_flag = '0' then
					if cnt_ff > 0 then
						cnt_ff <= cnt_ff - 1;
					else
						clear_flag <= '1';
						valid <= '1';
					end if;
				else
					valid <= '0';	
				end if;
			end if;
		end if;
	end process sync_pulse;
	
	------------------------------------------------------------------------------------------------
	-- next_ddfs_function_state : 
	------------------------------------------------------------------------------------------------
	next_ddfs_function_state : process(ddfs_function_type) is
	begin
		case to_integer(unsigned(ddfs_function_type)) is
			when COSINE | SINE | ARCCOSINE | ARCSINE | COSINE_H | SINE_H | EXPONENTIAL | SEC_H | GEN_SOLITON_SHAPE => ddfs_function_i_next <= to_integer(unsigned(ddfs_function_type));
			when others =>
		end case;
	end process next_ddfs_function_state;
	
	------------------------------------------------------------------------------------------------
	-- next_ddfs_cordic_state : 
	------------------------------------------------------------------------------------------------
	mode_i_next <= '0';
	coordinate_system_i_next <= std_logic_vector(to_unsigned(cordic_config_i_next, coordinate_system_i_next'length));
	next_ddfs_cordic_state : process(ddfs_function_i_next) is
	begin
		case ddfs_function_i_next is
			when COSINE | SINE => cordic_config_i_next <= CFG_CIRCULAR;
			when ARCCOSINE | ARCSINE => cordic_config_i_next <= CFG_INVERSE_TRIGONOMETRIC;
			when COSINE_H | SINE_H | EXPONENTIAL => cordic_config_i_next <= CFG_HYPERBOLIC;
			when SEC_H | GEN_SOLITON_SHAPE => cordic_config_i_next <= CFG_HYPERBOLIC_EXT;
			when others =>
		end case;
	end process next_ddfs_cordic_state;

end	rtl;