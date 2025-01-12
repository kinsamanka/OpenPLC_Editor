@echo off

:: install on the directory where this batch file resides
set PWD=%~dp0
pushd "%PWD%"

set OPENPLC_DIR=%PWD%openplc
set CONDA_DIR=%PWD%conda
set CONDA_FNAME=Miniconda3-latest-Windows-x86_64.exe
set CONDA_URL=https://repo.anaconda.com/miniconda/%CONDA_FNAME%

goto :main

::
:: start of functions
::

:download_installer
echo ## Downloading Miniconda installer ...
bitsadmin /transfer getminiconda /download /priority normal %CONDA_URL% "%PWD%%CONDA_FNAME%"
exit /b 0

:install_conda
setlocal
echo ## Installing miniconda environment to %CONDA_DIR%, please wait...
%CONDA_FNAME% /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=%CONDA_DIR%
del %CONDA_FNAME%
echo ## basic miniconda installed
call "%CONDA_DIR%\condabin\conda" update -n base -yc defaults --all
call "%CONDA_DIR%\condabin\conda" activate base
echo ## installing required packages
call conda install -yc conda-forge wxpython platformio git pypubsub
call conda create -n editor -yc conda-forge python=2.7 m2w64-gcc
call conda install -n editor -yc free wxpython
call conda activate editor

pip install future zeroconf==0.19.1 numpy==1.16.5 matplotlib==2.0.2 lxml==4.6.2 pyro sslpsk pyserial

conda deactivate
endlocal
exit /b 0

:clone_repo
echo ## cloning git repo
setlocal
call "%CONDA_DIR%\condabin\conda" activate base
git clone --recursive --depth=1 https://github.com/kinsamanka/OpenPLC_Editor "%OPENPLC_DIR%"
endlocal
exit /b 0

:start_ui
setlocal
call "%CONDA_DIR%\condabin\conda" activate editor
start pythonw "%OPENPLC_DIR%\editor\Beremiz.py"
endlocal
exit /b 0

:main
if exist "%CONDA_DIR%" (
  if exist "%OPENPLC_DIR%" (
    call :start_ui
  ) else (
    :: continue aborted install
    call :clone_repo
    call :start_ui
  )
  exit /b 0
)

if not exist "%CONDA_FNAME%" call :download_installer

call :install_conda
call :clone_repo
call :start_ui
