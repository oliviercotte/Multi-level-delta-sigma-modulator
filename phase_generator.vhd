-- Filename: phase_generator.vhd
-- Author: Olivier Cotte
-- Date: Jan-2017
-- Description:

use work.cordic_types.all; -- Entity that uses CORDIC_TYPES

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity phase_generator is
	port(
		clk, rst_n: in std_logic;
		function_type_sig : in ddfs_function_t;
		phase_out: out std_logic_vector(BIT_WIDTH - 1 downto 0)
	);
end;

architecture rtl of phase_generator is
signal z_inv_trig, z_circ, z_hyp, z_exp, z_sech_2 : std_logic_vector(BIT_WIDTH-1 downto 0);
begin
	------------------------------------------------------------------------------------------------
	-- a_sin_a_cos_phase_gen : 
	------------------------------------------------------------------------------------------------
	a_sin_a_cos_phase_gen : entity work.phase_accumulator(inverse_trigonometric)
	generic map (
		fout => fout,
		fref => fref,
		min => -1.0,
		max => 1.0
	)
	port map (
		clk => clk,
		phase_out => z_inv_trig,
		rst_n => rst_n
	);
	
	------------------------------------------------------------------------------------------------
	-- cosh_sinh_phase_gen : 
	------------------------------------------------------------------------------------------------
	cosh_sinh_phase_gen : entity work.phase_accumulator(hyperbolic)
	generic map (
		fout => fout,
		fref => fref,
		min => -6.0,
		max => 6.0
	)
	port map (
		clk => clk,
		phase_out => z_hyp,
		rst_n => rst_n
	);
	
	------------------------------------------------------------------------------------------------
	-- exp_phase_gen : 
	------------------------------------------------------------------------------------------------
	exp_phase_gen : entity work.phase_accumulator(hyperbolic)
	generic map (
		fout => fout,
		fref => fref,
		min => 0.00,
		max => LOG(2.0**Hyperbolic_Coordinate_IWL)
	)
	port map (
		clk => clk,
		phase_out => z_exp,
		rst_n => rst_n
	);
	
	------------------------------------------------------------------------------------------------
	-- sech_2_phase_gen : 
	------------------------------------------------------------------------------------------------
	sech_2_phase_gen : entity work.phase_accumulator(hyperbolic)
	generic map (
		fout => fout,
		fref => fref,
		min => -5.00,
		max => 5.00
	)
	port map (
		clk => clk,
		phase_out => z_sech_2,
		rst_n => rst_n
	);
	
	------------------------------------------------------------------------------------------------
	-- sin_cos_phase_gen : 
	------------------------------------------------------------------------------------------------
	sin_cos_phase_gen : entity work.phase_accumulator(circular)
	generic map (
		fout => fout,
		fref => fref
	)
	port map (
		clk => clk,
		phase_out => z_circ,
		rst_n => rst_n
	);
	
	------------------------------------------------------------------------------------------------
	-- mux_phase_gen : 
	------------------------------------------------------------------------------------------------
	mux_phase_gen : process(function_type_sig, z_circ, z_hyp, z_inv_trig) is
	begin
		case function_type_sig is
			when COSINE | SINE => phase_out <= z_circ;
			when ARCCOSINE | ARCSINE => phase_out <= z_inv_trig;
			when EXPONENTIAL =>	phase_out <= z_exp;
			when COSINE_H | SINE_H => phase_out <= z_hyp;
			when SEC_H | GEN_SOLITON_SHAPE => phase_out <= z_sech_2;
			when others =>
		end case;
	end process mux_phase_gen;
end	rtl;