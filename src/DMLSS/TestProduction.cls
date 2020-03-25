Class DMLSS.TestProduction Extends %UnitTest.TestProduction
{

Parameter PRODUCTION = "DMLSS.Production";

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
    Set dir = ##class(%SYSTEM.Process).CurrentDirectory()  ; determine InterSystems IRIS directory
	Do ##class(DMLSS.Util).DebugTEST("Directory is "_dir)
		
	Set s = ..ChangeSetting(
	"DMLSS.Production","FileService", 
	"FilePath",dir,0)
	
	Do $$$AssertEquals(s,$$$OK)
	
	if 's {
        Do ##class(DMLSS.Util).DebugTEST($System.Status.GetOneErrorText(s))
        Quit ..Error("Error in OnBeforeProductionStart()")
    }
	
	Quit $$$OK
}

Method OnAfterProductionStart() As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("OnAfterProductionStart")
	Set pCount = 1
	For ii=1:1:pCount {
		Write ii,"  "
		Do ##class(DMLSS.Util).DebugTEST("Loop "_ii)
		Set tSC = ..PutFile()
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
	Write "text = "_text,!
	//Set s2 = $$$AssertTrue(text[eText,"Should contain '"_eText_"'(found: '"_text_"')")
	
	//if 's1||'s2 set tSC=..Error("Expected error entries don't match")
	Do ##class(DMLSS.Util).DebugTEST(text)
	Quit tSC
}

Method PutFile() As %Status
{
	#dim response As AET.ResStream
	Do ##class(AET.TEST.Utility).DebugTEST("PutFile")
	Set tSC = $$$OK
	Set dir = ##class(%SYSTEM.Process).CurrentDirectory()  ; determine InterSystems IRIS directory
	Do ##class(AET.TEST.Utility).DebugTEST("Directory is "_dir)
	Set tFile = dir_"TestFile.txt"
    Set tSC = ##class(DMLSS.Util).WriteFile(tFile)
	Quit tSC
}

}
