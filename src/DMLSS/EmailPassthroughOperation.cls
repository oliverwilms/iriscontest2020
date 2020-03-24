Class DMLSS.EmailPassthroughOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Parameter INVOCATION = "Queue";

Method SendMessage(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
	Set ^TEST2($I(^TEST2),"Adapter.SMTPServer") = ..Adapter.SMTPServer
	Set ^TEST2($I(^TEST2),"Adapter.Recipient") = ..Adapter.Recipient
	Set email=##class(%Net.MailMessage).%New()
	Do email.To.Insert("Oliver.Wilms@VA.GOV")
	Set ^TEST2($I(^TEST2),"pRequest.OriginalFilename")=pRequest.OriginalFilename
	Set ^TEST2($I(^TEST2),"pRequest.Stream")=pRequest.Stream
	Set ^TEST2($I(^TEST2),"pRequest.Stream.Size")=pRequest.Stream.Size
	Set tSC = email.TextData.CopyFrom(pRequest.Stream)
	Set ^TEST2($I(^TEST2),"TextData tSC")=$System.Status.GetOneErrorText(tSC)
	Set email.Subject = pRequest.OriginalFilename
	Set tSC=..Adapter.SendMail(email,.pFailedRecipients)
	Set ^TEST2($I(^TEST2),"SendMail tSC")=$System.Status.GetOneErrorText(tSC)
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
