/// Version: 0.1 (test)
/// Author: Myasnikov Ivan Aleksandrovich
/// Email: Miacom@mail.ru
///    
/// <!-- <script type="text/javascript" src="#($SYSTEM.CSP.GetDefaultApp($ZU(5)))#/#($zcvt("%ZFastReport.js","O","URL"))#.cls"></script>   -->
/// <!-- <script type="text/javascript" src="#($SYSTEM.CSP.GetDefaultApp($ZU(5)))#/#($zcvt("%ZFastReport.js","O","URL"))#.cls/?include=#(##this)#"></script>                                            -->
Class %ZFastReport.js Extends %CSP.Page [ ClassType = "", Not ProcedureBlock ]
{

/// <br>   s %response.CharSet="CP1251" 
/// <br>   "CP1251" или "UTF-8"
/// Parameter CodePage = "UTF-8";
Parameter CodePage = "UTF-8";

Parameter GlobalMessage = "^mtempZFastReport.js";

Parameter intervalQueryStatus = 1500;

ClassMethod OnPreHTTP() As %Library.Boolean
{
     if ##this'="%ZFastReport.js"{ 
        Do %response.SetHeader("Content-Type","text/html")   
        q 1 
      }
     if $l(%request.GetCgiEnv("Cache port",""))=0{ // Запуск из %ZWeb.Server
        
         if $p($replace($$GetVersion^%apiOBJ(),"Cache Objects Version ",""),".",1)="2013"{;
	 	   s %response.CharSet="UTF-8"  
	     }else{
	       s %response.CharSet="CP1251"  
         }
        
     }
     if %request.Get("cspIntRunMethod",0)=1 {
	     if %response.ContentType="text/html" {
            Do %response.SetHeader("Content-Type","text/plain")   
	     }
         q 1   
     }
     Do %response.SetHeader("Content-Type","application/javascript")   
     q 1
}

ClassMethod OnPage() As %Status
{
    /// Подключение класса и интерпритация его как JS библиотек
    if %request.Get("include","")'=""{
	    d ..IncludeJsFun()
	    q 1   
    }
	
	if %request.Get("GetStatusJob","")'=""{	
	   s LastJobId=%request.Get("GetStatusJob","")
	   if '$DATA(^$JOB(LastJobId)) {
          w "Process Is Close" 
	   }else {
          w "Process Is Worc"    
	   }
	  q 1
	}
	
	if %request.Get("GetBufferJob","")'=""{	
	  s LastJobId=%request.Get("GetBufferJob","")
	  if $d(^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"BUFF")){
	     s ind=""
	     for {
	 	    s ind=$o(^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"BUFF",ind)) 
 		    q:ind=""
	        w ^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"BUFF",ind)
	        k ^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"BUFF",ind) 
         } 
	  }
      q 1
	}
	
	if %request.Get("GetResultJob","")'=""{	
	  s LastJobId=%request.Get("GetResultJob","")
	  if $d(^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"RESULT")){
 		  w ^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"RESULT")
		  k ^mtmpBufferHTMLBindjsDrawConsole(LastJobId,"RESULT")
	      k ^mtmpBufferHTMLBindjsDrawConsole(LastJobId)
	  }
      q 1
	}
	
	
	
    /// Вычитываем тело POST запроса
	s json=""
	if $isobject(%request.Content){
	   for {
		  q:%request.Content.AtEnd
	      s json=json_%request.Content.Read(32000)	     
	   }	
	}
	s ParentClass=""
    s:$d(%request.CgiEnvs("HTTP_REFERER")) ParentClass= $SYSTEM.CSP.GetClassName(%request.CgiEnvs("HTTP_REFERER"))
    s:ParentClass="" ParentClass=%request.Get("ParentClass","")
	s:ParentClass="" ParentClass=##THIS
	do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(json,,.%override,1)
	
	if %override'="" {
   	    s TestWebMethod=0
	    s ^||WEVENT=%override.GetAt(1)
	    ; k ^%deb
	    ; s ^%deb=^||WEVENT
        if $l(^||WEVENT,".")'=1  { 
           S TestWebMethod=1
        }else{
            s ^||WEVENT=$lg($$$cspDecode(%session.Key,^||WEVENT),1) 
            s ^||WEVENT=$p(^||WEVENT,":",1) ; ????
        }
    	   s objTmp=%override.GetAt(2)
    	   if $isObject(objTmp){
               k %override.Data(2)	    	   
	    	   s indInData=1
	    	   s subnd="" 
	    	   for {
		    	   s subnd=$o(objTmp.%data(subnd))
		    	   q:subnd=""
		    	   ; s ^%deb1("subnd:"_subnd)=subnd
		    	   s indInData=indInData+1
		    	   s %override.Data(indInData)=objTmp.%data(subnd)
		    	   k objTmp.%data(subnd)
	    	   }
    	   }
        s %method=$p(^||WEVENT,".",$l(^||WEVENT,"."))
        s %class=$e(^||WEVENT,1,$l(^||WEVENT)-$l(%method)-1)
        IF TestWebMethod=1 {
           q:'$d(^oddDEF(%class,"m",%method,51)) 1
           q:^oddDEF(%class,"m",%method,51)'=1 1
        }
        if %class="."{ s %class=ParentClass }
	    if %request.Get("RunJob")=""{
           d ..ExecRunMethod(%override)
	    }else{
		   s gl=..#GlobalMessage_"("_$job_")"
		   s @gl@("%class")=%class
		   s @gl@("%method")=%method
		   for ind=2:1:%override.Size {
             s @gl@(ind)=%override.GetAt(ind)
		   }
		   job ..ExecRunJobMethod(gl)
		   w $zchild
		   q 1
	    }
        q 1
    }
	
	
	 if ##this'="%ZFastReport.js"{	 
	     &html<
	       <script language="JavaScript" type="text/javascript" src="%25ZFastReport.js.cls"></script> 
           <script language="JavaScript" type="text/javascript" src="%25ZFastReport.js.cls?include=#(##this)#"></script> 
         >
         ; Поиск Xdata с формой DFM 
         s ClassName=##This,XdataName="Form"
         s GL="^oddDEF("""_ClassName_""",""x"","""_XdataName_""",21)"  
         if $d(@GL){  
            w ##class(%ZFastReport.js).ParseDFM(ClassName_":"_XdataName) 
         }
	     d ..main()
	     q 1
	 }
	
     s ParentClassName1=##this
     // zw ^oddDEF(ParentClassName1)
     s MethodName=""
     for {
	     s MethodName=$o(^oddDEF(ParentClassName1,"m",MethodName))
         q:MethodName=""
         continue:MethodName="init"
         
         if $d(^oddDEF(ParentClassName1,"m",MethodName,70)) {

             if $d(^oddDEF(ParentClassName1,"m",MethodName,4)){
	           w !,"/*",!
	           w ^oddDEF(ParentClassName1,"m",MethodName,4)
	           w "*/"
             }
	         w !,"  "_MethodName_" = function(" 
	         if $d(^oddDEF(ParentClassName1,"m",MethodName,27)){
		         w ^oddDEF(ParentClassName1,"m",MethodName,27)
	         }
	         w "){"
	         
             s ind=""
             for {
	            s ind=$o(^oddDEF(ParentClassName1,"m",MethodName,30,ind) )
                q:ind=""
                d ..ExecFrag(^oddDEF(ParentClassName1,"m",MethodName,30,ind),"/*(",")*/")
	            w $c(13,10)
                 // w ^oddDEF(ParentClassName1,"m",MethodName,30,ind)_$c(13,10)
             }
             w "}"
         }
     }
      
     s MethodName="init"
     s ind=""
     for {
	    s ind=$o(^oddDEF(ParentClassName1,"m",MethodName,30,ind) )
        q:ind=""
        w ^oddDEF(ParentClassName1,"m",MethodName,30,ind)_$c(13,10)
     }
      &js<   
           var cspHttpServerMethod=SendServer;   
       >
       s ClassCSP=ParentClass
       k filtr
	   for ind=1:1:$l(ClassCSP,","){
	      d $system.OBJ.GetDependencies($p(ClassCSP,",",ind),.included)
          s ClassParentTmp=""
          for {
            s ClassParentTmp=$o(included(ClassParentTmp))
            q:ClassParentTmp=""
            continue:$d(filtr(ClassParentTmp))
            d ..readJSFunctionFromCacheClass(ClassParentTmp)
            s filtr(ClassParentTmp)=1
          } 
	   }
     Quit $$$OK
}

ClassMethod main()
{
}

/// w ##class(%ZFastReport.js).GetType("Address.ESettle","ARegion")
ClassMethod GetType(ClassName = "", propertyName = "") As %String
{
	 if $d(^oddDEF(ClassName,"a",propertyName,5)){
		 s typ=^oddDEF(ClassName,"a",propertyName,5)
		 if $l(typ,".")=1 {
			 if $l(typ,"%")=2 {
			    s typ=$replace(typ,"%","%Library.")	 
			 }else{
			   s typ="User."_typ	 
			 }
		 }
		 q typ
	 }else{
	    if $d(^oddDEF(ClassName,60)){
	       w ..GetType(^oddDEF(ClassName,60),propertyName)
	    }else{
		 q ""   
	    }
	 }
     q ""
}

/// Функция инициализации
ClientMethod init() [ Language = javascript ]
{
 
 // ""
}

ClientMethod SendServer(MethodName) [ Language = javascript ]
{
    var FunCallBack=null;
    var FunProgress=null;
    var arr=new Array();
   //  console.log('*----'+SendServer.arguments[0]);
       for(var ind in SendServer.arguments){
	     if (SendServer.arguments[ind]==undefined){continue;}
	     if ((FunCallBack==null)&&(typeof SendServer.arguments[ind] === 'function')){
	        FunCallBack=SendServer.arguments[ind];
	        continue;
	     }  
	     if ((FunProgress==null)&&(typeof SendServer.arguments[ind] === 'function')){
	          FunProgress=SendServer.arguments[ind];
	          continue;
	     }  
	     arr.push(SendServer.arguments[ind]); 
	   }   
    
    
   // console.log( arr );
    
   if (FunCallBack==null){
      var requestSendServer = new XMLHttpRequest();
      requestSendServer.open('POST', '/*(   w $zcvt("%ZFastReport.js","O","URL")_".cls"  )*/', false);
      requestSendServer.send(JSON.stringify(arr));  
      requestSendServer.ontimeout = function (e) {
          alert('Время ожидания ответа вышло!!!!');
      }
      if (requestSendServer.status !== 200) {
          return {"error":requestSendServer.status}
      }
      return requestSendServer.responseText;
   }

      if (FunProgress==null){ FunProgress=function(){} };

      var requestSendServer = new XMLHttpRequest();
      requestSendServer.open('POST', '/*(   w $zcvt("%ZFastReport.js","O","URL")_".cls/?RunJob=1"  )*/', false);
      requestSendServer.send(JSON.stringify(arr));  
      requestSendServer.ontimeout = function (e) {
          alert('Время ожидания ответа вышло!!!!');
      }
      if (requestSendServer.status !== 200) {
          return {"error":requestSendServer.status}
      }
      var ProcessJob=requestSendServer.responseText;
      // console.log(ProcessJob);
      var isBreck=false;
      var FastReportTimerId = setTimeout(function tick() {
           var requestSendServerStatus = new XMLHttpRequest();
           requestSendServerStatus.open('GET','/*(   w $zcvt("%ZFastReport.js","O","URL")_".cls/?GetStatusJob="  )*/'+ProcessJob, false);
           requestSendServerStatus.ontimeout = function (e) { 
               isBreck=true; alert('Error:TimeOut'); 
           }
           requestSendServerStatus.send();  
           if (requestSendServerStatus.status !== 200) {   isBreck=true; alert('Error');  }
           // console.log(requestSendServerStatus.responseText);
           if (requestSendServerStatus.responseText=="Process Is Close"){  
                if (typeof FunCallBack === 'function'){ 
                   var requestSendServerStatusSub = new XMLHttpRequest();
                   requestSendServerStatusSub.open('GET','/*(   w $zcvt("%ZFastReport.js","O","URL")_".cls/?GetResultJob="  )*/'+ProcessJob, false);
                   requestSendServerStatusSub.ontimeout = function (e) {  alert('Error:TimeOut'); }
                   requestSendServerStatusSub.send();  
                   FunCallBack(requestSendServerStatusSub.responseText); 
                }
                clearInterval(FastReportTimerId);  
                return; 
           } 
           if (typeof FunProgress === 'function'){ 
               var requestSendServerStatusSub = new XMLHttpRequest();
               requestSendServerStatusSub.open('GET','/*(   w $zcvt("%ZFastReport.js","O","URL")_".cls/?GetBufferJob="  )*/'+ProcessJob, false);
               requestSendServerStatusSub.ontimeout = function (e) {  alert('Error:TimeOut'); }
               requestSendServerStatusSub.send();  
               FunProgress(requestSendServerStatusSub.responseText); 
               // console.log(requestSendServerStatusSub.responseText);
           }
           // console.log(requestSendServerStatus.responseText);
           FastReportTimerId = setTimeout(tick, /*(  if $l(##class(%ZFastReport.js).#intervalQueryStatus)>0 { w ##class(%ZFastReport.js).#intervalQueryStatus}else{ w 1000 } )*/+0 );
       }, /*(  if $l(##class(%ZFastReport.js).#intervalQueryStatus)>0 { w ##class(%ZFastReport.js).#intervalQueryStatus}else{ w 1000 } )*/+0 );
}

ClassMethod ExecRunJobMethod(gl = "")
{
	 s %class=@gl@("%class")
	 k @gl@("%class")
	 s %method=@gl@("%method")
	 k @gl@("%method")
     s numArg=0,ind=""
     for {
	    s ind=$o(@gl@(ind))
	    q:ind=""
 	    s numArg=numArg+1
        // set args(numArg) = $zcvt(override.GetAt(j),"i","UTF8")
        set args(numArg) = @gl@(ind)
        k @gl@(ind)
     }
	 s args=numArg
     d ..DrawBegin($job)	 
	 if '$d(^oddDEF(%class,"m",%method,70)) {
	    if $System.CLS.IsMthd(%class,%method)=1,'$d(^oddDEF(%class,"m",%method)){
		   s ^mtmpBufferHTMLBindjsDrawConsole($job,"RESULT")= $classmethod(%class, %method, args...)
		   q
	    }
	    if '$d(^oddDEF(%class,"m",%method,42)) {
	       do $classmethod(%class, %method, args...)
        } Else {
           s ^mtmpBufferHTMLBindjsDrawConsole($job,"RESULT")= $classmethod(%class, %method, args...)
        }
     }else{
        if $d(^oddDEF(%class,"m",%method,30)){
          for ind=1:1:^oddDEF(%class,"m",%method,30){
             w:ind'=1 $c(13,10)
             d ..ExecFrag(^oddDEF(%class,"m",%method,30,ind),"/*(",")*/")
          }
        }
     }
     d ..DrawEnd($job)
}

ClassMethod ExecRunMethod(override As %Library.ListOfDataTypes)
{
    s numArg=0
    s ind=""
    for {
	   s ind=$o(override.Data(ind))   
	   q:ind=""
	   continue:ind=1
	   s numArg=numArg+1
       set args(numArg) =$zcvt( override.Data(ind),"i","UTF8")
       ; s ^%deb(numArg)=$zcvt(override.Data(ind),"i","UTF8")
    }
    set args=numArg
     
   ;  d ..DrawBegin()
   ;  zw args
   ;  d ..DrawEnd()     
   ;  m ^%deb("BUFF")=^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")
     
     s len="",IsWrite=0
     if '$d(^oddDEF(%class,"m",%method,70)) {
	    if $System.CLS.IsMthd(%class,%method)=1,'$d(^oddDEF(%class,"m",%method)){
	      w $classmethod(%class, %method, args...)
          q
	    }
	    if '$d(^oddDEF(%class,"m",%method,42)) {
	       do $classmethod(%class, %method, args...)
        } Else {
           w $classmethod(%class, %method, args...)
        }
     }else{
        if $d(^oddDEF(%class,"m",%method,30)){
          for ind=1:1:^oddDEF(%class,"m",%method,30){
             w:ind'=1 $c(13,10)
              d ..ExecFrag(^oddDEF(%class,"m",%method,30,ind),"/*(",")*/")
          }
        }
     }
     q
}

/// Метод разбики исходного текста на Cache` код и HTML текст
ClassMethod ExecFrag(SrcCode = "", Beg = "", End = "")
{
    q:SrcCode=""   q:Beg=""    q:End=""    for ExecFragInd=1:1:$l(SrcCode,End){  s tmp=$p(SrcCode,End,ExecFragInd)   s Html=$p(tmp,Beg,1)     s Code=$p(tmp,Beg,2)   w Html   TRY {     x Code    } CATCH ErrorHandle {    zw ErrorHandle  }    }
}

/// <pre>
/// 
/// Варианты параметров классов 
///  1) [ Language = cache, WebMethod ]
///  2) [ Language = javascript, WebMethod ]
/// 
/// Пример классов , которые будут интерпритированы в JS функции:
///     ClassMethod test2()as %String [ Language = cache, WebMethod ]{ zw  q ""}
///     ClientMethod test3() [ Language = javascript, WebMethod ]{    alert('test3()');}
///     Property cspXMLHttp As %String [ ServerOnly = 1 ];
///     Property cspUseGetMethod As %Boolean [ InitialExpression = 0, ServerOnly = 1 ];
///     Property cspMozilla As %Boolean [ InitialExpression = "nill", ServerOnly = 1 ];
///    
/// </pre>
///  <h2>Переписать  %Library.ClassDefinition на  <h2>
ClassMethod readJSFunctionFromCacheClass(ParentClassName = "", MethodName = "", DrawDescript = 1) As %String
{
     s onEventFun=",onblur,onerror,onfocus,onload,onresize,onscroll,onbeforeunload,onhashchange,onlanguagechange,onmessage,onoffline,ononline,onpagehide,onpageshow,onpopstate,onrejectionhandled,onstorage,onunhandledrejection,onunload,onabort,oncancel,oncanplay,oncanplaythrough,onchange,onclick,onclose,oncontextmenu,oncuechange,ondblclick,ondrag,ondragend,ondragenter,ondragleave,ondragover,ondragstart,ondrop,ondurationchange,onemptied,onended,oninput,oninvalid,onkeydown,onkeypress,onkeyup,onloadeddata,onloadedmetadata,onloadstart,onmousedown,onmouseenter,onmouseleave,onmousemove,onmouseout,onmouseover,onmouseup,onmousewheel,onpause,onplay,onplaying,onprogress,onratechange,onreset,onseeked,onseeking,onselect,onshow,onstalled,onsubmit,onsuspend,ontimeupdate,ontoggle,onvolumechange,onwaiting,onauxclick,ongotpointercapture,onlostpointercapture,onpointercancel,onpointerdown,onpointerenter,onpointerleave,onpointermove,onpointerout,onpointerover,onpointerup,onbeforecopy,onbeforecut,onbeforepaste,oncopy,oncut,onpaste,onsearch,onselectstart,onwheel,onwebkitfullscreenchange,onwebkitfullscreenerror"
     s ClassOref=##class(%ClassDefinition).%OpenId(ParentClassName)
     if ClassOref {
       s ConstructMethod=$p(ParentClassName,".",$l(ParentClassName,"."))
       s count=ClassOref.Properties.Count() 
       for i=1:1:count {
            s nam=ClassOref.Properties.GetAt(i).Name
            continue:'$d(^oddDEF(ParentClassName,"a",nam,57))
            continue:^oddDEF(ParentClassName,"a",nam,57)'=1
            w "  var "_ClassOref.Properties.GetAt(i).Name_" "
            if $d(^oddDEF(ParentClassName,"a",nam,31)) {
                 s val=^oddDEF(ParentClassName,"a",nam,31)
                 if val="""null""" w "=null;"_$c(13,10)  continue
                 s typ=""
                 if $d(^oddDEF(ParentClassName,"a",nam,5)) {
                    s typ=^oddDEF(ParentClassName,"a",nam,5)
                    if $e(typ,1,1)="%",$l(typ,".")=1 {
                       s typ=$REPLACE(typ,"%","%Library.")
                    }
                 }   
                 if typ="" {
                     if $l(typ ," ")=1 { w "="_$e(val,2,$l(val)-1)_";"_$c(13,10)  continue }
                    try {   x "w "_val   }catch(e){  w "="_$e(val,2,$l(val)-1)_";"_$c(13,10)  continue }
                 }
                 
                 if typ="%Library.Boolean" {
                      if $e(val,1,1)="""" {
                         w "=" 
                         try {   x "w "_val   }catch(e){  if +val=1 { w "=true"  }else     { w "=false" }   }
                      }else {
                        if val=1 { w "=true"  }else     { w "=false" }
                      }
                 }elseif  typ="%Library.Integer" {
                     if $e(val,1,1)="""" {
                         w "=" 
                         try {   x "w "_val   }catch(e){  s val=+val  w val }
                      } else {
                          s val=+val  w val
                      } 
                 }else{
	                 
                     if $e(val,1,1)'="""" {
                           w "=""" 
                           try {   x "w "_val   }catch(e){  w val   }
                           w """"
                      }else {
                         w "="_val
                      } 
                 }
            }
            w ";"_$c(13,10) 
       }
       s ConstructMethodIndex=""
       s count=ClassOref.Methods.Count()
       for i=1:1:count {
            if (MethodName=""){
               continue:$l(ClassOref.Methods.GetAt(i).Name,"OnPage")'=1
               continue:ClassOref.Methods.GetAt(i).Name="OnPreHTTP"
               continue:ClassOref.Methods.GetAt(i).Name="OnPostHTTP"
               continue:ClassOref.Methods.GetAt(i).Name="getLibOne"
               continue:ClassOref.Methods.GetAt(i).Name="GetJSMethodFromClientMethod"
               continue:ClassOref.Methods.GetAt(i).Name="readJSFunctionFromCacheClass"
            }else{
                continue:ClassOref.Methods.GetAt(i).Name'=MethodName   
            }
           /// [ ServerOnly = 1 ]
           // continue:'$d(^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,59))
           // continue:^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,59)'=1
           
           /// [ WebMethod ]
           continue:'$d(^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,51))
           continue:^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,51)'=1
          
          if $ZCVT(ClassOref.Methods.GetAt(i).Name,"L")=$ZCVT(ConstructMethod,"L"){
             s ConstructMethodIndex=i
             continue    
          }
          
          if DrawDescript=1 {
             if $l(ClassOref.Methods.GetAt(i).Description)>0,ParentClassName'=##this{
                w !,"/*",!
                w $replace(ClassOref.Methods.GetAt(i).Description,"*/","-/-")
                w !,"*/"
             }
          }
          // Получаем JS представление Cache клиент метода
           if ClassOref.Methods.GetAt(i).Language="javascript" {
               w !,"var "_ClassOref.Methods.GetAt(i).Name_"=function("
               s param=ClassOref.Methods.GetAt(i).FormalSpec
               for ind=1:1:$l(param,","){
                   s subParam=$p(param,",",ind)
                   s subParam=$p(subParam,":",1)
                   s subParam=$p(subParam,"=",1)
                   w:ind'=1 ","
                   w subParam
               }
               w "){",!
                 d ..ExecFrag(ClassOref.Methods.GetAt(i).Code,"/*(",")*/")
                 // w ClassOref.Methods.GetAt(i).Code
                 w !,"};"
                
            }
           // Получаем JS представление Cache класс метода
           if ClassOref.Methods.GetAt(i).Language="cache" {
                   w !,"var "_ClassOref.Methods.GetAt(i).Name_"=function(){",!
                   ; if $d(^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,42)){ w "return "}
                   ; s WEVENT=$$$cspEncode(%session.Key,$lb(ParentClassName_"."_ClassOref.Methods.GetAt(i).Name))
                   s WEVENT=ParentClassName_"."_ClassOref.Methods.GetAt(i).Name
                  if '$d(^oddDEF(ParentClassName,"m",ClassOref.Methods.GetAt(i).Name,42)) {
                        &js< try { var res=cspHttpServerMethod('#(WEVENT)#',arguments); eval(res); }catch (e) { return res}>
                  } Else {
                     w "   return cspHttpServerMethod('"_WEVENT_"',arguments);"
                  }
                  w !,"};"
           }
                
         }
         // После отрисовки функций, создаем конструктор( если конечно он встретился ранее)
         if ConstructMethodIndex'="" {
           s i=ConstructMethodIndex
           if ClassOref.Methods.GetAt(i).Language="javascript" {
              d ..ExecFrag(ClassOref.Methods.GetAt(i).Code,"/*(",")*/")
           }
           if ClassOref.Methods.GetAt(i).Language="cache" {
              ; s WEVENT=$$$cspEncode(%session.Key,$lb(ParentClassName_"."_ClassOref.Methods.GetAt(i).Name))
              s WEVENT=ParentClassName_"."_ClassOref.Methods.GetAt(i).Name
              w " cspHttpServerMethod('"_WEVENT_"',arguments);"
           }
         }
       }
       q ""
}

ClassMethod IncludeJsFun()
{
	   s ClassCSP=%request.Get("include","")
  	   s ClassCSP=$tr(ClassCSP," ","")
       k filtr
	   for ind=1:1:$l(ClassCSP,","){
          // Если класс есть, тогда интерпритируем 
	      if $zObjClassMethod("%CompiledClass","%ExistsId",$p(ClassCSP,",",ind))=1 {
	             d $system.OBJ.GetDependencies($p(ClassCSP,",",ind),.included)
                 s ClassParentTmp=""
                 for {
                    s ClassParentTmp=$o(included(ClassParentTmp))
                    q:ClassParentTmp=""
                    continue:$d(filtr(ClassParentTmp))
                    d ..readJSFunctionFromCacheClass(ClassParentTmp)
                    s filtr(ClassParentTmp)=1
                } 
	     }else{
		    // иначе проверяем есть ли такой пакет, и добавляем весь пакет
		    s ClassTmpPacket=""
		    for {
		         s ClassTmpPacket=$o(^oddDEF(ClassTmpPacket))
		         q:ClassTmpPacket=""  
		         if $e(ClassTmpPacket,1,$l($p(ClassCSP,",",ind)))=$p(ClassCSP,",",ind){
 	                 d $system.OBJ.GetDependencies(ClassTmpPacket,.included)
                     s ClassParentTmp=""
                     for {
                        s ClassParentTmp=$o(included(ClassParentTmp))
                        q:ClassParentTmp=""
                        continue:$d(filtrObj(ClassParentTmp))
                        d ..readJSFunctionFromCacheClass(ClassParentTmp)
                        s filtrObj(ClassParentTmp)=1
                     } 
		         }

	     }}
	   }
}

ClassMethod redirects() [ Internal, ProcedureBlock = 0 ]
{
wstr(s)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")=$get(^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF"),0)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF",$i( ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF") ))=s          q
wchr(c)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")=$get(^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF"),0)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF",$i( ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF") ))=$c(c)      q
wnl      s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")=$get(^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF"),0)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF",$i( ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF") ))=$$$NL      q
wff      s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")=$get(^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF"),0)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF",$i( ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF") ))=$c(12)     q
wtab(s)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")=$get(^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF"),0)  s ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF",$i( ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF") ))=s          q
}

ClassMethod DrawBegin(JobId = {$job}) [ ProcedureBlock = 1 ]
{
	k ^mtmpBufferHTMLBindjsDrawConsole($job,"BUFF")
	s %LastIO=$IO
    u %LastIO::("^"_$zn)
    d ##class(%Device).ReDirectIO($$$YES)
}

ClassMethod DrawEnd(JobId = {$job})
{
 	d ##class(%Device).ReDirectIO($$$NO)
    u %LastIO
}

}

