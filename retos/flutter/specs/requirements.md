# Especificación: App de Seguimiento de Hábitos

## Requisitos funcionales

### 1. Lista de hábitos con check-in diario

- La pantalla principal debe mostrar una lista de hábitos.
- Cada hábito debe tener: nombre, icono, racha actual (días consecutivos), botón de check-in.
- El check-in solo puede hacerse una vez por día por hábito.
- Al hacer check-in, se debe registrar la fecha y mostrar retroalimentación visual (animación de confirmación).
- Los hábitos deben persistir entre sesiones.

### 2. Estadísticas semanales (gráfico de barras)

- Pantalla de estadísticas accesible desde la navegación inferior o un botón.
- Mostrar un gráfico de barras con los check-ins de los últimos 7 días.
- Cada barra representa un día (lun-dom) y su altura el número de hábitos completados.
- Usar `fl_chart` o `syncfusion_flutter_charts`.
- La gráfica debe animarse al cargar.

### 3. Notificaciones push locales

- El usuario debe poder configurar un recordatorio diario (hora).
- Usar `flutter_local_notifications`.
- La notificación debe dispararse a la hora configurada.
- Al tocar la notificación, debe abrir la app en la pantalla principal.

### 4. Persistencia con SQLite

- Usar `sqflite` + `path`.
- Tabla `habitos`: id, nombre, icono, fecha_creacion.
- Tabla `checkins`: id, id_habito (FK), fecha.
- Consultas: obtener hábitos con racha, check-ins por fecha, check-ins de los últimos 7 días.

### 5. Tema claro/oscuro

- Alternar entre tema claro y oscuro desde un interruptor en la pantalla de ajustes.
- Usar `ThemeProvider` o `ChangeNotifier` con `MaterialApp.themeMode`.
- Los colores del gráfico deben adaptarse al tema activo.

### 6. Animaciones

- Animación al completar check-in (escala o confeti).
- Animación de desplazamiento en la lista (`AnimatedList` o `Hero`).
- Transición suave entre pestañas (`AnimatedSwitcher` o `PageView`).
- Animación de carga del gráfico de barras.

## Widgets requeridos

| Widget | Propósito |
|--------|-----------|
| `HabitTile` | Cada item de la lista de hábitos |
| `HabitForm` | Formulario para crear/editar hábito |
| `StatsPage` | Pantalla de estadísticas semanales |
| `SettingsPage` | Pantalla de ajustes (tema, notificaciones) |
| `HabitProvider` / `HabitBloc` | Manejo de estado (Provider, Riverpod o BLoC) |

## Comportamiento esperado

- Al iniciar la app por primera vez, la lista debe estar vacía con un mensaje "Agrega tu primer hábito".
- Al crear un hábito, debe aparecer en la lista inmediatamente.
- El check-in debe ser instantáneo y mostrar feedback visual.
- El cambio de tema debe aplicarse sin reiniciar la app.
- Las notificaciones deben respetar la hora configurada aunque la app esté cerrada.
