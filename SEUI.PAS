{
$Id: SEUI.PAS 1.0 2003/01/15 21:13:49 tony Exp tony $
$Log: SEUI.PAS $
Revision 1.0  2003/01/15 21:13:49  tony
Initial revision

        2015-03-03   adg   Move Hints into the private section of this unit
                           since there is no code that needs to manipulate
                           it directly. The only exposed type is the TSCApp



        System Configuration Editor
        Version 1.0
        Written by Antony Gordon
        Copyright 2003 AGE Software

        ----------------------------------

        Filename: SEUI.PAS
        Contains Turbo Vision routines
}

unit SEUI;

interface

uses Strings, ColorSel, App, Editors, StdDlg, Dialogs, Memory, MsgBox,
     Objects, Menus, Drivers, Views, EventLog;

type
  PSCApp = ^TSCApp;
  TSCApp = object(TApplication)
    Logger : PEventLog;
    ClipWindow : PEditWindow;  (* Create clipboard window *)
    BW, Mono : Boolean;
    WinNum : byte;
    AboutBox : PDialog;
    procedure About;
    procedure AdjustCommands;
    procedure ColorSelDialog;
    destructor Done; virtual;
    function GetWinNum : byte;
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure Idle; virtual;
    constructor Init(_mono, _bw : boolean);
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    function IsBW : boolean;
    function IsMono : boolean;
    procedure Open(FName, Path : String);
    procedure OpenConfigFiles;
    function OpenEditor(theFile: FNameStr; isClip, Visible: Boolean): PEditWindow;
    procedure OutOfMemory; virtual;
    procedure SetBW (_bw : boolean);
    procedure SetMono (_mono : boolean);
    procedure SetWinNum (awinnum : byte);
    procedure ToggleBackupFiles;
  end;

implementation

uses Dos, SeConst;

type
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object(TStatusLine)
    function Hint (AHelpCtx : Word) : String; virtual;
  end;


{ -- Code for Status line hints -- }

function THintStatusLine.Hint(AHelpCtx : Word) : String;
begin
  case AHelpCtx of
    hcNew  : Hint := 'Create a new file in a new edit window';
    hcOpen : Hint := 'Locate and open a file in an edit window';
    hcSave : Hint := 'Save the file in the active edit window';
    hcPrint : Hint := 'Print the contents of the active edit window';
    hcDosShell : Hint := 'Temporarily exit to DOS';
    hcExit : Hint := 'Exit System Configuration Editor';
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

{ -- Turbo Vision Code begins here for the user interface -- }

procedure TSCApp.About;
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
    R.Assign(1, 4, 54, 5);
    FormatStr(S, #3+sBanner, VERSION);
    Insert(New(PStaticText, Init(R, S)));
    R.Assign(1, 6, 54, 7);
    Insert(New(PStaticText, Init(R, #3+Copyright)));
    R.Assign(23, 8, 32, 10);
    Insert(New(PButton, Init(R, '~C~lose', cmOK, bfDefault)));
  end;
  ExecuteDialog(AboutBox, nil);
end;

procedure TSCApp.AdjustCommands;
var WinCount : string;
begin
  setCmdState([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmPrint, cmClose, cmFind, cmReplace, cmSearchAgain], WinNum > 0);
end;

destructor TSCApp.Done;
begin

  inherited Done;
  Logger^.LogEvent(elInfo,'Shutting down application');
  Dispose(Logger, Done);
end;


procedure TSCApp.ColorSelDialog;
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

function TSCApp.GetWinNum : byte;
begin
  GetWinNum := WinNum;
end;

procedure TSCApp.HandleEvent;
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
  case Event.What of
    evCommand : case Event.Command of
      cmOptionsVideo   : ChangeVideo;
      cmColors         : ColorSelDialog;
      cmClipShow       : ShowClip;
      cmChangeDir      : ChangeDir;
      cmAbout          : About;
    end;
  end;
  ClearEvent(Event);
end;

procedure TSCApp.Idle;
begin
  AdjustCommands;
  inherited Idle;
end;

constructor TSCApp.Init(_mono, _bw : boolean);
(*
        Application initialization, sets up the heapsize and the clipboard
*)
var
  i : byte;
  cmdSet : TCommandSet;


begin
  cmdSet := [cmOpen, cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmPrint, cmFind, cmReplace, cmSearchAgain];
  MaxHeapSize := 4096;
  inherited Init;
  Logger := New(PEventLog, Init('se.log', false));
  Logger^.LogEvent(elInfo,'Application started');
  if _mono then
    begin
      Mono := _mono;
      SetScreenMode(smMono);
      Logger^.LogEvent(elInfo,'Monochrome mode selected');
    end;
  if _bw then
    begin
      BW := _bw;
      SetScreenMode(smBW80);
      Logger^.LogEvent(elInfo,'Black and white mode selected');
    end;

  DisableCommands(cmdSet);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', true, False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
  WinNum := 1;
  OpenConfigFiles;
  Logger^.LogEvent(elInfo,'Opening configuration files');
  Cascade;
end;

procedure TSCApp.InitMenuBar;
var R : TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', hcNoContext, NewMenu(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcAbout, nil)),
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

    nil)))))))));
end;

procedure TSCApp.InitStatusLine;
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

function TSCApp.IsBW : Boolean;
begin
  IsBW := (BW = true);
end;

function TSCApp.IsMono : boolean;
begin
  IsMono := (Mono = True);
end;

procedure TSCApp.Open(FName, Path : String);
var
  P : PathStr;
begin
  P := FSearch(FName, Path);
  If Length(P) <> 0 then OpenEditor(FExpand(P), false, true);
end;

procedure TSCApp.OpenConfigFiles;

var
  D : String[3];
  R : Registers;
  SearchPath : String;

begin
  SearchPath := GetEnv('PATH');
  Logger^.LogEvent(elInfo,'Search path: '+ SearchPath);
  Open('WIN.INI', SearchPath);
  Open('SYSTEM.INI', SearchPath);
  Open('PROTOCOL.INI', SearchPath);
  Open('AUTOEXEC.NT', SearchPath);
  Open('CONFIG.NT', SearchPath);
  Open('4DOS.INI', SearchPath);
  if Lo(DosVersion) >= 5 then
    begin
      r.ax := $3305;
      msdos(r);
      D := chr((64+r.dl))+':\';
      Logger^.LogEvent(elInfo,'Boot drive letter: '+ D);
    end
  else
    begin
      r.ah := $19;
      msdos(r);
      D := chr((65+r.al))+':\';
      Logger^.LogEvent(elInfo,'Default drive letter: '+ D);
    end;

  Open('AUTOEXEC.BAT', D);
  Open('CONFIG.SYS', D);
  Open('FDCONFIG.SYS', D);
  Open('FDAUTO.BAT', D);
end; (* OpenConfigFiles *)

function TSCApp.OpenEditor(theFile: FNameStr; isClip, Visible: Boolean): PEditWindow;
(*
The OpenEditor is used by the event handler to actually open files. It can
generate a new editor window, or create an editor window for an existing file
*)

var
  P: PWindow;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  if isClip then
    P := New(PEditWindow, Init(R, theFile, wnNoNumber))
  else
    P := New(PEditWindow, Init(R, theFile, WinNum));
  if not Visible then P^.Hide;
   { P^.Palette := wpCyanWindow; }
  OpenEditor := PEditWindow(Application^.InsertWindow(P));
  if not isClip then
    inc(WinNum);
end;

procedure TSCApp.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.',
    nil, mfError + mfOkButton);
  Logger^.LogEvent(elError,'Memory allocation error');
end;

procedure TSCApp.SetBW(_bw : boolean);
begin
  BW := _bw;
end;

procedure TSCApp.SetMono(_mono : boolean);
begin
  Mono := _mono;
end;

procedure TSCApp.SetWinNum(awinnum : byte);
begin
  WinNum := awinnum;
end;

procedure TSCApp.ToggleBackupFiles;
begin
  EditorFlags := EditorFlags or efBackupFiles;
  Logger^.LogEvent(elInfo, 'Toggling backup file state');
end;

{$IFDEF Debug}
begin
  writeln('Loading user interface module...');
{$ENDIF}
end.