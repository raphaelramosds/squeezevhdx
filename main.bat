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
	echo Docker data path exists.
) else (
	echo [AVISO] Docker data path nao encontrado: %DOCKER_DATA_VHDX%
)

set "LOCAL_WSL_PATH=%USERPROFILE%\AppData\Local\wsl"
if exist "%LOCAL_WSL_PATH%" (
	echo Local WSL path exists.
) else (
	echo [AVISO] Local WSL path nao encontrado: %LOCAL_WSL_PATH%
)

for /f "delims=" %%a in ('dir /b %LOCAL_WSL_PATH% 2^>nul') do (
    set "LOCAL_WSL_VHDX=%%a"
    goto :done
)
:done
echo Local WSL vhdx path exists: %LOCAL_WSL_VHDX%

set "RESOURCES_WSL_VHDX=C:\Program Files\Docker\Docker\resources\wsl\data\ext4.vhdx"

if exist "%RESOURCES_WSL_VHDX%" (
	echo Resources WSL ext4 path exists.
) else (
	echo [AVISO] Resources WSL ext4 path nao encontrado: %RESOURCES_WSL_VHDX%
)

:: Define o caminho do arquivo no diretório do Usuário
set "LISTA_VHDX=%USERPROFILE%\.vhdxs"

:: Verifica se o arquivo de lista existe
if not exist "%LISTA_VHDX%" (
echo [ERRO] O arquivo %LISTA_VHDX% nao foi encontrado.
pause
exit /b
)
echo Iniciando processo de compactacao...
:: Loop para ler cada linha do arquivo .vhdxs
for /f "usebackq tokens=*" %%A in ("%LISTA_VHDX%") do (
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