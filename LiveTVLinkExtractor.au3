#include <GUIConstantsEx.au3>
#include <File.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>
if FileExists(@Scriptdir & "\settings.ini") = 0 Then
IniWrite(@Scriptdir & "\settings.ini","global","list","http://exabytetv.info/USA.m3u|http://exabytetv.info/UK.m3u|http://exabytetv.info/ITA.m3u|http://exabytetv.info/NLD.m3u|http://exabytetv.info/ESP.m3u|http://exabytetv.info/PRT.m3u|http://exabytetv.info/SUA.m3u|http://exabytetv.info/ALB.m3u|http://exabytetv.info/FRA.m3u|http://exabytetv.info/DEU.m3u|http://exabytetv.info/TUR.m3u|http://exabytetv.info/IND.m3u|http://exabytetv.info/LA1.m3u|http://exabytetv.info/LA2.m3u|http://exabytetv.info/LA3.m3u|http://exabytetv.info/LA4.m3u|http://exabytetv.info/AMERICA.m3u|http://exabytetv.info/CABLEMX.m3u")
Endif
if FileExists(@Scriptdir & "\ffprobe.exe") = 0 Then
MsgBox(0,"LiveTVExtractor","FFprope not found please download ffmpeg and extract it to this directory")
ShellExecute("https://ffmpeg.org/download.html")
Endif

$List = IniRead(@Scriptdir & "\settings.ini","global","list","http://exabytetv.info/USA.m3u|http://exabytetv.info/UK.m3u|http://exabytetv.info/ITA.m3u|http://exabytetv.info/NLD.m3u|http://exabytetv.info/ESP.m3u|http://exabytetv.info/PRT.m3u|http://exabytetv.info/SUA.m3u|http://exabytetv.info/ALB.m3u|http://exabytetv.info/FRA.m3u|http://exabytetv.info/DEU.m3u|http://exabytetv.info/TUR.m3u|http://exabytetv.info/IND.m3u|http://exabytetv.info/LA1.m3u|http://exabytetv.info/LA2.m3u|http://exabytetv.info/LA3.m3u|http://exabytetv.info/LA4.m3u|http://exabytetv.info/AMERICA.m3u|http://exabytetv.info/CABLEMX.m3u")
If $CmdLine[0] Then
			   $Url = $CmdLine[1]
			    $Output = $CmdLine[2]
			   $append = $CmdLine[3]
			   $Audio = $CmdLine[4]
			   $Listname = $CmdLine[3]
			   DirCreate(@ScriptDir & "/Temp")
			   FileDelete(@ScriptDir & "/Temp/" & $Listname)
			   if FileExists($Output) = 0 Then
				  FileWrite($Output,"#EXTM3U" & @CRLF)
			   EndIf
			   InetGet($Url,@ScriptDir & "/Temp/" & $Listname,1)
			   $file = @ScriptDir & "/Temp/" &$Listname
			   FileOpen($file, 0)
			   For $i = 1 to _FileCountLines($file)
				  $line = FileReadLine($file, $i)
				  if StringInStr($line,"#EXTINF:" )= 0 Then
				  Else
					 $Channel = _StringBetween($line,",","")
					 $Channel = $Channel[0]
					 if StringInStr(FileReadLine($file, $i + 1),".m3u8") = 0 Then
					 Else
						$Link = FileReadLine($file, $i + 1)
						FileDelete(@ScriptDir & "\output.txt")
						$CMD = @ScriptDir & "\ffprobe.exe " & $Link & " -hide_banner 2>" & @ScriptDir & "\output.txt"
						RunWait(@ComSpec & " /c " & $CMD,"",@SW_HIDE)
						if StringInStr(FileRead(@ScriptDir & "\output.txt"),"Server returned 401") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Server returned 403") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Error when") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"error 502") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Empty playlist") Then
						Elseif not StringInStr(FileRead(@ScriptDir & "\output.txt"),"Audio: " & $Audio) Then
						Else

						   if StringInStr($line,'group-title="') = 0 Then
									FileWrite($Output,$line & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 Else
									$Group = _StringBetween($line,'group-title="','"')
									if $append = "none" Then
									   $append = $Group[0]
									EndIf
									if StringInStr(FileRead(@ScriptDir & "\output.txt"),"1280x720") = 0 Then
									   $quality = "SD"
									Else
									   $quality = "HD"
									EndIf
									$append = StringReplace($append,"%origonal", $Group[0])
									$append = StringReplace($append,"%quality", $quality)
									$ChannelName = StringReplace($line,'group-title="' & $Group[0] & '"','group-title="' & $append & '"')
									FileWrite($Output,$ChannelName & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 EndIf
						EndIf

					EndIf
				 EndIf


			Next
			FileClose(@ScriptDir & "/Temp/" & $Listname)
		 Else
			Example()
		 EndIf



Func Example()
    ; Create a GUI with various controls.
    Local $hGUI = GUICreate("LiveTV Link Extractor",270,360)

    Local $idOK = GUICtrlCreateButton("Build List", 10, 280, 250, 50)
	GUICtrlCreateLabel("List",10,10,250,25)
   $URL = GUICtrlCreateCombo("http://bit.ly/1tg_playlist1",10,30,250,25)
	   GUICtrlSetData($URL, $List, "http://bit.ly/1tg_playlist1")
	   GUICtrlCreateLabel("Output File",10,55,250,25)
	   $OutPut = GUICtrlCreateInput(@DesktopDir & "\livetv.m3u",10,80,250,25)
	   GUICtrlCreateLabel("Append Group Name",10,110,250,25)
	   $append = GUICtrlCreateInput("1 Tech",10,135,250,25)
	   GUICtrlCreateLabel("only allow audio format",10,165,250,25)
	   $audio = GUICtrlCreateInput("aac",10,190,250,25)
	   $Progress = GUICtrlCreateLabel("awaiting selection",10,250,250,25)
    ; Display the GUI.
    GUISetState(@SW_SHOW, $hGUI)

    ; Loop until the user exits.
    While 1
        Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
		   ExitLoop
		 case $idOK
			   $Url = GUICtrlRead($URL)
			   $append = GUICtrlRead($append)
			   $Output = GUICtrlRead($OutPut)
			   $Listname = GUICtrlRead($append)
			   $Audio = GUICtrlRead($audio)
			   DirCreate(@ScriptDir & "/Temp")
			   FileDelete(@ScriptDir & "/Temp/" & $Listname)
			   if FileExists($Output) = 0 Then
				  FileWrite($Output,"#EXTM3U" & @CRLF)
			   EndIf
			   GUICtrlSetData($Progress,"Grabbing List")
			   InetGet($Url,@ScriptDir & "/Temp/" & $Listname,1)
			   $file = @ScriptDir & "/Temp/" &$Listname
			   FileOpen($file, 0)
			   For $i = 1 to _FileCountLines($file)
				  $line = FileReadLine($file, $i)
				  if StringInStr($line,"#EXTINF:" )= 0 Then
				  Else
					 $Channel = _StringBetween($line,",","")
					 $Channel = $Channel[0]
					 GUICtrlSetData($Progress,"Checking " & $Channel)
					 if StringInStr(FileReadLine($file, $i + 1),".m3u8") = 0 Then
						GUICtrlSetData($Progress,$Channel & " has no m3u8 file")
					 Else
						$Link = FileReadLine($file, $i + 1)
						FileDelete(@ScriptDir & "\output.txt")
						$CMD = @ScriptDir & "\ffprobe.exe " & $Link & " -hide_banner 2>" & @ScriptDir & "\output.txt"
						RunWait(@ComSpec & " /c " & $CMD,"",@SW_HIDE)
						if StringInStr(FileRead(@ScriptDir & "\output.txt"),"Server returned 401") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Server returned 403") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Error when") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"error 502") Then
						Elseif StringInStr(FileRead(@ScriptDir & "\output.txt"),"Empty playlist") Then
						Elseif not StringInStr(FileRead(@ScriptDir & "\output.txt"),"Audio: " & $Audio) Then
						Else

						   if StringInStr($line,'group-title="') = 0 Then
									FileWrite($Output,$line & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 Else
									$Group = _StringBetween($line,'group-title="','"')
									if $append = "none" Then
									   $append = $Group[0]
									EndIf
									if StringInStr(FileRead(@ScriptDir & "\output.txt"),"1280x720") = 0 Then
									   $quality = "SD"
									Else
									   $quality = "HD"
									EndIf
									$append = StringReplace($append,"%origonal", $Group[0])
									$append = StringReplace($append,"%quality", $quality)
									$ChannelName = StringReplace($line,'group-title="' & $Group[0] & '"','group-title="' & $append & '"')
									FileWrite($Output,$ChannelName & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 EndIf
						EndIf

					EndIf
				 EndIf


			Next
			FileClose(@ScriptDir & "/Temp/" & $Listname)
			GUICtrlSetData($Progress,"Finished")
        EndSwitch
    WEnd

    ; Delete the previous GUI and all controls.
    GUIDelete($hGUI)
EndFunc   ;==>Example