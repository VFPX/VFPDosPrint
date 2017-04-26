*- HTML1.FMT
*  HTML generation demo
*

CLOSE ALL
CLEAR ALL
CLEAR

SET PROCEDURE TO vdp

LOCAL oDP
oDP=CREATEOBJECT("VFPDOSPrint")
oDP.PrintFormat="HTML1.FMT"
oDP.Run()

oDP.printToFile("dp.html")

LOCAL oWSH
oWSH = CREATE("WScript.Shell")
oWSH.Run(FULLPATH("dp.html"),,0)

