 ' signAndUploadDir.vbs - ���������� � �������� ������-������ ��� �� �����

 ' �������������:
 ' "cscript signAndUploadDir.vbs [-d] <url �� �������> <������� �����> <�������� �����>"
 '    ����� -d ��������� ������� ���� �� �������� �����

  Dim EVatService 
  Dim InvVatXml  
  Dim res 
  Dim xsd
  dim shouldDeleteFile
  dim url
  dim inFolder
  dim outFolder
  dim pos
  dim prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type, prxy_msg
  dim unp, pubKeyId, pwd, connectStr, loginFlags
  dim read_timeout
  dim progName, progVersion, compVersion
  progName = "signAndUploadDir"
  Set wshShell = CreateObject( "WScript.Shell" )
  progVersion = GetEnvVar("SIMPLE_APP_VERSION", "1.0.0")
  WScript.Echo "���� simpleapp." & progName &". ������ " & progVersion
  
  shouldDeleteFile = 0
  
  Set objArgs = WScript.Arguments
  if objArgs.count < 3 then
	 WScript.Echo "���������� � �������� ������-������ ���"
     WScript.Echo "�������������:"
     WScript.Echo "cscript signAndUploadDir.vbs [-d] <url �� �������> <������� �����> <�������� �����>"
     WScript.Echo "����� -d ��������� ������� ���� �� �������� �����"
	 WScript.Quit
  end if
  
  pos = 0
  
  if objArgs(pos) = "-d" then
	shouldDeleteFile = 1
	pos = pos + 1
  end if
  
  url = objArgs(pos)
  pos = pos + 1
  
  inFolder = objArgs(pos)
  pos = pos + 1
  
  outFolder = objArgs(pos)  
  
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

    
  '�������� COM object ��� ������ ������
  Set oFSO = CreateObject("Scripting.FileSystemObject")
  
  '�������� COM object EInvVatService.Connector

  Set EVatService = CreateObject("EInvVatService.Connector")
  if read_timeout <> "" then
     res = EVatService.SetServiceProperty( "connection.readTimeout", read_timeout, 0 )
     if res <> 0 then
       WScript.Echo "������ ��������� �������� �������� ������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
       WScript.Quit
     end if    
  end if
  
  compVersion = EVatService.Version
  WScript.Echo "������ ���������� EInvVatService " & compVersion  
 
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
	  
  For Each oFile In oFSO.GetFolder(inFolder).Files
	  SignSendFile oFile	  
  Next  
    
  if EVatService.Disconnect <> 0 then
     WScript.Echo "������ ��� ���������� ����������� � ������ �����������"
  end if
  
  if EVatService.Logout <> 0 then
     WScript.Echo "������ ��� ���������� �������������� ������"
  end if  

  '����� ���������  

  
'��������� ���������� � �������� ���������   
 sub SignSendFile(DocFile)
    dim InvVatTicket
	dim FileName
	dim InvVatNumber
	dim fn
	
	FileName = DocFile.Path
	
    WScript.Echo
    WScript.Echo "��������� ����� " & FileName

    set InvVatXml = EVatService.CreateEDoc

	res = InvVatXml.Document.LoadFromFile(FileName)
    if res <> 0 then
       WScript.Echo "������ ������ �����: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	   exit sub
    end if
	
	InvVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number")
	InvVatType = InvVatXml.Document.GetXmlNodeValue("issuance/general/documentType")
	WScript.Echo "�������� " & InvVatNumber & ", ��� ��������� " & InvVatType
	
	select case InvVatType
	 case "ORIGINAL"
	   xsd = "MNSATI_original.xsd"
	 case  "FIXED"
	   xsd = "MNSATI_fixed.xsd"
	 case  "ADDITIONAL"
	   xsd = "MNSATI_additional.xsd"
	 case  "ADD_NO_REFERENCE"
	   xsd = "MNSATI_add_no_reference.xsd"
	 case else
	  WScript.Echo "���� " & FileName & " �������� �������� ��� ���������"	  
	  exit sub
	end select

	res = InvVatXml.Document.ValidateXML("xsd\" & xsd, 0)

	if res <> 0 then
	  WScript.Echo "������ �������� ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	  WScript.Echo "�������� �� ������������� ��������� ����� xsd"
	  exit sub
	end if

	' �������� ������������� �����, �����������
	res = InvVatXml.Sign(0)
	if res <> 0 then
	   WScript.Echo "������ ��������� �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	   exit sub
	end if
	
	WScript.Echo "�������� ��������"
	
	fn = oFSO.BuildPath(outFolder, "invoice-" & InvVatNumber)

	res = InvVatXml.SaveToFile( fn & ".sgn.xml")
	if res <> 0 then
	   WScript.Echo "������ ���������� ������������ ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	   exit sub
	end if	
	
	res = EVatService.SendEDoc(InvVatXml)
	if res <> 0 then
	   WScript.Echo "������ ��������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	   exit sub
	end if
	  
	WScript.Echo "�������� ���������"
	
    set InvVatTicket = EVatService.Ticket
    if InvVatTicket.Accepted <> 0 then
		WScript.Echo "����� ������������������� �������: �������� �� ������ �� ������� " & InvVatTicket.Message

		res = InvVatTicket.SaveToFile( fn & ".ticket.error.xml" )
		if res <> 0 then
		   WScript.Echo "������ ���������� ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		   exit sub
		end if
        
        res = InvVatTicket.Document.SaveToFile( fn & ".ticket.error.text.xml" )
		if res <> 0 then
		   WScript.Echo "������ ���������� ������ ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		   exit sub
		end if

    else
        WScript.Echo "�������� ������"
        WScript.Echo "����� ������������������� �������: " & InvVatTicket.Message
		
		res = InvVatTicket.SaveToFile( fn & ".ticket.xml" )
		if res <> 0 then
		   WScript.Echo "������ ���������� ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		   exit sub
		end if
        
        res = InvVatTicket.Document.SaveToFile( fn & ".ticket.text.xml" )
		if res <> 0 then
		   WScript.Echo "������ ���������� ������ ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		   exit sub
		end if          
		
		if shouldDeleteFile = 1 then		    
			oFSO.DeleteFile(FileName)
			WScript.Echo "������ ���� " & FileName
		end if
    end if
		
end sub

Function GetEnvVar(envVarName, defValue)
  dim v
  v = wshShell.ExpandEnvironmentStrings( "%" & envVarName & "%" )
  if (v = "") or (v = ("%" & envVarName & "%")) then
     v = defValue
  end if  
  GetEnvVar = v
 End Function
 