<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 4
nchnls = 2
0dbfs = 1

////////////////////////////////////////////////////////////////////////
/* Tones
Generates the different tone sounds used in the piece
- Perlin Synths with controlled distortion for base tonal clusters
- FFT created fuzzy tones for melodic fragments and upper chords
*/
////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
//////////////////////// SETTINGS ////////////////////////
//////////////////////////////////////////////////////////
giAmpFactor = 15

gaOut[] init 2
gaMono[] init 11
gSConvolveFile = "/ImpulseResponse.wav"
giSpeed = 1.5
giLowPassFreqFactor init 2
giHighPassFreqFactor init 0.15
gkDepthCompression init 2
gkPerlinSpeedFactor init 0.
gkFreqDecay init 0
gkGlobalAmp init 1

chn_a "outL", 3
chn_a "outR", 3

//////////////////////////////////////////////////////////////////////
//////////////////////// OPTIMIZATION OPCODES //////////////////////// 
/////////////////////////////////////////////////////////////////////

opcode PerlinRotate, a, kka
	kFreq, kRes, aDepth xin 
	kTime init 0
	kRotationSpeed = kFreq * $M_PI * 2 / kr
	kTime += kRotationSpeed
	aX = sin(a(kTime)) * kRes
	aY = cos(a(kTime)) * kRes
	aOut = perlin3:a(aX, aY, aDepth)
	xout aOut
endop

opcode PerlinRotate, a, kkk
	kFreq, kRes, kDepth xin 
	kTime init 0
	kRotationSpeed = kFreq * $M_PI * 2 / kr
	kTime += kRotationSpeed
	aX = sin(a(kTime)) * kRes
	aY = cos(a(kTime)) * kRes
	xout perlin3:a(aX, aY, a(kDepth))
endop

opcode PerlinNorm, a, aaa
	a1, a2, a3 xin
	aPerlin = perlin3:a(a1, a2, a3)
	aPerlin = (aPerlin + 1) / 2
	xout aPerlin
endop

opcode PerlinNorm, k, kkk
	k1, k2, k3 xin
	kPerlin = perlin3:k(k1, k2, k3)
	kPerlin = (kPerlin + 1) / 2
	xout kPerlin
endop

opcode Convolve, a, a
	aOrigin xin
	aOut pconvolve aOrigin, gSConvolveFile
	xout aOut
endop

opcode Convolve2, a[], a[]
	aOrigin[] xin
	aOut[] init 2
	aOut[0] pconvolve aOrigin[0], gSConvolveFile
	aOut[1] pconvolve aOrigin[1], gSConvolveFile
	xout aOut
endop

opcode Convolve, a[], a[]
	aOrigin[] xin
	aOut[] init 8
	aOut[0] pconvolve aOrigin[0], gSConvolveFile
	aOut[1] pconvolve aOrigin[1], gSConvolveFile
	aOut[2] pconvolve aOrigin[2], gSConvolveFile
	aOut[3] pconvolve aOrigin[3], gSConvolveFile	
	aOut[4] pconvolve aOrigin[4], gSConvolveFile
	aOut[5] pconvolve aOrigin[5], gSConvolveFile
	aOut[6] pconvolve aOrigin[6], gSConvolveFile
	aOut[7] pconvolve aOrigin[7], gSConvolveFile
	xout aOut
endop

gifftsize  = 2048; We choose a large window since most of the samples contain many low frequencies
gioverlap =  256
giwintype  = 1 

opcode Vocoder, a, aak
	// Vocodes two signals using pvsvoc
	aSound, aVoc, kVocAmount xin
	fSound pvsanal aSound, gifftsize, gioverlap, gifftsize, giwintype
	fVoc pvsanal aVoc, gifftsize, gioverlap, gifftsize, giwintype
	fVoc pvsvoc fSound, fVoc, kVocAmount, 1
	fSmoothed pvsmooth fVoc, 0.1, 0.2
	aVocoded pvsynth fSmoothed
	xout aVocoded
endop

opcode Vocoder2, a[], a[]a[]k
	// Vocodes two signals using pvsvoc
	aSignal1[], aSignal2[], kVoc xin
	aVoc[] init 2
	aVoc[0] Vocoder aSignal1[1], aSignal2[1], kVoc
	aVoc[1] Vocoder aSignal1[1], aSignal2[1], kVoc
	xout aVoc
endop

opcode Morphing, a, aak
	//Morphs two signals using pvsmorph
	aSignal1, aSignal2, kMorph xin
	
	fSig1 pvsanal aSignal1, gifftsize, gioverlap, gifftsize, giwintype
	fSig2 pvsanal aSignal2, gifftsize, gioverlap, gifftsize, giwintype
 	fMorphed pvsmorph fSig1, fSig2, kMorph * 0.6, kMorph
  	fSmoothed pvsmooth fMorphed, 0.2, 0.2 // we add a bit of smoothing to reduce artifacts
	
	aMorphed pvsynth fSmoothed
	xout aMorphed
endop

opcode Morphing2, a[], a[]a[]k
	//Morphs two signals using pvsmorph
	aSignal1[], aSignal2[], kMorph xin
	aMorphed[] init 2
	aMorphed[0] Morphing aSignal1[0], aSignal2[0], kMorph
	aMorphed[1] Morphing aSignal1[1], aSignal2[1], kMorph
	
	xout aMorphed
endop


//////////////////////////////////////////////////////////////////////
//////////////////////// CHORD INSTRUMENTS  ///////////////////////// 
/////////////////////////////////////////////////////////////////////

instr PlayChordA
	iFreqs[] fillarray 27.5, 49, 61.25, 73.5, 82.41, 103.01, 123.61, 138.59, 173.23, 207.88, 233.08, 291.35, 349.62, 392, 490, 588, 659.25, 824.06, 988.87, 1108.7, 1385.9, 1663, 1864.6, 2330.8, 2796.9, 3136
	idx = 0
	iLen lenarray iFreqs
	while idx < iLen do
		iFreq = iFreqs[idx] * p5
		schedule "SuperCircle", 0,		p3,		p4 / 5,		20,		iFreq, 0, p6, idx
		idx += 1
	od
endin

instr PlayChordB
	iFreqs[] fillarray 24.50, 49.00, 61.25, 73.50, 82.69, 103.36, 124.03, 139.54, 174.42, 209.30, 235.47, 294.33, 353.20, 397.35, 496.69, 596.02, 670.53, 838.16, 1005.79, 1131.51, 1414.39, 1697.27, 1909.42, 2386.78, 2864.14, 3222.15
	idx = 0
	iLen lenarray iFreqs
	while idx < iLen do
		iFreq = iFreqs[idx] * p5
		schedule "SuperCircle", 0,		p3,		p4 / 5,		20,		iFreq, 0, p6, idx
		idx += 1
	od
endin


//////////////////////////////////////////////////////////////////////
//////////////////////// OSCILLATING INSTRUMENTS  ///////////////////
/////////////////////////////////////////////////////////////////////

instr CircleSyn
	iOutType = p7
	iResEnv = p8
	idx = p9
	kTime init 0
	kAmp init p5
	kFreq init p6
	if iResEnv == 1 then
		kResolution = line:k(random:i(0.1, 0.2), p3, random:i(3, 5))
	elseif iResEnv == 2 then
		kResolution = line:k(random:i(0.01, 0.05), p3, random:i(1, 3))
	elseif iResEnv == 3 then
		kResolution = line:k(random:i(40, 50), p3/2, 0.001)
		//kResolution = limit:k(kResolution, 0.00000001, 50)
	elseif iResEnv == 4 then
		kResolution = line:k(random:i(1, 1.5), p3, random:i(0.8, 1.3))
	elseif iResEnv == 5 then
		kResolution = line:k(random:i(25, 30), p3, random:i(35, 50))
	endif
	kDepth = random:i(1, 1000) + gkDepthCompression * p5
	
	kAmpVariation = perlin3:k(kTime, kFreq, kAmp)
	kScaledAmp scale kAmpVariation, 0.25, 1, -1, 1
	kAmp = p4 * kScaledAmp * giAmpFactor
	kFreqVariation = perlin3:k(p5, kTime, p5 * kDepth / 50)
	if kFreqVariation == 0 then
		kSign = 1
	else
		kSign = kFreqVariation / abs(kFreqVariation)
	endif
	kScaledFreq = scale(pow(kFreqVariation, 2), 0, 1/55, 0, 1)
	kFreqFactor = 1 + (kSign * kScaledFreq)
	kFreq = p6 * kFreqFactor
	
	aNoise = PerlinRotate(kFreq, kResolution, kDepth)
	aNoise = aNoise * kAmp
	iHPFreq = limit(p6 * giHighPassFreqFactor, 1, 20)
	iLPFreq = limit(p6 * giLowPassFreqFactor, 600, 9000)
	aNoise = buthp:a(aNoise, iHPFreq) 
	aNoise = butlp:a(aNoise, iLPFreq)
	
	kAzim = line:k(random:i(-360, 360), p3, random:i(-360, 360))
	ambiArray[] init 9
	ambiArray bformenc1 aNoise, kAzim, 0
	aOut[] init 2
	aOut bformdec1 1, ambiArray
	chnmix aOut[0], "outL"
	chnmix aOut[1], "outR"
	kTime += kResolution / 6000
endin

instr SuperCircle
	/*
	p4 = amp
	p5 = partial amount
	p6 = frequency
	p7 = out type
	p8 = Res 
	p9 = note number
	*/
	iAmp = p4 / sqrt(p5)
	iPartials = p5
	iIdx = 1
	while iIdx <= iPartials do
		iAmp = iAmp / (1 + log(pow(iIdx, 1.1)))
		iFreq = iIdx * p6
		schedule "CircleSyn", 0, p3, iAmp, iIdx, iFreq, p7, p8, p9
		iIdx += 1
	od
endin

instr Master
	schedule "PlayChordA",		0 ,		20,		0.8,		0.5,		2
	//schedule "PlayChordB",		0,			20,		0.8,			1,			2
	aPreL chnget "outL"
	aPreR chnget "outR"
	kFilterFreq expon 1200, p3, 14000
	aFilL tone aPreL, kFilterFreq
	aFilR tone aPreR, kFilterFreq
	
	aRevL, aRevR reverbsc aFilL, aFilR, 0.5, 1, sr, 0.8
	aOutL = aFilL + aRevL
	aOutR = aFilL + aRevR
	out aOutL, aOutR
	chnclear "outL"
	chnclear "outR"
endin


</CsInstruments>
<CsScore>
//i "SuperCircle"		0		20		0.1		20		100
//i "PlayChord1"		0		180		1		0.25
//i "PlayChord2"		0		150		1		0.5
//i "VocodeCircleTone"	0		20		4		8		233.08
//i "ChordMorph"		0		10
//i "SuperCircle"	 0		8		1	 16	100.89		1 		5 		0
//i "PlayChordX"	 0		 20		 4		 1
i "Master" 0	35
</CsScore>
</CsoundSynthesizer>




















































<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>664</x>
 <y>140</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
