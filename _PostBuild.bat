@echo off

call "%~dp0_Batch\processDir.bat" "%~dp0"
call "%~dp0_Batch\processDir.bat" "%~dp0VCL_DELPHIX_D6"

"C:\Programme\Inno Setup 5\iscc.exe" "%~dp0_InnoSetup\SpaceMission.iss"

call "%~dp0_Batch\processDir.bat" "%~dp0\_InnoSetup\Output"
