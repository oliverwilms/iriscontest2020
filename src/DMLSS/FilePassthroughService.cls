/// Accepts files from the File Inbound Adapter, encapsulates each one as a Stream object within a StreamContainer object and forwards the container object to the configured target configuration item or items.
Class DMLSS.FilePassthroughService Extends Ens.BusinessService [ ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

/// Configuration item(s) to which to send file stream messages
Property TargetConfigNames As %String(MAXLEN = 1000);

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Parameter CONTAINERCLASS = "Ens.StreamContainer";

/// Wrap the input stream object in a StreamContainer message object and send it.
/// If the adapter has a value for ArchivePath, send async; otherwise send synchronously
/// to ensure that we don't return to the Adapter and let it delete the file before the
/// target Config Item is finished processing it.
Method OnProcessInput(pInput As %Stream.Object, pOutput As %RegisteredObject) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("DMLSS.FilePassthroughService OnProcessInput")
	Do ##class(DMLSS.Util).DebugTEST("pInput received "_pInput)
	Set tSource=$G(pInput.Attributes("Filename"),pInput), pInput=$classmethod(..#CONTAINERCLASS,"%New",pInput)
	Do ##class(DMLSS.Util).DebugTEST("tSource "_tSource)
	Do ##class(DMLSS.Util).DebugTEST("pInput is now "_pInput)
	Do ##class(DMLSS.Util).DebugTEST("pInput.Stream "_pInput.Stream)
	Do ##class(DMLSS.Util).DebugTEST("pInput.Stream.Size "_pInput.Stream.Size)
	Set tSC=..resolveAndIndex(pInput) Quit:$$$ISERR(tSC) tSC
	Set tWorkArchive=(""'=..Adapter.ArchivePath)&&(..Adapter.ArchivePath=..Adapter.WorkPath || (""=..Adapter.WorkPath && (..Adapter.ArchivePath=..Adapter.FilePath)))
	$$$SyncCommitSet(tSyncCommit)
	For iTarget=1:1:$L(..TargetConfigNames, ",") { Set tOneTarget=$ZStrip($P(..TargetConfigNames,",",iTarget),"<>W")  Continue:""=tOneTarget
		Do ##class(DMLSS.Util).DebugTEST("iTarget "_iTarget)
		Do ##class(DMLSS.Util).DebugTEST("tOneTarget "_tOneTarget)
		If '(##class(DMLSS.Util).ValidateConfigItem(tOneTarget)) Continue  // Skip disabled target
		$$$sysTRACE("Sending input Stream "_pInput.Stream_"("_pInput.Stream.Size_")"_$S(tWorkArchive:" Async",1:" Sync")_" from '"_tSource_"' to '"_tOneTarget_"'")
		Set tTRACE=("Sending input Stream "_pInput.Stream_"("_pInput.Stream.Size_")"_$S(tWorkArchive:" Async",1:" Sync")_" from '"_tSource_"' to '"_tOneTarget_"'")
		Do ##class(DMLSS.Util).DebugTEST(tTRACE)
		If tWorkArchive {
			Do ##class(DMLSS.Util).DebugTEST("before SendRequestAsync")
			Set tSC1=..SendRequestAsync(tOneTarget,pInput)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
			Do ##class(DMLSS.Util).DebugTEST("after SendRequestAsync")
		} Else {
			#; If not archiving send Sync to avoid Adapter deleting file before Operation gets it
			Do ##class(DMLSS.Util).DebugTEST("before SendRequestSync")
			Set tSC1=..SendRequestSync(tOneTarget,pInput)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
			Do ##class(DMLSS.Util).DebugTEST("after SendRequestSync")
		}
	}
	Do ##class(DMLSS.Util).DebugTEST("tSyncCommit "_tSyncCommit)
	$$$SyncCommitClear(tSyncCommit)
	Do ##class(DMLSS.Util).DebugTEST("after $$$SyncCommitClear")
	Do ##class(DMLSS.Util).DebugStatus(tSC)
	Quit tSC
}

/// Initialize and perform requested validation if any
Method resolveAndIndex(pDoc As %Persistent) As %Status
{
	Quit $$$OK
}

/// Return an array of connections for drawing lines on the config diagram
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray,pItem)
	If pItem.GetModifiedSetting("TargetConfigNames",.tValue) {
		For i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
	}
}

}
