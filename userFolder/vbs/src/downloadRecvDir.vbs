 ' downloadRecvDir.vbs - Поиск и загрузка счетов-фактур НДС
 
  dim oFSO
  dim EVatService 
  dim res
  dim FolderName
  dim f
  dim content
  dim fromDate
  dim toDate
  dim ForReading
  dim ForWriting 
  dim prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type, prxy_msg
  dim read_timeout
  dim unp, pubKeyId, pwd, connectStr, loginFlags
  dim service_cert_cn
  dim progName, progVersion, compVersion
  ForReading = 1
  ForWriting = 2
  service_cert_cn="Автоматизированный сервис портала АИС УСФ"
  progName = "receive2Dir"
  
  Set wshShell = CreateObject( "WScript.Shell" )
  progVersion = GetEnvVar("SIMPLE_APP_VERSION", "1.0.0")
  WScript.Echo "ЭСЧФ simpleapp." & progName &". Версия " & progVersion

  set objArgs = WScript.Arguments
  if objArgs.count < 2 then
	 WScript.Echo "Поиск и загрузка счетов-фактур НДС"
     WScript.Echo "Использование:"
     WScript.Echo "cscript downloadRecvDir.vbs <url АС портала> <папка для сохранения документов>"
     WScript.Quit
  end if

  url = objArgs(0)
  FolderName = objArgs(1)
    
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
  
  'Создание COM object EInvVatService.Connector
  set EVatService = CreateObject("EInvVatService.Connector")
  if read_timeout <> "" then
     res = EVatService.SetServiceProperty( "connection.readTimeout", read_timeout, 0 )
     if res <> 0 then
       WScript.Echo "Ошибка установки таймаута сетевого чтения: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
       WScript.Quit
     end if    
  end if
  
  compVersion = EVatService.Version
  WScript.Echo "Версия компонента EInvVatService " & compVersion  
  
  'Создание COM object для чтения файлов
  Set oFSO = CreateObject("Scripting.FileSystemObject")
  
  'Чтение файла с датой и временем последнего обращения к сервису получения документов
  filename = oFSO.BuildPath(FolderName, "last.update.time")    
  if oFSO.FileExists(filename) then
     Set f = oFSO.OpenTextFile(filename, ForReading, True)  
     If Not f.AtEndOfStream Then 
        content = f.ReadAll()  
     else
       content = ""
     end if
     f.close   
  else
     content = ""
  end if
  if Len(content) > 0 then
     fromDate = content
  else
     ' Если нет сохраненной даты, запрашиваем за год
     fromDate = FormatDate(DateAdd("d", -365, Now))
  end if  
  
  res = EVatService.Login(connectStr, loginFlags)
  if res = 0 then
     WScript.Echo "Авторизация успешна"
  else
     WScript.Echo "Ошибка авторизации: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
     WScript.Quit
  end if

  if prxy_url <> "" and prxy_url <> "%PROXY_URL%" then
     if EVatService.SetProxy(prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type) <> 0 then
        WScript.Echo "Ошибка установки прокси: " & EVatService.LastError
        WScript.Quit
     end if
     prxy_msg = " через прокси " & prxy_url & ":" & prxy_port
  end if

  WScript.Echo "Подключение к " & url & prxy_msg
  res = EVatService.Connect(url)
  if res = 0 then
     WScript.Echo "Подключение успешно"
  else
     WScript.Echo "Ошибка подключения: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
     WScript.Quit
  end if 
  
  res = ListDocuments(fromDate)
  
  'Сохранение даты
  if res = 0 then  
	  Set f = oFSO.OpenTextFile(filename, ForWriting, True)	  
	  f.Write(toDate)  
	  f.close  
  end if	 
      
  if EVatService.Disconnect <> 0 then
     WScript.Echo "Ошибка при завершении подключения к службе регистрации"
  end if
  
  if EVatService.Logout <> 0 then
     WScript.Echo "Ошибка при завершении авторизованной сессии"
  end if  

  'конец программы
  
  
'Процедура запроса списка документов
 function ListDocuments(fromDate)
	dim i	
    dim InvVatNumber
    dim fn, fn2
    dim InvList	
    dim wereErrors
        
    wereErrors = 0
	
    set InvList = EVatService.GetList(fromDate)
	if InvList is Nothing then
	   WScript.Echo "Ошибка получения списка ЭСЧФ: " + EVatService.LastError
	   ListDocuments = 1
	   exit function
	end if
    
    res = InvList.Verify
    if res <> 0 then
       WScript.Echo "Ошибка проверки подписи под списком ЭСЧФ: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
	   ListDocuments = 1
	   exit function
    end if    
	
	toDate = InvList.ToDate
	
	if InvList.Count = 0 then
       if fromDate <> "" then
	      WScript.Echo "Нет поступивших документов на сервере начиная с даты " & FormatDatePrintStr(fromDate)
       else
	      WScript.Echo "Нет поступивших документов на сервере"
       end if
	   ListDocuments = 0
	   exit function
	end if
	
    WScript.Echo "На сервере доступно " & InvList.Count & " документов для скачивания"
    
	for i = 0 to InvList.Count - 1
  
		InvVatNumber = InvList.GetItemAttribute(i, "document/number")
		
		fn = oFSO.BuildPath(FolderName, "invoice-" & InvVatNumber & ".sgn.xml")
		
		'Проверить наличие уже скачанного счета-фактуры
		if oFSO.FileExists(fn) then
				WScript.Echo CStr(i + 1) & ". Файл счета-фактуры  № " & InvVatNumber & " уже существует"
		else
		    WScript.Echo CStr(i + 1) & ". Скачивание документа № " & InvVatNumber
			set InvVatXml = EVatService.GetEDoc(InvVatNumber)
                         
		    if InvVatXml is Nothing then
				WScript.Echo "Ошибка получения документа № " & InvVatNumber & ": " + EVatService.LastError
 			   	wereErrors = wereErrors + 1
   
		    else			
				'Проверить ЭЦП
				res = VerifyDocumentSign(InvVatXml)
				if res <> 0 then
                    if res <> 1 then                
                        WScript.Echo "Ошибка проверки ЭЦП полученного документа: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
                    else
                        WScript.Echo "Ошибка проверки ЭЦП полученного документа"
					end if
                    fn = oFSO.BuildPath(FolderName, "invoice-" & InvVatNumber & ".sgn.error.xml")
					res = InvVatXml.SaveToFile( fn )                    
				else
					res = InvVatXml.SaveToFile( fn )			
				end if				
				if res <> 0 then
				   WScript.Echo "Ошибка сохранения полученного документа: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
				   ListDocuments = res
				   exit function
				end if	

                fn2 = oFSO.BuildPath(FolderName, "invoice-" & InvVatNumber & ".xml")
                res = InvVatXml.Document.SaveToFile( fn2 )
                if res <> 0 then
                   WScript.Echo "Ошибка сохранения ЭСЧФ: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
                   exit function
                end if                 
				
				WScript.Echo "Файл " & fn & " сохранен"
		    end if
		end if
	next
    
    if wereErrors = 0 then	
        ListDocuments = 0
    else
        WScript.Echo "При скачивании ЭСЧФ возникли ошибки, количество нескачанных документов: " & wereErrors
        WScript.Echo "Перезапустите программу для скачивания оставшихся документов."
        ListDocuments = 2 
    end if	 
 end function
 
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
            WScript.Echo "Проверка подписи, выполненной '" & str & "'"
		
            res = InvVatXml.VerifySign(i, 0)
            if res <> 0 then
               WScript.Echo "Ошибка проверки подписи: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
            else
               WScript.Echo "ЭЦП проверена. Дата подписания: " & InvVatXml.GetSignProperty(i, "SIGNDATE", 0)
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
	   WScript.Echo "Ошибка: документ №" & InvVatNumber &  " не содержит ЭЦП"
	   VerifyAllSigns = 1
	   exit function
	end if
	
	for i = 0 to signCount - 1
		if IsASSign(InvVatXml, i) <> 1 then
			oid = "2.5.4.3" '(commonName)
			str = InvVatXml.GetSignProperty(i, oid, 0)
			WScript.Echo "Проверка подписи, выполненной '" & str & "'"
		
			res = InvVatXml.VerifySign(i, 0)
			if res <> 0 then
		   		WScript.Echo "Ошибка проверки подписи: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
		   		VerifyAllSigns = 2
		   		exit function
			else
			   WScript.Echo "ЭЦП проверена. Дата подписания: " & InvVatXml.GetSignProperty(i, "SIGNDATE", 0)
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
 
Function FormatDate(myDate)
    d = WhatEver(Day(myDate))
    m = WhatEver(Month(myDate))    
    y = Year(myDate)
	h = WhatEver(Hour(myDate))
	min = WhatEver(Minute(myDate))
	s = WhatEver(Second(myDate))
    FormatDate= y & "-" & m & "-" & d & "T" & h & ":" & min & ":" & s
End Function

Function WhatEver(num)
    If(Len(num)=1) Then
        WhatEver="0" & num
    Else
        WhatEver = num
    End If
End Function

Function FormatDatePrintStr(dateTStr)
  ' example dateTStr=2016-12-12T15:10:22, result=12.12.2016 15:10:22
  dim s
  if Mid(dateTStr, 11, 1) = "T" then
     s = Mid(dateTStr, 9, 2) & "." & Mid(dateTStr, 6, 2) & "." & Mid(dateTStr, 1, 4) & " " & Mid(dateTStr, 12, 8)
     if InStr(s, "-") > 0 then
       s = dateTStr
     end if
  else
     ' Unknown format
     s = dateTStr
  end if
  
  FormatDatePrintStr = s
End Function

Function GetEnvVar(envVarName, defValue)
  dim v
  v = wshShell.ExpandEnvironmentStrings( "%" & envVarName & "%" )
  if (v = "") or (v = ("%" & envVarName & "%")) then
     v = defValue
  end if  
  GetEnvVar = v
 End Function
  