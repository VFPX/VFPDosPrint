# VFPDosPrint
Generate text-based reports that can take full advantage of dot-matrix printer capabilities (VFP 6+).


## Note to collaborators
You are welcome to do any change or enhancement you want on this library, as long you keep the backward compatibility with VFP 6, 7 & 8.
 
 
## Quick Guide
_(for more detailed help, see file **dosprinten.chm** included in the release package)_ 

The fastest way to start using **VFPDosPrint** is using format files. All you will need is:

* A format file that contains the report design
* A dataset to be used to generate the report

Let's say we have a Customer table with the following columns:

* CustID
* CustName
* CustAddress
* CustPhone
* CustBalance

Now, we need to create a format file to generate a simple listing report. Create a text file with the following text. Once done, save the file with the name 'CUSTOMERS.FMT':

```
# CUSTOMERS.FMT
# Basic customer report
#
<config>
StartConfString=$C10$$COFF$    // 10 CPI not condensed (80 cols)
PaperLenght=60                 // This will cause a page eject every 60 lines
TopMargin=2                    // Print 2 empty lines at the start of every new page
LeftMargin=5                   // Append 5 spaces to every new line         
</config>

# Macros are like report variables. They exists only in the scope of the
# report begin generated
#
<macros>
COMPNAME='XYZ Bookstore'
COMPADDRESS='Caracas, Venezuela'
XCID=CustID
XCustBal=TRANSFORM(CustBalance,'9,999,999.99')
</macros>

# The FORMAT section is a quick way to declare the different bands
# of the report, like HEADER, DETAIL and FOOTER.
#
# pageno and datetime are internal macros that are generated automatically.
#
<format>
#   ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8
he: [COMPNAME                         ]                                CUSTOMER LIST
he: %COMPADDRESS%
he: 
he: ID      FULL NAME               ADDRESS               PHONE #            BALANCE
he: ======= ======================= ===================== ============= ============
de: [XCID ] [PROPER(CustName)     ] [CustAddress        ] [CustPhone  ] [XCustBal  ]
fo: 
fo: 
fo: [datetime           ]                                                   %pageno%
</format>
```

Before proceed with the next step, lets take a closer look of this format file. First, note that everything is contained in sections wich starts with < > and ends with </ >. Each section has a defined purpose inside the format:

**config:** configures page size and margins, as well as specific printer configurations.

**macros:** define report-level variables (called Macros), that are used in other sections across the format.

**format:** define the layout of the report.

Everything enclosed with brackets or '%' delimiters are **expandible expressions**. This expressions will be evaluated and the result inserted in the text in the same position of the expanded expression. Finally, any line starting with **#** will be considered as a comment and will not be sent to the final report, as well as any empty line or text that is not enclosed inside a section.

Now, we are ready to generate our text report. All we need now is a data set and an instance of VFPDOSPrint class:

```
*-- Generating customer report
*
SELECT 0
USE CUSTOMERS
GO TOP

LOCAL oDP
SET PROCEDURE TO vdp ADDITIVE
oDP=CREATEOBJECT("VFPDosPrint")
oDP.PrintFormat="CUSTOMERS.FMT"
oDP.Run()     && Automatically uses the current alias as the report's dataset
```

At this time, we have our report generated and ready to be printed. Yes, is **THAT** easy. You can either send the report to a defined printer or save it to a file:

```
oDP.Print( GETPRINTER() )     && Send report to a selected printer
oDP.PrintToFile( GETFILE() )   && Save report to a disk file
```

This is a basic example of what can be done using **VFPDosPrint**. Please, read carefully the help file included in the release package to learn how you can use VFPDosPrint to generate really complex text-based reports or even structured files like HTML or XML!.


#### IMPORTANT NOTE ABOUT THE HELP FILE
VFPDosPrint is the open source version of a commercial product called **DP** or **DOSPrint**.  Although I changed all references to DP in the source code to VFPDosPrint and remove the licensing restrictions, the help files are still the original ones and, therefore, they refers to **DP** and not VFPDosPrint.  This will be fixed in the near future, so I apologize for the confusion in the mean time.  

[Victor Espina](https://github.com/vespina)
 
