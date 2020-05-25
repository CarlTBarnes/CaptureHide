
  PROGRAM
  INCLUDE('CBCaptureHide.INC'),ONCE
  
  MAP
CapHideTest PROCEDURE()  
  END

  CODE
  CapHideTest()  

CapHideTest PROCEDURE()

HideCapWindow      BYTE

HideCaptureSSN     BYTE
HideCapRegion      BYTE

EmpNo   LONG(123)
EmpName STRING('Hilda Schrader Whitcher {10}')
EmpSSN  LONG(078051120)   !https://www.ssa.gov/history/ssn/misused.html
MoreText STRING(500)
                !,COLOR(COLOR:BtnFace) 
                
Window WINDOW('Capture Hide Test - SetWindowDisplayAffinity() '),AT(,,225,161),GRAY,SYSTEM, |
            FONT('Segoe UI',9)
        SHEET,AT(2,2,221,78),USE(?SHEET1)
            TAB('Name && Address'),USE(?TAB:General)
                PROMPT('Emp No:'),AT(20,27),USE(?PROMPT1)
                ENTRY(@n4),AT(54,27),USE(EmpNo)
                PROMPT('Name:'),AT(20,43),USE(?PROMPT2)
                ENTRY(@s40),AT(54,43),USE(EmpName)
            END
            TAB('Tax ID'),USE(?TAB:TaxID)
                PROMPT('Emp No:'),AT(20,27),USE(?PROMPT2:2)
                ENTRY(@n4),AT(54,27),USE(EmpNo,, ?EmpNo:2),SKIP,TRN,READONLY
                PROMPT('SSN:'),AT(20,43),USE(?PROMPT2:3)
                ENTRY(@p###-##-####p),AT(54,43),USE(EmpSSN)
            END
            TAB('More...'),USE(?TAB:More)
                TEXT,AT(6,20,211,52),USE(MoreText),VSCROLL
            END
        END
        PROMPT('Sheet Hides Capture when on Tax ID Tab'),AT(48,83),USE(?SheetFYI),FONT(,,,FONT:bold)
        BUTTON('Allow Capture'),AT(183,100,37,22),USE(?AllowCaptureButton),SKIP
        CHECK('Hide Window from Screen Capture Now'),AT(20,100),USE(HideCapWindow),FONT(,,,FONT:regular)
        CHECK('ShowErrors in CBCaptureHideClass'),AT(20,113),USE(?ShowErrorsCB)
        PROMPT('SetWindowDisplayAffinity() prevents capture only for a WINDOW and not Controls.  Wor' & |
                'karound is to put senstive info on a Tab and when Tab has focus stop capture. Or pu' & |
                't senstive info on its own Window. '),AT(5,130,212,27),USE(?FYI)
    END

CaptureCls  CBCaptureHideClass
    CODE
    OPEN(Window)
    CaptureCls.ShowErrors=1 
    ?ShowErrorsCB{PROP:Use}=CaptureCls.ShowErrors

    ACCEPT
        CASE FIELD()
        OF ?SHEET1
           CASE EVENT()
           OF EVENT:NewSelection
              CASE ?SHEET1{PROP:ChoiceFEQ}
              OF ?TAB:TaxID !SSN Capture Hide
                 CaptureCls.CaptureStop()
              ELSE
                 IF CaptureCls.IsStopped() THEN    !Is Capture Stopped?
                    CaptureCls.CaptureOK()         !Save an API call and only do this when required
                    HideCapWindow=0 ; display      !alternate test, not in normal code
                 END 
              END 
           END
        END 
        CASE ACCEPTED()
        OF ?AllowCaptureButton
            CaptureCls.CaptureOK() 

        OF ?HideCapWindow  
            IF HideCapWindow THEN 
               CaptureCls.CaptureStop()  
            ELSE
               CaptureCls.CaptureOK()  
            END

        OF ?EmpSSN ; DISPLAY 
        
        END

        CASE EVENT()
        OF EVENT:OpenWindow
        END 

    END

    OMIT('**END**')

!Tried to find the new Windows 10 flag but failed. Must not be released.

CaptureStop10   PROCEDURE() !hunt for win 10 new WDA_EXCLUDEFROMCAPTURE flag value

CBCaptureHideClass.CaptureStop10 PROCEDURE()  !hunt for win 10 WDA_EXCLUDEFROMCAPTURE
B BOOL
F LONG 
    CODE 
    IF ~GetProcsByName() THEN RETURN.
    LOOP F=4 TO 1024 by 2        !All Odd number work, must be BAND(1)
       B=SetWindowDisplayAffinity(0{PROP:Handle},F)  
       IF B<>0  THEN 
          Message('CaptureStop10 worked! F=' & F & '  LastError=' & GetLastError() )
          SELF.bStopped=True
          RETURN
       END
    END
    Message('CaptureStop10 failed! F=' & F & '  LastError=' & GetLastError() )
    RETURN
    
    !end of OMIT('**END**')


    !Cannot do controls so just excise that code from the Class

    OMIT('**END**')

        OF ?HideCaptureSSN  
            IF HideCaptureSSN THEN 
               CaptureCls.Hide(?EmpSSN)  
            ELSE
               CaptureCls.UnHide(?EmpSSN)  
            END 
        OF ?HideCapRegion  
            IF HideCapRegion THEN 
                CaptureCls.Hide(?HideCapRegion)  
            ELSE
               CaptureCls.UnHide(?HideCapRegion)  
            END


        CHECK('Hide SSN Entry from Screen Capture (cannot)'),AT(128,23),USE(HideCaptureSSN)
        CHECK('Hide Region from Screen Capture (cannot)'),AT(128,34),USE(HideCapRegion),TIP('Region ' & |
                'over SSN might work?')

Hide                    PROCEDURE(LONG FEQ)  !Does NOT work
UnHide                  PROCEDURE(LONG FEQ)  !Does NOT work

!-----------------------------------
CBCaptureHideClass.Hide PROCEDURE(LONG FEQ)
!-----------------------------------
B BOOL
    CODE
    ! MESSAGE('CBCaptureHideClass.Hide ' & FEQ &'||GetProcWin7()=' & GetProcWin7() ) 
    IF GetProcsByName() THEN 
       b=SetWindowDisplayAffinity(FEQ{PROP:Handle},1)  !WDA_MONITOR (0x01)
       IF B=0 AND SELF.ShowErrors THEN 
          Message('SetWindowDisplayAffinity Failed B=' & B & '  LastError=' & GetLastError() )
       END 
    END 
    RETURN
!-----------------------------------
CBCaptureHideClass.UnHide PROCEDURE(LONG FEQ)
!-----------------------------------
    CODE
!    MESSAGE('CBCaptureHideClass.UnHide ' & FEQ)
    IF GetProcsByName() THEN 
       SetWindowDisplayAffinity(FEQ{PROP:Handle},0)  !WDA_NONE (0x00)
    END 
    RETURN    
    !end of OMIT('**END**')
    