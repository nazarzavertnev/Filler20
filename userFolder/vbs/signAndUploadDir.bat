call env.bat

rem ��������� � ��������� ��� �����-������� �� �������� in.
rem 
rem ��������� ������-������ ����������� � ��������� �������: 
rem 
rem 1. ������� ������������ � ������� �� ����������� TLS ���������� � ������������ ������������ �� �����������.
rem 	����� ��� ������� ������������ ���������� ����� EINV_PORTAL_URL.
rem 	����� ����� � ����������� ������� ��� ����������� ������������ �� ����������� MY. 
rem 
rem 2. � ������ �������� �����������, ������������ ����� ����� � ����������� ������� ��� ������� ����-������.
rem
rem 3. ����� ��� ������� ��������������� �����-������� ����������� ��������� ��������: 
rem
rem 	3.1 �������������� ����-������� ����������� �� ������������ xsd-�����. 
rem    	����� XSD-����� �������������� ������������� � ����������� �� ���� ����-�������: 
rem 	 	* ORIGINAL � ADD_NO_REFERENCE - ����������� �������� "MNSATI_add_no_reference.xsd";
rem 	 	* FIXED - ����������� �������� "MNSATI_fixed.xsd";
rem 	 	* ADDITIONAL - ����������� �������� "MNSATI_additional.xsd".
rem 	��� ����������������� XSD-����� ������ ���������� � �������� xsd.
rem 
rem 	3.2 � ������ �������� �������� �� ������������ XSD-�����, ����������� ������� �����-�������, 
rem 	��������� �� ���� 2. ������ � ������������. ����������� ����-������� ����������� � �������� ������� out
rem     � ������: "invoice-�����_�����_�������.sgn.xml".
rem 
rem 	3.3 ����� ���� ��� ����-������� ������� ��������, �� ���������� �� ���-������ �������.
rem 
rem 	3.4 �� ���������� ��������� �����-������� ������ ��������� ����� � ���� ����������� ���������, � ������� ������ 
rem 	��������� ���������: ������ ����������� ���� ������� ��� ���. ���� �������� �� ������, ����������� �������, 
rem 	�� ������� �������� ��� ��������. ������� ��������� �������� ������� ��� ���������� � �������� ����������� �������. 
rem 	� ������ ���� ������� �����, ��������� ���������� � �������� ������� out,
rem 	� ������: "invoice-�����_�����_�������.ticket.xml", � ������ ������ � ��������� 
rem     ��� ����������� � ������ "invoice-�����_�����_�������.ticket.error.xml"
rem 
rem     3.5 ���� ������ ���� ��������� ������ -d � ������� �������� ����� �������, �� �������� ���� ���������.

%VBRUN% src\signAndUploadDir.vbs %1 %EINV_PORTAL_URL% %IN_FOLDER% %OUT_FOLDER%
