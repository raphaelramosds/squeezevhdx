@echo off
setlocal enabledelayedexpansion
:: Verifica privilégios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
echo [ERRO] Execute este script como Administrador.
pause
exit /b
)

:: Verifica caminhos candidatos de arquivos .vhdx
set "DOCKER_DATA_VHDX=%USERPROFILE%\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
if exist "%DOCKER_DATA_VHDX%" (
	echo Docker data path exists: %DOCKER_DATA_VHDX%
) else (
	echo [AVISO] Docker data path nao encontrado.
)

set "LOCAL_WSL_PATH=%USERPROFILE%\AppData\Local\wsl"
if exist "%LOCAL_WSL_PATH%" (
	echo Local WSL path exists: %LOCAL_WSL_PATH%
) else (
	echo [AVISO] Local WSL path nao encontrado.
)

for /f "delims=" %%a in ('dir /b "%LOCAL_WSL_PATH%" 2^>nul') do (
    set "LOCAL_WSL_VHDX=%LOCAL_WSL_PATH%\%%a"
    goto :done
)
:done
echo Local WSL vhdx path exists: %LOCAL_WSL_VHDX%

set "RESOURCES_WSL_VHDX=C:\Program Files\Docker\Docker\resources\wsl\ext4.vhdx"

if exist "%RESOURCES_WSL_VHDX%" (
	echo Resources WSL vhdx path exists: %RESOURCES_WSL_VHDX%
) else (
	echo [AVISO] Resources WSL vhdx path nao encontrado.
)

:: Monta a lista de VHDX a partir dos caminhos ja mapeados acima (*_VHDX)
set "LISTA_VHDX="
if exist "%DOCKER_DATA_VHDX%" set LISTA_VHDX=%LISTA_VHDX% "%DOCKER_DATA_VHDX%"
if exist "%LOCAL_WSL_VHDX%" set LISTA_VHDX=%LISTA_VHDX% "%LOCAL_WSL_VHDX%"
if exist "%RESOURCES_WSL_VHDX%" set LISTA_VHDX=%LISTA_VHDX% "%RESOURCES_WSL_VHDX%"

if not defined LISTA_VHDX (
echo [ERRO] Nenhum arquivo VHDX foi encontrado para compactar.
pause
exit /b
)

echo Iniciando processo de compactacao...
:: Loop para processar cada VHDX mapeado
for %%A in (%LISTA_VHDX%) do (
set "VHD_FILE=%%~A"
if exist "!VHD_FILE!" (
echo.
echo --------------------------------------------------
echo Processando: !VHD_FILE!
:: Cria script temporário para o Diskpart
set "DP_SCRIPT=%temp%\compact_vhdx.txt"
(
echo select vdisk file="!VHD_FILE!"
echo attach vdisk readonly
echo compact vdisk
echo detach vdisk
) > "!DP_SCRIPT!"
:: Executa o Diskpart
diskpart /s "!DP_SCRIPT!"
:: Apaga o script temporário
del "!DP_SCRIPT!"
) else (
echo.
echo [AVISO] Caminho nao encontrado: !VHD_FILE!
)
)
echo.
echo --------------------------------------------------
echo Limpando o diretorio TEMP...
:: Remove todos os arquivos do diretorio TEMP
del /f /s /q "%TEMP%\*.*" >nul 2>&1
:: Remove todos os subdiretorios do diretorio TEMP
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1

echo.
echo --------------------------------------------------
echo Esvaziando a Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo.
echo --------------------------------------------------
echo Concluido!
pause