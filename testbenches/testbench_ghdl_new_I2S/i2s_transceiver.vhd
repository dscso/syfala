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
--  Inspired  from DigiKey eewiki,
--  https://www.digikey.com/eewiki/pages/viewpage.action?pageId=10125324
--  added hand shake to buffer input/output sample (ap_hs vivado protocol)
--  added d_width generic for various d_width
--  added a patch for 768kHz (TODO YET HERE°
-------------------------------------------------------------------------


------------How to calculate/change clocks:
--
--    mclk_sclk_ratio = number of mclk periods per sclk period (is always 4)
--    sclk_ws_ratio = number of sclk periods per word select period
--        (depends on bitdepth)
--    d_width  = (real) sample bit depht: 16, 24 or 32
--
--    for d_width = 16, sclk_ws_ratio is 32
--    but for d_width = 24 AND 32, sclk_ws_ratio is 64
--
--     we use  "round_d_width" which is 32 when d_width is 24 or 32 
--     sys_clk = system clock= 120MHz, do not really matter 
--     mclk = sclk*mclk_sclk_ratio 
--     mclk_sclk_ratio=4   SHOULD NOT BE CHANGED
--     
--     sclk is the bit clock (should be call bclk or bitclock)
--     we want sclk = Fs*round_d_width*2
--     hence we set mclk = Fs*round_d_width*2*mclk_sclk_ratio
--     so mclk changes with Fs AND d_width
--     and sclk_ws_ratio changes with  d_width:
--     sclk_ws_ratio = round_d_width*2 
--
--     As a summary:
--      sys_clock should be approximately 120Mhz
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
    reset_n   : in  std_logic;          -- asynchronous active low reset
    start     : in  std_logic;          -- unused: always 1
    sclk      : out std_logic;          -- serial clock (or bit clock)
                                        -- Fs*d_width (3.072 Mhz  for 48kHz and
                                        -- 24 bits)
    ws        : out std_logic;          -- word select (or left-right clock)
    sd_tx     : out std_logic;          -- serial data transmit
    sd_rx     : in  std_logic;          -- serial data receive
    rdy       : out  std_logic;         -- rdy triggers Faust IP 'ap_start'
    ap_done             : in  std_logic;  -- faust computation finished (unused
                                          -- now)
    out_left_V_ap_vld   : in  std_logic;  -- left data from Faust ready  
    out_right_V_ap_vld  : in  std_logic;  -- right data from Faust ready
                                          -- data: tx is IN,  rx is OUT 
    l_data_tx : in  std_logic_vector(d_width-1 downto 0);  -- left channel data to
                                                           -- transmit bit by bit
    r_data_tx : in  std_logic_vector(d_width-1 downto 0);  -- right channel data to
                                                           -- transmit bit by bit
    l_data_rx : out std_logic_vector(d_width-1 downto 0);  -- left channel data
                                                           -- received bit by bit
    r_data_rx : out std_logic_vector(d_width-1 downto 0)); -- right channel data
                                                           -- received bit by bit
end i2s_transceiver;

architecture logic of i2s_transceiver is

  signal sclk_int      : std_logic := '0';     --internal serial clock signal
  signal ws_int        : std_logic := '0';     --internal word select signal
  signal ws_int_tx: std_logic := '0';     -- word select shifted by 1 sclk
                                               -- cycle
  signal ws_int_rx: std_logic := '0';    -- doc todo
  signal out_left_V_ap_vld_reg   : std_logic;  -- left data from Faust ready latched  
  signal out_right_V_ap_vld_reg  : std_logic;  -- right data from Faust ready latched   
  signal l_data_rx_int : std_logic_vector(d_width-1 downto 0);--internal left channel rx data buffer
  signal r_data_rx_int : std_logic_vector(d_width-1 downto 0);--internal right channel rx data buffer
  signal l_data_tx_int : std_logic_vector(d_width-1 downto 0);--internal left channel tx data buffer
  signal r_data_tx_int : std_logic_vector(d_width-1 downto 0);--internal right channel tx data buffer
  signal l_data_tx_latched : std_logic_vector(d_width-1 downto 0);-- latching faust left
                                                                  -- input (assynchronous arrival)
  signal r_data_tx_latched : std_logic_vector(d_width-1 downto 0);-- latching faust right input 
                                                                  --  (assynchronous arrival)
  signal rdy1 : std_logic:= '0';	-- shall trigger ap_start
  signal rdy1_reg : std_logic:= '0';	-- used to detect rising edge of rdy1

begin

  -- process clokcke on sys_clok: detecting Faust output arrival
  -- and start of next Faust computation
  -- set l_data_tx_latched and r_data_tx_latched signals
  -- also set the rdy (ap_start) signal
  process(sys_clk, reset_n)
  begin
    if(reset_n = '0') then              --asynchronous reset
  	l_data_tx_latched  <= (others => '0');
  	r_data_tx_latched  <= (others => '0');
  	out_left_V_ap_vld_reg <= '0';
  	out_right_V_ap_vld_reg <= '0';
  	rdy1_reg <= '0';
        rdy      <= '0';
    elsif(sys_clk'event and sys_clk = '1')  then
      --system clock rising edge
      
      -- latch left input from faust (at any sys_clk cycle) 
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

      -- rdy (i.e. ap_start) detect rising edge of rdy1 (clocked on sys_clk)
      rdy1_reg <= rdy1;
      if (rdy1 = '1') and (rdy1_reg /= rdy1) then
        rdy <= '1';
      else
        rdy <= '0';
      end if;
    end if;   
  end process;
  
  -- process clock on mclk
  -- 1) building clock: sclk, ws from mclk 
  -- 2) setting all other signal
  -- 3) implement a patch to delay sd_rx read
  -- See Syfala documentation for precise explanation
  process(mclk, reset_n)
    variable sclk_cnt : integer := 0;  -- used for clock divider frequencies:
                                       -- mclk/sclk=mclk_sclk_ratio (4)
                                       -- takes only 2 values (0 and 1)
    variable ws_cnt   : integer := 0;  -- count each sclk event in half a
                                       -- ws period: 0  to sclk_ws_ratio (63)
                                       -- that 0-63 when ws=0 and 0-63 when ws=1
    variable bit_cnt: integer := 0;    -- counts the bit to be transmitted
    variable   read_sd_rx_at_next_mclk_sample: integer := 0; -- used for patch:
                                                             -- read sd_rx one mclk sample later
    variable reset_bit_cnt_next_sclk_cycle: integer :=0;
  begin

    if(reset_n = '0') then              --asynchronous reset
      sclk_cnt      := 0;               
      ws_cnt        := 0;               
      bit_cnt        := 0;      
      reset_bit_cnt_next_sclk_cycle:= 0;
      read_sd_rx_at_next_mclk_sample := 0;
      l_data_rx_int <= (others => '0');  
      r_data_rx_int <= (others => '0');  
      l_data_tx_int <= (others => '0');  
      r_data_tx_int <= (others => '0');  
      sd_tx         <= '0';             
      l_data_rx     <= (others => '0'); 
      r_data_rx     <= (others => '0'); 
      rdy1 <= '0';
    elsif (mclk'event and mclk = '1')  and start = '1' then
      -- mclk rising edge 
      if(sclk_cnt < mclk_sclk_ratio/2-1) then
        -- do nothing
        sclk_cnt := sclk_cnt + 1;    -- set sclk_cnt to 1
        ------------------- PATCH -----------------------
        -- with patch:
        if (read_sd_rx_at_next_mclk_sample = 1) then 
          if(ws_int_rx = '1')  then
            r_data_rx_int <= r_data_rx_int(d_width-2 downto 0) & sd_rx;
          else
            l_data_rx_int <= l_data_rx_int(d_width-2 downto 0) & sd_rx;
          end if;
          read_sd_rx_at_next_mclk_sample := 0;
        end if;
        ------------------- END PATCH -----------------------
         else
        -- sclk edge (rising or falling)
        sclk_cnt := 0;                  --reset sclk_cnt counter
        sclk_int <= not sclk_int;       --toggle serial clock at next round
        
        -- updating bit counter
        if (sclk_int = '1') then
          -- sclk falling edge
          bit_cnt := bit_cnt + 1;
          -- example of assert:
          -- assert false
          --    report "bit_cnt=" & integer'image(bit_cnt)
          --    severity NOTE;
          if (reset_bit_cnt_next_sclk_cycle =1) then
            bit_cnt := 0;
            reset_bit_cnt_next_sclk_cycle:=0;
          end if;
        end if;

        -- building counters and updating
        -- current samples (input and ouput)
        if(ws_cnt < sclk_ws_ratio-1) then
          ws_cnt := ws_cnt + 1;    
        else
          -- changing channel (left or right)
          if (sclk_int = '1') then
            -- sclk falling edge
            -- reset counters
            ws_cnt        := 0;          
            reset_bit_cnt_next_sclk_cycle:=1;
            
            -- latches input samples
            -- and produced output samples
            if (ws_int = '0') then 
              -- ws_int rising edge: right channel
              r_data_rx     <= r_data_rx_int;
              r_data_tx_int <= r_data_tx_latched;    
            else
              -- falling edge of ws_int: ledt channel
              l_data_rx     <= l_data_rx_int;
              l_data_tx_int <= l_data_tx_latched;    
            end if; 
          end if; -- en sdlk falling edge
            
          -- building ws_int
          if (sclk_int = '1') then
            --falling edge
            ws_int        <= not ws_int;  --toggle word select
          end if;
        end if; --end changing channel       
        
        -- building ws_in_tx clock
        if (sclk_int = '0') then
          -- rising edge of sclk
          ws_int_tx <= ws_int;
        end if;     
        if (sclk_int = '1') then
          -- rising edge of sclk
          ws_int_rx <= ws_int;
        end if;     


        -- writing sd_tx  
        if (sclk_int = '1') then
          -- sclk falling edge
          -- sending d_width bits, shifted by 1 sclk cycle with respect to ws
          -- hence bit_cnt counts from 0 to d_width-1
          if(bit_cnt < d_width) then --WRITE ONE BIT
            if(ws_int_tx = '1' ) then      --right channel
              sd_tx <= r_data_tx_int(d_width-1);  -- transmit one right channel  bit 
              --shift data of right channel tx data buffer
              r_data_tx_int <= r_data_tx_int(d_width-2 downto 0) & '0';  
            else                        --left channel
              sd_tx <= l_data_tx_int(d_width-1);  --transmit one left channel bit
              --shift data of left channel tx data buffer
              l_data_tx_int <= l_data_tx_int(d_width-2 downto 0) & '0';  
            end if;
          end if; -- end WRITE ONE BIT
        end if; -- end sclk falling edge

        -- reading sd_rx  
        if (sclk_int = '0') then
          -- sclk rising edge
          -- receiving d_width bits, shifted by 1 sclk cycle with respect to ws
          -- hence bit_cnt counts from 0 to d_width-1
          if(bit_cnt < d_width ) then --READ ONE BIT
            ------------------- PATCH -----------------------
            -- no patch:
            -- if(ws_int = '1') then
            --   r_data_rx_int <= r_data_rx_int(d_width-2 downto 0) & sd_rx;
            -- else
            --   l_data_rx_int <= l_data_rx_int(d_width-2 downto 0) & sd_rx;
            --   end if;
            -- with patch:
            read_sd_rx_at_next_mclk_sample := 1;
            ------------------- END PATCH -----------------------
          end if; --- end READ ONE BIT
        end if; -- end reading sd_rx

        
        -- sending ap_start to faust when ws_cnt = 3 (arbitrary choice)
        if (ws_cnt = 3) and (ws_int = '1') then
          rdy1 <= '1';
        else
          rdy1 <= '0';
        end if;

      end if;  -- mclk rising edge
    end if; -- mclk event
  end process;

  sclk <= sclk_int;                     --output serial clock
  ws   <= ws_int;                       --output word select

end logic;
