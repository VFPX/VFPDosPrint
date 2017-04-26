*- CASHTRANS
*  Cash transactions report. This an example of a medium-complex report using nested grouping
*  section's commands and properties and nested reports.
*
*
PROC CASHTRANS
 *
 close all 
 set procedure to vdp
 
 if file("cashtrans.out")
  erase cashtrans.out
 endif
  
 local oRep
 oRep=create("VFPDOSPrint")
 oRep.RunFormat("cashtrans.fmt")
 modi file cashtrans.out noedit
 
 close all
 *
ENDPROC


