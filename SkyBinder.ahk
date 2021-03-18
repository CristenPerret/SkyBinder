#SingleInstance force
#NoEnv
SetBatchLines, -1
SetDefaultMouseSpeed, 0 ; Move mouse instantly
#Include %A_ScriptDir%\ControlColor.ahk





#actions = 6  ;Adjust this value to increase the amount of bindable hotkeys

;Change this array to display text next to the associated Hotkey.
ActionTitle :=["1. Open Gui"
, "2. Game Menu"
, "3. Basic Click"
, "4. End Turn"
, "5. Hand region"
, "6. Auto - Forefit" ] 




; Associating the functions to the labels are listed at the bottom of the script as 'Action#:'


;--------------------------------------------------------------------------------------------------
; THIS SECTION ISNT USER-FRIENDLY. BEWARNED IF YOU'RE NOT VERSED IN AHK'S SYNTAX.
;--------------------------------------------------------------------------------------------------

; Tray options ----
TrayTip, SkyBinder,,16
Menu, Tray, Icon, Skybinder.ico, 1,1
Menu, tray, Tip, SkyBinder
Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Keybinds, Action6
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Default, Keybinds



; GUI -----

guiWidth := 206

Gui +hWndhMainWnd
Gui Color, 0x2F204C
Gui, Add, Radio, x-15 y-15 ;Important to not automatically bind keys on opening gui
Gui Add, Picture, gButtonInfo xm yp ym w186 h92, Titlebar.png
Gui -0x10000 -0x30000
Loop,% #actions {
Gui Font, Bold Underline c0xCCCAD3, Georgia
Gui, Add, Text,xm +right,  % ActionTitle[A_Index] 
Gui Font
 IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%
 If savedHK%A_Index%                                       ;Check for saved hotkeys in INI file.
  Hotkey,% savedHK%A_Index%, Action%A_Index%                 ;Activate saved hotkeys if found.
 StringReplace, noMods, savedHK%A_Index%, ~                  ;Remove tilde (~) and Win (#) modifiers...
 StringReplace, noMods, noMods, #,,UseErrorLevel              ;They are incompatible with hotkey controls (cannot be shown).
 Gui, Add, Hotkey, x+5 vHK%A_Index% gGuiAction, %noMods%        ;Add hotkey controls and show saved hotkeys.
 
}                  
Gui +hWndhMainWnd                                              
Gui Add, Picture, gminimize xm wp w181 h28 ,Hide.png
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
 IniWrite,% GUI ? GUI:null, Hotkeys.ini, Hotkeys, %num%
 savedHK%num%  := HK%num%
 TrayTip, Action%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF" ; Display changing binds in notification, 
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
Gui, Hide ;minimizes to tray
return

ButtonInfo:
Gui, 2:New, -0x10000 -0x30000
Gui, 2:Add, Text, Center ,This script is very open-ended it can`nadd/remove and make whatever actions you wish`nby navigating through to this AHK file.`nTo adjust the amount of hotkeys change 'Actions = #',`nand ActionTitle to fit what changes you've made to this script.
Gui, 2:Add, Text,w295 h2 +0x10
Gui, 2:Add, Text,Center ,My UI Scale in game was 0.69 when aligning certain actions.

Gui, 2:Show, , More Info
return



; FUNCTIONS ------------------------------------------------------

; Convert relative positions of buttons on screen into absolute 
; pixels for AHK commands. Allows for different resolutions.
GAP(RatioX, RatioY) {
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
clipboard := " := GAP(" CalcRatiox ", " CalcRatioy ")"
Tooltip, "pos (%CalcRatiox%`,%CalcRatioy%) saved.", gx-50, gy-25
SetTimer, RemoveToolTip, -5000
BlockInput Off 
return
RemoveToolTip:
ToolTip
return
}

OpenMenu() {
	MenuButton := GAP(0.99, 0.02)
	MouseCenter := GAP(0.50, y)
	MouseMove, MenuButton[1], MenuButton[2] ; goes to the cog in-game
	Click,
	Sleep, 200 ; Wait until it has popped up
	MouseMove, MouseCenter[1], MouseCenter[1] ; goes to the menu ui
	
}

PassTurn() {
	BlockInput, On
	EndTurn := GAP(0.97, 0.98) ;Bottom right
	MouseGetPos, gx, gy ; remembers mouse position
	MouseMove, left EndTurn[1], EndTurn[2] ; goes to end turn
	Click, ; ends turn
	Sleep, 20
	MouseMove, gx, gy ;returns cursor
	BlockInput, Off 
	return
}

;Where the continue button is in-game 
HandCont() {
BlockInput, on
ContBtn := GAP(0.50, 0.96)
MouseMove, ContBtn[1], ContBtn[2]
BlockInput, on
}

; May have to increase intervals of sleep based on loading times
GG() {
	BlockInput, On
	OpenMenu() 
	LeaveQ := GAP(0.50, 0.44) ; Button on the settings UI
	GGButton := GAP(0.47, 0.53) ; Confirm leaving the match
	RKieu := GAP(0.80, 0.41) ; Button to requeue
	MouseClick, left, LeaveQ[1], LeaveQ[2]
	sleep, 240
	MouseClick, left, GGButton[1], GGButton[2]
	sleep, 240
	HandCont()
	Click,
	sleep, 240
	Click,
	sleep, 420
	click,
	sleep, 1420
	click,
	sleep, 1420
	click,
	sleep, 1420
	click,
	sleep, 1420
	click,
	sleep, 1420
	click,
	sleep, 4420
	MouseMove, RKieu[1], RKieu[2]
	sleep, 240
	click,
	BlockInput, Off
}

; End of Functions ------------------------------------------------


; Welcome friends!
; This is very openended so have fun customizing your own version of this script however you seem fit!


; Only allows this window to be trigger the actions below.
#IfWinActive, ahk_exe SkyWeaver.exe

; Custom Functions available ATM : 
; Grabscreenregion() - When bound to a hotkey it will save your cursor position when pressed to your clipboard. In the syntax this code likes.
; GG() - Will Concede and interact with the nessisary things to requeue.
; OpenMenu() - Clicks on the button for the in-game settings.
; PassTurn() - Ends your turn and returns the mouse back where it was .
; HandCont() - Moves mouse to the Continue button or in the center where your hand resides.

;These Actions may contain any commands for their respective hotkeys to perform.
Action1:
F8::
Gui, Show, w%guiWidth% ,SkyBinder
return

Action2:
reload
;OpenMenu()
return

Action3:
Click,
return

Action4:
PassTurn()

return

Action5:
HandCont() ; Space where the Continue button is, but also the central spot of the Hand.
return

Action6:
GG()
return