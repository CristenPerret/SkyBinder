#NoEnv
#SingleInstance force
SetBatchLines, -1
SetDefaultMouseSpeed, 0 ; Move mouse instantly
SetTitleMatchMode, 2

; To edit/customize the script, check out the bottom of the script, at '4. ACTIONS'.
; Thank you and happy gaming!



OnMessage(0x201, "WM_LBUTTONDOWN") ;left click drag trigger for the GUI
OnMessage(0x204, "WM_RBUTTONDOWN") ; right click infobox trigger for the GUI

; Populates a Hotkey for every one listed in ActionName
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


version := "v1.4" ; 07/11/22
PlayerDeck := "d" 
PlayerGrave := "g"
EndTurn := "Space"

;--------------------------------------------------------------------------------------------------
; THIS SECTION ISNT USER-FRIENDLY. BEWARNED IF YOU'RE NOT VERSED IN AHK'S SYNTAX. 
;--------------! THE FAR BOTTOM IS WHERE YOU MIGHT WANT TO LOOK INSTEAD !--------------------------
;--------------------------------------------------------------------------------------------------

;1. Tray options ----
TrayTip, SkyBinder %version%,,16
Menu, Tray, Icon, Assets\Skybinder.ico, 1,1
Menu, tray, Tip, SkyBinder %version%
Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Keybinds, Action13
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Default, Keybinds
;2. GUI -----
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
IniRead, savedHK%A_Index%, Hotkeys.ini, Actions, Action #%A_Index% , %A_Space%
Gui, Add, Hotkey, yp x%HKeyxPos% h18 w%HKeyWidth% vHK%A_Index% gGuiAction, %noMods%        ;Add hotkey controls and show saved hotkeys.
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
 IniWrite,% GUI ? GUI:null, Hotkeys.ini, Actions, Action #%num% ;Writes the hotkey to Hotkey.ini
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

; 3. FUNCTIONS ------------------------------------------------------
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

WM_RBUTTONDOWN() {  ;infobox/settings window 
ButtonInfo:
Gui, 2:New, -0x10000 -0x30000
Gui, 2:+hWndhInfoWnd
Gui, 2:Color, 0x2F204C
Gui, 2:Font, Bold c0xCCCAD3, Georgia

;Gui, 2:Add, Text,w820 h2 +0x10
Gui, 2:Add, Text, x0 xm Center +0x10,Made with UI Scale at 100`% (Default), and Fullscreen 1920x1080.`n`nMake sure to enable "Spacebar Ends Turn" in-game under Options-Game.`nElse you can remove the '`;' comment in the Action1 section to manually click it.`n`nCurrently set to only be enabled when Fullscreen, on any browser or the Standalone Client.`nSometimes when typing like in the filter to build a deck, you might want to get out of fullscreen else some hotkeys could fire.`n`nIf for some reason certain actions arent clicking in the right region:`n1.Mouseover in-game the thing you wish to get the screenregion of.`n2.Press the Grabscreenregion hotkey.`n3.update the Action with the current coordinates (now stored in your clipboard).`n`n
Gui, Font, underline
Gui, 2:Add, Text, x0 xm Center +0x10 cYellow gMyLink, GLHF!                                            Feel free to support me. Heres a Redirect to my BuyMeACoffee page.                                         Thankyou!
Gui, 2:+AlwaysOnTop
Gui, 2:Show, , More Info
}

MyLink:
Run, https://www.buymeacoffee.com/?via=Kaliados
return

; End of Functions ------------------------------------------------


; 4. ACTIONS 


; Welcome friends! ^^
; This is very openended so have fun customizing your own version of this script however you seem fit!

; Custom Functions available ATM : 
; Grabscreenregion() - When bound to a hotkey it will save your cursor position when pressed to your clipboard. In the syntax this code likes.
; GAP(RatioX, RatioY) - For more dynamically found pixels, uses the selected's window maxW/H. GetAbsolutePixels
; RNGsleep(MinMS, MaxMS, Click) - Whats not more fun than a little sleepytime RNG? (,,true)
; doAction(xRatio, yRatio, Click, ReturnToOrigialPosition) - Where (,,true,true) Moves to 0.x,0.y, clicks, then returns cursor to OG position.
; ShowGUI() 
; Fullscreen() - Checks if the window is fullscreen resolution.
; My Resolution UI for this was scaled at the default - 100%, and primarily at 1920x1080 Fullscreen.
;---
; In-Game Hotkeys that actually work can be refrenced like so : %PlayerDeck%, %PlayerGrave%, or %EndTurn%. 

; Only allow script to trigger while a window with "Skyweaver" is active/selected, AND Fullscreen.
; --- SHOULD work for any browser/client.(tm) ---
#If WinActive("Skyweaver") and fullscreen()


	
Action1:
	;doAction(0.98, 0.98,true,true) ;Manually click endturn - if you dont want to enable the Spacebar option.
	Send, {%EndTurn%}
return
Action2:
	Send, {%PlayerDeck%}
return
Action3:
	Send, {%PlayerGrave%}
return
Action4:
	doAction(0.50, 0.59) ; PLAYER BOARD
return
Action5:
	doAction(0.50, 0.97) ; PLAYER HAND
return
Action6:
	doAction(0.20, 0.37, true) ; ENEMY GRAVE
return
Action7:
	doAction(0.50, 0.30) ; ENEMY BOARD
return
Action8:
	doAction(0.50,0.02) ; ENEMY HAND
return
Action9:
	doAction(0.91, 0.03,true,true) ; HISTORY
return
Action10:
	doAction(0.95, 0.03,true,true) ;MUTE
return
Action11:
	doAction(0.98, 0.03,true) ; OPTIONS
	doAction(0.5, 0.5)
return
Action12: ;Concedes and presses the stuff to requeue again.
	tooltip, "attempting to requeue"
	doAction(0.98, 0.04,true) ; OPTIONS
	RNGsleep(300,420) ;Allow UI to load
	doAction(0.50, 0.44,true) ; Concede
	RNGsleep(50,100)
	doAction(0.44, 0.54,true) ; Confirm Concede
	doAction(0.78, 0.59) ;Requeue Button location
	RNGsleep(1300,1420) ;Allow UI to load
	Send, {%EndTurn%}
	RNGsleep(4000,5420,true)
	Send, {%EndTurn%}
	RNGsleep(240,420, true)
	Send, {%EndTurn%}
	RNGsleep(1000,1420,true) ; a bunch of delayed clicks
	Send, {%EndTurn%}
	RNGsleep(1000,1420,true) ; to get thro the rewards section
	Send, {%EndTurn%}
	RNGsleep(1000,1420,true)
	Send, {%EndTurn%}
	RNGsleep(4000,4420,true)
	RNGsleep(4000,4420,true)
	RNGsleep(4000,4420,true)
	tooltip,
return
Action13:
ShowGUI()
return
Action14:
reload
return
Action15:
Grabscreenregion()
return