"""
Copia el código compartido de FranTools a StreamDeckWoW
=======================================================

Los dos addons usan las mismas piezas genéricas: utilidades, acceso a la API
del juego, el registro de errores, tooltips y el botón del minimapa. WoW no deja que un addon cargue
archivos de otro sin depender de él, así que cada uno lleva su copia, como se
hace con las librerías de addons. El original está en FranTools y este script
lo copia a StreamDeckWoW, que debe estar al lado (en la misma carpeta AddOns).

  python tools/sync_shared.py           copia los archivos
  python tools/sync_shared.py --check   solo comprueba que son iguales
                                        (sale con error si no lo son)
"""

import argparse
import filecmp
import shutil
import sys
from pathlib import Path

# Rutas relativas a la carpeta de cada addon. Cada archivo usa solo constantes
# que los dos addons definen (ver la cabecera de Core/Constants.lua).
SHARED_FILES = [
    "Core/Util.lua",
    "Core/Api.lua",
    "Core/ErrorLog.lua",
    "UI/Tooltip.lua",
    "UI/MinimapButton.lua",
]

SOURCE = Path(__file__).resolve().parent.parent
TARGET = SOURCE.parent / "StreamDeckWoW"


def differing_files():
    """Archivos compartidos que no coinciden (o faltan) en el destino."""
    return [f for f in SHARED_FILES
            if not (TARGET / f).exists() or not filecmp.cmp(SOURCE / f, TARGET / f, shallow=False)]


def copy_files(files):
    for f in files:
        (TARGET / f).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(SOURCE / f, TARGET / f)
        print(f"copiado {f}")


def main():
    parser = argparse.ArgumentParser(description="Copia el código compartido de FranTools a StreamDeckWoW.")
    parser.add_argument("--check", action="store_true", help="solo comprobar, sin copiar")
    args = parser.parse_args()
    if not TARGET.is_dir():
        sys.exit(f"No encuentro StreamDeckWoW en {TARGET}")
    files = differing_files()
    if args.check:
        for f in files:
            print(f"distinto: {f}")
        sys.exit(1 if files else 0)
    copy_files(files)
    if not files:
        print("ya estaban iguales")


if __name__ == "__main__":
    main()
