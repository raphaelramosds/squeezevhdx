# Squeeze VHDX

## Descrição

Squeeze VHDX é um utilitário de linha de comando projetado para compactar arquivos `.vhdx` montados pelo Docker Desktop e WSL no Windows. 

A vantagem de usar esse utilitário é que ele reduz o tamanho dos arquivos `.vhdx` e, por conseguinte, liberando espaço em disco. Ele é especialmente útil para usuários que utilizam o Docker Desktop e WSL, pois esses ambientes frequentemente criam arquivos `.vhdx` que podem crescer significativamente ao longo do tempo.

## Configuração do Arquivo .vhdxs

Esse arquivo é essencial para o funcionamento do Squeeze VHDX, pois ele informa ao utilitário quais arquivos `.vhdx` devem ser compactados. Este arquivo deve estar na raiz da sua pasta de usuário `%USERPROFILE%\.vhdxs`. Um exemplo de arquivo válido pode ser visto em `.vhdxs.example`

> Certifique-se de que não existam linhas em branco extras no final do arquivo. Além disso, o script só processará os arquivos se o Docker e o WSL estiverem completamente desligados (`wsl --shutdown`).