* 
*   VDP.PRG
*   VFP DOS PRINT LIBRARY
*
*   AUTHOR: VICTOR ESPINA
*   VERSION: 1.0c
*   DATE: JUL 21, 2014
* 
*
DEFINE CLASS vfpdosprint AS custom


	Height = 17
	Width = 101
	*-- Margen superior de la página (en líneas)
	topmargin = 0
	*-- Margen inferior de la página (en lineas)
	bottommargin = 0
	*-- Margen izquierdo de la página (en columnas)
	leftmargin = 0
	*-- Longitud de la página (en líneas)
	paperlenght = 66
	*-- Cadena de configuración inicial
	startconfstring = ""
	*-- Cadena de configuración para nueva página
	newpageconfstring = ""
	*-- Archivo temporal de salida
	coutfile = ""
	*-- Contador de líneas impresas por página
	HIDDEN npl
	npl = 0
	*-- Contador de páginas
	pageno = 1
	*-- Nro. de lineas reservadas para pie de página.
	footerlenght = 0
	*-- Cadena a utilizar como encabezado de página.
	headerstring = ""
	*-- Cadena a utilizar como pié de página
	footerstring = ""
	*-- Comando a ejecutar cuando se inicia una nueva página
	onnewpage = ""
	*-- Cadena que se imprime cuando se utiliza el método PrintSection con el parámetro DETAIL.
	detailstring = ""
	*-- Nro. de grupos definidos
	HIDDEN ngroupcount
	ngroupcount = 0
	*-- Indica si se realizaran saltos de página automáticamente.
	autoeject = .T.
	*-- Texto a imprimir antes de iniciar el informe.
	titlestring = ""
	*-- Esto a imprimir al finalizar el informe.
	summarystring = ""
	*-- Cadena a imprimir para lograr el efecto de Eject.
	ejectstring = ""
	*-- Código de página del dispositivo de salida.
	targetcp = 850
	*-- Código de página nativo
	sourcecp = 1252
	*-- Marca de inicio de sección.
	sectionbeginmark = "<"
	*-- Marca de fin de sección.
	sectionendmark = ">"
	*-- Indica si se imprimará la cabezera de página al iniciar la página de Resumen.
	printheaderonsummary = .T.
	*-- Indica si se imprimira o no la seccion HEADER al imprimir la sección TITLE.
	printheaderontitle = .T.
	*-- Indica si se desea mostrar o no el avance del método Run.
	showrunprogress = .F.
	*-- Nombre de la impresora a donde se enviará el informe.
	printername = ""
	*-- Nombre del archivo a donde se enviará el informe.
	filename = ""
	*-- Nro. de copias a imprimir.
	copies = 1
	*-- Indica si el reporte será enviado a la impresora.
	sendtoprinter = .T.
	*-- Area de trabajo donde está el cursor de datos.
	workarea = 0
	log = ""
	*-- Texto a mostrar en la ventana de avance
	runprogressmessage = "Generando informe...%CR%%CR% %pagegen% página(s) generada(s)"
	*-- Referencia a la ventana de avance
	HIDDEN oprogressform
	oprogressform = .NULL.
	*-- Versión actual
	version = '1.0c'
	*-- Lleva el conteo del número de páginas generadas
	pagegen = 0
	*-- Caracter usado para delimitar los macros expandibles
	macrochar = "%"
	*-- Cadena de configuracion que se envia a la impresora al finalizar el informe.
	endconfstring = ""
	printfooterontitle = .T.
	printfooteronsummary = .T.
	Name = "vfpdosprint"
	lineno = .F.

	*-- Nombre del Documento en la Cola de Impresión, Agregado Esparta 27/08/2001. VES 29-11-02: Obsoleto. Sustituido por propiedad JobName. Se mantiene por compatibilidad.
	cdocname = .F.

	*-- Nombre del formato de impresión a utilizar.
	printformat = .F.

	*-- Contenido del archivo indicado en PrintFormat
	HIDDEN printformatdata

	*-- Indica si se saltará de página después de imprimir la sección Title.
	ejectaftertitle = .F.

	*-- Indica si se saltará la página antes de imprimir la sección Summary.
	ejectbeforesummary = .F.

	*-- Nombre del trabajo de impresión
	printjobname = .F.

	*-- Colección de secciones.
	sections = .F.

	*-- Nombre de un procedimiento o método que será invocado cada vez que se reporte el avance del método Run.
	runcallback = .F.

	*-- Indica si el reporte será enviado a un archivo.
	sendtofile = .F.
	sendtotext = .F.

	*-- Colección de eventos definidos en el formato.
	events = .F.

	*-- Indica si se mostrarán o no valores nulos
	shownullvalues = .F.

	*-- Carpeta de trabajo
	workfolder = .F.

	*-- Indica si el informe se está procesando como un subreporte llamado desde otro reporte.
	subreport = .F.
	mode = .F.

	*-- Tipo de dataset en uso
	sourcetype = .F.

	*-- Nombre del dataset en use o referencia al Recordset ADO
	datasource = .F.

	*-- Activa o desactiva el modo HTML
	htmlmode = .F.

	*-- Nro. de serial
	dpserial = .F.

	*-- Nombre del cliente
	dpcustomer = .F.

	*-- Fecha de expiración de la licencia
	dpexpire = .F.

	*-- Indica cuando se ha llegado al final del informe.
	eof = .F.

	*-- Lista de macros
	DIMENSION macros[1,1]

	*-- Lista de grupos definidos
	HIDDEN agroups[1,1]
	HIDDEN amacros[1,1]


	*-- Muestra el dialogo Acerca de...
	PROCEDURE about
		LOCAL oAboutForm
		oAboutForm = NEWOBJECT("VDPAbout", "vdp.prg", "",THIS)
		oAboutForm.Show()
	ENDPROC


	*-- Escribe el texto indicado sin avanzar la línea
	PROCEDURE write
		lparameters pcTexto,plLeftMargin


		#DEFINE CRLF	chr(13)+chr(10)

		if parameters()=0
		 pcTexto=""
		endif 

		* (ESP) 20-AGO-2001
		* Causaba inconvenientes el imprimir algo antes
		* de Imprimir el encabezado.... Por eso se agregó este
		* IF de This.nPL, de lo contrario WriteLn
		if this.nPL=0  
		  this.WriteLn()
		endif  


		* (VES)  07-OCT-2001
		* Se reescribió completamente el código a partir de este punto. 
		*
		this.BeforeWrite()

		local array aLineas[1]
		local i,nCount
		nCount=alines(aLineas,this.ExpandMacros(pcTexto))

		for i=1 to nCount
		 *
		 do case
		    case upper(left(aLineas[i],6))=="#EXEC "
		         local cCmd
		         cCmd=allt(subs(aLineas[i],7))
		         &cCmd
		         loop
		 endcase
		 
		 this.SetPrintOn()
		 if plLeftMargin
		  this.iPrintString(space(this.LeftMargin) + aLineas[i])
		 else
		  this.iPrintString(aLineas[i])
		 endif
		 
		 if nCount > 1 and i < nCount
		  ?
		  this.nPL=this.nPL + 1
		  this.AfterWrite()
		 endif
		 *
		endfor

		this.SetPrintOff()
	ENDPROC


	*-- Escribe el texto indicado avanzando la linea
	PROCEDURE writeln
		lparameters pcTexto,plDoCalcs,plNoEject,plNoHeader,plNoStartOnNewPage,poSection

		#DEFINE CRLF	chr(13)+chr(10)

		if parameters()=0
		 pcTexto=""
		endif 

		if vartype(poSection)<>"O"
		 poSection=this.New("Section")
		endif
		local oBand
		oBand=poSection


		*-- Si definen algunas variables publicas
		*
		private DPEOF
		DPEOF=THIS.EOF


		*-- Si se indicó el parámetro Macros de la sección, se definen las macros indicadas
		*
		local cVar,cExpr,i
		for i=1 to oBand.Macros.Count
		 cVar=oBand.Macros.Items(i).Name
		 cExpr=oBand.Macros.Items(i).Expr
		 private (cVar)
		 store eval(cExpr) to (cVar)
		endfor


		*-- Se descompone el texto a imprimir en lineas individuales y se determina su
		*   altura real.
		*
		local array aLineas[1]
		local i,nCount,nRealHeight,nNELCount
		nCount=alines(aLineas,this.ExpandMacros(pcTexto,plDoCalcs))

		nRealHeight=0
		nNELCount=0
		for i=1 to nCount
		 if left(aLineas[i],1)="#"
		  loop
		 endif 
		 nRealHeight=nRealHeight + 1
		 if not empty(aLineas[i])
		  nNELCount=nNELCount + 1
		 endif 
		endfor


		*-- Si el parámetro PrintIfBlank es Falso y el texto a imprimir está vacio, se cancela
		*   el método sin imprimir nada
		*
		if (not oBand.PrintIfBlank) and nNELCount=0 and ;
		   ((not oBand.StartOnNewPage) or plNoStartOnNewPage)
		 return
		endif


		*-- Si se indicaron los parámetros IntegralHeight y BandHeight de la sección, y 
		*   IntegralHeight=True, se determina el alto real de la banda
		*
		if oBand.IntegralHeight and vartype(oBand.BandHeight)="N"
		 nRealHeight=max(nRealHeight,oBand.BandHeight)
		endif


		*-- Si se indicó el parámetro IntegralHeight de la sección y no hay espacio suficiente en 
		*   la página para toda la sección, se hace un salto de página
		*
		if oBand.IntegralHeight and (not plNoEject) and this.AutoEject and (this.PaperLenght > 0) and ;
		   ((this.nPL + nRealHeight + this.BottomMargin) > (this.PaperLenght - this.FooterLenght))
		 this.Eject()   
		 nCount=alines(aLineas,this.ExpandMacros(pcTexto,.F.)) 
		endif


		*-- Si se indicó el parámetro StartOnNewPage de la sección, se hace un salto de página. Si
		*   además se indicó el parámetro ResetPageCounter, se reinicia el conteo de páginas. 
		*
		if oBand.StartOnNewPage and (not plNoStartOnNewPage)
		 *
		 local nPageCnt
		 nPageCnt=this.PageNo
		 if this.nPL > 0
		  this.Eject()
		 endif 
		 if oBand.ResetPageCounter 
		  this.iResolvePageCnt(nPageCnt) 
		  this.PageNo=1
		  this.SetMacroValue("PAGENO",alltrim(str(This.PageNo)))  
		 endif

		 if memlines(pcTexto) > 0 
		  nCount=alines(aLineas,this.ExpandMacros(pcTexto,.F.))  
		 else
		  nCount=0 
		 endif 
		 *
		endif


		*-- Si no hay lineas que imprimir, se termina el método en este punto
		*
		if nCount=0
		 return
		endif


		*-- Se realiza el chequeo necesario antes de imprimir
		*
		this.BeforeWrite(plNoHeader,oBand.Type)


		*-- Se procesa el texto
		*
		for i=1 to nCount
		 *
		 do case
		    case upper(left(aLineas[i],6))=="#EXEC "
		         local cCmd
		         cCmd=allt(subs(aLineas[i],7))
		         &cCmd
		         loop
		         
		    case upper(left(aLineas[i],8))=="#SUBREP "
		         private cCmd,cSubReportResult
		         cSubReportResult=""
		         if atc(".FMT",aLineas[i])=0
		          select 0
		          cCmd="cSubReportResult="+allt(subs(aLineas[i],8))
		          THIS.SetPrintOff()
		          set printer to
		          &cCmd         
		          set printer to (this.cOutFile) additive
		          THIS.SetPrintOn()
		         else
		          cSubReportResult=THIS.CallSubReport(allt(subs(aLineas[i],8)))
		         endif 
		         select (THIS.WorkArea)
		         
		         if not empty(cSubReportResult)
		          this.WriteLn(cSubReportResult,plDoCalcs,plNoEject,plNoHeader,plNoStartOnNewPage,oBand)
		         endif
		         
		         loop
		         
		         
		 endcase
		 
		 this.SetPrintOn()
		 this.iPrintString(space(this.LeftMargin) + aLineas[i])
		 ?
		 this.nPL=this.nPL + 1
		 this.AfterWrite(plNoEject)
		 
		 ** (VES 12-11-02)[V4]: Se obliga a imprimir el encabezado si se saltó la página antes
		 ** de haber finalizado la impresión de la sección.
		 if i<nCount and THIS.nPL=0
		  this.BeforeWrite(,oBand.Type)
		 endif
		 *
		endfor

		this.SetPrintOff()
	ENDPROC


	*-- Ejecuta un salto de página
	PROCEDURE eject

		#DEFINE NOEJECT		.T.


		*-- Si se indicó un texto para pié de página, se generan tantas lineas en blanco como
		*   sea necesario para llegar al punto de impresión del mismo
		*
		if not empty(this.FooterString)
		 if this.PaperLenght > 0
		  local i,j
		  this.SetPrintOn() 
		  j=0
		  for i=this.nPL+1 to (this.PaperLenght - this.FooterLenght - this.BottomMargin)  && (VES 17/2/07) Se incluyo BottomMargin en el calculo del espacio por llenar
		   ?
		   j=j + 1
		  endfor 
		  this.SetPrintOff() 
		  this.nPL=this.nPL + j
		 endif

		 this.PrintSection("FOOTER",NOEJECT)
		endif 


		*-- Se salta la página y se actualizan los contadores
		*
		this.SetPrintOn()
		??this.EjectString
		this.SetPrintOff()
		this.nPL=0
		this.PageNo = this.PageNo + 1
		this.PageGen = this.PageGen + 1

		* (ESP 20-AGO-2001) El numero de pagina se tiene que reasignar
		* (VES 07-OCT-2001) La instrucción fué modificada para usar el nuevo método SetMacro()
		this.SetMacroValue("PAGENO",alltrim(str(This.PageNo)))


		*-- Si la propiedad ShowRunProgress está activa, se muestra el avance
		*
		if this.ShowRunProgress
		 this.iShowProgress(THIS.PageNo - 1)
		endif

		if (not empty(this.RunCallBack))
		 this.CallRunCallBack(2,THIS.PageNo - 1)
		endif 
	ENDPROC


	*-- Imprime el reporte
	PROCEDURE print
		LPARAMETERS cPrinterName,pnCopies,pnFromPage,pnToPage

		if empty(this.cOutFile)
		 return .F.
		endif


		local oPDev,cLcDoc
		oPDev=THIS.New("PrintDev")

		if vartype(cPrinterName)="C"
		 oPDev.cPrinterName=cPrinterName
		else
		 oPDev.cPrinterName=THIS.PrinterName 
		endif
		if vartype(pnCopies)<>"N" or pnCopies < 1
		 pnCopies=THIS.Copies
		endif

		oPDev.cDocName  = THIs.PrintJobName


		if not oPDev.oOpen()
		 return .F.
		endif

		set printer to
		oPDev.cFileName=this.cOutFile

		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se obtiene el texto a imprimir
		*
		IF VARTYPE(pnFromPage)="N"
		 oPDev.cFileName = THIS.iPrintPageRange(pnFromPage,pnToPage)
		ENDIF
		*-- 13/Julio/2007

		local i
		for i=1 to pnCopies
		 oPDev.oPrintFile()
		endfor

		oPDev.oClose()
		set printer to (this.cOutFile) additive


		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se elimina el archivo temporal
		*   creado con el rango de paginas a imprimir
		*
		IF VARTYPE(pnFromPage)="N"
		 ERASE (oPDev.cFileName)
		ENDIF
		 
	ENDPROC


	*-- Limpia el reporte
	PROCEDURE clear
		LPARAMETERS plFullClear

		#define ESC 	chr(27)


		*-- Se limpia el buffer de salida
		*
		if not empty(THIS.cOutFile)
		 local fh,i
		 set printer to
		 fh=fcreate(this.cOutFile)
		 =fclose(fh)
		 set printer to (this.cOutFile)
		endif


		*-- Se eliminan las variables de totalización creadas
		*
		if vartype(ICALCS_VAR_LIST)<>"U"
		 local nCount,cVar
		 nCount=occurs(",",ICALCS_VAR_LIST) + 1
		 for i=1 to nCount
		  cVar=this.iToken(ICALCS_VAR_LIST,i,",")
		  if not empty(cVar)
		   release (cVar)
		  endif
		 endfor
		 ICALCS_VAR_LIST=""
		endif


		IF plFullClear
		 *
		 *-- Se configuran algunas propiedades
		 *
		 this.nPL=0
		 this.PageNo=1
		 this.PageGen=0
		 this.PrintFormat=""
		 this.TitleString=""
		 this.HeaderString=""
		 this.DetailString=""
		 this.FooterString=""
		 this.SummaryString=""
		 this.oProgressForm=NULL
		 this.EjectString=CHR(12)
		 this.PrintJobName="DOSPrint file"
		 THIS.SendToPrinter=.F.
		 THIS.SendToFile=.F.
		 THIS.SendToText=.F.
		 THIS.PrinterName=SET("PRINTER",2)
		 THIS.FileName=""
		 THIS.oProgressForm=NULL 


		 *-- Se limpian algunos objetos internos de uso comun 
		 *
		 this.Sections.Clear()
		 this.Events.Clear()
		 THIS.oPS_Sections1.Clear()
		 THIS.oPS_Sections2.Clear()
		 THIS.oPS_SingleSections.Clear()
		  

		 *-- Se limpia la colección de grupos
		 * 
		 this.nGroupCount=0
		 dimen this.aGroups[1,6]
		 this.aGroups[1,1]=.F.
		 this.aGroups[1,2]=.F.
		 this.aGroups[1,3]=.F.
		 this.aGroups[1,4]=.F.
		 this.aGroups[1,5]=.F.
		 this.aGroups[1,6]=.F.


		 *-- Se definen los macros por defecto
		 *
		 ********************************************************************
		 * MACROS RECONOCIDOS:
		 *
		 * $PAGENO$			Nro. de página
		 * $DATE$			Fecha actual
		 * $TIME$			Hora actual
		 * $DATETIME$		Fecha y hora actual
		 * $BON$				Activa la negrita
		 * $BOFF$			Desactiva la negrita
		 * $CON$				Activa la compresión
		 * $COFF$			Desactiva la compresión
		 * $C10$				Activa la compresión a 10 cpi
		 * $C12$				Activa la compresión a 12 cpi
		 * $CRLF$			Avance de linea
		 * $TAB$				Tabulador
		 *
		 * NOTA DE ACTUALIZACION:
		 * Como consecuencia de la implementación de STREXPAND() en esta clase
		 * todos los macros reconocidos pueden ser ahora referenciados usando
		 * la sintaxis %MACRO% así como la anterior $MACRO$.
		 **********************************************************************
		 dimen this.aMacros[1,4]
		 this.aMacros[1,1]=.F.
		 this.aMacros[1,2]=.F.
		 this.aMacros[1,3]=.F. 
		 this.aMacros[1,4]=.F. 

		 this.AddMacro("%PAGENO%","alltrim(str(oThis.PageNo))")
		 this.AddMacro("%DATE%",date())
		 this.AddMacro("%TIME%",time())
		 this.AddMacro("%DATETIME%",datetime())
		 this.AddMacro("%BON%",ESC+"G")
		 this.AddMacro("%BOFF%",ESC+"H")
		 this.AddMacro("%CON%",CHR(15))
		 this.AddMacro("%COFF%",CHR(18))
		 this.AddMacro("%C10%",ESC+"P")
		 this.AddMacro("%C12%",ESC+"M")
		 this.AddMacro("%CRLF%",CHR(13)+CHR(10))
		 this.AddMacro("%TAB%",space(5))
		 *
		ENDIF && FullClear

		 
	ENDPROC


	*-- Activa la salida hacia la impresión
	HIDDEN PROCEDURE setprinton
		*-- Se crea el archivo de salida (si no se ha indicado)
		*
		if empty(THIS.cOutFile)
		 THIS.cOutFile=THIS.iGenOutFile()
		 set printer to (this.cOutFile)
		endif 


		*-- Se deriva la salida standard hacia la impresora
		*
		set device to print
		set cons off
		set print on
	ENDPROC


	*-- Desactiva la salida hacia la impresora
	HIDDEN PROCEDURE setprintoff
		set print off
		set cons on
		set device to screen
	ENDPROC


	*-- Expande los macros incluidos en la cadena indicada
	HIDDEN PROCEDURE expandmacros
		lparameters pcTexto,plDoCalcs

		local tx
		tx=seconds()

		private oThis,DP,lERror
		oThis=this
		DP=this
		local i,cMacro,cExpr,lIsCalc,cOnError
		
		#IF VERSION(5) < 800
			cOnError=on("ERROR")
			on error lError=.T.
		#ENDIF

		for i=1 to alen(this.aMacros,1)
		 *
		 cMacro=this.aMacros[i,1]
		 cMacro=this.iGetMacroName(cMacro)
		 cExpr=this.aMacros[i,2]
		 lIsCalc=(vartype(cExpr)="C" and atc("oThis.",cExpr)<>0)
		 
		 if (not lIsCalc) or plDoCalcs 
		  *
		  private (cMacro)
		  if vartype(cExpr)="C" 
		   *
		   if this.aMacros[i,4]  && Expandible?
		    cExpr=this.STRExpand(cExpr)
		    this.aMacros[i,4]=(cExpr<>cExpr)  && Se actualiza el status de expandible.
		   endif 

		   lError=.F.		   		   
		   #IF VERSION(5) < 800
			   store eval(cExpr) to &cMacro
		   #ELSE
		   	   TRY
		   	       store eval(cExpr) to &cMacro
		   	   CATCH TO ex
		   	   	   lError = .T.
		   	   ENDTRY
		   #ENDIF
		   if lError
		    store cExpr to &cMacro
		   endif

		   *
		  else
		   store cExpr to (cMacro)
		  endif
		  
		  if lIsCalc
		   this.aMacros[i,3]=eval(cMacro)
		  endif
		  *
		 else
		  store this.aMacros[i,3] to &cMacro
		 endif
		 *
		endfor

		if not this.HTMLMode
		 pcTexto=chrt(pcTexto,"$",THIS.MacroChar)
		endif 
		pcTexto=this.StrExpand(pcTexto)

		#IF VERSION(5) < 800
			if not empty(cOnError)
			 on error &cOnError
			else
			 on error 
			endif
		#ENDIF


		return pcTexto
	ENDPROC


	*-- Genera la salida del reporte en el archivo indicado
	PROCEDURE printtofile
		LPARAMETERS cFileName,nCopies,pnFromPage,pnToPage

		if empty(this.cOutFile)
		 return .F.
		endif

		if vartype(cFileName)<>"C"
		 cFileName=this.FileName
		endif
		if vartype(nCopies)<>"N" or nCopies < 1
		 nCopies=THIS.Copies
		endif

		if empty(justpath(cFileName)) and (not empty(this.PrintFormat))
		 cFileName=forcepath(cFileName,JustPath(this.PrintFormat))
		endif 

		set printer to


		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se obtiene el texto a imprimir.
		*
		LOCAL cOutFile
		cOutFile = THIS.cOutFile
		IF VARTYPE(pnFromPage)="N"
		 cOutFile = THIS.iPrintPageRange(pnFromPage,pnToPage)
		ENDIF
		*-- 13/Julio/2007


		*-- VES 13/Julio/2007
		*   Se cambio el uso directo de THIS.cOutfile por el de la variable local cOutFile para
		*   soportar la impresion por rango de paginas
		*
		if nCopies = 1
		 copy file (cOutFile) to (cFileName)
		else
		 local cData,i,cData2
		 cData=filetostr(cOutFile)
		 cData2=""
		 for i=1 to nCopies
		  cData2 = cData2 + cData
		 endfor
		 strtofile(cData2,cFileName)
		endif

		set printer to (this.cOutFile) additive
		 

		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se elimina el archivo temporal
		*   creado con el rango de paginas a imprimir
		*
		IF VARTYPE(pnFromPage)="N"
		 ERASE (cOutFile)
		ENDIF
		 
	ENDPROC


	*-- Añade un macro a la lista de macros
	PROCEDURE addmacro
		lparameters pcMacro,pcString

		pcMacro=chrt(upper(pcMacro),THIS.MacroChar,"$")
		if left(pcMacro,1)<>"$"
		 pcMacro="$" + pcMacro
		endif
		if right(pcMacro,1)<>"$"
		 pcMacro=pcMacro + "$"
		endif

		local nCount
		if alen(this.aMacros,1)=1 and type("this.aMacros[1,1]")<>"C"
		 nCount=1
		else
		 nCount=alen(this.aMacros,1) + 1
		endif
		dimen this.aMacros[nCount,4]
		this.aMacros[nCount,1]=pcMacro		&& Nombre
		this.aMacros[nCount,2]=pcString     && Expresion
		this.aMacros[nCount,3]=""           && Ultimo valor 
		this.aMacros[nCount,4]=.T.          && Expandible?
	ENDPROC


	*-- Cambia el valor asociado a un macro
	PROCEDURE setmacro
		lparameters pcMacro,pcValor

		local i,nCount
		nCount=alen(this.aMacros,1)

		pcMacro=upper(pcMacro)
		if left(pcMacro,1)<>"$"
		 pcMacro="$" + pcMacro
		endif
		if right(pcMacro,1)<>"$"
		 pcMacro=pcMacro + "$"
		endif

		for i=1 to nCount
		 if vartype(this.aMacros[i,1])="C"
		  if this.aMacros[i,1]==pcMacro
		   this.aMacros[i,2]=pcValor
		   exit
		  endif 
		 endif
		endfor
	ENDPROC


	*-- Devuelve el valor de un macro
	PROCEDURE getmacro
		lparameters pcMacro

		local i,nCount
		nCount=alen(this.aMacros,1)

		pcMacro=upper(pcMacro)
		if left(pcMacro,1)<>"$"
		 pcMacro="$" + pcMacro
		endif
		if right(pcMacro,1)<>"$"
		 pcMacro=pcMacro + "$"
		endif

		for i=1 to nCount
		 if this.aMacros[i,1]==pcMacro
		  return this.aMacros[i,2]
		 endif 
		endfor

		return ""
	ENDPROC


	HIDDEN PROCEDURE lineno_access
		RETURN THIS.nPL
	ENDPROC


	HIDDEN PROCEDURE lineno_assign
		LPARAMETERS vNewVal
	ENDPROC


	*-- Imprime la cadena en secciones de 250 caracteres, se agregó para solucionar el problema de ?? y ?
	HIDDEN PROCEDURE iprintstring
		Parameters lcCadena


		* (ESP AGO-2001)
		* Función Utilizada simplemente para simplificar
		* Es de ayuda para subsanar el conflicto de cadenas 
		* mayores de 255 caracteres, Divide y Venceras!!
		* Forma de llamada 
		* this.Imprimir(cadena)
		* PARAMETROS lcCadena
		*
		* (VES AGO-2001)
		* Se añadió código para procesar los CRLF que puedan venir
		* incluidos en lcCadena
		*
		* (VES SEP-2001)
		* Se cambió el nombre del método a iPrintString para mantener
		* consistencia con el resto de la interfaz. También se declaró
		* como oculto en lugar de protegido.
		*
		* (VES OCT-2001)
		* Se añadió el código para conversión de código de página.
		*
		* (VES NOV-2002) (V4)
		* Se selecciona un área de trabajo vacia para evitar el error que se producia cuando
		* una columna de la tabla de trabajo tenia el mismo nombre que alguna de las variables
		* usadas en este método.
		*
		* (VES 30-NOV-2004) (V4.3c)
		* Se corrigió un error en el cálculo de la variable "ciclos", el cual daba un valor
		* incorrecto en cadenas superiores a los 500cars.
		*

		local nWkArea
		m.nWkArea=select()
		select 0

		local array aLineas[1]
		local nc, ciclos, nCount, i
		if this.SourceCP<>this.TargetCP
		 lcCadena=cpconvert(this.SourceCP,this.TargetCP,lcCadena)
		endif
		ncount=alines(aLineas,lcCadena)

		for i=1 to nCount
		  lcCadena=aLineas[i]
		  nc=1
		  ciclos = int(len(lccadena)/250) + iif(mod(len(lccadena),250)=0,0,1)

		  for i=1 to ciclos 
		   ?? substr(lcCadena,nc,250)
		      nc=nc+250
		  endfor
		  
		  if nCount > 1 and i < nCount
		   ?
		  endif
		endfor

		if m.nWkArea<>0
		 select (m.nWkArea)
		endif
	ENDPROC


	*-- Expande macros contenidos en una cadena.
	PROCEDURE strexpand
		PARAMETERS pcString


		 *-- Se declaran algunas variables temporales
		 *
		 local cVarName,nOcur,nPos,nPos2,cVarType,uVarValue,nExprLon,cVarExpr,cOnError
		 private lError
		 
		 #IF VERSION(5) < 800
			 cOnError=on("ERROR")
			 on error lError=.T.
		 #ENDIF
		 
		 
		 *-- Se inicia un ciclo infinito para procesar macros de longitud variable. El ciclo 
		 *   termina cuando ya no haya más ocurrencias del caracter delimitador
		 * 
		 local cMarker
		 cMarker=this.MacroChar
		 
		 nOcur=1
		 do while .T.
		  *
		  nPos=at(cMarker,pcString,nOcur)
		  if nPos=0
		   exit
		  endif
		  
		  
		  *-- Se obtiene el valor de la expresión
		  *
		  cVarName=subs(pcString,nPos+1)
		  nPos2=at(cMarker,cVarName)
		  if nPos2=0
		   exit
		  endif
		  cVarName=left(cVarName,nPos2-1)
		  cVarExpr=allt(cVarName)

		  lError=.F.
		  #IF VERSION(5) < 800
		  	uVarValue=eval(cVarExpr)
		  #ELSE
		  	TRY
		  		uVarValue=eval(cVarExpr)
		  	CATCH TO ex
		  		lERror = .T.
		  	ENDTRY
		  #ENDIF	
		  if lError
		   nOcur=nOcur + 2
		   loop
		  endif
		  cVarType=vartype(uVarValue)
		     
		  
		  *-- Se substituye la entrada %Expr% por su valor real de acuerdo al tipo. Si la expresión
		  *   es incorrecta (tipo U) o dá como resultado un objeto (tipo O), la cadena %Expr% no es
		  *   substituida.
		  *
		  do case
		     case cVarType $ "UO"		&& Expresión incorrecta o un objeto. No se procesa.
		          nOcur=nOcur + 2
		          
		     case cVarType="C"			&& Cadena. Se substituye directamente.
		          
		     case cVarType $ "NY" and int(uVarValue)=uVarValue    && Entero. Se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue))

		     case cVarType $ "NY" and int(uVarValue)<>uVarValue   && Flotante. Se utiliza la configuración de DECIMALS y se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue,20,set("decimals")))
		          
		     case cVarType="D"			&& Fecha. Se convierte a caracteres.
		          uVarValue=dtoc(uVarValue)
		          
		     case cVarType="L"			&& Lógico. Se subsitutye por S o N.
		          uVarValue=iif(uVarValue,"S","N")

		     otherwise					&& Otro. Se substituye por el resultado de TRANSFORM().
		          uVarValue=trans(uVarValue,"")
		  endcase
		  pcString=strtran(pcString,cMarker+cVarName+cMarker,uVarValue)       
		  
		  *
		 enddo
		 
		 
		 *-- Se inicia un ciclo infinito para procesar macros de longitud fija. El ciclo termina
		 *   cuando ya no haya más ocurrencias del signo [.
		 * 
		 nOcur=1
		 do while .T.
		  *
		  nPos=at("[",pcString,nOcur)
		  if nPos=0
		   exit
		  endif
		  
		  
		  *-- Se obtiene el valor de la expresión
		  *
		  cVarName=subs(pcString,nPos+1)
		  nPos2=at("]",cVarName)
		  if nPos2=0
		   exit
		  endif
		  cVarName=left(cVarName,nPos2-1)
		  nExprLon=len(cVarName) + 2
		  cVarExpr=allt(cVarName)
		  lError=.F.
		  #IF VERSION(5) < 800
		  	uVarValue=eval(cVarExpr)
          #ELSE
		  	TRY
		  		uVarValue=eval(cVarExpr)
		  	CATCH TO ex
		  		lERror = .T.
		  	ENDTRY          
          #ENDIF
		  if lError
		   nOcur=nOcur + 1
		   loop
		  endif
		  cVarType=vartype(uVarValue)
		  
		  
		  *-- Se substituye la entrada [Expr] por su valor real de acuerdo al tipo. Si la expresión
		  *   es incorrecta (tipo U) o dá como resultado un objeto (tipo O), la cadena %Expr% no es
		  *   substituida.
		  *
		  do case
		     case cVarType $ "UO"		&& Expresión incorrecta o un objeto. No se procesa.
		          nOcur=nOcur + 1
		          
		     case cVarType="C"			&& Cadena. Se substituye directamente.
		          
		     case cVarType $ "NY" and int(uVarValue)=uVarValue    && Entero. Se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue))

		     case cVarType $ "NY" and int(uVarValue)<>uVarValue   && Flotante. Se utiliza la configuración de DECIMALS y se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue,20,set("decimals")))
		          
		     case cVarType="D"			&& Fecha. Se convierte a caracteres.
		          uVarValue=dtoc(uVarValue)
		          
		     case cVarType="L"			&& Lógico. Se subsitutye por S o N.
		          uVarValue=iif(uVarValue,"S","N")

		     otherwise					&& Otro. Se substituye por el resultado de TRANSFORM().
		          uVarValue=trans(uVarValue,"")
		  endcase
		  pcString=strtran(pcString,"["+cVarName+"]",padr(uVarValue,nExprLon))       
		  
		  *
		 enddo


		 *-- Se inicia un ciclo infinito para procesar macros de longitud fija multilinea. El ciclo
		 *   termina cuando ya no haya más ocurrencias del signo {.
		 * 
		 nOcur=1
		 do while .T.
		  *
		  nPos=at("{",pcString,nOcur)
		  if nPos=0
		   exit
		  endif
		  
		  
		  *-- Se obtiene el valor de la expresión
		  *
		  cVarName=subs(pcString,nPos+1)
		  nPos2=at("}",cVarName)
		  if nPos2=0
		   exit
		  endif
		  cVarName=left(cVarName,nPos2-1)
		  nExprLon=len(cVarName) + 2
		  cVarExpr=allt(cVarName)
		  lError=.F.
		  #IF VERSION(5) < 800
		  	uVarValue=eval(cVarExpr)
          #ELSE
		  	TRY
		  		uVarValue=eval(cVarExpr)
		  	CATCH TO ex
		  		lERror = .T.
		  	ENDTRY          
          #ENDIF
		  if lError
		   nOcur=nOcur + 1
		   loop
		  endif
		  cVarType=vartype(uVarValue)
		  
		  
		  *-- Se substituye la entrada [Expr] por su valor real de acuerdo al tipo. Si la expresión
		  *   es incorrecta (tipo U) o dá como resultado un objeto (tipo O), la cadena %Expr% no es
		  *   substituida.
		  *
		  do case
		     case cVarType $ "UO"		&& Expresión incorrecta o un objeto. No se procesa.
		          nOcur=nOcur + 1
		          
		     case cVarType="C"			&& Cadena. Se eliminan los espacios a la derecha.
		          uVarValue=rtrim(uVarValue)
		          
		     case cVarType $ "NY" and int(uVarValue)=uVarValue    && Entero. Se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue))

		     case cVarType $ "NY" and int(uVarValue)<>uVarValue   && Flotante. Se utiliza la configuración de DECIMALS y se eliminan los espacios en blanco del STR().
		          uVarValue=allt(str(uVarValue,20,set("decimals")))
		          
		     case cVarType="D"			&& Fecha. Se convierte a caracteres.
		          uVarValue=dtoc(uVarValue)
		          
		     case cVarType="L"			&& Lógico. Se subsitutye por S o N.
		          uVarValue=iif(uVarValue,"S","N")

		     otherwise					&& Otro. Se substituye por el resultado de TRANSFORM().
		          uVarValue=trans(uVarValue,"")
		  endcase
		  

		  *-- Si la longitud de la expresión es menor o igual al espacio disponible, se sustituye
		  *   directamente, de lo contrario, se añaden tantas lineas como sean necesarias para
		  *   acomodar todo el texto resultante.
		  *   
		  if len(uVarValue) <= nExprLon
		   pcString=strtran(pcString,"{"+cVarName+"}",padr(uVarValue,nExprLon))       
		  else
		   *
		   *-- Se divide el texto original en lineas separadas
		   local cBuff,cText,nCount,i,nLin,nStart,nPos2
		   local array aLins[1]
		   nCount=alines(aLins,pcString)
		   
		   *-- Se ubica la linea en donde esta indicada la expansion
		   nStart=0
		   for i=1 to nCount
		    if atc("{"+cVarName,aLins[i])<>0
		     nStart=i
		     exit
		    endif
		   endfor
		   nPos2=AT("{"+cVarName,aLins[nStart])

		   *-- Se divide el texto a imprimir en lineas separadas
		   local array aBuff[1]
		   local array aTemp[1]
		   local nBuffSize,nTempSize
		   nTempSize=alines(aTemp,uVarValue)
		   nBuffSize=0
		   for i=1 to nTempSize
		    cBuff=aTemp[i]
		    do while not empty(cBuff)
		     nBuffSize=nBuffSize + 1
		     dimen aBuff[nBuffSize]
		     if len(cBuff) > nExprLon
		      aBuff[nBuffSize]=left(cBuff,nExprLon)
		      cBuff=subs(cBuff,nExprLon + 1)
		     else
		      aBuff[nBuffSize]=padr(cBuff,nExprLon)
		      cBuff=""
		     endif     
		    enddo
		   endfor
		   
		   *-- Se ajusta el nro. de lineas para ajustarse al tamano del texto
		   if (nStart + nBuffSize - 1) > nCount
		    nCount=nStart + nBuffSize - 1
		    dimen aLins[nCount]
		    for i=1 to nCount
		     if type("aLins[i]")="C"  
		      if len(aLins[i]) < (nPos2 + nExprLon)     
		       aLins[i]=padr(aLins[i],nPos2 + nExprLon)
		      endif
		     else
		      aLins[i]=space(nPos2 + nExprLon)
		     endif
		    endfor
		   endif
		   
		   
		   *-- Se carga el texto dentro de las lineas a imprimir
		   *
		   for i=1 to nBuffSize
		    nLin=nStart + (i - 1)
		    cBuff=aBuff[i]
		    
		    *-- VES 9/2/2007
		    *   Si la longitud de la linea es menor que la posicion donde se insertara el
		    *   texto + la longitud del texto a insertar, se produce un descuadre en la 
		    *   posicion del texto. Para evitar esto, se rellena con espacios en blanco
		    *   la cadena para brindar el espacio suficiente para insertar el texto 
		    *   requerido
		    IF LEN(aLins[nLin]) < nPos2 + nExprLon
		     aLins[nLin]=PADR(aLins[nLin],nPos2+nExprLon)
		    ENDIF
		    *--
		        
		    aLins[nLin]=stuff(aLins[nLin],nPos2,nExprLon,cBuff)
		   endfor

		   
		   *-- Se reconstruye el texto original, pero con las lineas adicionales
		   pcString=""
		   for i=1 to nCount
		    pcString=pcString + aLins[i] + CHR(13) + CHR(10)
		   endfor
		   
		   *-- Se liberan las variables creadas para este proceso
		   release cbuff,cText,nCount,i,nLin,aLins,aTemp,aBuff,nBuffSize,nTempSize
		   *
		  endif 
		  
		  
		  *-- Se busca la siguiente aparición del marcador "{"
		  *
		 enddo
		 
		 
		 *-- Se restaura la rutina de errores
		 *
		 #IF VERSION(5) < 800
			 if not empty(cOnError)
			  on error &cOnError
			 else
			  on error 
			 endif
		 #ENDIF
		 
		 
		 *-- Se devuelve la cadena expandida
		 *
		 return pcString
	ENDPROC


	*-- Devuelve el nombre de un macro, eliminando los marcadores $
	HIDDEN PROCEDURE igetmacroname
		lparameters pcMacro

		return chrt(pcMacro,"$%"+THIS.MacroChar,"")
	ENDPROC


	*-- Devuelve el texto asociado a una sección del formato de impresión indicado.  Este método se mantiene por compatibilidad. Use el nuevo método LoadFormatSection.
	PROCEDURE getformatsection
		LPARAMETERS pcSection
		 *
		 if empty(this.PrintFormat)
		  return ""
		 endif
		 
		 local array aText[1]
		 local nCount,i,lInSection,cData,cOpenTag,cCloseTag
		 nCount=alines(aText,this.PrintFormatData)
		 cOpenTag=this.SectionBeginMark + allt(upper(pcSection))
		 cCloseTag=this.SectionBeginMark + "/" + allt(upper(pcSection)) + this.SectionEndMark 
		 cData=""
		 lInSection=.F.
		 
		 for i=1 to nCount
		  *
		  do case
		     case left(aText[i],1)="#" and not ("#EXEC " $ upper(aText[i]) or "#SUBREP " $ upper(aText[i]) or "#SET " $ upper(aText[i]))
		          loop
		  
		     case (not lInSection) and left(allt(upper(aText[i])),len(cOpenTag))==cOpenTag
		          lInSection=.T.
		          loop
		          
		     case lInSection and allt(chrt(upper(aText[i])," ",""))==cCloseTag
		          lInSection=.F.
		          exit
		          
		     case lInSection
		          if "//" $ aText[i]
		           aText[i]=left(aText[i],at("//",aText[i])-1)
		          endif
		          cData=cData + aText[i] + CHR(13) + CHR(10)
		  endcase         
		  *
		 endfor
		 
		 return cData
		 *
	ENDPROC


	HIDDEN PROCEDURE printformat_assign
		LPARAMETERS vNewVal

		if not empty(m.vNewVal)
		 if file(m.vNewVal)
		  THIS.printformat = m.vNewVal
		  THIS.iLoadFormat(m.vNewVal)
		 else 
		  error "The file '"+m.vNewVal+"' does not exists!" 
		 endif
		else
		 this.PrintFormat=""
		endif
	ENDPROC


	*-- Carga el contenido de un archivo de formato.
	HIDDEN PROCEDURE iloadformat
		lparameters pcFormat


		*-- Se carga el formato en memoria
		*
		local cData
		cData=filetostr(pcFormat)


		*-- Se procesan las directivas #INCLUDE
		*
		local nPos,cFile,cIncluded,cData1,cData2
		nPos=atc("#INCLUDE ",cData)
		do while nPos<>0
		 cData1=subs(cData,1,nPos-1)
		 cFile=subs(cData,nPos + 9)
		 cData2=subs(cFile,at(chr(13)+chr(10),cData)) 
		 cFile=left(cFile,at(chr(13)+chr(10),cData) - 1)
		 if file(cFile)
		  cIncluded=filetostr(cFile)
		  cData=cData1 + cIncluded + cData2
		 else
		  cData=cData1 + cData2
		 endif
		 nPos=atc("#INCLUDE ",cData) 
		enddo
		this.PrintFormatData=cData
		release cData,cData1,cData2


		*-- Se cargan las configuraciones
		*
		private SI,NO,TRUE,FALSE,YES
		store .T. to SI,TRUE,YES
		store .F. to NO,FALSE


		local cPropList,nCount,i,j,cProp,cExpr
		local array aProps[1]
		cPropList=this.GetFormatSection("CONFIG")
		nCount=alines(aProps,cPropList)

		for i=1 to nCount
		 j=at("=",aProps[i])
		 cProp=allt(left(aProps[i],j-1))
		 if not empty(cProp)
		  cExpr=allt(subs(aProps[i],j+1))
		  if type("this."+cProp)<>"U"
		   cExpr=this.ExpandMacros(cExpr)
		   cExpr=strt(cExpr,chr(13)+chr(10),"CHR(13)+CHR(10)")   
		   if not empty(cExpr)
		    store eval(cExpr) to ("THIS."+cProp)
		   endif
		  endif
		 endif
		endfor


		*-- Se obtiene la lista de secciones definidas en el formato y se carga el formato
		*   de dichas secciones.
		*
		local oSections,oItem
		oSections=this.GetFormatSectionList()
		for i=1 to oSections.Count
		 oItem=this.LoadFormatSection(oSections.Items(i))
		 do case
		    case oItem.Type="EVENT"
		         this.Events.Add(oItem)
		         
		    otherwise
		         this.Sections.Add(oItem)
		 endcase         
		endfor


		*-- Si se indicó una sección FORMAT, se procesa su contenido
		*
		if THIS.Sections.IsItem("FORMAT")
		 THIS.iProcessFormatSection()
		endif


		*-- Se cargan las secciones fijas. Esto se hacer por compatibilidad con versiones
		*   anteriores de DOSPrint.
		*
		this.TitleString=iif(this.Sections.IsItem("TITLE"),this.Sections.Items("TITLE").Text,"")
		this.HeaderString=iif(this.Sections.IsItem("HEADER"),this.Sections.Items("HEADER").Text,"")
		this.DetailString=iif(this.Sections.IsItem("DETAIL"),this.Sections.Items("DETAIL").Text,"")
		this.FooterString=iif(this.Sections.IsItem("FOOTER"),this.Sections.Items("FOOTER").Text,"")
		this.SummaryString=iif(this.Sections.IsItem("SUMMARY"),this.Sections.Items("SUMMARY").Text,"")


		*-- Se cargan las definiciones de macros
		*
		private cMacroList,nCount,i,j,cMacro,cExpr
		local array aMacros[1]
		cMacroList=this.GetFormatSection("MACROS")
		nCount=alines(aMacros,cMacroList)

		local nPos,cSumExpr,nLen
		private cSum,cReset,cStart
		for i=1 to nCount
		 j=at("=",aMacros[i])
		 cMacro=allt(left(aMacros[i],j-1))
		 
		 if not empty(cMacro)
		  *
		  cExpr=allt(subs(aMacros[i],j+1))

		  do case
		     case atc("_SUM[",cExpr)<>0
		          nPos=atc("_SUM[",cExpr)
		          cSumExpr=subs(cExpr,nPos+5)
		          cSumExpr=subs(cSumExpr,1,at("]",cSumExpr)-1)
		          nLen=len(cSumExpr) + 5 + 1
		          cSum=this.iToken(cSumExpr,1,";")
		          cReset=this.iToken(cSumExpr,2,";")
		          cStart=this.iToken(cSumExpr,3,";")
		          cSumExpr=chrt("oThis.iDoCalc('SUM','%cMacro%','%cSum%','%cReset%','%cStart%')","%",this.MacroChar)
		          if this.HTMLMode
		           cSumExpr=chrt(cSumExpr,"%","$")
		          endif
		          cSumExpr=this.STRExpand(cSumExpr)
		          cExpr=stuff(cExpr,nPos,nLen,cSumExpr)
		          
		     case atc("_COUNT[",cExpr)<>0
		          nPos=atc("_COUNT[",cExpr)
		          cSumExpr=subs(cExpr,nPos+7)
		          cSumExpr=subs(cSumExpr,1,at("]",cSumExpr)-1)
		          nLen=len(cSumExpr) + 7 + 1
		          cReset=this.iToken(cSumExpr,1,";")
		          cStart=this.iToken(cSumExpr,2,";")
		          cSumExpr=chrt("oThis.iDoCalc('COUNT','%cMacro%','','%cReset%','%cStart%')","%",this.MacroChar)
		          if this.HTMLMode
		           cSumExpr=chrt(cSumExpr,"%","$")
		          endif
		          cSumExpr=this.STRExpand(cSumExpr)
		          cExpr=stuff(cExpr,nPos,nLen,cSumExpr)
		          
		     case atc("_MIN[",cExpr)<>0
		          nPos=atc("_MIN[",cExpr)
		          cSumExpr=subs(cExpr,nPos+5)
		          cSumExpr=subs(cSumExpr,1,at("]",cSumExpr)-1)
		          nLen=len(cSumExpr) + 5 + 1
		          cSum=this.iToken(cSumExpr,1,";")
		          cReset=this.iToken(cSumExpr,2,";")
		          cStart=this.iToken(cSumExpr,3,";")
		          cSumExpr=chrt("oThis.iDoCalc('MIN','%cMacro%','%cSum%','%cReset%','%cStart%')","%",this.MacroChar)
		          if this.HTMLMode
		           cSumExpr=chrt(cSumExpr,"%","$")
		          endif
		          cSumExpr=this.STRExpand(cSumExpr)
		          cExpr=stuff(cExpr,nPos,nLen,cSumExpr)
		          
		     case atc("_MAX[",cExpr)<>0
		          nPos=atc("_MAX[",cExpr)
		          cSumExpr=subs(cExpr,nPos+5)
		          cSumExpr=subs(cSumExpr,1,at("]",cSumExpr)-1)
		          nLen=len(cSumExpr) + 5 + 1
		          cSum=this.iToken(cSumExpr,1,";")
		          cReset=this.iToken(cSumExpr,2,";")
		          cStart=this.iToken(cSumExpr,3,";")
		          cSumExpr=chrt("oThis.iDoCalc('MAX','%cMacro%','%cSum%','%cReset%','%cStart%')","%",this.MAcroChar)
		          if this.HTMLMode
		           cSumExpr=chrt(cSumExpr,"%","$")
		          endif
		          cSumExpr=this.STRExpand(cSumExpr)
		          cExpr=stuff(cExpr,nPos,nLen,cSumExpr)
		          
		     case atc("_AVG[",cExpr)<>0
		          nPos=atc("_AVG[",cExpr)
		          cSumExpr=subs(cExpr,nPos+5)
		          cSumExpr=subs(cSumExpr,1,at("]",cSumExpr)-1)
		          nLen=len(cSumExpr) + 5 + 1
		          cSum=this.iToken(cSumExpr,1,";")
		          cReset=this.iToken(cSumExpr,2,";")
		          cStart=this.iToken(cSumExpr,3,";")
		          cSumExpr=chrt("oThis.iDoCalc('AVG','%cMacro%','%cSum%','%cReset%','%cStart%')","%",this.MacroChar)
		          if this.HTMLMode
		           cSumExpr=chrt(cSumExpr,"%","$")
		          endif
		          cSumExpr=this.STRExpand(cSumExpr)
		          cExpr=stuff(cExpr,nPos,nLen,cSumExpr)
		  endcase
		  
		  this.AddMacro(cMacro,cExpr)
		  *
		 endif
		endfor


		*-- Se cargan las definiciones de grupo
		*
		local cGroupList,cGroup,cExpr,cHeader,cFooter
		local array aGroups[1]
		cGroupList=this.GetFormatSection("GROUPS")
		nCount=alines(aGroups,cGroupList)

		for i=1 to nCount
		 j=at("=",aGroups[i])
		 cGroup=allt(left(aGroups[i],j-1))
		 if not empty(cGroup)
		  cExpr=allt(subs(aGroups[i],j+1))
		  cHeader=allt(this.iToken(cExpr,2,"|"))
		  cFooter=allt(this.iToken(cExpr,3,"|")) 
		  cExpr=allt(this.iToken(cExpr,1,"|"))
		  this.iAddGroup(cGroup,cExpr,cHeader,cFooter)
		 endif
		endfor
	ENDPROC


	*-- Imprime el contenido de una sección del formato en uso.
	PROCEDURE printsection
		lparameters pcSection,plNoEject,plNoHeader,plOnlyPrintOnNewPage,plNoStartOnNewPage

		#DEFINE CRLF	chr(13)+chr(10)

		if type("x1")="U"
		 public x1
		 x1=0
		endif


		*-- Se obtiene los datos de la sección (o secciones) a imprimir. 
		local oSection,oSections,lEvalGroups,lDoCalcs,cType,i
		oSections=THIS.New("Collection")  && THIS.PS_Sections1
		oSections.Clear()
		pcSection=allt(upper(pcSection))
		lEvalGroups=.F.
		
		*-- VES Nov 2016
		*   Si no hay secciones definidas, se aplica un auto formato
		IF THIS.Sections.Count = 0 
			THIS.iAutoFormat()
		ENDIF
		
		*-- VES Nov 2016
		*   Si no se ha confirado el datasource, se hace ahora
		*
		IF  EMPTY(THIS.dataSource)
			THIS.iSetDataSource()
		ENDIF


		*-- Si solo existe una sección del tipo indicado se toma 
		*   automáticamente, de lo contrario se busca dentro de la
		*   lista de secciones definidas
		if this.oPS_SingleSections.IsItem(pcSection)
		 oSections.Add( this.Sections.Items(pcSection) )
		else 
		 for i=1 to this.Sections.Count
		  oSection=this.Sections.Items(i)
		  if oSection.Name==pcSection or oSection.Type==pcSection
		   oSections.Add( oSection )
		  endif
		 endfor
		 x1=x1 + 1

		 *-- Si solo hay una sección del tipo indicado, y el nombre
		 *   de la  misma corresponde al tipo de sección, se añade en
		 *   la lista de secciones simples.
		 if oSections.Count=1 and oSection.Name==oSection.Type
		  this.oPS_SingleSections.Add(pcSection)
		 endif  
		endif 


		*-- Si la sección es DETAIL, se activa la evaluación de
		*   grupos y macros.
		if pcSection=="DETAIL"        
		 lEvalGroups=.T.
		 lDoCalcs=.T.
		endif 
		        
		        

		*-- Si se indicó que se evaluaran los grupos, se evaluan
		*
		if lEvalGroups
		 this.EvalGroups()
		endif


		*-- Si la seccion es FOOTER, se mueve el cursor un registro atras para preservar los
		*   valores del ultimo registro de la pagina
		*
		IF pcSection="FOOTER"
		 THIS.MoveBack()
		ENDIF


		*-- Se determina la lista de secciones a imprimir, en base al tipo y el valor
		*   de la propiedad ApplyIf. Si se trata de una version Shareware, se toma solo
		*   una sección.
		*
		local lResult,oSectionsToPrint
		oSectionsToPrint=THIS.New("Collection")  && THIS.oPS_Sections2
		oSectionsToPrint.Clear()
		lResult=.F.
		for i=1 to oSections.Count
		 oSection=oSections.Items(i)
		 oSection.iTypeCount=oSections.Count
		 
		  if oSection.ApplyIf=".T."
		   lResult=.T.
		  else 
		   lResult=THIS.CheckExpr(oSection.ApplyIf,lDoCalcs)
		   lDoCalcs=.F.
		  endif 

		 if lResult
		  oSectionsToPrint.Add(oSection)
		 endif 
		endfor


		*-- Si no hay secciones que imprimir, se cancela        
		if oSectionsToPrint.Count=0
		 return
		endif


		*-- Se escribe el texto en el archivo de salida
		*
		PRIVATE DPCurSection,lStartOnNewPage
		FOR i=1 to oSectionsToPrint.Count
		 *
		 oSection=oSectionsToPrint.Items(i)
		 DPCurSection=oSection.Type
		 

		 *-- Si la seccion está vacia o no debe imprimirse, se obvia
		 if (empty(oSection.Text) and memlines(oSection.Text)=0 and ;
		     (not oSection.PrintIfBlank) and ((not oSection.StartOnNewPage) or plNoStartOnNewPage)) or ;
		    (plOnlyPrintOnNewPage and (not oSection.PrintOnNewPage))
		  loop
		 endif 
		   
		 

		 *-- Se evalua e imprime el contenido de la sección
		 this.WriteLn(oSection.Text,;
		              lDoCalcs,;
		              plNoEject,;
		              plNoHeader,;
		              plNoStartOnNewPage,;
		              oSection)
		              

		 *-- Si la sección es DETAIL, se desactiva la evaluación de
		 *   grupos y macros para evitar que se evaluen más de una vez por registro.
		 if pcSection=="DETAIL"        
		  lEvalGroups=.F.
		  lDoCalcs=.F.
		 endif 
		 *
		endfor 


		*-- Si la seccion es FOOTER, se mueve el cursor un registro adelante para restaurar la
		*   posicion del cursor.
		*
		IF pcSection="FOOTER"
		 THIS.MoveNext()
		ENDIF
	ENDPROC


	*-- Ejecuta las verificaciones necesarias antes de escribir data al archivo de salida.
	HIDDEN PROCEDURE beforewrite
		LPARAMETERS plNoHeader,pcSectionType

		if vartype(_FROMBEFOREWRITE)<>"U"
		 return
		endif

		if vartype(pcSectionType)<>"C"
		 pcSectionType="UNKNOW"
		endif


		*-- Esta variable evita que este método se llame recursivamente
		*
		private _FROMBEFOREWRITE
		_FROMBEFOREWRITE=.T.


		*-- Si es la primera linea de la página, se imprime el encabezado
		*
		if this.nPL=0 and (not plNoHeader)
		 *
		 this.SetPrintOn()


		 *-- Si es la primera linea de la primera página, se envia la cadena de configuración general
		 if (this.nPL=0 and this.PageNo=1 and (not empty(this.StartConfString)))
		  ??this.StartConfString
		 endif 
		 
		  
		 *-- Si es la primera linea de una página, se envia la cadena de configuración de página
		 if not empty(this.NewPageConfString)
		  ??this.NewPageConfString
		 endif 
		 
		 *-- Se deja el margen superior indicado
		 for i=1 to this.TopMargin
		  ?
		 endfor 
		 this.nPL=this.TopMargin

		 
		 *-- Se imprime la cabezera
		 this.PrintSection("HEADER")
		 

		 *-- Se imprime la cabezera de todos los grupos que tengan la propiedad
		 *   PrintOnNewPage activada (solo si se está procesando una sección tipo DETAIL)
		 if pcSectionType="DETAIL"
		  local nGroup
		  for nGroup=1 to this.nGroupCount
		   cGroup=this.aGroups[nGroup,1]
		   cHeader=allt(upper(this.aGroups[nGroup,3]))
		   this.PrintSection(cHeader,,,.T.,.T.)
		  endfor
		 endif 
		 this.SetPrintOff()  


		 *-- si se indicó un comando para nueva página, se ejecuta 
		 if not empty(this.OnNewPage)
		  local cCmd
		  cCmd=this.OnNewPage
		  &cCmd
		 endif 
		 
		 *
		endif
	ENDPROC


	HIDDEN PROCEDURE footerlenght_access
		local nFooterLenght
		local array foo[1]
		nFooterLenght=alines(foo,this.FooterString)

		RETURN nfooterlenght
	ENDPROC


	HIDDEN PROCEDURE footerlenght_assign
		LPARAMETERS vNewVal
		*To do: Modify this routine for the Assign method
		*THIS.footerlenght = m.vNewVal
	ENDPROC


	*-- Realiza las verificaciones necesarias después de haber escrito en el archivo de salida.
	HIDDEN PROCEDURE afterwrite
		lparameters plNoEject

		if vartype(_FROMAFTERWRITE)<>"U"
		 return
		endif

		*-- Esta variable evita que este método se llame recursivamente
		*
		private _FROMAFTERWRITE
		_FROMAFTERWRITE=.T.


		*-- Si se llegó al final de la página, se salta
		*
		if (not plNoEject) and this.AutoEject and this.PaperLenght > 0 and ;
		   (this.nPL + this.BottomMargin) >= (this.PaperLenght - this.FooterLenght)
		 this.Eject()
		endif 
	ENDPROC


	*-- Añade un grupo a la lista de grupos
	HIDDEN PROCEDURE iaddgroup
		lparameters pcGroup,pcExpr,pcHeader,pcFooter

		local nCount
		nCount=this.nGroupCount + 1
		dimen this.aGroups[nCount,6]
		this.aGroups[nCount,1]=pcGroup
		this.aGroups[nCount,2]=pcExpr
		this.aGroups[nCount,3]=pcHeader
		this.aGroups[nCount,4]=pcFooter
		this.aGroups[nCount,5]=NULL
		this.aGroups[nCount,6]=NULL
		this.nGroupCount=nCount
	ENDPROC


	*-- Devuelve un elemento dado de una lista de elementos
	HIDDEN PROCEDURE itoken
		lparameters pcLista,pnElemento,pcSep,pnNumTokens
		 *
		 if type("pcSep")#"C" or len(pcSep)=0
		  pcSep=","
		 endif
		   
		 local vElement,vNumElem,i,j,nLenSep
		 vElement=""
		 vNumElem=occurs(pcSep,pcLista) + 1
		 nLenSep=len(pcSep)
		 
		 do case
		    case empty(pcLista) or pnElemento > vNumElem
		         vElement=""
		         
		    case vNumElem=1 
		         if pnElemento=1
		          vElement=pcLista
		         endif
		         
		    case pnElemento=1
		         vElement=subs(pcLista,1,atc(pcSep,pcLista,1)-1)
		         
		    case pnElemento=vNumElem
		         vElement=subs(pcLista,atc(pcSep,pcLista,vNumElem-1) + nLenSep)
		         
		    otherwise
		         i=at(pcSep,pcLista,pnElemento - 1) + nLenSep
		         j=at(pcSep,pcLista,pnElemento)
		         vElement=subs(pcLista,i,(j - i))
		 endcase
		 
		 if type("pnNumTokens")="N" 
		  pnNumTokens=pnNumTokens - 1
		  if pnElemento + pnNumTokens <= vNumElem
		   for i=1 to pnNumTokens
		    j=this.iToken(pcLista,pnElemento+i,pcSep)
		    vElement=vElement + pcSep + j
		   endfor
		  endif 
		 endif
		 
		 return vElement
	ENDPROC


	*-- Evalua los grupos de salto definidos
	PROCEDURE evalgroups
		lparameters plEOF

		if this.nGroupCount = 0
		 return
		endif


		*-- Se crean los macros definidos
		*
		LOCAL cOnError
		private oThis,lError
		lError=.F.
		
		#IF VERSION(5) < 800
		    cOnError=on("ERROR")
			on error lError=.T.
	    #ENDIF

		oThis=this
		local i,cMacro,cExpr,lIsCalc,k
		local array aLastValues[1,1]
		k=0
		for i=1 to alen(this.aMacros,1)
		 cMacro=this.aMacros[i,1]
		 if vartype(cMacro)<>"C"
		  loop
		 endif
		 cMacro=this.iGetMacroName(cMacro)

		 cExpr=this.aMacros[i,2]
		 lIsCalc=(vartype(cExpr)="C" and atc("oThis.",cExpr)<>0)
		 private (cMacro)
		 if not lIsCalc
		  if vartype(cExpr)="C" 
		   lError=.F.
		   #IF VERSION(5) < 800
		       store eval(cExpr) to &cMacro
		   #ELSE
		       TRY
		          store eval(cExpr) to &cMacro
		       CATCH TO ex
		          lError = .T.
		       ENDTRY
		   #ENDIF
		   if lError
		    store cExpr to &cMacro
		   endif
		  else
		   store cExpr to &cMacro
		  endif
		 else
		  store this.aMacros[i,3] to &cMacro
		 endif
		endfor

        #IF VERSION(5) < 800
			if empty(cOnError)
			 on error
			else
			 on error &cOnError
			endif
		#ENDIF


		*-- Se obtienen los valores actuales para cada grupo
		*
		local i,cExpr,cHEader,cFooter,uResult,uLastResult
		for i=1 to this.nGroupCount
		 cGroup=this.aGroups[i,1]
		 cExpr=this.aGroups[i,2] 
		 cFooter=this.aGroups[i,4] 
		 private (cGroup)

		 if type(cExpr)<>"U"
		  uResult=eval(cExpr)
		 else
		  uResult=cExpr
		 endif

		 this.aGroups[i,6]=uResult
		endfor


		*-- Se cierran los grupos abiertos.
		*
		for i=this.nGroupCount to 1 step -1
		 cGroup=this.aGroups[i,1]
		 cFooter=this.aGroups[i,4] 
		 uLastResult=this.aGroups[i,5]
		 uResult=this.aGroups[i,6]
		 store uLastResult to &cGroup
		 
		 if (not isnull(uLastResult)) and (uResult<>uLastResult or plEOF)
		  this.MoveBack()
		  this.PrintSection(cFooter) 
		  this.MoveNext()
		 endif
		endfor


		*-- Se evaluan los grupos definidos 
		*
		if not plEOF
		 *
		 for i=1 to this.nGroupCount
		  cGroup=this.aGroups[i,1]
		  cHeader=this.aGroups[i,3] 
		  uLastResult=this.aGroups[i,5]
		  uResult=this.aGroups[i,6]
		  store uResult to (cGroup)
		  
		  if isnull(uLastResult) or uResult<>uLastResult
		   this.PrintSection(cHeader) 
		  endif
		  
		  this.aGroups[i,5]=uResult
		 endfor
		 *
		endif
	ENDPROC


	*-- Prepara los grupos definidos
	PROCEDURE startgroups
		local i
		for i=1 to this.nGroupCount
		 this.aGroups[i,5]=NULL
		 this.aGroups[i,6]=NULL 
		endfor
	ENDPROC


	*-- Totaliza los grupos definidos
	PROCEDURE endgroups
		this.EvalGroups(.T.)
	ENDPROC


	*-- Ejecuta un reporte basándose en el alias activo o en el alias indicado.
	PROCEDURE run
		LPARAMETERS puDataSource,pcWhile,pcFor,pnDSID

		#define ST_CURSOR		1
		#define ST_ADORS		2
		#define CRLF			chr(13)+chr(10)

		LOCAL t1,t2,t3,t4,pt,tx,st,et,dt
		t1=seconds()
		st=0
		pt=0
		et=0
		dt=0


		*-- Si no hay un formato cargado, se obvia 
		*
		*   VES Nov 2016: Se valida adicionalmente que no se
		*   haya configurado la propiedad detailString
		if empty(this.PrintFormat) AND EMPTY(this.detailString)
		 return -1
		ENDIF
		
		
		*-- VES Nov 2016
		*   Si no se indico un formato, se genera uno por omision con el contenido
		*   de las propiedades "string"
		*
		IF EMPTY(THIS.printFormat)
			THIS.iAutoFormat()
		ENDIF


		*-- Se ajusta la sesión de datos
		*
		local nCurDSID
		nCurDSID=set("datasession")
		if vartype(pnDSID)="N"
		 set datasession to (pnDSID)
		endif


		*-- Se ejecuta el evento Init (si el mismo existe y no está vacio)
		*
		local lSubReport
		lSubReport=this.SubReport
		if THIS.Events.IsItem("INIT") and (not empty(THIS.Events.Items("INIT").Source))
		 private DPCANCEL,DPDATASOURCE
		 DPCANCEL=.F.
		 DPDATASOURCE=NULL
		 
		 if (not THIS.iRunEvent('INIT')) or DPCANCEL
		  return -1
		 endif 
		 
		 if not isnull(DPDATASOURCE)
		  puDataSource=DPDATASOURCE
		 endif
		endif


		*-- Si está activa la modalidad de subreporte, se restauran ciertas configuraciones que
		*   pudieron ser alteradas en el evento Init del formato.
		*
		if lSubReport
		 THIS.SendToText=.T.
		 THIS.SendToFile=.F.
		 THIS.SendToPrinter=.F.
		 THIS.ShowRunProgress=.F.
		 THIS.SubReport=.T.
		endif 


		*-- Se determina el tipo de fuente de datos
		*  
		*   VES Nov 2016: Se movio el codigo a un metodo reusable
		IF !THIS.isetDataSource(puDataSource)
			RETURN -1
		ENDIF
		

		*-- Se crea el archivo de salida (si no se ha indicado)
		*
		local fh
		if empty(THIS.cOutFile)
		 THIS.cOutFile=THIS.iGenOutFile()
		endif 
		set printer to
		fh=fcreate(this.cOutFile)
		=fclose(fh)
		set printer to (this.cOutFile)


		*-- Se eliminan las variables de totalización creadas
		*
		if vartype(ICALCS_VAR_LIST)<>"U"
		 local nCount,cVar
		 nCount=occurs(",",ICALCS_VAR_LIST) + 1
		 for i=1 to nCount
		  cVar=this.iToken(ICALCS_VAR_LIST,i,",")
		  if not empty(cVar)
		   release (cVar)
		  endif
		 endfor
		 ICALCS_VAR_LIST=""
		endif


		*-- Se inicializan algunas propiedades 
		*
		this.nPL=0
		this.PageNo=1
		this.PageGen=0
		this.SetMacroValue("PAGENO",alltrim(str(This.PageNo)))
		THIS.EOF=.F.


		*-- Se inicializa el informe
		*
		if this.ShowRunProgress
		 this.iShowProgress(0)
		endif 
		if (not empty(this.RunCallBack))
		 this.CallRunCallBack(1,0)
		endif 
		this.StartGroups()
		if this.SectionHeight("TITLE") > 0
		 this.PrintSection("TITLE",,(NOT THIS.PrintHeaderOnTitle))
		 if this.AutoEject and this.EjectAfterTitle
		  * (VES 17/2/07) Si se indico PrintFooterOnTitle, se invoca a Eject(); de lo contario a RawEject()
		  IF THIS.PrintFooterOnTitle
		   this.Eject()
		  ELSE
		   THIS.RawEject()
		  ENDIF 
		 endif
		endif


		*-- Se recorre el origen de datos.
		*
		t3=seconds()
		do case
		   case THIS.SourceType=ST_CURSOR             && Cursor, tabla o vista VFP
				select (THIS.WorkArea)
				if not empty(dbf())
				 go top
				 scan while (empty(pcWhile) or eval(pcWhile)) for (empty(pcFor) or eval(pcFor))
				  tx=seconds()
				  this.PrintSection("DETAIL")
				  pt=pt + (seconds() - tx)
				  select (THIS.WorkArea)
				 endscan
				endif 

		   case THIS.SourceType=ST_ADORS and (not oRS.EOF)      && RecordSet ADO
		        *-- Se declaran las variables de columna. Se aprovecha el ciclo para crear un 
		        *   pequeño PRG que servirá para hacer las asignaciones en cada registro
		        *
		        local nCol,cColName,cSetPRG,cCode
		        cSetPRG=forceext(this.cOutFile,"PRG")
		        cCode=""
		        tx=seconds()
		        for nCol=1 to oRS.Fields.Count
		         cColName=CHRT(oRS.Fields.Item(nCol - 1).Name," ","")
		         private (cColName)
		         store "" to (cColName)

		         if not this.ShowNullValues
		          store nvl(oRS.Fields.Item(nCol - 1).Value,"") to (cColName)
		         else
		          store oRS.Fields.Item(nCol - 1).Value to (cColName)           
		         endif 
		         
		         cCode=cCode + ;
		               cColName+"={X1}oFieldData.Item("+allt(str(nCol-1))+").Value{X2}" + CRLF 
		        endfor
		        dt=seconds() - tx
		        cCode="IF lShowNullValues" + CRLF + ;
		              STRT(STRT(cCode,"{X1}",""),"{X2}","") + CRLF + ;
		              "ELSE" + CRLF + ;
		              STRT(STRT(cCode,"{X1}","NVL("),"{X2}",",'')") + CRLF + ;              
		              "ENDIF" + CRLF
		        strtofile(cCode,cSetPRG)
		        compile (cSetPRG)
		        erase (cSetPRG)
		        cSetPRG=forceext(this.cOutFile,"FXP")        
		        
		        
		        *-- Se recorre el origen de datos
		        *
		        private oFieldData,lShowNullValues
		        lShowNullValues=THIS.ShowNullValues
		        
		        select (THIS.WorkArea)
		        oRS.MoveFirst()
		        et=0
		        do while not oRS.EOF
		         tx=seconds()
		         oFieldData=oRS.Fields
		         do (cSetPRG)
		         et=et + (seconds() - tx)
		         tx=seconds()
		         this.PrintSection("DETAIL")
		         pt=pt + (seconds() - tx)
		         oRS.MoveNext()
		        enddo
		        erase (cSetPRG)

		   case THIS.SourceType=ST_ADORS and oRS.EOF

		endcase
		   

		*-- Se cierra el informe
		*
		THIS.EOF=.T.
		do case
		   case THIS.SourceType=ST_CURSOR
				select (THIS.WorkArea)
				if not empty(dbf())
				 this.EndGroups()
				endif 

		   case THIS.SourceType=ST_ADORS and not oRS.BOF
		        oRS.MoveLast()
		        this.EndGroups()

		endcase   
		st=(seconds() - t3) - (pt + et)

		if this.AutoEject
		 if this.SectionHeight("SUMMARY") > 0
		  if this.EjectBeforeSummary
		   this.Eject()
		  endif
		  this.PrintSection("SUMMARY",,(NOT THIS.PrintHeaderOnSummary))
		 endif
		 if this.nPL > 0
		  * (VES 17/2/07) Si se indico PrintFooterOnSummary, se invoca a Eject(); de lo contrario a RawEject()
		  IF THIS.PrintFooterOnSummary
		   this.Eject()
		  ELSE
		   THIS.RawEject()
		  ENDIF
		 endif
		else
		 this.PrintSection("FOOTER")
		 this.PrintSection("SUMMARY")
		endif


		*-- Se define el valor de PAGECNT y se sustituye en el informe
		*
		private PAGECNT
		PAGECNT=THIS.PageNo - 1
		THIS.iResolvePageCnt(PAGECNT)

		if this.ShowRunProgress
		 this.iShowProgress(PAGECNT)
		 this.oProgressForm.Release()
		 this.oProgressForm=NULL
		endif

		if (not empty(this.RunCallBack))
		 this.CallRunCallBack(3,PAGECNT)
		endif 


		*-- Si se activaron las propiedades SendTo?, se procesan
		*
		do case
		   case this.SendToPrinter and not empty(this.PrinterName)
		        this.Print(this.PrinterName)
		        
		   case this.SendToFile and not empty(this.FileName)
		        this.PrintToFile(this.FileName)
		        
		   case this.SendToText
		        private DPRESULT
		        DPRESULT=THIS.PrintToText()     
		endcase


		*-- Se ejecuta el evento CLOSE
		*
		if THIS.Events.IsItem("CLOSE") and (not empty(THIS.Events.Items("CLOSE").Source))
		 THIS.iRunEvent('CLOSE')
		endif


		*-- Se restaura la sesion
		*
		set datasession to (nCurDSID)


		t2=seconds() - t1
		this.Log="Scan time: "+allt(str(st,20,6))+"s" + chr(13)+chr(10)+;
		         "Print time: "+allt(str(pt,20,6))+"s" + chr(13)+chr(10)+;
		         "Define time: "+allt(str(dt,20,6))+"s" + chr(13)+chr(10)+;
		         "Eval time: "+allt(str(et,20,6))+"s" + chr(13)+chr(10)+;
		         "Total time: "+allt(str(t2,20,6))+"s" + chr(13)+chr(10)


		*-- Si se indicó SendToText, se devuelve el valor de DPRESULT
		*
		if THIS.SendToText
		 RETURN DPRESULT
		else
		 RETURN PAGECNT 
		endif 
	ENDPROC


	*-- VES Nov 2016
	*   Auto configurar el formato de impresion en base a las propiedades string
	*
	HIDDEN PROCEDURE iAutoFormat
		    THIS.Sections.Add( THIS.newSection("TITLE", THIS.titleString) )
		 	THIS.Sections.Add( THIS.newSection("HEADER", THIS.headerString) )
		 	THIS.Sections.Add( THIS.newSection("DETAIL", THIS.detailString) )
		 	THIS.Sections.Add( THIS.newSection("FOOTER", THIS.footerString) )
		 	THIS.Sections.Add( THIS.newSection("SUMMARY", THIS.summaryString) )
	ENDPROC
	
	
	*-- VES Nov 2016
	*   Se auto configura la fuente de datos
	*
	HIDDEN PROCEDURE iSetDataSource(puDataSource)
		local nSourceType,cCursorAlias,oRS
		nSourceType=0
		do case
		   case vartype(puDataSource)="C" and used(puDataSource)    && VFP Cursor
		        nSourceType=ST_CURSOR
		        cCursorAlias=puDataSource
		        select (cCursorAlias)
		        
		   case type("puDataSource")="O"               && ADO RecordSet
		        nSourceType=ST_ADORS
		        oRS=puDataSource
		        
		   otherwise
		        nSourceType=ST_CURSOR
		        puDataSource=alias()
		        cCursorAlias=alias()
		endcase
		if nSourceType=0
		 return .F.
		endif

		THIS.WorkArea=select()

		THIS.SourceType=nSourceType
		THIS.DataSource=puDataSource	
	ENDPROC
		

	*-- Realiza un cálculo indicado.
	PROCEDURE idocalc
		lparameters pcCalc,pcName,pcExpr,pcResetAt,pcStartExpr
		 *
		 *-- Se ajustan algunos parámetros
		 *
		 pcCalc=allt(upper(pcCalc))
		 pcCalc=iif(inlist(pcCalc,"SUM","COUNT","MIN","MAX","AVG"),pcCalc,"SUM")
		 pcExpr=iif(vartype(pcExpr)="C" and type(pcExpr) $ "NY",pcExpr,"0.0")
		 pcResetAt=iif(vartype(pcResetAt)="C",iif(empty(pcResetAt),"''",pcResetAt),".T.")
		 pcStartExpr=iif(vartype(pcStartExpr)="C" and type(pcStartExpr) $ "NY",pcStartExpr,"0.0")
		 
		 *-- Se crea la variable que contiene la lista de variables de totalizacion almacenadas
		 *
		 if vartype(ICALCS_VAR_LIST)="U"
		  public ICALCS_VAR_LIST
		  ICALCS_VAR_LIST=""
		 endif
		 
		 
		 *-- Se crean algunas constantes
		 *
		 private PAGENO
		 PAGENO=this.PageNo
		 
		 
		 *-- Se define la variable de totalización y la de reset
		 *
		 local cBufVar,cResetVar
		 cBufVar="ICALC_"+allt(pcName)+"_BUF"
		 cResetVar="ICALC_"+allt(pcName)+"_RST"
		 if type(cBufVar)="U"
		  public (cBufVar)
		  store eval(pcStartExpr) to (cBufVar)
		  ICALCS_VAR_LIST=ICALCS_VAR_LIST + "," + cBufVar
		 endif
		 if type(cResetVar)="U"
		  public (cResetVar)
		  store eval(pcResetAt) to (cResetVar)
		  ICALCS_VAR_LIST=ICALCS_VAR_LIST + "," + cResetVar  
		 endif
		 
		  
		 *-- Si hay ruptura de control, se inicializa el buffer
		 *
		 local cReset
		 cReset=eval(pcResetAt)
		 if cReset<>eval(cResetVar)
		  store eval(pcStartExpr) to (cBufVar)
		  store cReset to (cResetVar)
		 endif
		 
		 *-- Se realiza el cálculo
		 *
		 local nBuf,nBuf0,nBuf1
		 nBuf0=eval(pcExpr)
		 do case
		    case pcCalc=="SUM"
		         nBuf0=iif(vartype(nBuf0)="N",nBuf0,0.0)
		         nBuf=eval(cBufVar) + nBuf0
		         store nBuf to (cBufVar)
		         
		    case pcCalc=="COUNT"
		         nBuf=eval(cBufVar) + 1
		         store nBuf to (cBufVar)

		    case pcCalc=="MIN"
		         nBuf1=eval(cBufVar)
		         if vartype(nBuf1)=vartype(nBuf0)
		          nBuf=min(nBuf1,nBuf0)
		          store nBuf to (cBufVar)
		         endif 
		        
		    case pcCalc=="MAX"
		         nBuf1=eval(cBufVar)
		         if vartype(nBuf1)=vartype(nBuf0)
		          nBuf=max(nBuf1,nBuf0)
		          store nBuf to (cBufVar)
		         endif 
		         
		    case pcCalc=="AVG"
		         if vartype(nBuf0)="N"
		          nBuf=(eval(cBufVar) + nBuf0) / 2
		          store nBuf to (cBufVar)
		         endif 
		          
		 endcase         
		 
		 return nBuf
	ENDPROC


	*-- Devuelve la altura en lineas de una sección
	PROCEDURE sectionheight
		lparameters pcSection


		local cData,nHeight
		local array foo[1]
		if not this.Sections.IsItem(pcSection)
		 this.Sections.Add( this.LoadFormatSection(pcSection) )
		endif
		cData=this.Sections.Items(pcSection).Text

		if not (empty(cData) and memlines(cData)=0)
		 nHeight=alines(foo,cData)
		else
		 nHeight=0
		endif


		RETURN nHeight
	ENDPROC


	PROCEDURE macros_access
		LPARAMETERS m.nIndex1, m.nIndex2

		RETURN this.aMacros[m.nIndex1, m.nIndex2]
	ENDPROC


	PROCEDURE macros_assign
		LPARAMETERS vNewVal, m.nIndex1, m.nIndex2
	ENDPROC


	*-- Copia el informe generado en una cadena y la devuelve.
	PROCEDURE printtotext
		LPARAMETERS nCopies,pnFromPage,pnToPage

		if empty(this.cOutFile)
		 return .F.
		endif



		*-- Se determina la cantidad de copias
		*
		if vartype(nCopies)<>"N" or nCopies < 1
		 nCopies=THIS.Copies
		endif


		*-- Se cierra el archivo temporal de salida
		*
		set printer to


		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se obtiene el texto a imprimir.
		*
		LOCAL cOutFile
		cOutFile = THIS.cOutFile
		IF VARTYPE(pnFromPage)="N"
		 cOutFile = THIS.iPrintPageRange(pnFromPage,pnToPage)
		ENDIF
		*-- 13/Julio/2007


		*-- Se genera la salida y se coloca en una variable tipo texto.
		*
		*   VES 13/Julio/2007
		*   Se cambio el uso directo de THIS.cOutfile por el de la variable local cOutFile para
		*   soportar la impresion por rango de paginas
		*
		local cData,cText
		cData=filetostr(cOutfile)
		if nCopies = 1
		 cText=cData
		else
		 cText=""
		 for i=1 to nCopies
		  cText = cText + cData
		 endfor
		endif


		*-- Se restaura la salida al archivo temporal
		*
		set printer to (this.cOutFile) additive


		*-- VES 13/Julio/2007
		*   Si se indico un rango de paginas, se elimina el archivo temporal
		*   creado con el rango de paginas a imprimir
		*
		IF VARTYPE(pnFromPage)="N"
		 ERASE (cOutFile)
		ENDIF
		 


		*-- Se devuelve el texto del informe
		*
		return cText 
	ENDPROC


	*-- Permite alterar el valor actual de una macro dada.
	PROCEDURE setmacrovalue
		lparameters pcMacro,puValor

		local i,nCount
		nCount=alen(this.aMacros,1)

		pcMacro=upper(pcMacro)
		if left(pcMacro,1)<>"$"
		 pcMacro="$" + pcMacro
		endif
		if right(pcMacro,1)<>"$"
		 pcMacro=pcMacro + "$"
		endif

		for i=1 to nCount
		 if vartype(this.aMacros[i,1])="C"
		  if this.aMacros[i,1]==pcMacro
		   this.aMacros[i,3]=puValor   
		   exit
		  endif 
		 endif
		endfor
	ENDPROC


	*-- Devuelve un objeto tipo vdpSection con la información de la sección indicada.
	PROCEDURE loadformatsection
		LPARAMETERS pcSection
		 *
		 if empty(this.PrintFormat)
		  return NULL
		 endif
		 
		 local array aText[1]
		 local nCount,i,lInSection,cData,cOpenTag,cCloseTag,oSection,cTagHdr,oTagOptions,oMacro,cExpr
		 nCount=alines(aText,this.PrintFormatData)
		 pcSection=upper(allt(pcSection))
		 cOpenTag=this.SectionBeginMark + pcSection
		 cCloseTag=this.SectionBeginMark + "/" + pcSection + this.SectionEndMark 
		 cData=""
		 oSection=THIS.New("Section")
		 oSection.Name=pcSection
		 oSection.Type=pcSection
		 
		 lInSection=.F.
		 
		 for i=1 to nCount
		  *
		  do case
		     case left(aText[i],1)="#" and not ("#EXEC " $ upper(aText[i]) or "#SUBREP " $ upper(aText[i]) or "#SET " $ upper(aText[i]))
		          loop
		          
		     case "#SET " $ upper(aText[i])
		          cExpr=subs(aText[i],6)
		          oMacro=THIS.New("SectionMacro")
		          oMacro.Name=left(cExpr,at("=",cExpr)-1)
		          oMacro.Expr=subs(cExpr,at("=",cExpr)+1)
		          oSection.Macros.Add(oMacro)
		          loop
		  
		     case (not lInSection) and left(allt(upper(aText[i])),len(cOpenTag))==cOpenTag
		          cTagHdr=allt(subs(aText[i],len(cOpenTag)+1))                         && Se elimina el inicio del tag
		          cTagHdr=allt(subs(cTagHdr,1,len(cTagHdr)-len(this.SectionEndMark)))  && Se elimina el final del tag
		          oTagOptions=THIS.ReadTagOptions(cTagHdr)
		          if type("oTagOptions.Type")="C"
		           oSection.Type=oTagOptions.Type
		          endif
		          if type("oTagOptions.ApplyIf")="C"
		           oSection.ApplyIf=oTagOptions.ApplyIf
		          endif
		          if type("oTagOptions.IntegralHeight")="C"
		           oSection.IntegralHeight=(inlist(upper(oTagOptions.IntegralHeight),"YES","SI","TRUE",".T."))
		          endif
		          if type("oTagOptions.PrintOnNewPage")="C"
		           oSection.PrintOnNewPage=(inlist(upper(oTagOptions.PrintOnNewPage),"YES","SI","TRUE",".T."))
		          endif
		          if type("oTagOptions.PrintIfBlank")="C"
		           oSection.PrintIfBlank=(inlist(upper(oTagOptions.PrintIfBlank),"YES","SI","TRUE",".T."))
		          endif
		          if type("oTagOptions.StartOnNewPage")="C"
		           oSection.StartOnNewPage=(inlist(upper(oTagOptions.StartOnNewPage),"YES","SI","TRUE",".T."))
		          endif
		          if type("oTagOptions.ResetPageCounter")="C"
		           oSection.ResetPageCounter=(inlist(upper(oTagOptions.ResetPageCounter),"YES","SI","TRUE",".T."))
		          endif
		          if type("oTagOptions.BandHeight")="N"
		           oSection.BandHeight=int(val(oTagOptions.BandHeight))
		          endif
		          lInSection=.T.
		          loop
		          
		     case lInSection and allt(upper(aText[i]))==cCloseTag
		          lInSection=.F.
		          exit
		          
		     case lInSection
		          if "//" $ aText[i]
		           aText[i]=left(aText[i],at("//",aText[i])-1)
		          endif
		          cData=cData + aText[i] + CHR(13) + CHR(10)
		  endcase         
		  *
		 endfor
		 oSection.Text=cData
		 if inlist(pcSection,"INIT","CLOSE")
		  oSection.Type="EVENT"
		 endif
		 oSection.Type=UPPER(oSection.Type)
		 
		 if upper(oSection.Type)="EVENT"
		  local oEvent
		  oEvent=THIS.New("Event")
		  oEvent.Name=oSection.Name
		  oEvent.Source=oSection.Text
		  oSection=oEvent
		 endif 
		 
		 return oSection
	ENDPROC


    * VES Nov 2016
    * Crea una nueva seccion manualmente
    *
	PROCEDURE newSection(pcSection, pcText)
		LOCAL oSection
		oSection=THIS.New("Section")
		oSection.Name=pcSection
		oSection.Type=pcSection
		oSection.Text = pcText
		RETURN oSection
	ENDPROC 


	*-- DEvuelve un objeto con las propiedades indicadas dentro de un Tag
	PROCEDURE readtagoptions
		LPARAMETERS pcTagOptions
		 *
		 local oOptions,n
		 oOptions=create("line")


		 *-- Se recorre la cadena pcTagOptions para cambiar los caracteres "=" que no esten
		 *   encerrados en algun "bloque" (ej: (..=..), '..=..', "..=..") por el car. "|". Esto
		 *   permitirá identificar apropiadamente los pares PROP=VALUE que esten contenidos
		 *   en la cadena pcTagOptions.
		 *   
		 local i,nCount,nBlockDeepth,cChar,lSingleQuoteOpen,lDoubleQuoteOpen
		 nCount=len(pcTagOptions)
		 nBlockDeepth=0
		 lSingleQuoteOpen=.F.
		 lDoubleQuoteOpen=.F.
		 for i=1 to nCount
		  cChar=subs(pcTagOptions,i,1)
		  
		  do case
		     case inlist(cChar,"(","{","[")
		          nBlockDeepth=nBlockDeepth + 1
		          
		     case inlist(cChar,[']) and (not lSingleQuoteOpen)
		          nBlockDeepth=nBlockDeepth + 1
		          lSingleQuoteOpen=.T.
		          
		     case inlist(cChar,["]) and (not lDoubleQuoteOpen)
		          nBlockDeepth=nBlockDeepth + 1
		          lDoubleQuoteOpen=.T.
		          
		     case inlist(cChar,")","}","]") and nBlockDeepth > 0
		          nBlockDeepth=nBlockDeepth - 1
		          
		     case inlist(cChar,")",[']) and nBlockDeepth > 0 and lSingleQuoteOpen
		          nBlockDeepth=nBlockDeepth - 1
		          lSingleQuoteOpen=.F.
		          
		     case inlist(cChar,")",["]) and nBlockDeepth > 0 and lDoubleQuoteOpen
		          nBlockDeepth=nBlockDeepth - 1
		          lDoubleQuoteOpen=.F.
		          
		     case cChar="=" and nBlockDeepth <= 0
		          pcTagOptions=stuff(pcTagOptions,i,1,"|")
		          
		     case cChar="=" and nBlockDeepth > 0
		          * Nothing
		  endcase         
		 endfor


		 *-- Se procesan todas las apariciones del caracter "|"
		 *
		 local cProp,cValue,nPos,cData,j
		 cData=pcTagOptions
		 nCount=occurs("|",cData)
		 for i=1 to nCount
		  *
		  nPos=at("|",cData)
		  cProp=allt(left(cData,nPos - 1))
		  cValue=subs(cData,nPos + 1)
		  
		  if i < nCount
		   nPos=at("|",cValue)
		   j=nPos - 1
		   do while j>1 and not empty(subs(cValue,j,1))
		    j=j - 1
		   enddo
		   if j>1
		    cData=subs(cValue,j+1)
		    cValue=allt(left(cValue,j))
		   endif
		  endif 
		  
		  oOptions.AddProperty(cProp,cValue)
		  *
		 endfor
		 
		 
		 return oOptions
	ENDPROC


	*-- Evalua la expresion indicada, tomando en cuenta los macros definidos.
	PROCEDURE checkexpr
		lparameters pcExpr,plDoCalcs

		private oThis,DP,DPEOF,lERror
		oThis=this
		DP=this
		DPEOF=this.EOF
		local i,cMacro,cExpr,lIsCalc,cOnERror
		
		#IF VERSION(5) < 800
			cOnError=on("ERROR")
			on error lError=.T.
		#ENDIF

		for i=1 to alen(this.aMacros,1)
		 *
		 cMacro=this.aMacros[i,1]
		 cMacro=this.iGetMacroName(cMacro)
		 cExpr=this.aMacros[i,2]
		 lIsCalc=(vartype(cExpr)="C" and (atc("oThis.",cExpr)<>0 or atc("DP.",cExpr)<>0))
		 
		 if (not lIsCalc) or plDoCalcs 
		  private (cMacro)
		  if vartype(cExpr)="C" 
		   cExpr=this.STRExpand(cExpr)
		   lError=.F.
		   #IF VERSION(5) < 800
			   store eval(cExpr) to (cMacro)
		   #ELSE
		       TRY
		           store eval(cExpr) to (cMacro)
		       CATCH TO ex
		           lError = .T.
		       ENDTRY
		   #ENDIF
		   if lError
		    store cExpr to (cMacro)
		   endif

		  else
		   store cExpr to (cMacro)
		  endif
		  if lIsCalc
		   this.aMacros[i,3]=eval(cMacro)
		  endif
		 else
		  store this.aMacros[i,3] to (cMacro)
		 endif
		 *
		endfor

		local lResult
		
		#IF VERSION(5) < 800
			lError=.F.
			lResult=eval(pcExpr)
			if lError
			 lResult=.F.
			endif

			if not empty(cOnError)
			 on error &cOnError
			else
			 on error 
			endif		
		#ELSE
			TRY
				lResult=eval(pcExpr)
			CATCH TO ex
				lResult = .F.
			ENDTRY
		#ENDIF

		return lResult
	ENDPROC


	*-- Devuelve una colección con los nombres de las secciones definidas.
	PROCEDURE getformatsectionlist
		 local oList
		 oList=this.New("Collection")
		 if empty(this.PrintFormat) or empty(this.PrintFormatData)
		  return oList
		 endif
		 
		 local array aText[1]
		 local nCount,i,lInSection,cSectionName,cCloseTag
		 nCount=alines(aText,this.PrintFormatData)
		 lInSection=.F.
		 cSectionName=""
		 cCloseTag=""
		 
		 for i=1 to nCount
		  *
		  do case
		     case left(aText[i],1)="#" and not ("#EXEC " $ upper(aText[i]) or "#SUBREP " $ upper(aText[i]))
		          loop
		  
		     case (not lInSection) and left(allt(upper(aText[i])),len(THIS.SectionBeginMark))==THIS.SectionBeginMark
		          cSectionName=subs(allt(upper(aText[i])),len(THIS.SectionBeginMark)+1)
		          if at(" ",cSectionName)<>0
		           cSectionName=left(cSectionName,at(" ",cSectionName)-1)
		          else
		           cSectionName=subs(cSectionName,1,len(cSectionName)-len(this.SectionEndMark))
		          endif  
		          cCloseTag=THIS.SectionBeginMark+"/"+cSectionName+this.SectionEndMark
		          if not inlist(cSectionName,"CONFIG","MACROS","GROUPS")
		           oList.Add(cSectionName)
		          endif 
		          lInSection=.T.
		          loop
		          
		     case lInSection and allt(chrt(upper(aText[i])," ",""))==cCloseTag
		          lInSection=.F.
		          loop
		          
		  endcase         
		  *
		 endfor
		 
		 *
		 return oList
	ENDPROC


	*-- Ejecuta un informe basada en el formato indicado.
	PROCEDURE runformat
		LPARAMETERS pcFormat,pcAlias,pnPrintTo,pcPrinter,pcWhile,pcFor,pnDSID

		local uResult
		THIS.PrintFormat=pcFormat
		uResult=THIS.Run(pcAlias,pcWhile,pcFor,pnDSID)

		if THIS.SendToPrinter or THIS.SendToFile or THIS.SendToText
		 this.SetPrintOff()
		 set printer to
		 return uResult
		endif

		do case
		   case vartype(pnPrintTo)<>"N" or pnPrintTo=1
		        THIS.Print(pcPrinter)
		        
		   case pnPrintTo=2
		        THIS.PrintToFile(pcPrinter)
		        
		   otherwise
		        RETURN THIS.PrintToText()
		endcase
	ENDPROC


	*-- Envia el texto indicado directamente a la impresora indicada.
	PROCEDURE sendtexttoprinter
		LPARAMETERS cText,cPrinterName,cJobName

		*-- Se crea el archivo de salida
		*
		local cOutFile
		cOutFile=this.iGenOutFile()
		strtofile(cText,cOutFile)

		THIS.SendFileToPrinter(cOutFile,cPrinterName,cJobName)

		erase (cOutFile)
		 
	ENDPROC


	PROCEDURE cdocname_access

		RETURN THIS.PrintJobName
	ENDPROC


	PROCEDURE cdocname_assign
		LPARAMETERS vNewVal

		THIS.PrintJobname = m.vNewVal
	ENDPROC


	*-- Envia el contenido de un archivo de texto dado a la impresora dada.
	PROCEDURE sendfiletoprinter
		LPARAMETERS cFile,cPrinterName,cJobName

		*-- Se instancia la clase PrintDev
		*
		local oPDev,cLcDoc
		oPDev=THIS.New("PrintDev")
		if vartype(cPrinterName)="C"
		 oPDev.cPrinterName=cPrinterName
		endif


		**** Agregado por Esparta 27/08/2001
		**** Para incluir el nombre del documento en la cola de impresión
		oPDev.cDocName  = iif(type('cJobName')='C',cJobName,'Documento VFP DosPrint')

		if not oPDev.oOpen()
		 return .F.
		endif

		set printer to
		oPDev.cFileName=cFile
		oPDev.oPrintFile()
		oPDev.oClose()
		set printer to (this.cOutFile) additive
		 
	ENDPROC


	*-- Ejecuta el método indicado en la propiedad RunCallBack
	HIDDEN PROCEDURE callruncallback
		lparameters pnModo,pnPageNo

		local cCmd
		cCmd=THIS.RunCallBack + "(pnModo,pnPageNo)"
		&cCmd
	ENDPROC


	*-- Procesa la sección FORMAT.
	HIDDEN PROCEDURE iprocessformatsection
		#DEFINE CRLF		chr(13)+chr(10)

		*-- Se define la lista de secciones predefinidas
		*
		private TI,HE,DE,FO,SU
		TI="TITLE"
		HE="HEADER"
		DE="DETAIL"
		FO="FOOTER"
		SU="SUMMARY"


		*-- Se toma el texto de la sección FORMAT y se divide en lineas 
		*
		local array aLins[1]
		local nCount
		nCount=alines(aLins,THIS.Sections.Items("FORMAT").Text)

		*-- Se recorren las lineas y se van armando las diferentes secciones
		*
		local nLin,cSection,cText,cLin,oSection
		for nLin=1 to nCount
		 *
		 cLin=aLins[nLin]
		 if left(cLin,1)="#" or at(":",cLin)=0
		  loop
		 endif
		 
		 cSection=alltrim(upper(left(cLin,at(":",cLin)-1)))
		 cText=subs(cLin,at(":",cLin)+2)
		 if inlist(cSection,"TI","HE","DE","FO","SU")
		  cSection=eval(cSection)
		 endif
		 
		 if THIS.Sections.IsItem(cSection)
		  oSection=THIS.Sections.Items(cSection)
		 else
		  oSection=THIS.New("Section")
		  oSection.Name=cSection
		  oSection.Type=cSection
		  THIS.Sections.Add(oSection)
		 endif 
		 
		 if len(oSection.Text)=0
		  oSection.Text=iif(empty(cText)," ",cText)
		 else
		  oSection.Text=oSection.Text + CRLF + cText
		 endif
		 *
		endfor
	ENDPROC


	*-- Devuelve una nueva instancia de la clase indicada.
	*   
	*   VES Nov 2016
	*   Se incluyo la posibilidad de pasar parametros al constructor de la clase
	*
	PROCEDURE new
		lparameters pcClass,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10

		local oRef,cClass
		pcClass=upper(allt(pcClass))
		oRef=NULL
		cClass=""

		do case
		   case pcClass=="SECTION"
		        cClass="vdpSection"
		        
		   case pcClass=="VFPDOSPRINT"
		        cClass="VFPDOSPrint"
		        
		   case pcClass=="COLLECTION"
		        cClass="vdpBasicCollection"
		        
		   case pcClass=="SECTIONMACRO"
		        cClass="vdpSectionMacro"
		        
		   case pcClass=="EVENT"
		        cClass="vdpEvent"
		        
		   case pcClass=="PRINTDEV"
		        cClass="PrintDev"     
		        
		endcase

		IF PCOUNT() = 1   && No hay parametros adicionales?
			if !empty(cClass)
			 oRef = NEWOBJECT(cClass, "vdp.prg")
			else
			 oRef = CREATEOBJECT(pcClass)
			ENDIF
 		ELSE
 			LOCAL cCmd
			if !empty(cClass)
			 cCmd = [NEWOBJECT('] + cClass + [', "vdp.prg",""]
			else
			 cCmd = [CREATEOBJECT('] + pcClass + [']
			ENDIF
			LOCAL p
			FOR p = 1 TO PCOUNT() - 1
			 cCmd = cCmd + ",p"+ ALLTRIM(STR(p))
			ENDFOR
			cCmd = cCmd + ")"
			oRef = EVALUATE(cCmd) 			
 		ENDIF			
		 
		return oRef
	ENDPROC


	*-- Ejecuta un evento
	PROCEDURE irunevent
		lparameters pcEvent

		#DEFINE CRLF		chr(13)+chr(10)
		#DEFINE MB_ICONSTOP             16      && Critical message


		*-- Si el evento indicado no existe, se cancela
		*
		local oEvent
		if not THIS.Events.IsItem(pcEvent)
		 return .T.
		endif
		oEvent=THIS.Events.Items(pcEvent)


		*-- Si el evento no ha sido compilado, se compila
		*
		if empty(oEvent.Object)
		 *
		 *-- Se obtiene el texto del evento
		 local cCode
		 cCode=oEvent.Source

		 *-- Se obtiene un archivo temporal .PRG
		 local cPRG,cFXP,cERR,cCurFolder
		 cPRG=""
		 cCurFolder=set("default")+curdir()
		 do while empty(cPRG) or file(cPRG)
		  cPRG=cCurFolder + sys(3)+".PRG"
		 enddo
		 cFXP=forceext(cPRG,"FXP")
		 cERR=forceext(cPRG,"ERR")

		 *-- Se genera el PRG y se compila. Si se encuentran errores, se cancela
		 if file(cERR)
		  erase (cERR)
		 endif 
		 strtofile(cCode,cPRG)
		 compile (cPRG)
		 if file(cERR)
		  erase (cPRG)
		  erase (cFXP)
		  messagebox("Se encontraron los siguientes errores en el evento Init del formato "+;
		             upper(THIS.PrintFormat)+":"+CRLF+CRLF+filetostr(cERR),MB_ICONSTOP,"VFPDosPrint")
		  erase (cERR)            
		  return .F.
		 endif 
		 oEvent.Object=filetostr(cFXP)
		 erase (cPRG)
		 erase (cFXP)
		 *
		endif


		*-- Se obtiene un archivo temporal .FXP
		*
		local cFXP,cCurFolder
		cFXP=""
		cCurFolder=set("default")+curdir()
		do while empty(cFXP) or file(cFXP)
		 cFXP=cCurFolder + sys(3)+".FXP"
		enddo
		strtofile(oEvent.Object,cFXP)


		*-- Se ejecuta el evento
		*
		PRIVATE DP,DPRESULT,TRUE,FALSE
		DP=THIS
		DPRESULT=.T.
		TRUE=.T.
		FALSE=.F.

		do (cFXP)


		*-- Se eliminan los archivos creados
		*
		erase (cFXP)

		return DPRESULT
	ENDPROC


	*-- Ejecuta un evento contenido en el formato.
	PROCEDURE callevent
		lparameters pcEvent,pu0,pu1,pu2,pu3,pu4,pu5,pu6,pu7,pu8,pu9,pu10


		*-- Si el evento no existe, se cancela
		*
		if not this.Events.IsItem(pcEvent)
		 return ""
		endif


		*-- Se toman los argumentos pasados al evento
		*
		private DPArg0,DPArg1,DPArg2,DPArg3,DPArg4,DPArg5,DPArg6,DPArg7,DPArg8,DPArh9,DPArg10
		DPArg0=pu0
		DPArg1=pu1
		DPArg2=pu2
		DPArg3=pu3
		DPArg4=pu4
		DPArg5=pu5
		DPArg6=pu6
		DPArg7=pu7
		DPArg8=pu8
		DPArg9=pu9
		DPArg10=pu10


		*-- Se ejecuta el evento y se devuelve su resultado
		*
		return this.iRunEvent(pcEvent)
	ENDPROC


	*-- Ejecuta un formato dado y devuelve el resultado en forma de texto.
	PROCEDURE callsubreport
		lparameters pcFormat


		*-- Se obtiene otra instancia de DP y se configura
		*
		local oDP,cResult
		oDP=THIS.New("VFPDosPrint")
		oDP.PrintFormat=pcFormat
		oDP.SubReport=.T.


		*-- Se cancela la impresión actual, para asi poder cerrar el archivo de salida actual
		*
		THIS.SetPrintOff()
		set printer to


		*-- Se ejecuta el subreporte y se obtiene el resultado en forma de cadena. Una vez
		*   finalizado el proceso, se libera la instancia temporal de DP.
		*
		select 0
		cResult=oDP.Run()
		release oDP
		 
		 
		*-- Se restaura el archivo temporal de salida 
		*
		set printer to (this.cOutFile) additive
		THIS.SetPrintOn()

		select (THIS.WorkArea)


		*-- Se devuelve el texto del subreporte
		*
		return cResult
	ENDPROC


	*-- Muestra el avance del proceso
	HIDDEN PROCEDURE ishowprogress
		lparameters pnPageCnt


		*-- Se define la variable PageCnt y CRLF
		*
		private PageCnt,PageGen,CR
		PageCnt=pnPageCnt
		PageGen=this.PageGen
		CR=chr(13)+chr(10)

		*-- Se obtiene el mensaje a mostrar
		*
		local cMsg
		cMsg=this.STRExpand(this.RunProgressMessage)


		*-- Si no se ha instanciado la ventana de avance, se instancia
		*
		local oProgressForm
		if isnull(this.oProgressForm)
		 oProgressForm = NEWOBJECT("VDPProgress", "vdp.prg")
		 this.oProgressForm=oProgressForm
		else
		 oProgressForm=this.oProgressForm 
		endif


		*-- Si la ventana de avance no está visible, se muestra 
		*
		if not oProgressForm.Visible
		 oProgressForm.Show()
		endif


		*-- Se actualiza el mensaje de la ventana
		*
		oProgressForm.lblMessage.Caption=cMsg
	ENDPROC


	HIDDEN PROCEDURE version_assign
		LPARAMETERS vNewVal
	ENDPROC


	*-- Genera un archivo temporal de salida
	HIDDEN PROCEDURE igenoutfile
		local cWorkFolder,cOutFile
		cWorkFolder=THIS.WorkFolder
		if empty(cWorkFolder)
		 cWorkFolder=".\"
		endif
		cWorkFolder=addbs(cWorkFolder)
		 
		cOutFile=cWorkFolder + sys(3) + ".DPF"
		do while file(cOutFile)
		 cOutFile=cWorkFolder + sys(3) + ".DPF"
		enddo
		 
		local fh
		fh=fcreate(cOutFile)
		=fclose(fh)

		return cOutFile
	ENDPROC



	PROCEDURE mode_access

		RETURN _VFP.StartMode
	ENDPROC


	*-- Moverse al siguiente registro en el dataset.
	PROCEDURE movenext
		#define ST_CURSOR		1
		#define ST_ADORS		2

		do case
		   case this.SourceType=ST_CURSOR             && Cursor, tabla o vista VFP
				select (THIS.DataSource)
				skip

		   case this.SourceType=ST_ADORS	          && RecordSet ADO
		        local oRS
		        oRS=THIS.DataSource
		        if (not oRS.EOF)      
		         oRS.MoveNext()
		        endif 

		   case THIS.SourceType=ST_ADORS and oRS.EOF
		        *-- Nothing
		endcase
	ENDPROC


	*-- Moverse al registro anterior en el dataset
	PROCEDURE moveback
		#define ST_CURSOR		1
		#define ST_ADORS		2

		do case
		   case this.SourceType=ST_CURSOR             && Cursor, tabla o vista VFP
				select (THIS.DataSource)
				skip -1
				if BOF()   && VES 17/2/07
				 go top
				endif

		   case this.SourceType=ST_ADORS	          && RecordSet ADO
		        local oRS
		        oRS=THIS.DataSource
		        if (not oRS.EOF)      
		         oRS.MoveBack()
		        endif 

		   case THIS.SourceType=ST_ADORS and oRS.EOF
		        *-- Nothing
		endcase
	ENDPROC


	*-- Ir al primer registro en el dataset
	PROCEDURE movefirst
		#define ST_CURSOR		1
		#define ST_ADORS		2

		do case
		   case this.SourceType=ST_CURSOR             && Cursor, tabla o vista VFP
				select (THIS.DataSource)
				go top

		   case this.SourceType=ST_ADORS	          && RecordSet ADO
		        local oRS
		        oRS=THIS.DataSource
		        if (not oRS.EOF)      
		         oRS.MoveFirst()
		        endif 

		   case THIS.SourceType=ST_ADORS and oRS.EOF
		        *-- Nothing
		endcase
	ENDPROC


	*-- Ir al ultimo registro en el dataset.
	PROCEDURE movelast
		#define ST_CURSOR		1
		#define ST_ADORS		2

		do case
		   case this.SourceType=ST_CURSOR             && Cursor, tabla o vista VFP
				select (THIS.DataSource)
				go bottom

		   case this.SourceType=ST_ADORS	          && RecordSet ADO
		        local oRS
		        oRS=THIS.DataSource
		        if (not oRS.EOF)      
		         oRS.MoveLast()
		        endif 

		   case THIS.SourceType=ST_ADORS and oRS.EOF
		        *-- Nothing
		endcase
	ENDPROC



	*-- Resuelve el valor de la macro PAGECNT.
	PROTECTED PROCEDURE iresolvepagecnt
		PARAMETERS PAGECNT

		SET PRINTER TO
		LOCAL cData
		cData=FILETOSTR(THIS.cOutFile)
		cData=THIS.STRExpand(cData)
		STRTOFILE(cData,THIS.cOutFile)
		SET PRINTER TO (THIS.cOutFile) ADDITIVE
	ENDPROC


	HIDDEN PROCEDURE htmlmode_assign
		LPARAMETERS vNewVal

		THIS.htmlmode = m.vNewVal
		IF THIS.HTMLMode
		 THIS.MacroChar="$"
		ENDIF
	ENDPROC


	*-- Efectua un salto de pagina "duro"
	PROCEDURE raweject
		LPARAMETERS plDoNotUpdatePageCount

		*-- Se salta la página y se actualizan los contadores
		*
		this.SetPrintOn()
		??this.EjectString
		this.SetPrintOff()
		this.nPL=0

		IF NOT plDoNotUpdatePageCount
		 *
		 this.PageNo = this.PageNo + 1
		 this.PageGen = this.PageGen + 1

		 * (ESP 20-AGO-2001) El numero de pagina se tiene que reasignar
		 * (VES 07-OCT-2001) La instrucción fué modificada para usar el nuevo método SetMacro()
		 this.SetMacroValue("PAGENO",alltrim(str(This.PageNo)))


		 *-- Si la propiedad ShowRunProgress está activa, se muestra el avance
		 *
		 if this.ShowRunProgress
		  this.iShowProgress(THIS.PageNo - 1)
		 endif

		 if (not empty(this.RunCallBack))
		  this.CallRunCallBack(2,THIS.PageNo - 1)
		 endif 
		 *
		ENDIF
	ENDPROC


	*-- Genera el texto correspondiente a un rango de paginas dado
	HIDDEN PROCEDURE iprintpagerange
		*-- VES 13/Julio/2007
		*   Metodo para generar una impresion parcial de un informe. Basicamente lo que se hace
		*   es utilizar la cadena indicada en la propiedad EjectString para determinar donde
		*   empieza y termina cada pagina.
		*
		LPARAMETERS pnFromPage,pnToPage


		*-- Se carga el contenido del informe en memoria
		*
		LOCAL cReportData
		cReportData = FILETOSTR(THIS.cOutFile)


		*-- Se determina la cantidad de paginas
		*
		LOCAL nPageCount
		nPageCount=OCCURS(THIS.ejectString,cReportData)


		*-- Se ajustan los parametros
		*
		IF VARTYPE(pnFromPage)<>"N" 
		 pnFromPage = 1
		ENDIF
		IF VARTYPE(pnToPage)<>"N"
		 pnToPage = nPageCount
		ENDIF


		*-- Se determina la posicion de la pagina siguiente a la ultima pagina a imprimir
		*   y se eliminan las paginas siguientes. 
		*
		LOCAL nPos
		IF pnToPage < nPageCount
		 nPos = AT(THIS.ejectString,cReportData,pnToPage)
		 cReportData = LEFT(cReportData,nPos)
		ENDIF


		*-- Se determina la posicion donde empieza la primera pagina a imprimir y se
		*   descarta todas las paginas anteriores a esa
		*
		LOCAL nPos
		IF pnFromPage > 1
		 nPos = AT(THIS.ejectString,cReportData,pnFromPage - 1) + LEN(THIS.ejectString)
		 cReportData = SUBS(cReportData,nPos)
		ENDIF


		*-- Se graba el texto obtenido en un nuevo archivo temporal
		*
		LOCAL cOutFile
		cOutFile = THIS.iGenOutFile()
		STRTOFILE(cReportData,cOutfile)

		RETURN cOutFile
	ENDPROC


	PROCEDURE Init


		*-- Se configura el ambiente 
		local nStrictDate
		nStrictDate=set("strictdate")
		set talk off
		set strictdate to 0




		*-- Se definen algunos objetos internos de uso comun 
		*
		this.Sections=this.New("Collection")
		this.Events=this.New("Collection")

		THIS.AddProperty("oPS_Sections1",THIS.New("Collection"))
		THIS.AddProperty("oPS_Sections2",THIS.New("Collection"))
		THIS.AddProperty("oPS_SingleSections",THIS.New("Collection"))


		*-- Se inicializa el ambiente
		*
		THIS.Clear(.T.)


		set strictdate to &nStrictDate
	ENDPROC


	PROCEDURE Destroy
		if not empty(this.cOutFile)
		 set printer to
		 erase (this.cOutFile)
		endif 
	ENDPROC


ENDDEFINE
*
*-- EndDefine: vfpdosprint
**************************************************


**************************************************
*-- Class:        vdpsection 
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Marca de hora:   03/25/03 12:10:14 AM
*
*   VES Nov 2016:  se elimino el GET/SET de la propiedad name, por innecesaria
*
DEFINE CLASS vdpsection AS custom


	*-- Tipo de sección. Los valores posibles son: TITLE, HEADER, DETAIL, FOOTER, SUMMARY o cualquier otro asignado en el formato.
	type = "CUSTOM"
	*-- Condición que debe cumplirse para aplicar la sección. El valor por omisión es .T.
	applyif = (('.T.'))
	*-- Data de la sección
	text = ""
	*-- Lista de macros definidos en la sección
	macros = .NULL.
	*-- Indica si la sección se imprimirá aunque este vacia
	printifblank = .T.
	*-- Altura de la sección (en lineas). Solo se tomará en cuenta si es mayor que cero, mayor que la altura real de la sección y la propiedad IntegralHeight está en True.
	bandheight = 0
	*-- Nro. de secciones del mismo tipo
	itypecount = 0
	Name = "vdpsection"

	*-- Indica si la sección puede o no imprimirse parcialmente en una página si no hay espacio suficiente. El valor predeterminado es False = Puede imprimirse parcialmente.
	integralheight = .F.

	*-- Indica si la sección deberá reimprimirse al iniciar una nueva página. Solo aplica a secciones usadas en grupos de control.
	printonnewpage = .F.

	*-- Indica si la sección se imprimirá en una nueva página. Solo para secciones de grupo.
	startonnewpage = .F.

	*-- Indica si se reiniciará el contador de páginas al imprimir la sección. Se utiliza solo para secciones de grupo y en conjunción con la propiedad StartOnNewPage.
	resetpagecounter = .F.


	PROCEDURE type_assign
		LPARAMETERS vNewVal

		this.Type=upper(m.vNewVal)
	ENDPROC



    * VES Nov 2016: Se anadieron parametros al constructor
	PROCEDURE Init(pcType, pcText)
		this.Macros=createobject("vdpBasicCollection")
		IF PCOUNT() = 2
			THIS.Type = pcType
			THIS.Name = pcType
			THIS.Text = pcText
		ENDIF
	ENDPROC


ENDDEFINE
*
*-- EndDefine: vdpsection
**************************************************


**************************************************
*-- Class:        cdpsectionmacro (e:\core\dev\vfp\opensource\vfpdosprint\vdp.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Marca de hora:   12/04/02 10:11:01 AM
*
DEFINE CLASS vdpsectionmacro AS custom


	HIDDEN cname
	cname = "MACRO"
	*-- Expresión que dá origen al macro
	expr = ""
	Name = "vdpsectionmacro"


	HIDDEN PROCEDURE name_access

		RETURN THIS.cName
	ENDPROC


	HIDDEN PROCEDURE name_assign
		LPARAMETERS vNewVal

		THIS.cName = m.vNewVal
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cdpsectionmacro
**************************************************


**************************************************
*-- Class:        vdpevent
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Marca de hora:   12/04/02 10:43:11 AM
*
DEFINE CLASS vdpevent AS custom


	*-- Código del evento
	source = ""
	*-- Código objeto del evento
	object = ""
	type = "EVENT"
	Name = "vdpevent"
	HIDDEN cname


	HIDDEN PROCEDURE name_access

		RETURN THIS.cName
	ENDPROC


	HIDDEN PROCEDURE name_assign
		LPARAMETERS vNewVal

		THIS.cName = m.vNewVal
	ENDPROC


	PROCEDURE type_access

		RETURN THIS.Type
	ENDPROC


	PROCEDURE type_assign
		LPARAMETERS vNewVal
	ENDPROC


ENDDEFINE
*
*-- EndDefine: vdpevent
**************************************************


**************************************************
*-- Class:        vdpabout 
*-- ParentClass:  form
*-- BaseClass:    form
*-- Marca de hora:   07/21/14 06:53:11 PM
*
DEFINE CLASS vdpabout AS form


	Height = 140
	Width = 303
	Desktop = .T.
	ShowWindow = 1
	DoCreate = .T.
	AutoCenter = .T.
	BorderStyle = 3
	Caption = "About VFPDosPrint"
	ControlBox = .T.
	minButton = .F.
	maxButton = .F.
	TitleBar = 1
	WindowType = 1
	keyPreview = .T.
	Icon = "vdplogo.ico"
	Name = "Form1"



	ADD OBJECT image1 AS image WITH ;
		Picture = "vdplogo.bmp", ;
		BackStyle = 0, ;
		Height = 32, ;
		Left = 9, ;
		Top = 11, ;
		Width = 32, ;
		Name = "Image1"


	ADD OBJECT lblversion AS label WITH ;
		AutoSize = .T., ;
		FontBold = .T., ;
		FontName = "Verdana", ;
		FontSize = 12, ;
		WordWrap = .F., ;
		BackStyle = 0, ;
		Caption = "VFPDosPrint v0.0", ;
		Height = 20, ;
		Left = 60, ;
		Top = 12, ;
		Width = 125, ;
		Name = "lblVersion"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		FontBold = .F., ;
		FontName = "Verdana", ;
		FontSize = 8, ;
		WordWrap = .F., ;
		BackStyle = 0, ;
		Caption = "Author: Victor J. Espina", ;
		Height = 15, ;
		Left = 60, ;
		Top = 36, ;
		Width = 136, ;
		Name = "Label1"


	ADD OBJECT label2 AS label WITH ;
		AutoSize = .T., ;
		FontBold = .F., ;
		FontName = "Verdana", ;
		FontSize = 8, ;
		WordWrap = .F., ;
		BackStyle = 0, ;
		Caption = "Email: vespinas@gmail.com", ;
		Height = 15, ;
		Left = 60, ;
		Top = 50, ;
		Width = 155, ;
		Name = "Label2"



	ADD OBJECT command1 AS commandbutton WITH ;
		Top = 214, ;
		Left = 109, ;
		Height = 21, ;
		Width = 84, ;
		FontName = "Verdana", ;
		FontSize = 8, ;
		Caption = "Close", ;
		Name = "Command1"


	PROCEDURE Init
		PARAMETERS poVDP

		THISFORM.lblVersion.Caption="VFPDosPrint v"+poVDP.Version
	ENDPROC


    PROCEDURE keypress(pnCode, pnSAC)
     IF pnCode = 27
      THISFORM.Release()
     ENDIF
    ENDPROC
    
    PROCEDURE queryUnload
     THISFORM.Release()
    ENDPROC


ENDDEFINE
*
*-- EndDefine: vdpabout
**************************************************


**************************************************
*-- Class:        vpprogress
*-- ParentClass:  form
*-- BaseClass:    form
*-- Marca de hora:   07/21/14 06:54:01 PM
*
DEFINE CLASS vdpprogress AS form


	Height = 64
	Width = 250
	Desktop = .T.
	ShowWindow = 2
	DoCreate = .T.
	AutoCenter = .T.
	BorderStyle = 2
	Caption = ""
	TitleBar = 0
	Name = "Form1"


	ADD OBJECT image1 AS image WITH ;
		Picture = "vdplogo.bmp", ;
		BackStyle = 0, ;
		Height = 32, ;
		Left = 9, ;
		Top = 11, ;
		Width = 32, ;
		Name = "Image1"


	ADD OBJECT lblmessage AS label WITH ;
		FontName = "Verdana", ;
		FontSize = 8, ;
		WordWrap = .T., ;
		Caption = "Generando informe...", ;
		Height = 42, ;
		Left = 53, ;
		Top = 10, ;
		Width = 187, ;
		Name = "lblMessage"


ENDDEFINE
*
*-- EndDefine: vdpprogress
**************************************************


**************************************************
*-- Class:        vdpbasiccollection 
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Marca de hora:   11/21/02 08:48:05 AM
*
DEFINE CLASS vdpbasiccollection AS custom


	HIDDEN ncount
	ncount = 0
	HIDDEN leoc
	leoc = .T.
	HIDDEN lboc
	lboc = .T.
	*-- Indica la posición actual dentro de la colección
	listindex = 0
	*-- Nombre de la clase a instanciar al llamar al método New.
	newitemclass = ""
	Name = "vbasiccollection"

	*-- Nro. de elementos en la colección
	count = .F.

	*-- Indica si se ha llegado al final de la colección
	eoc = .F.

	*-- Indica si se ha llegado al tope de la colección.
	boc = .F.

	*-- Devuelve el valor actual en la colección
	current = .F.

	*-- Lista de elementos en la colección
	DIMENSION items[1,1]
	HIDDEN aitems[1,1]


	PROCEDURE items_access
		LPARAMETERS m.nIndex1, m.nIndex2

		if type("m.nIndex1")="C"
		 m.nIndex1=this.FindItem(m.nIndex1)
		endif

		RETURN THIS.aItems[m.nIndex1]
	ENDPROC


	PROCEDURE items_assign
		LPARAMETERS vNewVal, m.nIndex1, m.nIndex2

		if type("m.nIndex1")="C"
		 m.nIndex1=this.FindItem(m.nIndex1)
		endif

		if between(m.nIndex1,1,THIS.Count)
		 THIS.aItems[m.nIndex1]=m.vNewVal
		endif
	ENDPROC


	PROCEDURE count_access

		RETURN THIS.nCount
	ENDPROC


	PROCEDURE count_assign
		LPARAMETERS vNewVal
	ENDPROC


	*-- Añade un elemento a la colección
	PROCEDURE add
		lparameters puValue

		if pcount()=0  && VES Nov 2016
		 return .F.
		endif

		this.nCount=this.nCount + 1
		dimen this.aItems[this.nCount]
		this.aItems[this.nCount]=puValue
		this.lEOC=.F.
		this.lBOC=.F.

		if this.ListIndex=0
		 this.ListIndex=1
		endif

		return puValue
	ENDPROC


	*-- Elimina un elemento de la colección
	PROCEDURE remove
		lparameters puValue

		if PCOUNT()=0   && VES Nov 2016
		 return .F.
		endif

		local nIndex
		nIndex=this.FindItem(puValue)
		if nIndex > 0
		 return this.RemoveItem(nIndex)
		else
		 return .F.
		endif
	ENDPROC


	*-- Limpia la colección
	PROCEDURE clear
		local i,uItem
		for i=1 to this.nCount
		 uItem=this.aItems[i]
		 if type("uItem")="O"
		  release uItem
		  this.aItems[i]=NULL
		 endif
		endfor

		dimen this.aItems[1]
		this.aItems[1]=NULL
		this.nCount=0
		this.lBOC=.T.
		this.lEOC=.T.
		this.ListIndex=0
	ENDPROC


	*-- Determina si un elemento dado forma parte de la colección.
	PROCEDURE isitem
		lparameters puValue,pcSearchProp

		if pcount()=0
		 return .F.
		endif

		return (this.FindItem(puValue,pcSearchProp)<>0)
	ENDPROC


	*-- Devuelve la posición en la colección donde se encuentra el elemento indicado
	PROCEDURE finditem
		lparameters puValue,pcSearchProp


		if PCOUNT()=0 or this.nCount=0   && VES Nov 2016
		 return 0
		endif

		if vartype(pcSearchProp)<>"C"
		 pcSearchProp=""
		endif

		local i,uItem,cType1,nPos
		nPos=0
		cType1=type("puValue")
		for i=1 to this.nCount
		 uItem=this.aItems[i]
		 if type("uItem")="O" 
		  if (cType1="O" and type("uItem.Name")="C" and type("puVale.Name")="C" and upper(uItem.Name)==upper(puValue.Name)) or ;
		     (cType1="C" and type("uItem.Name")="C" and upper(uItem.Name)==upper(puValue)) or ;
		     (cType1<>"O" and not empty(pcSearchProp) and type("uItem."+pcSearchProp)=cType1 and eval("uItem."+pcSearchProp)==puValue)
		   nPos=i
		   exit
		  endif 
		 else
		  if type("uItem")=cType1 and ((cType1<>"C" and uItem=puValue) or (cType1="C" and uItem==puValue))
		   nPos=i
		   exit
		  endif
		 endif
		endfor

		return nPos
	ENDPROC


	*-- Elimina un item por su posición
	PROCEDURE removeitem
		LPARAMETERS nIndex

		if PCOUNT()=0 or not between(nIndex,1,this.nCount)   && VES Nov 2016
		 return .f.
		endif

		local uItem
		uItem=this.aItems[nIndex]

		if type("uItem")="O"
		 release uItem
		 this.aItems[nIndex]=NULL
		endif

		adel(this.aItems,nIndex)

		this.nCount=this.nCount - 1
		if this.nCount > 0 
		 dimen this.aItems[this.nCount]
		 if this.nCount > this.ListIndex
		  this.ListIndex=this.nCount
		 endif
		else
		 this.aItems[1]=NULL
		 this.lEOC=.T.
		 this.lBOC=.T.
		 this.ListIndex=0
		endif
	ENDPROC


	PROCEDURE eoc_access

		RETURN THIS.lEOC
	ENDPROC


	PROCEDURE eoc_assign
		LPARAMETERS vNewVal
	ENDPROC


	PROCEDURE boc_access

		RETURN THIS.lBOC
	ENDPROC


	PROCEDURE boc_assign
		LPARAMETERS vNewVal
	ENDPROC


	*-- Ir al primer elemento en la colección
	PROCEDURE first
		if this.nCount=0
		 return
		endif

		this.ListIndex=1
		this.lBOC=.F.
		this.lEOC=.F.
	ENDPROC


	*-- Ir al siguiente elemento en la colección
	PROCEDURE next
		if this.nCount=0
		 return
		endif

		if this.ListIndex < this.nCount
		 this.ListIndex=this.ListIndex + 1
		 this.lBOC=.F.
		 this.lEOC=.F.
		else
		 this.lBOC=(this.nCount=1)
		 this.lEOC=.T.
		endif
	ENDPROC


	*-- Ir al último elemento en la colección
	PROCEDURE last
		if this.nCount=0
		 return
		endif

		this.ListIndex=this.nCount
		this.lBOC=.F.
		this.lEOC=.F.
	ENDPROC


	*-- Ir al elemento anterior en la colección
	PROCEDURE previous
		if this.nCount=0
		 return
		endif

		if this.ListIndex > 1
		 this.ListIndex=this.ListIndex - 1
		 this.lBOC=.F.
		 this.lEOC=.F.
		else
		 this.lBOC=.T.
		 this.lEOC=(this.nCount=1) 
		endif
	ENDPROC


	PROCEDURE listindex_assign
		LPARAMETERS vNewVal

		if type("m.vNewVal")="N" and between(m.vNewVal,1,this.nCount)
		 THIS.ListIndex = m.vNewVal
		 THIS.lEOC=.F.
		 this.lBOC=.F.
		endif
	ENDPROC


	PROCEDURE current_access
		if this.ListIndex=0
		 return NULL
		else
		 RETURN THIS.aItems[this.ListIndex]
		endif
	ENDPROC


	PROCEDURE current_assign
		LPARAMETERS vNewVal

		if this.ListIndex > 0
		 THIS.aItems[this.ListIndex]=m.vNewVal
		endif
	ENDPROC


	*-- Crea una instancia de la clase indicada en NewItemClass y devuelve una referencia al mismo.
	PROCEDURE new
		if empty(this.NewItemClass)
		 return NULL
		endif

		local oItem
		oItem=Kernel.CC.New(this.NewItemClass)

		return oItem
	ENDPROC


	*-- Permite añadir un item a la colección, solo si el mismo no existe.
	PROCEDURE addifnew
		lparameters puValue

		if PCOUNT()=0   && VES Nov 2016
		 return .F.
		endif

		if not this.IsItem(puValue)
		 this.Add(puValue)
		endif

		return puvalue
	ENDPROC


ENDDEFINE
*
*-- EndDefine: vdpbasiccollection
**************************************************


**************************************************
*-- Class:        printdev (e:\core\dev\vfp\opensource\vfpdosprint\vdp.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Marca de hora:   08/28/01 02:55:01 PM
*
DEFINE CLASS printdev AS custom


	*-- Printer handle returned from OpenPrinter
	PROTECTED nprnhandle
	nprnhandle = (0)
	*-- Name of the printer to open.
	cprintername = (Space(0))
	*-- File to use in oPrintFile()
	cfilename = (Space(0))
	*-- Error returned from last API call.
	nerror = (0)
	*-- Default printer name
	PROTECTED defprtname
	defprtname = (Space(0))
	*-- Current process heap
	PROTECTED procheap
	procheap = (0)
	*-- Memory Handle for DocName
	PROTECTED hdocname
	hdocname = (0)
	*-- Document name to show in print spooler
	cdocname = (Space(0))
	nopenerror = (0)
	Name = "printdev"


	*-- Open the printer device specified in cPrinterName, and store the result handle in nPrnHandle.
	PROCEDURE oopen
		Local lnhand, lndef, lcdoc

		lnhand = 0
		lndef  = 0

		this.DeclareAPI()
		this.oClose()

		this.nerror = OpenPrinter(this.cprintername, @lnhand, lndef)
		this.nopenerror = GetLastError()

		If this.nerror != 0
		   lcdoc  = this.oBldDocPtr()
		   this.nerror = StartDocPrinter(lnhand, 1, lcdoc)
		Endif

		If this.nerror != 0
		   this.nprnhandle = lnhand
		Else
		   If lnhand != 0
		      ClosePrinter(lnhand)
		   Endif
		Endif

		Return (this.nerror != 0)
	ENDPROC


	*-- Close a printer device previouly opened with oOpen()
	PROCEDURE oclose
		Local lresult

		this.DeclareAPI()
		lresult =.t.
		If this.nprnhandle != 0
		   EndDocPrinter(this.nprnhandle)
		   ClosePrinter(this.nprnhandle)
		   this.nprnhandle = 0
		Endif

		If this.hdocname != 0
		   HeapFree(this.procheap, 0, this.hdocname)
		   this.hdocname = 0
		Endif

		Return lresult
	ENDPROC


	*-- Send the file specified in the cFilename to a previously opened print device.
	PROCEDURE oprintfile
		#define BLKSZ 65535
		Local lresult, lnwrtchr, lcMemo, lnflhnd, nfsize

		nfsize   = 0
		lnwrtchr = 0
		lresult  = .f.
		lcMemo   = Space(0)

		this.DeclareAPI()
		If this.nprnhandle != 0
		   If !Empty(this.cFilename) .And. File(this.cFilename)
		      lnflhnd = Fopen(this.cFilename)
		      If lnflhnd != -1
		         nfsize = Fseek(lnflhnd,0,2)
		         Fseek(lnflhnd,0,0)
		      Endif
		      If nfsize > 0
		         lresult = .t.
		         Do While !Feof(lnflhnd)
		            lcMemo = FRead(lnflhnd, BLKSZ)
		            If WritePrinter(this.nprnhandle, lcMemo, Len(lcMemo),@lnwrtchr) == 0
		              lresult = .f.
		            Endif
		         EndDo
		      Endif
		      If lnflhnd != -1
		         Fclose(lnflhnd)
		      Endif
		   Endif
		Endif

		Return lresult
	ENDPROC


	*-- Send the content of a string variable passed as parameter to a previouly opened printer device.
	PROCEDURE oprintmem
		LPARAM pcMemo
		Local lresult, lnwrtchr

		lresult=.f.

		this.DeclareAPI()
		If this.nprnhandle != 0
		   If type('pcMemo')='C' .And. Len(pcMemo)>0
		      If WritePrinter(this.nprnhandle, pcMemo, Len(pcMemo), @lnwrtchr) != 0
		         lresult = .t.
		      Endif
		   Endif
		Endif

		Return lresult
	ENDPROC


	*-- Declare API functions Required to access the printer device in raw mode.
	PROTECTED PROCEDURE declareapi
		*--
		*   pPrinterName - Pointer to a null-terminated string that specifies 
		*                  the name of the printer or print server. 
		*   phPrinter    - Pointer to a variable that receives the handle 
		*                  identifying the opened printer or print server object. 
		*   pDefault     - Pointer to a PRINTER_DEFAULTS structure. 
		*                  This value can be NULL. 
		*--
		DECLARE INTEGER OpenPrinter      IN WINSPOOL.DRV ;
		        STRING  pPrinterName,                    ;
		        INTEGER @phPrinter,                      ;
		        LONG    pDefault

		*--
		*   hPrinter     - Handle to the printer object to be closed. Use the OpenPrinter 
		*                  or AddPrinter function to retrieve a printer handle. 
		*--
		DECLARE INTEGER ClosePrinter     IN WINSPOOL.DRV ;
		        INTEGER hPrinter

		*--
		*   hPrinter     - Handle to the printer. Use the OpenPrinter or AddPrinter 
		*                  function to retrieve a printer handle. 
		*   nLevel       - Specifies the version of the structure to which
		*                  pDocInfo points. WinNT: 1, Win9x: 1 or 2. 
		*   pDocInfo     - Pointer to a structure that describes the document to print. 
		*--
		DECLARE INTEGER StartDocPrinter  IN WINSPOOL.DRV ;
		        INTEGER hPrinter,                        ;
		        LONG    nLevel,                          ;
		        STRING  pDocInfo

		*--
		*   hPrinter     - Handle to a printer for which the print job should be ended. 
		*                  Use the OpenPrinter or AddPrinter function to retrieve a 
		*                  printer handle.
		*--
		DECLARE INTEGER EndDocPrinter    IN WINSPOOL.DRV ;
		        INTEGER hPrinter

		*--
		*   hPrinter        - Handle to the printer. Use the OpenPrinter or AddPrinter 
		*                     function to retrieve a printer handle. 
		*   pBuf            - Pointer to an array of bytes that contains the data that 
		*                     should be written to the printer. 
		*   cbBuf           - Specifies the size, in bytes, of the array. 
		*   pcWritten       - Pointer to a value that specifies the number of bytes of 
		*                     data that were written to the printer. 
		*--
		DECLARE INTEGER WritePrinter     IN WINSPOOL.DRV ;
		        INTEGER hPrinter,                        ;
		        STRING  pBuf,                            ;
		        LONG    cbBuf,                           ;
		        LONG    @pcWritten
		*--
		*   Obtains a handle to the heap of the calling process.
		*--
		DECLARE INTEGER GetProcessHeap   IN WIN32API


		*--
		*   Allocates a block of memory from a heap.
		*--
		DECLARE LONG HeapAlloc           IN WIN32API     ;
		        INTEGER hHeap,                           ;
		        INTEGER dwFlags,                         ;
		        INTEGER dwBytes

		*--
		*   Frees a memory block allocated from a heap by HeapAlloc.
		*--
		DECLARE INTEGER HeapFree         IN WIN32API     ;
		        INTEGER hHeap,                           ;
		        INTEGER dwFlags,                         ;
		        LONG    lpMem

		*--
		*   Copies a block of memory from one location to another. 
		*--
		DECLARE memcpy          IN MSVCRT  AS CopyMemory ;
		        LONG Destination,                        ;
		        STRING Source,                           ;
		        INTEGER Length

		*--
		*   Get Last error in thread
		*--
		DECLARE INTEGER GetLastError IN WIN32API
	ENDPROC


	*-- Verify status of the print device.
	PROCEDURE oisopen
		Return (this.nprnhandle != 0)
	ENDPROC


	*-- Long value to char conversion
	PROTECTED PROCEDURE long2char
		LParameter nLongVal
		Local lnlv, lcRetval

		lcRetVal=Replicate(chr(0),4)

		If type('nLongVal') = 'N'
		    lnlv = Int(nLongVal)
		    lcRetval = chr(bitand(lnlv,255))                 + ;
		               chr(bitand(bitrshift(lnlv,  8), 255)) + ;
		               chr(bitand(bitrshift(lnlv, 16), 255)) + ;
		               chr(bitand(bitrshift(lnlv, 24), 255))
		Endif

		Return lcRetVal
	ENDPROC


	*-- Build a Pointer to String for use in the Doc_info_1 structure.
	PROTECTED PROCEDURE oblddocptr
		Local lcDocPtr, lcDocstr

		lcDocPtr = Replicate(Chr(0), 20)
		If this.procheap = 0
		   this.procheap = GetProcessHeap()
		Endif

		If this.procheap != 0
		   Do Case
		      Case !Empty(this.cdocname)
		           lcdocstr = this.cdocname
		      Case !Empty(this.cfilename)
		           lcdocstr = this.cfilename
		      Otherwise
		           lcdocstr = "Visual Foxpro Document"
		   EndCase
		   
		   lcdocstr = lcDocStr+chr(0)
		   this.hdocname = HeapAlloc(this.procheap, 0, Len(lcdocstr)+1)

		   If this.hdocname != 0
		       CopyMemory(this.hdocname, lcDocstr, Len(lcDocstr) )
		       lcDocPtr  = this.Long2Char(this.hdocname) + Replicate(chr(0), 16)
		   Endif
		Endif

		Return lcDocPtr
	ENDPROC


	PROCEDURE Init
		Local laprtlst(1,2), npos
		this.DeclareAPI()

		If Empty(this.cprintername) .And. !Empty(this.defprtname)
		   APrinters(laprtlst)
		   npos = ASCAN(laprtlst, this.defprtname)
		   If npos != 0
		      this.cprintername = laprtlst(npos)
		   Endif
		Endif
	ENDPROC


	PROCEDURE Destroy
		this.oclose()
	ENDPROC


ENDDEFINE
*
*-- EndDefine: printdev
**************************************************


