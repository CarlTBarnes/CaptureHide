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
        END
    END
SetWinDspAff_fp LONG,NAME('SetWinDspAff')

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

    