(
SynthDef(\klonk, {
	arg trigFreq = 50,
	//rez = #[200, 420, 832, 1042],
	rez = #[200, 671, 1153, 1723],
	ampz = #[0.55, 0.55, 0.55, 0.55],
	timez = #[1, 1, 1, 1],
	hiCutoff = 2500, loCutoff = 50,
	pan = 0, amp = 0.1, trigType = 0,
	attack = 0.01, gate = 1, release = 1, bend = 0;
	var sig;
	var trig = Select.kr(trigType, [Dust.kr(trigFreq), Impulse.kr(trigFreq)]);
	var volEnv = Env.asr(attack, 1, release, -2).kr(2, Select.kr(trigType, [gate, trig]));
	var lfoRate = \lfoRate.kr(0.5);

	bend = bend + LFTri.kr(
		lfoRate
	).bipolar(
		\bendLfoDepth.kr(0)
	).lag(0.1);

	pan = pan + LFTri.kr(
		LFNoise2.kr(lfoRate * 0.5).exprange(lfoRate * 0.75, lfoRate * 1.5)
	).bipolar(
		LFNoise2.kr(lfoRate).unipolar(\panLfoDepth.kr(0))
	);

	sig = DynKlank.ar(
		`[rez.lag(0.01), ampz.lag(0.01), timez.lag(0.01)],
		PinkNoise.ar(0.1!2) * Env.perc(0.0005,0.0005).kr(0, trig),
		LFNoise1.kr(0.5!4).bipolar(0.3).midiratio *
		bend.lag(0.01).midiratio
	);
	sig = HPF.ar(LPF.ar(sig, hiCutoff), loCutoff) * volEnv;
	sig = Balance2.ar(sig[0], sig[1], pan.lag(0.1), amp.lag(0.5));
	Out.ar(0, sig);
}).add;

~examples['2A'] = {
	var synth;

	var ampzMap = Env([
		Array.interpolation(4, 1, 0.1),
		Array.interpolation(4, 0.1, 1),
	], [1]);

	Fdef(\enter, { synth = Synth(\klonk, target: ~group) });

	Fdef(\exit, { synth.set(\gate, 0, \trigFreq, 5) });

	Fdef(\leapTick, {
		~handIsPresent.if{
			(
				trigFreq: l.transLenAvg.lincurve(0, 1, 0, 50, -1),
				timez: l.pinchStrength.linlin(0, 1, 1.2, 0.25) ! 4,
				pan: l.palm.x.linlin(0, 1, -0.75, 0.75),
				amp: l.transLenAvg.lincurve(0, 0.5, 0, 0.5, 2),
				bend: l.palm.y.lincurve(0, 1, 0, 0.5, 2),
				ampz: ampzMap[l.palm.y].pow(2)
			).keysValuesDo({ |key,value| synth.set(key, value) });
		};
	})
};


~examples['2B'] = {
	var ampzMap = Env([
		Array.interpolation(4, 1, 0.1),
		Array.interpolation(4, 0.1, 1),
	], [1]);

	~loop = Pbindef(\bend,
		\instrument, \klonk,
		\trigType, 1,
		\trigFreq, 0,
		\attack, 0.0001,
		\release, 1.2,
		\db, Pwhite(-22, -18),
		\dur, Pexprand(0.12, 0.25),
	).play.quant_(0);

	Fdef(\leapTick, {
		Pbindef(\bend,
			\hiCutoff, l.palm.y.linexp(0, 1, 1000, 2500),
			\loCutoff, l.palm.y.linexp(0, 1, 50, 250),
			\timez, Ptuple([l.pinchStrength.linlin(0, 1, 1.2, 0.3) ! 4]),
			\bend, l.palm.y.lincurve(0, 1, 0, 12, 4),
			\bendLfoDepth, l.pinchStrength.lincurve(0, 1, 1, 0.125, 0.5), // max 0.5
			\panLfoDepth, l.pinchStrength.linlin(0, 1, 0.75, 0),
			\pan, l.palm.x.linlin(0, 1, -0.5, 0.5),
			\dur, Pexprand(0.12, 0.25) * l.pinchStrength.linlin(0, 1, 1, 0.75)
		)
	});
};
)
