# Fintual Alert

App Flutter para dar seguimiento local a decisiones de inversion en Fintual.

La primera version se enfoca en el PPR con perfil 100% acciones/Risky:

- captura de senales locales de mercado: caida desde maximos, VIX y USD/MXN
- objetivo anual configurable, por defecto 15,000 MXN
- tope mensual deducible de referencia, por defecto 1,800 MXN
- registro local de depositos
- semaforo de oportunidad: normal, buen momento o muy buen momento
- notificacion local cuando las senales guardadas marcan una oportunidad muy buena

No usa backend ni APIs externas en esta version. Los datos se guardan en el dispositivo con `shared_preferences`.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
