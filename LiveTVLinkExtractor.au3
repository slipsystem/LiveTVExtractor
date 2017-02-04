#include <GUIConstantsEx.au3>
#include <File.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>
if FileExists(@Scriptdir & "\settings.ini") = 0 Then
IniWrite(@Scriptdir & "\settings.ini","global","list","http://exabytetv.info/USA.m3u|http://exabytetv.info/UK.m3u|http://exabytetv.info/ITA.m3u|http://exabytetv.info/NLD.m3u|http://exabytetv.info/ESP.m3u|http://exabytetv.info/PRT.m3u|http://exabytetv.info/SUA.m3u|http://exabytetv.info/ALB.m3u|http://exabytetv.info/FRA.m3u|http://exabytetv.info/DEU.m3u|http://exabytetv.info/TUR.m3u|http://exabytetv.info/IND.m3u|http://exabytetv.info/LA1.m3u|http://exabytetv.info/LA2.m3u|http://exabytetv.info/LA3.m3u|http://exabytetv.info/LA4.m3u|http://exabytetv.info/AMERICA.m3u|http://exabytetv.info/CABLEMX.m3u")
Endif
$List = IniRead(@Scriptdir & "\settings.ini","global","list","http://exabytetv.info/USA.m3u|http://exabytetv.info/UK.m3u|http://exabytetv.info/ITA.m3u|http://exabytetv.info/NLD.m3u|http://exabytetv.info/ESP.m3u|http://exabytetv.info/PRT.m3u|http://exabytetv.info/SUA.m3u|http://exabytetv.info/ALB.m3u|http://exabytetv.info/FRA.m3u|http://exabytetv.info/DEU.m3u|http://exabytetv.info/TUR.m3u|http://exabytetv.info/IND.m3u|http://exabytetv.info/LA1.m3u|http://exabytetv.info/LA2.m3u|http://exabytetv.info/LA3.m3u|http://exabytetv.info/LA4.m3u|http://exabytetv.info/AMERICA.m3u|http://exabytetv.info/CABLEMX.m3u")
If $CmdLine[0] Then
			   $Url = $CmdLine[1]
			    $Output = $CmdLine[2]
			   $append = $CmdLine[3]
			   $Speed = $CmdLine[4]
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
					 $info = InetGet(FileReadLine($file, $i + 1),@ScriptDir & "/Temp/" & $Channel,1,1)
					 $End = 1
					 If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
						Do
						If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
						   $End1 = $End + 1
						   Sleep(500)
						Else
						   $End1 = 6
						EndIf
						$End = $End1
						Until $End = 6
					 EndIf
					 InetClose($info)
					 If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
					 Else
						if StringInStr(fileRead(@ScriptDir & "/Temp/" & $Channel),".ts") = 0 Then
						Else
						   $Stream = StringTrimRight(FileReadLine($file, $i + 1),4)
						   $inetstream = InetGet($Stream & "ts",@ScriptDir & "/Temp/" & $Channel & ".ts",1,1)
						   Sleep(3000)
						   InetClose($inetstream)
						   If FileExists(@ScriptDir & "/Temp/" & $Channel & ".ts") = 0 then
						   Else
							  If FileGetSize(@ScriptDir & "/Temp/" & $Channel & ".ts") > $Speed*1024*3 Then
								 if StringInStr($line,'group-title="') = 0 Then
									FileWrite($Output,$line & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 Else
									$Group = _StringBetween($line,'group-title="','"')
									if $append = "none" Then
									   $append = $Group[0]
									EndIf
									$ChannelName = StringReplace($line,'group-title="' & $Group[0] & '"','group-title="' & $append & '"')
									FileWrite($Output,$ChannelName & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
								 EndIf
							  Else
							  EndIf
						   EndIf
						EndIf
					 EndIf
				  EndIf
				  FileDelete(@ScriptDir & "/Temp/" & $Channel)
			   FileDelete(@ScriptDir & "/Temp/" & $Channel & ".ts")
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
	   GUICtrlCreateLabel("Reject Connections Slower Than",10,165,250,25)
	   $speed = GUICtrlCreateInput("0",10,190,250,25)
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
			   $Speed = GUICtrlRead($speed)
			   $Listname = GUICtrlRead($append)
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
					 $info = InetGet(FileReadLine($file, $i + 1),@ScriptDir & "/Temp/" & $Channel,1,1)
					 $End = 1
					 If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
						Do
						If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
						   $End1 = $End + 1
						   Sleep(500)
						Else
						   $End1 = 6
						EndIf
						$End = $End1
						Until $End = 6
					 EndIf
					 InetClose($info)
					 If FileExists(@ScriptDir & "/Temp/" & $Channel) = 0 Then
						GUICtrlSetData($Progress,$Channel & " link is dead")
					 Else
						if StringInStr(fileRead(@ScriptDir & "/Temp/" & $Channel),".ts") = 0 Then
						   GUICtrlSetData($Progress,$Channel & " no stream found in m3u8 file")
						Else
						   $Stream = StringTrimRight(FileReadLine($file, $i + 1),4)
						   $inetstream = InetGet($Stream & "ts",@ScriptDir & "/Temp/" & $Channel & ".ts",1,1)
						   Sleep(3000)
						   InetClose($inetstream)
						   If FileExists(@ScriptDir & "/Temp/" & $Channel & ".ts") = 0 then
							  GUICtrlSetData($Progress,$Channel & " unable to playback stream")
						   Else
							  If FileGetSize(@ScriptDir & "/Temp/" & $Channel & ".ts") > $Speed*1024*3 Then
								 if StringInStr($line,'group-title="') = 0 Then
									FileWrite($Output,$line & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
									GUICtrlSetData($Progress,$Channel & " added to list but group was not appended")
								 Else
									$Group = _StringBetween($line,'group-title="','"')
									if $append = "none" Then
									   $append = $Group[0]
									EndIf
									$ChannelName = StringReplace($line,'group-title="' & $Group[0] & '"','group-title="' & $append & '"')
									FileWrite($Output,$ChannelName & @CRLF)
									FileWrite($Output,FileReadLine($file, $i + 1) & @CRLF)
									GUICtrlSetData($Progress,$Channel & " added to list")
								 EndIf
							  Else
								 GUICtrlSetData($Progress,$Channel & " slower than requested")
							  EndIf
						   EndIf
						EndIf
					 EndIf
				  EndIf
				  FileDelete(@ScriptDir & "/Temp/" & $Channel)
			   FileDelete(@ScriptDir & "/Temp/" & $Channel & ".ts")
			   EndIf

			Next
			FileClose(@ScriptDir & "/Temp/" & $Listname)
			GUICtrlSetData($Progress,"Finished")
        EndSwitch
    WEnd

    ; Delete the previous GUI and all controls.
    GUIDelete($hGUI)
EndFunc   ;==>Example