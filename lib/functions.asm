#importonce

#import "labels.asm"

.function neg(value) {
	.return value ^ $FF
}
.assert "neg($00) gives $FF", neg($00), $FF
.assert "neg($FF) gives $00", neg($FF), $00
.assert "neg(%10101010) gives %01010101", neg(%10101010), %01010101

.macro fill1kbAddressMulti(listKVP) {
    // set up the counter
    ldx #0
    loop:
    .for(var i = 0; i < listKVP.size(); i++) {
        .var ram = listKVP.get(i);
        .var address = ram.get(0);
        .var val = ram.get(1);
        lda #val
        sta address, x
        sta address + $0100, x
        sta address + $0200, x
        sta address + $0300, x
    }
    inx
    bne loop
}

.macro fill1kbAddress(address, value) {
    lda #value
    ldx #$00
    loop: // until x wraps
        sta address, x
        sta address + $0100, x
        sta address + $0200, x
        sta address + $0300, x
        inx
        bne loop
}

.macro copy1kbAddress(origin, destination) {
    ldx $00
    loop:
        lda origin, x
        sta destination, x
        lda origin + $0100, x
        sta destination + $0100, x
        lda origin + $0200, x
        sta destination + $0200, x
        lda origin + $0300, x
        sta destination + $0300, x
        inx
        bne loop
        .var destinationEnd = destination + $0300 + 255;
        {}.print "copied 1k from origin : $" + toHexString(origin) + ", to dest : $" + toHexString(destination) + " - $" + toHexString(destinationEnd);
}


/*
flips between exposing character rom and registers at $d000
*/
.macro toggleCharacterRomVisible(visible) {
    .var mask = visible ? %11111011 : %11111111;
    sei
    enableRomPaging(true);
    lda PROCESSOR_PORT
    and #mask
    sta PROCESSOR_PORT
    enableRomPaging(false);
    cli
}
/*
pages basic and kernal roms in or out
*/
.macro configureRoms(basicEnabled, kernalEnabled) {
    .var mask = %11111100;
    .if (basicEnabled) {
        .eval mask += 1
    }
    .if (kernalEnabled) {
        .eval mask += 2
    }
    sei
    enableRomPaging(true);
    lda PROCESSOR_PORT
    and #mask
    sta PROCESSOR_PORT
    enableRomPaging(false);
    cli
}
/*
set read / write permissions on the PROCESSOR_PORT register
*/
.macro enableRomPaging(bool) {
    .var maskRead = %11111000
    .var maskWrite = %00000111

    lda PROCESSOR_PORT_ACCESS
    .if (bool) {
        ora #maskWrite
    } else {
        and #maskRead
    }
    sta PROCESSOR_PORT_ACCESS
}