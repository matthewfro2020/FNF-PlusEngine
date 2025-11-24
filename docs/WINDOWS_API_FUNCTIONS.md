# Windows API Functions - Guía Completa

## Funciones Nuevas Agregadas (v1.2.0)

### 🖼️ Funciones de Escritorio Avanzadas

#### `getDesktopWindowsXPos()` -> Int
Obtiene la posición X actual de las ventanas del escritorio.

#### `getDesktopWindowsYPos()` -> Int
Obtiene la posición Y actual de las ventanas del escritorio.

### 🎨 Apariencia de Ventana

#### `setWindowBorderColor(r, g, b)`
Cambia el color del borde de la ventana.
- **r**: Rojo (0-255)
- **g**: Verde (0-255)
- **b**: Azul (0-255)

```lua
setWindowBorderColor(255, 0, 0)
```

#### `setWindowOpacity(alpha)`
Establece la opacidad de la ventana principal.
- **alpha**: 0.0 (transparente) a 1.0 (opaco)

```lua
setWindowOpacity(0.5)
```

#### `getWindowOpacity()` -> Float
Obtiene la opacidad actual de la ventana.

#### `setWindowVisible(visible)`
Muestra u oculta la ventana principal.
- **visible**: true para mostrar, false para ocultar

```lua
setWindowVisible(false)
```

### 💬 Ventanas de Mensaje

#### `showMessageBox(message, caption, icon)`
Muestra un cuadro de mensaje de Windows.
- **message**: Texto del mensaje
- **caption**: Título de la ventana
- **icon**: "ERROR", "QUESTION", "WARNING", "INFORMATION"

```lua
showMessageBox("¿Continuar?", "Confirmación", "QUESTION")
```

### 🖼️ Fondo de Pantalla

#### `changeWindowsWallpaper(path)`
Cambia el fondo de pantalla de Windows.
- **path**: Ruta relativa a la imagen

```lua
changeWindowsWallpaper("assets/images/wallpaper.png")
```

#### `saveCurrentWallpaper()`
Guarda el fondo de pantalla actual para restaurarlo después.

#### `restoreOldWallpaper()`
Restaura el fondo de pantalla guardado anteriormente.

### 🔧 Utilidades de Ventana

#### `reDefineMainWindowTitle(title)`
Redefine el título de la ventana principal.
- **title**: Nuevo título

```lua
reDefineMainWindowTitle("Friday Night Funkin' - Custom Title")
```

### 🖥️ Funciones de Consola

#### `allocConsole()`
Crea y muestra una consola de Windows.

#### `clearTerminal()`
Limpia el contenido de la terminal/consola.

#### `hideMainWindow()`
Oculta la ventana principal del juego (útil cuando se usa consola).

#### `setConsoleTitle(title)`
Establece el título de la ventana de consola.

```lua
setConsoleTitle("Debug Console")
```

#### `setConsoleWindowIcon(path)`
Establece el icono de la ventana de consola.

#### `centerConsoleWindow()`
Centra la ventana de consola en la pantalla.

#### `disableResizeConsoleWindow()`
Deshabilita el redimensionamiento de la consola.

#### `disableCloseConsoleWindow()`
Deshabilita el botón de cerrar de la consola.

#### `maximizeConsoleWindow()`
Maximiza la ventana de consola.

#### `getConsoleWindowWidth()` -> Int
Obtiene el ancho de la ventana de consola.

#### `getConsoleWindowHeight()` -> Int
Obtiene el alto de la ventana de consola.

#### `setConsoleCursorPosition(x, y)`
Establece la posición del cursor en la consola.

#### `getConsoleCursorPositionX()` -> Int
Obtiene la posición X del cursor de consola.

#### `getConsoleCursorPositionY()` -> Int
Obtiene la posición Y del cursor de consola.

#### `setConsoleWindowPositionX(posX)`
Establece la posición X de la ventana de consola.

#### `setConsoleWindowPositionY(posY)`
Establece la posición Y de la ventana de consola.

#### `hideConsoleWindow()`
Oculta la ventana de consola.

### 📊 Efectos GDI (Requiere GDI_ENABLED)

Los efectos GDI son efectos visuales de pantalla en tiempo real. Para habilitarlos, asegúrate de tener la versión 1.2.0 de sl-windows-api.

#### `initGDIThread()`
Inicia el hilo de efectos GDI.

#### `stopGDIThread()`
Detiene el hilo de efectos GDI.

#### `pauseGDIThread(pause)`
Pausa o reanuda el hilo de efectos GDI.

#### `isGDIThreadRunning()` -> Bool
Verifica si el hilo GDI está corriendo.

#### `getGDIElapsedTime()` -> Float
Obtiene el tiempo transcurrido del sistema GDI.

#### `prepareGDIEffect(effect, wait)`
Prepara un efecto GDI para usarse.
- **effect**: Nombre del efecto
- **wait**: Tiempo de espera entre actualizaciones (ms)

**Efectos disponibles:**
- `"DrawIcons"` - Dibuja iconos de error/advertencia
- `"ScreenBlink"` - Invierte colores de pantalla
- `"ScreenGlitches"` - Crea glitches visuales
- `"ScreenShake"` - Sacude la pantalla
- `"ScreenTunnel"` - Efecto de túnel/zoom infinito
- `"SetTitleTextToWindows"` - Cambia texto de ventanas

```lua
initGDIThread()
prepareGDIEffect("ScreenGlitches", 0.01)
enableGDIEffect("ScreenGlitches", true)
```

#### `enableGDIEffect(effect, enabled)`
Habilita o deshabilita un efecto GDI.

#### `removeGDIEffect(effect)`
Elimina un efecto GDI del sistema.

#### `setGDIEffectWaitTime(effect, wait)`
Cambia el tiempo de espera de un efecto.

#### `setGDIElapsedTime(elapsed)`
Establece manualmente el tiempo transcurrido del sistema GDI.

## Ejemplos de Uso

### Ejemplo: Animación de Ventana con Efectos
```lua
function onCreate()
    saveCurrentWallpaper()
end

function onStepHit()
    if curStep == 100 then
        winTweenX("moveX", 100, 2, "elasticOut")
        setWindowBorderColor(255, 0, 0)
    end
    
    if curStep == 200 then
        randomizeWindowPosition()
        setWindowOpacity(0.8)
    end
    
    if curStep == 300 then
        changeWindowsWallpaper("assets/images/scary.jpg")
        showNotification("Alert!", "Something changed...")
    end
end

function onDestroy()
    restoreOldWallpaper()
    resetSystemChanges()
end
```

### Ejemplo: Sistema de Debug con Consola
```lua
function onCreate()
    if getPropertyFromClass('backend.ClientPrefs', 'data.debugMode') then
        allocConsole()
        setConsoleTitle("FNF Debug Console")
        centerConsoleWindow()
        disableCloseConsoleWindow()
    end
end
```

### Ejemplo: Efectos GDI Horror
```lua
function onCreate()
    initGDIThread()
end

function onStepHit()
    if curStep == 512 then
        prepareGDIEffect("ScreenGlitches", 0.005)
        enableGDIEffect("ScreenGlitches", true)
    end
    
    if curStep == 768 then
        prepareGDIEffect("ScreenShake", 0)
        enableGDIEffect("ScreenShake", true)
    end
    
    if curStep == 1024 then
        removeGDIEffect("ScreenGlitches")
        removeGDIEffect("ScreenShake")
    end
end

function onDestroy()
    stopGDIThread()
end
```

## Funciones Existentes (Mantenidas)

Todas las funciones anteriores siguen disponibles:
- `winTweenX`, `winTweenY`, `winTweenSize`
- `setWindowX`, `setWindowY`, `setWindowSize`
- `getWindowX`, `getWindowY`, `getWindowWidth`, `getWindowHeight`
- `centerWindow`, `randomizeWindowPosition`
- `setWindowTitle`, `getWindowTitle`, `setWindowIcon`
- `setWindowResizable`, `setWindowFullscreen`, `isWindowFullscreen`
- `saveWindowState`, `loadWindowState`, `getWindowState`
- `setDesktopWallpaper`, `hideDesktopIcons`, `hideTaskBar`
- `moveDesktopElements`, `setDesktopTransparency`, `setTaskBarTransparency`
- `getCursorPosition`, `getSystemRAM`, `showNotification`
- `resetSystemChanges`

## Notas Importantes

1. **Compatibilidad**: Todas las funciones solo funcionan en Windows
2. **GDI Effects**: Requieren la versión 1.2.0 de sl-windows-api con soporte GDI
3. **Seguridad**: Usar `resetSystemChanges()` en `onDestroy()` para restaurar el sistema
4. **Permisos**: Algunas funciones pueden requerir permisos administrativos
