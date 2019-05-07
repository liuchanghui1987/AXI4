--
--  File Name:         AxiStreamComponentPkg.vhd
--  Design Unit Name:  AxiStreamComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi4 Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    05/2018:   2018.05    Initial revision
--
--
-- Copyright 2018 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.AxiStreamTransactionPkg.all ; 
  use work.Axi4CommonPkg.all ; 
    
package AxiStreamComponentPkg is

  component AxiStreamMaster is
    generic (
      DEFAULT_ID     : std_logic_vector ; 
      DEFAULT_DEST   : std_logic_vector ; 
      DEFAULT_USER   : std_logic_vector ; 

      tperiod_Clk     : time := 10 ns ;
      
      tpd_Clk_TValid : time := 2 ns ; 
      tpd_Clk_TID    : time := 2 ns ; 
      tpd_Clk_TDest  : time := 2 ns ; 
      tpd_Clk_TUser  : time := 2 ns ; 
      tpd_Clk_TData  : time := 2 ns ; 
      tpd_Clk_TStrb  : time := 2 ns ; 
      tpd_Clk_TKeep  : time := 2 ns ; 
      tpd_Clk_TLast  : time := 2 ns 
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Master Functional Interface
      TValid    : out std_logic ;
      TReady    : in  std_logic ; 
      TID       : out std_logic_vector ; 
      TDest     : out std_logic_vector ; 
      TUser     : out std_logic_vector ; 
      TData     : out std_logic_vector ; 
      TStrb     : out std_logic_vector ; 
      TKeep     : out std_logic_vector ; 
      TLast     : out std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout AxiStreamTransactionRecType 
    ) ;
  end component AxiStreamMaster ;
  
  component AxiStreamSlave is
    generic (
      tperiod_Clk     : time := 10 ns ;
      
      tpd_Clk_TReady : time := 2 ns  
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Master Functional Interface
      TValid    : in  std_logic ;
      TReady    : out std_logic ; 
      TID       : in  std_logic_vector ; 
      TDest     : in  std_logic_vector ; 
      TUser     : in  std_logic_vector ; 
      TData     : in  std_logic_vector ; 
      TStrb     : in  std_logic_vector ; 
      TKeep     : in  std_logic_vector ; 
      TLast     : in  std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout AxiStreamTransactionRecType 
    ) ;
  end component AxiStreamSlave ;

end package AxiStreamComponentPkg ;