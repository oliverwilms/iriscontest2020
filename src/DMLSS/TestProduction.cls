Class DMLSS.TestProduction Extends %UnitTest.TestProduction
{

Parameter PRODUCTION = "DMLSS.NewProduction";

Parameter IGNOREPRODUCTIONERRORS = 1;

/*
	Set ^UnitTestRoot = ""
	Do ##class(DMLSS.TestProduction).Run()
*/

Method OnBeforeProductionStart() As %Library.Status
{
	KILL ^TEST
	KILL ^TESTdmlss
	KILL ^CacheTempResponse($Job)

	Do ##class(DMLSS.Util).DebugTEST("OnBeforeProductionStart")
	Set ..MainDir = "C:\AET\TEST"
	Set tInputDir = ..MainDir_"\IN"
	Set tOutputDir = ..MainDir_"\OUT"
	
	Set s = ..ChangeSetting(
	"DMLSS.NewProduction","FileService", 
	"FilePath",tOutputDir,0)
	
	Do $$$AssertEquals(s,$$$OK)
	
	Set s0 = ..ChangeSetting(DMLSS.NewProduction,
	 "FileService","FilePath",tInputDir,0)
	
	Do $$$AssertEquals(s0,$$$OK)
	
	Set (s1,s2,s3,s4) = $$$OK
	//Set s1=$$$AssertStatusOK(..CreateMainDirTree())
	
	//Set s2 = $$$AssertStatusOK(..CleanUpDirectory(..HL7InputDir))
	//Set s3 = $$$AssertStatusOK(..CleanUpDirectory(..HL7OutputDir))
	
	//Set s3 = $$$AssertStatusOK(..CopyFile("ABC1.txt",..MainDir,tInputDir))
	
	//Set s4 = $$$AssertStatusOK(..CopyFile("dtp.txt",..MainDir,tInputDir))
	
	if 's||'s0||'s1||'s2||'s3||'s4 
	{Quit ..Error("Error in OnBeforeProductionStart()")}
	
	Quit $$$OK
}

Method OnAfterProductionStart() As %Status
{
	Do ##class(AET.TEST.Utility).DebugTEST("OnAfterProductionStart")
	Set pMessagesCount = 31700
	For ii=1:1:pMessagesCount {
		Write ii,"  "
		Do ##class(AET.TEST.Utility).DebugTEST("Loop "_ii)
		Set tSC = ..SendX12TCP()
	}
	Quit tSC
}

Method CheckResults(ByRef Log As %String, New As %String) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("CheckResults")
	Set tSC = $$$OK
	Set zA1 = $Get(^CacheTempResponse($Job,"A1"))
	Set zA4 = $Get(^CacheTempResponse($Job,"A4"))
	Set zAAA = $Get(^CacheTempResponse($Job,"AAA"))
	Set zERR = $Get(^CacheTempResponse($Job,"ERR"))
	Set total = zA1 + zA4 + zAAA + zERR
	Write "A1 = "_zA1,!
	Write "A4 = "_zA4,!
	Write "AAA = "_zAAA,!
	Write "ERR = "_zERR,!
	Write "Total: "_total,!
	Quit tSC
}

Method CheckErrors() As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("CheckErrors")
	Set tSC = $$$OK
	Set s = ..GetEventLog("error","","",.err,.new)
	//Set s1 = $$$AssertEquals(new,3,"Should be 3 new errors(found: "_+$Get(new)_")")
		
	Set text = $Get(err(1,"Text"))
	Set eText = "Test error case"
	//Set s2 = $$$AssertTrue(text[eText,"Should contain '"_eText_"'(found: '"_text_"')")
	
	//if 's1||'s2 set tSC=..Error("Expected error entries don't match")
	
	Quit tSC
}

Method MergeMessageLog() As %Status
{
	Set tSC = $$$OK

	Quit tSC
}

Method SendX12TCP() As %Status
{
	#dim response As AET.ResStream
	//Do ##class(AET.TEST.Utility).DebugTEST("SendX12TCP")
	Set tSC = $$$OK
	Set (xNPI,xRBB,xRNT,xSSN,xSta,xSto) = ""
	Set tX12 = ##class(AET.TEST.X12Factory).MakeX12(.xNPI,.xRBB,.xRNT,.xSSN,.xSta,.xSto)

	Set request = ##class(AET.TEST.Utility).makeTestStreamRequest(tX12)
	Set tSC = ..SendRequest( "AET.TCPPassOper" ,request, .response,1,40)
	Set strMessage = response
	//Do ##class(AET.TEST.Utility).DebugTEST(strMessage)
	Set tSC = ##class(AET.TEST.Utility).zAnalyseResponse(response,.pA1,.pA4,.pAAA,.pERR)
	/*
	&SQL(Select TOP 1 ID,ReferenceNumber,xNPI,xREFxBB,xREFxNT,xSSN,xStartDate,xStopDate 
	INTO :rId,tRef,xNPI,xRBB,xRNT,xSSN,xSta,xSto FROM AET.Request
	ORDER BY ID DESC
	)
	
	Set r = $$$AssertEquals(SQLCODE, 0, "AET.Request Query")
	*/
	Set r = 1	
	If r {
		//Set r1=$$$AssertEquals(Rea,"rule#1:when#1", "Rule:("_Rea_")")
		//Set r2=$$$AssertTrue(Ret["TutorialHL7FileOperation","Target: "_Ret)
		&SQL(Select TOP 1 ID,ReferenceNumber 
		INTO :sId,tRefNum FROM AET_TEST.MessageLog
		ORDER BY ID DESC
		)

		Set s = $$$AssertEquals(SQLCODE, 0, "AET_TEST.MessageLog Query")
		If s {
			/*
			Set t = $$$AssertEquals(tRef, tRefNum, "ReferenceNumber Compare")
			*/
			Set t = 1
			If t {
				Set objMessageLog = ##class(AET.TEST.MessageLog).%OpenId(sId)
				If $IsObject(objMessageLog) {
					Set objMessageLog.xNPI = xNPI
					Set objMessageLog.xREFxBB = xRBB
					Set objMessageLog.xREFxNT = xRNT
					Set objMessageLog.xSSN = xSSN
					Set objMessageLog.xStartDate = ##class(%Library.Date).DisplayToLogical(xSta)
					Set objMessageLog.xStopDate = ##class(%Library.Date).DisplayToLogical(xSto)
					Set objMessageLog.zA1 = pA1
					Set objMessageLog.zA4 = pA4
					Set objMessageLog.zAAA = pAAA
					Set objMessageLog.zERR = pERR
					Set tSC = objMessageLog.%Save()
					Do ##class(AET.TEST.Utility).DebugTESTStatus(tSC, "MessageLog %Save = ")
				}
			}
		}
	}
	//Do $$$AssertEquals(response.StringValue,"OK","Response should contain OK.")
	Quit tSC
}

}
