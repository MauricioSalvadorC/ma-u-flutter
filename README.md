# Ma-U

App Flutter para estudiantes universitarios. La primera version trae una calculadora de notas, pero el proyecto queda preparado para crecer como asistente academico.

## Arquitectura inicial

- `lib/main.dart`: punto de entrada.
- `lib/app`: configuracion principal de la app.
- `lib/core`: piezas compartidas, como tema visual.
- `lib/features`: modulos funcionales separados por dominio.
- `test`: pruebas de logica y comportamiento visible.

## Modulos propuestos

- Calculadora de notas.
- Promedio acumulado.
- Horario de clases.
- Recordatorios de tareas.
- Control de parciales.
- Lista de materias.
- Notas por semestre.
- Calculadora de cuanto necesito para pasar.
- Gastos universitarios.
- Agenda de estudio.
- Modo semana de parciales.

## Pantalla principal

El tablero inicial se organiza en tarjetas:

- Calcular notas.
- Horario.
- Tareas.
- Gastos.
- Metas academicas.

## Comandos utiles

```bash
flutter pub get
flutter analyze
flutter test
```

## Comandos que conviene saber

- `flutter pub get`: instala o actualiza las dependencias del proyecto.
- `flutter analyze`: revisa errores y malas practicas sin ejecutar la app.
- `flutter test`: corre las pruebas automatizadas.
- `flutter run`: abre la app en un emulador, celular o navegador conectado.
- `flutter clean`: limpia archivos generados cuando el proyecto se pone raro.
- `dart format lib test`: ordena el formato del codigo.
- `git status --short`: muestra que archivos cambiaste.
- `git diff`: muestra exactamente que cambio en el codigo.
