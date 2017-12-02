@echo off

RUNAS /user:Administrator
CLS
java -Djava.net.preferIPv4Stack=true -Xms256m -Xmx256m -jar "%~dp0ArmA3Sync.jar" -console

pause