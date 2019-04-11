Class %ZFastReport.page Extends %CSP.Page [ ClassType = "", Not ProcedureBlock ]
{

/// <br>   s %response.CharSet="CP1251" 
/// <br>   "CP1251" или "UTF-8"
/// Parameter CodePage = "UTF-8";
Parameter CodePage = "CP1251";

Parameter Port = 51773;

Parameter IntervalStatusQuery = 1500;

Parameter GlobalMessage = "^mtempZFastReport.page";

/// Имя пользователя от которого будет подключатся программа
Parameter UserName = "_SYSTEM";

/// Пароль пользователя от которого будет подключатся программа
Parameter UserPass = "SYS";

Parameter ExecFileName = {^%SYS("bindir")_"FastReportPlayer.exe"};

///  Запуск построения отчета, и ожидание окончания построение
ClassMethod ShowReport(FileName = "Fil11.pdf", Error = "", %parm...) As %Status
{
	 s ExecFileName=..#ExecFileName
	 if $e(FileName,2,2)="$" { s FileName=$tr(FileName,"$",":")  }
	 if $l(FileName,":")=2,$l(FileName,"\")>2 {
	    s DirName=$e(FileName,1,$l(FileName)-$l($p(FileName,"\",$l(FileName,"\"))))
	    if ##class(%File).Exists(DirName)=0 {
		    d ##class(%File).CreateDirectory(DirName)
	        if ##class(%File).Exists(DirName)=0  s Error="Error create dir:"_DirName q 0
	    }
	 } 
     d $SYSTEM.Security.Login(..#UserName,..#UserPass)   
        
        
        
 	 
 	 if ##class(%File).Exists(ExecFileName)'=1 {
	 	 s ExecFileName=^%SYS("bindir")_ExecFileName
	 	 if ##class(%File).Exists(ExecFileName)'=1 {
 	       s Error="FileNotFound :"_..#ExecFileName
	 	   q 0
	 	 }
	 } 	 
	 if ##class(%File).Exists(FileName)=1 {
	     d ##class(%File).Delete(FileName)
		 if ##class(%File).Exists(FileName) s Error="File is blocked" q 0
	 }
	 s NoMaket=1
     if $d(^oddDEF(##this,"p","MaketFile",22)){ 
        s FileNameMaket=^oddDEF(##this,"p","MaketFile",22) 
        if $l(FileNameMaket)>0,##class(%File).Exists(FileNameMaket)'=1 {
	       s Error="Maket not found("_##this_":MaketFile) in server : "_FileNameMaket
	       q 0
        }else{
	      s NoMaket=0   
        }
     }
     if NoMaket=1,'$d(^oddDEF(##this,"x","Maket",21)){ 
	    s Error="Maket not found in class("_##this_":Maket): "_FileNameMaket
	    q 0
     }else{
	    s NoMaket=0   
     }
     s Params=""
     if $d(%parm),$l(%parm)>0{
        if +%parm=0 {
	        s @%parm=$job
	        s ind=""
	        for {
		       s ind=$o(@%parm@(ind))
		       q:ind=""
		       s Params=Params_" """_$zcvt(@%parm@(ind),"O","URL")_""" "
	        }
	        k @%parm
        }else{     
           for tPtr = 1:1:$Get(%parm) {
	          s Params=Params_" """_$zcvt(%parm(tPtr),"O","URL")_""" "
           }
        }
     }
     
     S Port=1972
     // 51773
     if $l(..#Port)>0{
        S Port=..#Port
     }
     s cmd=ExecFileName_" "
     s cmd=cmd_" ""localhost"" "
     s cmd=cmd_" """_Port_""" "
     s cmd=cmd_" """_..#UserName_""" "
     s cmd=cmd_" """_..#UserPass_""" "
     s cmd=cmd_" """_$ZU(5)_""" "
     s cmd=cmd_" """_##this_""" "
     s cmd=cmd_" """_FileName_""" "
     s cmd=cmd_" "_Params
     ; w cmd,!
     d $zf(-1,cmd)
     q 1
     // d $zf(-2,cmd) // не ждать окончания
     // C:\DelphiProject\FastReportPlayer\FastReportPlayer.exe "127.0.0.1" 6030 "_SYSTEM" "SYS" "USER" "Demo.FastReport3" "C:\DELETE\t.pdf"
}

///    var texts=['param1','param2','param3'];
///    try { var res=#server(Dogovor.Bill.ProntDoc.SchetOne.ShowReportWeb('pdf',JSON.stringify(texts)))#;  eval(res);   }catch (e) {console.log(res);}   ; 
ClassMethod ShowReportWeb(FormatFile = "PDF", %parm...) As %String
{
  s DirName = $ZUTIL(168)_"FRTempFile"
  ; s DirName="C:\FastReport"
  s exec=FormatFile
  if ##class(%File).Exists(DirName)=0  d $zf(-1,"mkdir """_DirName_"""") 
  s FileName = DirName_"\Tmp_"_exec_"_"_$job_"("_$tr($h,",","_")_")."_exec
  s giud=##class(%ZFastReport.page).MD5HashToGuid( 
         ##class(%ZFastReport.page).MD5HashString(FileName)
  )
  s @..#GlobalMessage@("WebFile",giud)=FileName  
  d ..ShowReport(FileName , .Error, %parm...)
  if $l(Error)>0  q Error

  s URL=$zcvt("%ZFastReport.page","O","URL")
  s URL=URL_".cls?LoadFile="_giud
  s ProcessJob=$job
  s res=""
  s res=res_"     var link"_ProcessJob_" = document.createElement('a'); link"_ProcessJob_".href = '"_URL_"'; "
  s res=res_"     link"_ProcessJob_".style.display = 'none'; document.body.appendChild(link"_ProcessJob_");"
  s res=res_"     link"_ProcessJob_".click(); document.body.removeChild(link"_ProcessJob_");"
  q res
}

/// d ##class(%ZFastReport.page).ShowDesigner(ClassName,.Target)
ClassMethod ShowDesigner(ClassName = "", Target = "", UserName = {..#UserName}, UserPass = {..#UserPass})
{
     s ExecFileName=..#ExecFileName
 	 if ##class(%File).Exists(ExecFileName)'=1 {
	 	 s ExecFileName=^%SYS("bindir")_ExecFileName
	 	 if ##class(%File).Exists(ExecFileName)'=1 {
 	       s Error="Файл для создания отчета не найден :"_..#ExecFileName
	 	   q 0
	 	 }
	 } 	 
     S Port=..#Port
     set Port=..#Port
     if $l(Port)=0{set Port=1972}
     s Target=""
     s Target=Target_ExecFileName_"  "
     s Target=Target_""""_$zu(110)_""" "
     // s Target=Target_"""localhost"" "
     s Target=Target_" """_Port_""" "
     s Target=Target_" """_UserName_""" "
     s Target=Target_" """_UserPass_""" "
     s Target=Target_" """_$ZU(5)_""" "
     s Target=Target_" """_ClassName_""" "
     s Target=Target_" ""RunDesigner"" "
     q Target
}

ClassMethod OnPreHTTP() As %Library.Boolean
{
	 if %request.Get("LoadFile","")'=""{
		 s giud=%request.Get("LoadFile","")
	     if $d(@..#GlobalMessage@("WebFile",giud)){
	      s FileName=@..#GlobalMessage@("WebFile",giud)
          if ##class(%File).Exists(FileName)=1   {
	         s FileNameLocal=$p(FileName,"\",$l(FileName,"\"))
             do %response.SetHeader("Content-Disposition","attachment;filename="""_FileNameLocal_"""")
             set %response.Expires = "Thu, 01 Apr 2003 00:00:00 GMT"
             set %response.HeaderCharSet ="windows-1251"
             set %response.ContentType="application/x-msexcel"
             q 1
         }
       }
     }
	 if $L(..#CodePage )>0 {
  	   s %response.CharSet=..#CodePage  
	 }
     Do %response.SetHeader("Content-Type","application/javascript")   
     q 1
}

/// Получить IP клиента
ClassMethod GetIP() As %String
{
    s ip=$ZU(67, 15, $job)
    if ip="::1" s ip=""
    if ip="" {
       s I=$ZU(111,0)   
       s ip=$A(I,1)_"."_$A(I,2)_"."_$A(I,3)_"."_$A(I,4)
       k I
    }
   q ip
}

ClassMethod OnPage() As %Status
{
	//  ?LoadFile=3d096f34-206c-3a6d-d3d0-63aff6dc4eb5
    if %request.Get("LoadFile","")'=""{	
        s giud=%request.Get("LoadFile","")
        if $d(@..#GlobalMessage@("WebFile",giud)){
         s FileName=@..#GlobalMessage@("WebFile",giud)
         if ##class(%File).Exists(FileName)=1   {
           S stream=##class(%FileBinaryStream).%New()
           S stream.Filename=FileName
           While 'stream.AtEnd  {
                s readFrag=stream.Read(32000)
                w readFrag
           }
           d stream.%Close()
           d ##class(%File).Delete(FileName)
         }
         k @..#GlobalMessage@("WebFile",giud)
        }
        q 1
    }
    
	if %request.Get("GetStatusFastRepJob","")'=""{	
	   s LastJobId=%request.Get("GetStatusFastRepJob","")
	   if '$DATA(^$JOB(LastJobId)) {
		   w "ProcessIsClose" 
		   q 1
	   }
	  if $d(@##class(%ZFastReport.page).#GlobalMessage@(LastJobId,"info")){
		  w @##class(%ZFastReport.page).#GlobalMessage@(LastJobId,"info")
		  q 1
	  } 
	  w "ProcessIsWorc" 
	  q 1
	}
    s %ClientIP=..GetIP()
    Quit $$$OK
}

ClassMethod ExecFrag(SrcCode = "", Beg = "", End = "")
{
      q:SrcCode=""   q:Beg=""    q:End="" 
      s html=SrcCode
      for {
          s HtmlFrag=$e(SrcCode,1,$l($p(SrcCode,Beg,1)) ) 
          w HtmlFrag
          s SrcCode=$e(SrcCode,$l(HtmlFrag)+1+$l(Beg),$l(SrcCode) ) 
          s CodeFrag=$e(SrcCode,1, $l($p(SrcCode,End,1)) ) 
          s SrcCode=$e(SrcCode,$l(CodeFrag)+1+$l(End),$l(SrcCode) ) 
          if $l(CodeFrag)>0{
             TRY {  x "w """"_"_$tr(CodeFrag,$c(13,10),"   ")   } CATCH ErrorHandle {    zw ErrorHandle  }
          }
        q:SrcCode=""
      }
}

ClassMethod GetTypeContent(CrcText = "") As %String
{
	if $l(CrcText)=0 q ""
	if $l(CrcText,":\")=2,$l($p(CrcText,":\",1))=1 q "file"
	if $l(CrcText,"http")=2,$l($p(CrcText,"http",1))=0 q "url"
	if $l(CrcText," ")>2 {  q "cache"  }
	q "{NODATA}"
}

ClassMethod KillExeProc()
{
    d $zf(-1," taskkill /im FastReportPlayerHTTP.exe / f")
    q
}

///  d ##class(%ZFastReport.page).SaveMasterData(ClassName, .Error,"MasterData1","MasterData2")
ClassMethod SaveMasterData(ClassName, MasterDataNames...) As %Status
{
    s AddDefDescript=0
    if '$d(^oddDEF(ClassName)) {
	  s tt=##class(%Dictionary.ClassDefinition).%New(ClassName) 
	  s tt.Super="%ZFastReport.page"
	  s AddDefDescript=1
    }else{
	  s tt=##class(%Dictionary.ClassDefinition).%OpenId(ClassName) 
      s:$l(tt.Super)=0 tt.Super="%ZFastReport.page"
    }
    s tt.ProcedureBlock=1
    d tt.%Save()
       
       
    if $d(^oddDEF(ClassName,"x","Maket")){
      s Supper=tt.Super
      s tt.Super="ffffff"    
      k ^oddDEF(ClassName,"x","Maket")
      s tt.Super=Supper
      d tt.%Save()
    }
       
    
    if '$d(^oddDEF(ClassName,"p","MaketFile")){
      s Supper=tt.Super
      s tt.Super="ffffff"    
      S ^oddDEF(ClassName,"p","MaketFile")="" 
      s str="Путь к файлу макету *.fr3 (если он пуст, тогда макет" 
      s str=str_" братся из XML схемы расположенной в XData:Maket)"
      S ^oddDEF(ClassName,"p","MaketFile",4)=str
      S ^oddDEF(ClassName,"p","MaketFile",22)=""
      s tt.Super=Supper
      d tt.%Save()
    }
    
    if '$d(^oddDEF(ClassName,"m","PostReport")){
      s MethodNameHead="PostReport"        
      s MethodHead=##class(%Dictionary.MethodDefinition).%New(ClassName_":"_MethodNameHead)        
      s MethodHead.FormalSpec="arg1="""""        
      s MethodHead.Description="Метод запускается после окончания построения отчета."  
      s MethodHead.ClassMethod=1        
      d MethodHead.%Save()
      d tt.Methods.Insert(MethodHead)
      d tt.%Save()
    }

    
    s MasterDataGLSql="^mtempMasterDataSql"
    k @MasterDataGLSql
    s MasterDataGL="^mtempMasterData"
    k @MasterDataGL
    s MemoList="^mtempMemoList"
    k @MemoList
    for indArg=1:1:MasterDataNames{
       s ElementName=MasterDataNames(indArg)
       s TypeObj=$p(ElementName,":",1)
       s ObjName=$p(ElementName,":",2)
       s ObjPar=$p(ElementName,":",3)
       continue:$l(ObjName)=0
       if TypeObj="MasterDataSQL",$l(ObjPar)>0{
	      try {  s @MasterDataGLSql@(ObjName)=$System.Encryption.Base64Decode(ObjPar) }CATCH { }
       }       
       if TypeObj="StaticMemo",$l(ObjPar)=0{
	      s @MemoList@(ObjName)=1
	      continue          
       }
       if TypeObj="MasterDataMemo"{ 
          if '$d(@MasterDataGL@(ObjPar)) {
               s @MasterDataGL@(ObjPar)=$lb(ObjName)
          }else{
           s $li(@MasterDataGL@(ObjPar),$ll(@MasterDataGL@(ObjPar))+1)=ObjName
          }
          continue          
       }
    }
    
    
    if '$d(^oddDEF(ClassName,"m","PreReport")){
      s MethodNameHead="PreReport"        
      s MethodHead=##class(%Dictionary.MethodDefinition).%New(ClassName_":"_MethodNameHead)        
      s MethodHead.FormalSpec="arg1="""""        
      s MethodHead.Description="Метод запускается перед началом построения отчета."_$c(13,10)
      s MethodHead.Description=MethodHead.Description_"Инициализация статических переменных:"_$c(13,10)
      s MethodHead.Description=MethodHead.Description_" Если переменная имеет вид ""%Memo1"" "
      s MethodHead.Description=MethodHead.Description_"То она соответствует статическому элементу на форме ""Memo1"" "       
      s ObjName=""
      for { 
        s ObjName=$o(@MemoList@(ObjName))
        q:ObjName=""
        d MethodHead.Implementation.WriteLine("  ; s %"_ObjName_"=""Text-"_ObjName_""" ")        
      }
      s MethodHead.ClassMethod=1        
      d MethodHead.%Save()
      d tt.Methods.Insert(MethodHead)
      d tt.%Save()
    }
    
    s MasterDataName=""
     s ObjName=""
      for { 
       s MasterDataName=$o(@MasterDataGL@(MasterDataName))
       q:MasterDataName=""
       s MemoList=$g(@MasterDataGL@(MasterDataName),$lb())
       s MethodNameHead=MasterDataName_"Execute"     
       if '$d(^oddDEF(ClassName,"m",MethodNameHead)){    
           s MethodHead=##class(%Dictionary.MethodDefinition).%New(tt.Name_":"_MethodNameHead) 
           s MethodHead.ReturnType= "%Library.Integer" 
           s MethodHead.Description="Заполняем масив данными для "_MasterDataName_"  "  
           s MethodHead.ClassMethod=1 
           d MethodHead.Implementation.WriteLine("   s CountRow=0 ")
           if $d(@MasterDataGLSql@(MasterDataName)){
              s SqlSrc=@MasterDataGLSql@(MasterDataName)
              s SqlStr="",ParamsFun=""
              s Beg="[",End="]" 
              
             if SqlSrc'="" {
	           s Beg="["    s End="]" 
               for {
                  s SqlFrag=$e(SqlSrc,1,$l($p(SqlSrc,Beg,1)) ) 
                  s SqlStr=SqlStr_SqlFrag
                  s SqlSrc=$e(SqlSrc,$l(SqlFrag)+1+$l(Beg),$l(SqlSrc) ) 
                  s ParamFrag=$e(SqlSrc,1, $l($p(SqlSrc,End,1)) ) 
                  s SqlSrc=$e(SqlSrc,$l(ParamFrag)+1+$l(End),$l(SqlSrc) ) 
                  if $l(ParamFrag)>0{
                     s:$l(ParamsFun)'=0 ParamsFun=ParamsFun_","
                     s ParamsFun=ParamsFun_ParamFrag
                  }
                  q:SqlSrc=""
               }
             }
             
               s SqlStr=$replace(SqlStr,"{","""_")
               s SqlStr=$replace(SqlStr,"}","_""")
              s MethodHead.FormalSpec=ParamsFun   
              d MethodHead.Implementation.WriteLine("   s st=##class(%SQL.Statement).%New()  ")
              d MethodHead.Implementation.WriteLine("   s SqlStr="""_SqlStr_""" ")
              d MethodHead.Implementation.WriteLine("   d st.%Prepare(SqlStr)  ")
              d MethodHead.Implementation.WriteLine("   s stres=st.%Execute() ")
              d MethodHead.Implementation.WriteLine("   s colcount=st.%Metadata.columnCount ")
              d MethodHead.Implementation.WriteLine("   for i=1:1:colcount   s columns(i)=st.%Metadata.columns.GetAt(i).colName    ")
              d MethodHead.Implementation.WriteLine("   while stres.%Next()   {")
              d MethodHead.Implementation.WriteLine("     k LineRow     s LineRow=$lb() ")
              d MethodHead.Implementation.WriteLine("     for i=1:1:colcount {")
              d MethodHead.Implementation.WriteLine("       s rowname=columns(i) ")
              d MethodHead.Implementation.WriteLine("       s rowdata=stres.%GetData(i) ")
              d MethodHead.Implementation.WriteLine("       s $li(LineRow,i)=rowdata  ")
              d MethodHead.Implementation.WriteLine("     } ")
              d MethodHead.Implementation.WriteLine("     s ^mtempFastReportHTTP($job,"""_MasterDataName_""",$i(CountRow))=LineRow ") 
              d MethodHead.Implementation.WriteLine("   } ")
                       
           }else{
              s Code=""
              for IndListMemo=1:1:$ll(MemoList){
                 s:$l(Code)'=0 Code=Code_","
                 s Code=Code_"""%"_$lG(MemoList,IndListMemo)_""""
              }
              d MethodHead.Implementation.WriteLine("   s ^mtempFastReportHTTP($job,"""_MasterDataName_""",$i(CountRow))=$lb("_Code_") ") 
           }
           d MethodHead.Implementation.WriteLine("   s ^mtempFastReportHTTP($job,"""_MasterDataName_""")="""" ")
           d MethodHead.Implementation.WriteLine("   q CountRow ")
           d MethodHead.%Save()   
           d tt.Methods.Insert(MethodHead)
           d tt.%Save()
       } 
       s MethodNameHead=MasterDataName_"Fetch"     
       if '$d(^oddDEF(ClassName,"m",MethodNameHead)){    
           s MethodHead=##class(%Dictionary.MethodDefinition).%New(tt.Name_":"_MethodNameHead) 
           s MethodHead.ReturnType= "%Library.Status" 
           s MethodHead.Description="Получаем следующую запись из массива для "_MasterDataName
           s MethodHead.ClassMethod=1 
           
           d MethodHead.Implementation.WriteLine("  if '$d(^mtempFastReportHTTP($job,"""_MasterDataName_""")) { q 0 }    ")
           s str="  s ^mtempFastReportHTTP($job,"""_MasterDataName_""")=$o(^mtempFastReportHTTP($job,"""_MasterDataName_""""
           s str=str_",^mtempFastReportHTTP($job,"""_MasterDataName_""")))   "
           d MethodHead.Implementation.WriteLine(str)
           s str="  if ^mtempFastReportHTTP($job,"""_MasterDataName_""")="""" "
           s str=str_"  k ^mtempFastReportHTTP($job,"""_MasterDataName_""")   q 0    "
           d MethodHead.Implementation.WriteLine(str) 
           s str="  s row=^mtempFastReportHTTP($job,"""_MasterDataName_""""
           s str=str_",^mtempFastReportHTTP($job,"""_MasterDataName_"""))   "
           d MethodHead.Implementation.WriteLine(str)
           for IndListMemo=1:1:$ll(MemoList){
               d MethodHead.Implementation.WriteLine("   s %"_$lG(MemoList,IndListMemo)_"=$lg(row,"_IndListMemo_","""") ")           
           }
           d MethodHead.Implementation.WriteLine("    q 1 ")
           d MethodHead.%Save()   
           d tt.Methods.Insert(MethodHead)
           d tt.%Save()
       }     
    }
    d tt.%Save()
    q 1
}

/// вычисление хэша MD5 из строки
/// do ##class(Word.DrawMaket).MD5HashString("sdfjksdgfjk")
ClassMethod MD5HashString(str As %String = "") As %String
{
	set bytestring = $system.Encryption.MD5Hash(str)
	set hash = ""
	for i=1:1:$length(bytestring) {
		set hex = $zhex($ascii($extract(bytestring, i)))
		if ($length(hex) = 1) set hex = "0" _ hex
		set hash = hash _ hex
	}
	quit $zcvt(hash, "l")
}

/// преобразование хэша MD5 в гуид
ClassMethod MD5HashToGuid(hash As %String) As %String
{
	quit $zcvt($extract(hash,1,8)_"-"_$extract(hash,9,12)_"-"_$extract(hash,13,16)_"-"_$extract(hash,17,20)_"-"_$extract(hash,21,32), "l")
}

ClassMethod ReplaceFragText(SrcCode = "", Beg = "#(", End = ")#") As %String [ ProcedureBlock = 0 ]
{
      q:SrcCode="" SrcCode  
      q:Beg="" SrcCode  
      q:End="" SrcCode
      q:$l(SrcCode,Beg)=1 SrcCode
      q:$l(SrcCode,End)=1 SrcCode
      n html,resTxtReplaceFragText,HtmlFrag,classname,methodReplaceFragText,argTmp,IndexArgumentReplaceFragText
      s resTxtReplaceFragText=""
      s html=SrcCode
      for {
          s HtmlFrag=$e(SrcCode,1,$l($p(SrcCode,Beg,1)) ) 
          s resTxtReplaceFragText=resTxtReplaceFragText_HtmlFrag
          s SrcCode=$e(SrcCode,$l(HtmlFrag)+1+$l(Beg),$l(SrcCode) ) 
          s CodeFrag=$e(SrcCode,1, $l($p(SrcCode,End,1)) ) 
          s SrcCode=$e(SrcCode,$l(CodeFrag)+1+$l(End),$l(SrcCode) ) 
          if $l(CodeFrag)>0{
            d ..AddParamClassMethod(1,$lb(CodeFrag),.argTmp) 
            s resTxtReplaceFragText=resTxtReplaceFragText_argTmp   
          }
        q:SrcCode=""
      }
      q resTxtReplaceFragText
}

ClassMethod AddParamClassMethod(IndexArgumentReplaceFragText, argsReplaceFragTextLB, argTmp = "") [ ProcedureBlock = 0 ]
{
   try{	
     XECUTE " SET argTmp="_$lg(argsReplaceFragTextLB,IndexArgumentReplaceFragText)
   }CATCH {
	 s argTmp="#("_$lg(argsReplaceFragTextLB,IndexArgumentReplaceFragText)_")#"
   }
}

ClassMethod GetReportMaket(NameObj = "", GetSrc = 1)
{
   s:NameObj="" NameObj = ##This_":Maket"
   if $l(NameObj,":")=1,$e(NameObj,1,2)'=".."{  s Name=".."_NameObj  }
   if $e(NameObj,1,2)=".." {  s ClassName=##This,XdataName=$e(NameObj,3,$l(NameObj))
   }else{                     s ClassName=$p(NameObj,":",1),XdataName=$p(NameObj,":",2)  }
   s GL="^oddDEF("""_ClassName_""",""x"","""_XdataName_""",21)"  
   if '$d(@GL) q
   s GlIndex="",CountLine=0
   for { 
       s GlIndex=$o(@GL@(GlIndex))
       q:GlIndex=""  
       s val=@GL@(GlIndex)
       continue:$l(val)=0
       // Для Cache2013 необходимо включить следующую строку
       s val=$zcvt(val,"o","UTF8")
       // if $l(..#CodePage)>0 s val=$zcvt(val,"O",$tr(..#CodePage,"-","")  )
       s CountLine=CountLine+1
       if $l(val)=32766 {w val continue}
       if GetSrc=1 {
          w val
       }else{
	      d ##class(%ZFastReport.page).ExecFrag(val, "#(",")#")
       }
       
   }
   q
}

ClassMethod DrawBegin() [ ProcedureBlock = 0 ]
{
	s %LastIO=$IO
    u %LastIO::("^"_$zn)
    d ##class(%Device).ReDirectIO($$$YES)
}

ClassMethod DrawEnd() As %String
{
 	d ##class(%Device).ReDirectIO($$$NO)
    u %LastIO
    s res=""    
    if $d(^||tmpBufferFastReportDrawConsole){
	   for ind=1:1:^||tmpBufferFastReportDrawConsole {
		   q:'$d(^||tmpBufferFastReportDrawConsole(ind))
		   s:ind'=1 res=res_$c(13,10)
		   s res=res_^||tmpBufferFastReportDrawConsole(ind)
	   } 
    }
    k ^||tmpBufferFastReportDrawConsole
    q res
}

ClassMethod redirects() [ Internal, ProcedureBlock = 0 ]
{
wstr(s)s ^||tmpBufferFastReportDrawConsole($i(^||tmpBufferFastReportDrawConsole))=s       q
wchr(c)  s ^||tmpBufferFastReportDrawConsole($i(^||tmpBufferFastReportDrawConsole))=$c(c) q
wnl s ^||tmpBufferFastReportDrawConsole($i(^||tmpBufferFastReportDrawConsole))=$$$NL      q
wff  s ^||tmpBufferFastReportDrawConsole($i(^||tmpBufferFastReportDrawConsole))=$c(12)    q
wtab(s)  s ^||tmpBufferFastReportDrawConsole($i(^||tmpBufferFastReportDrawConsole))=s     q
}

ClassMethod GetInputParamList(ClassNameLocal = "", MethodName = "") As %String [ ProcedureBlock = 1 ]
{
	if '$d(^oddDEF(ClassNameLocal,"m",MethodName)) q "{NODATA}"	
	if '$d(^oddDEF(ClassNameLocal,"m",MethodName,27)){
	   q "{NODATA}"	
	}
	zw ^oddDEF(ClassNameLocal,"m",MethodName,27)
	s src=^oddDEF(ClassNameLocal,"m",MethodName,27)
	s dst="" 
	for ind=1:1:$l(src,","){
	   s tmp= $p(src,",",ind)
	   s tmp= $p(tmp,":",1)
	   s tmp= $tr(tmp," ","")
	   s:$l(dst)>0 dst=dst_","
	   s dst=dst_tmp
	}
	q dst
}

///  d ##class(%ZFastReport.page).AddDescription(ClassName)
Method AddDescription(ClassName)
{
   if '$d(^oddDEF(ClassName)) q
   if $d(^oddDEF(ClassName,4)),$l(^oddDEF(ClassName,4))>2 q
   s tt=##class(%Dictionary.ClassDefinition).%OpenId(ClassName) 
   s tt.Description=""
   s tt.Description=tt.Description_" if ##class("_ClassName_").ShowReport(""C:\FastReport\"_ClassName_".pdf"",.Error)=0 {  zw Error  }  "
   s tt.Description=tt.Description_$c(13,10)_" if ##class("_ClassName_").ShowReport(""C:\FastReport\"_ClassName_".doc"",.Error)=0 {  zw Error  } "
   s tt.Description=tt.Description_$c(13,10)_" if ##class("_ClassName_").ShowReport(""C:\FastReport\"_ClassName_".txt"",.Error)=0 {  zw Error  }"
   s tt.Description=tt.Description_$c(13,10)_" if ##class("_ClassName_").ShowReport(""C:\FastReport\"_ClassName_".jpg"",.Error)=0 {  zw Error  }"
   s tt.Description=tt.Description_$c(13,10)_"  Web CSP: "
   s tt.Description=tt.Description_$c(13,10)_"                     <script type='text/javascript' src='#($SYSTEM.CSP.GetDefaultApp($ZU(5)))#/#($zcvt(""%ZFastReport.js"",""O"",""URL""))#.cls'></script>"  
   s tt.Description=tt.Description_$c(13,10)_"                     <script language='javascript'> "
   s tt.Description=tt.Description_$c(13,10)_"                        GerReportFile=function(){ "
   s tt.Description=tt.Description_$c(13,10)_"                           var res=#server("_ClassName_".ShowReportWeb('pdf','Arg1'))#; " 
   s tt.Description=tt.Description_$c(13,10)_"                           try {   eval(res); }catch (e) {console.log(res);} "   
   s tt.Description=tt.Description_$c(13,10)_"                        } "
   s tt.Description=tt.Description_$c(13,10)_"                     </script> "
   s tt.Description=tt.Description_$c(13,10)_"                     <button   onclick='GerReportFile()' >GerReportFile</button>" 
   s tt.Description=tt.Description_$c(13,10)_"  "
   s tt.Description=tt.Description_$c(13,10)_" Web Cls : "
   s tt.Description=tt.Description_$c(13,10)_"    Class User.TestClass1 Extends %CSP.Page "
   s tt.Description=tt.Description_$c(13,10)_"    { "
  
   s tt.Description=tt.Description_$c(13,10)_"      ClassMethod OnPage() As %Status "
   s tt.Description=tt.Description_$c(13,10)_"      {"
   s tt.Description=tt.Description_$c(13,10)_"                   &html<" 
   s tt.Description=tt.Description_$c(13,10)_"                     <script type='text/javascript' src='#($SYSTEM.CSP.GetDefaultApp($ZU(5)))#/#($zcvt(""%ZFastReport.js"",""O"",""URL""))#.cls'></script>"  
   s tt.Description=tt.Description_$c(13,10)_"                     <script language='javascript'> "
   s tt.Description=tt.Description_$c(13,10)_"                        isOkFun=function(res){try {   eval(res); }catch (e) {console.log(res);} console.log(res); } "
   s tt.Description=tt.Description_$c(13,10)_"                        ProgrressBarFun=function(){ console.log('Create...'); } "
   s tt.Description=tt.Description_$c(13,10)_"                        GerReportFile=function(){ "
   s tt.Description=tt.Description_$c(13,10)_"                            #server("_ClassName_".ShowReportWeb('pdf','Arg1',isOkFun,ProgrressBarFun ))#;"   
   s tt.Description=tt.Description_$c(13,10)_"                        } "
   s tt.Description=tt.Description_$c(13,10)_"                     </script> "
   s tt.Description=tt.Description_$c(13,10)_"                     <button   onclick='GerReportFile()' >GerReportFile</button>" 
   s tt.Description=tt.Description_$c(13,10)_"                   > "
   s tt.Description=tt.Description_$c(13,10)_"                   Quit $$$OK"
   s tt.Description=tt.Description_$c(13,10)_"      } "
   s tt.Description=tt.Description_$c(13,10)_"    } "
   d tt.%Save()
   Do $system.OBJ.Compile(ClassName,"cuk /checkuptodate=expandedonly")
}

}

