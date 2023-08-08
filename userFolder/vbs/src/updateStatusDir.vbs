 ' updateStatusDir.vbs - ���������� �������� ��������� ���� ��� � ��������

 ' �������������:
 ' "cscript updateStatusDir.vbs <url �� �������> <����� ��� �������� ����������> <��� ���������>"
  
  dim oFSO
  dim EVatService 
  dim EDocStatus
  dim res
  dim FolderName
  dim dt
  dim docType, sgnPattern
  dim prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type, prxy_msg
  dim unp, pubKeyId, pwd, connectStr, loginFlags
  dim read_timeout
  dim progName, progVersion, compVersion
  progName = "updateStatus"
  Set wshShell = CreateObject( "WScript.Shell" )
  progVersion = GetEnvVar("SIMPLE_APP_VERSION", "1.0.0")
  
  set objArgs = WScript.Arguments
  if objArgs.count < 3 then
     WScript.Echo "���� simpleapp." & progName &". ������ " & progVersion
	 WScript.Echo "���������� �������� ��������� ���� ��� � ��������"
     WScript.Echo "�������������:"
     WScript.Echo "cscript updateStatusDir.vbs <url �� �������> <����� ��� �������� ����������> <��� ���������>"
     WScript.Quit
  end if

  progName = objArgs(0)
  url = objArgs(1)
  FolderName = objArgs(2)
  docType = objArgs(3)
  
  WScript.Echo "���� simpleapp." & progName &". ������ " & progVersion  
  
  prxy_url = GetEnvVar("PROXY_URL", "")
  prxy_port = GetEnvVar("PROXY_PORT", 0)
  prxy_user = GetEnvVar("PROXY_USER", "")
  prxy_pass = GetEnvVar("PROXY_PASS", "")
  prxy_type = GetEnvVar("PROXY_TYPE", 1)

  read_timeout = GetEnvVar("READ_TIMEOUT", "")
  
  unp = GetEnvVar("UNP", "")
  pubKeyId = GetEnvVar("PUBLIC_KEY_ID", "")
  pwd = GetEnvVar("PASSWORD", "")
  
  connectStr = ""
  loginFlags = 0  
  if unp <> "" then
    if len(connectStr) > 0 then
       connectStr = ";UNP=" & unp
    else
      connectStr = "UNP=" & unp
    end if 
    loginFlags = &h40
  end if
  if pubKeyId <> "" then
    if len(connectStr) > 0 then
       connectStr = ";PUB_KEY_ID=" & pubKeyId
    else
      connectStr = "PUB_KEY_ID=" & pubKeyId
    end if 
    loginFlags = &h40
  end if
  if pwd <> "" then
    if len(connectStr) > 0 then
       connectStr = connectStr & ";PASSWORD_KEY=" & pwd
    else
       connectStr = connectStr & "PASSWORD_KEY=" & pwd
    end if 
  end if

  
  sgnPattern = "\." & docType & "\.xml$"
  
  '�������� COM object EInvVatService.Connector
  set EVatService = CreateObject("EInvVatService.Connector")
  if read_timeout <> "" then
     res = EVatService.SetServiceProperty( "connection.readTimeout", read_timeout, 0 )
     if res <> 0 then
       WScript.Echo "������ ��������� �������� �������� ������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
       WScript.Quit
     end if    
  end if
  
  compVersion = EVatService.Version
  WScript.Echo "������ ���������� EInvVatService " & compVersion  
  
  '�������� COM object ��� ������ ������
  Set oFSO = CreateObject("Scripting.FileSystemObject")
  
  res = EVatService.Login(connectStr, loginFlags)
  if res = 0 then
     WScript.Echo "����������� �������"
  else
     WScript.Echo "������ �����������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
     WScript.Quit
  end if

  if prxy_url <> "" and prxy_url <> "%PROXY_URL%" then
     if EVatService.SetProxy(prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type) <> 0 then
        WScript.Echo "������ ��������� ������: " & EVatService.LastError
        WScript.Quit
     end if
     prxy_msg = " ����� ������ " & prxy_url & ":" & prxy_port
  end if

  WScript.Echo "����������� � " & url & prxy_msg
  res = EVatService.Connect(url)
  if res = 0 then
     WScript.Echo "����������� �������"
  else
     WScript.Echo "������ �����������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
     WScript.Quit
  end if 
  
  RefreshFolder FolderName, sgnPattern
    
  if EVatService.Disconnect <> 0 then
     WScript.Echo "������ ��� ���������� ����������� � ������ �����������"
  end if
  
  if EVatService.Logout <> 0 then
     WScript.Echo "������ ��� ���������� �������������� ������"
  end if  
  
  '����� ���������
  
  
  sub RefreshFolder(FolderName, sgnPattern)
    dim objFolder
	dim colFiles
	dim invoiceFileName
	dim InvVatXml
	dim lastStatus
	dim invVatNumber
	dim refresh 
	dim myRegExp
	dim cnt
	
	cnt = 0
	
	Set myRegExp = New RegExp
	myRegExp.IgnoreCase = True
	'myRegExp.Global = True
	myRegExp.Pattern = sgnPattern
	
	Set objFolder = oFSO.GetFolder(FolderName)
	
	Set colFiles = objFolder.Files

	For Each objFile in colFiles
		If myRegExp.Test(objFile.Name) Then
			invoiceFileName = objFile.Name
					
			cnt = cnt + 1
			set InvVatXml = EVatService.CreateEDoc
			res = InvVatXml.LoadFromFile(objFile.Path)
			if res <> 0 then
			   WScript.Echo "������ ������ �����: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
			else
			
				invVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number") 
				
				lastStatus = FindLastStatusFor(invVatNumber, colFiles)
				
				refresh = 0
				
				if lastStatus = "" then
					refresh = 1
				'���� ������, �������� ������������ ��������
				elseif lastStatus = "COMPLETED" then
					refresh = 1
				'���� ������, �������� ������ ���������
				elseif lastStatus = "COMPLETED_SIGNED" then
					refresh = 1
				'�� ������������
				' ������ ������ ������������� ��� �������������� � ������������ ���� � ��������� �������:
				' -   ����� �� �������� (������������) ����-�������, ������� �������� ������ ���������,
				' ������������ �������������� ���� � ������������� ������;
				' -   ����� �� �������� (������������) ����-�������, ������� �������� ������ ���������,
				' ������������ ������������ ����.
				elseif lastStatus = "ON_AGREEMENT" then
					refresh = 1
				'�����������
				elseif lastStatus = "CANCELLED" then
						refresh = 0
				'�� ������
				elseif lastStatus = "NOT_FOUND" then
						refresh = 0
				'�� ������������ �� �������������
				elseif lastStatus = "ON_AGREEMENT_CANCEL" then
					refresh = 1
				'���� ������, �� ��������
				elseif lastStatus = "IN_PROGRESS" then
					refresh = 1
				'���� ������, �� ��������, �������� ������
				elseif lastStatus = "IN_PROGRESS_ERROR" then
					refresh = 1
				elseif lastStatus = "DENIED" then
					refresh = 0
                '������ ��� ����������� ���� �� ������
				elseif lastStatus = "ERROR" then
					refresh = 0
				else
					'����������� ������
					refresh = 1
				end if
				
				if refresh = 1 then
				
				   RefreshInvStatus(invVatNumber)
				   
				end if			
			
			end if	
		End If
	Next	
	
	if cnt = 0 then
	   WScript.Echo "��������� ��� ��������� �� ����������"
	end if
  end sub
  
  
  function FindLastStatusFor(invVatNumber, colFiles)
	dim myRegExp
	dim status
	dim onDate
	dim dtStr
	dim StatusXml
	dim fn
	
	Set myRegExp = New RegExp
	myRegExp.IgnoreCase = True
	'myRegExp.Global = True	
	myRegExp.Pattern = "invoice-" & "[a-zA-Z_0-9\-]{5,}-status-\S+\.xml$"
	
	onDate = " "
	status = ""
	For Each objFile in colFiles
	    fn = objFile.Name
		If myRegExp.Test(fn) Then
		    if Instr(fn, "invoice-" & invVatNumber) = 1 then
		
				set StatusXml = EVatService.CreateEDoc
				if StatusXml.LoadFromFile(objFile.Path) <> 0 then
				   WScript.Echo "������ ������ ����� " & fn & ": " & EVatService.LastError
				else
				   dtStr = StatusXml.Document.GetXmlNodeValue("status_info/document_state/since") 
				   if dtStr > onDate then
					  onDate = dtStr
					  status = StatusXml.Document.GetXmlNodeValue("status_info/document_state/status") 
				   end if   
				end if           	
			end if				
		End If
	Next	
	
	FindLastStatusFor = status
	
  end function
  
  
  sub RefreshInvStatus(InvNumber)
      WScript.Echo "��������� ������� �����-������� � ������� " & InvNumber & ": "
  
	  set EDocStatusInfo = EVatService.GetStatus(InvNumber)  
	  if EDocStatusInfo is Nothing then
		  WScript.Echo "������ ��� ��������� ������� �����-������� � ������� " & InvNumber & ": " + EVatService.LastError
		  
		  exit sub
	  else
		  dt = FormatDate(Date)

		  res = EDocStatusInfo.Verify
		  if res <> 0 then
			 WScript.Echo "������ �������� ����������� ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
			 
             fn = oFSO.BuildPath(FolderName, "invoice-" & InvNumber & "-status-" & dt & "-" & EDocStatusInfo.Status & ".error")
          else
		     WScript.Echo "������ ��������� ����: " + EDocStatusInfo.Status
             WScript.Echo "�������������� ����������: " + EDocStatusInfo.Message
             WScript.Echo "���� ��������� ������� ����: " + EDocStatusInfo.Since
			  
		     fn = oFSO.BuildPath(FolderName, "invoice-" & InvNumber & "-status-" & dt & "-" & EDocStatusInfo.Status)
		  end if		  
		  
		  res = EDocStatusInfo.SaveToFile( fn & ".xml" )
		  if res <> 0 then
			 WScript.Echo "������ ���������� ����������� ��������� �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
			 WScript.quit
		  end if
          
          res = EDocStatusInfo.Document.SaveToFile( fn & ".text.xml" )
		  if res <> 0 then
		     WScript.Echo "������ ���������� ������ �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		     WScript.quit
		  end if          
		
		  WScript.Echo "���� ���������� � ������� " & fn & ".xml" & " ��������"	  
	  end if
  end sub
    

 Function FormatDate(myDate)
    d = WhatEver(Day(myDate))
    m = WhatEver(Month(myDate))    
    y = Year(myDate)	
    FormatDate= y & "_" & m & "_" & d
End Function

Function WhatEver(num)
    If(Len(num)=1) Then
        WhatEver="0" & num
    Else
        WhatEver = num
    End If
End Function  

Function GetEnvVar(envVarName, defValue)
  dim v
  v = wshShell.ExpandEnvironmentStrings( "%" & envVarName & "%" )
  if (v = "") or (v = ("%" & envVarName & "%")) then
     v = defValue
  end if  
  GetEnvVar = v
 End Function
 