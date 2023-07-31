 ' verifySignAndUploadDir.vbs - ���������� ������ �������� � �������� ������-������ ��� �� �����

 ' �������������:
 ' "cscript verifySignAndUploadDir.vbs <url �� �������> <����� � �����������>"

  Dim EVatService 
  Dim InvVatXml  
  Dim res 
  dim url
  dim inFolder
  dim pos
  dim myRegExp
  dim objFolder
  dim colFiles    
  dim prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type, prxy_msg
  dim unp, pubKeyId, pwd, connectStr, loginFlags
  dim service_cert_cn
  dim read_timeout
  dim progName, progVersion, compVersion
  service_cert_cn="������������������ ������ ������� ��� ���"
  progName = "signAndUploadRecvDir"
  Set wshShell = CreateObject( "WScript.Shell" )
  progVersion = GetEnvVar("SIMPLE_APP_VERSION", "1.0.0")
  WScript.Echo "���� simpleapp." & progName &". ������ " & progVersion  
 
  Set objArgs = WScript.Arguments
  if objArgs.count < 2 then
	 WScript.Echo "���������� ������ �������� � �������� ������-������ ���"
     WScript.Echo "�������������:"
     WScript.Echo "cscript verifySignAndUploadDir.vbs <url �� �������> <����� � �����������>"
	 WScript.Quit
  end if
  
  pos = 0
  
  url = objArgs(pos)
  pos = pos + 1
  
  inFolder = objArgs(pos)  
  
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
  
  Set myRegExp = New RegExp
  myRegExp.IgnoreCase = True
  'myRegExp.Global = True
  myRegExp.Pattern = "\.sgn\.xml$"	
	
  Set objFolder = oFSO.GetFolder(inFolder)

  Set colFiles = objFolder.Files	
  	  
  For Each oFile in colFiles
  
	  If myRegExp.Test(oFile.Name) Then
	     
		 VerifySignSendFile oFile
	
	  end if 	  	  
  Next  
    
  if EVatService.Disconnect <> 0 then
     WScript.Echo "������ ��� ���������� ����������� � ������ �����������"
  end if
  
  if EVatService.Logout <> 0 then
     WScript.Echo "������ ��� ���������� �������������� ������"
  end if  

  '����� ���������

  
 ' ��������� ���������� � �������� ���������   
 sub VerifySignSendFile(DocFile)
    dim InvVatTicket
	dim FileName
	dim InvVatNumber
	dim fn, fnt, fnt2
	dim i, signCount
	dim str, oid

	FileName = DocFile.Path

    set InvVatXml = EVatService.CreateEDoc
	res = InvVatXml.LoadFromFile(FileName) 
    if res <> 0 then
       WScript.Echo "������ ������ �����: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
	   exit sub
    end if
	
	InvVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number")
	InvVatType = InvVatXml.Document.GetXmlNodeValue("issuance/general/documentType")
	
	fn = oFSO.BuildPath(inFolder, "invoice-" & InvVatNumber)
	if oFSO.FileExists(fn & ".sgn2.xml") then
		'���� ��� ��������, ��������� ���� �� ��������� �� ��������
		
		fnt = oFSO.BuildPath(inFolder, "invoice-" & InvVatNumber & ".ticket.xml")
		if oFSO.FileExists(fnt) then
		  '��������� ��� ����
		  exit sub
		end if
		
		fnt = oFSO.BuildPath(inFolder, "invoice-" & InvVatNumber & ".ticket.error.xml")
		if oFSO.FileExists(fnt) then
		  '��������� � ������� ��� ����
          
          fnt2 = fnt & ".bak"
          
          if oFSO.FileExists(fnt2) then          
             oFSO.DeleteFile fnt2
          end if
          
          oFSO.MoveFile fnt, fnt2
		end if
        
        fnt2 = fn &  ".sgn2.xml" & ".bak"
        if oFSO.FileExists(fnt2) then          
           oFSO.DeleteFile fnt2
        end if   

        oFSO.MoveFile fn & ".sgn2.xml", fnt2        
	end if
    
    '��������� ���
    WScript.Echo "�������� � " & InvVatNumber & ". �������� ���"	
    res = VerifyDocumentSign(InvVatXml)
    if res <> 0 then
        if res <> 1 then                
            WScript.Echo "������ �������� ��� ���������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
        else
            WScript.Echo "������ �������� ��� ���������"
        end if        
        exit sub
    end if    
        
    res = InvVatXml.Sign(0)
    if res <> 0 then
       WScript.Echo "������ ��������� �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
       exit sub
    end if

    WScript.Echo "�������� � " & InvVatNumber & " ��������"	

    res = InvVatXml.SaveToFile( fn & ".sgn2.xml")
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
		WScript.Echo "����� ������������������� �������: �������� �� ������ �� ������� " + InvVatTicket.Message

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
		
    end if
end sub

function VerifyDocumentSign(InvVatXml)
   if IsSignedByASServer(InvVatXml) = 1 then
      VerifyDocumentSign = VerifyASServerSign(InvVatXml)
      exit function
   end if
   
   VerifyDocumentSign = VerifyAllSigns(InvVatXml)
end function

function IsSignedByASServer(InvVatXml)
	dim i, signCount
	dim InvVatNumber

	InvVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number")
	
	signCount = InvVatXml.GetSignCount
	
	if signCount = 0 then
	   IsSignedByASServer = 0
	   exit function
	end if
	
	for i = 0 to signCount - 1
        	if IsASSign(InvVatXml, i) = 1 then
	   	   IsSignedByASServer = 1
		   exit function
        	end if
	next
	
	IsSignedByASServer = 0
end function              

function VerifyASServerSign(InvVatXml)
	dim i, signCount
	dim InvVatNumber

	InvVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number")
	
	signCount = InvVatXml.GetSignCount
	
	if signCount = 0 then
	   VerifyASServerSign = 1
	   exit function
	end if
	
	for i = 0 to signCount - 1
        if IsASSign(InvVatXml, i) = 1 then
            oid = "2.5.4.3" '(commonName)
            str = InvVatXml.GetSignProperty(i, oid, 0)
            WScript.Echo "�������� �������, ����������� '" & str & "'"
		
            res = InvVatXml.VerifySign(i, 0)
            if res <> 0 then
               WScript.Echo "������ �������� �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
            else
               WScript.Echo "��� ���������. ���� ����������: " & InvVatXml.GetSignProperty(i, "SIGNDATE", 0)
               VerifyASServerSign = 0
               exit function
            end if
        end if
	next
	
	VerifyASServerSign = 1
end function 
 
function VerifyAllSigns(InvVatXml)
	dim i, signCount
	dim InvVatNumber

    InvVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number")
	
	signCount = InvVatXml.GetSignCount
	
	if signCount = 0 then
	   WScript.Echo "������: �������� �" & InvVatNumber &  " �� �������� ���"
	   VerifyAllSigns = 1
	   exit function
	end if
	
	for i = 0 to signCount - 1
		if IsASSign(InvVatXml, i) <> 1 then
			oid = "2.5.4.3" '(commonName)
			str = InvVatXml.GetSignProperty(i, oid, 0)
			WScript.Echo "�������� �������, ����������� '" & str & "'"
		
			res = InvVatXml.VerifySign(i, 0)
			if res <> 0 then
		   		WScript.Echo "������ �������� �������: " & EVatService.LastError & " (��� 0x" & Hex(res) & ")"
		   		VerifyAllSigns = 2
		   		exit function
			else
			   WScript.Echo "��� ���������. ���� ����������: " & InvVatXml.GetSignProperty(i, "SIGNDATE", 0)
			end if				
		end if				
	next
	
	VerifyAllSigns = 0	
end function

function IsASSign(InvVatXml, n)
    dim oid
	oid = "2.5.4.3" '(commonName)
	str = InvVatXml.GetSignProperty(n, oid, 0)
    if str <> service_cert_cn then
       IsASSign = 0
       exit function
    end if
    
    IsASSign = 1
end function

Function GetEnvVar(envVarName, defValue)
  dim v
  v = wshShell.ExpandEnvironmentStrings( "%" & envVarName & "%" )
  if (v = "") or (v = ("%" & envVarName & "%")) then
     v = defValue
  end if  
  GetEnvVar = v
 End Function
 