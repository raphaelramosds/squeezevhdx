@echo off
setlocal enabledelayedexpansion
:: Verifica privilégios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
echo [ERRO] Execute este script como Administrador.
pause
exit /b
)
:: Define o caminho do arquivo no diretório do Usuário
set "LISTA_VHDX=%USERPROFILE%\.vhdxpaths"

:: Verifica se o arquivo de lista existe
if not exist "%LISTA_VHDX%" (
echo [ERRO] O arquivo %LISTA_VHDX% nao foi encontrado.
pause
exit /b
)
echo Iniciando processo de compactacao...
:: Loop para ler cada linha do arquivo .vhdxpaths
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
echo Concluido!
pause