#importonce

#import "../lib/labels.asm"
#import "../lib/input.asm"
#import "../lib/screen.asm"
#import "state.asm"
#import "config.asm"
#import "music.asm"

Intro: {

    // border flashing
    inc VIC_BORDER_COLOUR

    ldx #00
    jsr AnimatedBorder

    lda STATE.entered
    cmp #StateEntered
    beq INTRO_DRAW
    jmp INTRO_INPUT

    INTRO_DRAW:

        // set up the music, IRQ's and or game specific stuff
        #if HAS_MUSIC
            ldx #0
            ldy #0
            lda #MUSIC_INTRO
            jsr music.init
        #endif

        setTextColour(LIGHT_GREEN)
        centreText(@"<- ! a c=64 adventure ! ->", 10);
        centreText("introduction", 12);
        centreText("welcome to a game", 14);
        // reset state
        stateTransitioned(GameStateIntro);

    INTRO_INPUT:

        checkKey(KeySpace, true);
        beq NOOP

    KEY:
        // goto instructions screen
        transitionState(GameStateInstructions);

    NOOP:
        rts
}

Instructions: {

    ldx #00
    jsr AnimatedBorder

    lda STATE.entered
    cmp #StateEntered
    beq INSTRUCTION_DRAW
    jmp INSTRUCTION_INPUT

    INSTRUCTION_DRAW:

        setBorderColour(BLACK);
        setTextColour(WHITE);
        centreText(@"<- ! a c=64 adventure ! ->", 10)
        centreText("instructions", 12);
        centreText("! just play it !", 14);
        
        // reset state
        stateTransitioned(GameStateInstructions);

    INSTRUCTION_INPUT:

        checkKey(KeySpace, true);
        beq NOOP

    KEY:
        transitionState(GameStateNewGame);

    NOOP:
        rts
}

