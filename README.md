# FranTools — Léeme

<p align="center">
  <b>¿Te gusta el proyecto? Sígueme para no perderte las novedades.</b><br>
  <a href="https://www.youtube.com/@fran_76"><img src="https://img.shields.io/badge/YouTube-Suscr%C3%ADbete-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="Suscríbete en YouTube"></a>
  <a href="https://www.twitch.tv/fran76"><img src="https://img.shields.io/badge/Twitch-S%C3%ADgueme-9146FF?style=for-the-badge&logo=twitch&logoColor=white" alt="Sígueme en Twitch"></a>
  <a href="https://x.com/fran76yt"><img src="https://img.shields.io/badge/X-@fran76yt-000000?style=for-the-badge&logo=x&logoColor=white" alt="Sígueme en X"></a><br>
  <sub>Si te sirve, una suscripción o un follow es la mejor forma de apoyarlo. ⭐ Y una estrella en GitHub también ayuda.</sub>
</p>

---

Addon de **World of Warcraft: Forever** con pequeñas ayudas para el día a día:

- **Avisos del cazador:** el taunt de la mascota mal puesto, la munición que se acaba y pelear sin el aspecto que toca.
- **Ayudas del guerrero:** Grito de guerra caído y, para el tanque, Revancha lista, el enfriamiento de Provocar y los colores de tanque del agro.
- **Avisos del brujo:** pocos fragmentos de alma, sin piedra de salud, sin armadura y el taunt del abisario mal puesto.
- **Avisos del paladín:** sin aura, sin bendición y Furia justa cuando no toca.
- **Vendedor:** al abrirlo, vende la basura y repara el equipo.
- **Agro en las barras de nombre:** quién tiene a cada enemigo (tú, tu mascota u otro) y tu amenaza.

Todo se configura dentro del juego, en una ventana con una página por tema, y cada función se puede apagar.

Nació dentro de [StreamDeckWoW](https://github.com/fran76yt/StreamDeckWoW), el addon que conecta el juego con una Stream Deck, y se separó porque nada de esto necesita una. Los dos addons funcionan por separado y comparten parte del código (ver [Librería común](#librería-común-franlib)).

> **Estado:** versión **0.1.0**, en pruebas. Cada función tiene pruebas automáticas sobre una API del juego simulada, pero aún no se ha probado dentro del juego.

---

## Índice

1. [Instalación](#instalación)
2. [Uso](#uso)
3. [El addon por dentro](#el-addon-por-dentro)
4. [Librería común (FranLib)](#librería-común-franlib)
5. [Datos guardados](#datos-guardados)
6. [Añadir opciones de una clase](#añadir-opciones-de-una-clase)
7. [Pruebas](#pruebas)
8. [Estructura del proyecto](#estructura-del-proyecto)

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
| `/fran aviso` | Apaga o enciende el aviso del taunt de la mascota (cazador y brujo) |
| `/fran municion` | Apaga o enciende el aviso de munición baja |
| `/fran aspecto` | Apaga o enciende el aviso de aspecto |
| `/fran reparar` | Apaga o enciende reparar al abrir un vendedor |
| `/fran basura` | Apaga o enciende vender la basura al abrir un vendedor |
| `/fran agro` | Apaga o enciende el agro en las barras de nombre |
| `/fran registro` | Apaga o enciende el registro de combate en mazmorras y bandas |
| `/fran agro estado` | Con un enemigo seleccionado, repasa paso a paso por qué se ve o no el agro (ver [Agro en las barras de nombre](#agro-en-las-barras-de-nombre)) |
| `/fran grito` | Guerrero: apaga o enciende el aviso de Grito de guerra |
| `/fran revancha` | Guerrero: apaga o enciende el aviso de Revancha |
| `/fran provocar` | Guerrero: apaga o enciende el enfriamiento de Provocar |
| `/fran iconos` | Todos los avisos solo con el icono, sin texto, o con texto otra vez |
| `/fran fragmentos` | Brujo: apaga o enciende el aviso de fragmentos de alma |
| `/fran piedra` | Brujo: apaga o enciende el aviso de piedra de salud |
| `/fran armadura` | Brujo: apaga o enciende el aviso de armadura |
| `/fran aura` | Paladín: apaga o enciende el aviso de aura |
| `/fran bendicion` | Paladín: apaga o enciende el aviso de bendición |
| `/fran furia` | Paladín: apaga o enciende el aviso de Furia justa |
| `/fran errores` | Errores de Lua apuntados; con un número, uno entero; con `borrar`, vacía la lista (ver [Registro de errores](#registro-de-errores)) |
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

- **General:** para todas las clases: reparar y vender la basura al abrir un vendedor, el agro en las barras de nombre y cómo se ven los recuadros de aviso (solo el icono y su tamaño).
- **La sección de tu clase**, bajo su nombre en el color de la clase. Cada personaje ve solo la de su clase. Un clic en el nombre del grupo lo pliega o lo despliega, y se recuerda.
  - **Cazador:** Mascota (aviso del taunt), Munición (aviso y umbrales por tipo de arma) y Aspectos (aviso y qué aspectos valen).
  - **Guerrero:** Gritos (aviso de Grito de guerra) y Tanque (casilla Tanqueo yo, Revancha y Provocar).
  - **Brujo:** Mascota (taunt del abisario), Reactivos (fragmentos de alma con sus umbrales y piedra de salud) y Armadura.
  - **Paladín:** Aura (aviso y qué auras valen), Bendición y Furia justa.

Las notas largas de una página ocupan lo que necesitan y empujan hacia abajo lo que va detrás, y la ventana crece si alguna página no cabe.

### Recuadros de aviso

Casi todos los avisos son un recuadro pequeño con un icono y una línea de texto: borde **ámbar** para avisar, **rojo** cuando es más urgente y **verde** para algo que ya puedes usar (Revancha, Provocar listo). No suenan ni ocupan el centro de la pantalla, y desaparecen solos en cuanto se arregla lo que avisan.

- **Arrástralos** a donde te molesten menos; la posición de cada uno se guarda por personaje.
- Los que no has movido se **apilan** uno debajo de otro por debajo del centro de la pantalla, solo los que están a la vista, para que varios avisos a la vez no se tapen.
- **Solo el icono:** en **General › Recuadros de aviso** (o con `/fran iconos`) todos pasan a ser un icono cuadrado, sin texto, con el borde del mismo color. Lo que dice cada uno sale al pasar el ratón.
- **Tamaño del icono:** en la misma sección, de 16 a 64 píxeles; vale para los dos modos.
- Lo que tiene una cuenta atrás (Provocar) la enseña con una cifra encima del icono, y el icono se ve apagado hasta que está listo.

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

Los IDs de todos los rangos están en `Const.ASPECT` ([`Core/Constants.lua`](Core/Constants.lua)), comprobados en Wowhead Forever.

**En combate**, el cliente de Forever oculta a los addons la lista de beneficios (comprobado en el juego: es un «valor secreto» y pedirla da un error). Entonces el addon usa lo último que supo: lo que leyó antes de empezar la pelea y lo que **lances tú** durante ella (el juego sí cuenta qué hechizos lanzas). Así, si entras en combate sin el beneficio, el aviso sale, y se quita en cuanto te lo pones. Preguntar hechizo a hechizo solo sirve para confirmar que lo llevas, porque con los datos ocultos el juego contesta «no» aunque lo lleves. Lo que no puede saber es si se te cae a mitad de pelea, ni un beneficio que te ponga otro jugador en combate. Vale para todos los avisos de beneficios: aspecto, Grito de guerra, armadura, aura, bendición y Furia justa.

### Guerrero

- **Grito de guerra:** recuadro ámbar «Sin Grito de guerra» si no lo llevas. Cuenta cualquier rango, también el de otro guerrero del grupo. Por defecto **solo en combate**; con la casilla desmarcada avisa siempre. Se configura en **Guerrero › Gritos** o con `/fran grito`.

Para el **tanque** (protección), en **Guerrero › Tanque**:

- **Tanqueo yo:** marca que tanqueas, para cuando el juego no sabe tu rol (si el grupo tiene roles puestos, manda el rol). Cambia los colores del agro en las barras de nombre: **verde** si va a por ti, **ámbar** si va a por ti pero otro está a punto de quitártelo, **rojo** si se te ha escapado. Es la misma casilla que la del paladín.
- **Revancha:** icono verde mientras puedes usarla, tras bloquear, esquivar o parar. Dura poco y es lo que más amenaza da por ira. Con el icono del rango más alto que sabes. Solo en combate. `/fran revancha`.
- **Provocar:** icono verde «Provocar listo» y, al usarlo, apagado con los segundos que le quedan encima. En Forever son **8 s** (comprobado en Wowhead Forever), o 7 y 6 con el talento Provocar mejorado. Por defecto solo en combate. `/fran provocar`.

En combate el cliente de Forever oculta los enfriamientos a los addons, y su reloj de enfriamiento no acepta valores ocultos de un addon. Por eso la cuenta de Provocar es propia: empieza al lanzarlo (eso el juego sí lo cuenta) con lo que dura según tus talentos, y si el juego da el enfriamiento de verdad, manda el suyo. Lo que el juego no oculta es si un hechizo se puede usar, y de ahí sale el aviso de Revancha.

### Brujo

- **Fragmentos de alma:** recuadro ámbar con menos de **5** («Fragmentos de alma: 3») y rojo con menos de **2** o sin ninguno, desde que sabes **Drenar alma** (nivel 10), que es lo que los da. Los umbrales se cambian en **Brujo › Reactivos**, como los de la munición; 0 en ámbar apaga el aviso. `/fran fragmentos`.
- **Piedra de salud:** recuadro ámbar «Sin piedra de salud» si no llevas ninguna (de cualquier tamaño) y sabes crearla. `/fran piedra`.
- **Armadura:** recuadro ámbar «Sin armadura» si no llevas Piel de demonio ni Armadura demoníaca; el icono es el de la mejor que sabes. Avisa **también fuera de combate** de entrada, porque dura media hora y se pone antes de empezar; la casilla **Solo en combate** de **Brujo › Armadura** lo cambia. `/fran armadura`.
- **Taunt del abisario:** el mismo aviso que el Bramido del cazador, con **Tormento**: desactivado en mazmorra y banda, activado fuera. Se configura en **Brujo › Mascota** o con `/fran aviso`.

### Paladín

- **Aura:** como los aspectos del cazador. Recuadro ámbar «Sin aura» si no llevas ninguna de las marcadas y rojo («Aura: Devoción») si llevas una sin marcar. Por defecto valen todas; se eligen en **Paladín › Aura**, con una casilla con icono por aura. Por defecto solo en combate. `/fran aura`.
- **Bendición:** recuadro ámbar «Sin bendición» si no llevas ninguna; vale la de cualquier paladín, normal o superior. Por defecto solo en combate. `/fran bendicion`.
- **Furia justa:** solo en grupo. Si tanqueas y no la llevas, recuadro ámbar «Sin Furia justa»; si la llevas sin tanquear (le robarías los enemigos al tanque), rojo «Furia justa: quítala». Quién tanquea lo dice el rol del grupo si está puesto; si no, la casilla **Tanqueo yo** de **Paladín › Furia justa** (la misma que la del guerrero). `/fran furia`.

Sin verificar en Forever: que su cliente tenga roles de grupo (`UnitGroupRolesAssigned`); si no, manda la casilla. Wowhead Forever no tiene las bendiciones de Salvación, Luz y Santuario: sus IDs están en la lista igualmente, por si el juego las tiene.

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
- **Si tanqueas** (rol de tanque en el grupo, o la casilla **Tanqueo yo** de tu clase), lo que alarma es lo contrario: **verde** si va a por ti, **ámbar** si va a por ti pero otro está a punto de quitártelo y **rojo** si se te ha escapado. Con la amenaza oculta, solo verde o rojo (el ámbar del tanque necesitaría leerla).
- Si solo la mascota está en combate con el enemigo, el marco sale sin porcentaje.
- No cambia la barra de vida en sí (el juego la volvería a pintar con su color); el marco va por fuera.
- Se apaga o enciende en **General** de `/fran config`, o con `/fran agro`. Viene encendido.
- El marco va por encima de la barra de vida, para que su propio borde no lo tape. Sirve con las barras de nombre de los clientes clásicos y de los modernos (la barra de vida está en sitios distintos).
- **Si no se ve:** selecciona un enemigo con el que estés en combate y escribe `/fran agro estado`. Dice, paso a paso, si el aviso está encendido, si el juego da la amenaza, si el objetivo tiene barra de nombre y barra de vida, qué amenaza tenéis tú y la mascota, y si el marco está puesto.

**En Forever, con la amenaza oculta:** su cliente puede ocultar la amenaza a los addons en combate, y entonces llega como «valor secreto». Un addon no puede leer ni comparar ese valor, pero sí dárselo a la interfaz del juego para que lo pinte. Así lo cuenta la documentación de la API de Blizzard para Forever (la rama `forever` de su código de interfaz). El addon pinta lo mismo sin mirar los valores:

- El **color del marco** lo elige el juego a partir de «¿va a por ti?» y «¿va a por tu mascota?» (`SetVertexColorFromBoolean`, que acepta un sí o no secreto).
- El **ámbar** es una barra en cada lado del marco que solo se llena del todo cuando tu amenaza pasa del 80 %.
- El **porcentaje** lo escribe el juego (`SetFormattedText`).

Si un cliente no dejara ni eso, el addon quita el marco y lo explica una vez por sesión en el chat, con el motivo; se apaga con `/fran agro`. `/fran agro estado` dice si la amenaza llega oculta.

Sin addons, el juego también enseña tu porcentaje de amenaza en el marco del objetivo si activas la opción de amenaza numérica de la interfaz (variable `threatShowNumeric`).

### Registro de combate

Al entrar en una mazmorra o banda, el addon hace lo mismo que escribir `/combatlog`: el juego guarda todo el combate (lanzamientos, auras, daño, muertes) en `Logs\WoWCombatLog-<fecha>.txt`, dentro de la carpeta `_forever_`. Ese archivo sirve para analizar las peleas fuera del juego, porque Forever no deja a los addons leer el registro de combate.

- Al salir de la instancia lo apaga, pero solo si lo encendió el addon: si lo pusiste tú a mano, lo deja como está.
- Para que el archivo traiga todos los datos, activa también **Registro de combate avanzado** en las opciones del juego (Sistema → Red).
- Se apaga o enciende en **General** de `/fran config`, o con `/fran registro`. Viene encendido.
- Si algún día el juego no dejara a los addons encenderlo, lo dice en el chat y hay que escribir `/combatlog` a mano.

---

## El addon por dentro

Todos los archivos del addon reciben la misma tabla privada (`local _, ns = ...`), que hace de espacio de nombres compartido sin llenar el espacio global. Las únicas globales son las que exige WoW (los comandos, `FranToolsConfig` para cerrar la ventana con Escape, los recuadros de aviso y el botón del minimapa, `FranToolsMinimapButton`) y `FranTools`, que expone esa tabla para inspeccionarla en el juego con `/dump`.

| Archivo | Responsabilidad |
|---|---|
| [`Core/Constants.lua`](Core/Constants.lua) | Todos los valores fijos: IDs de hechizos, umbrales, tiempos, colores y medidas |
| [`Libs/FranLib/`](Libs/FranLib) | *Librería común FranLib, incrustada (es una copia: se edita en el repositorio FranLib).* Utilidades (llamadas protegidas con `Util.SafeCall`, eventos, mensajes entre módulos, interruptores de opciones, chat), la única puerta a la API del juego, el registro de errores (`/fran errores`), tooltips de ayuda, casillas y el botón del minimapa |
| [`Core/Storage.lua`](Core/Storage.lua) | Único módulo que toca la variable guardada `FranToolsChar` |
| [`Core/Migration.lua`](Core/Migration.lua) | Trae, una vez, las opciones que había en StreamDeckWoW |
| [`Core/Role.lua`](Core/Role.lua) | Quién tanquea: el rol del grupo o la casilla Tanqueo yo, la misma para todas las clases |
| [`Core/Buffs.lua`](Core/Buffs.lua) | Reconoce qué beneficio de una lista lleva el jugador (por ID o por nombre) y si sabe lanzarlo |
| [`Core/Thresholds.lua`](Core/Thresholds.lua) | Umbrales ámbar y rojo que cambia el jugador, y el nivel y texto del aviso para una cantidad |
| [`Features/BuffWarning.lua`](Features/BuffWarning.lua) | Motor de los avisos «no llevas X puesto»: cada uno es una descripción (aspecto, Grito de guerra, armadura, aura, bendición) |
| [`Features/CountWarning.lua`](Features/CountWarning.lua) | Motor de los avisos «te quedan pocos X» (fragmentos de alma, piedra de salud) |
| [`Features/ReadyWarning.lua`](Features/ReadyWarning.lua) | Motor de los avisos «ya puedes usarlo» (Revancha) |
| [`Features/CooldownWarning.lua`](Features/CooldownWarning.lua) | Motor de los avisos de enfriamiento con su propia cuenta atrás (Provocar) |
| [`Features/PetTaunt.lua`](Features/PetTaunt.lua) | Aviso del taunt de la mascota (Bramido, Tormento) |
| [`Features/Ammo.lua`](Features/Ammo.lua) | Aviso de munición baja |
| [`Features/Aspect.lua`](Features/Aspect.lua) | Aviso de aspecto (cazador) |
| [`Features/Warrior.lua`](Features/Warrior.lua) | Avisos del guerrero: Grito de guerra, Revancha y Provocar |
| [`Features/Warlock.lua`](Features/Warlock.lua) | Avisos de fragmentos de alma, piedra de salud y armadura |
| [`Features/Paladin.lua`](Features/Paladin.lua) | Avisos de aura y bendición |
| [`Features/RighteousFury.lua`](Features/RighteousFury.lua) | Aviso de Furia justa, según si tanqueas |
| [`Features/Merchant.lua`](Features/Merchant.lua) | Al abrir un vendedor: vende la basura en tandas y después repara |
| [`Features/CombatLog.lua`](Features/CombatLog.lua) | Registro de combate: lo enciende al entrar en una mazmorra o banda y lo apaga al salir, si lo encendió él |
| [`Features/Threat.lua`](Features/Threat.lua) | Agro en las barras de nombre: decide el color y el porcentaje de cada enemigo, o se los pasa sin mirar al marco si el juego los oculta |
| [`UI/NoticeBox.lua`](UI/NoticeBox.lua) | Recuadro de aviso discreto: icono, texto, borde del color del nivel y posición movible que se guarda; los no movidos se apilan. Modo solo icono, tamaño del icono y una cifra encima (cuenta atrás) |
| [`UI/ThreatBadge.lua`](UI/ThreatBadge.lua) | Marco de color y texto alrededor de la barra de vida de una barra de nombre, sin tocar la barra |
| [`UI/NumberBox.lua`](UI/NumberBox.lua) | Caja numérica: aplica con Intro o al salir, descarta con Escape |
| [`UI/OptionsPage.lua`](UI/OptionsPage.lua) | Dibuja una página de opciones a partir de filas descritas como datos |
| [`UI/OptionRows.lua`](UI/OptionRows.lua) | Filas que se repiten en varias clases: encender el aviso, solo en combate, elegir los que valen, umbrales, taunt de la mascota |
| [`UI/Sidebar.lua`](UI/Sidebar.lua) | Barra lateral de la ventana: entradas agrupadas bajo títulos que se pliegan con un clic |
| [`UI/GeneralPage.lua`](UI/GeneralPage.lua) | Página **General**, solo como filas de datos |
| [`UI/ClassPages/ClassPages.lua`](UI/ClassPages/ClassPages.lua) | Registro de secciones por clase |
| [`UI/ClassPages/Hunter.lua`](UI/ClassPages/Hunter.lua) | Sección **Cazador**: páginas Mascota, Munición y Aspectos |
| [`UI/ClassPages/Warrior.lua`](UI/ClassPages/Warrior.lua) | Sección **Guerrero**: páginas Gritos y Tanque |
| [`UI/ClassPages/Warlock.lua`](UI/ClassPages/Warlock.lua) | Sección **Brujo**: páginas Mascota, Reactivos y Armadura |
| [`UI/ClassPages/Paladin.lua`](UI/ClassPages/Paladin.lua) | Sección **Paladín**: páginas Aura, Bendición y Furia justa |
| [`UI/ConfigWindow.lua`](UI/ConfigWindow.lua) | La ventana `/fran config` |
| [`UI/Minimap.lua`](UI/Minimap.lua) | El botón del minimapa de este addon |
| [`Core/Commands.lua`](Core/Commands.lua) | Comandos `/fran` |

---

## Librería común (FranLib)

FranTools, [StreamDeckWoW](https://github.com/fran76yt/StreamDeckWoW) y [FranFundir](https://github.com/fran76yt/FranFundir) usan las mismas piezas genéricas: utilidades, el acceso a la API del juego, el registro de errores, tooltips, casillas y el botón del minimapa. Están en la librería **FranLib**, que va incrustada en [`Libs/FranLib/`](Libs/FranLib), como se hace con Ace3 y el resto de librerías de WoW: cada addon lleva su copia y funciona solo, sin instalar nada más. También es de FranLib el montaje de las [pruebas](#pruebas): `tests/run.js`, `tests/api_stubs.lua` y `tests/package.json`.

La carpeta `Libs/FranLib/` no se edita aquí: el original está en el repositorio FranLib, con sus propias pruebas, y se copia a los addons con su `tools/sync.py` (`--check` solo comprueba que todo coincide).

Lo que la librería necesita saber de este addon (icono, prefijo del chat, variable y comando del registro de errores, nombre del botón del minimapa) está en `ns.FranLibConfig`, al final de [`Core/Constants.lua`](Core/Constants.lua).

### Registro de errores

Si el addon da un error de Lua, queda apuntado aunque el juego tenga apagada la ventana de errores (lo normal). La primera vez en cada sesión sale un aviso en el chat.

Los errores se escriben en un archivo de texto, `WTF\Account\<CUENTA>\SavedVariables\FranTools.lua` (la variable `FranToolsLog`), que se puede abrir con cualquier editor o pasar a quien lo vaya a revisar. Un addon no puede escribir archivos cuando quiere: el juego guarda ese archivo al hacer `/reload`, al cerrar sesión o al salir. Si el juego se cierra de golpe, se pierde lo de esa sesión, así que tras un error conviene hacer `/reload`.

| Comando | Qué hace |
|---|---|
| `/fran errores` | Lista los errores apuntados, con la fecha de la última vez y cuántas veces ha salido cada uno |
| `/fran errores 2` | El error número 2 entero, con su pila de llamadas (qué función llamó a cuál hasta fallar) |
| `/fran errores borrar` | Vacía la lista |

- Se guardan en una variable de **toda la cuenta**, en `WTF\Account\<CUENTA>\SavedVariables\FranTools.lua`: se ven con cualquier personaje y se pueden abrir con un editor de texto.
- Cada error distinto se guarda una vez, con un contador (en combate el mismo puede salir cientos de veces), y como mucho 50: al pasarse se borran los más antiguos.
- Solo los de este addon; los demás siguen su camino como siempre. Con BugSack, que se queda con todos los errores, puede que aquí no llegue nada: entonces se ven en BugSack.
- Un error en una función ya no impide que se ejecuten las demás que esperaban el mismo evento.

---

## Datos guardados

Los errores de Lua apuntados van aparte, en `FranToolsLog`, una variable de toda la cuenta (ver [Registro de errores](#registro-de-errores)). Las opciones, en una variable por personaje, `FranToolsChar`, en:

```
World of Warcraft\_forever_\WTF\Account\<CUENTA>\<Reino>\<Personaje>\SavedVariables\FranTools.lua
```

Solo se guarda lo que has cambiado respecto a los valores por defecto:

```lua
FranToolsChar = {
    ["sidebar"] = { ["Cazador"] = true },        -- grupo plegado en la ventana
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
    ["combatLog"] = { ["startedByUs"] = true },   -- el registro que corre lo encendió el addon
    ["shards"] = { ["thresholds"] = { ["count"] = { ["low"] = 8 } } },
    ["aura"] = { ["chosen"] = { ["retribution"] = false } },
    ["role"] = { ["tank"] = true },               -- casilla Tanqueo yo
    ["taunt"] = { ["point"] = { "CENTER", "CENTER", 220, -40 } },   -- icono de Provocar movido
    ["notices"] = { ["iconOnly"] = true, ["iconSize"] = 36 },     -- solo el icono, más grande
}
```

El detalle de cada campo está en la cabecera de [`Core/Storage.lua`](Core/Storage.lua).

---

## Añadir opciones de una clase

1. La lógica, en `Features/<Clase>.lua`. Si es un aviso de «no llevas X puesto» o «te quedan pocos X», basta con describirlo para los motores [`BuffWarning`](Features/BuffWarning.lua) y [`CountWarning`](Features/CountWarning.lua); el modelo más corto es [`Warrior.lua`](Features/Warrior.lua):

   ```lua
   ns.BattleShout = ns.BuffWarning.Create({
       key = "battleShout",
       boxName = "FranToolsBattleShoutNotice",
       classes = { WARRIOR = true },
       list = { { key = "battleShout", label = "Grito de guerra", spells = { 6673, ... } } },
       missing = "Sin Grito de guerra",
       tooltip = { ... },
   })
   ```

2. Las páginas, en `UI/ClassPages/<Clase>.lua`, siguiendo el modelo de [`UI/ClassPages/Warrior.lua`](UI/ClassPages/Warrior.lua). Solo describe las páginas y sus filas; las comunes están en [`UI/OptionRows.lua`](UI/OptionRows.lua) y los tipos de fila en [`UI/OptionsPage.lua`](UI/OptionsPage.lua):

   ```lua
   ns.ClassPages.Register("WARRIOR", {
       title = "Guerrero",
       pages = {
           { title = "Gritos", rows = {
               Rows.Switch(ns.BattleShout, "Avisar si no llevo Grito de guerra", tooltip),
               Rows.CombatOnly(ns.BattleShout),
           } },
       },
   })
   ```

   La clave es el nombre interno de la clase en inglés: `WARRIOR`, `PALADIN`, `HUNTER`, `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID`. Cada página sale en la barra lateral bajo el nombre de la clase, en su color.

3. Añade las dos líneas al `.toc`, junto a las de las otras clases, y su comando a la lista `TOGGLES` de [`Core/Commands.lua`](Core/Commands.lua).

Un aviso con otra lógica va en su propio módulo de `Features/`, con `Util.Switch` si se enciende y se apaga (como [`RighteousFury.lua`](Features/RighteousFury.lua)). Las opciones para todas las clases van en [`UI/GeneralPage.lua`](UI/GeneralPage.lua).

Los IDs de hechizos y objetos de Forever se consultan en [Wowhead (Forever)](https://www.wowhead.com/forever).

---

## Pruebas

El addon se puede probar sin abrir el juego: [`tests/run.js`](tests/run.js) carga sus archivos en el orden del `.toc`, como hace WoW, sobre una API del juego simulada en Lua, y ejecuta las pruebas de [`tests/test.lua`](tests/test.lua): avisos de cada clase, opciones, comandos, agro, registro de errores, lo que se guarda… Hace falta [Node.js](https://nodejs.org/).

```bash
cd tests
npm install   # la primera vez: instala fengari, un Lua escrito en JavaScript
npm test
```

Cada comprobación que pasa escribe `ok` y la primera que falla para con un error (y el comando sale con código 1). Las SavedVariables que quedarían se escriben en `tests/out/FranTools.lua`, para revisarlas.

| Archivo | Qué es |
|---|---|
| [`tests/test.lua`](tests/test.lua) | Las pruebas de este addon |
| [`tests/api_stubs.lua`](tests/api_stubs.lua) | *De FranLib.* La API de WoW simulada: frames que apuntan lo que se les hace, eventos, temporizadores y el estado del personaje (hechizos, bolsas, combate, auras…) en variables que las pruebas cambian |
| [`tests/run.js`](tests/run.js) | *De FranLib.* Carga la API simulada, el addon y las pruebas |

Las simulaciones que solo usa un addon (por ejemplo TradeSkillMaster, en FranFundir) van en su propio `tests/stubs.lua`. Ojo: aquí corre Lua 5.3 y WoW usa Lua 5.1, así que lo que cambia entre ambos (como los números enteros y decimales) no queda probado. Nada sustituye a probarlo en el juego.

---

## Estructura del proyecto

```
FranTools/
├── FranTools.toc                      metadatos y orden de carga
├── Libs/FranLib/                     librería común (copia de FranLib: no se edita aquí)
├── Core/
│   ├── Constants.lua                  valores fijos
│   ├── Storage.lua                    SavedVariables
│   ├── Migration.lua                  opciones traídas de StreamDeckWoW
│   ├── Role.lua                       quién tanquea
│   ├── Buffs.lua                      beneficios que lleva el jugador
│   ├── Thresholds.lua                 umbrales de aviso
│   └── Commands.lua                   comandos /fran
├── Features/
│   ├── BuffWarning.lua                motor de avisos de beneficio
│   ├── CountWarning.lua               motor de avisos por cantidad
│   ├── ReadyWarning.lua               motor de avisos «ya puedes usarlo»
│   ├── CooldownWarning.lua            motor de avisos de enfriamiento
│   ├── PetTaunt.lua                   aviso del taunt de la mascota
│   ├── Merchant.lua                   reparar y vender la basura
│   ├── Threat.lua                     agro en las barras de nombre
│   ├── CombatLog.lua                  registro de combate en mazmorras y bandas
│   ├── Ammo.lua                       cazador: munición baja
│   ├── Aspect.lua                     cazador: aspecto
│   ├── Warrior.lua                    guerrero: Grito de guerra, Revancha, Provocar
│   ├── Warlock.lua                    brujo: fragmentos, piedra de salud, armadura
│   ├── Paladin.lua                    paladín: aura, bendición
│   └── RighteousFury.lua              paladín: Furia justa
├── UI/
│   ├── NoticeBox.lua                  recuadro de aviso discreto
│   ├── ThreatBadge.lua                marco de agro en una barra de nombre
│   ├── NumberBox.lua                  caja numérica
│   ├── OptionsPage.lua                página de opciones descrita como filas
│   ├── Sidebar.lua                    barra lateral de la ventana
│   ├── GeneralPage.lua                página General
│   ├── OptionRows.lua                 filas comunes a varias clases
│   ├── ClassPages/                    una sección de páginas por clase
│   │   ├── ClassPages.lua             registro
│   │   ├── Hunter.lua                 cazador
│   │   ├── Warrior.lua                guerrero
│   │   ├── Warlock.lua                brujo
│   │   └── Paladin.lua                paladín
│   ├── ConfigWindow.lua               ventana /fran config
│   └── Minimap.lua                    el botón del minimapa de este addon
├── tests/
│   ├── test.lua                       las pruebas
│   ├── api_stubs.lua                  API de WoW simulada (de FranLib)
│   ├── run.js                         carga el addon y ejecuta las pruebas (de FranLib)
│   └── package.json                   dependencia: fengari (de FranLib)
```
