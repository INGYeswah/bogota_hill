# 🏔️ Bogotá Hill 🚙

**Bogotá Hill** es un videojuego de conducción en 2D desarrollado con **Godot Engine 4.7.2**, inspirado en los juegos de ascenso y conducción basados en físicas. El jugador debe conducir un vehículo a través de un terreno irregular, controlar su equilibrio, recoger monedas y galones  de combustible, y alcanzar la meta evitando accidentes.

<img width="989" height="600" alt="image" src="https://github.com/user-attachments/assets/4ad646a7-af77-4dd9-bcfc-61277a68b378" />

<img width="996" height="598" alt="image" src="https://github.com/user-attachments/assets/6a760042-6b97-4db1-aff4-8818d9b52252" />

<img width="999" height="601" alt="image" src="https://github.com/user-attachments/assets/9db6ae48-a7dc-41e7-bcb4-4f42d6a0dfca" />


<img width="1159" height="692" alt="image" src="https://github.com/user-attachments/assets/25d1196a-5c6f-4dc5-bbb4-d89fd90b48b6" />
<img width="1158" height="633" alt="image" src="https://github.com/user-attachments/assets/effc4afb-cc92-4f19-8410-48522e056630" />

<img width="1148" height="638" alt="image" src="https://github.com/user-attachments/assets/59e655fc-d334-4b8c-a5f7-1dd6db1ba503" />


## 🎮 Características principales

- **Física del vehículo:** sistema de conducción con ruedas, suspensión y comportamiento físico.
- **Terreno dinámico:** recorrido con colinas y desniveles mediante SmartShape2D.
- **Sistema de monedas:** recolección de monedas y contador de puntuación.
- **Sistema de combustible:** consumo durante la conducción y posibilidad de repostar mediante bidones.
- **Conductor físico:** personaje con cuerpo, cabeza y articulaciones físicas.
- **Sistema de accidentes:** detección de impactos de la cabeza y torsión excesiva del cuello.
- **Interfaz de usuario:** indicadores de combustible, distancia, progreso y monedas.
- **Sistema de pausa y reinicio:** controles mediante teclado y botones de interfaz.
- **Sistema de sonido:** efectos de audio, sonido del motor y opción para silenciar.
- **Meta y resumen final:** finalización del recorrido y presentación de resultados.
- **Récords:** almacenamiento local de los mejores resultados y preferencias de sonido.

## 🕹️ Controles

| Acción | Teclas |
|---|---|
| Acelerar | D / Flecha derecha |
| Retroceder | A / Flecha izquierda |
| Inclinar el vehículo | W / S |
| Inclinar el vehículo (alternativa) | Flechas arriba / abajo |
| Pausar / continuar | P / Esc |
| Reiniciar partida | R |
| Continuar después de finalizar | Enter |
| Silenciar / activar sonido | M |

La interfaz también permite utilizar los botones disponibles para pausar, reiniciar y controlar el sonido.

## 🛠️ Tecnologías y herramientas

- **Motor de desarrollo:** Godot Engine 4.7.2.
- **Lenguaje de programación:** GDScript.
- **Tipo de proyecto:** videojuego 2D.
- **Física:** sistema de físicas 2D de Godot.
- **Control de versiones:** Git y GitHub.
- **Editor de terreno:** SmartShape2D.
- **Tipografía:** Fredoka One.

## 📥 Instalación y ejecución

### Requisitos

- Godot Engine 4.7.2.
- Git.
- Sistema operativo compatible con Godot.

### 1. Clonar el repositorio

```bash
git clone https://github.com/INGYeswah/bogota_hill.git
```

### 2. Ingresar al directorio

```bash
cd bogota_hill
```

### 3. Abrir el proyecto

Abre Godot Engine, selecciona **Importar** y busca el archivo `project.godot` dentro de la carpeta del proyecto.

También puedes abrirlo desde una terminal:

```bash
godot --editor project.godot
```

### 4. Ejecutar el juego

Una vez importado el proyecto, pulsa **F6** para ejecutar la escena actual o **F5** para iniciar el juego desde la escena principal configurada.

La escena del primer nivel es:

```text
Levels/level_1.tscn
```

## 📁 Estructura del proyecto

```text
bogota_hill/
│
├── Audio/              # Efectos de sonido y recursos de audio
├── Code/               # Scripts y lógica del videojuego
├── Images/             # Imágenes y recursos gráficos
├── Levels/             # Escenas de los niveles
├── Scenes/             # Escenas y componentes reutilizables
├── addons/
│   └── rmsmartshape/   # Complemento SmartShape2D
├── tests/              # Pruebas automatizadas
│
├── project.godot       # Configuración principal del proyecto
├── icon.svg            # Icono del proyecto
├── OFL.txt             # Licencia de la tipografía
└── README.md           # Documentación del proyecto
```

## ⚙️ Mecánicas de juego

Durante el recorrido, el jugador debe recoger la mayor cantidad de  monedas para optener puntos, recoger  combustible que permite que el vehiculo avance  y mantener el equilibrio del vehículo para evitar que este se volque.

- El combustible disminuye al acelerar o retroceder.
- Los galones permiten recuperar combustible.
- Cuando el combustible se agota, el jugador dispone de un tiempo limitado para alcanzar un galon aprovechando la inercia.
- La alarma de combustible bajo se activa al llegar al 20 %.
- El vehículo puede sufrir un accidente si la cabeza del conductor impacta contra el terreno o si se supera el límite de torsión del cuello.
- Las monedas recogidas se acumulan en el contador de la interfaz.

Al completar el recorrido, se muestra un resumen con los resultados de la partida.

## 🧪 Pruebas y validación

El proyecto cuenta con un conjunto de pruebas automatizadas para verificar el funcionamiento de sus principales mecánicas.

En la validación realizada con Godot 4.7.2 se obtuvieron **47 comprobaciones aprobadas**, que incluyen:

- Entradas físicas y controles del vehículo.
- Pausa, reanudación y reinicio.
- Consumo de combustible.
- Recolección de monedas y bidones.
- Recuperación del combustible.
- Activación de la alarma.
- Detección de accidentes.
- Finalización por agotamiento de combustible.
- Almacenamiento de récords y preferencias.
- Recorrido físico completo hasta la meta.

También se verificó la ubicación de los bidones sobre el terreno y su separación respecto a las monedas.

> Las pruebas se ejecutan mediante los archivos incluidos en la carpeta `tests`. No se incluye todavía un ejecutable exportado del videojuego.

## 📚 Referencia de desarrollo

El proyecto toma como referencia el tutorial:

[How to make Hill Climb Racing in Godot — LucyLavend](https://www.youtube.com/)

Se adaptaron las mecánicas y los recursos a Godot 4, incorporando funcionalidades adicionales y modificaciones propias del proyecto.

## 🚶 Autores

Proyecto académico desarrollado de manera colaborativa por estudiantes del programa de ingieneria de sistemas y computacion, de la Universida Nacional de Colombia para el curso de Computacion visual

    Integrantes:
   ⛽ Arnold Oswaldo Acosta
   
   ⛽ Yeswah Gonzales Tapia
   
   ⛽ Jose Alejandro Ordoñez
   
   ⛽ Juan David Peña


## 👥 Créditos

Proyecto desarrollado de manera colaborativa utilizando Godot Engine 4.

Los recursos gráficos, de audio y las herramientas externas conservan sus respectivas licencias y atribuciones. La tipografía Fredoka One se distribuye bajo la licencia indicada en `OFL.txt`.

## 📄 Licencia

Consulta los archivos de licencia incluidos en el repositorio para conocer las condiciones de uso de los recursos externos.
