*- CUSTOMERS1.FMT
*  Basic customer report (report básico de clientes)
*

CLOSE ALL
CLEAR ALL
CLEAR

SET PROCEDURE TO VDP


SELECT * ;
  FROM Customers ;
 ORDER BY CustID ;
  INTO CURSOR qCustomers
  
SELECT qCustomers
GO TOP
  
LOCAL oDP
oDP=CREATEOBJECT("VFPDosPrint")
oDP.PrintFormat="CUSTOMERS1.FMT"
oDP.Run()

oDP.PrintToFile("DP.OUT")
MODIFY FILE DP.OUT

* oDP.Print( GetPrinter() )   && Uncomment this to send the output to a selected printer

RELEASE oDP
CLOSE ALL
