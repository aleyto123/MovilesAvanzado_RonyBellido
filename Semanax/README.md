# DOCUMENTO DE REQUERIMIENTOS FUNCIONALES

**Proyecto:** Sistema de Consulta de Estaciones y Conexiones de Transporte  
**Desarrollador:** Rony Bellido  
**Fecha:** 8 de Septiembre de 2026  
**Módulo:** Laboratorio 03 - Colecciones Avanzadas en Swift  

## Especificación de Requerimientos

| ID | Nombre del Requerimiento | Descripción Detallada | Criterio de Aceptación |
| :--- | :--- | :--- | :--- |
| **REQ-01** | **Búsqueda por Estación** | El sistema debe permitir al usuario ingresar el nombre de una estación (ej. "Grau") para consultar su información, siendo insensible a mayúsculas y minúsculas. | El sistema captura el input mediante consola y formatea la cadena para coincidir con la clave primaria del diccionario. |
| **REQ-02** | **Despliegue de Conectividad** | Al ubicar una estación, el software debe retornar una vista que incluya: Línea principal, cruce de avenidas, opciones de transbordo y lugares cercanos. | Se muestra en consola la información desglosada extrayendo los datos de la tupla asociada a la estación. |
| **REQ-03** | **Búsqueda Inversa** | El usuario debe poder ingresar un destino final (ej. "Estadio Nacional") y el sistema calculará qué estación y conexiones tomar. | El algoritmo itera sobre los arrays internos de lugares de todas las estaciones y retorna la ruta exacta si hay coincidencia. |
| **REQ-04** | **Gestión de Errores** | Si el usuario ingresa una estación o punto que no existe, el sistema debe capturar el error y mostrar un aviso. | Se imprime un mensaje de error claro usando Optional Binding (`if let`) para evitar cierres forzados. |
| **REQ-05** | **Interfaz Iterativa** | El programa debe mantenerse en ejecución continua para permitir múltiples consultas seguidas. | Se implementa un menú principal dentro de un ciclo `while` controlado por una variable bandera. |