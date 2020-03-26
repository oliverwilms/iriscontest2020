Class DMLSS.TCPPassthroughOperation Extends Ens.BusinessOperation [ ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "EnsLib.TCP.CountedOutboundAdapter";

/// Name to transmit as the name of the stream content. May include timestamp specifiers. The %f specifier if present will be 
/// replaced with the name of the stream's original source filename (stripped of characters illegal in target filenames).<p>
/// See the method Ens.Util.File.CreateTimestamp() for documentation of timestamping options.<p>
/// If empty, the stream content will be sent as a single counted block without any associated stream name.
Property Streamname As %String(MAXLEN = 1000) [ InitialExpression = "%f" ];

Parameter SETTINGS As %String = "Streamname:Connection";

Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("DMLSS.TCPPassthroughOperation OnMessage")
	Quit:'$IsObject(pRequest.Stream) $$$ERROR($$$EnsErrGeneral,"No Stream contained in StreamContainer Request")
	Do ##class(DMLSS.Util).DebugTEST("pRequest received "_pRequest)
	Do ##class(DMLSS.Util).DebugTEST("Streamname "_..Streamname)
	If ""'=..Streamname {
		Set tFilename="Passthru:"_##class(Ens.Util.File).CreateTimestamp(##class(%File).GetFilename(pRequest.OriginalFilename),..Streamname)
		Do ##class(DMLSS.Util).DebugTEST("tFilename "_tFilename)
		Set tGR=..Adapter.GetReply, ..Adapter.GetReply=0
		$$$catTRACE("protocol","Sending name block:'"_tFilename_"'")
		Do ##class(DMLSS.Util).DebugTEST("[protocol] Sending name block:'"_tFilename_"'")
		Set tSC=..Adapter.SendMessageString(tFilename)
		Do ##class(DMLSS.Util).DebugStatus(tSC)
		Quit:$$$ISERR(tSC) tSC
		Set ..Adapter.GetReply=tGR
	}
	Do ##class(DMLSS.Util).DebugTEST("before SendMessageStream")
	Set tSC=..Adapter.SendMessageStream(pRequest.Stream,.tReplyStream)
	Do ##class(DMLSS.Util).DebugTEST("after SendMessageStream")
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	Quit:$$$ISERR(tSC) tSC
	If ..Adapter.GetReply {
		Set tReply=tReplyStream.Read()
		Do ##class(DMLSS.Util).DebugTEST("tReply "_tReply)
		If $Case(tReply,"":0,"OK":0,:1) {
			Set tSC=$$$ERROR($$$EnsErrGeneral,"Remote acknowledgement not OK:"_$E(tReply,1,1000))
		}
	}
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	Quit tSC
}

}
