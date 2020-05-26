!Test MDI and Capture Hide
    program
    INCLUDE 'KeyCodes.CLW'
    INCLUDE('CBCaptureHide.INC'),ONCE

CaptureCls  CBCaptureHideClass

    MAP
Main            procedure
Client1Window   procedure
Client2Window   procedure
NonMdiWindow    procedure
DB              PROCEDURE (<STRING Sec>, STRING Info)  
        module('RTL')
ClaFieldName        PROCEDURE(SIGNED pFEQ),CSTRING,RAW,NAME('Cla$FIELDNAME')        
DebugerNameMessage  PROCEDURE(*CSTRING OutMsg, UNSIGNED EventNum ),NAME('WslDebug$NameMessage'),RAW,long,PROC             
        end     

        module('Win32')
            OutputDebugString(*cstring dMsg),PASCAL,RAW,NAME('OutputDebugStringA'),dll(1)
            GetLastError(),LONG,PASCAL,DLL(1)  
GetParent    PROCEDURE(SIGNED hWnd),SIGNED,PASCAL,DLL(1)
GetAncestor  PROCEDURE(SIGNED hwnd, UNSIGNED gaFlags),SIGNED,RAW,PASCAL,DLL(1)
        end
    end !map

GA_PARENT   EQUATE(1)   !Retrieves the parent window. This does not include the owner, as it does with the GetParent function.
GA_ROOT     EQUATE(2)   !Retrieves the root window by walking the chain of parent windows.
GA_ROOTOWNER EQUATE(3)  !Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent.

    CODE
    Main()
    return
!-----------------
Main    procedure

AppFrame APPLICATION('Capture Stop Frame Test'),AT(,,500,300),SYSTEM,ICON(ICON:Frame),FONT('Segoe UI',9,,FONT:regular), |
            RESIZE
        MENUBAR,USE(?MENUBAR1)
            MENU('&File'),USE(?File)
                ITEM('&Printer Setup'),USE(?PrinterSetup),STD(STD:PrintSetup),LAST
                ITEM('E&xit'),USE(?Exit),STD(STD:Close),LAST
            END
            ITEM('Client1!'),USE(?ClientWindow1)
            ITEM('Client2!'),USE(?ClientWindow2)
            MENU('NonMDI'),USE(?NonMDI)
                ITEM('Open NonMDI'),USE(?NonMDIOpen)
                ITEM('Start NonMDI'),USE(?NonMDIStart)
            END
            MENU('&Edit'),USE(?Edit)
                ITEM('Cut'),USE(?ITEM1),STD(STD:Cut)
                ITEM('Copy'),USE(?ITEM2),STD(STD:Copy)
                ITEM('Paste'),USE(?ITEM3),STD(STD:Paste)
            END
            MENU('&Window'),USE(?MENU1),STD(STD:WindowList)
                ITEM('Tile'),USE(?ITEM4),STD(STD:TileWindow)
                ITEM('Cascade'),USE(?ITEM5),STD(STD:CascadeWindow)
                ITEM('Arrange'),USE(?ITEM6),STD(STD:ArrangeIcons)
            END
            MENU('&Help'),USE(?MENU2),MSG('Windows Help')
                ITEM('STD:Help'),USE(?HelpStd),STD(STD:Help)
                ITEM('Contents STD:HelpIndex'),USE(?ITEM7),STD(STD:HelpIndex)
                ITEM('Search Help STD:HelpSearch'),USE(?ITEM8),STD(STD:HelpSearch)
                ITEM('How to Use Help STD:HelpOnHelp'),USE(?ITEM9),STD(STD:HelpOnHelp)
            END
            ITEM('Exit!'),USE(?Exit2),STD(STD:Close)
        END
        TOOLBAR,AT(0,0,500,17),USE(?TOOLBAR1)
            BUTTON('Client 1'),AT(1,1,44,16),USE(?ClientFrame1),TIP('Open Client 1 Window'),FLAT,LEFT
            BUTTON('Client 2'),AT(51,1,44,16),USE(?ClientFrame2),TIP('Open Client 2 Window'),FLAT,LEFT
            BUTTON('Capture Stop Frame'),AT(100,1,89,16),USE(?CaptureStop),TIP('Call Capture Hide'),FLAT
            BUTTON('Capture OK'),AT(190,1,,16),USE(?CaptureOK),TIP('Call Capture OK'),FLAT
        END
    END
    CODE
    OPEN(AppFrame)
    0{PROP:text}=clip(0{PROP:text}) &' - Wnd=' & 0{PROP:Handle} & |
            ' - Clarion ' & system{PROP:LibVersion,2} &'.'& system{PROP:LibVersion,3} &' - '& system{PROP:WindowsVersion}
    Accept
        case event()
        end
        Case Accepted()
        of ?ClientWindow1 orof ?CLientFrame1 ; START(Client1Window)
        of ?ClientWindow2 orof ?CLientFrame2 ; START(Client2Window)
        of ?NonMDIOpen                       ; NonMdiWindow()
        of ?NonMDIStart                      ; START(NonMdiWindow)

        of ?CaptureStop ; CaptureCls.CaptureStop()
        of ?CaptureOK   ; CaptureCls.CaptureOK()

        end
    end
    Close(AppFrame)
    return
!------------
Client1Window    procedure
Entry1      string(20)
Entry2      string(20)
Window WINDOW('Client 1 MDI'),AT(,,206,136),MDI,GRAY,SYSTEM,ICON(ICON:Child),FONT('Segoe UI',8),RESIZE
        PROMPT('Entry1'),AT(4,7),USE(?PROMPT1)
        ENTRY(@s20),AT(55,7,89,10),USE(Entry1)
        PROMPT('Entry2'),AT(4,18),USE(?PROMPT2)
        ENTRY(@s20),AT(55,18,89,10),USE(Entry2)
        BUTTON('OK'),AT(39,49),USE(?OkBtn)
        BUTTON('Std:Close'),AT(75,49),USE(?CloseBtn),STD(STD:Close)
        BUTTON('Client 1'),AT(153,49),USE(?Client1Btn),TIP('Open another client 1 to check for parent')
        BUTTON('MDI Capture Stop'),AT(65,75,,16),USE(?CaptureStop),TIP('Call Capture STOP')
        BUTTON('MDI Capture OK'),AT(65,95,,16),USE(?CaptureOK),TIP('Call Capture OK')
        STRING('Capture Stopped?'),AT(65,115,,16),USE(?CaptureStop:2)
    END
    code
    open(Window) 
    0{prop:Text}=clip(0{prop:Text}) & |
            ' - Wnd=' & 0{PROP:Handle} &|
            ' - Parent=' & GetParent(0{PROP:Handle}) &  |
            ' - Root=' & GetAncestor(0{PROP:Handle},GA_ROOT) &  |
            ' - Thread ' & Thread()

   ?CaptureStop{'TextB4'}=?CaptureStop{Prop:Text}
   ?CaptureOK{'TextB4'}=?CaptureOK{Prop:Text}
        
    accept
        case EVENT()
        end
        case FIELD()
        end
        case ACCEPTED()
        of ?Client1Btn  ; Client1Window()
        of ?CaptureStop ; CaptureCls.MdiCaptureStop() ; ?CaptureStop{Prop:Text}=?CaptureStop{'TextB4'} &' MdiStopCnt=' & CaptureCls.MdiStopCnt
        of ?CaptureOK   ; CaptureCls.MdiCaptureOK()   ; ?CaptureOK{Prop:Text}=?CaptureOK{'TextB4'} &' MdiStopCnt=' & CaptureCls.MdiStopCnt
        end
        ?CaptureStop:2{PROP:Text}='IsStoppped=' & CaptureCls.IsStopped()
    end
    close(Window)
!-----------------------------------
Client2Window    procedure
Window WINDOW('Client 2 MDI'),AT(,,206,110),MDI,GRAY,SYSTEM,ICON(ICON:Child),FONT('Segoe UI',8),RESIZE
        PROMPT('&Prompt1'),AT(10,8),USE(?PROMPT1)
        ENTRY(@s20),AT(47,7),USE(?ENTRY1)
        CHECK('&Check1'),AT(46,23),USE(?CHECK1)
        OPTION('Optio&n1'),AT(47,34,,41),USE(?OPTION1),BOXED
            RADIO('&Radio1'),AT(52,47),USE(?OPTION1:RADIO1)
            RADIO('R&adio2'),AT(52,60),USE(?OPTION1:RADIO2)
        END
        BUTTON('&OK'),AT(56,86),USE(?OkBtn)
        BUTTON('Std:Close'),AT(106,86),USE(?CloseBtn),STD(STD:Close)

    END
    code
    open(Window) 
    0{prop:Text}=clip(0{prop:Text}) & |
            ' - Wnd=' & 0{PROP:Handle} &|
            ' - Parent=' & GetParent(0{PROP:Handle}) &  |
            ' - Root=' & GetAncestor(0{PROP:Handle},GA_ROOT) &  |
            ' - RootOwn=' & GetAncestor(0{PROP:Handle},GA_ROOTOWNER) &  |
            ' - Thread ' & Thread()
    
    DB('Client 2','Accept Loop Starts')
    accept 
        case EVENT()
        of event:OpenWindow 
        of event:CloseWindow 
        end
        case FIELD()
        end
        case ACCEPTED()
        !OF ?OkBtn
        end
    end
    close(Window)
!-----------------------------------
NonMdiWindow    procedure
Window WINDOW('Not MDI'),AT(,,206,110),FONT('Segoe UI',8,,),ICON(Icon:Child),SYSTEM,GRAY,RESIZE
       BUTTON('OK'),AT(56,48),USE(?OkBtn)
       BUTTON('Std:Close'),AT(106,48),USE(?CloseBtn),STD(STD:Close)
        BUTTON('Capture Stop'),AT(10,75,61,16),USE(?CaptureStop),TIP('Call Capture STOP')
        BUTTON('Capture OK'),AT(75,75,,16),USE(?CaptureOK),TIP('Call Capture OK')

     END
    code
    open(Window) !; 0{prop:Text}=clip(0{prop:Text}) & ' - Thread ' & Thread()
    0{prop:Text}=clip(0{prop:Text}) & |
            ' - Wnd=' & 0{PROP:Handle} &|
            ' - Parent=' & GetParent(0{PROP:Handle}) &  |
            ' - Root=' & GetAncestor(0{PROP:Handle},GA_ROOT) &  |
            ' - Thread ' & Thread()
    
    accept
        case EVENT()
        of event:OpenWindow 
        end
        case FIELD()
        end
        case ACCEPTED()
        OF ?OkBtn 
        of ?CaptureStop ; CaptureCls.CaptureStop()
        of ?CaptureOK   ; CaptureCls.CaptureOK()        
        end
    end
    close(Window)

!===============================
DB                   PROCEDURE (<STRING Sec>, STRING Info) 
DBC     CSTRING(512),AUTO
    CODE
    IF ~OMITTED(1)
        DBC = CLIP(Sec) & ': ' & CLIP(Info) & '<13,10>'
    ELSE
        DBC = CLIP(Info)                    & '<13,10>'
    END
    OutputDebugString(DBC)
    RETURN
