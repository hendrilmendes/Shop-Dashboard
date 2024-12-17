@echo off
title Iniciando o Servidor - Backend

echo.
echo ================================================
echo        INICIANDO O SERVIDOR...
echo ================================================
echo.

:: Definindo o caminho do projeto
set "PROJECT_PATH=C:\Users\Hendril\Documents\GitHub\Shop-Backend\backend"

:: Acessando o diretório do projeto
cd /d "%PROJECT_PATH%"

:: Mensagem antes de iniciar o servidor
echo.
echo ================================================
echo O servidor sera iniciado. Pressione Ctrl+C para parar.
echo ================================================

:: Iniciando o servidor
dart run lib/server.dart

pause
