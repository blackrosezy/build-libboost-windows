@echo off
setlocal EnableDelayedExpansion 

echo Preparing workspace...

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set CP="%CD%\bin\unxutils\cp.exe"
set MKDIR="%CD%\bin\unxutils\mkdir.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set SED="%CD%\bin\unxutils\sed.exe"
set WGET="%CD%\bin\unxutils\wget.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"
set VSPC="%CD%\bin\vspc\vspc.exe"

REM Housekeeping
%RM% -rf tmp_*
%RM% -rf third-party
%RM% -rf boost.7z*
%RM% -rf build_*.txt

REM Get download url.
echo Get download url...
%XIDEL% "http://www.boost.org/" --follow "(//div[@id='downloads']/ul/li/div/a)[3]/@href" -e "//a[text()[contains(.,'7z')]]/@href" > tmp_url

set /p url=<tmp_url

REM Download latest curl and rename to fltk.tar.gz
echo Downloading latest stable boost...
%WGET% "%url%" -O boost.7z

echo Extracting boost.7z ... (Please wait, this may take a while)
%SEVEN_ZIP% x boost.7z -y -otmp_libboost | FIND /V "ing  " | FIND /V "Igor Pavlov"

cd %ROOT_DIR%\tmp_libboost\boost*
CALL bootstrap.bat
b2 install toolset=msvc variant=release,debug link=static,shared threading=multi address-model=32 --prefix=%ROOT_DIR%\third-party\libboost --without-python

REM copy files
echo Copying output files...
cd %ROOT_DIR%\third-party\libboost\lib
%MKDIR% -p lib-release lib-debug dll-release dll-debug
move lib*-mt-gd* lib-debug
move lib* lib-release
move *-mt-gd* dll-debug
move *-mt-* dll-release

cd %ROOT_DIR%\third-party\libboost\include\boost*
move boost ..\tmp
cd ..
%RM% -rf boost*
ren tmp boost

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*
%RM% boost.7z

exit /b
