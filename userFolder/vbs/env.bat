@echo off
rem ���� ������������
chcp 1251 >nul
set SIMPLE_APP_VERSION=1.3.2

rem ��������� ����������� ============================================
rem URL ������������������� ������� �������
SET EINV_PORTAL_URL=https://ws.vat.gov.by:443/InvoicesWS/services/InvoicesPort

rem ������� � �������� �������� ======================================
SET IN_FOLDER=.\in
SET OUT_FOLDER=.\out
SET RECV_FOLDER=.\recv

rem ��������� ����������� ============================================
rem ����� ����������� �� ���
rem ������� rem � ������� ��������� ���
rem set UNP=
rem ���� ����� ������� ����������� �� �������������� ��������� ����� (���� ������������� ����� �������� � �����������)
rem ������� rem � ������� ��������� ������������� ��������� ����� (��� ��������)
rem set PUBLIC_KEY_ID=
rem ����� ����� ������� ������ � �����
rem set PASSWORD=


rem ��������� ����������� ����� ������ ===================================
rem ������� rem � ������� �������� ����������� � ������, ���� ��������� ����� ������

rem URL ��� ����������� ������
rem set PROXY_URL=

rem ���� ��� ����������� ������
rem set PROXY_PORT=

rem ������������ ��� ����������� ������ � ������������
rem set PROXY_USER=

rem ������ ��� ����������� ������ � ������������
rem set PROXY_PASS=

rem ��� ������: 1 - HTTP ������ (�� ���������)
rem set PROXY_TYPE=1

rem ������� �������� ������ (������)
rem set READ_TIMEOUT=300 


if exist C:\Windows\SysWOW64\cscript.exe (
   SET VBRUN=C:\Windows\SysWOW64\cscript.exe /nologo
) else (
   SET VBRUN=cscript.exe /nologo
)
