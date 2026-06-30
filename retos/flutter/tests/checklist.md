# Checklist de Verificación — Flutter

## Compilación y ejecución

- [ ] La app compila sin errores (`flutter run`)
- [ ] Corre correctamente en Android (emulador o físico)
- [ ] Corre correctamente en iOS (simulador o físico)
- [ ] No hay warnings críticos en la consola

## Lista de hábitos

- [ ] Pantalla principal muestra lista de hábitos
- [ ] Se puede crear un nuevo hábito (nombre + icono)
- [ ] Se puede editar un hábito existente
- [ ] Se puede eliminar un hábito
- [ ] El check-in diario funciona una sola vez por día
- [ ] La racha (streak) se actualiza correctamente
- [ ] Aparece mensaje "Agrega tu primer hábito" si la lista está vacía

## Estadísticas semanales

- [ ] La pantalla de estadísticas es accesible
- [ ] El gráfico de barras muestra los últimos 7 días
- [ ] Las barras reflejan correctamente los check-ins registrados
- [ ] El gráfico se anima al cargar

## Notificaciones push locales

- [ ] Se puede configurar la hora del recordatorio
- [ ] La notificación se dispara a la hora configurada
- [ ] Al tocar la notificación se abre la app

## Persistencia SQLite

- [ ] Los hábitos persisten al cerrar y reabrir la app
- [ ] Los check-ins persisten al cerrar y reabrir la app
- [ ] La estructura de tablas es la especificada
- [ ] Las consultas de racha y estadísticas funcionan correctamente

## Tema claro/oscuro

- [ ] El interruptor de tema está presente en ajustes
- [ ] Cambiar el tema funciona inmediatamente
- [ ] Los colores del gráfico se adaptan al tema activo

## Animaciones

- [ ] Animación al hacer check-in (escala, confeti u otra)
- [ ] Animación en la lista al agregar/eliminar hábitos
- [ ] Transición suave entre pantallas
- [ ] Animación de carga del gráfico

## Código

- [ ] Sigue las convenciones de Dart (formateo con `dart format`)
- [ ] No hay variables no utilizadas
- [ ] Manejo de errores con try-catch en operaciones de BD
- [ ] Uso correcto de `async`/`await`
- [ ] Los widgets requeridos están implementados

## Puntuación (100 pts)

| Criterio | Pts |
|----------|-----|
| Lista de hábitos + check-in | 20 |
| Estadísticas semanales + gráfico | 15 |
| Notificaciones push locales | 15 |
| Persistencia SQLite | 15 |
| Tema claro/oscuro | 10 |
| Animaciones | 10 |
| Calidad del código y convenciones | 10 |
| Funciona en ambas plataformas | 5 |
