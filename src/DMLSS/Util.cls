Class DMLSS.Util
{

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	If $$$OK Set ^TESTdmlss($I(^TESTdmlss))=$ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod StatusToText(pStatus As %Status) As %String
{
	Set tReturn = $System.Status.GetOneErrorText(pStatus)
	Quit tReturn
}

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = ..StatusToText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod SendSimpleMessage(server As %Net.SMTP) As %List
{
  Set msg = ##class(%Net.MailMessage).%New()
  Set From=server.authenticator.UserName
  Set:From="" From="xxx@xxx.com"
  Set msg.From = From
  
  Do msg.To.Insert("oliverwilms@yahoo.com")
  //Do msg.Cc.Insert("yyy@yyy.com")
  //Do msg.Bcc.Insert("zzz@zzz.com")
  Set msg.Subject="Unique subject line here "_$H
  Set msg.IsBinary=0
  Set msg.IsHTML=0
  Do msg.TextData.Write("This is the message.")
  
  Set status=server.Send(msg)
  If $$$ISERR(status) {
    Do $System.Status.DisplayError(status)
    Write server.Error
    Quit ""
  }
  Quit server.FailedSend
}

ClassMethod HotPOPAsSMTP() As %Net.SMTP
{
  Set server=##class(%Net.SMTP).%New()
  Set server.smtpserver="smtp.hotpop.com"
  //HotPOP SMTP server uses the default port (25)
  Set server.port=25
  
  //Create object to carry authentication
  Set auth=##class(%Net.Authenticator).%New()
  Set auth.UserName="isctest@hotpop.com"
  Set auth.Password="123pass"
  
  Set server.authenticator=auth
  Set server.AuthFrom=auth.UserName
  Quit server
}

ClassMethod YPOPsAsSMTP() As %Net.SMTP
{
  Set server=##class(%Net.SMTP).%New()
  //local host acts as the server
  Set server.smtpserver="127.0.0.1"
  //YPOPs uses default port, apparently
  Set server.port=25
  
  //Create object to carry authentication
  Set auth=##class(%Net.Authenticator).%New()
  //YPOPs works with a Yahoo email account
  Set auth.UserName="isc.test@yahoo.com"
  Set auth.Password="123pass"
  
  Set server.authenticator=auth
  Set server.AuthFrom=auth.UserName
  Quit server
}

ClassMethod Test() As %Status
{
	Kill ^TEST
	Set server = ..HotPOPAsSMTP()
	Set ^TEST($I(^TEST),"server") = server
	Set ^TEST($I(^TEST)) = ..SendSimpleMessage(server)
	Quit $$$OK
}

ClassMethod ValidateConfigItem(pName As %String) As %Status
{
	Set pName = $Get(pName)
	Set tProdName = ##class(Ens.Director).GetActiveProductionName()
	Set strWhere = "Name = '"_pName_"' and Production = '"_tProdName_"'"
	Set strSQL = "select * from Ens_Config.Item where "_strWhere
	Do ..DebugTEST("strSQL = "_strSQL)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set qStatus = tStatement.%Prepare(strSQL)
	If $$$ISERR(qStatus) {
		Set msg = $system.Status.GetOneErrorText(qStatus)
		Do ..DebugTEST("Util:ValidateConfigItem %Prepare failed : "_msg)
		Quit qStatus
	}
	#dim rset As %SQL.StatementResult
	Set rset = tStatement.%Execute()
	If rset.%SQLCODE'=0 {
		//rset.%SQLCODE=-361 { WRITE !,"Query exists: ",rset.%Message }
		Do ..DebugTEST("Util:ValidateConfigItem rset.%SQLCODE : "_rset.%SQLCODE)
		Do ..DebugTEST("Util:ValidateConfigItem rset.%Message : "_rset.%Message)
		Quit $$$ERROR($$$GeneralError,"Unable to run SQL "_strSQL)
	}
	While rset.%Next() {
		Set recCount = rset.%ROWCOUNT
		Do ..DebugTEST("%ROWCOUNT : "_recCount)
		Set tEnabled = rset.Enabled
		Do ..DebugTEST("tEnabled : "_tEnabled)
	}
	Quit ($Get(tEnabled) = 1)
}

ClassMethod WriteFile(pFile As %String) As %Status
{
	Open pFile:("NRW"):5
    Use pFile
    Write "a line of data for the test file"
	Close pFile
	Quit $$$OK
}

}
