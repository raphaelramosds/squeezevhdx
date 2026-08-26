# Squeeze VHDX

## Descrição

Squeeze VHDX é um utilitário de linha de comando projetado para compactar discos virtuais montados pelo Docker Desktop e WSL no Windows. 

A vantagem de usar esse utilitário é que ele reduz o tamanho desses discos e, por conseguinte, liberando espaço em disco. Ele é especialmente útil para usuários que utilizam o Docker Desktop e WSL, pois esses ambientes frequentemente criam arquivos VHDX que podem crescer significativamente ao longo do tempo.

## Uso

Basta executar o `main.bat` como Administrador. Os discos do Docker Desktop e do WSL são localizados automaticamente, sem necessidade de configuração.

> O script só processará os arquivos se o Docker e o WSL estiverem completamente desligados (`wsl --shutdown`).