@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=C:\Users\Raphael\Documents\Github\Deploy-Squeeze-VHDX\Squeeze-VHDX-0.2.0.EXE
REM BFCPEICON=C:\Users\Raphael\Documents\Github\Squeeze-VHDX\icon.ico
REM BFCPEICONINDEX=1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=1
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=0.0.2.0
REM BFCPEVERPRODUCT=Squeeze VHDX
REM BFCPEVERDESC=Compacts VHDX to free up disk space
REM BFCPEVERCOMPANY=raphaelramosds
REM BFCPEVERCOPYRIGHT=Raphael
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=30
REM BFCPEWINDOWWIDTH=120
REM BFCPEWTITLE=Squeeze VHDX
REM BFCPEOPTIONEND
@echo off
setlocal enabledelayedexpansion

echo.
echo  .###. .###. #...# ##### ##### ##### ##### #...# #...# ####. #...#
echo  #.... #...# #...# #.... #.... ....# #.... #...# #...# #...# #...#
echo  #.... #...# #...# #.... #.... ...#. #.... #...# #...# #...# .#.#.
echo  .###. #...# #...# ####. ####. ..#.. ####. #...# ##### #...# ..#..
echo  ....# #.#.# #...# #.... #.... .#... #.... #...# #...# #...# .#.#.
echo  ....# #..#. #...# #.... #.... #.... #.... .#.#. #...# #...# #...#
echo  ###.. .##.# .###. ##### ##### ##### ##### ..#.. #...# ####. #...#
echo.

call :print_header "Verificando privilegios..."
:: Verifica privilégios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
echo [ERRO] Execute este script como Administrador.
pause
exit /b
)
echo Privilegios de Administrador confirmados.

call :print_header "Verificando processos WSL..."
:: Verifica se alguma distro/VM do WSL ainda esta em execucao
set "WSL_RUNNING="
tasklist /fi "imagename eq vmmemWSL" 2>nul | find /i "vmmemWSL" >nul
if %errorLevel% equ 0 set "WSL_RUNNING=1"
tasklist /fi "imagename eq Vmmem" 2>nul | find /i "Vmmem" >nul
if %errorLevel% equ 0 set "WSL_RUNNING=1"

if defined WSL_RUNNING (
echo.
echo [ERRO] O WSL ainda esta em execucao. Os arquivos VHDX nao podem ser compactados enquanto estiverem em uso.
echo.
echo Reinicie o computador, ou entao:
echo   1. Feche o Docker Desktop.
echo   2. Feche terminais WSL e o VSCode, caso tenha uma conexao remota ao WSL aberta.
echo   3. Execute "wsl --shutdown" para encerrar o processo VmmemWSL.
echo.
pause
exit /b
)
echo Nenhum processo WSL em execucao.

call :print_header "Mapeando arquivos VHDX candidatos..."
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
    set "LOCAL_WSL_VHDX=%LOCAL_WSL_PATH%\%%a\ext4.vhdx"
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

call :print_header "Montando lista de VHDX..."
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
echo Lista de VHDX: %LISTA_VHDX%

call :print_header "Compactando arquivos VHDX..."
:: Loop para processar cada VHDX mapeado
for %%A in (%LISTA_VHDX%) do (
set "VHD_FILE=%%~A"
if exist "!VHD_FILE!" (
echo.
echo Processando: !VHD_FILE!...
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

:: TODO: TEMP removal is not trivial, since the script itself may be running from %TEMP%
@REM call :print_header "Limpando diretorio TEMP..."
:: Remove todos os arquivos do diretorio TEMP
@REM del /f /s /q "%TEMP%\*.*" >nul 2>&1
:: Remove todos os subdiretorios do diretorio TEMP
@REM for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
@REM echo Diretorio TEMP limpo.

@REM call :print_header "Esvaziando a Lixeira..."
@REM powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
@REM echo Lixeira esvaziada.

call :print_header "Concluido"
echo Pressione qualquer tecla para fechar o programa...
pause >nul
exit /b 0

:print_header
for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format 'dd/MM/yyyy HH:mm:ss'"') do set "HEADER_TS=%%T"
echo.
echo [!HEADER_TS!] %~1
echo.
exit /b 0
