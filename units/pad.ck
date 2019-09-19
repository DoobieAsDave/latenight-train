BPM tempo;

Gain master;

SawOsc voice1 => master;
SawOsc voice2 => master;
SawOsc voice3 => master;
SawOsc voice4 => master;

HPF hpf;

SqrOsc subVoice1 => hpf => master;
SqrOsc subVoice2 => hpf => master;

master => ADSR adsr => LPF lpf => Pan2 stereo => dac;

///

Std.mtof(25) => hpf.freq;
1 => hpf.Q;
.5 => hpf.gain;

.8 => lpf.Q;
.8 => lpf.gain;

.5 => voice1.gain => voice2.gain, voice3.gain, voice4.gain;
.5 => subVoice1.gain => subVoice2.gain;

/// 

[
    0, 2, 3,
    0, 2, -2,
    0, 2, 3,
    7, 5, 3
] @=> int melody[];
[
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 1, 1
] @=> int harmonies[];
[
    tempo.note, tempo.note, tempo.note * 2,
    tempo.note, tempo.note, tempo.note * 2,
    tempo.note, tempo.note, tempo.note * 2,
    tempo.note, tempo.note, tempo.note * 2
] @=> dur durations[];
48 => int key;

1.0 / 6.0 => float maxVolume;

float masterVolume;
float cutOff;
dur delayTime;
float stereoPan;

///

function void swipeVolume(Gain master, dur t, float min, float max, float step, int riseVolume) {
    step => float crement;
    max - min => float range;
    (range / step) => float stepNumber;

    if (riseVolume) {
        min => masterVolume;
    }
    else {
        max => masterVolume;
    }

    while(true) {
        masterVolume => master.gain;
        masterVolume + crement => masterVolume;

        if (riseVolume) {
            if (masterVolume <= max) {
                step => crement;
            }
            else {
                0 => crement;
            }
        }
        else {
            if (masterVolume >= min) {
                step * -1 => crement;
            }
            else {
                0 => crement;
            }
        }
        
        t / stepNumber => now;
    }
}

function void riseVolume(Gain mater, dur t, float min, float max, float step) {
    step => float crement;
    max - min => float range;
    (range / step) => float stepNumber;

    min => masterVolume;

    while(true) {
        masterVolume => master.gain;
        masterVolume + crement => masterVolume;       

        <<< masterVolume >>>;

        t / stepNumber => now;
    }
}
function void lowerVolume(Gain master, dur t, float min, float max, float step) {
    step => float crement;
    max - min => float range;
    (range / step) => float stepNumber;

    max => masterVolume;

    while(true) {
        masterVolume => master.gain;
        masterVolume - crement => masterVolume;        

        <<< masterVolume >>>;

        t / stepNumber => now;
    }
}

function void swipeFilter(LPF filter, dur t, float min, float max, float step) {
    step => float crement;
    max - min => float range;
    (range / step) * 2 => float stepNumber;

    min => cutOff;

    while(true) {
        cutOff => filter.freq;
        cutOff + crement => cutOff;

        if (cutOff >= max) {
            step * -1 => crement;
        }
        else if (cutOff <= min) {
            step => crement;
        }              

        t / stepNumber => now;
    }
}
function void swipeDelay(Echo delay, dur t, dur min, dur max, dur step) {
    step => dur crement;
    max - min => dur range;
    (range / step) * 2 => float stepNumber;

    min => delayTime;

    /* .5 => delay.mix;
    .5 => feedback.gain; */

    while(true) {
        delayTime => delay.delay;
        delayTime * 2 => delay.max;

        delayTime + crement => delayTime;

        if (delayTime >= max) {
            step * -1 => crement;
        }
        else if (delayTime <= min) {
            step => crement;
        }

        <<< delayTime >>>;

        t / stepNumber => now;
    }
}
function void panStereo(Pan2 stereo, dur t, float min, float max, float step) {
    step => float crement;
    max - min => float range;
    (range / step) * 2 => float stepNumber;

    min => stereoPan;

    while(true) {
        stereoPan => stereo.pan;
        stereoPan + crement => stereoPan;

        if (stereoPan >= max) {
            step * -1 => crement;
        }
        else if (stereoPan <= min) {
            step => crement;
        }       

        t / stepNumber => now;
    }
}

///

function void runPad() {
    while(true) {
        for (0 => int step; step < melody.cap(); step++) {
            durations[step] * .4 => dur attack;
            durations[step] * .1 => dur decay;
            float sustain;
            dur release;

            if (durations[step] != tempo.note * 2) {
                .8 => sustain;
                durations[step] * .4 => release;
            }
            else {
                1.0 => sustain;
                durations[step] * .6 => release;
            }            

            adsr.set(attack, decay, sustain, release);

            //

            key + melody[step] => int rootNote;

            Std.mtof(rootNote) => voice1.freq;
            
            if (!harmonies[step]) {
                Std.mtof(rootNote + 3) => voice2.freq;
            }
            else {
                Std.mtof(rootNote + 4) => voice2.freq;
            }

            Std.mtof(rootNote + 7) => voice3.freq;
            
            if (!harmonies[step]) {
                Std.mtof(rootNote + 10) => voice4.freq;
            }
            else {
                Std.mtof(rootNote + 11) => voice4.freq;
            }

            Std.mtof(rootNote - 12) => subVoice1.freq;
            Std.mtof(rootNote - 24) => subVoice2.freq;

            adsr.keyOn();
            durations[step] - release => now;
            adsr.keyOff();
            release => now;
        }
    }
}

///
// 96 bars

Shred padShred, volumeShred, filterShred, delayShred, stereoShred;

spork ~ swipeVolume(master, tempo.note * 16, .0, maxVolume, .001, 1) @=> volumeShred;
spork ~ panStereo(stereo, tempo.quarterNote, -.25, .25, .01) @=> stereoShred;
spork ~ swipeFilter(lpf, tempo.note, Std.mtof(20), Std.mtof(75), 20.0) @=> filterShred;
spork ~ runPad() @=> padShred;
tempo.note * 16 => now;

Machine.remove(volumeShred.id());
tempo.note * 16 => now;

Machine.remove(stereoShred.id());
Machine.remove(filterShred.id());
spork ~ panStereo(stereo, tempo.quarterNote, -.4, .25, .01) @=> stereoShred;
spork ~ swipeFilter(lpf, tempo.note, Std.mtof(20), Std.mtof(85), 20.0) @=> filterShred;
tempo.note * 16 => now;


Machine.remove(stereoShred.id());
Machine.remove(filterShred.id());
spork ~ panStereo(stereo, tempo.quarterNote, -.6, .75, .01) @=> stereoShred;
spork ~ swipeFilter(lpf, tempo.note, Std.mtof(20), Std.mtof(90), 20.0) @=> filterShred;
tempo.note * 16 => now;

Machine.remove(filterShred.id());
spork ~ swipeFilter(lpf, tempo.note / 2, Std.mtof(20), Std.mtof(80), 10.0) @=> filterShred;
tempo.note * 16 => now;

Machine.remove(stereoShred.id());
Machine.remove(filterShred.id());
spork ~ panStereo(stereo, tempo.quarterNote, -.4, .25, .1) @=> stereoShred;
spork ~ swipeFilter(lpf, tempo.note, Std.mtof(20), Std.mtof(72), 20.0) @=> filterShred;
tempo.note * 8 => now;

spork ~ swipeVolume(master, tempo.note * 4, 0, master.gain(), .001, 0) @=> volumeShred;
tempo.note * 8 => now;
Machine.remove(volumeShred.id());
Machine.remove(filterShred.id());
Machine.remove(padShred.id());