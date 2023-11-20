/******************************************************************************
 * @file ADAU1777Reg.cpp
 * Autogenerated with sigmaS_to_syfala_generator.tcl.
 * Registers configuration for ADAU1777
 * Based on X_IC_1_REG.h file, generated with Sigma Studio
 * This file doesn't need to be regenerated each time. Only the header file configures the registers.
 *
 * @authors M.POPOFF
 * @date: 03/01/2023 15:34:37
 *
 *****************************************************************************/

#include <syfala/arm/codecs/ADAU17xx.hpp>
#include <syfala/arm/codecs/ADAU1777Reg.h>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>

#define CTARGET "[ADAU1777]"

#define REGWRITE(_A, _D, _O)                                                        \
if (ADAU17xx::regwrite(bus, codec_addr, _A, _D, _O) != XST_SUCCESS) {               \
    Syfala::Status::warning(RN(CTARGET " Could not write to register " #_A));       \
    return XST_FAILURE;                                                             \
}

constexpr int get_reg_sai_0_value() {
    int reg_sai_0_value = 0;
    switch (SYFALA_SAMPLE_RATE) {
        case 8000:   reg_sai_0_value |= 0b0001; break;
        case 12000:  reg_sai_0_value |= 0b0010; break;
        case 16000:  reg_sai_0_value |= 0b0011; break;
        case 24000:  reg_sai_0_value |= 0b0100; break;
        case 32000:  reg_sai_0_value |= 0b0101; break;
        case 48000:  reg_sai_0_value |= 0b0000; break;
        case 96000:  reg_sai_0_value |= 0b0110; break;
        case 192000: reg_sai_0_value |= 0b0111; break;
        default:     reg_sai_0_value |= 0b0000;

    }
    return reg_sai_0_value;
}

static constexpr int reg_sai_0_value = get_reg_sai_0_value();

namespace ADAU1777 {
int initialize(int bus, unsigned long codec_addr) {
	REGWRITE(REG_CLK_CONTROL_IC_1_ADDR, REG_CLK_CONTROL_IC_1_VALUE, 0)
	REGWRITE(REG_PLL_CTRL0_IC_1_ADDR, REG_PLL_CTRL0_IC_1_VALUE, 0)
	REGWRITE(REG_PLL_CTRL1_IC_1_ADDR, REG_PLL_CTRL1_IC_1_VALUE, 0)
	REGWRITE(REG_PLL_CTRL2_IC_1_ADDR, REG_PLL_CTRL2_IC_1_VALUE, 0)
	REGWRITE(REG_PLL_CTRL3_IC_1_ADDR, REG_PLL_CTRL3_IC_1_VALUE, 0)
	REGWRITE(REG_PLL_CTRL4_IC_1_ADDR, REG_PLL_CTRL4_IC_1_VALUE, 0)
	REGWRITE(REG_CLKOUT_SEL_IC_1_ADDR, REG_CLKOUT_SEL_IC_1_VALUE, 0)
	REGWRITE(REG_REGULATOR_IC_1_ADDR, REG_REGULATOR_IC_1_VALUE, 0)
	REGWRITE(REG_CORE_CONTROL_IC_1_ADDR, REG_CORE_CONTROL_IC_1_VALUE, 0)
	REGWRITE(REG_SLEEP_INST_IC_1_ADDR, REG_SLEEP_INST_IC_1_VALUE, 0)
	REGWRITE(REG_CORE_ENABLE_IC_1_ADDR, REG_CORE_ENABLE_IC_1_VALUE, 0)
	REGWRITE(REG_CORE_IN_MUX_0_1_IC_1_ADDR, REG_CORE_IN_MUX_0_1_IC_1_VALUE, 0)
	REGWRITE(REG_CORE_IN_MUX_2_3_IC_1_ADDR, REG_CORE_IN_MUX_2_3_IC_1_VALUE, 0)
	REGWRITE(REG_DAC_SOURCE_0_1_IC_1_ADDR, REG_DAC_SOURCE_0_1_IC_1_VALUE, 0)
	REGWRITE(REG_PDM_SOURCE_0_1_IC_1_ADDR, REG_PDM_SOURCE_0_1_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_SOURCE_0_1_IC_1_ADDR, REG_SOUT_SOURCE_0_1_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_SOURCE_2_3_IC_1_ADDR, REG_SOUT_SOURCE_2_3_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_SOURCE_4_5_IC_1_ADDR, REG_SOUT_SOURCE_4_5_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_SOURCE_6_7_IC_1_ADDR, REG_SOUT_SOURCE_6_7_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_SDATA_CH_IC_1_ADDR, REG_ADC_SDATA_CH_IC_1_VALUE, 0)
	REGWRITE(REG_ASRCO_SOURCE_0_1_IC_1_ADDR, REG_ASRCO_SOURCE_0_1_IC_1_VALUE, 0)
	REGWRITE(REG_ASRCO_SOURCE_2_3_IC_1_ADDR, REG_ASRCO_SOURCE_2_3_IC_1_VALUE, 0)
	REGWRITE(REG_ASRC_MODE_IC_1_ADDR, REG_ASRC_MODE_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_CONTROL0_IC_1_ADDR, REG_ADC_CONTROL0_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_CONTROL1_IC_1_ADDR, REG_ADC_CONTROL1_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_CONTROL2_IC_1_ADDR, REG_ADC_CONTROL2_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_CONTROL3_IC_1_ADDR, REG_ADC_CONTROL3_IC_1_VALUE, 0)
	REGWRITE(REG_ADC0_VOLUME_IC_1_ADDR, REG_ADC0_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_ADC1_VOLUME_IC_1_ADDR, REG_ADC1_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_ADC2_VOLUME_IC_1_ADDR, REG_ADC2_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_ADC3_VOLUME_IC_1_ADDR, REG_ADC3_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_CONTROL_0_IC_1_ADDR, REG_PGA_CONTROL_0_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_CONTROL_1_IC_1_ADDR, REG_PGA_CONTROL_1_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_CONTROL_2_IC_1_ADDR, REG_PGA_CONTROL_2_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_CONTROL_3_IC_1_ADDR, REG_PGA_CONTROL_3_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_STEP_CONTROL_IC_1_ADDR, REG_PGA_STEP_CONTROL_IC_1_VALUE, 0)
	REGWRITE(REG_PGA_10DB_BOOST_IC_1_ADDR, REG_PGA_10DB_BOOST_IC_1_VALUE, 0)
	REGWRITE(REG_POP_SUPPRESS_IC_1_ADDR, REG_POP_SUPPRESS_IC_1_VALUE, 0)
	REGWRITE(REG_TALKTHRU_IC_1_ADDR, REG_TALKTHRU_IC_1_VALUE, 0)
	REGWRITE(REG_TALKTHRU_GAIN0_IC_1_ADDR, REG_TALKTHRU_GAIN0_IC_1_VALUE, 0)
	REGWRITE(REG_TALKTHRU_GAIN1_IC_1_ADDR, REG_TALKTHRU_GAIN1_IC_1_VALUE, 0)
	REGWRITE(REG_MIC_BIAS_IC_1_ADDR, REG_MIC_BIAS_IC_1_VALUE, 0)
	REGWRITE(REG_DAC_CONTROL1_IC_1_ADDR, REG_DAC_CONTROL1_IC_1_VALUE, 0)
	REGWRITE(REG_DAC0_VOLUME_IC_1_ADDR, REG_DAC0_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_DAC1_VOLUME_IC_1_ADDR, REG_DAC1_VOLUME_IC_1_VALUE, 0)
	REGWRITE(REG_OP_STAGE_MUTES_IC_1_ADDR, REG_OP_STAGE_MUTES_IC_1_VALUE, 0)
	REGWRITE(REG_SAI_0_IC_1_ADDR, reg_sai_0_value, 0)
	REGWRITE(REG_SAI_1_IC_1_ADDR, REG_SAI_1_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_CONTROL0_IC_1_ADDR, REG_SOUT_CONTROL0_IC_1_VALUE, 0)
	REGWRITE(REG_SOUT_CONTROL1_IC_1_ADDR, REG_SOUT_CONTROL1_IC_1_VALUE, 0)
	REGWRITE(REG_PDM_OUT_IC_1_ADDR, REG_PDM_OUT_IC_1_VALUE, 0)
	REGWRITE(REG_PDM_PATTERN_IC_1_ADDR, REG_PDM_PATTERN_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP0_IC_1_ADDR, REG_MODE_MP0_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP1_IC_1_ADDR, REG_MODE_MP1_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP2_IC_1_ADDR, REG_MODE_MP2_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP3_IC_1_ADDR, REG_MODE_MP3_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP4_IC_1_ADDR, REG_MODE_MP4_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP5_IC_1_ADDR, REG_MODE_MP5_IC_1_VALUE, 0)
	REGWRITE(REG_MODE_MP6_IC_1_ADDR, REG_MODE_MP6_IC_1_VALUE, 0)
	REGWRITE(REG_PB_VOL_SET_IC_1_ADDR, REG_PB_VOL_SET_IC_1_VALUE, 0)
	REGWRITE(REG_PB_VOL_CONV_IC_1_ADDR, REG_PB_VOL_CONV_IC_1_VALUE, 0)
	REGWRITE(REG_DEBOUNCE_MODE_IC_1_ADDR, REG_DEBOUNCE_MODE_IC_1_VALUE, 0)
	REGWRITE(REG_RESERVED_IC_1_ADDR, REG_RESERVED_IC_1_VALUE, 0)
	REGWRITE(REG_OP_STAGE_CTRL_IC_1_ADDR, REG_OP_STAGE_CTRL_IC_1_VALUE, 0)
	REGWRITE(REG_DECIM_PWR_MODES_IC_1_ADDR, REG_DECIM_PWR_MODES_IC_1_VALUE, 0)
	REGWRITE(REG_INTERP_PWR_MODES_IC_1_ADDR, REG_INTERP_PWR_MODES_IC_1_VALUE, 0)
	REGWRITE(REG_BIAS_CONTROL0_IC_1_ADDR, REG_BIAS_CONTROL0_IC_1_VALUE, 0)
	REGWRITE(REG_BIAS_CONTROL1_IC_1_ADDR, REG_BIAS_CONTROL1_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL0_IC_1_ADDR, REG_PAD_CONTROL0_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL1_IC_1_ADDR, REG_PAD_CONTROL1_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL2_IC_1_ADDR, REG_PAD_CONTROL2_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL3_IC_1_ADDR, REG_PAD_CONTROL3_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL4_IC_1_ADDR, REG_PAD_CONTROL4_IC_1_VALUE, 0)
	REGWRITE(REG_PAD_CONTROL5_IC_1_ADDR, REG_PAD_CONTROL5_IC_1_VALUE, 0)
	REGWRITE(REG_FAST_RATE_IC_1_ADDR, REG_FAST_RATE_IC_1_VALUE, 0)
	REGWRITE(REG_DAC_CONTROL0_IC_1_ADDR, REG_DAC_CONTROL0_IC_1_VALUE, 0)
	REGWRITE(REG_VOL_BYPASS_IC_1_ADDR, REG_VOL_BYPASS_IC_1_VALUE, 0)
	REGWRITE(REG_ADC_OPER_IC_1_ADDR, REG_ADC_OPER_IC_1_VALUE, 0)
    return XST_SUCCESS;
}
}
