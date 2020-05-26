                    MEMBER()
!--------------------------
! CBCaptureHideClass by Carl Barnes May 2019. Released under MIT License. 
!--------------------------
    INCLUDE('CBCaptureHide.INC'),ONCE
    MAP
GetProcsByName PROCEDURE(BYTE ShowErrors=0),BOOL
        MODULE('Win32')
GetModuleHandleA PROCEDURE(*CSTRING lpModuleName),LONG,RAW,PASCAL,DLL(1)
GetProcAddress   PROCEDURE(long HInstance,*cstring ProcName),LONG,PASCAL,RAW,DLL(1)
GetLastError     PROCEDURE(),LONG,PASCAL,DLL(1)
SetWindowDisplayAffinity  PROCEDURE(SIGNED hWnd, UNSIGNED dwAffinity),BOOL,PROC,PASCAL,DLL(_fp_),NAME('SetWinDspAff') 
GetParent       PROCEDURE(SIGNED hWnd),SIGNED,PASCAL,DLL(1)
GetAncestor     PROCEDURE(SIGNED hwnd, UNSIGNED gaFlags),SIGNED,RAW,PASCAL,DLL(1)
        end
    end !map

SetWinDspAff_fp LONG,NAME('SetWinDspAff')

GA_PARENT   EQUATE(1)   !Retrieves the parent window. This does not include the owner, as it does with the GetParent function.
GA_ROOT     EQUATE(2)   !Retrieves the root window by walking the chain of parent windows.
GA_ROOTOWNER EQUATE(3)  !Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent.

!Win 10 will offer WDA_EXCLUDEFROMCAPTURE that omits window rather than turns black.
!I tried ,2) and it error. Tried 2 to 1024 anbd nothing.
!-----------------------------------
CBCaptureHideClass.CaptureStop PROCEDURE()
B BOOL
    CODE 
    IF GetProcsByName(SELF.ShowErrors) THEN 
       B=SetWindowDisplayAffinity(0{PROP:Handle},1)  !WDA_MONITOR (0x01)
       IF B=0 AND SELF.ShowErrors THEN 
          Message('SetWindowDisplayAffinity Failed B=' & B & '  LastError=' & GetLastError() )
       END
       SELF.bStopped=True
    END 
    RETURN
!-----------------------------------
CBCaptureHideClass.CaptureOK PROCEDURE()
    CODE
    IF GetProcsByName() THEN 
       SetWindowDisplayAffinity(0{PROP:Handle},0)  !WDA_NONE (0x00)
       SELF.bStopped=False
    END 
    RETURN

!-----------------------------------
CBCaptureHideClass.MdiCaptureStop PROCEDURE()
B BOOL
Hnd LONG,AUTO
    CODE
    Hnd=GetAncestor(0{PROP:Handle}, GA_Root)  !Parent would be MDI Frame Desktop and not work
    IF GetProcsByName(SELF.ShowErrors) THEN 
       B=SetWindowDisplayAffinity(Hnd,1)  !WDA_MONITOR (0x01)
       IF B=0 AND SELF.ShowErrors THEN 
          Message('SetWindowDisplayAffinity Failed B=' & B & '  LastError=' & GetLastError() )
       END
       SELF.bStopped=True
       SELF.MdiStopCnt += 1
    END 
    RETURN
!-----------------------------------
CBCaptureHideClass.MdiCaptureOK PROCEDURE(BOOL ForceOk=0)
Hnd LONG,AUTO
    CODE
    SELF.MdiStopCnt -= 1 
    IF SELF.MdiStopCnt < 0 OR ForceOk THEN SELF.MdiStopCnt=0.
    IF SELF.MdiStopCnt THEN RETURN.
    Hnd=GetAncestor(0{PROP:Handle}, GA_Root)
    IF GetProcsByName() THEN 
       SetWindowDisplayAffinity(Hnd,0)  !WDA_NONE (0x00)
       SELF.bStopped=False
    END 
    RETURN
    
!-----------------------------------
CBCaptureHideClass.IsStopped PROCEDURE()
    CODE
    RETURN SELF.bStopped
!====================================================
GetProcsByName PROCEDURE(BYTE ShowErrors=0)!,BOOL
hDll   LONG,AUTO      
hProc  LONG,AUTO      
DllName  CSTRING('user32.dll')
ProcName CSTRING('SetWindowDisplayAffinity')
    CODE
    IF ~SetWinDspAff_fp THEN
       SetWinDspAff_fp=-1             !set to -1 if failed to Get
       hDll=GetModuleHandleA(DllName)
       IF hDll THEN 
          hProc=GetProcAddress(hDll, ProcName)
          IF hProc THEN 
             SetWinDspAff_fp=hProc
          ELSIF ShowErrors THEN 
             Message('GetProcsByName GetProcAddress(' & hDll &','& ProcName &')||Error ' & GetLastError())
          END
        ELSIF ShowErrors THEN 
             Message('GetProcsByName GetModuleHandleA(' & DllName &')||Error ' & GetLastError())
       END 
    END 
    RETURN CHOOSE(SetWinDspAff_fp<>-1)

    