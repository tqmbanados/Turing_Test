<CsoundSynthesizer>
<CsOptions>
-odac
-m128
-Ma
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 16
0dbfs = 1

massign(0, 0)

#include "OOP_UDOS.udos"
//THESE UDOS ASSUME A CERTAIN FRAMEWORK FOR CLASS CODING
// P4 Of instruments that belong to a class must ALWAYS be the class name!
vbaplsinit 2, 4, -45, 45, 135, -135

////// GLOBAL Params //////
giRecord = 1 // if 1 then record
ginBufferSize = 4 //seconds
giAmpFactor = 2.5 //multiply certain amps by this amount
giPlayback = 0 //1 if mics should be played through csound. Use for testing while listening to recording.

// PATHS
gSPushChordA = "audio_samples/chords/chordA.wav"
gSPushChordB = "audio_samples/chords/chordB.wav"
gSFileA = "audio_samples/tts/password.wav"
gSFileB = "audio_samples/tts/enunciation.wav"
gSFileC = "audio_samples/tts/password.wav"
gSTestSample = "audio_samples/test/AccordeonRecording.wav"

//Buffers
giBufferA ftgen 0, 0, 0, -1, gSFileA, 0, 0, 0
giBufferB ftgen 0, 0, 0, -1, gSFileB, 0, 0, 0
giBufferC ftgen 0, 0, 0, -1, gSFileC, 0, 0, 0
giMicin1 ftgen 0, 0, ginBufferSize*sr, 2, 0
giMicin2 ftgen 0, 0, ginBufferSize*sr, 2, 0
giMicin3 ftgen 0, 0, ginBufferSize*sr, 2, 0
giTestBuffer ftgen 0, 0, ginBufferSize*sr, 2, 0

ginChannel1 = 0  // Accordion Right //  0 to read file, else, determines the in channel
ginChannel2 = 0  // Accordion Left //   0 to read file, else, determines the in channel
ginChannel3 = 0  // Headset  		 //    0 to read file, else, determines the in channel


gkPushUpperDBLimit init -0
gkPushLowerDBLimit init -40
gkPushEnvDetecionFactor init 1
gkPushResponseLevel init 12

gkSeedEnvBaseDB init 20
gkSeedReactBaseDB init 20

gkCroakQBaseDB init 10
gkCroakEnvBaseDB init 0

gkTesting init 0

// Meter Channels
chn_k "in1", 2
chn_k "in1_over", 2
chn_k "in2", 2
chn_k "in2_over", 2
chn_k "in3", 2
chn_k "in3_over", 2

chn_k "out1", 2
chn_k "out1_over", 2
chn_k "out2", 2
chn_k "out2_over", 2
chn_k "out3", 2
chn_k "out3_over", 2
chn_k "out4", 2
chn_k "out4_over", 2

chn_k "sampA", 2
chn_k "sampA_over", 2
chn_k "sampB", 2
chn_k "sampB_over", 2

// Global channels
chn_k "growth", 3
chn_a "bufferPosition", 3	//current write index of the buffer
chn_k "masterdB", 1				//master dB
chn_k "reverbSize", 3			//room size (0-1)
chn_k "reverbHC", 3				//decay of higherfrequencies
chn_k "reverbHCBase", 3		//normalized and pre-exponential value for reverbHC for controller use

chn_a "EOut1", 2		//Outs for electronics
chn_a "EOut2", 2
chn_a "EOut3", 2
chn_a "EOut4", 2

chn_k "mirror_status", 3		//status of each extension
chn_k "push_active", 3
chn_k "push_reverse", 3
chn_k "seed_active", 3
chn_k "croak_active", 3

// Soundcheck channels
chn_k "test_noise_db", 3
chn_k "push_upper_db", 3
chn_k "push_lower_db", 3
chn_k "push_indb", 2
chn_k "push_outdb", 2

chn_k "push_env_detect", 3
chn_k "push_response_level", 3
chn_k "global_in_gain", 3

chn_k "seed_env_base_db", 3

chn_k "croak_q_base_db", 3
chn_k "croak_env_base_db", 3


//fft setup
gifftsize  = pow(2, 12)
gioverlap =  gifftsize / 4
giwintype  = 1 

////// General Opcodes //////
opcode CsQtMeter, 0, SSak
 S_chan_sig, S_chan_over, aSig, kTrig	 xin
 iDbRange = 60 ;shows 60 dB
 iHoldTim = 1 ;seconds to "hold the red light"
 kOn init 0
 kTim init 0
 kStart init 0
 kEnd init 0
 kMax max_k aSig, kTrig, 1
 if kTrig == 1 then
  chnset (iDbRange + dbfsamp(kMax)) / iDbRange, S_chan_sig
  if kOn == 0 && kMax > 1 then
   kTim = 0
   kEnd = iHoldTim
   chnset k(1), S_chan_over
   kOn = 1
  endif
  if kOn == 1 && kTim > kEnd then
   chnset k(0), S_chan_over
   kOn =	0
  endif
 endif
 kTim += ksmps/sr
; code by Joachim Heintz
endop

opcode IdxAccum, a, i
	iBuffer xin
	//iLen = nsamp(iBuffer)
	aIdx = line:a(0, 1, sr)
	xout aIdx
endop

opcode ReadBuffer, a, ik
	iBuffer, kDelay xin
	aPos chnget "bufferPosition" //We get the current position of the Buffer
	aPos -= sr * kDelay //We substract from the position based on kDelay in seconds
	aOut table3 aPos, iBuffer, 0, 0, 1
	xout aOut
endop

opcode SendAll, 0, a
	//send audio to all out channels
	aOut xin
	chnmix aOut, "EOut1"
	chnmix aOut, "EOut2"
	chnmix aOut, "EOut3"
	chnmix aOut, "EOut4"
endop

opcode OutArray, 0, a[]
	aOut[] xin
	chnmix aOut[0], "EOut1"
	chnmix aOut[1], "EOut2"
	chnmix aOut[2], "EOut3"
	chnmix aOut[3], "EOut4"
endop

opcode SendSampleData, 0, 0
	aIdx = line:a(0, 1, sr)
	aSampA table3, aIdx, giBufferA, 0, 0, 1
	aSampB table3, aIdx, giBufferB, 0, 0, 1
	kTrigDisp metro 5
 	CsQtMeter "sampA", "sampA_over", aSampA, kTrigDisp
 	CsQtMeter "sampB", "sampB_over", aSampB, kTrigDisp
endop


instr Chassis
	//Base control instrument
	schedule "Mic", 0, p3
	schedule "PushInit", 0, 0.1, "push"
	schedule "SeedInit", 0, 0.1, "seed"
	schedule "CroakInit", 0, 0.1, "croak"
	schedule "Setup1", 0, 1
	schedule "MidiController", 0, p3
	schedule "Master", 0, p3
	schedule "Recorder", 0, p3
	
	iCroakNum nstrnum "Croak" 
	iSeedNum nstrnum "Seed" 
	iTestNum nstrnum "Testing" 
	kMirrorStatus chnget "mirror_status"
	kMirrorReverse chnget "push_reverse"
	kCroakStatus chnget "croak_status"
	kSeedStatus chnget "seed_status"
	kTestingStatus chnget "testing_status"
	
	kMirrorChanged changed2 kMirrorStatus
	kCroakChanged changed2 kCroakStatus
	kSeedChanged changed2 kSeedStatus
	kTestingChanged changed2 kTestingStatus
	if kMirrorChanged == 1 then
		if kMirrorStatus == 1 then
			schedulek "Push", 0, 999, "push", kMirrorReverse
			chnset k(1), "push_active"
			chnset k(0), "push.endpush"
		elseif kMirrorStatus == 2 then
			chnset k(1), "push.endpush"
		endif
	endif
	
	if kSeedChanged == 1 then
		if kSeedStatus == 1 then
			schedulek "Seed", 0, -1, "seed"
			chnset k(1), "seed_active"
		elseif kSeedStatus == 2 then
			turnoff2 k(iSeedNum), 0, 0
			schedulek "SeedEnd", 0, 3, "seed"
			chnset k(0), "seed_active"
		endif
	endif
	
	if kCroakChanged == 1 then
		if kCroakStatus == 1 then
			schedulek "Croak", 0, -1, "croak"
			chnset k(1), "croak_active"
		elseif kCroakStatus == 2 then
			turnoff2 k(iCroakNum), 0, 1
			chnset k(0), "croak_active"
		endif
	endif
	if kTestingChanged == 1 then
		if kTestingStatus == 1 then
			schedulek "Testing", 0, -1
			gkTesting = 1
		elseif kTestingStatus == 2 then
			turnoff2 k(iTestNum), 0, 1
			gkTesting = 0
		endif
	endif
	
	gkPushUpperDBLimit chnget "push_upper_db"
	gkPushLowerDBLimit chnget "push_lower_db"
	gkPushEnvDetecionFactor chnget "push_env_detect"
	gkPushResponseLevel chnget "push_response_level"
	
	gkSeedEnvBaseDB chnget "seed_env_base_db"
	gkSeedReactBaseDB chnget "seed_react_base_db"
	
	gkCroakQBaseDB chnget "croak_q_base_db"
	gkCroakEnvBaseDB chnget "croak_env_base_db"
	
	//Freq Unnormalization
	kRevHPBase chnget "reverbHCBase"
	kRevHPReal = scale:k(pow:k(kRevHPBase, 2), 15000, 100, 1, 0)
	chnset kRevHPReal, "reverbHC"
	
endin

instr MidiController
	kOne init 1
	kTwo init 2
	kStatus, kChan, kData1, kData2 midiin
	kTrig changed kStatus, kChan, kData1, kData2
	if kTrig = 1 then
		//F -> 5, G -> 7, B -> 11, C -> 0, D -> 2
		kPitchClass = kData1 % 12
		//printks "status:%d%tchannel:%d%tdata1:%d%tdata2:%d%n", 0, kStatus, kChan, kData1,kData2
		if kStatus == 144 then
			if kPitchClass == 5 then
				chnset kOne, "mirror_status"
			elseif kPitchClass == 6 then
				chnset kTwo, "mirror_status"
			elseif kPitchClass == 7 then
				chnset kOne, "seed_status"
			elseif kPitchClass == 8 then
				chnset kTwo, "seed_status"
			elseif kPitchClass == 9 then
				chnset kOne, "croak_status"
			elseif kPitchClass == 10 then
				chnset kTwo, "croak_status"
			elseif kPitchClass == 11 then
				kPushReverse chnget "push_reverse"
				kPushReverse = 1 - kPushReverse
				chnset kPushReverse, "push_reverse"
			elseif kPitchClass == 2 then
				chnset 1, "seed.eventPlay"
			elseif kPitchClass == 4 then
				chnset 1, "seed.eventEnd"
			endif
		endif
		 
		 
	endif
endin


instr Setup1
	chnset 0.6, "reverbSize"
	chnset 0.5, "reverbHCBase"
	chnset 0, "push_active"
	chnset 0, "seed_active"
	chnset 0, "croak_active"
	
	chnset 0, "growth"
	chnset -6, "masterdB"
	chnset 7, "global_in_gain"
	
	chnset 0, "push_upper_db"
	chnset -60, "push_lower_db"
	chnset 0, "push_env_detect"
	chnset 12, "push_response_level"
	
	chnset 20, "seed_env_base_db"
	
endin


///////////////////////////////////////////////////////////////////////
////////////////////////////////// seed //////////////////////////////
//////////////////////////////////////////////////////////////////////

////// Attributes //////
chn_a "seed.reactiveEnv", 3
chn_k "seed.pendulumWidth", 3
chn_k "seed.eventPause", 3
chn_k "seed.eventPlay", 3
chn_k "seed.eventEnd", 3
chn_k "seed.globalEnv", 3

chn_k "seed.table1", 3
chn_k "seed.table2", 3
chn_k "seed.playing", 3
chn_k "seed.ending", 3

chn_k "seed.minSize", 3
chn_k "seed.period", 3
chn_k "seed.reactionLevel", 3

chn_k "seed.global_db", 3
chn_k "seed.growth", 2

//Buffer Choice

chn_k "buffer_1", 3
chn_k "buffer_2", 3
chn_S "buff_1_name", 3
chn_S "buff_2_name", 3


instr SeedInit
	prints "Initializing Class %s\n", strget(p4)
	SetAttr "growth", 0
	SetAttr "globalEnv", 1
	SetAttr "eventEnd", 0
	SetAttr "minSize", 1
	SetAttr "period", 0.0001
	SetAttr "pendulumWidth", 1

endin

opcode Pendulum, kk, kop
	kNextDur, iMin, iMax xin
	iSize = iMax - iMin
	kPos init iMin
	kCurrentDur init 1
	kPolarity init 1
	kTrig changed kPolarity
	
	if kTrig == 1 then
		kCurrentDur = kNextDur
	endif
	
	if kPos <= iMin then
		kPolarity = 1
	elseif kPos >= iMax then
		kPolarity = -1
	endif
	
	if kCurrentDur == 0 then
		printf "WARNING: kCurrentDur = 0!!!", 1
		kCurrentDur = 1
	endif
	
	kPos += (kPolarity * iSize) / (kr * kCurrentDur)
	xout kPos, kPolarity
endop

opcode ReactiveEnvelope, a, ii
/*
	Creates amplitude variation based on rms of a buffer, exaggerating it through exponential functions.
*/
	iBuffer1, iBuffer2 xin
	kGrowth GetAttr "growth"
	kDelay scale kGrowth, ginBufferSize * 0.6, 0, 1, 0
	kIntensity = 2
	audioIn1 ReadBuffer iBuffer1, kDelay
	audioIn2 ReadBuffer iBuffer2, kDelay
	kAmpIn = rms(audioIn1 + audioIn2)
	kAmpIn limit kAmpIn, 0.000001, 1
	kAmpFactor ampdb gkSeedEnvBaseDB
	kPowered = pow:k(kAmpIn, kIntensity)
	kPowered = limit(kPowered, 0.2, 2)
	aAmp = interp(kPowered)
	xout aAmp * 2
endop

opcode PingPongFFTGranulator, a, iikaakkk
/*receives two audio signals and performs the Synthesis.
The size of each "grain" is reduced as Growth.k increases, 
as well as the variation in size.
*/
	iFnTable1, iFnTable2, kPositionVariation, aPosition1, aPosition2, kMin, kMSize, kPendulumWidth xin
	kMax = kMin + kMSize
	kDur init random:i(i(kMin), i(kMax))
	kPenPos, kPolarity Pendulum kDur
	kPenMax = limit(0.5 + (kPendulumWidth / 2), 0, 1)
	kPenMin = limit(0.5 - (kPendulumWidth / 2), 0, 1)
	
	kPenPos scale kPenPos, kPenMax, kPenMin, 1, 0
	kPosDiff1 init 0
	kPosDiff2 init 0
	
	kTrigger changed kPolarity
	if kTrigger == 1 then
		kDur random kMin, kMax
		if kPolarity == 1 then
			kPosDiff1 = random:k(0, kPositionVariation)
			//printk 0, kPosDiff1, 0, 1
			kPosDiff1 *= sr
		else 
			kPosDiff2 = random:k(0, kPositionVariation)
			//printk 0, kPosDiff2, 0, 1
			kPosDiff2 *= sr
		endif
	endif
	
	aPos1 = aPosition1 - kPosDiff1
	aPos2 = aPosition2 - kPosDiff2
	aSamp1 table3 aPos1, iFnTable1, 0, 0, 1
	aSamp2 table3 aPos2, iFnTable2, 0, 0, 1
	fSound1 pvsanal aSamp1, gifftsize, gioverlap, gifftsize, giwintype
	fSound2 pvsanal aSamp2, gifftsize, gioverlap, gifftsize, giwintype
	fMorph pvsmorph fSound1, fSound2, kPenPos, kPenPos
	fSmoothed pvsmooth fMorph, 0.4, 0.4
	aOut pvsynth fSmoothed
	xout aOut
endop

opcode SeedRhythmicEnvelope, k, 0
/*
Creates rhythms for each event, based on algorithms. 
As Growth.k gets larger, the rhythms are more varied and random.
Outputs 1 whenever an event should happen
*/
	iPeakHalfLife = 2 //time it takes for -6 decibel
	iMinFreqDecay = 1/4 //per second
	iMaxFreqDecay = 1/5 //per second
	inversekr = 1/kr
	iMinPeak = -24
	kPeakDB init 0
	audioIn ReadBuffer giMicin3, 0
	kAmp = rms:k(audioIn)
	kDB dbamp kAmp
	
	kDB = gkSeedEnvBaseDB + kDB
	kMinFreq init 0.4
	kMaxFreq init 0.7
	
	if kDB >= kPeakDB then
		//printks "New Peak Reached: %f\n", 0, kDB
		kMinFreq = 1
		kMaxFreq = 2.5
		kPeakDB = kDB
	else 
		kMinFreq = limit(kMinFreq - (iMinFreqDecay * inversekr), 0.1, 2)
		kMaxFreq = limit(kMaxFreq - (iMaxFreqDecay * inversekr), 0.3, 2)
	endif

	kFreqFreq = 5.1 + poscil:k(5, 0.4)
	kFreq = randomi:k(kMinFreq, kMaxFreq, kFreqFreq)
	kPlay = metro:k(kFreq)
	kPaused GetAttr "paused"
	if kPaused == 1 then
		kPlay = 0
	endif
	kPeakDB = limit(kPeakDB + ((-6/iPeakHalfLife) * inversekr), -60, 1)
	//printk 1, kPeakDB
	xout kPlay
endop

opcode GetTableFromValue, k, kk
	kValue, kPrevious xin
		if kValue == 1 then
			kTable = giMicin1
		elseif kValue == 2 then
			kTable = giMicin2
		elseif kValue == 3 then
			kTable = giBufferA
		elseif kValue == 4 then
			kTable = giBufferB
		else 
			kTable = kPrevious
		endif
	xout kTable
endop

opcode SetTableName, 0, kS
	kTable, SChannel xin
	if kTable == giMicin1 then
		chnset "Acc Right", SChannel
	elseif kTable == giMicin2 then
		chnset "Acc Left", SChannel
	elseif kTable == giBufferA then
		chnset "TTS", SChannel
	elseif kTable == giBufferB then
		chnset "Enunciation", SChannel
	else 
		chnset "Other", SChannel
	endif
endop

opcode GetTableType, i, i
	// Returns 1 for Input Buffers, 2 for Sample Buffers, 0 for weird Tables!
	iTable xin
	if iTable == giMicin1 then
		iType = 1
	elseif iTable == giMicin2 then
		iType = 1
	elseif iTable == giMicin3 then
		iType = 1
	elseif iTable == giBufferA then
		iType = 2
	elseif iTable == giBufferB then
		iType = 2
	else 
		iType = 0
	endif
	xout iType
endop

opcode GetTableStartPos, i, ii
	iTable, iGrowth xin
	iType GetTableType iTable
	if iType == 2 then
		//The table will tend to start after 5 seconds as growth increases
		iLen nsamp iTable
		iVar = random:i(0, 1) * (1 - iGrowth) * iLen
		iStartPos = (5 * sr + iVar) % iLen
	else 
		iStartPos = 0
	endif
	xout iStartPos
endop

opcode GetSeedIndex, a, ii
	//returns the index for the table based on its type
	iTable, iGrowth xin
	iType GetTableType iTable
	iStartPos GetTableStartPos iTable, iGrowth
	if iType == 1 then
		aIdx chnget "bufferPosition"
	else 
		aIdx IdxAccum iTable 
	endif
	xout aIdx + iStartPos
endop

opcode ManageFunctionTables, kk, 0
	kFnValue1 chnget "buffer_1"
	kFnValue2 chnget "buffer_2"
	kTable1 init giMicin1
	kTable2 init giMicin2
	kTable1 GetTableFromValue kFnValue1, kTable1
	kTable2 GetTableFromValue kFnValue2, kTable2
	SetTableName(kTable1, "buff_1_name")
	SetTableName(kTable2, "buff_2_name")
	
	xout kTable1, kTable2
endop


instr Seed
/*
Main Instrument for Seed.  
Upon receiving an Attack Trigger, begins an event. 
Upon receiving an End Trigger, if the Event has culminated, begins the Event Decay. 
*/
	// INITIALIZATION
	Sactivate = strget(p4)
	iInit = 0
	if iInit == 0 then
		SetAttr "globalEnv", 1
		iInit = 1
	endif
 	kGrowthMod chnget "growth"
 	kBaseGrowth line 0, 150, 1
 	kBaseGrowth += kGrowthMod
 	kGrowth limit kBaseGrowth, 0, 1
 	SetAttr "growth", kGrowth
 	SendSampleData()
 	//Read Events
 	kPlayEvent GetAttr "eventPlay"
 	kEndEvent GetAttr "eventEnd"
 	kPaused init 0
	kTrig changed kPlayEvent, kEndEvent, kPaused
   if kTrig == 1 then
   	if kPaused == 0 then
   		if kPlayEvent == 1 then
   			kPlayEvent = 0
   			schedulek "SeedPlay", 0, 360, strget(p4)
   		endif
   		if kEndEvent == 1 then
   			kEndEvent = 0
   			schedulek "SeedEnd", 0, 5, strget(p4)
   			turnoff
   		endif
   	endif
   endif
  	aEnv = ReactiveEnvelope(giMicin1, giMicin2)
	SetAttr "reactiveEnv", aEnv
endin

instr SeedPlay
/*
Uses the combination of above opcodes to play the events
*/
	Sactivate = strget(p4)
	kRhythm = SeedRhythmicEnvelope()
	kTable1, kTable2 = ManageFunctionTables()
	kGrowth chnget "growth"
	if kRhythm == 1 then
		kDur = random:k(1, 4 - kGrowth) 
		schedulek "SingleSeed", 0, kDur, strget(p4), 0, kTable1, kTable2, kGrowth
	endif
	
	//Calculate Ending
	kEnd GetAttr "eventEnd"
	if kEnd == 1 && kRhythm == 1 then
		schedulek "SingleSeed", 0, 2, strget(p4), 1, kTable1, kTable2, kGrowth
		turnoff
	endif
endin

instr SingleSeed
	// Init
	iTable1 = p6
	iTable2 = p7
	iGrowth = p8
	iEndAzim = (1 - (0.8 * iGrowth)) * random:i(-90, 90)
	iStartAzim = random:i(90, 180) * signum(iEndAzim)
	Sactivate = strget(p4)
	kMin init 0.01
	kPeriod init 0.001
	
	//Get Table Data
	aIdx1 GetSeedIndex iTable1, iGrowth
	aIdx2 GetSeedIndex iTable2, iGrowth

	//Get Values
	kMin GetAttr "minSize"
	kPeriod GetAttr "period"
	kWidth GetAttr "pendulumWidth"
	iVariability = 4 - 3.3 * iGrowth
	
	// Get Morphed Audio
	if p5 == 1 then
		kPeriod = 0.0001
	endif
	aMorphed PingPongFFTGranulator iTable1, iTable2, k(iVariability), aIdx1, aIdx2, kMin, kPeriod, kWidth

	// Calculate Env
	aREnv GetAttr "reactiveEnv"
	kGlobalEnv GetAttr "globalEnv"
	kGlobalEnv port kGlobalEnv, 0.1
	kEnv = linen:k(kGlobalEnv, 0.45, p3, 0.5)
	aEnv = aREnv * kEnv
	
	kGlobalDB GetAttr "global_db"
	kGlobalDB port kGlobalDB, 0.1
	kAmp ampdb kGlobalDB
	aOut = aMorphed * aEnv * kAmp
	
	kAzim = line:k(iStartAzim, p3, iEndAzim)
	aSpacialized[] vbap aOut, kAzim
	
	OutArray(aSpacialized)
endin

instr SeedEnd
	Sactivate = strget(p4)
	kEnv = expon(1, p3, 0.00001) - 0.00001
	SetAttr "globalEnv", kEnv
endin


///////////////////////////////////////////////////////////////////////
////////////////////////////////// croak //////////////////////////////
//////////////////////////////////////////////////////////////////////

chn_k "croak.growth", 3
chn_k "croak.pitchScale", 3
chn_k "croak.waveSpeed", 3
chn_k "croak.clickSpeed", 3
chn_k "croak.clickFreq", 3
chn_k "croak.clickQ", 3
chn_k "croak.lowpassCutoff", 3
chn_k "croak.delayAlter", 3
chn_k "croak.paused", 3

instr CroakInit
	prints "Initializing Class %s\n", strget(p4)
	SetAttr "growth", 1
	SetAttr "pitchScale", 0.3
	SetAttr "paused", 0
	SetAttr "waveSpeed", 0.8
	SetAttr "clickFreq", 25
	SetAttr "clickQ", 10
	SetAttr "clickSpeed", 0.2
endin

gkPeakPossible init 1
opcode CroakRhythmicEnvelope, k, 0
	/*
	Creates rhythms for each Click.
	As Growth.k gets larger, the rhythms are more varied and random.
	Outputs 1 whenever an event should happen
	*/
	// TODO TODO TODO TODO //
	iHalfLife = 4
	iMinPeak = -24
	kPeakDB init -50
	audioIn ReadBuffer giMicin1, 0
	kAmp = rms:k(audioIn)
	kDB dbamp kAmp
	kDB += gkCroakEnvBaseDB
	kMinFreq init 0.2
	kMaxFreq init 0.7
	
	if kDB >= (kPeakDB + 12) && kDB > iMinPeak then
		//printks "New Peak Reached: %f\n", 0, kDB
		kPeakDB = kDB
		gkPeakPossible = 0
		schedulek "PeakCountdown", 1, 1
	endif
	if gkPeakPossible == 0 then
		kMinFreq = limit(kMinFreq + (12/(kr)), 0.3, 3)
		kMaxFreq = limit(kMaxFreq + (8/(kr)), 0.8, 5)
	else 
		kMinFreq = limit(kMinFreq - (5/(iHalfLife * kr)), 0.3, 3)
		kMaxFreq = limit(kMaxFreq - (3/(iHalfLife * kr)), 0.8, 5)
	endif
	kFreqFreq = random:k(0.8, 2)
	kFreq = randomi:k(kMinFreq, kMaxFreq, kFreqFreq, 2)
	kFreqFactor GetAttr "clickSpeed"
	kPlay = metro:k(kFreq * kFreqFactor)
	kPaused GetAttr "paused"
	if kPaused == 1 then
		kPlay = 0
	endif
	kPeakDB = limit(kPeakDB + (-8/(iHalfLife * kr)), -90, 1)
	xout kPlay
endop

instr PeakCountdown
	gkPeakPossible init 1
	turnoff
endin

opcode LowPassFilter, a, ak
	aIn, kFilterFreq xin
	aFiltered butlp aIn, kFilterFreq	
	xout aFiltered
endop

opcode LowPassFilter, a[], a[]k
	aIn[], kFilterFreq xin
	aFiltered[] init 4
	
	aFiltered[0] butlp aIn[0], kFilterFreq
	aFiltered[1] butlp aIn[1], kFilterFreq
	aFiltered[2] butlp aIn[2], kFilterFreq
	aFiltered[3] butlp aIn[3], kFilterFreq
	
	xout aFiltered
endop

opcode Scaling, a, ak
	aIn, kPitchScale xin
	fIn pvsanal aIn, gifftsize, gioverlap, gifftsize, giwintype
	fScaled pvscale fIn, kPitchScale
	aScaled pvsynth fScaled
	xout aScaled
endop

opcode GetDelay, k, i
	initDelay xin
	kDelayAlter GetAttr "delayAlter"
	iMaxDelay = initDelay
	iMinDelay = iMaxDelay - (2 * initDelay / ginBufferSize)
	iStepSize = (iMaxDelay - iMinDelay) / 3
	xout initDelay + (iStepSize * kDelayAlter)
endop

opcode GetCutoff, k, a
	aIn xin
	kAmp rms aIn 
	kDB dbamp kAmp
	kCutoff = scale(kDB, 600, 300, 0, -60)
	kCutoff limit kCutoff, 200, 600
	xout kCutoff
endop

opcode SetClickQuality, 0, 0
	aIn1 ReadBuffer giMicin1, 0
	aIn2 ReadBuffer giMicin2, 0
	aIns = aIn1 + aIn2
	kAmp rms aIns
	kDB dbamp kAmp
	kDB += gkCroakQBaseDB
	kQ scale kDB, 10, 20, -30, 0
	kQ limit kQ, 5, 30
	SetAttr "clickQ", kQ
endop

instr Croak
	/*
	Main Instrument for Croak.  
	Produces low frequency sounds and percussive impulses.
	*/
	// INITIALIZATION
	//Generate Audio Buffer
	schedule "Mic", 0, 999
	SActive sprintf "Class %s\n Initialized", strget(p4)
	
	kGrowth = line:k(0, 120, 1)
	SetAttr "growth", kGrowth
	kClickSpeed GetAttr "waveSpeed"
	kClickFreq = 2 * kClickSpeed + poscil:k(kClickSpeed, 0.4) 
	if kClickFreq == 0 then
		kClickFreq = 0.2
	endif
	kTrig = metro:k(kClickFreq)
	kPhase init 1
	if kTrig == 1 then
		kMinDur = min(0.5, 1/kClickSpeed)
		schedulek "LowWave", 0.01, random:k(kMinDur, 2/kClickSpeed), "croak", 1, giMicin1, kGrowth * 60
		schedulek "LowWave", 0.01, random:k(kMinDur, 2/kClickSpeed), "croak", 1, giMicin2, kGrowth * -60
	endif 	
	
	kRhythm init 0
	kDelayAlter init 0
	kRhythm = CroakRhythmicEnvelope()
	if kRhythm == 1 then
		kDelayAlter += 1
		schedulek "Click", 0, 1, "croak"
		if random:k(kDelayAlter, 4) >= 3 then
			kDelayAlter = 0
		endif
		kRhythm = 0
	endif
	SetAttr "delayAlter", kDelayAlter
	SetClickQuality()
endin

instr LowWave
	/*
	p5 = env type
	p6 = buffer
	p7 = delay
	p8 = azim
	*/
	Sactivate = strget(p4)
	kAzim init p8
	kDelay = GetDelay(p7)
	aRead ReadBuffer p6, kDelay
	iScale GetAttr "pitchScale"
	aOut Scaling aRead, k(iScale)
	kCutoff GetCutoff aRead
	aFiltered LowPassFilter aOut, 300
	if p5 == 0 then
		aEnv = linen:a(1, p3*0.4, p3, p3*0.4)
	else
		aEnv = transeg:a(0, p3*0.3, -6, 0.2, 0.1, 9, 1, (p3*0.7)-0.1, 2, 0)
	endif
	kdB GetAttr "global_dB"
	kdB port kdB, 0.1
	kdB += 8
	kAmp ampdb kdB
	aOut = aFiltered * aEnv * 4 * kAmp
	aOuts[] vbap aOut, kAzim, 0, 10
	aOutRev[] init 4
	aOutRev[2], aOutRev[3] freeverb aOuts[0], aOuts[1], 0.6, 1
	OutArray aOuts
	OutArray aOutRev
	//chnmix aRevL, "EOut2"
	//chnmix aRevR, "EOut3"
endin

instr Click
	Sactivate = strget(p4)
	iFreq GetAttr "clickFreq"
	iQuality GetAttr "clickQ"
	iGrowth chnget "growth"
	kdB GetAttr "global_dB"
	kdB port kdB, 0.1
	kdB -= 20
	kAmp ampdb kdB
	aImp = mpulse:a(1, p3)
	aFilt1 = mode:a(aImp, iFreq * random:i(7/8, 8/7), random:i(iQuality * 1.5, iQuality * 1.8))
	aFilt2 = mode:a(aImp, iFreq * random:i(9/10, 10/9), random:i(iQuality * 1.2, iQuality * 1.4)			)
	aFilt3 = mode:a(aImp * 0.5, iFreq * random:i(11/13, 13/11), random:i(iQuality * 1.3, iQuality * 1.5))
	
	iAzim = random:i(0, (360 - iGrowth * 360)) + 180
	aOut = kAmp * (aFilt1 + aFilt2 + aFilt3)
	kAmp rms aOut
	//printk 0.1, kAmp
	aOuts[] vbap aOut, k(iAzim)
	OutArray aOuts
endin


///////////////////////////////////////////////////////////////////////
////////////////////////////////// push //////////////////////////////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////
/////////// Attributes //////////////////
/////////////////////////////////////////
gkEndRelease init 0
gkEndAttack init 0

//Chord Parameters
chn_k "push.masterbpFreq", 3
chn_k "push.bpFreq", 3
chn_k "push.bpWidth", 3
chn_k "push.morphValue", 3
chn_k "push.global_db", 3
chn_k "push.distortValue", 3
chn_k "push.mirror_db", 3

//Env Parameters
chn_k "push.impulseEnv", 3 
chn_k "push.endAttack", 3 
chn_k "push.endRelease", 3 

chn_k "push.outdb", 2

//Form Parameters
chn_k "push.endpush", 3 
chn_k "push.growth", 2

instr PushInit
	prints "Initializing Class %s\n", strget(p4)
	SetAttr "masterbpFreq", 50
	SetAttr "bpFreq", 50
	SetAttr "bpWidth", 1
	SetAttr "morphValue", 0
	SetAttr "distortValue", 0
	SetAttr "impulseEnv", 1
	SetAttr "endpush", 0
endin

// Tables and Globals
giPushFileSize filelen gSPushChordA


//////////////////////////////////////////
/////////// FUNCTIONS ////////////////////
//////////////////////////////////////////


opcode Morphing, a, aak
	//Morphs two signals using pvsmorph
	aSignal1, aSignal2, kMorph xin
	
	fSig1 pvsanal aSignal1, gifftsize, gioverlap, gifftsize, giwintype
	fSig2 pvsanal aSignal2, gifftsize, gioverlap, gifftsize, giwintype
 	fMorphed pvsmorph fSig1, fSig2, kMorph, kMorph
  	fSmoothed pvsmooth fMorphed, 0.2, 0.2 // we add a bit of smoothing to reduce artifacts
	
	aMorphed pvsynth fSmoothed
	xout aMorphed
endop

opcode Morphing2, a[], a[]a[]k
	//Morphs two audio arrays using pvsmorph
	aSignal1[], aSignal2[], kMorph xin
	aMorphed[] init 2
	aMorphed[0] Morphing aSignal1[0], aSignal2[0], kMorph
	aMorphed[1] Morphing aSignal1[1], aSignal2[1], kMorph
	
	xout aMorphed
endop

opcode InvertDB, k, k
	kInDB xin
	kA = -1/2
	kB = gkPushUpperDBLimit - kA * gkPushLowerDBLimit
	kOutDB = kA * kInDB + kB 
	kOutDB port kOutDB, 0.3
	xout kOutDB
endop

opcode BandFilter2, a[], a[]kk
	aIn[], kFilterFreq, kFilterWidth xin
	aFiltered[] init 2
	aFilteredL[] init 3
	aFilteredR[] init 3
	
	kFilterFreqA = kFilterFreq
	kFilterWidthA = kFilterFreqA / (3 * kFilterWidth)
	aFilteredL[0] butbp aIn[0], kFilterFreqA, kFilterWidthA
	aFilteredR[0] butbp aIn[1], kFilterFreqA, kFilterWidthA
	
	kFilterFreqB = kFilterFreq * 7.5
	kFilterWidthB = kFilterFreqB / (5 * kFilterWidth)
	aFilteredL[1] butbp aIn[0], kFilterFreqB, kFilterWidthB
	aFilteredR[1] butbp aIn[1], kFilterFreqB, kFilterWidthB
	
	kFilterFreqC = kFilterFreq * 61
	kFilterWidthC = kFilterFreqC / (7 * kFilterWidth)
	aFilteredL[2] butbp aIn[0], kFilterFreqC, kFilterWidthC
	aFilteredR[2] butbp aIn[1], kFilterFreqC, kFilterWidthC

	aFiltered[0] sum aFilteredL[0], aFilteredL[1], aFilteredL[2]
	aFiltered[1] sum aFilteredR[0], aFilteredR[1], aFilteredR[2]
	xout aFiltered
endop

opcode PushSpacialize, a[], a[]k
	aOutStereo[], kGrowth xin
	kSpread = pow(kGrowth, 2) * 80
	aOutL[] vbap aOutStereo[0], 155, 0, kSpread 
	aOutR[] vbap aOutStereo[1], -155, 0, kSpread 
	aOut[] = aOutL + aOutR
	xout aOut
endop

opcode GetAttack, k, ikk
	iReverse, kOutDB, kInDB xin
	
	//if we detect a change, we want a bit of a cooldown before another can be made
	//this should make the program a bit more robust
	kChanged init 0
	kChanged = limit(kChanged - (3/kr), 0, 1)
	if kChanged <= 0.01 then
		if iReverse == 0 then
			// attacks when Accordeon is silent
			if kOutDB > (kInDB + gkPushResponseLevel) then
				kSwitch = 1
				kChanged = 1
			elseif kOutDB < kInDB then
				kChanged = 1
				kSwitch = 0
			endif
		else
			// attacks together with accordeon
			if kInDB - 6 > gkPushLowerDBLimit then
				kSwitch = 1
				kChanged = 1
			else
				kSwitch = 0
				kChanged = 1
			endif
		endif
	endif
	xout kSwitch
endop

opcode ReadBuffer2, a, ii
	iTable1, iTable2 xin
	aIn1 ReadBuffer iTable1, 0
	aIn2 ReadBuffer iTable2, 0
	aOut = aIn1 + aIn2
	xout aOut
endop


instr Push
	Sactivate = strget(p4)
	chnset k(1), "push_active"
	iReverse = p5 // If reverse == 1, then the out dB are not inverted
	kSwitch init 0 //When 1, trigger an attack, when 0 trigger a release.
	// Get data from channels
	if gkTesting == 0 then
		aIn ReadBuffer2 giMicin1, giMicin2
	else
		aIn ReadBuffer2 giTestBuffer, giTestBuffer
	endif
	kMasterFilterFreq GetAttr "masterbpFreq"
	kFilterWidth GetAttr "bpWidth"
	kTurnoff GetAttr "endpush"
	kGrowthMod chnget "growth"
 	kBaseGrowth line 0, 120, 1
 	kBaseGrowth += kGrowthMod
 	kGrowth limit kBaseGrowth, 0, 1
 	SetAttr "growth", kGrowth
	// Get amp of audio in
	kInAmp rms aIn
  	kInDB dbamp kInAmp
  	kInDB += gkPushEnvDetecionFactor
  	// Calculate the Amp of the tone
  	if iReverse == 1 then
  		kOutDB = kInDB
  		kAmp ampdb kOutDB
  	else
  		kInDB dbamp kInAmp
  		kOutDB InvertDB kInDB		
		kAmp ampdb kOutDB
	endif
	kOutDB limit kOutDB, -120, -3
	SetAttr "mirror_db", kOutDB
	chnset kInDB, "push_indb"
	chnset kOutDB, "push_outdb"
	kAmp limit kAmp, 0, 1
	kSwitch GetAttack iReverse, kOutDB, kInDB
	//Triggers for Attack
	kTrigger changed2 kSwitch
	if kTrigger == 1 then
		//printf "in: %f, Out %f\n", kAmp, kInAmp, kAmp
		gkEndRelease = 1
		gkEndAttack = 1
		kStart GetAttr "impulseEnv"
		if kSwitch == 1 then
			schedulek "Attack", 1/kr, 0.8, "push", kStart, kTurnoff, iReverse
			SetAttr "bpFreq", kMasterFilterFreq
			if kTurnoff == 1 then
				chnset k(0), "push_active"
				SetAttr "endpush", 0
				turnoff
			endif
		elseif kSwitch == 0 then
			schedulek "Release", 1/kr, 1, "push", kStart
		endif
	endif
	  	
	//We call the instrument that plays the chord
	iDur = 6
	kTrig = metro(2 / iDur)
	if kTrig == 1 then
		//kBaseStart = kGrowth * giPushFileSize * 0
		//kStart = random:k(kBaseStart-3, kBaseStart+3)
		//kStart limit kStart, 0, 2* giPushFileSize / 3
		kStart = random:k(0, 10)
		schedulek "ChordFrag", 0, iDur, "push", kStart
	endif
endin

instr ChordFrag
	iStart = p5
	Sactivate = strget(p4)
	kFilterFreq GetAttr "bpFreq"
	kFilterWidth GetAttr "bpWidth"
	kMorphFactor GetAttr "morphValue"
	kGrowth GetAttr "growth"
	kMirrorDB GetAttr "mirror_db"
	kMorphAmount = kGrowth + (kMorphFactor * 0.3)
	kMorphAmount limit kMorphAmount, 0, 1
	// Load the chord and output the result multiplied by the amplification and envelope
	aChordA[] diskin gSPushChordA, 1, iStart, 0
	aChordB[] diskin gSPushChordB, 1, iStart, 0
	aMorphed[] Morphing2 aChordA, aChordB, kMorphAmount
	aFiltered[] BandFilter2 aMorphed, kFilterFreq, kFilterWidth
	kImpulseEnv GetAttr "impulseEnv"
	kMasterDB GetAttr "global_db"
	kMasterDB += kMirrorDB 
	kMasterDB port kMasterDB, 0.05
	kAmp ampdb kMasterDB
	kEnv transeg 0, p3/2, -2, 1, p3/2, 2, 0
	aOut[] = aFiltered * kEnv * kImpulseEnv * kAmp
	aOut4[] PushSpacialize aOut, kGrowth
	OutArray aOut4
endin

instr Attack
	/*
	p6 = turnoff?
	p7 = reverse?
	*/
	gkEndAttack init 0
	gkEndRelease init 0
	iStart = p5
	if p6 == 0 then
		iAttack = 0.1
		iDecay = p3 - iAttack
		kAttackEnv = transeg:k(iStart, iAttack, -1.5, 1.4, iDecay, 2, 0.8)
		
	elseif p6 == 1 then
		kAttackEnv = transeg:k(iStart, p3, 2, 0)
		if p7 == 0 then
			schedule "TTS", 0.2, 1, "push"
		endif
	endif
	SetAttr "impulseEnv", kAttackEnv
	if gkEndAttack == 1 then
		turnoff 
	endif

endin

instr Release
	gkEndAttack init 0
	gkEndRelease init 0
	iStart = p5
	kReleaseEnv = transeg:k(iStart, p3, 2, 0)
	SetAttr "impulseEnv", kReleaseEnv
	if gkEndRelease == 1 then
		turnoff 
	endif
endin

instr TTS
	Sactivate = strget(p4)
	p3 = filelen(gSFileA)
	aIdx = line:a(0, p3, 1)
	aOut table3, aIdx, giBufferA, 1, 0, 0
	kDB GetAttr "global_db"
	kMasterDB chnget "masterdB"
	kDB += kMasterDB
	kAmp ampdb kDB
	outall aOut * kAmp * 0.1
endin


//////////////////////////////////////////////////////////////////////////////
////////////////////////////////// Master Mic and Record /////////////////////
/////////////////////////////////////////////////////////////////////////////
opcode Effects, a, a
	// Do we want to add some reverb or something?
	aIn xin

	xout aIn
endop

opcode SReverb, aa, aa
	aInL, aInR xin
	kRevSize chnget "reverbSize"
	kRevHC chnget "reverbHC"
	
	aRevL, aRevR reverbsc aInL, aInR, kRevSize, kRevHC
	
	xout aInL + aRevL, aInR + aRevR
endop
	
instr Master
	kMasterDB chnget "masterdB"
	kMasterDB port kMasterDB, 0.1
	kMasterAmp ampdb kMasterDB
	aOut1 chnget "EOut1"
	aOut2 chnget "EOut2"
	aOut3 chnget "EOut3"
	aOut4 chnget "EOut4"
	
	aOut1 Effects aOut1
	aOut2 Effects aOut2
	aOut3 Effects aOut3
	aOut4 Effects aOut4
	
	aOut1, aOut2 SReverb aOut1, aOut2
	aOut3, aOut4 SReverb aOut3, aOut4

	aOut1 *= kMasterAmp
	aOut2 *= kMasterAmp
	aOut3 *= kMasterAmp
	aOut4 *= kMasterAmp
	
	if nchnls >= 4 then
		out aOut1, aOut2, aOut3, aOut4
	else
		out aOut1 + aOut4, aOut2 + aOut3
	endif
	chnclear "EOut1"
	chnclear "EOut2"
	chnclear "EOut3"
	chnclear "EOut4"
endin

instr Mic
	//Generate Audio Buffer
	aIdx IdxAccum giMicin1
	chnset aIdx, "bufferPosition"
	if ginChannel1 == 0 || ginChannel2 == 0 || ginChannel3 == 0 then
		aInTest[] diskin gSTestSample, 1, 0, 1
	else 
		aInTest[] init 3
	endif
	
	if ginChannel1 == 0 then
		aIn1 = aInTest[0]
	else 
		aIn1 inch ginChannel1
	endif
	if ginChannel2 == 0 then
		aIn2 = aInTest[1]
	else 
		aIn2 inch ginChannel2
	endif
	if ginChannel3 == 0 then
		aIn3 = aInTest[2]
	else 
		aIn3 inch ginChannel3
	endif
	kGlobalGaindB chnget "global_in_gain"
	kGlobalAmp ampdb kGlobalGaindB
	aIn1 *= kGlobalAmp
	aIn2 *= kGlobalAmp
	aIn3 *= kGlobalAmp
	if giPlayback == 1 then
		SendAll aIn3
		SendAll aIn1
		SendAll aIn2
	endif
	
	// Load into Buffer
	
 	tablew aIn1, aIdx, giMicin1, 0, 0, 1
 	tablew aIn2, aIdx, giMicin2, 0, 0, 1
 	tablew aIn3, aIdx, giMicin3, 0, 0, 1

 	kTrigDisp metro 10
 	CsQtMeter "in1", "in1_over", aIn1, kTrigDisp
 	CsQtMeter "in2", "in2_over", aIn2, kTrigDisp
 	CsQtMeter "in3", "in3_over", aIn3, kTrigDisp
endin

instr Testing
	SendSampleData()
	kNoiseDB chnget "test_noise_db"
	kNoiseAmp ampdb kNoiseDB
	aNoise = pinkish:a(kNoiseAmp)
	aIdx chnget "bufferPosition"
	tablew aNoise, aIdx, giTestBuffer, 0, 0, 1
	
	SendAll aNoise

endin


// Monitor + Record
opcode GenFileName, S, 0
	itim date 
	Stim dates itim
	Syear strsub Stim, 20, 24
	Smonth strsub Stim, 4, 7
	Sday strsub Stim, 8, 10
	iday strtod Sday
	Shor strsub Stim, 11, 13
	Smin strsub Stim, 14, 16
	Ssec strsub Stim, 17, 19
	Soutfile sprintf "testRecordings/Chassis_%s%s%02d__%s_%s_%s.wav", Syear, Smonth, iday, Shor, Smin, Ssec
	xout Soutfile
endop

instr Recorder
	//GNU Terry Pratchet
	aOut[] init 7
	aElekOuts[] monitor

	kTrigDisp metro 10
	CsQtMeter "out1", "out1_over", aElekOuts[0], kTrigDisp
	CsQtMeter "out2", "out2_over", aElekOuts[1], kTrigDisp
	if nchnls > 2 then
		CsQtMeter "out3", "out3_over", aElekOuts[2], kTrigDisp
		CsQtMeter "out4", "out4_over", aElekOuts[3], kTrigDisp
	endif
	
	if giRecord == 1 then
		aAccL ReadBuffer giMicin1, 0
		aAccR ReadBuffer giMicin2, 0
		aVoice ReadBuffer giMicin3, 0
		aOut[0] = aElekOuts[0]
		aOut[1] = aElekOuts[1]
		aOut[2] = aElekOuts[2]
		aOut[3] = aElekOuts[3]
		aOut[4] = aAccL
		aOut[5] = aAccR
		aOut[6] = aVoice
		fout(GenFileName(), 18, aOut)
	endif
endin

</CsInstruments>
<CsScore>
i "Chassis" 0 1600
</CsScore>
</CsoundSynthesizer>






























































<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>164</x>
 <y>184</y>
 <width>1680</width>
 <height>800</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>324</y>
  <width>868</width>
  <height>400</height>
  <uuid>{7146e953-9f0d-4545-8da6-7c9573c00972}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Seed</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>391</x>
  <y>5</y>
  <width>483</width>
  <height>319</height>
  <uuid>{333c672c-6d4f-44e6-b501-2c1ad4ffc414}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Croak</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>127</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>6</y>
  <width>384</width>
  <height>319</height>
  <uuid>{ef812f3f-8c85-44c9-ab5b-020dfd563ebc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Mirror</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>131</r>
   <g>247</g>
   <b>224</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>889</x>
  <y>285</y>
  <width>163</width>
  <height>373</height>
  <uuid>{953560e5-e353-4983-8511-0523c9244a54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>MeterBackground</description>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>192</r>
   <g>184</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out1</objectName>
  <x>934</x>
  <y>312</y>
  <width>24</width>
  <height>122</height>
  <uuid>{f8582227-bbb6-431f-a433-33ed267d1d67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.72461038</xValue>
  <yValue>0.72461038</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out1_over</objectName>
  <x>934</x>
  <y>291</y>
  <width>24</width>
  <height>25</height>
  <uuid>{3d46619f-a663-483c-b62e-04fd2a51d003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out1_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>934</x>
  <y>433</y>
  <width>24</width>
  <height>28</height>
  <uuid>{49a414ae-3e95-4893-a8a4-a24a4a626f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out2</objectName>
  <x>961</x>
  <y>312</y>
  <width>24</width>
  <height>122</height>
  <uuid>{ef368113-1b9b-4021-ba3a-e8636e44bd63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.67856259</xValue>
  <yValue>0.67856259</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out2_over</objectName>
  <x>961</x>
  <y>291</y>
  <width>24</width>
  <height>25</height>
  <uuid>{2a7246d3-5730-495c-831f-43cb1541e26f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out2_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>961</x>
  <y>433</y>
  <width>24</width>
  <height>28</height>
  <uuid>{3c3fb42a-276e-47d7-9d2a-b960870e29b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out3</objectName>
  <x>989</x>
  <y>312</y>
  <width>24</width>
  <height>122</height>
  <uuid>{9df4b4e2-cf40-4544-a56c-a8c38cf9bb7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.68769166</xValue>
  <yValue>0.68769166</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out3_over</objectName>
  <x>989</x>
  <y>291</y>
  <width>24</width>
  <height>25</height>
  <uuid>{77caaed3-d8fb-463f-8703-bfcc3235ca17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out3_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>989</x>
  <y>433</y>
  <width>24</width>
  <height>28</height>
  <uuid>{85e5a582-8708-4d3c-a477-de431b2fc7bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1</objectName>
  <x>934</x>
  <y>498</y>
  <width>24</width>
  <height>122</height>
  <uuid>{17ee73f3-0724-4674-9be6-77e34decacc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.83502473</xValue>
  <yValue>0.83502473</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1_over</objectName>
  <x>934</x>
  <y>477</y>
  <width>24</width>
  <height>25</height>
  <uuid>{86262ec4-d95e-4f99-b457-3b27b73542ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>934</x>
  <y>619</y>
  <width>24</width>
  <height>28</height>
  <uuid>{05782c50-1317-49e4-8833-2789f049d988}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2</objectName>
  <x>961</x>
  <y>498</y>
  <width>24</width>
  <height>122</height>
  <uuid>{93eb0256-e128-4311-8c19-7a56db6d328a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.67174974</xValue>
  <yValue>0.67174974</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2_over</objectName>
  <x>961</x>
  <y>477</y>
  <width>24</width>
  <height>25</height>
  <uuid>{69dd83a3-2292-4df9-9261-2a9feb7fe6f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>961</x>
  <y>619</y>
  <width>24</width>
  <height>28</height>
  <uuid>{01554380-b115-4180-8226-f4f6f6dd8112}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in3</objectName>
  <x>989</x>
  <y>498</y>
  <width>24</width>
  <height>122</height>
  <uuid>{4f92760e-1392-4a19-82b0-585b1c32809f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.51290017</xValue>
  <yValue>0.51290017</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in3_over</objectName>
  <x>989</x>
  <y>477</y>
  <width>24</width>
  <height>25</height>
  <uuid>{53ec5e3c-70bb-48e6-9fb1-86ecd9fbc781}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in3_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>989</x>
  <y>619</y>
  <width>24</width>
  <height>28</height>
  <uuid>{e6331948-04cc-47a5-9ac3-a4a3dd2594d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>898</x>
  <y>434</y>
  <width>35</width>
  <height>28</height>
  <uuid>{0cfc1da0-dadf-4a21-82dc-2409a945e327}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Out</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>905</x>
  <y>618</y>
  <width>23</width>
  <height>29</height>
  <uuid>{3c83cc6a-2ecb-4dda-b0ae-04ab3cec1df6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>I</description>
  <label>In</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>881</x>
  <y>662</y>
  <width>172</width>
  <height>62</height>
  <uuid>{799e2e9c-68dd-469d-a648-778070582b19}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>push.masterbpFreq</objectName>
  <x>14</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{faa260f2-d0fd-489c-8653-57a2457a4996}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <description/>
  <minimum>50.00000000</minimum>
  <maximum>400.00000000</maximum>
  <value>151.96850394</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push.masterbpFreq</objectName>
  <x>43</x>
  <y>172</y>
  <width>52</width>
  <height>23</height>
  <uuid>{e237d7c1-6de5-44f8-91bf-6f82db8978e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>151.969</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>44</y>
  <width>51</width>
  <height>24</height>
  <uuid>{4be99e8f-e3c3-4e88-86ad-60b08a5108db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bp Freq</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>push.morphValue</objectName>
  <x>191</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{bdfbbd94-aecf-470d-a7d3-2ba209ab9d04}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33070866</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push.morphValue</objectName>
  <x>221</x>
  <y>172</y>
  <width>52</width>
  <height>23</height>
  <uuid>{badb21a3-e8bc-4c22-a168-c84add9d0bb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.331</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>188</x>
  <y>43</y>
  <width>69</width>
  <height>27</height>
  <uuid>{0f77138e-0ac2-46eb-844f-91d1d79311c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>morph Value</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>push.bpWidth</objectName>
  <x>103</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{ba8215ef-2be1-406d-aca5-251039fa005c}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <description/>
  <minimum>0.50000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.14960630</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push.bpWidth</objectName>
  <x>130</x>
  <y>172</y>
  <width>52</width>
  <height>23</height>
  <uuid>{c5294fb1-1c87-4e55-b18f-d1d4344db9e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.150</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>102</x>
  <y>44</y>
  <width>62</width>
  <height>24</height>
  <uuid>{c37d9984-097b-4e71-b573-4394392154dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bp bWidth</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>growth</objectName>
  <x>885</x>
  <y>49</y>
  <width>178</width>
  <height>31</height>
  <uuid>{4c23229d-7606-4b92-983c-43bae363030f}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <description/>
  <minimum>-0.50000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>growth</objectName>
  <x>998</x>
  <y>11</y>
  <width>65</width>
  <height>34</height>
  <uuid>{22cd6db5-66e5-40d1-828f-c013ce38d851}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>885</x>
  <y>12</y>
  <width>70</width>
  <height>32</height>
  <uuid>{a34bbb0c-e406-4e8e-841c-09d3326c3bc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Growth</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>masterdB</objectName>
  <x>884</x>
  <y>147</y>
  <width>183</width>
  <height>28</height>
  <uuid>{90da1c99-d46e-4b19-98a4-56a0fb253297}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>73</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>-3.77952756</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>masterdB</objectName>
  <x>995</x>
  <y>103</y>
  <width>71</width>
  <height>36</height>
  <uuid>{e23d3d1a-9e0e-4fee-8336-7c39ddca2475}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-3.780</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>884</x>
  <y>105</y>
  <width>85</width>
  <height>33</height>
  <uuid>{961b06f4-96c4-4964-aa3d-04df96eff057}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Master dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>push.global_db</objectName>
  <x>289</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{2142d170-ccb4-44ef-b6e2-fa0dda634259}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>70</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>24.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push.global_db</objectName>
  <x>320</x>
  <y>172</y>
  <width>52</width>
  <height>23</height>
  <uuid>{29c31b83-f7b8-4334-97bc-0eb440d6060c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>24.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>286</x>
  <y>43</y>
  <width>69</width>
  <height>27</height>
  <uuid>{0ed6b863-6676-479c-885b-7ffa6ce1b923}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>mirror dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>push_reverse</objectName>
  <x>99</x>
  <y>229</y>
  <width>20</width>
  <height>20</height>
  <uuid>{61f31b2b-2194-4401-b9dc-cb11ec81f4de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>19</x>
  <y>225</y>
  <width>80</width>
  <height>25</height>
  <uuid>{117c5912-6dfa-49e7-a729-4498638ff03f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Reverse Mirror:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>croak.pitchScale</objectName>
  <x>408</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{fe08b757-e389-4ff4-9317-fa9e76676563}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <description/>
  <minimum>0.05000000</minimum>
  <maximum>0.80000000</maximum>
  <value>0.26850394</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>croak.pitchScale</objectName>
  <x>444</x>
  <y>172</y>
  <width>47</width>
  <height>25</height>
  <uuid>{b36b6b57-7b8e-4d6c-a23f-becabe259231}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.269</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>croak.waveSpeed</objectName>
  <x>500</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{6bff2c80-6c31-4afa-a2c4-4264d83c9432}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.92283465</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>499</x>
  <y>41</y>
  <width>69</width>
  <height>24</height>
  <uuid>{ee0ce93b-a6b4-4751-8a2e-35554464902a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Wave Speed</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>croak.waveSpeed</objectName>
  <x>525</x>
  <y>172</y>
  <width>39</width>
  <height>25</height>
  <uuid>{aa5ee0a8-8578-4e01-a371-04ddd2f55e59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.923</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>croak.clickFreq</objectName>
  <x>587</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{99346cbd-7891-4cb2-9f40-dd3fdf5b5dbe}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>53.07086614</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>585</x>
  <y>41</y>
  <width>59</width>
  <height>25</height>
  <uuid>{a7c6d33f-40f0-4ed1-8a90-fb9ee7bbed1d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Click Freq</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>croak.clickFreq</objectName>
  <x>613</x>
  <y>172</y>
  <width>47</width>
  <height>25</height>
  <uuid>{20eb8526-5a5c-4379-beb1-7ad4be927ce9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>53.071</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>croak.clickSpeed</objectName>
  <x>680</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{a93787ec-b25a-4e08-97be-3ac2c2c96fa8}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>5</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.31023622</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>679</x>
  <y>37</y>
  <width>57</width>
  <height>33</height>
  <uuid>{807e5a5b-44ee-4349-8fea-7ee29331ed7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Click Freq Factor</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>croak.clickSpeed</objectName>
  <x>707</x>
  <y>172</y>
  <width>45</width>
  <height>24</height>
  <uuid>{e08b440e-ea54-42f5-9583-a6af96f4e2a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.310</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>407</x>
  <y>41</y>
  <width>62</width>
  <height>25</height>
  <uuid>{7bbebb34-6ba4-47ff-bf45-418c9e7b824a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>pitch Scale</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>croak.global_dB</objectName>
  <x>771</x>
  <y>70</y>
  <width>25</width>
  <height>125</height>
  <uuid>{9a89ebbc-8024-40c9-b3a6-75522da2d419}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>72</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>6.80314961</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>croak.global_dB</objectName>
  <x>797</x>
  <y>172</y>
  <width>52</width>
  <height>23</height>
  <uuid>{18bc329c-259b-4993-ab66-c6c77f9f288b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>6.803</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>768</x>
  <y>41</y>
  <width>69</width>
  <height>27</height>
  <uuid>{294b0e9d-0f15-4ad0-9649-0d37d21434b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>croak dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seed.eventPause</objectName>
  <x>45</x>
  <y>380</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4437de1c-cb4b-4ed4-bc75-e0c10a135624}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Seed-Pause</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seed.eventPlay</objectName>
  <x>168</x>
  <y>380</y>
  <width>100</width>
  <height>30</height>
  <uuid>{5256f1c5-1c42-4268-a199-9a35bebf101e}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>65</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Seed-Play</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seed.eventEnd</objectName>
  <x>290</x>
  <y>379</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f11a96c7-8f36-4181-bd17-9ad87d259e41}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>66</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Seed-End</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>seed.pendulumWidth</objectName>
  <x>57</x>
  <y>452</y>
  <width>25</width>
  <height>125</height>
  <uuid>{12a3dd0a-c7dd-416f-8f39-3c4f24c40bde}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.29133858</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>seed.pendulumWidth</objectName>
  <x>82</x>
  <y>555</y>
  <width>52</width>
  <height>23</height>
  <uuid>{2953eba9-665e-4c08-b2e9-7d308dbde0c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.291</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>51</x>
  <y>419</y>
  <width>62</width>
  <height>32</height>
  <uuid>{c4bfecd5-b633-48aa-9cb9-acc752bfade3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Pendulum Width</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>seed.period</objectName>
  <x>229</x>
  <y>453</y>
  <width>25</width>
  <height>125</height>
  <uuid>{89712097-6156-49ed-a3e0-6f79954970b5}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <description/>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33077559</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>seed.period</objectName>
  <x>260</x>
  <y>555</y>
  <width>52</width>
  <height>23</height>
  <uuid>{61b3ac90-a02b-4504-8c21-fe1a69e2bba2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.331</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>229</x>
  <y>425</y>
  <width>66</width>
  <height>23</height>
  <uuid>{ede88f52-249f-4aea-8acf-03dfd4e1246f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Max Period</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>seed.minSize</objectName>
  <x>142</x>
  <y>453</y>
  <width>25</width>
  <height>125</height>
  <uuid>{b2e9ca5b-d7c9-414c-bcf8-40d91b9952a9}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <description/>
  <minimum>0.00500000</minimum>
  <maximum>1.50000000</maximum>
  <value>0.65244094</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>seed.minSize</objectName>
  <x>169</x>
  <y>554</y>
  <width>52</width>
  <height>23</height>
  <uuid>{ab77a567-d585-471d-93b9-0a724e97de53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.652</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>142</x>
  <y>418</y>
  <width>65</width>
  <height>33</height>
  <uuid>{c912fac7-7b57-4c73-a485-de2b986cd5d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Min Grain Size</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>seed.global_db</objectName>
  <x>327</x>
  <y>454</y>
  <width>25</width>
  <height>125</height>
  <uuid>{59d85aae-5355-404c-b980-799258d47915}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>71</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>11.43307087</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>seed.global_db</objectName>
  <x>359</x>
  <y>555</y>
  <width>52</width>
  <height>23</height>
  <uuid>{1c8e2cd7-678c-4003-b72b-96407c7adcc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>11.433</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>327</x>
  <y>426</y>
  <width>53</width>
  <height>23</height>
  <uuid>{05fe845d-d6b5-4343-80d3-8f76a3d52b72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>seed dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seed_status</objectName>
  <x>22</x>
  <y>609</y>
  <width>87</width>
  <height>46</height>
  <uuid>{cfb5f879-9051-48d0-a73e-b9243f182b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>START</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seed_status</objectName>
  <x>115</x>
  <y>607</y>
  <width>89</width>
  <height>47</height>
  <uuid>{b9c961a0-72b5-41bd-bdb7-bb11bf02d5ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>END</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>mirror_status</objectName>
  <x>17</x>
  <y>266</y>
  <width>87</width>
  <height>46</height>
  <uuid>{e6173983-a23b-4ba3-bca7-d91bb80f3301}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>START</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>mirror_status</objectName>
  <x>110</x>
  <y>266</y>
  <width>89</width>
  <height>47</height>
  <uuid>{47af04c8-a175-463d-a93c-c1e537353fe9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>END</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>croak_status</objectName>
  <x>410</x>
  <y>267</y>
  <width>87</width>
  <height>46</height>
  <uuid>{13ef2202-6ea3-409a-bb9f-0bf4341945fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>START</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>croak_status</objectName>
  <x>503</x>
  <y>267</y>
  <width>89</width>
  <height>47</height>
  <uuid>{1b87ec24-3b6c-4c1f-b445-8371d42095f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>END</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>449</x>
  <y>350</y>
  <width>96</width>
  <height>35</height>
  <uuid>{d2b221be-8bc8-4229-98d5-5b9b3b948678}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Buffer 1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>449</x>
  <y>474</y>
  <width>96</width>
  <height>35</height>
  <uuid>{d0a1dccc-0c87-4d3f-8913-8d0b2b01fcd8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Buffer 2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_1</objectName>
  <x>449</x>
  <y>401</y>
  <width>60</width>
  <height>50</height>
  <uuid>{d3131559-e100-4fda-8464-f2908c7029c5}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>40</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>In 1</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_1</objectName>
  <x>513</x>
  <y>402</y>
  <width>60</width>
  <height>50</height>
  <uuid>{8478ed45-851d-4833-a8aa-2679ca6bcfdb}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>41</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>In 2</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_1</objectName>
  <x>575</x>
  <y>401</y>
  <width>71</width>
  <height>51</height>
  <uuid>{d5374c9d-aae8-4535-83ba-280c1b1d5e1f}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>42</midicc>
  <description/>
  <type>value</type>
  <pressedValue>3.00000000</pressedValue>
  <stringvalue/>
  <text>S 1</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_1</objectName>
  <x>649</x>
  <y>401</y>
  <width>70</width>
  <height>51</height>
  <uuid>{010cea37-6936-4eb5-8ac1-51b4a87ca2c3}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>43</midicc>
  <description/>
  <type>value</type>
  <pressedValue>4.00000000</pressedValue>
  <stringvalue/>
  <text>S 2</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_2</objectName>
  <x>449</x>
  <y>526</y>
  <width>60</width>
  <height>50</height>
  <uuid>{079b77a0-6880-4ece-b9db-223b10aea7ac}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>44</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>In 1</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_2</objectName>
  <x>511</x>
  <y>526</y>
  <width>60</width>
  <height>50</height>
  <uuid>{62cd72a4-e708-4d33-871c-63acb13fed53}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>45</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>In 2</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_2</objectName>
  <x>576</x>
  <y>526</y>
  <width>68</width>
  <height>51</height>
  <uuid>{83f42555-5678-4ab7-97ed-96b0f2314b7a}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>46</midicc>
  <description/>
  <type>value</type>
  <pressedValue>3.00000000</pressedValue>
  <stringvalue/>
  <text>S 1</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>buffer_2</objectName>
  <x>646</x>
  <y>526</y>
  <width>72</width>
  <height>50</height>
  <uuid>{c2398b3b-0f9a-44e6-b3c2-ad86e9c5e008}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>47</midicc>
  <description/>
  <type>value</type>
  <pressedValue>4.00000000</pressedValue>
  <stringvalue/>
  <text>S 2</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>buff_1_name</objectName>
  <x>564</x>
  <y>350</y>
  <width>136</width>
  <height>36</height>
  <uuid>{f3cce55a-5985-4c6b-b9a8-c4a7ba3e7cad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Acc Right</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>buff_2_name</objectName>
  <x>560</x>
  <y>472</y>
  <width>135</width>
  <height>36</height>
  <uuid>{84b910db-2482-4ebc-a867-60fc7eed02e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Acc Left</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>push_active</objectName>
  <x>282</x>
  <y>8</y>
  <width>100</width>
  <height>28</height>
  <uuid>{d13e36a6-cd9f-4bf8-87f5-885bf4dd534c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>push_active</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>croak_active</objectName>
  <x>749</x>
  <y>8</y>
  <width>102</width>
  <height>29</height>
  <uuid>{d1b06e5b-7b8f-4b06-8104-8dc2bebe7226}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>croak_active</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>seed_active</objectName>
  <x>743</x>
  <y>332</y>
  <width>117</width>
  <height>31</height>
  <uuid>{5c354f12-02fa-488f-b869-3799aee06396}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>seed_active</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out4</objectName>
  <x>1016</x>
  <y>312</y>
  <width>24</width>
  <height>122</height>
  <uuid>{0f6ad781-c16b-4d8b-b343-627b93dbfebb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.61099017</xValue>
  <yValue>0.61099017</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out4_over</objectName>
  <x>1016</x>
  <y>291</y>
  <width>24</width>
  <height>25</height>
  <uuid>{5667c034-2afc-4cf0-ad02-deee7cb029a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out4_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1016</x>
  <y>433</y>
  <width>24</width>
  <height>28</height>
  <uuid>{42ae48a0-58b5-4134-888b-ec1cc13a146e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>4</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1091</x>
  <y>14</y>
  <width>629</width>
  <height>708</height>
  <uuid>{68505383-b850-4a0b-a65c-5146fc85a1d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SoundCheck</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>170</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1104</x>
  <y>214</y>
  <width>566</width>
  <height>164</height>
  <uuid>{d57eab77-f4ce-4afe-b1f6-e1ff94f4536b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Mirror Parameters</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1105</x>
  <y>378</y>
  <width>565</width>
  <height>179</height>
  <uuid>{2421ceb8-18b9-4a28-b75b-1097d26482a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Seed Parameters</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>238</r>
   <g>238</g>
   <b>178</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1105</x>
  <y>559</y>
  <width>261</width>
  <height>151</height>
  <uuid>{063dd609-1232-4e90-91ac-3ed908cd9e68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Croak Parameters</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>116</r>
   <g>231</g>
   <b>0</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>push_upper_db</objectName>
  <x>1109</x>
  <y>288</y>
  <width>80</width>
  <height>25</height>
  <uuid>{404d9d18-559f-463d-9975-14a0fb2d1158}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>6.00000000</resolution>
  <minimum>-90</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1109</x>
  <y>262</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9c28a954-4aba-4cb2-8d6b-c54564fa916f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Upper DB Limit</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>push_lower_db</objectName>
  <x>1212</x>
  <y>288</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8014b656-09d3-4ebf-8b5b-fbfef540e19a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>6.00000000</resolution>
  <minimum>-90</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>-60</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1212</x>
  <y>262</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c794675b-5f52-4d11-bb10-13b228c41b70}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lower DB Limit</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>push_env_detect</objectName>
  <x>1118</x>
  <y>347</y>
  <width>64</width>
  <height>24</height>
  <uuid>{42632c27-e64a-4ac6-a27d-517c8c0774ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>3.00000000</resolution>
  <minimum>-100</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1110</x>
  <y>311</y>
  <width>103</width>
  <height>35</height>
  <uuid>{8ca46b96-e4ed-4f0e-8d5a-fcc89ba7b641}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Envelope Detection Factor</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>global_in_gain</objectName>
  <x>1099</x>
  <y>81</y>
  <width>221</width>
  <height>29</height>
  <uuid>{ffd2e170-a2c7-4db1-950b-d540b1375d3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-36.00000000</minimum>
  <maximum>36.00000000</maximum>
  <value>7.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>global_in_gain</objectName>
  <x>1242</x>
  <y>53</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ed2b4cdf-2206-4d44-adf3-53d9a58331f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>7.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1097</x>
  <y>52</y>
  <width>141</width>
  <height>25</height>
  <uuid>{58a25c11-22eb-4eb9-abbe-cabad7c2be22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Global In Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>seup</objectName>
  <x>1101</x>
  <y>127</y>
  <width>147</width>
  <height>44</height>
  <uuid>{58d95c84-2fa8-42e8-8d3e-121ed713671c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Reset Values</text>
  <image>/</image>
  <eventLine>i "Setup1" 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>seed_env_base_db</objectName>
  <x>1222</x>
  <y>421</y>
  <width>80</width>
  <height>32</height>
  <uuid>{f0610c85-60dd-47e1-b948-a3e46c716d68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>3.00000000</resolution>
  <minimum>-12</minimum>
  <maximum>40</maximum>
  <randomizable group="0">false</randomizable>
  <value>20</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1117</x>
  <y>421</y>
  <width>102</width>
  <height>35</height>
  <uuid>{8bb5ef3f-b5a5-4fcd-82bd-766deeca98e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Seed Rhythmic Env Base dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>croak_q_base_db</objectName>
  <x>1217</x>
  <y>590</y>
  <width>79</width>
  <height>24</height>
  <uuid>{f319bbc3-9692-4812-9b6e-f0f83c673882}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>3.00000000</resolution>
  <minimum>-12</minimum>
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>32</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1112</x>
  <y>590</y>
  <width>103</width>
  <height>24</height>
  <uuid>{802106a9-8caf-4ee7-a2c6-dcde80f0fcc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Croak Q Base dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>croak_env_base_db</objectName>
  <x>1215</x>
  <y>623</y>
  <width>79</width>
  <height>24</height>
  <uuid>{ce6ff135-79d3-4aab-90ba-3152cfec5e5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>3.00000000</resolution>
  <minimum>-12</minimum>
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>20</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1110</x>
  <y>623</y>
  <width>103</width>
  <height>24</height>
  <uuid>{c01163f5-b78e-4091-a19d-35033b8cfedd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Croak Env Base dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>seed_react_base_db</objectName>
  <x>1220</x>
  <y>461</y>
  <width>79</width>
  <height>32</height>
  <uuid>{a1f6da52-9f7d-4e78-b63b-e96e3facb766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>3.00000000</resolution>
  <minimum>-36</minimum>
  <maximum>40</maximum>
  <randomizable group="0">false</randomizable>
  <value>-12</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1115</x>
  <y>461</y>
  <width>103</width>
  <height>33</height>
  <uuid>{42777828-3b95-4f23-86b8-e953767b8e02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Seed Reactive Env Base dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampA</objectName>
  <x>592</x>
  <y>609</y>
  <width>28</width>
  <height>103</height>
  <uuid>{a88294b9-09d7-4e6d-ad6b-c4d49f93d53a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampA</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampA_over</objectName>
  <x>592</x>
  <y>584</y>
  <width>28</width>
  <height>25</height>
  <uuid>{bae830bb-67bf-45c7-8454-a125f882590f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampA_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1561</x>
  <y>385</y>
  <width>81</width>
  <height>27</height>
  <uuid>{e5fdfaa9-b95e-4ad4-baf2-69df2dae4a76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SampleA</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1562</x>
  <y>426</y>
  <width>81</width>
  <height>27</height>
  <uuid>{a3d8a0a5-77b8-4a2a-b0cd-1a420446806d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SampleB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1562</x>
  <y>469</y>
  <width>81</width>
  <height>27</height>
  <uuid>{61dd4adc-3525-4d5c-a63f-96602169185c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>In 1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1563</x>
  <y>513</y>
  <width>81</width>
  <height>27</height>
  <uuid>{7dd8004a-fd97-49f1-92c0-0c7f2749f8e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>In 2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1115</x>
  <y>500</y>
  <width>253</width>
  <height>47</height>
  <uuid>{69210905-0b96-4259-9c9a-aa9c517b0fdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Adjust Input Gain until the 4 meters are relatively equal in average decibels</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>170</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>testing_status</objectName>
  <x>1370</x>
  <y>216</y>
  <width>109</width>
  <height>33</height>
  <uuid>{f2a4998c-157f-4df2-9e1a-7ae3f293e244}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Begin Test</text>
  <image>/</image>
  <eventLine>i "BeginTest" 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>testing_status</objectName>
  <x>1370</x>
  <y>252</y>
  <width>110</width>
  <height>34</height>
  <uuid>{1ad0dc64-b908-45e3-8e4b-baf784bc2b66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text>End Test</text>
  <image>/</image>
  <eventLine>i "BeginTest" 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampB</objectName>
  <x>663</x>
  <y>609</y>
  <width>28</width>
  <height>103</height>
  <uuid>{6198c5d7-b10f-4939-8d21-9475056c0f11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampB</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampB_over</objectName>
  <x>663</x>
  <y>584</y>
  <width>28</width>
  <height>25</height>
  <uuid>{9378d748-c2ed-41ba-8250-889f1f231f31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampB_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1</objectName>
  <x>459</x>
  <y>609</y>
  <width>28</width>
  <height>103</height>
  <uuid>{6909fc62-fd2d-436f-ad2c-f5ee7a0ade48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.83502473</xValue>
  <yValue>0.83502473</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1_over</objectName>
  <x>459</x>
  <y>584</y>
  <width>28</width>
  <height>25</height>
  <uuid>{388d3459-9ee2-42bd-8630-cc980722337c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2</objectName>
  <x>523</x>
  <y>609</y>
  <width>28</width>
  <height>103</height>
  <uuid>{8951640a-eecd-41d0-a54e-514c076c2b43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.67174974</xValue>
  <yValue>0.67174974</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2_over</objectName>
  <x>523</x>
  <y>584</y>
  <width>28</width>
  <height>25</height>
  <uuid>{6dc0b510-304f-4514-8bab-734380a2156a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampA</objectName>
  <x>1370</x>
  <y>383</y>
  <width>160</width>
  <height>30</height>
  <uuid>{29934593-81c2-4f29-9530-6897efd3cbf6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampA</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampA_over</objectName>
  <x>1530</x>
  <y>383</y>
  <width>28</width>
  <height>30</height>
  <uuid>{46058341-b37b-4abf-973d-d06951f7131d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampA_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampB</objectName>
  <x>1371</x>
  <y>424</y>
  <width>160</width>
  <height>30</height>
  <uuid>{44aff5f5-2b82-462b-bc9a-4e0af4df178f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampB</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sampB_over</objectName>
  <x>1529</x>
  <y>424</y>
  <width>28</width>
  <height>31</height>
  <uuid>{d30c983f-7ae0-4d67-a305-641f85360e0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sampB_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1</objectName>
  <x>1371</x>
  <y>468</y>
  <width>160</width>
  <height>30</height>
  <uuid>{bf95cb7b-93a4-4408-98de-b97db22fe4c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.83502473</xValue>
  <yValue>0.83502473</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1_over</objectName>
  <x>1531</x>
  <y>468</y>
  <width>28</width>
  <height>30</height>
  <uuid>{b8502d5d-bbbe-416c-afd2-c8c6ef4df887}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in1_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2</objectName>
  <x>1369</x>
  <y>512</y>
  <width>161</width>
  <height>30</height>
  <uuid>{93d90009-ac77-404c-a483-788ac3321107}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.67174974</xValue>
  <yValue>0.67174974</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2_over</objectName>
  <x>1529</x>
  <y>512</y>
  <width>26</width>
  <height>30</height>
  <uuid>{0ba3a79d-4879-4fdf-b011-fc6cbd4730ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>in2_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>test_noise_db</objectName>
  <x>1369</x>
  <y>315</y>
  <width>139</width>
  <height>27</height>
  <uuid>{6b021718-c3e4-4091-9807-6bf71f7cde4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-59.23000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1369</x>
  <y>289</y>
  <width>98</width>
  <height>23</height>
  <uuid>{f90880f6-1efa-46bc-91b5-d8a8262b3d68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Test Noise dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>test_noise_db</objectName>
  <x>1514</x>
  <y>317</y>
  <width>64</width>
  <height>24</height>
  <uuid>{77fd0234-6957-434a-b1fd-4b9b3e2c5db5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-59.230</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>push_indb</objectName>
  <x>205</x>
  <y>212</y>
  <width>129</width>
  <height>32</height>
  <uuid>{e4bd7875-d89a-44ac-8eff-eeb46fccb415}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>push_indb</objectName2>
  <xMin>-80.00000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>-80.00000000</yMin>
  <yMax>20.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>push_outdb</objectName>
  <x>205</x>
  <y>253</y>
  <width>129</width>
  <height>32</height>
  <uuid>{69e894a3-a373-45f9-87a1-b4dca1f67e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>push_outdb</objectName2>
  <xMin>-80.00000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>-80.00000000</yMin>
  <yMax>20.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push_indb</objectName>
  <x>337</x>
  <y>212</y>
  <width>47</width>
  <height>32</height>
  <uuid>{28ec4859-f443-45df-a13d-aa1e457fbb29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>push_outdb</objectName>
  <x>337</x>
  <y>254</y>
  <width>47</width>
  <height>31</height>
  <uuid>{e08ef7bd-6412-4d7c-98b2-a968fec3545d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>182</x>
  <y>216</y>
  <width>25</width>
  <height>25</height>
  <uuid>{c97c92c2-707c-4435-9d70-d6a0b7ce90f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>In</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>push_response_level</objectName>
  <x>1217</x>
  <y>347</y>
  <width>64</width>
  <height>24</height>
  <uuid>{d643f70a-9aa7-451d-a7c9-7778632198d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>2.00000000</resolution>
  <minimum>-40</minimum>
  <maximum>40</maximum>
  <randomizable group="0">false</randomizable>
  <value>12</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1214</x>
  <y>311</y>
  <width>103</width>
  <height>35</height>
  <uuid>{80ae6808-7a16-46a7-ae8e-93a96104d175}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Response Detection Factor</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>reverbSize</objectName>
  <x>1417</x>
  <y>76</y>
  <width>201</width>
  <height>28</height>
  <uuid>{21b0ef6b-426a-44a0-8d8c-2c94ff5d0025}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>93</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>reverbSize</objectName>
  <x>1546</x>
  <y>35</y>
  <width>71</width>
  <height>36</height>
  <uuid>{9285424e-5464-4ab4-8727-26756b25135a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.600</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1418</x>
  <y>34</y>
  <width>120</width>
  <height>33</height>
  <uuid>{9e325da4-424a-404d-9f5e-ca6ab4cb323b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Reverb size</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>reverbHCBase</objectName>
  <x>1418</x>
  <y>151</y>
  <width>201</width>
  <height>28</height>
  <uuid>{2da40f92-3ad8-44b6-9063-46fb781b17eb}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>93</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>reverbHC</objectName>
  <x>1546</x>
  <y>108</y>
  <width>71</width>
  <height>36</height>
  <uuid>{a5eedb81-7aed-480f-963e-2e381c60a524}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3825.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1419</x>
  <y>109</y>
  <width>124</width>
  <height>33</height>
  <uuid>{cb1d09ba-1517-4734-acaa-10c3faf8dd18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Reverb highcut</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Base" number="0" >
<value id="{f8582227-bbb6-431f-a433-33ed267d1d67}" mode="1" >-inf</value>
<value id="{f8582227-bbb6-431f-a433-33ed267d1d67}" mode="2" >-inf</value>
<value id="{3d46619f-a663-483c-b62e-04fd2a51d003}" mode="1" >0.00000000</value>
<value id="{3d46619f-a663-483c-b62e-04fd2a51d003}" mode="2" >0.00000000</value>
<value id="{ef368113-1b9b-4021-ba3a-e8636e44bd63}" mode="1" >-inf</value>
<value id="{ef368113-1b9b-4021-ba3a-e8636e44bd63}" mode="2" >-inf</value>
<value id="{2a7246d3-5730-495c-831f-43cb1541e26f}" mode="1" >0.00000000</value>
<value id="{2a7246d3-5730-495c-831f-43cb1541e26f}" mode="2" >0.00000000</value>
<value id="{9df4b4e2-cf40-4544-a56c-a8c38cf9bb7e}" mode="1" >0.00000000</value>
<value id="{9df4b4e2-cf40-4544-a56c-a8c38cf9bb7e}" mode="2" >0.00000000</value>
<value id="{77caaed3-d8fb-463f-8703-bfcc3235ca17}" mode="1" >0.00000000</value>
<value id="{77caaed3-d8fb-463f-8703-bfcc3235ca17}" mode="2" >0.00000000</value>
<value id="{17ee73f3-0724-4674-9be6-77e34decacc4}" mode="1" >0.06992421</value>
<value id="{17ee73f3-0724-4674-9be6-77e34decacc4}" mode="2" >0.06992421</value>
<value id="{86262ec4-d95e-4f99-b457-3b27b73542ba}" mode="1" >0.00000000</value>
<value id="{86262ec4-d95e-4f99-b457-3b27b73542ba}" mode="2" >0.00000000</value>
<value id="{93eb0256-e128-4311-8c19-7a56db6d328a}" mode="1" >0.17026754</value>
<value id="{93eb0256-e128-4311-8c19-7a56db6d328a}" mode="2" >0.17026754</value>
<value id="{69dd83a3-2292-4df9-9261-2a9feb7fe6f1}" mode="1" >0.00000000</value>
<value id="{69dd83a3-2292-4df9-9261-2a9feb7fe6f1}" mode="2" >0.00000000</value>
<value id="{4f92760e-1392-4a19-82b0-585b1c32809f}" mode="1" >-0.03041913</value>
<value id="{4f92760e-1392-4a19-82b0-585b1c32809f}" mode="2" >-0.03041913</value>
<value id="{53ec5e3c-70bb-48e6-9fb1-86ecd9fbc781}" mode="1" >0.00000000</value>
<value id="{53ec5e3c-70bb-48e6-9fb1-86ecd9fbc781}" mode="2" >0.00000000</value>
<value id="{799e2e9c-68dd-469d-a648-778070582b19}" mode="4" >0</value>
<value id="{faa260f2-d0fd-489c-8653-57a2457a4996}" mode="1" >50.00000000</value>
<value id="{e237d7c1-6de5-44f8-91bf-6f82db8978e6}" mode="1" >50.00000000</value>
<value id="{e237d7c1-6de5-44f8-91bf-6f82db8978e6}" mode="4" >50.000</value>
<value id="{bdfbbd94-aecf-470d-a7d3-2ba209ab9d04}" mode="1" >0.00000000</value>
<value id="{badb21a3-e8bc-4c22-a168-c84add9d0bb5}" mode="1" >0.00000000</value>
<value id="{badb21a3-e8bc-4c22-a168-c84add9d0bb5}" mode="4" >0.000</value>
<value id="{ba8215ef-2be1-406d-aca5-251039fa005c}" mode="1" >1.00000000</value>
<value id="{c5294fb1-1c87-4e55-b18f-d1d4344db9e5}" mode="1" >1.00000000</value>
<value id="{c5294fb1-1c87-4e55-b18f-d1d4344db9e5}" mode="4" >1.000</value>
<value id="{4c23229d-7606-4b92-983c-43bae363030f}" mode="1" >1.00000000</value>
<value id="{22cd6db5-66e5-40d1-828f-c013ce38d851}" mode="1" >1.00000000</value>
<value id="{22cd6db5-66e5-40d1-828f-c013ce38d851}" mode="4" >1.000</value>
<value id="{90da1c99-d46e-4b19-98a4-56a0fb253297}" mode="1" >8.13114738</value>
<value id="{e23d3d1a-9e0e-4fee-8336-7c39ddca2475}" mode="1" >8.13099957</value>
<value id="{e23d3d1a-9e0e-4fee-8336-7c39ddca2475}" mode="4" >8.131</value>
<value id="{2142d170-ccb4-44ef-b6e2-fa0dda634259}" mode="1" >-60.00000000</value>
<value id="{29c31b83-f7b8-4334-97bc-0eb440d6060c}" mode="1" >-60.00000000</value>
<value id="{29c31b83-f7b8-4334-97bc-0eb440d6060c}" mode="4" >-60.000</value>
<value id="{61f31b2b-2194-4401-b9dc-cb11ec81f4de}" mode="1" >1.00000000</value>
<value id="{fe08b757-e389-4ff4-9317-fa9e76676563}" mode="1" >0.30000001</value>
<value id="{b36b6b57-7b8e-4d6c-a23f-becabe259231}" mode="1" >0.30000001</value>
<value id="{b36b6b57-7b8e-4d6c-a23f-becabe259231}" mode="4" >0.300</value>
<value id="{6bff2c80-6c31-4afa-a2c4-4264d83c9432}" mode="1" >0.80000001</value>
<value id="{aa5ee0a8-8578-4e01-a371-04ddd2f55e59}" mode="1" >0.80000001</value>
<value id="{aa5ee0a8-8578-4e01-a371-04ddd2f55e59}" mode="4" >0.800</value>
<value id="{99346cbd-7891-4cb2-9f40-dd3fdf5b5dbe}" mode="1" >25.00000000</value>
<value id="{20eb8526-5a5c-4379-beb1-7ad4be927ce9}" mode="1" >25.00000000</value>
<value id="{20eb8526-5a5c-4379-beb1-7ad4be927ce9}" mode="4" >25.000</value>
<value id="{a93787ec-b25a-4e08-97be-3ac2c2c96fa8}" mode="1" >0.20000000</value>
<value id="{e08b440e-ea54-42f5-9583-a6af96f4e2a8}" mode="1" >0.20000000</value>
<value id="{e08b440e-ea54-42f5-9583-a6af96f4e2a8}" mode="4" >0.200</value>
<value id="{9a89ebbc-8024-40c9-b3a6-75522da2d419}" mode="1" >-47.43307114</value>
<value id="{18bc329c-259b-4993-ab66-c6c77f9f288b}" mode="1" >-47.43299866</value>
<value id="{18bc329c-259b-4993-ab66-c6c77f9f288b}" mode="4" >-47.433</value>
<value id="{4437de1c-cb4b-4ed4-bc75-e0c10a135624}" mode="1" >0.00000000</value>
<value id="{4437de1c-cb4b-4ed4-bc75-e0c10a135624}" mode="4" >0</value>
<value id="{5256f1c5-1c42-4268-a199-9a35bebf101e}" mode="4" >1</value>
<value id="{f11a96c7-8f36-4181-bd17-9ad87d259e41}" mode="4" >0</value>
<value id="{12a3dd0a-c7dd-416f-8f39-3c4f24c40bde}" mode="1" >1.00000000</value>
<value id="{2953eba9-665e-4c08-b2e9-7d308dbde0c3}" mode="1" >1.00000000</value>
<value id="{2953eba9-665e-4c08-b2e9-7d308dbde0c3}" mode="4" >1.000</value>
<value id="{89712097-6156-49ed-a3e0-6f79954970b5}" mode="1" >0.00010000</value>
<value id="{61b3ac90-a02b-4504-8c21-fe1a69e2bba2}" mode="1" >0.00010000</value>
<value id="{61b3ac90-a02b-4504-8c21-fe1a69e2bba2}" mode="4" >0.000</value>
<value id="{b2e9ca5b-d7c9-414c-bcf8-40d91b9952a9}" mode="1" >1.00000000</value>
<value id="{ab77a567-d585-471d-93b9-0a724e97de53}" mode="1" >1.00000000</value>
<value id="{ab77a567-d585-471d-93b9-0a724e97de53}" mode="4" >1.000</value>
<value id="{59d85aae-5355-404c-b980-799258d47915}" mode="1" >12.00000000</value>
<value id="{1c8e2cd7-678c-4003-b72b-96407c7adcc3}" mode="1" >12.00000000</value>
<value id="{1c8e2cd7-678c-4003-b72b-96407c7adcc3}" mode="4" >12.000</value>
<value id="{cfb5f879-9051-48d0-a73e-b9243f182b86}" mode="4" >0</value>
<value id="{b9c961a0-72b5-41bd-bdb7-bb11bf02d5ad}" mode="4" >0</value>
<value id="{e6173983-a23b-4ba3-bca7-d91bb80f3301}" mode="4" >0</value>
<value id="{47af04c8-a175-463d-a93c-c1e537353fe9}" mode="4" >0</value>
<value id="{13ef2202-6ea3-409a-bb9f-0bf4341945fa}" mode="4" >0</value>
<value id="{1b87ec24-3b6c-4c1f-b445-8371d42095f0}" mode="4" >0</value>
<value id="{d3131559-e100-4fda-8464-f2908c7029c5}" mode="4" >0</value>
<value id="{8478ed45-851d-4833-a8aa-2679ca6bcfdb}" mode="4" >0</value>
<value id="{d5374c9d-aae8-4535-83ba-280c1b1d5e1f}" mode="4" >0</value>
<value id="{010cea37-6936-4eb5-8ac1-51b4a87ca2c3}" mode="4" >0</value>
<value id="{079b77a0-6880-4ece-b9db-223b10aea7ac}" mode="4" >0</value>
<value id="{62cd72a4-e708-4d33-871c-63acb13fed53}" mode="4" >0</value>
<value id="{83f42555-5678-4ab7-97ed-96b0f2314b7a}" mode="4" >0</value>
<value id="{c2398b3b-0f9a-44e6-b3c2-ad86e9c5e008}" mode="4" >0</value>
<value id="{f3cce55a-5985-4c6b-b9a8-c4a7ba3e7cad}" mode="1" >0.00000000</value>
<value id="{f3cce55a-5985-4c6b-b9a8-c4a7ba3e7cad}" mode="4" >Acc Right</value>
<value id="{84b910db-2482-4ebc-a867-60fc7eed02e2}" mode="1" >0.00000000</value>
<value id="{84b910db-2482-4ebc-a867-60fc7eed02e2}" mode="4" >Acc Left</value>
<value id="{d13e36a6-cd9f-4bf8-87f5-885bf4dd534c}" mode="1" >0.00000000</value>
<value id="{d13e36a6-cd9f-4bf8-87f5-885bf4dd534c}" mode="2" >0.00000000</value>
<value id="{d1b06e5b-7b8f-4b06-8104-8dc2bebe7226}" mode="1" >0.00000000</value>
<value id="{d1b06e5b-7b8f-4b06-8104-8dc2bebe7226}" mode="2" >0.00000000</value>
<value id="{5c354f12-02fa-488f-b869-3799aee06396}" mode="1" >0.00000000</value>
<value id="{5c354f12-02fa-488f-b869-3799aee06396}" mode="2" >0.00000000</value>
<value id="{0f6ad781-c16b-4d8b-b343-627b93dbfebb}" mode="1" >0.00000000</value>
<value id="{0f6ad781-c16b-4d8b-b343-627b93dbfebb}" mode="2" >0.00000000</value>
<value id="{5667c034-2afc-4cf0-ad02-deee7cb029a9}" mode="1" >0.00000000</value>
<value id="{5667c034-2afc-4cf0-ad02-deee7cb029a9}" mode="2" >0.00000000</value>
<value id="{404d9d18-559f-463d-9975-14a0fb2d1158}" mode="1" >0.00000000</value>
<value id="{8014b656-09d3-4ebf-8b5b-fbfef540e19a}" mode="1" >-60.00000000</value>
<value id="{42632c27-e64a-4ac6-a27d-517c8c0774ce}" mode="1" >0.00000000</value>
<value id="{ffd2e170-a2c7-4db1-950b-d540b1375d3e}" mode="1" >7.65600014</value>
<value id="{ed2b4cdf-2206-4d44-adf3-53d9a58331f3}" mode="1" >7.65600014</value>
<value id="{ed2b4cdf-2206-4d44-adf3-53d9a58331f3}" mode="4" >7.656</value>
<value id="{58d95c84-2fa8-42e8-8d3e-121ed713671c}" mode="4" >0</value>
<value id="{f0610c85-60dd-47e1-b948-a3e46c716d68}" mode="1" >20.00000000</value>
<value id="{f319bbc3-9692-4812-9b6e-f0f83c673882}" mode="1" >32.00000000</value>
<value id="{ce6ff135-79d3-4aab-90ba-3152cfec5e5d}" mode="1" >20.00000000</value>
<value id="{a1f6da52-9f7d-4e78-b63b-e96e3facb766}" mode="1" >-12.00000000</value>
<value id="{a88294b9-09d7-4e6d-ad6b-c4d49f93d53a}" mode="1" >0.00000000</value>
<value id="{a88294b9-09d7-4e6d-ad6b-c4d49f93d53a}" mode="2" >0.00000000</value>
<value id="{bae830bb-67bf-45c7-8454-a125f882590f}" mode="1" >0.00000000</value>
<value id="{bae830bb-67bf-45c7-8454-a125f882590f}" mode="2" >0.00000000</value>
<value id="{f2a4998c-157f-4df2-9e1a-7ae3f293e244}" mode="4" >0</value>
<value id="{1ad0dc64-b908-45e3-8e4b-baf784bc2b66}" mode="4" >0</value>
<value id="{6198c5d7-b10f-4939-8d21-9475056c0f11}" mode="1" >0.00000000</value>
<value id="{6198c5d7-b10f-4939-8d21-9475056c0f11}" mode="2" >0.00000000</value>
<value id="{9378d748-c2ed-41ba-8250-889f1f231f31}" mode="1" >0.00000000</value>
<value id="{9378d748-c2ed-41ba-8250-889f1f231f31}" mode="2" >0.00000000</value>
<value id="{6909fc62-fd2d-436f-ad2c-f5ee7a0ade48}" mode="1" >0.06992421</value>
<value id="{6909fc62-fd2d-436f-ad2c-f5ee7a0ade48}" mode="2" >0.06992421</value>
<value id="{388d3459-9ee2-42bd-8630-cc980722337c}" mode="1" >0.00000000</value>
<value id="{388d3459-9ee2-42bd-8630-cc980722337c}" mode="2" >0.00000000</value>
<value id="{8951640a-eecd-41d0-a54e-514c076c2b43}" mode="1" >0.17026754</value>
<value id="{8951640a-eecd-41d0-a54e-514c076c2b43}" mode="2" >0.17026754</value>
<value id="{6dc0b510-304f-4514-8bab-734380a2156a}" mode="1" >0.00000000</value>
<value id="{6dc0b510-304f-4514-8bab-734380a2156a}" mode="2" >0.00000000</value>
<value id="{29934593-81c2-4f29-9530-6897efd3cbf6}" mode="1" >0.00000000</value>
<value id="{29934593-81c2-4f29-9530-6897efd3cbf6}" mode="2" >0.00000000</value>
<value id="{46058341-b37b-4abf-973d-d06951f7131d}" mode="1" >0.00000000</value>
<value id="{46058341-b37b-4abf-973d-d06951f7131d}" mode="2" >0.00000000</value>
<value id="{44aff5f5-2b82-462b-bc9a-4e0af4df178f}" mode="1" >0.00000000</value>
<value id="{44aff5f5-2b82-462b-bc9a-4e0af4df178f}" mode="2" >0.00000000</value>
<value id="{d30c983f-7ae0-4d67-a305-641f85360e0e}" mode="1" >0.00000000</value>
<value id="{d30c983f-7ae0-4d67-a305-641f85360e0e}" mode="2" >0.00000000</value>
<value id="{bf95cb7b-93a4-4408-98de-b97db22fe4c1}" mode="1" >0.06992421</value>
<value id="{bf95cb7b-93a4-4408-98de-b97db22fe4c1}" mode="2" >0.06992421</value>
<value id="{b8502d5d-bbbe-416c-afd2-c8c6ef4df887}" mode="1" >0.00000000</value>
<value id="{b8502d5d-bbbe-416c-afd2-c8c6ef4df887}" mode="2" >0.00000000</value>
<value id="{93d90009-ac77-404c-a483-788ac3321107}" mode="1" >0.17026754</value>
<value id="{93d90009-ac77-404c-a483-788ac3321107}" mode="2" >0.17026754</value>
<value id="{0ba3a79d-4879-4fdf-b011-fc6cbd4730ec}" mode="1" >0.00000000</value>
<value id="{0ba3a79d-4879-4fdf-b011-fc6cbd4730ec}" mode="2" >0.00000000</value>
<value id="{6b021718-c3e4-4091-9807-6bf71f7cde4f}" mode="1" >-59.22999954</value>
<value id="{77fd0234-6957-434a-b1fd-4b9b3e2c5db5}" mode="1" >-59.22999954</value>
<value id="{77fd0234-6957-434a-b1fd-4b9b3e2c5db5}" mode="4" >-59.230</value>
<value id="{e4bd7875-d89a-44ac-8eff-eeb46fccb415}" mode="1" >0.00000000</value>
<value id="{e4bd7875-d89a-44ac-8eff-eeb46fccb415}" mode="2" >0.00000000</value>
<value id="{69e894a3-a373-45f9-87a1-b4dca1f67e87}" mode="1" >0.00000000</value>
<value id="{69e894a3-a373-45f9-87a1-b4dca1f67e87}" mode="2" >0.00000000</value>
<value id="{28ec4859-f443-45df-a13d-aa1e457fbb29}" mode="1" >0.00000000</value>
<value id="{28ec4859-f443-45df-a13d-aa1e457fbb29}" mode="4" >0.000</value>
<value id="{e08ef7bd-6412-4d7c-98b2-a968fec3545d}" mode="1" >0.00000000</value>
<value id="{e08ef7bd-6412-4d7c-98b2-a968fec3545d}" mode="4" >0.000</value>
<value id="{d643f70a-9aa7-451d-a7c9-7778632198d1}" mode="1" >12.00000000</value>
</preset>
</bsbPresets>
