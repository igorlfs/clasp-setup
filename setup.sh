#!/bin/bash

if ! command -v npm &>/dev/null; then
    echo "Você precisa instalar o npm. Use o seguinte comando:"
    echo "sudo apt-get update && sudo apt-get install npm"
    exit
fi

SHELL_CONFIG=~/.bashrc

if [ ! -f "${SHELL_CONFIG}" ]; then
    echo "O arquivo ${SHELL_CONFIG} não existe. Como você chegou até aqui?"
    echo "A instalação não pode continuar. Entre em contato com o Igor"
    exit
fi

if [ -z ${XDG_CONFIG_HOME+x} ]; then
    echo "export XDG_CONFIG_HOME=${HOME}/.config" >>${SHELL_CONFIG}
fi
if [ -z ${XDG_DATA_HOME+x} ]; then
    echo "export XDG_DATA_HOME=${HOME}/.local/share" >>${SHELL_CONFIG}
fi
if [ -z ${XDG_CACHE_HOME+x} ]; then
    echo "export XDG_CACHE_HOME=${HOME}/.cache" >>${SHELL_CONFIG}
fi

NPM_CONFIG_DIR=${HOME}/.config/npm
NPM_CONFIG=${NPM_CONFIG_DIR}/npmrc

echo "export NPM_CONFIG_USERCONFIG=${NPM_CONFIG}" >>${SHELL_CONFIG}

# Atualiza PATH para poder rodar diretamente os binários do node (por exemplo, o clasp)
# Confere se a variável PATH contém o clasp
if [[ ! ${PATH} =~ "clasp" ]]; then
    echo "export PATH=${XDG_DATA_HOME}/npm/bin:${PATH}" >>${SHELL_CONFIG}
fi

source ${SHELL_CONFIG}

# Confere se o diretório existe
if [ ! -d "${NPM_CONFIG_DIR}" ]; then
    echo "Criando arquivo de configuração para o npm"
    mkdir -p "${NPM_CONFIG_DIR}"
fi

# Escrevendo o arquivo
# o arquivo é criado durante a escrita e é sobrescrito, então não é preciso conferir
echo "prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js" >"${NPM_CONFIG}"

echo "Atualizando o npm e o node"
npm i -g --quiet npm node

echo "Instala o clasp"
npm i -g --quiet @google/clasp

clasp -v || echo "Ocorreu algum erro inesperado :("
