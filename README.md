# Ciudad Viva

Un juego corto en 3D en tercera persona: son las 6:40 de la tarde en la Calle 27 y el barrio está lleno de gente que necesita un mandado. Caminas, entras a los negocios, conversas y te haces un nombre en la cuadra.

## Cómo se juega

Empiezas sin clientela. En cada negocio hay dos personas: habla con ellas, ofrécele tus mandados y pregunta por el barrio. Cada cliente nuevo suma reputación y te acerca al objetivo.

- Objetivo: conseguir **5 clientes**.
- Al lograrlo aparece la tarjeta de cierre del día con tus clientes y tu reputación; cualquier tecla la cierra y puedes seguir caminando.

### Controles

| Acción | Tecla |
| --- | --- |
| Caminar | `WASD` o flechas |
| Mover la cámara | ratón |
| Correr | `Shift` |
| Hablar, entrar y salir | `E` |
| Elegir respuesta | `1`, `2`, `3` |
| Completar el texto / continuar | `Espacio` |
| Salir del diálogo | `Esc` |

## El barrio

- Ferretería El Tornillo de Oro — Don Aurelio atiende, Doña Elvira compra.
- Papelería Papel & Tinta — Doña Nelly atiende, Sofía estudia fotografía.
- Café La Esquina — Camila atiende, Don Jorge espera su tinto.

Cada persona tiene sus propias líneas de conversación y sus propios contactos para recomendarte.

## Cómo abrirlo

- Motor: Summer Engine 0.8.5 (basado en Godot 4.7).
- Escena principal: `main.tscn`.
- Renderizador: Vulkan. El proyecto usa `rendering/rendering_device/driver.windows = "vulkan"` porque Direct3D 12 no está disponible en todas las tarjetas.

## Estructura

| Ruta | Qué contiene |
| --- | --- |
| `main.tscn` | Escena principal: ciudad, jugador, cámara, diálogos y HUD |
| `world/city.tscn` | La Calle 27 completa: calzada, andenes, fachadas, interiores, mobiliario y personajes |
| `scripts/main.gd` | Arranque, luces, audio ambiental, puertas y cierre del día |
| `scripts/player.gd` | Movimiento del jugador, animaciones y detección de lo que tiene cerca |
| `scripts/orbit_camera.gd` | Cámara en tercera persona con brazo elástico |
| `scripts/dialogue_flow.gd` | Reglas de la conversación: ofrecer mandados, preguntar, dar clientes |
| `scripts/game_data.gd` | Textos de los negocios, clientes y títulos de reputación |
| `scripts/game_state.gd` | Estado de la partida (autoload `GameState`) |
| `scripts/hud.gd` | Tarjetas de clientela, avisos, diálogo y tarjeta de final de día |
| `scripts/person.gd` | Personajes que conversan, giran hacia el jugador y caminan |
| `tools/build_city.gd` | Genera `world/city.tscn` (con `geo.gd`, `mats.gd` y `shops.gd`) |
| `tools/make_ambience.gd` | Genera el audio ambiental de calle e interior |
| `library/` | Luz de hora dorada y efectos de sonido |
| `art/` | Modelos de personajes |

Para reconstruir la ciudad después de cambiar el generador:

```
Summer.exe --headless --path . -s res://tools/build_city.gd
```

## Créditos

- Efectos de sonido: Interface Sounds, Impact Sounds y RPG Audio de Kenney (kenney.nl), CC0 1.0.
- Modelos de personajes y ambiente: generados para este proyecto.
