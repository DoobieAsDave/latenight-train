BPM tempo;

Gain master;

SndBuf kick => master;
SndBuf snare => master;
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

-.3 => clavesPan.pan;
.25 => maracasPan.pan;
-.1 => rimPan.pan;

tempo.sixteenthNote => rimDelay.delay;
tempo.eighthNote => rimDelay.max;
.2 => rimDelay.mix;

.5 => snare.gain;
.2 => clap.gain => closedHat.gain => openHat.gain => maracas.gain => claves.gain => rim.gain;

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
    0, 1, 0, 1,
    0, 1, 0, 1,
    0, 1, 0, 1,
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
    0, 0, 1, 0
] @=> int openHatPattern[];

[
    0, 0, 1, 0,
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
] @=> int rimPattern[];

///

function void runKick(int beatLength, int sequence[], dur stepDuration, int allowAccent) {
    while(true) {
        for (0 => int beat; beat < beatLength; beat++) {
            for (0 => int step; step < sequence.cap(); step++) {
                if (sequence[step]) {
                    0 => kick.pos;                    
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
                    1 => closedHat.rate;
                    0 => closedHat.pos;
                }

                if (allowAccent) {
                    if (beat % 2 == 1 && step == 1) {
                        for (0 => int repetition; repetition < 2; repetition++) {                         
                            Math.random2(0, 5) => closedHat.pos;

                            stepDuration / 2 => now;
                        }

                        continue;
                    }

                    if (beat == beatLength - 1 && step >= sequence.cap() - 2) {
                        for (0 => int repetition; repetition < 2; repetition++) {
                            closedHat.rate() - .2 => closedHat.rate;
                            Math.random2(0, 20) => closedHat.pos;

                            stepDuration / 2 => now;
                        }

                        continue;
                    }
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
// 73 bars

Shred kickShred, snareShred, clapShred, clavesShred, maracasShred;
Shred closedHatShred, openHatShred, rimShred;

/* spork ~ runKick(4, kickPattern, tempo.sixteenthNote, 0) @=> kickShred;
spork ~ runSnare(4, snarePattern, tempo.sixteenthNote, 0) @=> snareShred;
spork ~ runClap(4, clapPattern, tempo.sixteenthNote, 1) @=> clapShred;
spork ~ runClosedHat(4, closedHatPattern, tempo.sixteenthNote, 1) @=> closedHatShred;
spork ~ runOpenHat(4, openHatPattern, tempo.sixteenthNote, 0) @=> openHatShred;

while(true) {
    second => now;
} */

//

spork ~ runKick(4, kickPattern, tempo.sixteenthNote, 0) @=> kickShred;
tempo.note * 4 => now;
spork ~ runSnare(4, snarePattern, tempo.sixteenthNote, 0) @=> snareShred;
tempo.note * 4 => now;
spork ~ runClosedHat(4, closedHatPattern, tempo.sixteenthNote, 0) @=> closedHatShred;
tempo.note * 20 => now;
spork ~ runOpenHat(4, openHatPattern, tempo.sixteenthNote, 0) @=> openHatShred;
spork ~ runClap(4, clapPattern, tempo.sixteenthNote, 1) @=> clapShred;
tempo.note * 16 => now;
spork ~ runRim(4, rimPattern, tempo.sixteenthNote, 0) @=> rimShred;
spork ~ runClaves(4, clavesPattern, tempo.sixteenthNote, 0) @=> clavesShred;
tempo.note * 16 => now;
Machine.remove(rimShred.id());
tempo.note * 4 => now;
Machine.remove(openHatShred.id());
Machine.remove(clavesShred.id());
tempo.note * 4 => now;
Machine.remove(closedHatShred.id());
tempo.note * 4 => now;
Machine.remove(snareShred.id());
Machine.remove(clapShred.id());
tempo.note => now;
Machine.remove(kickShred.id());