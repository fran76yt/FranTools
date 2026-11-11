# FranTools — Léeme

<p align="center">
  <b>¿Te gusta el proyecto? Sígueme para no perderte las novedades.</b><br>
  <a href="https://www.youtube.com/@fran_76"><img src="https://img.shields.io/badge/YouTube-Suscr%C3%ADbete-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="Suscríbete en YouTube"></a>
  <a href="https://www.twitch.tv/fran76"><img src="https://img.shields.io/badge/Twitch-S%C3%ADgueme-9146FF?style=for-the-badge&logo=twitch&logoColor=white" alt="Sígueme en Twitch"></a>
  <a href="https://x.com/fran76yt"><img src="https://img.shields.io/badge/X-@fran76yt-000000?style=for-the-badge&logo=x&logoColor=white" alt="Sígueme en X"></a><br>
  <sub>Si te sirve, una suscripción o un follow es la mejor forma de apoyarlo. ⭐ Y una estrella en GitHub también ayuda.</sub>
</p>

---

Addon de **World of Warcraft: Forever** con pequeñas ayudas para el día a día, sobre todo para el cazador:

- **Avisos del cazador:** el taunt de la mascota mal puesto, la munición que se acaba y pelear sin el aspecto que toca.
- **Vendedor:** al abrirlo, vende la basura y repara el equipo.
- **Agro en las barras de nombre:** quién tiene a cada enemigo (tú, tu mascota u otro) y tu amenaza.

Todo se configura dentro del juego, en una ventana con una página por tema, y cada función se puede apagar.

Nació dentro de [StreamDeckWoW](https://github.com/fran76yt/StreamDeckWoW), el addon que conecta el juego con una Stream Deck, y se separó porque nada de esto necesita una. Los dos addons funcionan por separado y comparten parte del código (ver [Código compartido](#código-compartido-con-streamdeckwow)).

> **Estado:** versión **0.1.0**, en pruebas. Cada función tiene pruebas automáticas sobre una API del juego simulada, pero aún no se ha probado dentro del juego.

---

## Índice

1. [Instalación](#instalación)
2. [Uso](#uso)
3. [El addon por dentro](#el-addon-por-dentro)
4. [Código compartido con StreamDeckWoW](#código-compartido-con-streamdeckwow)
5. [Datos guardados](#datos-guardados)
6. [Añadir opciones de una clase](#añadir-opciones-de-una-clase)
7. [Estructura del proyecto](#estructura-del-proyecto)

---

## Instalación

Clona o copia este repositorio como carpeta `FranTools` dentro de los addons de Forever:

```
World of Warcraft\_forever_\Interface\AddOns\FranTools\FranTools.toc
```

El nombre de la carpeta tiene que coincidir con el del `.toc`. En la pantalla de personajes, botón **AddOns**, comprueba que **FranTools** está activado.

**Si venías de StreamDeckWoW** con los avisos configurados: la primera vez que entres con FranTools se traen tus opciones (avisos apagados, posición de los recuadros, umbrales, aspectos elegidos…) y se quitan de StreamDeckWoW. Lo dice en el chat.

---

## Uso

### Comandos

| Comando | Qué hace |
|---|---|
| `/fran` o `/fran config` | Abre o cierra la ventana de opciones (también con clic en el botón del minimapa). `/frantools` vale igual que `/fran` |
| `/fran minimapa` | Oculta el botón del minimapa o lo vuelve a mostrar; se recuerda por personaje |
| `/fran aviso` | Apaga o enciende el aviso del taunt de la mascota |
| `/fran municion` | Apaga o enciende el aviso de munición baja |
| `/fran aspecto` | Apaga o enciende el aviso de aspecto |
| `/fran reparar` | Apaga o enciende reparar al abrir un vendedor |
| `/fran basura` | Apaga o enciende vender la basura al abrir un vendedor |
| `/fran agro` | Apaga o enciende el agro en las barras de nombre |
| `/fran ayuda` | Versión del addon y lista de comandos (también sale con cualquier otro texto) |

Todo lo que se apaga o enciende se recuerda por personaje, y va sincronizado con su casilla en la ventana.

### Botón del minimapa

Un botón con una llave inglesa en el borde del minimapa:

- **Clic:** abre o cierra la ventana de opciones.
- **Arrastrar:** lo mueve alrededor del minimapa. La posición se guarda por personaje.
- `/fran minimapa` lo esconde si molesta, y el mismo comando lo recupera.

### Ventana de opciones

<p align="center"><code>/fran</code> o clic en el botón del minimapa</p>

A la izquierda, una **barra lateral** para elegir la página; la elegida se marca en dorado:

- **General:** para todas las clases: reparar y vender la basura al abrir un vendedor, y el agro en las barras de nombre.
- **La sección de tu clase**, si la tiene, bajo su nombre en el color de la clase. De momento solo existe **Cazador**, con tres páginas: **Mascota** (aviso del taunt), **Munición** (aviso y umbrales por tipo de arma) y **Aspectos** (aviso y qué aspectos valen). Cada personaje ve solo la de su clase.

Pasa el ratón por encima de cada opción para ver qué hace.

### Aviso del taunt de la mascota

En mazmorras y bandas los enemigos los tiene que mantener el tanque: si la mascota los provoca con **Bramido**, se los quita. En solitario es al revés: conviene que la mascota los provoque para que no vengan a por ti. El addon vigila el lanzamiento automático de Bramido (el borde dorado que gira en la barra de la mascota) y avisa cuando no toca:

| Dónde estás | Bramido automático | Aviso |
|---|---|---|
| Mazmorra o banda | Activado | «Bramido de la mascota ACTIVADO en mazmorra o banda: desactívalo…» |
| Fuera (mundo abierto, campos de batalla…) | Desactivado | «Bramido de la mascota DESACTIVADO fuera de mazmorra: actívalo…» |

- El aviso sale **en el centro de la pantalla**, en el chat y con un sonido. Solo lo ves tú: no se envía a nadie.
- Se avisa una vez cuando la situación pasa a estar mal: al entrar o salir de una instancia, al invocar la mascota o al cambiar el automático. Si sigue mal, **se repite al entrar en combate**. Cuando lo corriges, una línea en el chat lo confirma.
- Sin mascota, o con una que no tiene Bramido, no avisa.
- El addon **no lo cambia por ti**: activar o desactivar el automático de una habilidad de la mascota es una acción protegida que solo puede hacer el jugador. Se cambia con clic derecho en Bramido, en la barra de la mascota. Si quieres hacerlo desde la Stream Deck, crea una macro con `/petautocasttoggle Bramido` y, si usas StreamDeckWoW, arrástrala a un hueco con `/sdeck config`.
- Se apaga o enciende con la casilla **Avisar del taunt de la mascota (Bramido)** de **Cazador › Mascota** en `/fran config`, o con `/fran aviso`. Las dos cosas van sincronizadas.

Los IDs de los siete rangos de Bramido están en `Const.PET_TAUNT` ([`Core/Constants.lua`](Core/Constants.lua)), junto con los tipos de instancia en los que debe estar desactivado. Sirve para cualquier taunt de mascota: basta con añadir sus IDs a la lista.

### Aviso de munición baja

Un recuadro pequeño con el icono de tu munición y cuántas te quedan, para acordarte de comprar antes de quedarte sin flechas. No suena ni ocupa el centro de la pantalla: aparece mientras falte y desaparece solo cuando vuelves a tener suficiente.

| Munición | Recuadro |
|---|---|
| Por encima del umbral ámbar (200 por defecto) | No aparece |
| Por debajo del ámbar | Borde ámbar: «Munición baja: 143» |
| Por debajo del rojo (50 por defecto) | Borde rojo: «Munición muy baja: 32» |
| Ninguna | Borde rojo: «Sin munición» |

- **Qué cuenta:** la munición equipada, si el cliente tiene esa ranura; si no, todas las flechas (con arco o ballesta) o balas (con arma de fuego) de tus bolsas y carcajes. Las de otro tipo no cuentan: unas balas no sirven para un arco.
- Solo para cazadores, y solo con un arma que gaste munición: con varita o arma arrojadiza no hay aviso.
- **Arrástralo** a donde te moleste menos; la posición se guarda por personaje. Al principio está algo por debajo del centro de la pantalla.
- Se apaga o enciende con la casilla **Avisar de munición baja** de **Cazador › Munición** en `/fran config`, o con `/fran municion`.
- **Los umbrales se configuran por tipo de arma** en **Cazador › Munición** de `/fran config`, porque no es lo mismo un arco que un arma de fuego: una fila para **Arco/ballesta** (flechas) y otra para **Arma de fuego** (balas), cada una con su caja **Ámbar** y **Rojo**. Se aplica con Intro o haciendo clic fuera; Escape deja el valor que había.
  - El rojo no puede ser mayor que el ámbar: si lo escribes, se ajusta al ámbar; y si bajas el ámbar por debajo del rojo, el rojo baja con él.
  - **0 en ámbar** apaga el aviso de ese tipo.
  - Solo se guardan los que cambias; los demás siguen los valores por defecto de `Const.AMMO.TYPES` ([`Core/Constants.lua`](Core/Constants.lua)).

Sin verificar en Forever: si su cliente tiene ranura de munición. Por eso, además, se cuentan las bolsas, que funciona en cualquier caso.

### Aviso de aspecto

Otro recuadro discreto, como el de la munición, para no pelear sin aspecto o con el que no toca (el clásico: entrar en combate con el guepardo y quedarte aturdido al primer golpe).

| Qué llevas | Recuadro |
|---|---|
| Un aspecto marcado | No aparece |
| Ninguno | Borde ámbar: «Sin aspecto» |
| Uno sin marcar | Borde rojo: «Aspecto: Guepardo» |

- El icono es el del primer aspecto marcado que conoces: el que toca ponerse.
- **Qué aspectos valen** se elige en **Cazador › Aspectos** de `/fran config`, con una casilla por aspecto (con su icono). Por defecto valen **Halcón** y **Mono**, los de combate; Salvaje, Guepardo, Manada y Bestia no. Solo se guardan los que cambias.
- **Solo en combate** (marcado por defecto): fuera de combate no avisa, para que puedas viajar con el guepardo. Si lo desmarcas, avisa siempre.
- No avisa muerto ni de aspectos que aún no has aprendido; si no conoces ninguno de los marcados, no hay aviso.
- Se reconoce cualquier rango del aspecto, por su ID o, si el cliente no lo da, por su nombre.
- **Arrástralo** a donde te moleste menos; la posición se guarda por personaje.
- Se apaga o enciende con la primera casilla de **Cazador › Aspectos**, o con `/fran aspecto`.

Los IDs de todos los rangos están en `Const.ASPECT` ([`Core/Constants.lua`](Core/Constants.lua)), comprobados en Wowhead Forever. Sin verificar en Forever: que su cliente dé las auras con `C_UnitAuras` (si no, se usa `UnitBuff`).

### Reparar y vender la basura

Para cualquier clase. Al abrir un vendedor, sin tocar nada:

1. **Vende la basura**: los objetos grises que el vendedor compra. Nunca nada blanco o mejor, aunque valga poco.
2. **Repara todo el equipo**, si el vendedor repara y te llega el dinero. Va después de vender, para contar ya con lo que da la basura.

Las dos se cuentan en el chat («basura vendida: 7 objetos por 1p 20c», «equipo reparado por 3p 4c»); si no te llega para reparar, también lo dice. La basura se vende en tandas de 10 con una pausa corta entre ellas, porque el servidor descarta ventas si llegan muchas de golpe; si cierras el vendedor a medias, para.

- **Abre el vendedor con Mayús pulsada** para que no haga nada, por si quieres vender a mano.
- Repara con tu dinero, no con el del banco de hermandad.
- Cada una se apaga o enciende en **General** de `/fran config`, o con `/fran reparar` y `/fran basura`. Las dos vienen encendidas.

### Agro en las barras de nombre

Para cualquier clase. En la barra de nombre de cada enemigo con el que estáis en combate tú o tu mascota, un **marco de color** alrededor de la barra de vida y **tu porcentaje de amenaza** al lado (a 100 le quitas el agro a quien lo tiene):

| Color | Quién tiene el agro |
|---|---|
| Rojo | Va a por ti |
| Ámbar | Aún no, pero estás a punto: llegas al 80 % o ya tienes más amenaza que quien lo tiene |
| Verde | Tu mascota |
| Gris | Otro (el tanque del grupo) |

- El ámbar va por delante del verde: si dejas tanquear a la mascota, te avisa antes de quitárselo.
- Si solo la mascota está en combate con el enemigo, el marco sale sin porcentaje.
- No cambia la barra de vida en sí (el juego la volvería a pintar con su color); el marco va por fuera.
- Se apaga o enciende en **General** de `/fran config`, o con `/fran agro`. Viene encendido.

Sin verificar en Forever: que su cliente dé la amenaza (`UnitDetailedThreatSituation`; si no, no se ve nada) y que sus barras de nombre sean las de Blizzard. Con otro addon que las sustituya, el marco rodea la barra entera o no se ve.

---

## El addon por dentro

Todos los archivos del addon reciben la misma tabla privada (`local _, ns = ...`), que hace de espacio de nombres compartido sin llenar el espacio global. Las únicas globales son las que exige WoW (los comandos, `FranToolsConfig` para cerrar la ventana con Escape, los recuadros de aviso y el botón del minimapa, `FranToolsMinimapButton`) y `FranTools`, que expone esa tabla para inspeccionarla en el juego con `/dump`.

| Archivo | Responsabilidad |
|---|---|
| [`Core/Constants.lua`](Core/Constants.lua) | Todos los valores fijos: IDs de hechizos, umbrales, tiempos, colores y medidas |
| [`Core/Util.lua`](Core/Util.lua) | *Compartido.* Utilidades genéricas: eventos, mensajes entre módulos, temporizadores y *debounce*, ejecutar fuera de combate, interruptores de opciones (`Util.Switch`), guardar solo lo que difiere del valor por defecto (`Util.SetOverride`), escribir en el chat |
| [`Core/Api.lua`](Core/Api.lua) | *Compartido.* Única puerta a la API del juego: hechizos, objetos, bolsas, mascota, auras, amenaza y barras de nombre, vendedores y dinero, tipo de instancia, avisos en pantalla. Si a un cliente le falta una función, devuelve vacío en lugar de dar un error de Lua |
| [`Core/Storage.lua`](Core/Storage.lua) | Único módulo que toca la variable guardada `FranToolsChar` |
| [`Core/Migration.lua`](Core/Migration.lua) | Trae, una vez, las opciones que había en StreamDeckWoW |
| [`Features/PetTaunt.lua`](Features/PetTaunt.lua) | Aviso del taunt de la mascota |
| [`Features/Ammo.lua`](Features/Ammo.lua) | Aviso de munición baja |
| [`Features/Aspect.lua`](Features/Aspect.lua) | Aviso de aspecto |
| [`Features/Merchant.lua`](Features/Merchant.lua) | Al abrir un vendedor: vende la basura en tandas y después repara |
| [`Features/Threat.lua`](Features/Threat.lua) | Agro en las barras de nombre: decide el color y el porcentaje de cada enemigo |
| [`UI/Tooltip.lua`](UI/Tooltip.lua) | *Compartido.* Tooltips de ayuda (título y líneas en gris) |
| [`UI/NoticeBox.lua`](UI/NoticeBox.lua) | Recuadro de aviso discreto: icono, texto, borde del color del nivel y posición movible que se guarda |
| [`UI/ThreatBadge.lua`](UI/ThreatBadge.lua) | Marco de color y texto alrededor de la barra de vida de una barra de nombre, sin tocar la barra |
| [`UI/Checkbox.lua`](UI/Checkbox.lua) | Casilla: lee y escribe su estado con funciones del módulo que la usa |
| [`UI/NumberBox.lua`](UI/NumberBox.lua) | Caja numérica: aplica con Intro o al salir, descarta con Escape |
| [`UI/OptionsPage.lua`](UI/OptionsPage.lua) | Dibuja una página de opciones a partir de filas descritas como datos |
| [`UI/Sidebar.lua`](UI/Sidebar.lua) | Barra lateral de la ventana: entradas agrupadas bajo títulos |
| [`UI/GeneralPage.lua`](UI/GeneralPage.lua) | Página **General**, solo como filas de datos |
| [`UI/ClassPages/ClassPages.lua`](UI/ClassPages/ClassPages.lua) | Registro de secciones por clase |
| [`UI/ClassPages/Hunter.lua`](UI/ClassPages/Hunter.lua) | Sección **Cazador**: páginas Mascota, Munición y Aspectos |
| [`UI/ConfigWindow.lua`](UI/ConfigWindow.lua) | La ventana `/fran config` |
| [`UI/MinimapButton.lua`](UI/MinimapButton.lua) | *Compartido.* Componente de botón del minimapa, hecho a mano sin LibDBIcon |
| [`UI/Minimap.lua`](UI/Minimap.lua) | El botón del minimapa de este addon |
| [`Core/Commands.lua`](Core/Commands.lua) | Comandos `/fran` |

---

## Código compartido con StreamDeckWoW

Los dos addons usan las mismas piezas genéricas: [`Core/Util.lua`](Core/Util.lua), [`Core/Api.lua`](Core/Api.lua), [`UI/Tooltip.lua`](UI/Tooltip.lua) y [`UI/MinimapButton.lua`](UI/MinimapButton.lua). Un addon de WoW no puede cargar archivos de otro sin depender de él, así que cada uno lleva su copia, como se hace con las librerías de addons. Así cada addon funciona sin el otro.

El original está aquí. Con StreamDeckWoW en la misma carpeta `AddOns`:

```bash
python tools/sync_shared.py           # copia los archivos compartidos a StreamDeckWoW
python tools/sync_shared.py --check   # solo comprueba que son iguales
```

Los archivos compartidos leen de `Core/Constants.lua` algunas constantes que los dos addons definen (están en su cabecera): `ADDON_NAME`, `ICON`, `MSG.SETTINGS_CHANGED`, `CHAT_PREFIX`, `UI.TOOLTIP_HELP_COLOR` y `MINIMAP`.

---

## Datos guardados

Una variable por personaje, `FranToolsChar`, en:

```
World of Warcraft\_forever_\WTF\Account\<CUENTA>\<Reino>\<Personaje>\SavedVariables\FranTools.lua
```

Solo se guarda lo que has cambiado respecto a los valores por defecto:

```lua
FranToolsChar = {
    ["minimap"] = { ["angle"] = 200, ["hidden"] = true },
    ["petTaunt"] = { ["off"] = true },             -- aviso apagado
    ["ammo"] = {
        ["point"] = { "CENTER", "CENTER", 0, -160 },   -- recuadro movido
        ["thresholds"] = { ["arrow"] = { ["low"] = 300 } },
    },
    ["aspect"] = {
        ["anytime"] = true,                        -- avisa también fuera de combate
        ["chosen"] = { ["monkey"] = false, ["wild"] = true },
    },
    ["repair"] = { ["off"] = true },
    ["junk"] = { ["off"] = true },
    ["threat"] = { ["off"] = true },
}
```

El detalle de cada campo está en la cabecera de [`Core/Storage.lua`](Core/Storage.lua).

---

## Añadir opciones de una clase

1. Crea `UI/ClassPages/<Clase>.lua` siguiendo el modelo de [`Hunter.lua`](UI/ClassPages/Hunter.lua). Solo describe las páginas y sus filas; los tipos de fila están en [`UI/OptionsPage.lua`](UI/OptionsPage.lua):

   ```lua
   local _, ns = ...

   ns.ClassPages.Register("WARRIOR", {
       title = "Guerrero",
       pages = {
           { title = "Gritos", rows = {
               { kind = "check", label = "…", get = function() … end, set = function(on) … end },
           } },
       },
   })
   ```

   La clave es el nombre interno de la clase en inglés: `WARRIOR`, `PALADIN`, `HUNTER`, `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID`. Cada página sale en la barra lateral bajo el nombre de la clase, en su color.

2. Añade la línea `UI\ClassPages\<Clase>.lua` al `.toc`, junto a la del cazador.

La lógica de cada opción va en su módulo de `Features/`, con `Util.Switch` si es una opción que se enciende y se apaga. Las opciones para todas las clases van en [`UI/GeneralPage.lua`](UI/GeneralPage.lua).

Los IDs de hechizos y objetos de Forever se consultan en [Wowhead (Forever)](https://www.wowhead.com/forever).

---

## Estructura del proyecto

```
FranTools/
├── FranTools.toc                      metadatos y orden de carga
├── Core/
│   ├── Constants.lua                  valores fijos
│   ├── Util.lua                       utilidades genéricas (compartido)
│   ├── Api.lua                        acceso a la API del juego (compartido)
│   ├── Storage.lua                    SavedVariables
│   ├── Migration.lua                  opciones traídas de StreamDeckWoW
│   └── Commands.lua                   comandos /fran
├── Features/
│   ├── PetTaunt.lua                   aviso del taunt de la mascota
│   ├── Ammo.lua                       aviso de munición baja
│   ├── Aspect.lua                     aviso de aspecto
│   ├── Merchant.lua                   reparar y vender la basura
│   └── Threat.lua                     agro en las barras de nombre
├── UI/
│   ├── Tooltip.lua                    tooltips de ayuda (compartido)
│   ├── NoticeBox.lua                  recuadro de aviso discreto
│   ├── ThreatBadge.lua                marco de agro en una barra de nombre
│   ├── Checkbox.lua                   casilla de opciones
│   ├── NumberBox.lua                  caja numérica
│   ├── OptionsPage.lua                página de opciones descrita como filas
│   ├── Sidebar.lua                    barra lateral de la ventana
│   ├── GeneralPage.lua                página General
│   ├── ClassPages/                    una sección de páginas por clase
│   │   ├── ClassPages.lua             registro
│   │   └── Hunter.lua                 cazador
│   ├── ConfigWindow.lua               ventana /fran config
│   ├── MinimapButton.lua              componente de botón del minimapa (compartido)
│   └── Minimap.lua                    el botón del minimapa de este addon
└── tools/
    └── sync_shared.py                 copia el código compartido a StreamDeckWoW
```
