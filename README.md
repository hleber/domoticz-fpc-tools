# domoticz-fpc-tools
Tools for Domoticz, connecting devices via api and small utility applications

Usage: compile with freepascal

On debian based systems: install first

  apt install fpc
  
the compiled application should be copied to the script folder of domoticz (e.g. /opt/domoticz/scripts)

the compiled application can be used in a domoticz trigger or called from crontab.

the file iodata.pas and dmzmail.pas must be adjusted to the input/output configuration of domoticz
