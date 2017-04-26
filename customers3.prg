*- CUSTOMERS3.FMT
*  Simple customers list with no FMT file
*

CLOSE ALL
CLEAR ALL
CLEAR

SET PROCEDURE TO vdp


* Configurando el reporte
LOCAL oDP
oDP=CREATEOBJECT("VFPDOSPrint")
oDP.PaperLenght = 60
oDP.HeaderString="CUSTOMER REPORT $CRLF$ DUE $DATE$"
oDP.DetailString="[CUSTID] [CUSTNAME              ] [CUSTSTAT]"
oDP.FooterString="$DATETIME$                        $PAGENO$"


* Generando reporte (version legacy)
SELECT 0
USE Customers
SCAN
	oDP.printSection("DETAIL")
ENDSCAN
USE IN customers


* Generando reporte (recomendada)
* SELECT 0
* USE customers
* oDP.Run()
* USE IN customers


oDP.PrintToFile("customers3.txt") 


RETURN


