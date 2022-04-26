(
// To start the sound engine and user interface, place the cursor anywhere in this document and press Ctrl+Enter

l = ();
~examples = ();

~handIsPresent = false;

~leapHandlerSetup = {
	var leapLimits = (
		x: (min: -210, max: 210),
		y: (min: 50, max: 410),
		z: (min: -200, max: 200),
		maxTrans: 15
	);

	// running average buffers
	var transVecBuf = List.newFrom(0!5)!2;
	var transLenBuf = List.newFrom(0!10);

	var transLenTick = { |in = 0|
		transLenBuf.pop;
		transLenBuf.addFirst(in);
		l.transLenAvg = transLenBuf.mean;
	};

	var transVecTick = {
		arg in = [0, 0];
		transVecBuf.do{ |list,i|
			list.pop;
			list.addFirst(in[i]);
		};
		l.transVecAvg = transVecBuf.collect{|v|v.mean};
	};

	var translationAverager = Routine{
		[transLenBuf.size, transVecBuf.size].maxItem.do{
			transLenTick.value;
			transVecTick.value;
			0.05.wait;
		};
	};

	// handlers for incoming data
	[
		'/leap/right/palmPosition',
		'/leap/right/translationLength',
		'/leap/right/pinchStrength',
		'/leap/right/grabStrength',
		'/leap/right/translation',
		'/leap/right/confidence'
	].do{ |path|
		var parameter = PathName(path.asString).fileName.asSymbol;
		OSCdef(parameter.asSymbol, { |msg|
			var in = msg[1..];
			// rename palmPosition
			if (parameter == 'palmPosition', {parameter = 'palm'});
			// avoid storing as array if only one parameter
			if (in.size == 1, { in = in.first });

			// handle special cases
			l[parameter] = switch(parameter,
				\palm, {
					var dict = ();
					[\x, \y, \z].do{ |coord,i|
						dict[coord] = in[i].linlin(
							leapLimits[coord].min,
							leapLimits[coord].max,
							0, 1
						)
					};
					l.palmVec = dict.x@dict.y;
					dict;
				},
				\translationLength, {
					in = in.linlin(0, leapLimits.maxTrans, 0, 1);
					transLenTick.value(in);
					in;
				},
				\translation, {
					in = in[..1].collect{ |c|
						c.linlin(
							leapLimits.maxTrans.neg,
							leapLimits.maxTrans,
							-1, 1)
					};
					transVecTick.value(in);
					in[0]@in[1];
				},
				// default case
				{ in }
			);
		}, path);
	};

	[
		'/leap/right/newFrame'
	].do{ |path|
		var parameter = PathName(path.asString).fileName.asSymbol;
		OSCdef(parameter.asSymbol, Fdef(\leapTick), path);
	};

	OSCdef(\enter, {
		~handIsPresent = true;
		translationAverager.stop;
		translationAverager.reset;
		Fdef(\enter).value;
	}, '/leap/right/enter');

	OSCdef(\exit, {
		~handIsPresent = false;
		translationAverager.play;
		Fdef(\exit).value;
	}, '/leap/right/exit');

};

// reset to initial state
~reset = {
	~loop.stop;
	~group.set(\gate, 0);
	Fdef(\enter, {nil});
	Fdef(\exit, {nil});
	Fdef(\leapTick, {nil});
	l = (
		transVecAvg: [0, 0],
		palmVec: 0.5@0.5,
		translation: 0@0,
		palm: (y: 0.5, x: 0.5, z: 0.5),
		pinchStrength: 0,
		grabStrength: 0,
		transLenAvg: 0,
		translationLength: 0
	);
};

~makeGui = {
	{
		var bounds, refresher;

		// hand position and pinch strength visualization
		~visualizer !? { |w|
			~visualizer.isClosed.not.if({
				bounds = w.bounds;
				w.close;
			})
		};

		~visualizer = Window.new('position', bounds ? Rect(
			Window.availableBounds.width * 0.5,
			Window.availableBounds.height * 0.3,
			400, 400)
		).front.alwaysOnTop_(true)
		.background_(Color.black)
		.onClose_({ refresher.stop });

		~visualizer.drawFunc = {
			var x, y, radius = 14;
			~handIsPresent.if({
				x = l.palm.x * (~visualizer.bounds.width - (radius*2)) + radius;
				y = ~visualizer.bounds.height - (l.palm.y * (~visualizer.bounds.height - (radius*2)) + radius);
				Pen.color = Color.red;
				radius = l.pinchStrength.linlin(0, 1, radius, 4);
				Pen.fillOval(
					Rect(
						x-radius,
						y-radius,
						radius*2,
						radius*2
					)
				);
			});
		};

		refresher = Routine {
			loop {
				defer { ~visualizer.refresh };
				25.reciprocal.wait; // 25hz refresh rate
			}
		}.play;

	}.value;

	// control menu
	{
		var bounds;
		var layout = VLayout();
		var buttons = Array.new(8);

		~examples.keys.asArray.sort.do({
			arg key, i;
			var name = 'Start eksempel ' ++ key;
			buttons.add(
				Button()
				.states_([
					[name],
					[name, Color.black, Color.green(0.8, 0.5)]
				])
				.action_({ |btn|
					buttons
					.reject{|b| b == btn}
					.do{|b| b.value_(0)};
					~reset.value;
					if (btn.value == 1, {
						~examples[key].value;
					});
				})
				.minHeight_(50)
				.font_(Font(size: 15))
			)
		});

		buttons.do{|btn|layout.add(btn)};

		// reset button
		layout.add(
			Button()
			.states_([["Stop", Color.black, Color.red(0.8, 0.6)]])
			.action_({
				//Fdef(\stop).value;
				~reset.value;
				buttons.do{|b|b.value_(0)};
			})
			.minHeight_(50)
			.font_(Font(size: 14))
		);

		~gui !? { |w|
			~gui.isClosed.not.if({
				bounds = w.bounds;
				w.close;
			})
		};

		~gui = Window('interface-forsøg', bounds ? Rect(
			Window.availableBounds.width * 0.25,
			Window.availableBounds.height * 0.5,
			300, 300)
		).front.alwaysOnTop_(true)
		.layout_(layout);

	}.value;
};

// reinitialize system on Cmd+Period
CmdPeriod.add(~leapHandlerSetup);
CmdPeriod.add(~reset);
CmdPeriod.add(~makeGui);

ServerTree.removeAll;
ServerTree.add({
	~group = Group.new(s);
}, s);

s.waitForBoot({
	"ex1 - airharp.scd".loadRelative;
	"ex2 - klonk.scd".loadRelative;
	"ex3 - glide.scd".loadRelative;
	s.sync;
	CmdPeriod.run;
});
)