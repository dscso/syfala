--------------------------------------------------------------------------------
--
--   FileName:         i2s_transceiver.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 03/29/2019 Scott Larson
--     Initial Public Release
-- 
--------------------------------------------------------------------------------
-------------------------------------------------------------------- 
--- Version 2.0 01/02/2022: Adeyemi Gbadamosi, Tanguy Risset, Maxime Popoff
--  version extended from DigiKey eewiki,
--  https://www.digikey.com/eewiki/pages/viewpage.action?pageId=10125324
--  added hand shake to buffer input/output sample (ap_hs vivado protocol)
--  added d_width generic fot various d_width
--  added a patch for 768kHz
-------------------------------------------------------------------------


------------How to calculate/change clocks:
--
--    mclk_sclk_ratio = number of mclk periods per sclk period 
--    sclk_ws_ratio = number of sclk periods per word select period
--    d_width  = sample data width
--
--    for d_width = 16, sclk_ws_ratio is 32
--    but for d_width = 24 AND 32, sclk_ws_ratio is 64
--
--     we use  "round_d_width" which is 32 when d_width is 24 or 32 
--     sys_clk = system clock= 120MHz, MUST NOT BE CHANGED
--     mclk = sclk*mclk_sclk_ratio 
--     mclk_sclk_ratio=4   SHOULD NOT BE CHANGED
--     
--     sclk is the bit clock (should be call bclk or bitclock)
--     sclk changes with Fs and d_width
--     we want sclk = Fs*round_d_width*2
--     hence we set mclk = Fs*round_d_width*2*mclk_sclk_ratio
--     So mclk change with Fs AND d_width
--
--     sclk_ws_ratio changes with  d_width:
--     sclk_ws_ratio = round_d_width*2 
--
--     As a summary:
--      sys_clock should be 120Mhz
--      if you change Fs, you have to change mclk
--      If you change d_width, you have to change mclk and sclk_ws_ratio
--------------------


library ieee;
use ieee.std_logic_1164.all;

entity i2s_transceiver is
  generic(
 -- AUTO GENERATED WITH vhdl_value_set.py file, DO NOT CHANGE ANYTHING HERE
 -------------------------------------------------------------------------
	mclk_sclk_ratio : integer := 4; 
        sclk_ws_ratio   : integer := 64; 
	d_width         : integer := 24); 
 --------------------------------------------------------------------------
 -- END OF AUTO GENERATED
  port(
    sys_clk   : in  std_logic;          -- sys_clk (FPGA) 120 MHz
    mclk      : in  std_logic;          -- mclk== 4*d_width*fs (12.288  MHZ
                                        --  for F48kHz and 24 bits)
    reset_n   : in  std_logic;          --asynchronous active low reset
    start     : in  std_logic;
    sclk      : out std_logic;          --serial clock (or bit clock)
                                        --Fs*d_width (3.072 Mhz  for 48kHz and
                                        -- 24 bits)
    ws        : out std_logic;          --word select (or left-right clock)
    sd_tx     : out std_logic;          --serial data transmit
    sd_rx     : in  std_logic;          --serial data receive
    rdy       : out  std_logic;          
    ap_done             : in  std_logic;  -- faust computation finished    
    out_left_V_ap_vld   : in  std_logic;  -- left data from Faust ready  
    out_right_V_ap_vld  : in  std_logic;  -- right data from Faust ready
                                                           -- data: tx is IN,  rx is OUT 
    l_data_tx : in  std_logic_vector(d_width-1 downto 0);  -- left channel data to transmit
    r_data_tx : in  std_logic_vector(d_width-1 downto 0);  -- right channel data to transmit
    l_data_rx : out std_logic_vector(d_width-1 downto 0);  -- left channel data received
    r_data_rx : out std_logic_vector(d_width-1 downto 0)); -- right channel data received
end i2s_transceiver;

architecture logic of i2s_transceiver is


  signal sclk_int      : std_logic := '0';              --internal serial clock signal
  signal ws_int        : std_logic := '0';              --internal word select signal
  signal ap_done_reg        : std_logic := '0';         --ap_done at previous cycle
  signal  out_left_V_ap_vld_reg   : std_logic;          --left data from Faust ready  
  signal  out_right_V_ap_vld_reg  : std_logic;          --right data from Faust ready   
  signal faust_finished        : std_logic := '0';      --should be removed 
  signal faust_finished_latched_mclk    : std_logic := '0';     --should be removed 
  signal l_data_rx_int : std_logic_vector(d_width-1 downto 0);  --internal left channel rx data buffer
  signal r_data_rx_int : std_logic_vector(d_width-1 downto 0);  --internal right channel rx data buffer
  signal l_data_tx_int : std_logic_vector(d_width-1 downto 0);  --internal left channel tx data buffer
  signal r_data_tx_int : std_logic_vector(d_width-1 downto 0);  --internal right channel tx data buffer
  signal l_data_tx_latched : std_logic_vector(d_width-1 downto 0);  -- latching faust left input
  signal r_data_tx_latched : std_logic_vector(d_width-1 downto 0);  -- latching faust right input 
  signal rdy1 : std_logic:= '0';  			-- shall trigger ap_start
  signal rdy1_reg : std_logic:= '0';  			-- used to detect rising edge of rdy1

begin
  process(sys_clk, reset_n)
  begin
    if(reset_n = '0') then              --asynchronous reset
  	l_data_tx_latched  <= (others => '0');
  	r_data_tx_latched  <= (others => '0');
  	ap_done_reg <= '0';
  	out_left_V_ap_vld_reg <= '0';
  	out_right_V_ap_vld_reg <= '0';
  	rdy1_reg <= '0';
        rdy           <= '0';
    elsif(sys_clk'event and sys_clk = '1')  then	--system clock rising
      -- detect ap_done rising edge. At the moment we do not use it
      ap_done_reg <= ap_done;
      -- latch left input from faust(at any sys_clk cycle) 
      out_left_V_ap_vld_reg <= out_left_V_ap_vld;
      if (out_left_V_ap_vld = '1') and
        (out_left_V_ap_vld_reg /= out_left_V_ap_vld) then
        l_data_tx_latched <= l_data_tx;
      end if;
      -- latch left input from faust (at any sys_clk cycle) 
      out_right_V_ap_vld_reg <= out_right_V_ap_vld;
      if (out_right_V_ap_vld = '1') and
        (out_right_V_ap_vld_reg /= out_right_V_ap_vld) then
        r_data_tx_latched <= r_data_tx;
      end if;

      -- rdy detect rising edge of rdy1 (clocked on sys_clk)
      rdy1_reg <= rdy1;
      if (rdy1 = '1') and (rdy1_reg /= rdy1) then
        rdy <= '1';
        assert false
          report "setting ap_start to 1"
          severity NOTE;
      else
        rdy <= '0';
      end if;
    end if;   
  end process;
  
  process(mclk, reset_n)
    variable sclk_cnt : integer := 0;  --counter of master clocks during half period of serial clock
    variable ws_cnt   : integer := 0;  --counter of serial clock toggles during half period of word select
    variable bit_cnt   : integer := 0; --counter of the number of bit to be sent/read
    variable word_channel   : std_logic := '0'; --save the current channel for the word
    variable correction_cnt : integer := 0; 
  begin

    if(reset_n = '0') then              --asynchronous reset
      correction_cnt      := 0;         
      sclk_cnt      := 0;               --clear mclk/sclk counter
      ws_cnt        := 0;               --clear sclk/ws counter
      bit_cnt       := 0;               --clear bit counter
      l_data_rx_int <= (others => '0');  --clear internal left channel rx data buffer
      r_data_rx_int <= (others => '0');  --clear internal right channel rx data buffer
      l_data_tx_int <= (others => '0');  --clear internal left channel tx data buffer
      r_data_tx_int <= (others => '0');  --clear internal right channel tx data buffer
      sd_tx         <= '0';             --clear serial data transmit output
      l_data_rx     <= (others => '0');  --clear left channel received data output
      r_data_rx     <= (others => '0');  --clear right channel received data output
      rdy1 <= '0';
    elsif(mclk'event and mclk = '1') and start = '1' then
            --master clock rising edge 12.28MHz (at 48kHz and 24 bits)
            --PATCH: at 768kHz, we read the value too early (the bit is  little too late)
	    -- so we patch by reading the bit one mclk rising edge after rising edge of sclk
	    --- (which is why the reading is out of the normal if statement)
         correction_cnt := correction_cnt + 1;      
         --READ
        if(correction_cnt = 1 and bit_cnt<d_width ) then  --count 1 mclk rising edge after each rising edge of sclk during data word
          if(word_channel = '1') then       --right channel
            r_data_rx_int <= r_data_rx_int(d_width-2 downto 0) & sd_rx;  --shift data bit into right channel rx data buffer
          else                        --left channel
            l_data_rx_int <= l_data_rx_int(d_width-2 downto 0) & sd_rx;  --shift data bit into left channel rx data buffer
          end if;
        end if;
      --END OF PATCH         
            
      if(sclk_cnt < mclk_sclk_ratio/2-1) then  --less than half period of sclk (mclk_sclk_ratio=4)
                                               --ok: change every 2 periode of mclk (count until 4/2-1=1) so full periode in 4 periode of mclk
        sclk_cnt := sclk_cnt + 1;       --increment mclk/sclk counter
      else                              --half period of sclk. Sur changement de front de sclk (bclk)
        sclk_cnt := 0;                  --reset mclk/sclk counter
        sclk_int <= not sclk_int;       --toggle serial clock
        
        if(sclk_int = '1') then --falling edge of sclk
          if (ws_cnt > 1) then
            bit_cnt := bit_cnt + 1;
          else
            bit_cnt:=0;	--Start bit counter one sclk clock after ws change
            word_channel:= ws_int; -- Save the value of ws for the word to come  
          end if;
        end if; 
        -- regular i2s process CORRECTED
        --READ
        if(sclk_int = '0' ) then  --rising edge of sclk during data word
        	correction_cnt      := 0;   --put the counter to 0
        end if;
		--WRITE
        if(sclk_int = '1' and bit_cnt<d_width ) then --falling edge of sclk during data word
          if(word_channel = '1' ) then      --right channel
            sd_tx         <= r_data_tx_int(d_width-1);  --transmit serial data bit
            r_data_tx_int <= r_data_tx_int(d_width-2 downto 0) & '0';  --shift data of right channel tx data buffer
          else                        --left channel
            sd_tx        <= l_data_tx_int(d_width-1);  --transmit serial data bit
            l_data_tx_int <= l_data_tx_int(d_width-2 downto 0) & '0';  --shift data of left channel tx data buffer
          end if;
        end if; 
        if(ws_cnt < sclk_ws_ratio-1) then  --less than half period of ws. Etat haut ou bas de WS (sclk_ws_ratio=64)
          ws_cnt := ws_cnt + 1;         --increment sclk/ws counter
          -- "beguinning" of faust computation x ws is '1' 
          if (ws_cnt = 3) and (ws_int = '1') then
            rdy1 <= '1';
          else
            rdy1 <= '0';
          end if;
        else                            --half period of ws: ws_cnt = sclk_ws_ratio-1. Changement d'etat de WS
          ws_cnt        := 0;           --reset sclk/ws counter
          ws_int        <= not ws_int;  --toggle word select
          if (ws_int = '0') then
            r_data_rx     <= r_data_rx_int;  --output right channel received data
            r_data_tx_int <= r_data_tx_latched;    --latch in right channel data to transmit
          else
            l_data_rx     <= l_data_rx_int;  --output left channel received data
            l_data_tx_int <= l_data_tx_latched;    --latch left channel data to transmit
          end if;   
        end if; 
      end if;
    end if;
  end process;

  sclk <= sclk_int;                     --output serial clock
  ws   <= ws_int;                       --output word select

end logic;
