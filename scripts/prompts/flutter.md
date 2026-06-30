# Reto: Flutter — App de Hábitos Diarios

Debes crear una aplicación móvil en Flutter para llevar un registro de hábitos diarios con check-in, estadísticas, notificaciones y persistencia local.

## Funcionalidades requeridas

1. **Lista de hábitos con check-in diario** — CRUD de hábitos, marcar como completado cada día
2. **Estadísticas semanales** — Gráfico de barras mostrando racha semanal
3. **Notificaciones push locales** — Recordatorio diario para hacer check-in
4. **Persistencia con SQLite** — Usando sqflite, datos persisten entre sesiones
5. **Tema claro/oscuro** — Selector de tema con persistencia de preferencia
6. **Animaciones** — Transiciones suaves entre pantallas

## Archivos que debes crear

### `pubspec.yaml`
Con dependencias: flutter, sqflite, path, fl_chart, flutter_local_notifications, provider o riverpod.

### `lib/main.dart`
Punto de entrada con configuración de tema claro/oscuro y rutas.

### `lib/models/habit.dart`
Modelo Habit con id, nombre, descripción, createdAt.

### `lib/models/habit_record.dart`
Modelo HabitRecord con id, habitId, fecha, completado.

### `lib/database/database_helper.dart`
Helper de SQLite con creación de tablas y operaciones CRUD.

### `lib/screens/home_screen.dart`
Lista de hábitos con check-in diario.

### `lib/screens/stats_screen.dart`
Estadísticas semanales con gráfico de barras (fl_chart).

### `lib/screens/add_habit_screen.dart`
Formulario para crear/editar hábito.

### `lib/services/notification_service.dart`
Servicio de notificaciones push locales.

### `lib/providers/theme_provider.dart`
Provider para tema claro/oscuro.

## Restricciones

- No uses Firebase ni servicios en la nube
- Todo debe ser local y autocontenido
- Sigue las convenciones de Dart/Flutter (nombres, estructura)
- La app debe compilar y funcionar tanto en Android como en iOS
- No uses StatefulWidget donde un stateless widget baste; usa Provider o Riverpod para estado

## Criterios de evaluación (100 pts)

- Lista de hábitos + check-in (20 pts)
- Estadísticas semanales con gráfico (15 pts)
- Notificaciones push locales (15 pts)
- Persistencia SQLite (15 pts)
- Tema claro/oscuro (10 pts)
- Animaciones (10 pts)
- Calidad del código y convenciones (10 pts)
- Funciona en ambas plataformas (5 pts)

## Formato de salida

```dart
// filepath: pubspec.yaml
// ...
```

```dart
// filepath: lib/main.dart
// ...
```

(Repite para cada archivo con la ruta completa como comentario.)
