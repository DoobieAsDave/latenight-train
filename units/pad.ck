BPM tempo;

Gain master;

SawOsc voice1 => master;
SawOsc voice2 => master;
SawOsc voice3 => master;
SawOsc voice4 => master;

HPF hpf;

SqrOsc subVoice1 => hpf => master;
SqrOsc subVoice2 => hpf => master;

master => ADSR adsr => Pan2 stereo => Echo delay => dac;
delay => Gain feedback => delay;

///

Std.mtof(25) => hpf.freq;
1 => hpf.Q;
.5 => hpf.gain;

tempo.quarterNote => delay.delay;
tempo.quarterNote * 1.25 => delay.max;
.2 => delay.mix;

.5 => voice1.gain => voice2.gain, voice3.gain, voice4.gain;
.5 => subVoice1.gain => subVoice2.gain;

.2 => feedback.gain;
1.0 / 15.0 => master.gain;

/// 

[0, 2, 3, 3, 0, 2, -2, -2, 0, 2, 3, 3, 7, 5, 3, 3] @=> int melody[];
[0, 0, 1, 1, 0, 0,  1,  1, 0, 0, 1, 1, 0, 1, 1, 1] @=> int harmony[];
48 => int key;

///

function void runPad(dur noteDuration) {
    noteDuration * .4 => dur attack;
    noteDuration * .1 => dur decay;
    .8 => float sustain;
    noteDuration * .4 => dur release;

    adsr.set(attack, decay, sustain, release);

    while(true) {
        for (0 => int step; step < melody.cap(); step++) {
            key + melody[step] => int rootNote;

            Std.mtof(rootNote) => voice1.freq;
            
            if (!harmony[step]) {
                Std.mtof(rootNote + 3) => voice2.freq;
            }
            else {
                Std.mtof(rootNote + 4) => voice2.freq;
            }

            Std.mtof(rootNote + 7) => voice3.freq;
            
            if (!harmony[step]) {
                Std.mtof(rootNote + 10) => voice4.freq;
            }
            else {
                Std.mtof(rootNote + 11) => voice4.freq;
            }

            Std.mtof(rootNote - 12) => subVoice1.freq;
            Std.mtof(rootNote - 24) => subVoice2.freq;

            adsr.keyOn();
            noteDuration - release => now;
            adsr.keyOff();
            release => now;
        }
    }
}

///

//tempo.note * 8 => now;
spork ~ runPad(tempo.note);
tempo.note * 44 => now;