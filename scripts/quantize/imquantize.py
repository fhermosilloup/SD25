import cv2
import numpy as np

# --- CONFIGURACIÓN ---
IN_IMG = 'img2.jpg'
OUT_FILE = 'mem.bin'
WIDTH, HEIGHT = 320, 240
BITS_PER_CHANNEL = 4  # 4 bits → 16 niveles

# --- 1. Cargar y reescalar la imagen ---
img = cv2.imread(IN_IMG)
if img is None:
    raise FileNotFoundError(f"No se encontró la imagen: {IN_IMG}")

img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
img_resized = cv2.resize(img_rgb, (WIDTH, HEIGHT), interpolation=cv2.INTER_NEAREST)
img2 = cv2.cvtColor(img_resized, cv2.COLOR_RGB2BGR)

cv2.imshow("Original", img)
cv2.imshow("Resized", img2)
cv2.waitKey()



# --- 2. Cuantificación a 4 bits por canal ---
img_4bit = img_resized >> 4
print("img[0,0]=",img_rgb[0,0])
print("imgresize[0,0]=",img_resized[0,0])
print("imquant[0,0]=",img_4bit[0,0])

# --- 3. Convertir cada pixel a una palabra de 12 bits (RGB) ---
with open(OUT_FILE, 'w') as f:
    for row in img_4bit:
        for pixel in row:
            r, g, b = pixel
            r=np.uint16(r)
            g=np.uint16(g)
            b=np.uint16(b)
            rgb_12bit = np.uint16(0)  # inicializada en 0
            # Empaquetar los tres canales en un solo número de 12 bits
            rgb_12bit = (r*256) + (g*16) + b
            f.write(f"{rgb_12bit:03X}\n")  # 3 dígitos hex (000–FFF)

print(f"Archivo '{OUT_FILE}' generado con {WIDTH*HEIGHT} palabras de 12 bits.")
