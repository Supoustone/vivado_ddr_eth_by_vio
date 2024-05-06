//
// Vivado(TM)
// rundef.js: a Vivado-generated Runs Script for WSH 5.1/5.6
// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//

var WshShell = new ActiveXObject( "WScript.Shell" );
var ProcEnv = WshShell.Environment( "Process" );
var PathVal = ProcEnv("PATH");
if ( PathVal.length == 0 ) {
  PathVal = "D:/software_download_zc/Vivado/download/SDK/2018.3/bin;D:/software_download_zc/Vivado/download/Vivado/2018.3/ids_lite/ISE/bin/nt64;D:/software_download_zc/Vivado/download/Vivado/2018.3/ids_lite/ISE/lib/nt64;D:/software_download_zc/Vivado/download/Vivado/2018.3/bin;";
} else {
  PathVal = "D:/software_download_zc/Vivado/download/SDK/2018.3/bin;D:/software_download_zc/Vivado/download/Vivado/2018.3/ids_lite/ISE/bin/nt64;D:/software_download_zc/Vivado/download/Vivado/2018.3/ids_lite/ISE/lib/nt64;D:/software_download_zc/Vivado/download/Vivado/2018.3/bin;" + PathVal;
}

ProcEnv("PATH") = PathVal;

var RDScrFP = WScript.ScriptFullName;
var RDScrN = WScript.ScriptName;
var RDScrDir = RDScrFP.substr( 0, RDScrFP.length - RDScrN.length - 1 );
var ISEJScriptLib = RDScrDir + "/ISEWrap.js";
eval( EAInclude(ISEJScriptLib) );


ISEStep( "vivado",
         "-log ddr_to_eth_fifo_w9xd4096.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source ddr_to_eth_fifo_w9xd4096.tcl" );



function EAInclude( EAInclFilename ) {
  var EAFso = new ActiveXObject( "Scripting.FileSystemObject" );
  var EAInclFile = EAFso.OpenTextFile( EAInclFilename );
  var EAIFContents = EAInclFile.ReadAll();
  EAInclFile.Close();
  return EAIFContents;
}
