# SkyBinder
Currently its just an `AHK` that can openendly be given bind keys to perform actions.

__Requires:__  [AutoHotKey](https://www.autohotkey.com/download/)

It will only apply to anything named 'Skyweaver.exe' but can be easily changed to work in-browser aswell.

Hotkeys are saved & stored in an `.ini` file where this `.ahk` file resides.

Once running you can either press **"F8"**, or select the 'Keybinds' option in your Tray to setup your binds.
___
![Screenshot](Assets/Screenshot.png)
###### Your options are the functions listed below, or feel free to have it do anything you want it to do as your copy is your copy.


### Functions
```
Grabscreenregion() - When bound to a hotkey it will save your cursor position when pressed to your clipboard. In the syntax this code likes.
GAP(RatioX, RatioY) - For more dynamically found pixels, uses the selected's window maxW/H. GetAbsolutePixels
RNGsleep(MinMS, MaxMS) - Whats not more fun than a little sleepytime RNG?
doAction(xRatio, yRatio, Click, ReturnToOrigialPosition) - Where (,,true,true) Moves to 0.x,0.y, clicks, then returns cursor to OG position.
```
### Customizing the script
* To adjust the quantity of hotkeys change `#actions = 6` Found at the very top.
* To change the text that appears next to each hotkey edit `ActionTitle :=[]` Found just below `#actions = #`. 
* Assigning actions to the hotkeys are found at the very end of the script. Starting at `Action1:`
____
#### If theres any problems with the alignment of the binds
add `GrabScreenRegion()` in one of the 'Action' areas of the very bottom of the Script.

Once the bind for this function is used, it will save in the proper syntax for this code in your clipboard the data from where your cursor was relative to the Skyweaver Window. `doAction(0.xx,0.yy)`


### Known issues :
Can bind Mousebutton4 (XButton1), Mousewheel press (MButton), and other special keys. 

Just not through the GUI. Only by Editing the `.ini` file.

HotKey text doesnt display right information. `ini` file > gui display.


# Next to be added
- [x] Be an idiot and not use the 'Releases' feature
- [x] Auto-forefit & requeue
- [ ] Emotes 	:lying_face:
- [ ] Smorc
