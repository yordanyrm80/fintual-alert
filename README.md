# Fintual Alert

App Flutter para dar seguimiento local a decisiones de inversion en Fintual.

La primera version se enfoca en el PPR con perfil 100% acciones/Risky:

- lectura en vivo de senales de mercado: caida del S&P 500 desde maximos recientes, VIX y USD/MXN
- objetivo anual configurable, por defecto 15,000 MXN
- tope mensual deducible de referencia, por defecto 1,800 MXN
- registro local de depositos
- almacenamiento local en SQLite
- exportacion/importacion de respaldo JSON para mover los mismos datos entre escritorio y telefono
- semaforo de oportunidad: normal, buen momento o muy buen momento
- notificacion local cuando las senales guardadas marcan una oportunidad muy buena

No usa backend propio ni base remota. Lee datos publicos de mercado en internet y guarda la informacion en SQLite dentro del dispositivo.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
