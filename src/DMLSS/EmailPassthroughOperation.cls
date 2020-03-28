Class DMLSS.EmailPassthroughOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Parameter INVOCATION = "Queue";

Method SendMessage(
	pRequest As Ens.StreamContainer,
	Output pResponse As Ens.Response) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("DMLSS.EmailPassthroughOperation SendMessage")
	Quit:'$IsObject(pRequest.Stream) $$$ERROR($$$EnsErrGeneral,"No Stream contained in StreamContainer Request")
	Do ##class(DMLSS.Util).DebugTEST("pRequest received "_pRequest)
	Do ##class(DMLSS.Util).DebugTEST("pRequest.OriginalFilename "_pRequest.OriginalFilename)
	Do ##class(DMLSS.Util).DebugTEST("pRequest.Stream "_pRequest.Stream)
	Do ##class(DMLSS.Util).DebugTEST("pRequest.Stream.Size "_pRequest.Stream.Size)
	Do ##class(DMLSS.Util).DebugTEST("Adapter.SMTPServer "_..Adapter.SMTPServer)
	Do ##class(DMLSS.Util).DebugTEST("Adapter.Recipient "_..Adapter.Recipient)
	Set email=##class(%Net.MailMessage).%New()
	Set tSC = email.ContentTransferEncodingSet("7bit")
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	//Set tSC = email.TextData.Write("test1234")
	//Set tSC = email.AttachStream(pRequest.Stream,pRequest.OriginalFilename,0)
	Set tSC = email.TextData.CopyFrom(pRequest.Stream)
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	//Set email.Subject = pRequest.OriginalFilename
	Set email.Subject = ##class(%File).GetFilename(pRequest.OriginalFilename)
	Do ##class(DMLSS.Util).DebugTEST("before ..Adapter.SendMail")
	Set tSC=..Adapter.SendMail(email,.pFailedRecipients)
	Do ##class(DMLSS.Util).DebugTEST("after ..Adapter.SendMail")
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	Quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StreamContainer"> 
		<Method>SendMessage</Method>
	</MapItem>
</MapItems>
}

}
