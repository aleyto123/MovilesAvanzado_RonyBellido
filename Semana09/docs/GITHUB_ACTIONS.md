# Ejecutar Semana09 en GitHub Actions

El workflow **Semana09 - Simulador iPhone** usa macOS 15 con Xcode 16.4. Crea un iPhone 16 Pro con un runtime de iOS 18 instalado en el runner y ejecuta la app SwiftUI.

## Iniciar y ver la ejecución

1. Abrir la pestaña **Actions** del repositorio y elegir **Semana09 - Simulador iPhone**.
2. Abrir la ejecución correspondiente al último commit. Se inicia al subir cambios de la app a `main` o `codex/semana09-simulador`, y al abrir o actualizar una solicitud de cambios.
3. Cuando el workflow esté en la rama predeterminada, también se podrá pulsar **Run workflow** y elegir la rama.
4. Al terminar, bajar a **Artifacts** y descargar **Semana09-evidencias**. Descomprimirlo y abrir la carpeta `capturas` o el video `recorrido-simulador.mp4`.

Actions ejecuta las interacciones automáticamente. La grabación muestra el simulador durante las pruebas; no ofrece una pantalla remota para manejar el iPhone con el ratón.

## Comprobaciones

| Prueba de interfaz | Resultado esperado |
| --- | ---: |
| Caso 1: ONP, sin hijos, mes completo | Neto S/ 2,175.00 |
| Caso 2: ONP, con hijos, 27 días | Neto S/ 1,516.41 |
| Caso 3: AFP Ejemplo, extras y adelanto | Neto S/ 2,631.73 |
| Caso 4: AFP Ejemplo, 24 días | Neto S/ 3,011.17 |
| Cambiar los días de 30 a 31 después de calcular | Retira el resultado anterior y muestra el error |

Las pruebas completan el formulario, pulsan **Calcular boleta** y comprueban importes en la pantalla. Los cálculos se ejecutan por la misma ruta que usa el usuario. Antes se ejecutan también las pruebas del paquete `BoletaCore`.

## Archivos publicados

* **Semana09-evidencias**: capturas PNG, video MP4, informe de Xcode `BoletaPago.xcresult`, resultados numéricos del motor y logs de compilación y pruebas. El informe se puede abrir en Xcode; las imágenes, el video y los logs se pueden consultar en Windows.
* **Semana09-app-simulador**: la aplicación `.app` compilada, dentro de un ZIP. Se puede instalar en otro simulador de iOS en una Mac.

Si falla la compilación o una prueba, la ejecución se marca como fallida y se conservan los logs disponibles. Los artifacts se guardan durante 14 días.

Configuración: [workflow](../../.github/workflows/semana09-simulador.yml), [script del simulador](../tools/ci/simulador.sh) y [pruebas de interfaz](../UITests/BoletaPagoUITests.swift).
