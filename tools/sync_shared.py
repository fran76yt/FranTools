"""
Copia el código compartido de FranTools a los otros addons
==========================================================

Los addons usan las mismas piezas genéricas: utilidades, acceso a la API del
juego, el registro de errores, tooltips, algunos componentes de interfaz y
el montaje de las pruebas (tests/).
WoW no deja que un addon cargue archivos de otro sin depender de él, así que
cada uno lleva su copia, como se hace con las librerías de addons. El
original está en FranTools y este script lo copia a los demás, que deben
estar al lado (en la misma carpeta AddOns). Cada uno recibe solo lo que usa.

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
# que todos los addons que lo reciben definen (ver la cabecera de
# Core/Constants.lua de cada uno).
CORE = [
    "Core/Util.lua",
    "Core/Api.lua",
    "Core/ErrorLog.lua",
    "UI/Tooltip.lua",
    # Pruebas fuera del juego: el cargador y la API simulada son los mismos;
    # cada addon pone sus pruebas en tests/test.lua (y tests/stubs.lua).
    "tests/run.js",
    "tests/api_stubs.lua",
    "tests/package.json",
]

# Addon de destino -> archivos que recibe.
TARGETS = {
    "StreamDeckWoW": CORE + ["UI/MinimapButton.lua"],
    "FranFundir": CORE + ["UI/Checkbox.lua"],
}

SOURCE = Path(__file__).resolve().parent.parent


def differing_files(target, files):
    """Archivos compartidos que no coinciden (o faltan) en el destino."""
    return [f for f in files
            if not (target / f).exists() or not filecmp.cmp(SOURCE / f, target / f, shallow=False)]


def copy_files(target, files):
    for f in files:
        (target / f).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(SOURCE / f, target / f)
        print(f"copiado {target.name}/{f}")


def main():
    parser = argparse.ArgumentParser(description="Copia el código compartido de FranTools a los otros addons.")
    parser.add_argument("--check", action="store_true", help="solo comprobar, sin copiar")
    args = parser.parse_args()
    pending = False
    for name, files in TARGETS.items():
        target = SOURCE.parent / name
        if not target.is_dir():
            sys.exit(f"No encuentro {name} en {target}")
        different = differing_files(target, files)
        if args.check:
            for f in different:
                print(f"distinto: {name}/{f}")
            pending = pending or bool(different)
        else:
            copy_files(target, different)
    if args.check:
        sys.exit(1 if pending else 0)


if __name__ == "__main__":
    main()
