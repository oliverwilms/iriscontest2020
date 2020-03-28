Class DMLSS.Production Extends Ens.Production
{

ClassMethod OnStart(pTimeStarted As %String) As %Status
{
	//Kill ^TESTdmlss
	Do ##class(DMLSS.Util).DebugTEST("Production Time Started "_pTimeStarted)
	Quit $$$OK
}

ClassMethod OnStop(pTimeStopped As %String, pForced As %Boolean) As %Status
{
	Do ##class(DMLSS.Util).DebugTEST("Production Time Stopped "_pTimeStopped)
	Do ##class(DMLSS.Util).DebugTEST("Forced "_pForced)
	Quit $$$OK
}

XData ProductionDefinition
{
<Production Name="DMLSS.Production" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="FileService" Category="" ClassName="DMLSS.FilePassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/intersystems/irishealth/mgr/oliver</Setting>
    <Setting Target="Adapter" Name="FileSpec">testFile???.txt</Setting>
    <Setting Target="Host" Name="TargetConfigNames">EmailOperation</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="EmailOperation" Category="" ClassName="DMLSS.EmailPassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="From">owilms@oliverwilms.com</Setting>
    <Setting Target="Adapter" Name="Recipient">oliverwilms@oliverwilms.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtp.oliverwilms.com</Setting>
    <Setting Target="Adapter" Name="Cc"></Setting>
    <Setting Target="Host" Name="Domain"></Setting>
  </Item>
  <Item Name="TCPService" Category="" ClassName="DMLSS.TCPPassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="GetStreamName">0</Setting>
    <Setting Target="Adapter" Name="Port">3000</Setting>
    <Setting Target="Adapter" Name="QSize">0</Setting>
    <Setting Target="Adapter" Name="StayConnected">0</Setting>
  </Item>
  <Item Name="OperationMailman" Category="" ClassName="DMLSS.TCPPassthroughOperation" PoolSize="2" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">127.0.0.1</Setting>
    <Setting Target="Adapter" Name="Port">3000</Setting>
  </Item>
  <Item Name="Ens.Alert" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
  </Item>
</Production>
}

}
