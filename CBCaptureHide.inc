!Fly in the ointment... this does not work on MDI windows. Must send it to the Frame.
!
!-------------------------- Hide Windows from Screen Capture ----------------------------
! CBCaptureHideClass by Carl Barnes May 2019. Released under MIT License. 
! Disclaimer: This code has no intended purpose, any appearance as anything useful is mearly coincidental.
! Calls SetWindowDisplayAffinity() that is ONLY AVAILABLE under Windows 7, 8, 10 or newer, so not XP nor Vista.
!
!    INCLUDE('CBCaptureHide.INC'),ONCE      !
!CapHideCls  CBCaptureHideClass
!
!   CapHideCls.CaptureStop()    !Captures as Black
!   CapHideCls.CaptureOK()      !Captures as Normal
!
! This only works on entire Windows so put senstive info on special window.
! Can put senstive data on it's own tab and when that tab has focus prevent capture.
!   In ?Sheet Event:NewSelection check if the ?Sheet{PROP:ChoiceFEQ}=?TabSensitive and call .CaptureStop()
!
!        OF ?SHEET1
!           CASE EVENT()
!           OF EVENT:NewSelection
!              CASE ?SHEET1{PROP:ChoiceFEQ}
!              OF ?TAB:SenstiveInfo
!                 CaptureCls.CaptureStop()
!              ELSE
!                 IF CaptureCls.IsStopped() THEN    !Is Capture Stopped?
!                    CaptureCls.CaptureOK()         !Save an API call and only do this when required
!                 END 
!              END 
!           END
!
! Suggested music: Fade to Black - Dire Staits
!--------------------------------------------------------------------------------------------------------

    OMIT('_EndOfInclude_',_IFDef_CBCaptureHide_)
_IFDef_CBCaptureHide_  EQUATE(1)

!----------------- CBCaptureHideClass -----------------
CBCaptureHideClass    CLASS,TYPE,MODULE('CBCaptureHide.CLW'),LINK('CBCaptureHide.CLW',1),DLL(0)   !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!Properties
!----------
ShowErrors      BYTE            !Set to 1 to see error
bStopped        BOOL,PROTECTED  !Capture is currently stopped
!Methods
!-------
CaptureStop     PROCEDURE() !Prevent Screen Capture on the current window
CaptureOK       PROCEDURE() !Allow Screen Capture
IsStopped       PROCEDURE(),BOOL !Has .CaptureStop() been called and is in effect.

!Special version for MDI Hides the ROOT Window which is the Frame.
!The class could check Window PROP:MDI and automatically handle this.
MdiStopCnt         SHORT        !Count so only OK when StopCnt undone
MdiCaptureStop     PROCEDURE() !Prevent Screen Capture on the current window
MdiCaptureOK       PROCEDURE(BOOL ForceOk=0) !Allow Screen Capture

!This is a simple test.
!To do this right would probably want to send Notify Events to the Frame to Stop or OK Capture.
!it would need to keep a count incase multiple threads Asked for Hide.
!MdiStopCn SHORT is an attemp to do this.
             END

    _EndOfInclude_
