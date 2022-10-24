@echo off

:: install on the directory where this batch file resides
set PWD=%~dp0
pushd "%PWD%"

set OPENPLC_DIR=%PWD%..
set CONDA_DIR=%PWD%..\..\conda

echo ## cloning git repo
call "%CONDA_DIR%\condabin\conda" activate base
cd %OPENPLC_DIR%
git pull --recurse-submodules 
