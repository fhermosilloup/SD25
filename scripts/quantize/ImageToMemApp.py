import tkinter as tk
from tkinter import filedialog, messagebox
import cv2
import numpy as np
import os

class ImageToMemApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Imagen to .mem (RGB444)")
        self.root.geometry("600x250")
        self.root.resizable(False, False)

        # Variables
        self.input_path = tk.StringVar()
        self.output_path = tk.StringVar()
        self.width_var = tk.StringVar(value="320")
        self.height_var = tk.StringVar(value="240")
        self.orig_width = tk.StringVar()
        self.orig_height = tk.StringVar()

        # --- Layout ---
        tk.Label(root, text="Image file:").grid(row=0, column=0, sticky="e", padx=5, pady=5)
        tk.Entry(root, textvariable=self.input_path, width=45, state="readonly").grid(row=0, column=1, padx=5)
        tk.Button(root, text="Choose", command=self.select_image).grid(row=0, column=2, padx=5)

        tk.Label(root, text=".mem file:").grid(row=1, column=0, sticky="e", padx=5, pady=5)
        self.output_entry = tk.Entry(root, textvariable=self.output_path, width=45, state="readonly")
        self.output_entry.grid(row=1, column=1, padx=5)
        self.output_button = tk.Button(root, text="Save as", command=self.select_output, state="disabled")
        self.output_button.grid(row=1, column=2, padx=5)

        # Dimensiones originales
        tk.Label(root, text="Input Size:").grid(row=2, column=0, sticky="e", padx=5, pady=5)
        frame_in = tk.Frame(root)
        frame_in.grid(row=2, column=1, sticky="w")
        tk.Entry(frame_in, textvariable=self.orig_width, width=8, state="disabled").pack(side="left")
        tk.Label(frame_in, text="x").pack(side="left", padx=2)
        tk.Entry(frame_in, textvariable=self.orig_height, width=8, state="disabled").pack(side="left")

        # Dimensiones de salida
        tk.Label(root, text="Output Size:").grid(row=3, column=0, sticky="e", padx=5, pady=5)
        frame_out = tk.Frame(root)
        frame_out.grid(row=3, column=1, sticky="w")
        vcmd = (root.register(self.validate_size), "%P")
        tk.Entry(frame_out, textvariable=self.width_var, width=8, validate="key", validatecommand=vcmd).pack(side="left")
        tk.Label(frame_out, text="x").pack(side="left", padx=2)
        tk.Entry(frame_out, textvariable=self.height_var, width=8, validate="key", validatecommand=vcmd).pack(side="left")

        # Botón de conversión
        tk.Button(root, text="Generate", bg="#4CAF50", fg="white",
                  command=self.generate_mem, width=25).grid(row=5, column=1, pady=25)

    # --- Funciones ---
    def validate_size(self, value):
        """Valida que solo se ingresen números >= 8."""
        if value == "":
            return True
        try:
            n = int(value)
            return n >= 8
        except ValueError:
            return False

    def select_image(self):
        path = filedialog.askopenfilename(
            title="Choose image",
            filetypes=[("Images", "*.jpg *.png *.jpeg *.bmp *.tiff")]
        )
        if not path:
            return
        self.input_path.set(path)

        img = cv2.imread(path)
        if img is not None:
            h, w = img.shape[:2]
            self.orig_width.set(str(w))
            self.orig_height.set(str(h))

            # Habilitar campo y botón de salida
            self.output_button.config(state="normal")

            # Generar nombre por defecto
            base, _ = os.path.splitext(path)
            default_out = base + ".mem"
            self.output_path.set(default_out)

        else:
            messagebox.showerror("Error", "Image cannot be opened.")

    def select_output(self):
        path = filedialog.asksaveasfilename(
            title="Save .mem file as",
            defaultextension=".mem",
            filetypes=[("Memory File", "*.mem"), ("All files", "*.*")]
        )
        if path:
            self.output_path.set(path)
        # Si cancela, no hace nada (mantiene la ruta por defecto)

    def generate_mem(self):
        in_path = self.input_path.get()
        out_path = self.output_path.get()

        if not in_path:
            messagebox.showerror("Error", "Debe seleccionar una imagen de entrada.")
            return

        if not out_path:
            base, _ = os.path.splitext(in_path)
            out_path = base + ".mem"
            self.output_path.set(out_path)

        # Leer y procesar
        img = cv2.imread(in_path)
        if img is None:
            messagebox.showerror("Error", "No se pudo abrir la imagen de entrada.")
            return

        try:
            WIDTH = int(self.width_var.get())
            HEIGHT = int(self.height_var.get())
        except ValueError:
            messagebox.showerror("Error", "Invalid output image size.")
            return

        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_resized = cv2.resize(img_rgb, (WIDTH, HEIGHT), interpolation=cv2.INTER_NEAREST)
        img_4bit = img_resized >> 4

        # Guardar archivo .mem
        with open(out_path, 'w') as f:
            for row in img_4bit:
                for pixel in row:
                    r, g, b = pixel.astype(np.uint16)
                    rgb_12bit = (r << 8) | (g << 4) | b
                    f.write(f"{rgb_12bit:03X}\n")

        messagebox.showinfo("Success", f"Memory file was successfully generated:\n{out_path}")


if __name__ == "__main__":
    root = tk.Tk()
    app = ImageToMemApp(root)
    root.mainloop()
