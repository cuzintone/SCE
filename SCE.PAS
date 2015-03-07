{
$Id: SCW.PAS 1.0 2003/01/15 21:13:22 tony Exp tony $
$Log: SCW.PAS $
Revision 1.0  2003/01/15 21:13:22  tony
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

        Filename: SCE.PAS
        Main program
}

{$M 16384,8192,655360}
{$X+,S-}

uses seui, seconst;

var SCEditor : TSysEdit;


begin
  {$IFDEF Debug}
  writeln('Debug defined.');
  {$ENDIF}
  SCEditor.Init;
  SCEditor.Run;
  SCEditor.Done;
end.
