-- Filename: phase_accumulator.vhd
-- Author: Olivier Cotte
-- Date: Jan-2017
-- Description:

use work.cordic_types.all; -- Entity that uses CORDIC_TYPES

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;

entity phase_accumulator is
	generic (
		fout : real := 10.0;
		fref : real := 200.0;
		min : real := 0.0;
		max : real := 2.0 * MATH_PI;
		offset : real := 0.0
	);
	port(
		clk, rst_n: in std_logic;
		phase_out: out std_logic_vector(BIT_WIDTH - 1 downto 0));
end;

architecture inverse_trigonometric of phase_accumulator is
constant phase_step_real : real := (max - min) * (fout / fref);
constant INIT_MIN : Range_Of_Convergence_t := to_sfixed(min, Range_Of_Convergence_t'left, Range_Of_Convergence_t'right);
constant INIT_PHASE : Range_Of_Convergence_t := to_sfixed(min + offset, Range_Of_Convergence_t'left, Range_Of_Convergence_t'right);
constant PHASE_STEP : Range_Of_Convergence_t := to_sfixed(phase_step_real, Range_Of_Convergence_t'left, Range_Of_Convergence_t'right);
signal phase_ff : Range_Of_Convergence_t := INIT_PHASE;
begin
	accumulator : process(clk) is
	variable v_accum : Range_Of_Convergence_t;
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				phase_ff <= INIT_PHASE;
			else
				v_accum := resize(phase_ff + PHASE_STEP, v_accum);
				if v_accum < max then
					phase_ff <= v_accum;
				else
					phase_ff <= INIT_MIN;
				end if;
			end if;		
		end if;
	end process accumulator;
	phase_out <= to_slv(phase_ff);
end inverse_trigonometric;

architecture hyperbolic of phase_accumulator is
constant phase_step_real : real := (max - min) * (fout / fref);
constant INIT_MIN : Hyperbolic_Angle_t := to_sfixed(min, Hyperbolic_Angle_t'left, Hyperbolic_Angle_t'right);
constant INIT_PHASE : Hyperbolic_Angle_t := to_sfixed(min + offset, Hyperbolic_Angle_t'left, Hyperbolic_Angle_t'right);
constant PHASE_STEP : Hyperbolic_Angle_t := to_sfixed(phase_step_real, Hyperbolic_Angle_t'left, Hyperbolic_Angle_t'right);
signal phase_ff : Hyperbolic_Angle_t := INIT_PHASE;
begin
	accumulator : process(clk) is
	variable v_accum : Hyperbolic_Angle_t;
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				phase_ff <= INIT_PHASE;
			else
				v_accum := resize(phase_ff + PHASE_STEP, v_accum);
				if v_accum < max then
					phase_ff <= v_accum;
				else
					phase_ff <= INIT_MIN;
				end if;
			end if;		
		end if;
	end process accumulator;
	phase_out <= to_slv(phase_ff);
end hyperbolic;

architecture circular of phase_accumulator is
constant phase_step_real : real := (max - min) * (fout / fref);
constant INIT_MIN : Circular_Angle_t := to_ufixed(min, Circular_Angle_t'left, Circular_Angle_t'right);
constant INIT_PHASE : Circular_Angle_t := to_ufixed(min + offset, Circular_Angle_t'left, Circular_Angle_t'right);
constant PHASE_STEP : Circular_Angle_t := to_ufixed(phase_step_real, Circular_Angle_t'left, Circular_Angle_t'right);
signal phase_ff : Circular_Angle_t := INIT_PHASE;
begin
	accumulator : process(clk) is
	variable v_accum : Circular_Angle_t;
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				phase_ff <= INIT_PHASE;
			else
				v_accum := resize(phase_ff + PHASE_STEP, v_accum);
				if v_accum < max then
					phase_ff <= v_accum;
				else
					phase_ff <= INIT_MIN;
				end if;
			end if;		
		end if;
	end process accumulator;
	phase_out <= to_slv(phase_ff);
end circular;