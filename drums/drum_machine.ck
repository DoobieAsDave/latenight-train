BPM tempo;

Gain master;

SndBuf kick => LPF kickFilter => master;
SndBuf snare => NRev snareReverb => master;
SndBuf clap => master;
SndBuf claves => Pan2 clavesPan => master;
SndBuf maracas => Pan2 maracasPan => master;
SndBuf closedHat => master;
SndBuf openHat => master;
SndBuf rim => Pan2 rimPan => Echo rimDelay => master;
rimDelay => Gain rimDelayFeedback => rimDelay;

master => dac;

///

me.dir(-1) + "audio/kick.wav" => kick.read;
me.dir(-1) + "audio/snare.wav" => snare.read;
me.dir(-1) + "audio/clap.wav" => clap.read;
me.dir(-1) + "audio/claves.wav" => claves.read;
me.dir(-1) + "audio/maracas.wav" => maracas.read;
me.dir(-1) + "audio/closed_hat.wav" => closedHat.read;
me.dir(-1) + "audio/open_hat.wav" => openHat.read;
me.dir(-1) + "audio/rim.wav" => rim.read;

kick.samples() => kick.pos;
snare.samples() => snare.pos;
clap.samples() => clap.pos;
claves.samples() => claves.pos;
maracas.samples() => maracas.pos;
closedHat.samples() => closedHat.pos;
openHat.samples() => openHat.pos;
rim.samples() => rim.pos;

-.8 => clavesPan.pan;
.25 => maracasPan.pan;
-.1 => rimPan.pan;

tempo.sixteenthNote => rimDelay.delay;
tempo.eighthNote => rimDelay.max;
.2 => rimDelay.mix;

Std.mtof(120) => kickFilter.freq;
1.5 => kickFilter.Q;
1 => kickFilter.gain;

.8 => kick.rate;
1.05 => snare.rate;

.025 => snareReverb.mix;

.5 => kick.gain;
.5 => snare.gain;
.1 => clap.gain => closedHat.gain => claves.gain => rim.gain;
.05 => openHat.gain => maracas.gain;

.3 => rimDelayFeedback.gain;

1 => master.gain;

///

[
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0
] @=> int kickPattern[];
[
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 1,
    1, 0, 1, 0
] @=> int kickPatternAccent[];

[
    0, 0, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
    1, 0, 0, 0
] @=> int snarePattern[];
[
    0, 0, 0, 0,
    0, 0, 0, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
] @=> int clapPattern[];

[
    0, 0, 0, 1,
    0, 0, 0, 0,
    0, 0, 1, 1,
    0, 1, 0, 0
] @=> int clavesPattern[];
[
    1, 0, 0, 1,
    0, 1, 0, 1,
    1, 1, 0, 0,
    0, 1, 0, 1
] @=> int maracasPattern[];

[
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1
] @=> int closedHatPattern[];
[
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 1
] @=> int openHatPattern[];

[
    0, 0, 1, 0,
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
] @=> int rimPattern[];

float masterVolume;

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
            if (masterVolume >= min) {
                step * -1 => crement;
            }
            else {
                0 => crement;
            }
        }
        else {
            if (masterVolume <= max) {
                step => crement;
            }
            else {
                0 => crement;
            }
        }

        <<< masterVolume >>>;

        t / stepNumber => now;
    }
}

///

function void runKick(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => kick.pos;                    
                }

                if (allowAccent) {
                    if (beat == beatLength - 1 && step == sequence.cap() - 1) {
                        (kick.samples() / 2) - 20 => kick.pos;
                    }
                }
                
                stepDuration => now;
            }
        }
    }
}
function void runSnare(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => snare.pos;
                }

                stepDuration => now;
            }
        }
    }
}
function void runClap(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {            
            for (0 => int step; step < sequence.cap(); step++) {                
                if (sequence[step]) {
                    1.0 => clap.rate;
                    0 => clap.pos;
                }
                
                if (allowAccent) {
                    1.2 => clap.rate;
                                     
                    if (beat == 0 && step == 1) {
                        0 => clap.pos;
                    }

                    if (beat == beatLength - 1 && step == 13) {
                        0 => clap.pos;
                    }
                }
                
                stepDuration => now;
            }
        }
    }
}
function void runClaves(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => claves.pos;
                }

                stepDuration => now;
            }
        }
    }
}
function void runMaracas(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => maracas.pos;
                }

                stepDuration => now;
            }
        }
    }
}
function void runClosedHat(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    .1 => closedHat.gain;
                    1 => closedHat.rate;
                    0 => closedHat.pos;
                }

                stepDuration => now;
            }
        }
    }
}
function void runOpenHat(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => openHat.pos;
                }                

                stepDuration => now;
            }
        }
    }
}
function void runRim(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => rim.pos;
                }

                stepDuration => now;
            }
        }
    }
}

///
// 96 bars

Shred kickShred, snareShred, clapShred, clavesShred, maracasShred;
Shred closedHatShred, openHatShred, rimShred, volumeShred;

spork ~ runKick(4, kickPattern, tempo.sixteenthNote, 1) @=> kickShred;
tempo.note * 8 => now;
spork ~ runClosedHat(4, closedHatPattern, tempo.sixteenthNote, 1) @=> closedHatShred;
tempo.note * 8 => now;
spork ~ runSnare(4, snarePattern, tempo.sixteenthNote, 0) @=> snareShred;
tempo.note * 8 => now;
spork ~ runClap(4, clapPattern, tempo.sixteenthNote, 1) @=> clapShred;
spork ~ runMaracas(4, maracasPattern, tempo.sixteenthNote, 0) @=> maracasShred;
tempo.note * 8 => now;
spork ~ runOpenHat(4, openHatPattern, tempo.sixteenthNote, 0) @=> openHatShred;
spork ~ runClaves(4, clavesPattern, tempo.sixteenthNote, 0) @=> clavesShred;
tempo.note * 16 => now;
spork ~ runRim(4, rimPattern, tempo.sixteenthNote, 0) @=> rimShred;
tempo.note * 40 => now;
Machine.remove(rimShred.id());
Machine.remove(openHatShred.id());
Machine.remove(clapShred.id());
Machine.remove(maracasShred.id());
spork ~ swipeVolume(master, tempo.note * 8, 0, master.gain(), .001, 0) @=> volumeShred;
tempo.note * 4 => now;
Machine.remove(snareShred.id());
Machine.remove(kickShred.id());
Machine.remove(closedHatShred.id());
tempo.note * 4 => now;
Machine.remove(clavesShred.id());
Machine.remove(volumeShred.id());