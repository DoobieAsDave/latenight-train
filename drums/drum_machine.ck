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

Shred kickSh, snareSh, clapSh, clavesSh, maracasSh, closedHatSh, openHatSh, rimSh;

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

///

[   1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0
] @=> int kickPattern[];
[   1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 1,
    1, 0, 1, 0
] @=> int kickPatternAccent[];

[   0, 0, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
    1, 0, 0, 0
] @=> int snarePattern[];
[   0, 0, 0, 0,
    0, 0, 0, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
] @=> int clapPattern[];

[   0, 0, 0, 1,
    0, 0, 0, 0,
    0, 0, 1, 1,
    0, 1, 0, 0
] @=> int clavesPattern[];
[   0, 1, 0, 1,
    0, 1, 0, 1,
    0, 1, 0, 1,
    0, 1, 0, 1
] @=> int maracasPattern[];

[   1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1
] @=> int closedHatPattern[];
[   0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0
] @=> int openHatPattern[];

[   0, 0, 1, 0,
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

                // if accent on
                if (allowAccent) {
                    1.2 => clap.rate;

                    // random clap on every 2nd beat                    
                    if (beat % 2 == 1) {
                        if (step == sequence.cap() - 3 && Math.random2(0, 1)) {
                            0 => clap.pos;
                        }
                    }
                    
                    // end tripplets
                    if (beat == beatLength - 1 && step >= sequence.cap() - 4) {
                        Math.random2(10, 30) => clap.pos;
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

/* spork ~ runKick(4, kickPattern, tempo.sixteenthNote, 0) @=> kickSh;
spork ~ runSnare(4, snarePattern, tempo.sixteenthNote, 0) @=> snareSh;
spork ~ runClosedHat(4, closedHatPattern, tempo.sixteenthNote, 0) @=> closedHatSh;
spork ~ runClap(4, clapPattern, tempo.sixteenthNote, 1) @=> clapSh;
spork ~ runClaves(4, clavesPattern, tempo.sixteenthNote, 0) @=> clavesSh;
spork ~ runMaracas(4, maracasPattern, tempo.sixteenthNote, 0) @=> maracasSh;
spork ~ runOpenHat(4, openHatPattern, tempo.sixteenthNote, 0) @=> openHatSh;
spork ~ runRim(4, rimPattern, tempo.sixteenthNote, 0) @=> rimSh;
tempo.note * 1000 => now; */


spork ~ runKick(4, kickPattern, tempo.sixteenthNote, 0) @=> kickSh;
tempo.note * 4 => now;
spork ~ runSnare(4, snarePattern, tempo.sixteenthNote, 0) @=> snareSh;
tempo.note * 4 => now;
spork ~ runClosedHat(4, closedHatPattern, tempo.sixteenthNote, 0) @=> closedHatSh;
spork ~ runClap(4, clapPattern, tempo.sixteenthNote, 0) @=> clapSh;
tempo.note * 16 => now;
spork ~ runClaves(4, clavesPattern, tempo.sixteenthNote, 0) @=> clavesSh;
spork ~ runMaracas(4, maracasPattern, tempo.sixteenthNote, 0) @=> maracasSh;
tempo.note * 8 => now;
spork ~ runOpenHat(4, openHatPattern, tempo.sixteenthNote, 0) @=> openHatSh;
spork ~ runRim(4, rimPattern, tempo.sixteenthNote, 0) @=> rimSh;

<<< "all drums added" >>>;
tempo.note * 8 => now;

Machine.remove(rimSh.id());
Machine.remove(openHatSh.id());
tempo.note * 4 => now;
Machine.remove(maracasSh.id());
Machine.remove(clavesSh.id());
tempo.note * 4 => now;
Machine.remove(clapSh.id());
Machine.remove(closedHatSh.id());
tempo.note * 4 => now;
Machine.remove(snareSh.id());
tempo.note * 4 => now;
Machine.remove(kickSh.id());