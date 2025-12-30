#!/bin/bash

# Script para generar un ícono placeholder usando ImageMagick o sips (macOS)
# Si no tienes ImageMagick instalado, puedes instalarlo con: brew install imagemagick

OUTPUT_DIR="MultiplicationTables/Assets.xcassets/AppIcon.appiconset"
ICON_FILE="$OUTPUT_DIR/AppIcon.png"

echo "🎨 Generando ícono placeholder para Multiplication Masters..."

# Verificar si ImageMagick está instalado
if command -v convert &> /dev/null; then
    echo "✓ Usando ImageMagick"

    # Crear ícono con gradiente y símbolo de multiplicación
    convert -size 1024x1024 \
        gradient:'#FF6B9D-#FFB347' \
        \( -size 800x800 -background none -fill white -font "Helvetica-Bold" \
           -gravity center label:'×' \) \
        -gravity center -composite \
        \( -size 120x120 -background none -fill white -font "Helvetica-Bold" \
           -gravity center label:'⭐' -gravity northeast -geometry +150+150 \) \
        -composite \
        "$ICON_FILE"

    echo "✓ Ícono generado: $ICON_FILE"

elif command -v sips &> /dev/null; then
    echo "✓ Usando sips (macOS nativo)"
    echo "⚠️  sips no puede crear gradientes. Creando ícono simple..."

    # Crear un PNG simple con color sólido
    # Primero creamos un archivo temporal con Python
    python3 << 'EOF'
from PIL import Image, ImageDraw, ImageFont
import os

# Crear imagen con gradiente
img = Image.new('RGB', (1024, 1024))
draw = ImageDraw.Draw(img)

# Gradiente simple (rosa a naranja)
for y in range(1024):
    r = int(255 + (255 - 255) * y / 1024)
    g = int(107 + (179 - 107) * y / 1024)
    b = int(157 + (71 - 157) * y / 1024)
    draw.line([(0, y), (1024, y)], fill=(r, g, b))

# Agregar texto ×
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 600)
except:
    font = ImageFont.load_default()

draw.text((512, 512), '×', fill='white', font=font, anchor='mm')

# Guardar
output_path = 'MultiplicationTables/Assets.xcassets/AppIcon.appiconset/AppIcon.png'
img.save(output_path)
print(f'✓ Ícono generado: {output_path}')
EOF

else
    echo "❌ No se encontró ImageMagick ni Python/PIL"
    echo ""
    echo "Para instalar ImageMagick:"
    echo "  brew install imagemagick"
    echo ""
    echo "O abre icon-design.html en tu navegador y genera el ícono manualmente"
    exit 1
fi

echo ""
echo "✅ ¡Listo! El ícono placeholder ha sido generado."
echo ""
echo "📝 PRÓXIMOS PASOS:"
echo "1. Abre icon-design.html en tu navegador para ver el diseño"
echo "2. Usa IA (DALL-E, Midjourney) para generar un ícono profesional"
echo "3. O usa Figma/Canva siguiendo las instrucciones en icon-design.html"
echo "4. Guarda el ícono final como AppIcon.png y reemplaza el placeholder"
echo ""
