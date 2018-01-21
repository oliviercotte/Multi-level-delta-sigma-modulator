library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;

package dsm_pkg is
	constant DSM_NBITS : integer := 10;
	subtype dsm_t is sfixed(DSM_NBITS downto 1+DSM_NBITS-36);
	constant nLev : integer := 512;
end dsm_pkg;