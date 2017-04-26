*- CUSTOMERS2.FMT
*  Customer list grouped by status. Note that the dataset is constructed
*  inside the format file.
*

CLOSE ALL
CLEAR ALL
CLEAR

SET PROCEDURE TO vdp

  
LOCAL oDP
oDP=CREATEOBJECT("VFPDOSPrint")
oDP.PrintFormat="CUSTOMERS2.FMT"
oDP.Run()

oDP.PrintToFile("DP.OUT")
MODIFY FILE DP.OUT

* oDP.Print( GetPrinter() )   && Uncomment this to send the output to a selected printer

RELEASE oDP
CLOSE ALL
