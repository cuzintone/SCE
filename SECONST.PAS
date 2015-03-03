{


        System Configuration Editor
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

        Filename: SECONST.PAS
        Contains global constants for the editor

}

unit SEConst;

interface

{$IFNDEF SECONST}
{$DEFINE SECONST}
{$ENDIF}
uses Objects;

type
  TVersion = record
    OSName :PString;
    Maj, Min, Rev : longint;
  end;

const
  RCSID : String = '$Id: SECONST.PAS 1.0 2015/01/15 21:13:38 tony Exp tony $';
  RCSRev : String = '$Revision: 1.0 $';
  ID : String = 'System Configuration Editor';
  Copyright : String = 'Copyright (C) 2015 AGE Software';
  sBanner = '%s - Version %d.%d.%06d';
  VERSION : TVersion = (OSName:@ID;Maj:1;Min:0;Rev:150227);
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
  Mono, BW : Boolean;

implementation
{$IFDEF Debug}
begin
  writeln('Loading global constants...');
{$ENDIF}
end.