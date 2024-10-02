[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=12189728&assignment_repo_type=AssignmentRepo)
# Ejemplo base de Jack en C++

Este ejemplo construye una aplicación muy sencilla de "pass-through"
usando Jack, como punto de partida para los proyectos y tareas del
curso.

Esta versión permite además, recibir además una lista de archivos
.wav, que se ejecutan uno tras otro, reemplazando la entrada de
micrófono en tanto hayan datos de los archivos disponibles.  Una vez
que todos los archivos terminan de ejecutarse, regresa al modo
"pass-through".

## Dependencias

Requiere C++ en su estándar del 2020 (g++ 12, clang 14).

En derivados de debian (ubuntu, etc):

     sudo apt install jackd2 libjack-jackd2-dev qjackctl build-essential meson ninja-build libboost-all-dev libsndfile1-dev libsndfile1 
     
Jack requiere que su usuario pertenezca al grupo audio, o de otro modo
no tendrá privilegios para el procesamiento demandante en tiempo
real...

     sudo usermod -aG audio <su usuario>

## Construcción

Para construir los ejemplos la primera vez utilice

     meson setup builddir
     cd build
     ninja


Si requiere reconstruir todo, utilice

     meson setup --wipe builddir
     cd build
     ninja

## Latencia y tamaño de bloque

Para reducir la latencia por medio del tamaño del "periodo" (esto es,
el número de "frames" que cada ciclo de procesamiento recibe, en
QjackCtl, en Settings, se indica en Frames/Period.  Eso es un
parámetro del servidor de Jack y no lo puede controlar la aplicación
como tal.
