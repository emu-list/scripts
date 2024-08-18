#!/bin/bash

# Definición de colores
W="\e[0m"      # Reset
N="\e[30;1m"   # Negro brillante
R="\e[31m"     # Rojo
G="\e[32m"     # Verde
Y="\e[33m"     # Amarillo
B="\e[34m"     # Azul
C="\e[36m"     # Cian

# Mensaje de inicio de compilación
echo -e "${G}Iniciando COMPILACIÓN....${W}"
sleep 3

# Actualizar e instalar paquetes necesarios
echo -e "${C}Actualizando paquetes y instalando dependencias...${W}"
yes | pkg update && yes | pkg upgrade -y
pkg remove libglvnd
pkg install git wget make python getconf zip apksigner clang binutils libglvnd-dev aapt which -y

# Eliminar cualquier repositorio existente
echo -e "${C}Eliminando repositorios existentes...${W}"
rm -rf $HOME/sm64ex-omm $HOME/MenuOmm

# Clonar el repositorio principal
REPO_URL="https://github.com/robertkirkman/sm64ex-omm.git"
REPO_DIR="$HOME/sm64ex-omm"
echo -e "${C}Clonando el repositorio principal...${W}"
git clone --recursive $REPO_URL

# Verificar si el repositorio principal se clonó correctamente
if [ $? -ne 0 ]; then
    echo -e "${R}Error al clonar el repositorio principal. Por favor, verifica tu conexión a Internet y vuelve a intentarlo.${W}"
    exit 1
fi

# Clonar el repositorio de traducción
MENU_ES="https://github.com/Retired64/MenuOmm.git"
REPO_ES="$HOME/MenuOmm"
echo -e "${C}Clonando el repositorio de traducción...${W}"
git clone $MENU_ES

# Verificar si el repositorio de traducción se clonó correctamente
if [ $? -ne 0 ]; then
    echo -e "${R}Error al clonar el repositorio de traducción. Por favor, verifica tu conexión a Internet y vuelve a intentarlo.${W}"
    exit 1
fi

# Copiar archivos de traducción
echo -e "${C}Copiando archivos de traducción...${W}"
cp -r $REPO_ES/sm64ex-omm/* $REPO_DIR/

# Verificar si el archivo baserom.us.z64 existe en la ubicación esperada
BASEROM_PATH="/sdcard/baserom.us.z64"
if [ ! -f "$BASEROM_PATH" ]; then
    echo -e "${R}No se ha encontrado el archivo baserom.us.z64 en /sdcard/. Por favor, asegúrate de que está en la ubicación correcta.${W}"
    exit 1
fi

# Copiar el archivo baserom.us.z64 al directorio del repositorio
echo -e "${C}Copiando el archivo baserom.us.z64 al directorio del repositorio...${W}"
cp "$BASEROM_PATH" "$REPO_DIR/baserom.us.z64"
if [ $? -ne 0 ]; then
    echo -e "${R}Error al copiar el archivo baserom.us.z64.${W}"
    exit 1
fi
echo -e "${G}Archivo baserom.us.z64 encontrado y copiado exitosamente.${W}"

# Cambiar al directorio del repositorio
cd $REPO_DIR

# Verificar si el archivo baserom.us.z64 está en el directorio del repositorio
if [ -f "baserom.us.z64" ]; then
    # Ejecutar el script de extracción de assets
    echo -e "${C}Extrayendo los assets...${W}"
    python extract_assets.py us
    if [ $? -ne 0 ]; then
        echo -e "${R}Error al extraer los assets.${W}"
        exit 1
    fi
else
    echo -e "${R}El archivo baserom.us.z64 no está en el directorio del repositorio.${W}"
    exit 1
fi

# Descargar y descomprimir el archivo de sonido
SOUND_URL="https://github.com/Retired64/sounds/raw/main/sound.zip"
SOUND_DIR="$REPO_DIR/sound/samples"
echo -e "${C}Descargando archivo de sonido...${W}"
wget $SOUND_URL
if [ $? -ne 0 ]; then
    echo -e "${R}Error al descargar el archivo de sonido.${W}"
    exit 1
fi
echo -e "${C}Descomprimiendo archivo de sonido...${W}"
mkdir -p $SOUND_DIR
unzip -o sound.zip -d $SOUND_DIR
if [ $? -ne 0 ]; then
    echo -e "${R}Error al descomprimir el archivo de sonido.${W}"
    exit 1
fi

# Compilar el juego
echo -e "${C}Compilando el juego...${W}"
make
if [ $? -ne 0 ]; then
    echo -e "${R}Error al compilar el juego.${W}"
    exit 1
fi

# Verificar si se compiló exitosamente el APK
APK_PATH="$REPO_DIR/build/us_pc/sm64.us.f3dex2e.apk"
if [ -f "$APK_PATH" ]; then
    # Copiar el APK compilado a la carpeta de almacenamiento externo
    echo -e "${C}Copiando APK compilado a /storage/emulated/0/...${W}"
    cp "$APK_PATH" /storage/emulated/0/
    if [ $? -ne 0 ]; then
        echo -e "${R}Error al copiar el APK compilado.${W}"
        exit 1
    fi
    echo -e "${G}APK compilado copiado a /storage/emulated/0/ exitosamente.${W}"
else
    echo -e "${R}Error: No se pudo compilar el APK correctamente.${W}"
fi

# Salir del script
exit 0
