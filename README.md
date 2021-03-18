# MyweaverControls
Currently its just an `AHK` that can openendly be given hotkeys to functions.

Its hotkeys only applies to the Skyweaver.exe window.

#The default bind to open the GUI to bind the actions is "F8"

Hotkeys are stored in an `.ini` file in the folder this `.ahk` file resides.

#### Functions
```
Grabscreenregion() - When bound to a hotkey it will save your cursor position when pressed to your clipboard. In the syntax this code likes.
GG() - Will Concede and interact with the nessisary things to requeue.
OpenMenu() - Clicks on the button for the in-game settings.
PassTurn() - Ends your turn and returns the mouse back where it was .
HandCont() - Moves mouse to the Continue button or in the center where your hand resides.
```







__If theres any problems with the alignment of the binds__

add `GrabScreenRegion()` in one of the 'Action' areas of the very bottom of the Script.

Once the bind for this function is used, it will save in the proper syntax for this code in your clipboard the data from where your cursor was relative to the Skyweaver Window. `:= GAP(x.xx, y.yy)`


Working on a way to bind the Emotes, ripme. 	:lying_face:
