-- Filename: top_level_ddfs.vhd
-- Author: Olivier Cotte
-- Date: Jan-2017
-- Description:	Direct digital frequency synthesizer based on cordic algorithm

use work.cordic_types.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity top_level_ddfs is
	port (
		clk, rst_n : in std_logic;
		ddfs_function_type : in std_logic_vector(3 downto 0);
		ddfs_function_out : out std_logic_vector(BIT_WIDTH-1 downto 0)
	);
end top_level_ddfs;

architecture structural of top_level_ddfs is
-- DDFS STATE --
signal mode_reg : std_logic;
signal coordinate_system_reg : std_logic_vector(2 downto 0);
signal ddfs_function_sig, ddfs_function_reg : ddfs_function_t;
signal cordic_config_sig, cordic_config_reg : cordic_config_t;
signal re_init, valid : std_logic := '0';
signal dbg_mem_out : std_logic_vector(BIT_WIDTH-1 downto 0);
begin
	------------------------------------------------------------------------------------------------
	-- ddfs_ctrl : 
	------------------------------------------------------------------------------------------------
	ddfs_state_machine : entity work.ddfs_ctrl(rtl) 
	port map (
		clk => clk,
		rst_n => rst_n,
		ddfs_function_type => ddfs_function_type,
		mode_reg => mode_reg,
		coordinate_system_reg => coordinate_system_reg,
		ddfs_function_sig => ddfs_function_sig, 
		ddfs_function_reg => ddfs_function_reg,
		cordic_config_sig => cordic_config_sig, 
		cordic_config_reg => cordic_config_reg,
		valid => valid,
		re_init => re_init
	);

	------------------------------------------------------------------------------------------------
	-- trig_fct_gen : 
	------------------------------------------------------------------------------------------------
	trig_fct_gen : entity work.trigonometric_function_generator(rtl)
	port map (
		clk => clk,
		rst_n => rst_n,
		mode_reg => mode_reg,
		coordinate_system_reg => coordinate_system_reg,
		ddfs_function_sig => ddfs_function_sig,
		trig_fct_out => ddfs_function_out
	);
	
end structural;