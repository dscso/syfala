import("stdfaust.lib");
declare options "[midi:on]";

// These are now in separate upstairs directories:
// echo = echog(component("echo.dsp"));     // ../echo/echo.dsp
// flanger = flg(component("flanger.dsp")); // ../flanger/flanger.dsp
// chorus = chg(component("chorus.dsp"));   // ../chorus/chorus.dsp
// reverb = rg(component("freeverb.dsp"));  // ../freeverb/freeverb.dsp

note_base = 47;

// bottom-left pads (1-to-4)
note_0 = 1 * hslider("note_1[midi:key 73]", 0, 0, 1, 1);
note_1 = 2 * hslider("note_2[midi:key 74]", 0, 0, 1, 1);
note_2 = 3 * hslider("note_3[midi:key 75]", 0, 0, 1, 1);
note_3 = 4 * hslider("note_4[midi:key 76]", 0, 0, 1, 1);
// bottom-right pads (5-to-8)
note_4 = 5 * hslider("note_5[midi:key 89]", 0, 0, 1, 1);
note_5 = 6 * hslider("note_6[midi:key 90]", 0, 0, 1, 1);
note_6 = 7 * hslider("note_7[midi:key 91]", 0, 0, 1, 1);
note_7 = 8 * hslider("note_8[midi:key 92]", 0, 0, 1, 1);
// top-left pads (1-to-4)
note_8  = 9 * hslider("note_9[midi:key 41]", 0, 0, 1, 1);
note_9  = 10 * hslider("note_10[midi:key 42]", 0, 0, 1, 1);
note_10 = 11 * hslider("note_11[midi:key 43]", 0, 0, 1, 1);
note_11 = 12 * hslider("note_12[midi:key 44]", 0, 0, 1, 1);
// top-right pads (5-to-8)
note_12 = 13 * hslider("note_13[midi:key 57]", 0, 0, 1, 1);
note_13 = 14 * hslider("note_14[midi:key 58]", 0, 0, 1, 1);
note_14 = 15 * hslider("note_15[midi:key 59]", 0, 0, 1, 1);
note_15 = 16 * hslider("note_16[midi:key 60]", 0, 0, 1, 1);

main_note = note_base
            + note_0
            + note_1
            + note_2
            + note_3
            + note_4
            + note_5
            + note_6
            + note_7
            + note_8
            + note_9
            + note_10
            + note_11
            + note_12
            + note_13
            + note_14
            + note_15
;

main_gate = main_note > note_base;

process = main <: _,_; // Now separate: : echo : flanger : chorus : reverb;
main = (signal + attach(extInput,amp) : filters : *(ampScaling)) ~ _;
signal = oscs + noise * noiseOff * namp;

ampScaling = envelopeAmp * masterVolume; // masterVolume is redundant but easier to find
oscs = par(i,3,(oscamp(i+1)*osc(i+1))) :> _;

controlSelect(1) = osc1(vrockerred); // ("[0] use as LFO"));
octaveSelect(1) = osc1(vslider("[1] Octave1 [midi:ctrl 49] [style:knob]",1,0,5,1):int); // LO, 32', 16', 8', 4', 2'
// Osc1 detunes like Osc2 and Osc3 (unlike in the Minimoog where it would be an expensive extra knob):
detuneOctaves(1) = osc1(vslider("[2] DeTuning1 [units:Octaves] [midi:ctrl 29] [style:knob]",0.0,-1.0,1.0,0.001));
waveSelect(1) = osc1(vslider("[3] Waveform1 [midi:ctrl 13] [style:knob]",5,0,5,1):int);
amp1Enable = mr1(vslider("[1] amp1Enable [midleft i:ctrl 12] [style:knob] [color:blue]",1,0,1,1));
oscamp(1) = mr1(vslider("[0] Osc1 Amp [midi:ctrl 77] [style:knob]",0.5,0.0,1.0,0.001)) * amp1Enable;

eei = mr2(vslider("[1] extInputOn [midi:ctrl 13] [style:knob] [color:blue]",0,0,1,1)); // External input = MAIN OUTPUT when "off"
sei = mr2(vslider("[0] Ext Input [midi:ctrl 27] [style: knob]",0,0,1.0,0.001));
extInput(fb,extSig) = fb,extSig : select2(eei) : *(sei) : extClipLED;
extClipLED = _ <: _, (abs : >(0.95) : mr2(vbargraph("[2] Ext Input Clip [style:led]",0,1)):!);
keycLED = attach(mr2(vbargraph("[3] Keyboard Ctl [style:led]",0,1)));

controlSelect(2) = osc2(vrockerred); // ("[0] use as LFO"));
octaveSelect(2) = osc2(vslider("[1] Octave2 [midi:ctrl 50] [style:knob]",1,0,5,1):int); // LO, 32', 16', 8', 4', 2'
detuneOctaves(2) = osc2(vslider("[2] DeTuning2 [units:Octaves] [midi:ctrl 30] [style:knob]",0.41667,-1.0,1.0,0.001));
waveSelect(2) = osc2(vslider("[3] Waveform2 [midi:ctrl 14] [style:knob]",5,0,5,1):int);
amp2Enable = mr3(vslider("[1] amp2Enable [midi:ctrl 14] [style:knob] [color:blue]",1,0,1,1));
oscamp(2) = mr3(vslider("[0] Osc2 Amp [midi:ctrl 78] [style:knob]",0.5,0.0,1.0,0.001)) * amp2Enable;

noise = select2(ntype,no.noise,10.0*no.pink_noise); // pink noise needs some "make-up gain"
namp = mr4(vslider("[0] Noise Amp [midi:ctrl 80] [style: knob]",0.0,0.0,1.0,0.001));
noiseOff = mr4cbg(vslider("[0] noiseEnable [midi:ctrl 52] [style:knob] [color:blue]",0,0,1,1));
ntype = mr4cbg(vslider("[1] White/Pink [midi:ctrl 32] [tooltip: Choose either White or Pink Noise] [style: knob] [color:blue]",1,0,1,1));

controlSelect(3) = osc3(vrockerred); // ("[0] use as LFO"));
octaveSelect(3) = osc3(vslider("[1] Octave3 [midi:ctrl 51] [style:knob]",0,0,5,1):int); // LO, 32', 16', 8', 4', 2'
detuneOctaves(3) = osc3(vslider("[2] DeTuning3 [units:Octaves] [midi:ctrl 31] [style:knob]",0.3,-1.0,1.0,0.001));
waveSelect(3) = osc3(vslider("[3] Waveform3 [midi:ctrl 15] [style:knob]",0,0,5,1):int);
amp3Enable = mr5(vslider("[1] amp3Enable [midi:ctrl 17] [style:knob] [color:blue]",0,0,1,1));
oscamp(3) = mr5(vslider("[0] Osc3 Amp [midi:ctrl 79] [style:knob]",0.5,0.0,1.0,0.001)) * amp3Enable;

waveforms(i) = (tri(i), bent(i), saw(i), sq(i), ptm(i), ptn(i));

// compute oscillator frequency scale factor, staying in lg(Hz) as much as possible:
modWheelShift = 1.5*modWheel; // Manual says 0 to 1.5 octaves
modulationCenterShift = 0; // Leave this off until triangle-wave modulation is debugged
modulationShift = select2(oscModEnable, 0.0,
		          modWheelShift * ( modulationCenterShift + (1.0-modulationCenterShift) * oscNoiseModulation ));
octaveShift(i) = -2+int(octaveSelect(i));
osc3FixedFreq = 369.994; // F# a tritone above middle C
keyFreqGlidedMaybe = select2(osc3Control,osc3FixedFreq,keyFreqGlided);
keyFreqModulatedShifted(3) = keyFreqGlidedMaybe; // osc3 not allowed to FM itself
keyFreqModulatedShifted(i) = keyFreqGlided * pow(2.0, modulationShift); // i=1,2

// When disconnected from the keyboard, Osc3 can detune 3 octaves up or down (Pat video):
detuneBoost(3) = select2(osc3Control,3.0,1.0);
detuneBoost(i) = 1.0; // i=1,2
detuneOctavesFinal(i) = detuneOctaves(i)*detuneBoost(i);

fBase(i) = keyFreqModulatedShifted(i) * pow(2.0, (masterTuneOctaves+octaveShift(i)+detuneOctavesFinal(i)))
           : si.smooth(ba.tau2pole(0.016));
fLFOBase(i) = 3.0 * pow(2.0, detuneOctavesFinal(i)); // used when osc3 (only) is in LFO mode
lfoMode(i) = (octaveSelect(i) == 0);
f(i) = select2(lfoMode(i), fBase(i), fLFOBase(i)); // lowest range setting is LFO mode for any osc

// i is 1-based:
osc(i) = ba.selectn(6, int(waveSelect(i)), tri(i), bent(i), saw(i), sq(i), ptm(i), ptn(i));
tri(i) = select2(lfoMode(i),
          os.triangle(f(i)),
          os.lf_triangle(f(i)));
bent(i) = 0.5*tri(i) + 0.5*saw(i); // from Minimoog manual
saw(i) = select2(lfoMode(i),
          os.sawtooth(f(i)),
          os.lf_saw(f(i)));
sq(i) = select2(lfoMode(i),
          os.square(f(i)),
          os.lf_squarewave(f(i)));
ptm(i) = select2(lfoMode(i), // Note: a Duty knob would be better than these two, or in addition
          os.pulsetrain(f(i),0.25),
          lf_pulsetrain(f(i),0.25));
ptn(i) = select2(lfoMode(i),
          os.pulsetrain(f(i),0.125),
          lf_pulsetrain(f(i),0.125));

// Soon to appear in oscillators.lib:
lf_pulsetrain(freq,duty) = 2.0*os.lf_pulsetrainpos(freq,duty) - 1.0;

filters = ba.bypass1(bp,vcf); // BYPASS WILL GO AWAY (I think you just open it up all the way to bypass):
bp = 0; // VCF is always on
fcLgHz = vcf1(vslider("[1] Corner Freq [unit:Log2(Hz)]
		  [tooltip: Corner resonance frequency in Log2(Hertz)]
		  [style: knob]
                  [midi:ctrl 17]", // Frequency Cutoff (aka Brightness )
          10.6, log(40.0)/log(2), log(20000.0)/log(2), 0.000001)) // 9 octaves (from Minimoog manual)
		  //p: 40, 30, 80, 0.01))
		  //p: : ba.pianokey2hz
          : si.smooth(ba.tau2pole(0.016));
res = vcf1(vslider("[2] Corner Resonance [midi:ctrl 33] [tooltip: Resonance Q at VCF corner frequency (0 to 1)]
		  [style: knob]",
		  0.7, 0, 1, 0.01));

vcfKeyRange = vcf1cbg(vslider("[2] Kbd Ctl [midi:ctrl 38] [tooltip: Keyboard tracking of VCF corner-frequency (0=none, 1=full)]
		  [style: knob]",
		  1, 0, 1, 0.001)); // was in mr2
vcfModEnable = vcf1cbg(vslider("[1] Filter Mod. [midi:ctrl 53] [color:red] [style:knob] [tooltip: Filter Modulation => Route Modulation Mix output to VCF frequency]",1,0,1,1));
// Note that VCF has three sources of corner-frequency setting that are added together:
// - Corner Freq knob (40 Hz to 20 kHz)
// - VCF Contour envelope (0 to 4 octaves)
// - Injection 32 of Modulation Mix (0 to 1.5 octaves)
// Manual says maximum vcf sweep spans 0 to 4 octaves:
// Original Knob went to 10, but we're going to 4 so we can say the knob is in "octaves" units:
vcfContourAmountOctaves = vcf1(vslider("[3] Amount of Contour (octaves) [midi:ctrl 39] [style: knob]", 1.2, 0, 4.0, 0.001));
vcfContourOctaves = vcfContourAmountOctaves * envelopeVCF; // in octaves
// We are assuming that the modulation-mix range for the VCF freq is 1.5 octaves like it is for oscs 1 and 2:
vcfModMixModulationOctaves = select2(vcfModEnable, 0, (1.5 * oscNoiseModulation * modWheel)); // octaves
vcfModulationOctaves = vcfModMixModulationOctaves + vcfContourOctaves;
keyFreqLogHzGlided = log(keyFreqGlided)/log(2.0); // FIXME: Start w freqLogHz not freq so we don't need exp(log()) here
keyShiftOctaves = keyFreqLogHzGlided - log(261.625565)/log(2.0); // FIXME: ARBITRARILY centering on middle C - check device
vcfKeyShiftOctaves = vcfKeyRange * keyShiftOctaves;
modulatedFcLgHz = fcLgHz + vcfModulationOctaves + vcfKeyShiftOctaves;

fc = min((0.5*ma.SR), pow(2.0,modulatedFcLgHz));
vcf = ve.moog_vcf_2bn(res,fc);

// Attack, Decay, and Sustain ranges are set according to the Minimoog manual:
attT60VCF = 0.001 * vcf2(vslider("[0] AttackF [midi:ctrl 81] [tooltip: Attack Time] [unit:ms] [style: knob]",1400,10,10000,1));
decT60VCF = 0.001 * vcf2(vslider("[0] DecayF [midi:ctrl 82] [tooltip: Decay-to-Sustain Time] [unit:ms] [style: knob]",10,10,10000,1));
susLvlVCF = 0.01 * vcf2(vslider("[0] SustainF [midi:ctrl 83] [tooltip: Sustain level as percent of max] [style: knob]",80,0,100,0.1));
decayButton = wg(vslider("Decay [midi:ctrl 20] [tooltip:Envelope Release either Decay value or 0][style:knob]",1,0,1,1):int); // was Staccato
legatoButton = wg(vslider("GlideEnable [midi:ctrl 65] [tooltip: Glide from note to note][style:knob]",1,0,1,1)); // was Legato
relT60VCF = select2(decayButton,0.010,decT60VCF);
envelopeVCF = en.adsre(attT60VCF,decT60VCF,susLvlVCF,relT60VCF,gate);

// --- Smart Keyboard interface ---

declare interface "SmartKeyboard{
    'Number of Keyboards':'2',
    'Keyboard 0 - Number of Keys':'13',
    'Keyboard 1 - Number of Keys':'13',
    'Keyboard 0 - Lowest Key':'72',
    'Keyboard 1 - Lowest Key':'60'
}";

// --- functions ---

// Signal controls:

keyDownHold = gg(vslider("[0] gateHold [tooltip: lock sustain pedal on (hold gate set at 1)][style:knob]",0,0,1,1));

keyDown = gg(button("[1] gate [tooltip: The gate signal is 1 during a
	note and 0 otherwise. For MIDI, NoteOn occurs when the gate
	transitions from 0 to 1, and NoteOff is an event corresponding
	to the gate transition from 1 to 0. The name of this Faust
	button must be 'gate'.]"));

sustain = gg(button("[1] sustain [midi:ctrl 64]
	[tooltip: extends the gate (keeps it set to 1)]")); // MIDI only (see smartkeyb doc)

//gate = keyDown + keyDownHold + sustain : min(1);
gate = main_gate + keyDown + keyDownHold + sustain : min(1);

attT60 = 0.001 * ng(vslider("[0] AttackA [midi:ctrl 43] [tooltip: Attack Time] [unit:ms] [style: knob]",2,0,5000,0.1));
decT60 = 0.001 * ng(vslider("[0] DecayA [midi:ctrl 44] [tooltip: Decay-to-Sustain Time] [unit:ms] [style: knob]",10,0,10000,0.1));
susLvl = 0.01 * ng(vslider("[0] SustainA [midi:ctrl 45] [tooltip: Sustain level as percent of max] [style: knob]",80,0,100,0.1));
relT60 = select2(decayButton,0.010,decT60); // right?
envelopeAmpNoAM = en.adsre(attT60,decT60,susLvl,relT60,gate);
AMDepth = 0.5;
envelopeAmp = select2(oscModEnable, envelopeAmpNoAM,
	    envelopeAmpNoAM * (1.0 + AMDepth*modWheel * 0.5 * (1.0+oscNoiseModulation)));

// Signal Parameters
ampL = volg(vslider("[1] gain [style:knob] [midi:ctrl 84] [tooltip: Amplitude]",0.2,0,1.0,0.001));
amp = ampL : si.smoo; // envelopeAmp is multiplied once on entire signal sum
//elecGuitar.dsp values used:
bend = wg(ba.semi2ratio(hslider("[0] bend [style:knob] [midi:pitchwheel]",0,-2,2,0.01))) : si.polySmooth(gate,0.999,1);
//Previous guess:
modWheel = wg(vslider("[1] mod [midi:ctrl 1] [style:knob] [tooltip: PitchModulation amplitude in octaves]",
	       0,0,1.0,0.01)) : si.polySmooth(gate,0.999,1);
//p: MIDI requires frequency in Hz, not piano-keys as we had before
// Frequency Range is 0.1 Hz to 20 kHz according to the Minimoog manual:
// MIDI REQUIRES THE FOLLOWING PARAMETER TO BE NAMED 'freq':
keyFreqBent = ba.midikey2hz(main_note); //+ kg(hslider("[2] freq [unit:Hz] [style:knob]",440,0.1,20000,0.1));
//keyFreqBent = bend * main_note;
masterVolume = vg(vslider("MasterVolume [style:knob] [midi:ctrl 7] [tooltip: master volume, MIDI controlled]",
         0.7,0,1,0.001))
           : si.smooth(ba.tau2pole(0.16));
masterTuneOctaves = dg(vslider("[0] Tune [midi:ctrl 47] [unit:Octaves] [style:knob]
    [tooltip: Frequency-shift up or down for all oscillators in Octaves]", 0.0,-1.0,1.0,0.001));
    // Oscillator Modulation HrockerRed => apply Modulation Mix output osc1&2 pitches
glide = gmmg(vslider("[0] Glide [midi:ctrl 5] [unit:sec/octave] [style:knob] [scale:log]
    [tooltip: Portamento (frequency-glide) in seconds per octave]",
		    0.008,0.001,1.0,0.001));
legatoPole = select2(legatoButton,0.5,ba.tau2pole(glide*exp(1.0f)/2.0f)); // convert 1/e to 1/2 by slowing down exp
keyFreqGlided = keyFreqBent : si.smooth(legatoPole);

mmix = gmmg(vslider("[1] Mod. Mix [midi:ctrl 48] [style:knob] [tooltip: Modulation Mix: Osc3 (0) to Noise (1)]",
            0.0,0.0,1.0,0.001));
oscNoiseModulation = (mmix * noise) + ((1.0-mmix) * osc(3)); // noise amplitude and off-switch ignored here
oscModEnable = dsg(vslider("[0] Osc. Mod. [midi:ctrl 22] [color:red] [style:knob] [tooltip:Oscillator Modulation adds Modulation Mix output to osc1&2 frequencies",1,0,1,1)); // any offset?
osc3Control = dsg(vslider("[1] Osc. 3 Ctl [midi:ctrl 9] [color:red] [style:knob] [tooltip:Oscillator 3 frequency tracks the keyboard if on, else not",0,0,1,1):int);
// This layout loosely follows the MiniMoog-V
// Arturia-only features are labeled
// Original versions also added where different

// Need vrocker and hrocker toggle switches in Faust!
// Need orange and blue color choices
//   Orange => Connect modulation sources to their destinations
//    Blue  => Turn audio sources On and Off
// - and later -
//   White  => Turn performance features On and Off
//   Black  => Select between modulation sources
//   Julius Smith for Analog Devices 3/1/2017

vrocker(x) = checkbox("%%x [style:vrocker]");
hrocker(x) = checkbox("%%x [style:hrocker]");
vrockerblue(x) = checkbox("%x  [style:vrocker] [color:blue]");
vrockerblue(x) = checkbox("%x [style:vrocker] [color:blue]");
 // USAGE: vrockerorange("[0] ModulationEnable");

hrockerblue(x) = checkbox("%%x [style:hrocker] [color:blue]");
vrockerred(x) = checkbox("%%x [style:vrocker] [color:red]");
hrockerred(x) = checkbox("%%x [style:hrocker] [color:red]");

declare designer "Robert A. Moog";

mmg(x) = hgroup("",x); // Minimoog + Effects
  synthg(x) = mmg(vgroup("[0] Minimoog",x));
  fxg(x) = mmg(hgroup("[1] Effects",x));
  mg(x) = synthg(hgroup("[0]",x));
    cg(x) = mg(vgroup("[0] Controllers",x)); // Formerly named "Modules" but "Minimoog" group-title is enough
      vg(x) = cg(hgroup("[0] Master Volume", x));
      dg(x) = cg(hgroup("[1] Oscillator Tuning & Switching", x));
        // Tune knob = master tune
        dsg(x) = dg(vgroup("[1] Switches", x));
	  // Oscillator Modulation HrockerRed => apply Modulation Mix output to osc1&2 pitches
	  // [MOVED here from osc3 group] Osc 3 Control VrockerRed => use osc3 as LFO instead of osc3
      gmmg(x) = cg(hgroup("[2] Glide and ModMix", x));
        // Glide knob [0:10] = portamento speed
        // Modulation Mix knob [0:10] (between Osc3 and Noise) = mix of noise and osc3 modulating osc1&2 pitch and/or VCF freq
    og(x) = mg(vgroup("[1] Oscillator Bank", x));
      osc1(x) = og(hgroup("[1] Oscillator 1", x));
        // UNUSED Control switch (for alignment) - Could put Oscillator Modulation switch there
        // Range rotary switch: LO (slow pulses or rhythm), 32', 16', 8', 4', 2'
        // Frequency <something> switch: LED to right
        // Waveform rotary switch: tri, impulse/bent-triangle, saw, pulseWide, pulseMed, pulseNarrow
      osc2(x) = og(hgroup("[2] Oscillator 2", x));
        // UNUSED (originall) or Osc 2 Control VrockerRed
        // Range rotary switch: LO, 32', 16', 8', 4', 2'
        // Detuning knob: -7 to 7 [NO SWITCH]
        // Waveform rotary switch: tri, impulse(?), saw, pulseWide, pulseMed, pulseNarrow
      osc3(x) = og(hgroup("[3] Oscillator 3", x));
        // Osc 3 Control VrockerRed => use osc3 as LFO instead of osc3
        // Range rotary switch: LO, 32', 16', 8', 4', 2'
        // Detuning knob: -7 to 7 [NO SWITCH]
        // Waveform rotary switch: tri, impulse(?), saw, pulseWide, pulseMed, pulseNarrow
    mixg(x) = mg(vgroup("[2] Mixer", x));
      // Each row 5 slots to maintain alignment and include red rockers joining VCF area:
      mr1(x) = mixg(hgroup("[0] Osc1", x)); // mixer row 1 =
      // Osc1 Volume and Osc1 HrockerBlue & _ & _ & Filter Modulation HrockerRed
      // Filter Modulation => Modulation Mix output to VCF freq
      mr2(x) = mixg(hgroup("[1] Ext In, KeyCtl", x)); // row 2 = Ext In HrockerBlue and Vol and Overload LED and Keyboard Ctl HrockerRed 1
      mr3(x) = mixg(hgroup("[2] Osc2", x)); // = Osc2 Volume and Osc2 HrockerBlue and Keyboard Ctl HrockerRed 2
      // Keyboard Control Modulation 1&2 => 0, 1/3, 2/3, all of Keyboard Control Signal ("gate?") applied to VCF freq
      mr4(x) = mixg(hgroup("[3] Noise", x)); // = Noise HrockerBlue and Volume and Noise Type VrockerBlue
        mr4cbg(x) = mr4(vgroup("[1]", x)); // = Noise Off and White/Pink selection
	// two rockers
      mr5(x) = mixg(hgroup("[4] Osc3", x)); //  Osc3 Volume and Osc3 HrockerBlue
    modg(x) = mg(vgroup("[3] Modifiers", x));
      vcfg(x) = modg(vgroup("[0] Filter", x));
        vcf1(x) = vcfg(hgroup("[0] [tooltip:freq, Q, ContourScale]", x));
	  vcf1cbg(x) = vcf1(vgroup("[0] [tooltip:two checkboxes]", x));
          // Filter Modulation switch
          // VCF Off switch
        // Corner Frequency knob
        // Filter Emphasis knob
        // Amount of Contour knob
        vcf2(x) = vcfg(hgroup("[1] Filter Contour [tooltip:AttFilt, DecFilt, Sustain Level for Filter Contour]", x));
        // Attack Time knob
        // Decay Time knob
        // Sustain Level knob
      ng(x) = modg(hgroup("[1] Loudness Contour", x));
        // Attack Time knob
        // Decay Time knob
        // Sustain Level knob
    echog(x) = fxg(hgroup("[4] Echo",x));
      ekg(x) = echog(vgroup("[0] Knobs",x));
      esg(x) = echog(vgroup("[1] Switches",x));
    flg(x) = fxg(hgroup("[5] Flanger",x));
      flkg(x) = flg(vgroup("[0] Knobs",x));
      flsg(x) = flg(vgroup("[1] Switches",x));
    chg(x) = fxg(hgroup("[6] Chorus",x));
      ckg(x) = chg(vgroup("[0] Knobs",x));
      csg(x) = chg(vgroup("[1] Switches",x));
    rg(x) = fxg(hgroup("[7] Reverb",x));
      rkg(x) = rg(vgroup("[0] Knobs",x));
      rsg(x) = rg(vgroup("[1] Switches",x));
    outg(x) = fxg(vgroup("[8] Output", x));
      volg(x) = outg(hgroup("[0] Volume Main Output", x));
        // Volume knob [0-10]
	// Unison switch (Arturia) or Output connect/disconnect switch (original)
	//   When set, all voices are stacked and instrument is in mono mode
      tunerg(x) = outg(hgroup("[1] A-440 Switch", x));
      vdtpolyg(x) = outg(hgroup("[2] Voice Detune / Poly", x));
        // Voice Detune knob [0-10] (Arturia) or
	// Polyphonic switch [red LED below] (Arturia)
	//   When set, instrument is in polyphonic mode with one oscillator per key
    clipg(x) = fxg(vgroup("[9] Soft Clip", x));
	// Soft Clipping switch [red LED above]
  kg(x) = synthg(hgroup("[1] Keyboard Group", x)); // Keyboard was 3 1/2 octaves
    ws(x) = kg(vgroup("[0] Wheels and Switches", x));
      s1g(x) = ws(hgroup("[0] Jacks and Rockers", x));
        jg(x) = s1g(vgroup("[0] MiniJacks",x));
        gdlg(x) = s1g(vgroup("[1] Glide/Decay/Legato Enables",x)); // Arturia
	// Glide Hrocker (see original Button version below)
	// Decay Hrocker (see original Button version below) => Sets Release (R) of ADSR to either 0 or Decay (R)
	// Legato Hrocker (not in original)
      s2g(x) = ws(hgroup("[1] [tooltip:Wheels+]", x));
        bg(x) = s2g(vgroup("[0] [tooltip:Bend Enable and Range]", x));
        wg(x) = s2g(hgroup("[1] [tooltip:Bend and Mod Wheels]", x));
	// Using Glide/Decay/Legato enables above following Arturia:
	//   dg(x) = s2g(hgroup("[2] Glide and Decay momentary pushbuttons", x));
	//   Glide Button injects portamento as set by Glide knob
	//   Decay Button uses decay of Loudness Contour (else 0)
    keys(x) = kg(hgroup("[1] [tooltip:Keys]", x));
      gg(x) = keys(hgroup("[0] [tooltip: Gates]",x));
      // leave slot 1 open for sustain (below)

