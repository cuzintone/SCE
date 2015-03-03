{
$Id: SEUI.PAS 1.0 2003/01/15 21:13:49 tony Exp tony $
$Log: SEUI.PAS $
Revision 1.0  2003/01/15 21:13:49  tony
Initial revision



        System Configuration System Configuration Editor
        Version 1.0
        Written by Antony Gordon
        Copyright 2003 AGE Software

        ----------------------------------

    This file is part of System Configuration Editor.
    System Configuration Editor is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    System Configuration Editor is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with System Configuration Editor.  If not, see <http://www.gnu.org/licenses/>.

        ----------------------------------


        Filename: SEUI.PAS
        Contains Turbo Vision routines
}

unit SEUI;

interface

uses Strings, ColorSel, App, Editors, StdDlg, Dialogs, Memory, MsgBox,
     Objects, Menus, Drivers, Views;
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
    procedure OutOfMemory; virtual;
  end;

implementation

uses Dos, SeConst;

var
  ClipWindow : PEditWindow;  (* Create clipboard window *)
  Editor     : TSysEdit;

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
  cmdSet : TCommandSet;


begin
  cmdSet := [cmOpen, cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmPrint, cmFind, cmReplace, cmSearchAgain];
  MaxHeapSize := HeapSize;
  inherited Init;
  if Mono then SetScreenMode(smMono);
  if BW then SetScreenMode(smBW80);
  EditorFlags := EditorFlags or efBackupFiles;
  DisableCommands(cmdSet);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', False);
  dec(WinNum);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
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

procedure TSysEdit.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.',
    nil, mfError + mfOkButton);
end;

{$IFDEF Debug}
begin
  writeln('Loading user interface module...');
{$ENDIF}
end.