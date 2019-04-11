/// Versoin: 0.1 (Test)
/// Author:  Myasnikov Ivan Aleksandrovich
/// Email:   Miacom@mail.ru
Class %ZDelphi.Controller Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

Property ERROR As %String(TRUNCATE = 1);

Property VALUE As %String(TRUNCATE = 1);

Property isAuthor As %String(TRUNCATE = 1) [ InitialExpression = 0, Private ];

/// Авторизация
Method Author(UserName = "", UserPass = "") As %String
{
    s res=$SYSTEM.Security.Login(UserName,UserPass)
    s ..isAuthor=res
	q res
}

Method SetVar(gl = "^%deb", VALUE = "") [ ProcedureBlock = 1 ]
{
  IF ..isAuthor=0  q 
  s @gl=VALUE
}

Method job(execcmd = "") As %String [ ProcedureBlock = 0 ]
{
	s ..ERROR=""
	s ..VALUE=""
	IF ..isAuthor=0 {
	  s ..ERROR="No author"	
	  q ""
	}
    try{	
      x " job "_execcmd	
      s ResultRunJobZDelphiController=$zchild
    }CATCH {
      s ..ERROR=$ZE
      s ResultRunJobZDelphiController=-1
    }
	q ResultRunJobZDelphiController
}

Method do(execcmd = "")
{
	s ..ERROR=""
	s ..VALUE=""
	IF ..isAuthor=0 {
	  s ..ERROR="No author"	
	  q ""
	}
	if execcmd=""  s ..ERROR="Error cache' command"  q 
     try{	
       x execcmd
    }CATCH {
       s ..ERROR=$ZE
    }
    q
}

Method exec(execcmd = "") As %String [ ProcedureBlock = 0 ]
{
	s ..ERROR=""
	s ..VALUE=""
	IF ..isAuthor=0 {
	  s ..ERROR="No author"		
	  q ""
	}
	if execcmd=""  s ..ERROR="Error cache' command"  q ""
	if $e(execcmd,1,1)="=" {
	   s execcmd=$e(execcmd,2,$l(execcmd))
	   try{	
         XECUTE " s execVarResult="_execcmd
       }CATCH {
	     s execVarResult=execcmd
	     s ..ERROR=$ZE
       }
       s ..VALUE=execVarResult
       q execVarResult
	}else{
	   x execcmd	
	}
	q ""
}

Method write(execcmd = "") As %String
{
	s ..ERROR=""
	s ..VALUE=""
    IF ..isAuthor=0 {
	  s ..ERROR="No author"	
	  q ""
	}
	if execcmd=""  s ..ERROR="Error cache' command"  q ""
	d ..DrawBegin()
	if $e(execcmd,1,1)="=" {
	   s execcmd=$e(execcmd,2,$l(execcmd))
	   try{	
         XECUTE " w "_execcmd
       }CATCH {
	     s execVarResult=execcmd
	     s ..ERROR=$ZE
       }
       w execVarResult
	}else{
	   x execcmd	
	}
	s res=..DrawEnd()
	s ..VALUE=res
	q res
}

ClassMethod DrawBegin() [ ProcedureBlock = 0 ]
{
	s %LastIO=$IO
    u %LastIO::("^"_$zn)
    d ##class(%Device).ReDirectIO($$$YES)
}

ClassMethod DrawEnd() As %String
{
 	d ##class(%Device).ReDirectIO($$$NO)    s isUnicode=$SYSTEM.Version.IsUnicode()  
    u %LastIO
    s res=""    
    if $d(^||tmpBuffer){
	   for ind=1:1:^||tmpBuffer {
		   q:'$d(^||tmpBuffer(ind))
		   ; s:ind'=1 res=res_$c(13,10)
		   if isUnicode=1{ s res=res_$zcvt(^||tmpBuffer(ind),"i","CP1251") /* UNICODE */ }else{s res=res_^||tmpBuffer(ind) /* 8bit */} 
	   } 
    }
    k ^||tmpBuffer
    q res
}

ClassMethod redirects() [ Internal, ProcedureBlock = 0 ]
{
wstr(s)s ^||tmpBuffer($i(^||tmpBuffer))=s       q
wchr(c)  s ^||tmpBuffer($i(^||tmpBuffer))=$c(c) q
wnl s ^||tmpBuffer($i(^||tmpBuffer))=$$$NL      q
wff  s ^||tmpBuffer($i(^||tmpBuffer))=$c(12)    q
wtab(s)  s ^||tmpBuffer($i(^||tmpBuffer))=s     q
}

}

