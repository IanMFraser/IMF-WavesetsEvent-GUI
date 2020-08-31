/***************************************************
****************************************************

A simple GUI for Waveset Synthesis.

Requires WavesetsEvents, which should be placed in your
SC extensions folder.

Shout out to Julian Rohrhuber for WavesetsEvent!
https://github.com/musikinformatik/WavesetsEvent

***************************************************
***************************************************/

(
s.waitForBoot{

var numSliders = 11;
var numButtons = 3;
var switchFile, sliders, buttons, actions, labels, controls, init, panning;

WavesetsEvent.prepareSynthDefs;

~wavesets = ~wavesets ?? {
	WavesetsEvent.read(Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff")
};

Tdef(\ws, {|ev|
		ev.which = 0;
	inf.do{ |i|

		var event = ~wavesets.asEvent((
			start: (( i % ~wavesets.size) * ~transposition) + ~shuf.rand, //from which waveset to start * tansposition + waveset shuffle amount
			num: ~numWs, //how many wavesets to play
			repeats: ~repeats, // how many times to repeat the selected wavesets
			rate: ~playRate, //playback speed of the audio file
			rate2: ~playRate2, //end playback speed of the audio file (will create a linear glisson sweep)
			amp: if(~prob.coin, {~volume}, {0}), //scale the amplitude of the original sound + random waveset omission from 0 - 100%
			pan: switch(ev.which.next, 0, {~pan}, 1, {[-1, 1].choose}), //stereo panorama position
			legato: ~legato, //scales the duration, so that wavesets will overlap or have gaps between them.
			distance: ~distance //distancing between wavesets
			));
		event.play;
		(event[\dur] + event[\distance]).wait;
	}
});


//gui
w = Window.new("wavesets", Rect(128, 64, 400, 500)).front;
w.addFlowLayout;
w.view.decorator.gap=5@5;

	labels = ["numWs", "repeats", "playRate", "playRate2", "volume", "pan",  "legato", "shuffle", "transp", "omission", "distance"];

controls = (
		numWs: [1, 10, \lin, 1],
		repeats: [1, 10, \lin, 1],
		playRate: [-10, 10, \lin],
		playRate2: [-10, 10, \lin],
		volumes: [0, 1, \lin],
		pan: [-1, 1, \lin],
		legato: [0.001, 2, \lin],
		shuffle: [0, 100, \lin, 1],
		transp: [0.25, 10, \lin, 0.25],
		omission: [0, 1, 'lin'],
		distance: [0, 0.5, 'lin']
	);

init = [1, 2, 1, 1.5, 1, 0, 1, 0, 1, 1, 0];

actions = (
		numWs: {|v| ~numWs = v},
		repeats: {|v| ~repeats = v},
		playRate: {|v| ~playRate = v},
		playRate2: {|v| ~playRate2 = v},
		volume: {|v| ~volume = v},
		pan: {|v| ~pan = v},
		legato: {|v| ~legato = v},
		shuffle: {|v| ~shuf = v},
		transp: {|v| ~transposition = v},
		omission: {|v| ~prob = v},
		distance: {|v| ~distance = v}
	);

//create buttons
buttons = numButtons.collect{|i|
	Button.new(w, 125@30);
};

//create sliders
sliders = numSliders.collect{|i|
		EZSlider.new(w, 390@30, labels[i], controls[labels[i].asSymbol], {|sl| actions[labels[i].asSymbol].(sl.value)}, init[i], true)
		.setColors(sliderBackground: Color.rand);
};

//new soundfile button
buttons[0]
.states_(
	[["Switch File", Color.black]]
)
.action_({|obj|
	Dialog.openPanel({ | path |
		var ws = WavesetsEvent.new;
		ws.readChannel(path, onComplete: { ~wavesets = ws; ~path = path })
	});
});

//start button
buttons[1]
.states_(
	[["Start", Color.black]]
)
.action_({|obj|
	Tdef(\ws).play;
});

//start button
buttons[2]
.states_(
	[["Stop", Color.black]]
)
.action_({|obj|
	Tdef(\ws).stop;
});

//auto-panning
panning = CheckBox.new(w, 120@30);
panning.action = {|obj|
		if(obj.value, {Tdef(\ws).set(\which, 1)}, {Tdef(\ws).set(\which, 0)})
};
panning.string = "auto-pan";

}
)
