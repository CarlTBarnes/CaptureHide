# CaptureHide Class
 Screen Capture Stop

The CBCaptureHide class calls Windows [SetWindowDisplayAffinity](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowdisplayaffinity) function to set to "Monitor Only". Any attempt at screen capture will show a black window. This works for Print Screen and various screen snipping tools.
The API only works with top-level windows. You cannot set it for individual controls. A workaround is to put sensitive information on a specific Tab, then when that Tab takes focus stop capture. 
The included example below shows a screen capture with the Tax ID tab active

![capture](readme_caphide.png)

The Allow Capture button shows monitor view of the tab.

![capture](readme_capok.png)

## Requirements
SetWindowDisplayAffinity() is available under Windows 7 and newer. The class dynamically loads User32.DLL and does GetProcAddress(). If run under Vista or XP the program will load and run fine, it will not prevent capture.
