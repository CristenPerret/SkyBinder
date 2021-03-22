#SingleInstance force
#NoEnv
SetBatchLines, -1
SetDefaultMouseSpeed, 0 ; Move mouse instantly

OnMessage(0x201, "WM_LBUTTONDOWN") ;left click drag trigger
; OnMessage(0x204, "WM_RBUTTONDOWN") ; right click infobox trigger






; Populates a HotKey for every one listed in ActionName
ActionName :=["END TURN [1]"
,"P DECK [2]"
,"P GRAVE [3]"
,"P BOARD [4]"
,"P HAND [5]"
,"ENE GRAVE [6]"
,"ENE BOARD [7]"
,"ENE HAND [8]"
,"HiSTORY [9]"
,"MUTE [10]"
,"OPTiONS [11]"
,"CONCEDE [12]"
,"GUi(F8) [13]"
,"RELOADUi [14]"
,"(DEV) GAP [15]"]



#actions = % ActionName.MaxIndex() ; Gets the count from the array to make the hotkey fields.

; Associating the functions to the labels are listed at the very bottom of the script 
; as 'Action#:'

version := "v1.3" ; 03/22/21
PlayerDeck := "d" ; actual in-game binds??
PlayerGrave := "g" ; actual in-game binds??

;--------------------------------------------------------------------------------------------------
; THIS SECTION ISNT USER-FRIENDLY. BEWARNED IF YOU'RE NOT VERSED IN AHK'S SYNTAX.
;--------------------------------------------------------------------------------------------------

; Tray options ----
TrayTip, SkyBinder %version%,,16
Menu, Tray, Icon, Assets\Skybinder.ico, 1,1
Menu, tray, Tip, SkyBinder %version%
Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Keybinds, Action13
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Default, Keybinds
; GUI -----
global guiWidth := 206
Gui +hWndhMainWnd
Gui, +AlwaysOnTop
Gui -0x10000 -0x30000 -0xC00000
Gui Color, 0x2F204C
Gui, Add, Radio, x-15 y-15 ;Important to not automatically bind keys on opening gui
Gui Add, Picture, x4 y1 w160 h33, Assets\Titlebar.png
Gui Add, Picture, x+2 y-0 w36 h33 gGuiClose, Assets\Exit.png
HKeyxPos := guiWidth / 2
HKeyWidth := guiWidth - HKeyxPos - 5
TxtWidth := guiWidth - HKeyWidth - 5
Loop,% #actions {
Gui Font
Gui Font, Bold Underline c0xCCCAD3, Georgia
Gui, Add, Text, xp y+s x-3 w%TxtWidth% +right,  % ActionName[A_Index] 
Gui, Font, Bold, Georgia
Gui, Add, Hotkey, yp x%HKeyxPos% h18 w%HKeyWidth% vHK%A_Index% gGuiAction, %noMods%        ;Add hotkey controls and show saved hotkeys.



 IniRead, savedHK%A_Index%, Hotkeys.ini, Actions, %A_Index%, %A_Space%
 If savedHK%A_Index%                                       ;Check for saved hotkeys in INI file.
  Hotkey,% savedHK%A_Index%, Action%A_Index%                 ;Activate saved hotkeys if found.
 StringReplace, noMods, savedHK%A_Index%, ~                  ;Remove tilde (~) and Win (#) modifiers...
 StringReplace, noMods, noMods, #,,UseErrorLevel              ;They are incompatible with hotkey controls (cannot be shown).

}                  
Gui +hWndhMainWnd
Gui Add, Picture, xm x9 wp w188 h30 gminimize,Assets\Hide.png
return
GuiClose:
 ExitApp
Reload:
 reload

GuiAction:
 If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
  return
 If InStr(%A_GuiControl%,"vk07")            ;vk07 = MenuMaskKey (see below)
  GuiControl,,%A_GuiControl%, % lastHK      ;Reshow the hotkey, because MenuMaskKey clears it.
 Else
  validateHK(A_GuiControl)
return
validateHK(GuiControl) {
 global lastHK
 Gui, Submit, NoHide
 lastHK := %GuiControl%                     ;Backup the hotkey, in case it needs to be reshown.
 num := SubStr(GuiControl,3)                ;Get the index number of the hotkey control.
 If (HK%num% != "") {                       ;If the hotkey is not blank...
  StringReplace, HK%num%, HK%num%, SC15D, AppsKey      ;Use friendlier names,
  StringReplace, HK%num%, HK%num%, SC154, PrintScreen  ;  instead of these scan codes.
  If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
   HK%num% := "#" HK%num%
  If !RegExMatch(HK%num%,"[#!\^\+]")        ;  If the new hotkey has no modifiers, add the (~) modifier.
   HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
  checkDuplicateHK(num)
 }
 If (savedHK%num% || HK%num%)               ;Unless both are empty,
  setHK(num, savedHK%num%, HK%num%)         ;  update INI/GUI
}
checkDuplicateHK(num) {
 global #actions
 Loop,% #actions
  If (HK%num% = savedHK%A_Index%) {
   dup := A_Index
   Loop,6 {
    GuiControl,% "Disable" b:=!b, HK%dup%   ;Flash the original hotkey to alert the user.
    Sleep,200
   }
   GuiControl,,HK%num%,% HK%num% :=""       ;Delete the hotkey and clear the control.
   break
  }
}
setHK(num,INI,GUI) {
 If INI                           ;If previous hotkey exists,
  Hotkey, %INI%, Action%num%, Off  ;  disable it.
 If GUI                           ;If new hotkey exists,
  Hotkey, %GUI%, Action%num%, On   ;  enable it.
 IniWrite,% GUI ? GUI:null, Hotkeys.ini, Actions, %num%
 savedHK%num%  := HK%num%
 ;TrayTip, Action%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF" ; Display changing binds in notification, 
}
#MenuMaskKey vk07                 ;Requires AHK_L 38+
#If ctrl := HotkeyCtrlHasFocus()
 *AppsKey::                       ;Add support for these special keys,
 *BackSpace::                     ;  which the hotkey control does not normally allow.
 *Delete::
 *Enter::
 *Escape::
 *Pause::
 *PrintScreen::
 *Space::
 *Tab::
  modifier := ""
  If GetKeyState("Shift","P")
   modifier .= "+"
  If GetKeyState("Ctrl","P")
   modifier .= "^"
  If GetKeyState("Alt","P")
   modifier .= "!"
  Gui, Submit, NoHide             ;If BackSpace is the first key press, Gui has never been submitted.
  If (A_ThisHotkey == "*BackSpace" && %ctrl% && !modifier)   ;If the control has text but no modifiers held,
   GuiControl,,%ctrl%                                       ;  allow BackSpace to clear that text.
  Else                                                     ;Otherwise,
   GuiControl,,%ctrl%, % modifier SubStr(A_ThisHotkey,2)  ;  show the hotkey.
  validateHK(ctrl)
 return
#If
HotkeyCtrlHasFocus() {
 GuiControlGet, ctrl, Focus       ;ClassNN
 If InStr(ctrl,"hotkey") {
  GuiControlGet, ctrl, FocusV     ;Associated variable
  Return, ctrl
 }
}
minimize:
WinGetPos, gui_x, gui_y,,, ahk_id %MainWnd%
IniWrite, x%gui_x% y%gui_y%, Hotkeys.ini, GuiPos, xy
	Gui, Hide ;minimizes to tray
return

; FUNCTIONS ------------------------------------------------------
fullscreen() {
	WinGetPos,,, w, h,
	return (w = A_ScreenWidth && h = A_ScreenHeight)
}

ShowGUI() {
	Gui, Show, %gui_position% w%guiWidth% ,SkyBinder
	}

GAP(RatioX, RatioY) { ; [G]et [A]bsolute [P]ixels
	WinGetPos,,, Width, Height
	AbsoluteX := Round(Width * RatioX)
	AbsoluteY := Round(Height * RatioY)
	return [AbsoluteX, AbsoluteY]
}

Grabscreenregion() {
BlockInput On
MouseGetPos, gx, gy
WinGetPos,,, maxx, maxy
CalcRatiox := round((gx / maxx) , 2)
CalcRatioy :=  round((gy / maxy) , 2)
clipboard := "doAction(" CalcRatiox ", " CalcRatioy ")"
Tooltip, "pos (%CalcRatiox%`,%CalcRatioy%) saved.", gx-50, gy-25
SetTimer, RemoveToolTip, -5000
BlockInput Off 
return
RemoveToolTip:
ToolTip
return
}

RNGsleep(Between1, Between2, cliQue=false) {
	Random, RandomizedSleepTime, Between1, Between2
	Sleep, RandomizedSleepTime
		if (cliQue) {
	click,
	}
}

doAction(AX, AY, cliQue=false,return2ogpos=false ) {
	BlockInput, on
	MoveAction := GAP(AX, AY)
	MouseGetPos, gx, gy
	MouseMove, MoveAction[1], MoveAction[2]
	if (cliQue) {
	click,
	}
	if (return2ogpos) {
	MouseMove, gx, gy
	}	
	BlockInput, off
	return
}

WM_LBUTTONDOWN() {
	PostMessage, 0xA1, 2
	return
}
/*
WM_RBUTTONDOWN() {  ;infobox/settings window wip so disabled for now
ButtonInfo:
Gui, 2:New, -0x10000 -0x30000
Gui, 2:+hWndhInfoWnd
Gui, 2:Color, 0x2F204C
Gui, 2:Font, Bold c0xCCCAD3, Georgia

Gui, 2:Add, Text,w330 h2 +0x10
Gui, 2:Add, Text, x0 xm Center +0x10,Made with UI Scale was 0.69 Fullscreen 1920x1080.
Gui, 2:Show, , More Info
}
*/

; End of Functions ------------------------------------------------





; Welcome friends! ^^
; This is very openended so have fun customizing your own version of this script however you seem fit!

; Custom Functions available ATM : 
; Grabscreenregion() - When bound to a hotkey it will save your cursor position when pressed to your clipboard. In the syntax this code likes.
; GAP(RatioX, RatioY) - For more dynamically found pixels, uses the selected's window maxW/H. GetAbsolutePixels
; RNGsleep(MinMS, MaxMS, Click) - Whats not more fun than a little sleepytime RNG? (,,true)
; doAction(xRatio, yRatio, Click, ReturnToOrigialPosition) - Where (,,true,true) Moves to 0.x,0.y, clicks, then returns cursor to OG position.
; ShowGUI() 
; Fullscreen() - Checks if the window is fullscreen resolution.
; My Resolution UI for this was scaled at 0.69, and primarily at 1920x1080 Fullscreen.
;---
; %PlayerDeck% - actual in-game binds??
; %PlayerGrave% - actual in-game binds??


; Only allow script to trigger while a window with "Skyweaver" is active/selected
; --- Should work for any browser/client.(tm) ---
#If WinActive("Skyweaver") and fullscreen()


	
Action1:
		doAction(0.97, 0.98,true,true) ; END TURN
return
Action2:
	Send, %PlayerDeck%
return
Action3:
	Send, %PlayerGrave%
return
Action4:
	doAction(0.50, 0.59) ; PLAYER BOARD
return
Action5:
	doAction(0.50, 0.97) ; PLAYER HAND
return
Action6:
	doAction(0.16, 0.39, true) ; ENEMY GRAVE
return
Action7:
	doAction(0.50, 0.30) ; ENEMY BOARD
return
Action8:
	doAction(0.50,0.02) ; ENEMY HAND
return
Action9:
	doAction(0.93, 0.02,true,true) ; HISTORY
return
Action10:
	doAction(0.96,0.02,true,true) ;MUTE
return
Action11:
	doAction(0.99, 0.02,true) ; OPTIONS
	doAction(0.5, 0.48)
return
Action12: ;Concedes and presses the stuff to requeue again.
	doAction(0.99, 0.02, true) ; OPTIONS
	RNGsleep(300,420) ;Allow UI to load
	doAction(0.5, 0.44, true) ; Concede
	doAction(0.47, 0.53, true) ; Confirm Concede
	RNGsleep(300,420) ;Allow UI to load
	doAction(0.50, 0.97,true) ; Continue Button
	RNGsleep(240,420, true)
	RNGsleep(420,840, true)
	RNGsleep(1000,1420, true)
	RNGsleep(1000,1420, true)
	RNGsleep(1000,1420, true) ; a bunch of delayed clicks
	RNGsleep(1000,1420, true) ; to get thro the rewards section
	RNGsleep(1000,1420, true)
	RNGsleep(4000,4420, true)
	doAction(0.8, 0.41,true) ;Requeue
return
Action13:
F8::
ShowGUI()
return
Action14:
reload
return
Action15:
Grabscreenregion()
return
