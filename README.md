# MA U

App Flutter para estudiantes universitarios. La primera version trae una calculadora de notas, pero el proyecto queda preparado para crecer como asistente academico.

## Arquitectura inicial

- `lib/main.dart`: punto de entrada.
- `lib/app`: configuracion principal de la app.
- `lib/core`: piezas compartidas, como tema visual.
- `lib/features`: modulos funcionales separados por dominio.
- `test`: pruebas de logica y comportamiento visible.

## Modulos propuestos

- Calculadora de notas por cortes y simulador de promedio.
- Agenda academica para clases, parciales y entregas.
- Tareas y proyectos por materia con prioridad y fecha limite.
- Materias con creditos, docente, salon y horario.
- Recursos de estudio: apuntes, enlaces, documentos y recordatorios.
- Panel de progreso para ver riesgos academicos antes de final de semestre.

## Comandos utiles

```bash
flutter pub get
flutter analyze
flutter test
```
