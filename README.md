# Bogotá Hill

Juego de conducción 2D en Godot **4.7.2**, con el terreno, las imágenes y los sonidos que ya estaban incluidos en el proyecto.

Abre `project.godot` en Godot y pulsa **F5**. La escena principal es `Levels/level_1.tscn`. Llega a la bandera de meta, recoge monedas y bidones, y evita golpear la cabeza del conductor contra el suelo.

## Controles

| Acción | Teclas |
| --- | --- |
| Acelerar | D / flecha derecha |
| Retroceder | A / flecha izquierda |
| Inclinar el carro | W / S o flechas arriba / abajo |
| Pausar / continuar | P / Esc |
| Reiniciar | R; Enter también funciona al terminar |
| Silenciar / activar sonido | M |

Los botones de la interfaz permiten pausar, reiniciar y cambiar el sonido. El juego se pausa al perder el foco; vuelve a continuar manualmente para evitar accidentes al cambiar de ventana. La vista conserva su proporción al redimensionarla.

## Referencia y partes completadas

[How to make Hill Climb Racing in Godot — LucyLavend](https://www.youtube.com/watch?v=nPX9MrnvNLo).

La cobertura funcional del tutorial está completa: configuración del proyecto (1:07), carro físico con ruedas y suspensión (2:20), terreno SmartShape2D (13:50), monedas y contador (20:10), combustible y repostaje (32:35), además de las tres partes finales descritas abajo. Se conserva el nivel original y se adaptan las APIs a Godot 4; el diseño del HUD y los ajustes del recorrido son propios de este proyecto.

- **48:26, conductor:** cuerpo, cabeza física, articulación del cuello y muelle. Se adaptó la solución a Godot 4 con `PinJoint2D`, `DampedSpringJoint2D` y restauración angular amortiguada. También se tuvo en cuenta el [aviso de la autora sobre las articulaciones omitidas](https://www.youtube.com/watch?v=vwe3_2HfGjo).
- **53:26, mejoras:** control del chasis en el aire, fricción de ruedas, accidente por contacto de la cabeza o torsión excesiva del cuello y alarma de combustible bajo.
- **1:01:36, fondo:** colinas y nubes con velocidades distintas y repetición horizontal; se utiliza `Parallax2D` de Godot 4.

Extras: HUD en español, porcentaje de combustible, distancia y progreso, pausa, reinicio con teclado y botones, silencio persistente, meta y resumen final. Los récords de distancia y monedas se guardan al terminar o reiniciar cada partida en `user://records.cfg`, junto con la preferencia de sonido. El motor reproduce un bucle con tono variable y libera su reproducción al cambiar de escena.

Se corrigieron el consumo de combustible con decimales, el procesamiento del carro durante la pausa, las recogidas duplicadas por carro y ruedas, las máscaras y el tamaño de recogida de las monedas, el temporizador pendiente después de repostar y el acceso a una interfaz ya eliminada al reiniciar. Se conservaron los controles adicionales W/S y se añadieron bidones para completar el terreno existente.

El combustible se consume al acelerar o retroceder. Al agotarse quedan **5 segundos** para alcanzar un bidón por inercia. La alarma aparece al llegar al 20 %. El motor se detiene al finalizar.

Los tres bidones se sitúan completamente sobre la superficie, con separación respecto al borde de césped y a las monedas. El segundo y el tercero se reubicaron para evitar enterrarlos o dejarlos sobre una caída muy pronunciada. Una partida completa puede recoger los tres.

## Validación

Ejecutar desde la carpeta del proyecto, sustituyendo `godot` por la ruta al ejecutable de consola si no está en el PATH:

```powershell
./tests/run_tests.ps1 -GodotPath "C:/ruta/a/Godot_console.exe"
```

**47 comprobaciones aprobadas** en Godot 4.7.2: entradas físicas y lógicas, pausa/reanudación/reinicio por el sistema de eventos, consumo de combustible, recogida única, recuperación tras repostar, alarma, accidente, fin por combustible, récords al reiniciar y un recorrido físico completo hasta la meta recogiendo los tres bidones. Se verifica todo el ancho de cada bidón contra el terreno y que ninguno se superponga con monedas. Las pruebas utilizan un archivo de guardado separado que eliminan al terminar. El lanzador también detecta errores de script aunque el proceso de Godot devuelva código cero.

También se revisaron la interfaz y los tres bidones con el renderizador real de Godot. No se ha generado un ejecutable exportado.

## Recursos

Se reutilizan los recursos existentes del tutorial y la fuente Fredoka One (licencia en `OFL.txt`). El editor de terreno incluido es SmartShape2D, en `addons/rmsmartshape`. No se sustituyó el terreno original.
