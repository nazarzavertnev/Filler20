@echo off
rem Файл конфигурации
chcp 1251 >nul
set SIMPLE_APP_VERSION=1.3.2

rem Параметры подключения ============================================
rem URL автоматизированного сервиса портала
SET EINV_PORTAL_URL=https://ws.vat.gov.by:443/InvoicesWS/services/InvoicesPort

rem Входные и выходные каталоги ======================================
SET IN_FOLDER=.\in
SET OUT_FOLDER=.\out
SET RECV_FOLDER=.\recv

rem Параметры авторизации ============================================
rem Выбор сертификата по УНП
rem Уберите rem и впишите требуемый УНП
rem set UNP=
rem Либо можно выбрать сертификата по идентификатору открытого ключа (поле Идентификатор ключа субъекта в сертификате)
rem Уберите rem и впишите требуемый идентификатор открытого ключа (без пробелов)
rem set PUBLIC_KEY_ID=
rem Также можно указать пароль к ключу
rem set PASSWORD=


rem Параметры подключения через прокси ===================================
rem Уберите rem и впишите парметры подключения к прокси, если работаете через прокси

rem URL для подключения прокси
rem set PROXY_URL=

rem Порт для подключения прокси
rem set PROXY_PORT=

rem Пользователь для подключения прокси с авторизацией
rem set PROXY_USER=

rem Пароль для подключения прокси с авторизацией
rem set PROXY_PASS=

rem Тип прокси: 1 - HTTP прокси (по умолчанию)
rem set PROXY_TYPE=1

rem Таймаут сетевого чтения (секунд)
rem set READ_TIMEOUT=300 


if exist C:\Windows\SysWOW64\cscript.exe (
   SET VBRUN=C:\Windows\SysWOW64\cscript.exe /nologo
) else (
   SET VBRUN=cscript.exe /nologo
)
