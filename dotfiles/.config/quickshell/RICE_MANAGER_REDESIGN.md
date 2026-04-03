# Rice Manager Panel — Rediseño

## Cambios Principales

### 1. **Estructura Mejorada**
El panel ahora está dividido en **4 secciones claras**:

```
┌─────────────────────────────────────────────┐
│  ⚙ RICE MANAGER                  [tema] [×] │  ← Header
├─────────────────────────────────────────────┤
│                                             │
│  🎨 TEMAS                                   │  ← Sección 1
│  [Button][Button] [Button][Button]          │    Temas con
│  [Button][Button] [Button][Button]          │    indicador activo
│                                             │  
│  🌓 MODO                                    │  ← Sección 2
│  [Light*] [Dark ]                           │    Modo con
│                                             │    indicador activo
│  🖼 WALLPAPER                               │  ← Sección 3
│  • Generado por Matugen                     │    Wallpaper:
│    [Aplicar]                                │    - Generado
│  • Imagen desde archivo                     │    - Imagen
│    [path input] [Seleccionar]               │    - Color sólido
│    [Aplicar Imagen]                         │
│  • Color sólido                             │
│    [#color] [preview] [Aplicar Color]       │
│                                             │
│  ⚡ ACCIONES                                │  ← Sección 4
│  [Abrir Pictures] [Abrir Scripts]           │    Acciones rápidas
│  [Aplicar Guardado] [Ver Estado]            │
│                                             │
└─────────────────────────────────────────────┘
```

### 2. **Componentes Reutilizables**

#### `ThemeButton`
- Muestra el nombre del tema
- **Activo**: Borde blanco grueso + color accent
- **Inactivo**: Borde gris + color normal

#### `ModeButton`
- Botón Light/Dark
- **Activo**: Resaltado (accent)
- **Inactivo**: Apagado

#### `ActionButton`
- Botón genérico con state `enabled/disabled`
- **Habilitado**: clickeable + color visible
- **Deshabilitado**: opacidad reducida (gris) + no interactivo

### 3. **Mejoras de UX**

✅ **Indicador visual de tema actual en el header**
```qml
Text {
    text: window.currentTheme
    font.family: Core.Theme.fontMono
    font.pixelSize: Core.DPI.s(8)
}
```

✅ **Botones de tema con estado visual**
- Tema activo: borde blanco de 3px
- Tema inactivo: borde gris de 2px

✅ **Preview de color sólido**
```qml
Rectangle {
    color: try { solidSeed.text } catch(e) { "#000000" }
}
```

✅ **Wallpaper image button deshabilitado si el path está vacío**
```qml
enabled: wallpaperPath.text.trim().length > 0
```

✅ **Organización clara por secciones**
- Cada sección tiene su propio `Core.RetroBox` con color distinto
- Subtítulos con emojis para identificar rápidamente

### 4. **Funcionalidades Activas**

| Acción | Estado | Detalles |
|--------|--------|----------|
| Cambiar Tema | ✅ Funcional | Click directo + indicador visual |
| Modo Light/Dark | ✅ Funcional | Toggle rápido |
| Wallpaper Generado | ✅ Funcional | Con un click |
| Wallpaper Imagen | ✅ Funcional | Con validación de path |
| Wallpaper Color | ✅ Funcional | Con preview en vivo |
| Abrir Pictures | ✅ Funcional | Abre Thunar |
| Abrir Scripts | ✅ Funcional | Abre Thunar |
| Aplicar Guardado | ✅ Funcional | Reaplica la config guardada |
| Ver Estado | ✅ Funcional | Muestra estado actual |

### 5. **Tamaños y Spacing**
- **Panel**: 700px × 580px (ampliado para mejor UX)
- **Secciones**: 12px separación entre ellas
- **Botones tema**: Grid 2 columnas, 160px × 28px
- **Modo**: Row 2 botones, 110px × 32px
- **Wallpaper**: Cajas anidadas con 8px padding interno

### 6. **Validaciones**
- **Imagen wallpaper**: Solo se habilita si hay path
- **Color wallpaper**: Solo se habilita si hay valor hex
- **Preview color**: Intenta parsear el valor en tiempo real

---

## Próximos Pasos (Opcional)

- [ ] Agregar paleta de colores preestablecidos para wallpaper
- [ ] Mostrar vista previa del wallpaper actual
- [ ] Persister estado del panel (posición al cerrar)
- [ ] Integrar color picker nativo de quickshell
