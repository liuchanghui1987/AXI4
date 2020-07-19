--
--  File Name:         TbAxi4_BasicReadWrite.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2020 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--  

architecture BasicReadWrite of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_BasicReadWrite") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_BasicReadWrite.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_BasicReadWrite.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_BasicReadWrite.txt", "") ; 
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- AxiSuperProc
  --   Generate transactions for AxiSuper
  ------------------------------------------------------------
  AxiSuperProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    NoOp(AxiSuperTransRec, 2) ; 
    log("Write and Read with ByteAddr = 0, 4 Bytes") ;
    Write(AxiSuperTransRec, X"AAAA_AAA0", X"5555_5555" ) ;
    Read(AxiSuperTransRec,  X"1111_1110", Data) ;
    AffirmIfEqual(Data, X"2222_2222", "Super Read Data: ") ;
    
    log("Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    Write(AxiSuperTransRec, X"AAAA_AAA0", X"11" ) ;
    Write(AxiSuperTransRec, X"AAAA_AAA1", X"22" ) ;
    Write(AxiSuperTransRec, X"AAAA_AAA2", X"33" ) ;
    Write(AxiSuperTransRec, X"AAAA_AAA3", X"44" ) ;
    
    Read(AxiSuperTransRec,  X"1111_1110", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"AA", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1111", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"BB", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1112", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"CC", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1113", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"DD", "Super Read Data: ") ;

    log("Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    Write(AxiSuperTransRec, X"BBBB_BBB0", X"2211" ) ;
    Write(AxiSuperTransRec, X"BBBB_BBB1", X"33_22" ) ;
    Write(AxiSuperTransRec, X"BBBB_BBB2", X"4433" ) ;

    Read(AxiSuperTransRec,  X"1111_1110", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"BBAA", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1111", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"CCBB", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1112", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"DDCC", "Super Read Data: ") ;

    log("Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    Write(AxiSuperTransRec, X"CCCC_CCC0", X"33_2211" ) ;
    Write(AxiSuperTransRec, X"CCCC_CCC1", X"4433_22" ) ;

    Read(AxiSuperTransRec,  X"1111_1110", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"CC_BBAA", "Super Read Data: ") ;
    Read(AxiSuperTransRec,  X"1111_1111", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"DDCC_BB", "Super Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiSuperTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSuperProc ;


  ------------------------------------------------------------
  -- AxiMinionProc
  --   Generate transactions for AxiMinion
  ------------------------------------------------------------
  AxiMinionProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    NoOp(AxiMinionTransRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Minion Write Data: ") ;
    
    SendRead(AxiMinionTransRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Minion Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(AxiSuperTransRec, X"AAAA_AAA0", X"11" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0000_0011", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA1", X"22" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA1", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0000_2200", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA2", X"33" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA2", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0033_0000", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA3", X"44" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA3", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"4400_0000", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(Addr, X"1111_1113", "Minion Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(AxiSuperTransRec, X"BBBB_BBB0", X"2211" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"BBBB_BBB0", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0000_2211", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"BBBB_BBB1", X"3322" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"BBBB_BBB1", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0033_2200", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"BBBB_BBB2", X"4433" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"BBBB_BBB2", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"4433_0000", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Minion Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(AxiSuperTransRec, X"CCCC_CCC0", X"332211" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"CCCC_CCC0", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"0033_2211", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"CCCC_CCC1", X"443322" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"CCCC_CCC1", "Minion Write Addr: ") ;
    AffirmIfEqual(Data, X"4433_2200", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Minion Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiMinionTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMinionProc ;


end BasicReadWrite ;

Configuration TbAxi4_BasicReadWrite of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicReadWrite) ; 
    end for ; 
  end for ; 
end TbAxi4_BasicReadWrite ; 