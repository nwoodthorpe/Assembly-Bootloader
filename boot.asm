[BITS 16]
[ORG 0x7C00]  ;Origin

MOV AL, 65
CALL PrintCharacter
CALL ListenForInput

PrintCharacter:  ;Procedure to print character on screen
  CMP  AL, 8    ; Check if char is backspace
  MOV AH, 0x0E  ; Tell BIOS that we need to print one charater on screen.
  JNE .skip_handle_backspace

  MOV AH, 3
  INT 10H       ; Grab current cursor coords
  CMP DL, 0     ; Are we at col 0? jump to handle if not
  JNE .handle_backspace
  CMP DH, 0     ; Are we at row 0? jump to handle if not
  JNE .handle_backspace

  RET           ; We're at 0,0, can't do a backspace


  .handle_backspace

  MOV AL, 0x20  ; If AL was backspace, change to space

  CALL MoveCursorBackOne
  MOV AH, 0x0A

  .skip_handle_backspace
  MOV BH, 0x00  ; Page no.
  MOV BL, 0x0D  ; Text attribute 0x07 is lightgrey font on black background

  INT 0x10  ;Call video interrupt

  RET

ListenForInput:  ;Repeatedly check for keyboard input, print if available
  MOV AH, 0 ; Set AH to 0 to lock when listening for key
  MOV AL, 0 ; Set last key to 0
  INT 16H   ; Listen for a keypress, save to register AL
 
  CALL PrintCharacter

  CALL ListenForInput
  RET

MoveCursorBackOne: 
  MOV AH, 3
  INT 10H       ; Grab current cursor coords

  ADD DL, -1    ; Move cursor back one place
  
  MOV AH, 2
  INT 10H       ; Set new cursor position
  RET

TIMES 510 - ($ - $$) db 0  ;Fill the rest of sector with 0
DW 0xAA55      ;Add boot signature at the end of bootloader
