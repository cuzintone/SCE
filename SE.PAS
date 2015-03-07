(*
 $Id: se.pas 1.12 2003/01/05 05:56:21 Tony Exp Tony $
 $Log: se.pas $
 Revision 1.12  2003/01/05 05:56:21  Tony
 *** empty log message ***

 Revision 1.11  2002/01/18 09:30:49  tony
 Fixed code

 Revision 1.10  2002/01/08 17:32:20  tony
 Release to manufacture

 Revision 1.9  2001/09/19 04:45:31  tony
 Added support for Win NT configuration file loading

 Revision 1.8  2001/09/13 06:13:52  tony
 Tweaked code

 Revision 1.7  2001/09/04 15:40:44  tony
 Fixed menu bar, status bar, cleaned up code

 Revision 1.6  2001/08/24 08:36:32  tony
 Added help hints and color selection dialog

 Revision 1.5  2001/08/17 02:43:51  tony
 Cleaned up command line parsing routine

 Revision 1.4  2001/08/16 09:45:03  tony
 Updated revision code, fixed command line parsing routines, added
 usage information.


 Revision 1.3  2001/08/15 19:21:55  tony
 Updated revision code and fixed /B switch function so that the backup
 flag is actually turned off

 Revision 1.2  2001/08/14 17:05:33  tony
 Added RCSID line to source

 Revision 1.1  2001/08/13 15:57:25  tony
 Initial revision


        System Editor
        Version 1.00

        Copyright (C) AGE Software
        All rights reserved

        Purpose: Full screen system editor.
        FILENAME: SE.PAS



*)
{$M 8192,8192,655360}
{$X+,S-}


uses Dos, Strings, ColorSel, App, Editors, StdDlg, Dialogs, Memory, MsgBox, Objects, Menus, Drivers, Views;

type
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object(TStatusLine)
    function Hint (AHelpCtx : Word) : String; virtual;
  end;

  TSysEdit = object(TApplication)
    AboutBox : PDialog;
    constructor Init;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure About;
    procedure ColorSelDialog;
  end;

  TVersion = record
    OSName : PString;
    Maj, Min, Rev : longint;
  end;

const
  RCSID : String = '$Id: se.pas 1.12 2003/01/05 05:56:21 Tony Exp Tony $';
  RCSRev : String = '$Revision: 1.12 $';
  ID : String = 'FreeDOS SysEdit';
  Copyright : String = 'Copyright (C) 2001-2003 AGE Software';
  sBanner = '%s - Version %d.%d (Build %04d LeSabre)';
  VERSION : TVersion = (OSName:@ID;Maj:1;Min:0;Rev:0112);
  cmAbout        = 100;
  cmClipShow     = cmAbout + 1;
  cmHelp         = cmClipShow + 1;
  cmPrint        = cmHelp + 1;
  cmOptionsVideo = cmPrint + 1;
  cmOptionsSave  = cmOptionsVideo + 1;
  cmOptionsLoad  = cmOptionsSave + 1;
  cmColors       = cmOptionsLoad + 1;

  hcPrint        = 1000;
  hcFind         = hcPrint + 1;
  hcReplace      = hcFind + 1;
  hcSearchAgain  = hcReplace + 1;
  hcOptionsVideo = hcSearchAgain + 1;
  hcAbout        = hcOptionsVideo + 1;
  hcClipShow     = hcAbout + 1;
  hcColors       = hcClipShow + 1;
  hcAboutDlg     = hcColors + 1;
  hcColorDlg     = hcAboutDlg + 1;

  hcFileMenu     = 2000;
  hcEditMenu     = hcFileMenu + 1;
  hcSearchMenu   = hcEditMenu + 1;
  hcOptionsMenu  = hcSearchMenu + 1;
  hcWindowMenu   = hcOptionsMenu + 1;
  hcHelpMenu     = hcWindowMenu + 1;


  WinNum : byte = 1;
  HeapSize = 48 * (1024 div 16);    (* 48K buffer *)


var
  ClipWindow : PEditWindow;  (* Create clipboard window *)
  Editor     : TSysEdit;
  Mono, BW   :  Boolean;
  i          : byte;
  S          : String;
  progname   : string[8];
  P          : Pchar;

procedure Usage;

begin
  FormatStr(S, sBanner, VERSION);
  PrintStr(S);
  PrintStr(#9+Copy(RCSRev,2,(Length(RCSRev) - 2)));
  PrintStr(#13#10#13#10'Editor for system configuration files'#13#10#13#10);
  PrintStr(progname+' [/B] [/BW] [/M] [/?]'#13#10#13#10);
  PrintStr('  /B   - turns off the auto backup feature'#13#10);
  PrintStr('  /BW  - show in black and white on a color monitor'#13#10);
  PrintStr('  /M   - force monochrome mode'#13#10);
  PrintStr('  /?   - displays this help screen'#13#10);
end;

function GetProgName(S : String) : string;
var
  D : DirStr;
  N : NameStr;
  E : ExtStr;
begin
  FSplit(S, D, N, E);
  GetProgName := N;
end;

{

This portion of unused code to display OS information

procedure OSInfo(var p : TVersion; var S : String);

var EDC_Product : word;

begin
  EDC_Product := is_drdos;
  if EDC_Product <> 0 then
  begin
    case EDC_Product of
      $1060 : S := 'DOS Plus';
      $1063 : S := 'DR DOS 3.41';
      $1064 : S := 'DR DOS 3.42';
      $1065 : S := 'DR DOS 5.0';
      $1067 : S := 'DR DOS 6.0';
      $1070 : S := 'DR DOS PalmDOS';
      $1071 : S := 'DR DOS 6.0 March ''93 update';
      $1072 : S := 'Novell DOS 7.0';
      $1432 : S := 'Concurrent PC-DOS 3.2';
      $1441 : S := 'Concurrent DOS 4.1';
      $1450 : S := 'Concurrent DOS/XM 5.0 or Concurrent DOS/386 1.1';
      $1460 : S := 'Concurrent DOS/XM 6.0 or Concurrent DOS/386 2.0';
      $1462 : S := 'Concurrent DOS/XM 6.2 or Concurrent DOS/386 3.0';
      $1466 : S := 'DR Multiuser DOS 5.1';
      $1467 : S := 'Concurrent DOS 5.1';
      else  S := 'Unknown DR DOS version';
    end;
  end;
  case GetOEMNumber of
    $00 : S :='IBM ';
    $01 : S :='Compaq ';
    $02 : S :='Microsoft MS-';
    $04 : S :='AT&T ';
    $05 : S :='ZDS (Zenith Electronics) ';
    $06 : S :='HP ';
    $07 : S :='ZDS (Groupe Bull) ';
    $0D : S :='Packard Bell ';
    $16 : S :='DEC ';
    $23 : S :='Olivetti ';
    $28 : S :='TI ';
    $29 : S :='Toshiba ';
    $33 : S :='Novell (Windows/386 device IDs only) ';
    $34 .. $35 :
      S :='MS Multimedia Systems (Windows/386 device IDs only) ';
    $4D : S :='HP ';
    $5E : S :='Rx';
    $66 : S :='PTS-';
    $99 : S :='General Software''s Embedded ';
    $EE : S :='DR ';
    $EF : S :='Novell ';
    $FD : S :='Free';
    $FF : S :='Microsoft MS-';
    else
  end;
  S:= S +'DOS';
  p.Maj := Lo(DosVersion);
  p.Min := Hi(DosVersion);
end;

This code block may be removed at a later time

}

function THintStatusLine.Hint(AHelpCtx : Word) : String;
begin
  case AHelpCtx of
    hcNew  : Hint := 'Create a new file in a new edit window';
    hcOpen : Hint := 'Locate and open a file in an edit window';
    hcSave : Hint := 'Save the file in the active edit window';
    hcPrint : Hint := 'Print the contents of the active edit window';
    hcDosShell : Hint := 'Temporarily exit to DOS';
    hcExit : Hint := 'Exit SysEdit';
    hcUndo : Hint := 'Undo the previous editor operation';
    hcCut : Hint := 'Removes the current selection and copies it to the clipboard';
    hcCopy : Hint := 'Copies the current selection to the clipboard';
    hcPaste : Hint := 'Insert items you have copied or cut into the selected area';
    hcClear : Hint := 'Deletes the selected text';
    hcFind : Hint := 'Search for text';
    hcReplace : Hint := 'Search for text and replace it with new text';
    hcSearchAgain : Hint := 'Repeat the last find or replace command';
    hcOptionsVideo : Hint := 'Switch between hi res and low res mode';
    hcTile : Hint := 'Arrange windows on desktop by tiling';
    hcCascade : Hint := 'Arrange windows on desktop by cascading';
    hcCloseAll : Hint := 'Close all windows on the desktop';
    hcResize : Hint :=  'Change the size of the active window';
    hcZoom : Hint := 'Enlarge or restore the size of the active window';
    hcNext : Hint := 'Make the next window active';
    hcPrev : Hint := 'Make the previous window active';
    hcClose : Hint := 'Close the active window';
    hcAbout : Hint := 'Show version and copyright information';
    hcClipShow : Hint := 'Show contents of the clipboard';
    hcColors : Hint := 'Customize editor colors';
    hcFileMenu : Hint := 'File management commands (Open, Save, etc)';
    hcEditMenu : Hint := 'Cut-and-paste editing commands';
    hcSearchMenu : Hint := 'Text search commands';
    hcOptionsMenu : Hint := 'Set defaults for editor';
    hcWindowMenu : Hint := 'Open and arrange windows';
    hcHelpMenu : Hint := 'Get online help';
    hcAboutDlg : Hint := 'Welcome to System Config Editor. Press Enter to close this dialog box';
    hcColorDlg : Hint := 'Use cursor keys to select an editor group and customize its colors';
  else
    Hint := '';
  end;
end;

function OpenEditor(theFile: FNameStr; Visible: Boolean): PEditWindow;
(*
The OpenEditor is used by the event handler to actually open files. It can
generate a new editor window, or create an editor window for an existing file
*)

var
  P: PWindow;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := New(PEditWindow, Init(R, theFile, WinNum));
  if not Visible then P^.Hide;
  OpenEditor := PEditWindow(Application^.InsertWindow(P));
  inc(WinNum);
end;

procedure Open(FName, Path : String);
var
  P : PathStr;
begin
  P := FSearch(FName, Path);
  If Length(P) <> 0 then OpenEditor(FExpand(P), true);
end;

procedure OpenConfigFiles;

var
  D : String[3];
  R : Registers;

begin
  Open('WIN.INI', GetEnv('PATH'));
  Open('SYSTEM.INI', GetEnv('PATH'));
  Open('PROTOCOL.INI', GetEnv('PATH'));
  Open('AUTOEXEC.NT', GetEnv('PATH'));
  Open('CONFIG.NT', GetEnv('PATH'));
  r.ah := $19;
  msdos(r);
  D := chr((65+r.al))+':\';
  Open('AUTOEXEC.BAT', D);
  Open('CONFIG.SYS', D);
  Open('FDCONFIG.SYS', D);
end; (* OpenConfigFiles *)

(*
  Turbo Vision Code begins here for the user interface
*)

constructor TSysEdit.Init;
(*
        Application initialization, sets up the heapsize and the clipboard
*)
var
  i : byte;


begin
  MaxHeapSize := HeapSize;
  inherited Init;
  if Mono then SetScreenMode(smMono);
  if BW then SetScreenMode(smBW80);
  EditorFlags := EditorFlags or efBackupFiles;
  DisableCommands([cmOpen, cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmPrint, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', False);
  dec(WinNum);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
  About;
  OpenConfigFiles;
  Cascade;
end;

procedure TSysEdit.ColorSelDialog;
var
  R : TRect;
  D : PDialog;

begin
 D := New(PColorDialog, Init('',
   ColorGroup('Desktop',          DesktopColorItems(nil),
   ColorGroup('Menus',            MenuColorItems(nil),
   ColorGroup('Editor/Windows',   WindowColorItems(wpBlueWindow, nil),
   ColorGroup('Dialog Boxes',     DialogColorItems(dpGrayDialog, nil),
     nil))))));
 D^.HelpCtx := hcColorDlg;
 if ExecuteDialog(D, Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;
    ReDraw;
  end;
end;

procedure TSysEdit.InitStatusLine;
var R : TRect;
begin
  GetExtent(R);                         (* get application boundaries *)
  R.A.Y := R.B.Y - 1;                   (* set top to one above bottom *)
  StatusLine := New(PHintStatusLine, Init(R,
    NewStatusDef(0, 999,
      NewStatusKey('', kbF1, cmHelp,
      NewStatusKey('~F2~ Save', kbF2, cmSave,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(nil)))),
    NewStatusDef(1000, $FFFF,
      NewStatusKey('', kbF1, cmHelp,
      nil), nil))));
end;

procedure TSysEdit.InitMenuBar;
var R : TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcFileMenu, NewMenu(
      NewItem('~S~ave','F2', kbF2, cmSave, hcSave,
      NewItem('~P~rint', 'Ctrl+PrtScr', kbCtrlPrtSc, cmPrint, hcPrint,
      NewItem('~D~OS Shell', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('E~x~it','Alt+X', kbAltX, cmQuit, hcExit,
      nil))))),
    NewSubMenu('~E~dit', hcEditMenu, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmClipShow, hcClipShow,
        nil)))),
    NewSubMenu('~S~earch', hcSearchMenu, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcFind,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcReplace,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcSearchAgain,
      nil)))),
    NewSubMenu('~O~ptions', hcOptionsMenu, NewMenu(
      NewItem('~T~oggle video', '', kbNoKey, cmOptionsVideo, hcOptionsVideo,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcColors,
    nil))),
    NewSubMenu('~W~indow', hcWindowMenu, NewMenu(
      StdWindowMenuItems(nil)),
    NewSubMenu('~H~elp', hcHelpMenu, NewMenu(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcAbout, nil)),
    nil)))))))));
end;

procedure TSysEdit.About;
{
        Draws about box
}

var
  S : String;
  R : TRect;

begin
  R.Assign(0, 0, 55, 12);
  AboutBox := New(PDialog, Init(R, 'About System Config Editor'));
  with AboutBox^ do begin
    Options := Options or ofCentered;
    HelpCtx := hcAboutDlg;
    R.Assign(1,4,54,5);
    FormatStr(S, #3+sBanner, VERSION);
    Insert(New(PStaticText, Init(R, S)));
    R.Assign(1, 6, 54, 7);
    Insert(New(PStaticText, Init(R, #3+Copyright)));
    R.Assign(23, 8, 32, 10);
    Insert(New(PButton, Init(R, '~C~lose', cmOK, bfDefault)));
  end;
  ExecuteDialog(AboutBox, nil);

end;

procedure TSysEdit.HandleEvent;
(*
  Event handler code
*)
  procedure ChangeDir;
  begin
    ExecuteDialog(New(PChDirDialog, Init(cdNormal, 0)), nil);
  end;

  procedure ChangeVideo;
  begin
    SetScreenMode(ScreenMode xor smFont8x8);
  end;
  procedure ShowClip;
  begin
    ClipWindow^.Select;
    ClipWindow^.Show;
  end;

{ Main portion of event handler }
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  case Event.Command of
    cmOptionsVideo   : ChangeVideo;
    cmColors         : ColorSelDialog;
    cmClipShow       : ShowClip;
    cmChangeDir      : ChangeDir;
    cmAbout          : About;
   else
     exit;
  end;
  ClearEvent(Event);
end;

{ Main execution portion }
begin
(*
  Let's make the following assumptions -
     1. You can't directly write to video memory
     2. We are using a color video adapter
     3. We are in color mode
*)

  BW := false;
  Mono := false;
  if Lo(DosVersion) < 3 then begin
    PrintStr('System Config Editor requires DOS 3.0 or higher'#13#10);
    halt(255);
  end;

  if paramstr(0) <> '' then progname := GetProgName(paramstr(0));
  if paramcount > 0 then
    for i := 1 to paramcount do begin
      StrPCopy(P, paramstr(i));
      StrUpper(P);
      inc(P);
      case char( P^) of
        'B' :
          begin
            inc (P);
            if char(P^) = 'W' then
            BW := true
            else
             EditorFlags := EditorFlags xor efBackupFiles;
            end;
        'M' : Mono := true;
        '?', 'H' :
          begin
            Usage;
            halt;
          end;
        'I' :
         begin
           FormatStr(S, sBanner, VERSION);
           PrintStr(S);
           PrintStr(#9+Copy(RCSRev,2,(Length(RCSRev) - 2))+#13#10);
           halt;
         end;
        else;
      end;
    end;
  Editor.Init;
  Editor.Run;
  Editor.Done;
end.
