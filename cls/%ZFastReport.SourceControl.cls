/// Add ContextMenu: ##class(%ZFastReport.SourceControl).InstallSorceControllAllNameSpace()
Class %ZFastReport.SourceControl Extends %Studio.SourceControl.Base [ ClassType = "", ProcedureBlock ]
{

Property LoginUserName As %String(TRUNCATE = 1);

Property LoginUserPass As %String(TRUNCATE = 1);

Method Login(login As %String = "", password As %String = "") As %Status
{
	s ..LoginUserName=login
	s ..LoginUserPass =password
	quit $$$OK
}

XData Menu
{
<MenuBase>
<Menu Name="%SourceMenuContext" Type="1">
  <MenuItem Name="CacheFastReportDesigner"/>
</Menu>
</MenuBase>
}

Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
	if MenuName = "%SourceMenuContext" {
		set DisplayName = "Tools"
		Set Enabled=1
		quit $$$OK
	}
    if MenuName="%SourceMenuContext,CacheFastReportDesigner"{	    
		Set DisplayName="Designer FastReport"
		Set Enabled=1
	}	
  	Quit $$$OK
}

Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
	Set Action=0,Target="",Msg="",Reload=0
    if (Type=0)&&(Name="%SourceMenuContext,CacheFastReportDesigner")
	{
		  s ClassName=$e(InternalName,1,$l(InternalName)-4)
		  d ##class(%ZFastReport.page).ShowDesigner(ClassName,.Target,..LoginUserName,..LoginUserPass)
          s Action = 3
	    ; w !,Target,!
          Quit $$$OK		  
	}	
	Quit $$$OK
}

/// d ##class(%ZFastReport.SourceControl).InstallSorceControllAllNameSpace()
/// Установка Контроля версия во все области имен
ClassMethod InstallSorceControllAllNameSpace()
{
     For i=1:1:$ZU(90,0) Set nslist($ZU(90,2,0,i))=""
     Set nameSpace=""
     For {
        Set nameSpace=$O(nslist(nameSpace))
        Quit:nameSpace=""
        CONTINUE:nameSpace="%CACHELIB"
        w !,nameSpace_":"
        w ##class(%Studio.SourceControl.Interface).SourceControlClassSet(##this,nameSpace)
     }
	 w !,"OK"
}

}

