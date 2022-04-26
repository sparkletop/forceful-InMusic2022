(
var rates = [0.2, 8];
(
strike: {| atk = 0.02, sus = 0.4, rel = 2 | Env.linen(atk, sus, rel).kr(2) },
slide: {| gate = 1 | Env.asr(3, 1, 3).kr(2, gate) }
).keysValuesDo{ |key, envFunc, num|

	SynthDef(key, {
		arg freq = 220, pan = 0, cutoffOctave = 4, amp = 0.1,	outBus = 0,
		detuneCent = 15, spread = 0.75, lfoRate = 5, lfoDepth = 0.5, lfoLagTime = 0.25;

		var sig, env;

		env = SynthDef.wrap(envFunc);

		sig = 4.collect{ |num|
			var lfo = LFTri.kr(lfoRate.lag(lfoLagTime), Rand(0.9, 1.1) * num * 0.5);
			VarSaw.ar(
				freq: freq * (
					num.linlin(0, 3, -1, 1) * 0.01 *
					LFNoise1.kr(1).unipolar(detuneCent).clip(0, 50)
				).midiratio,
				width: 0)	* lfo.range(1 - lfoDepth.clip(0, 1), 1);
		};

		sig = Splay.ar(sig, spread, center: pan);

		sig = sig + (SinOsc.ar(freq * 0.5) * 0.2);

		sig = (sig * 5).tanh;

		sig = BLowPass.ar(
			sig,
			(freq * 2.pow(cutoffOctave)).clip(20, 20000)
		);

		sig = sig * env;

		sig = Balance2.ar(sig[0], sig[1], pan, amp);

		Out.ar(outBus, sig);
	}, (rates[num]!3)).add;
};

~getMidinote = { |inY|
	inY.linlin(0, 1, 32, 82).round(1)
	.nearestInList([36,43,48,55,60,67,72,79])
};

~examples['3A'] = {
	var started = false, synth;

	var trigFunc = {
		if (started.not && (l.transLenAvg > 0.5), {
			started = true;
			Routine{
				var vecX = l.transVecAvg[0];
				var vecY = l.transVecAvg[1];
				var initPan = l.palm.x.linlin(0,1,-1,1);
				var initFreq = ~getMidinote.value(l.palm.y).midicps;
				var duration = 2;
				var freqCurve = l.translationLength.linlin(0.5, 1, -2, -8);
				var initLfoRate = l.translationLength.linlin(0.5, 1, 5, 10);
				var synth = Synth(\strike, [
					\freq, initFreq,
					\pan, initPan,
					\rel, duration,
					\lfoRate, initLfoRate,
					\lfoDepth, 0.75,
					\cutoffOctave, l.translationLength.linlin(0.5,1,2,4),
					\atk, l.pinchStrength.linlin(0, 1, 0.1, 0.005)
				], ~group);
				var numSteps = duration * 500;
				numSteps.asInteger.do{ |i|
					synth.set(
						\freq, i.lincurve(0,numSteps, 0, 1, freqCurve).linexp(
							0, 1,
							initFreq,
							initFreq * (vecY * 24).round(1).midiratio
						),
						\pan, i.lincurve(
							0,
							numSteps,
							initPan,
							initPan + (vecX * 2),
							4
						),
						\lfoRate, i.lincurve(0, numSteps, initLfoRate, initLfoRate * 0.3, -3)
					);
					if (i > 200 && (l.transLenAvg < 0.07), {started = false});
					0.002.wait;
				};

				started = false;
			}.play
		});
	};

	Fdef(\enter, {
		~loop = Routine{
			loop {
				trigFunc.value;
				0.002.wait;
			}
		}.play
	});

	Fdef(\exit, {
		~loop.notNil.if({
			~loop.stop;
			synth.set(\gate, 0);
			Routine{ 0.2.wait; started = false; }.play;
		});
	});
};

~examples['3B'] = {
	var defaultFreq = ~getMidinote.value(0.5).midicps;
	var	synth = Synth(\slide, [
		\freq, defaultFreq,
		\lfoRate, 5,
		\lfoDepth, 0.75,
		\atk, 2,
		\rel, 3,
		\lfoLagtime, 1
	], ~group);

	~loop = Routine{
		loop {
			(
				freq: ~getMidinote.value(l.palm.y).midicps,
				pan: l.palm.x.linlin(0,1,-1,1),
				cutoffOctave: l.pinchStrength.linlin(0,1,4,2),
				lfoRate: l.pinchStrength.linlin(0,1, 5,10),
				lfoDepth: l.pinchStrength.linlin(0,1, 0.75, 1)
			).keysValuesDo{|key,val| synth.set(key, val)};
			0.01.wait;
		}
	};

	Fdef(\enter, {
		~loop.reset;
		~loop.play;
	});

	Fdef(\exit, {
		~loop.stop;
		(
				freq: defaultFreq,
				pan: 0,
				cutoffOctave: 4,
				lfoRate: 5,
				lfoDepth: 0.75
			).keysValuesDo{|key,val| synth.set(key, val)};
	});
};
)
