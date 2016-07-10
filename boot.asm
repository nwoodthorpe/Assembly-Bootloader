; This program shows a functional text field on boot.
[BITS 16]
[ORG 0x7C00]  ;Origin

CALL ListenForInput

Backspace:      ; Logic for doing a backspace
  MOV AH, 0x03
  INT 0x10      ; Grab current cursor coords
  CMP DL, 0x00     ; Are we at col 0? jump to handle if not
  JNE .handle_backspace
  CMP DH, 0x00     ; Are we at row 0? jump to handle if not
  JNE .handle_newline

  RET           ; We're at 0,0, can't do a backspace

  .handle_newline ; Col 0 but not row 0. We need to skip to the last col of the previous row
  
  MOV AH, 0x0F    ; Get video mode and info
  INT 0x10 
  ADD DH, -1
  MOV DL, AH
  MOV AH, 0x02
  INT 0x10       ; Set new cursor position

  .handle_backspace

  CALL MoveCursorBackOne

  MOV AL, 0x20  ; If AL was backspace, change to space
  MOV AH, 0x0A
  INT 0x10
  RET

PrintCharacter: ; Procedure to print character on screen
  CMP  AL, 0x08    ; Check if char is backspace
  JNE .skip_handle_backspace
  CALL Backspace
  RET
  
  .skip_handle_backspace
  MOV BH, 0x00  ; Page no.
  MOV BL, 0x07  ; Text attribute 0x07 is lightgrey font on black background
  MOV AH, 0x0E  ; Tell BIOS that we need to print one charater on screen.

  INT 0x10  ;Call video interrupt

  RET

ListenForInput:  ;Repeatedly check for keyboard input, print if available
  MOV AH, 0x00 ; Set AH to 0 to lock when listening for key
  MOV AL, 0x00 ; Set last key to 0
  INT 0x16   ; Listen for a keypress, save to register AL
 
  CALL PrintCharacter

  CALL ListenForInput
  RET

MoveCursorBackOne: 
  MOV AH, 0x03
  INT 0x10      ; Grab current cursor coords

  ADD DL, -1    ; Move cursor back one place
  
  MOV AH, 0x02
  INT 0x10       ; Set new cursor position
  RET

TIMES 510 - ($ - $$) db 0  ;Fill the rest of sector with 0
DW 0xAA55      ;Add boot signature at the end of bootloader
