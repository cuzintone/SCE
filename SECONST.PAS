{


        System Configuration Editor
        Version 1.0
        Written by Antony Gordon
        Copyright AGE Software

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
  Copyright : String = 'Copyright (C) 2025 AGE Software';
  sBanner = '%s - v%d.%d.%06d';
  VERSION : TVersion = (OSName:@ID;Maj:1;Min:0;Rev:202504);

  { Command Constants }

  cmAbout        = 100;
  cmClipShow     = cmAbout + 1;
  cmHelp         = cmClipShow + 1;
  cmPrint        = cmHelp + 1;
  cmOptionsVideo = cmPrint + 1;
  cmOptionsSave  = cmOptionsVideo + 1;
  cmOptionsLoad  = cmOptionsSave + 1;
  cmColors       = cmOptionsLoad + 1;

  { Help context constants }

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

  { Error constants }

  erDosVersion   = 1;

implementation
{$IFDEF Debug}
begin
  writeln('Loading global constants...');
{$ENDIF}
end.