(
SynthDef(\airharp, {
	arg freq = 440, pan = 0, amp = 0.1, release = 1.8;
	var sig, env;
	sig = Pulse.ar(freq.lag(0.01));
	env = Env.perc(releaseTime: release).kr(2);
	sig = LPF.ar(sig, freq.lag(0.005) * (4*env + 1)) * env;
	sig = Pan2.ar(sig, pan, amp.lag(0.2));
	Out.ar(0, sig);
}).add;

~examples['1A'] = {
	var lastFreq = 0;
	var inv = Env([1,0], [1], \lin);
	Fdef(\leapTick, {
		var freq = Scale.harmonicMinor.degreeToFreq(
			l.palm.y.linlin(0, 1, 0, 20).round,
			48.midicps,
			1
		);
		(lastFreq != freq).if({
			Synth(\airharp, [
				\freq, freq,
				\release, inv[l.pinchStrength].linlin(0, 1, 0.2, 1.8),
				\pan, l.palm.x.linlin(0, 1, -1, 1),
				\amp, l.translationLength.linlin(0, 10, -20, -10).dbamp
			], ~group);
			lastFreq = freq;
		});
	});
};

~examples['1B'] = {
	var steps = (l.pinchStrength.linlin(0,1,6,0)).round(1).asInteger;
	var durWeights = [
		Env([1,0], [1], -2),
		Env.sine,
		Env([0,1], [1], 2)
	];

	~loop = Pbindef(\airharp,
		\instrument, \airharp,
		\pan, (l.palm.x + Pgauss(0.0, 0.1)).linlin(0, 1, -1, 1),
		\mtranspose, (l.palm.y * 10).round,
		\release, l.palm.y.linexp(0,1,0.5,4),
		\degree, Pwhite(steps.neg, steps),
		\root, 0,
		\scale, Scale.harmonicMinor,
		\octave, 4,
		\dur, Prand([0.25, 0.5], inf),
		\db, Pgauss(-10, 2),
		\group, ~group
	).quant_([1,0]).play;

	Fdef(\leapTick, {
		var steps = (l.pinchStrength.linlin(0,1,6,0)).round(1).asInteger;
		Pbindef(\airharp,
			\pan, (l.palm.x + Pgauss(0.0, 0.1)).linlin(0, 1, -1, 1),
			\mtranspose, (l.palm.y * 10).round,
			\release, l.palm.y.linexp(0,1,0.5,4),
			\degree, Pwhite(steps.neg, steps),
			//\dur, l.palm.y.linexp(0,1,1/16, 1/4).round(1/16) * 4 * 60/120,
			\dur, Pwrand([1, 2, 4] * 0.125, durWeights.collect{|e|e.at(l.palm.y)}.normalizeSum, inf).trace,
		).quant_([1,0]);
	});
};
)
