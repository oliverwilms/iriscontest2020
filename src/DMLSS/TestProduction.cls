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
	Do ##class(DMLSS.Util).DebugTEST("Attempt to change FileService FilePath setting...")
	Set s1 = ..ChangeSetting("DMLSS.Production","FileService","FilePath",dir,0)
    Do ##class(DMLSS.Util).DebugTEST($System.Status.GetOneErrorText(s1))
	Do $$$AssertEquals(s1,$$$OK)
	Do ##class(DMLSS.Util).DebugTEST("Attempt to change EmailOperation FailureTimeout setting...")
	Set s2 = ..ChangeSetting("DMLSS.Production","EmailOperation","FailureTimeout",6,0)
    Do ##class(DMLSS.Util).DebugTEST($System.Status.GetOneErrorText(s2))
	Do $$$AssertEquals(s2,$$$OK)
	if 's1||'s2 {
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
		Set tSC = ..PutFile("testFile001.txt")
	}
	Quit tSC
}

Method CheckResults(ByRef Log As %String, New As %String) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("CheckResults")
	Set tSC = $$$OK
	Quit tSC
}

Method CheckErrors() As %Status
{
	// Expect 3 errors
	Do ##class(DMLSS.Util).DebugTEST("CheckErrors")
	Kill ^TESTdmlss("CheckErrors")
	Set tSC = $$$OK
	Set s = ..GetEventLog("error","","",.err,.new)
	Merge ^TESTdmlss("CheckErrors","err")=err
	Merge ^TESTdmlss("CheckErrors","new")=new
	
	Set s1 = $$$AssertEquals(new,3,"Should be 3 new errors(found: "_+$Get(new)_")")
		
	Set text = $Get(err(1,"Text"))
	Set eText = "#6031:"
	//Write "text = "_text,!
	Set s2 = $$$AssertTrue(text[eText,"Should contain '"_eText_"'(found: '"_text_"')")
	
	if 's1||'s2 set tSC=..Error("Expected error entries don't match")
	//Do ##class(DMLSS.Util).DebugTEST(text)
	Quit tSC
}

Method OnAfterProductionStop() As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("OnAfterProductionStop")
	Set pCount = 1
	For ii=1:1:pCount {
		Write ii,"  "
		Do ##class(DMLSS.Util).DebugTEST("Loop "_ii)
		Set tSC = ..RemoveFile("testFile001.txt")
	}
	Quit tSC
}

Method PutFile(pFilename As %String = "") As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("PutFile")
	Set tSC = $$$OK
	Set dir = ##class(%SYSTEM.Process).CurrentDirectory()  ; determine InterSystems IRIS directory
	Do ##class(DMLSS.Util).DebugTEST("Directory is "_dir)
	If (pFilename = "") Set pFilename = "TestFile.txt"
	Set tFile = dir_pFilename
    Quit ##class(DMLSS.Util).WriteFile(tFile)
}

Method RemoveFile(pFilename As %String = "") As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("RemoveFile")
	Set tSC = $$$OK
	Set dir = ##class(%SYSTEM.Process).CurrentDirectory()  ; determine InterSystems IRIS directory
	Do ##class(DMLSS.Util).DebugTEST("Directory is "_dir)
	If (pFilename = "") Set pFilename = "TestFile.txt"
	Set tFile = dir_pFilename
	Set tReturn	= ##class(%File).Delete(tFile)
	Do ##class(DMLSS.Util).DebugTEST("##class(%File).Delete(tFile) return "_tReturn)
    Quit tSC
}

}
