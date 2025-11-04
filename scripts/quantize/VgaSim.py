import tkinter as tk
from tkinter import filedialog, messagebox
from tkinter import ttk
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg


class VGASimulatorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Simulador VGA - Log Analyzer")

        # Variables principales
        self.pixel_period = tk.IntVar(value=40)
        self.res_x = tk.IntVar(value=640)
        self.res_y = tk.IntVar(value=480)
        self.h_fp = tk.IntVar(value=16)
        self.h_sync = tk.IntVar(value=96)
        self.h_bp = tk.IntVar(value=48)
        self.v_fp = tk.IntVar(value=10)
        self.v_sync = tk.IntVar(value=2)
        self.v_bp = tk.IntVar(value=33)
        self.h_polarity = tk.StringVar(value="Activa en Bajo")
        self.v_polarity = tk.StringVar(value="Activa en Bajo")

        self.lines = None
        self.frames = []
        self.current_frame = 0

        self.setup_gui()

    def setup_gui(self):
        frame_params = ttk.LabelFrame(self.root, text="Parámetros VGA")
        frame_params.grid(row=0, column=0, padx=10, pady=5, sticky="ew")

        # --- Fila 1: Pixel clock + resolución ---
        ttk.Label(frame_params, text="Periodo Pixel (ns):").grid(row=0, column=0, padx=5, sticky="w")
        ttk.Entry(frame_params, textvariable=self.pixel_period, width=8).grid(row=0, column=1, padx=5)

        ttk.Label(frame_params, text="Resolución:").grid(row=0, column=2, padx=5, sticky="w")
        ttk.Entry(frame_params, textvariable=self.res_x, width=6).grid(row=0, column=3, padx=(0, 2))
        ttk.Label(frame_params, text="x").grid(row=0, column=4)
        ttk.Entry(frame_params, textvariable=self.res_y, width=6).grid(row=0, column=5, padx=(2, 5))

        # --- Fila 2: HSYNC timings ---
        ttk.Label(frame_params, text="HSYNC Front:").grid(row=1, column=0, padx=5, sticky="w")
        ttk.Entry(frame_params, textvariable=self.h_fp, width=6).grid(row=1, column=1)
        ttk.Label(frame_params, text="Pulse:").grid(row=1, column=2, sticky="w")
        ttk.Entry(frame_params, textvariable=self.h_sync, width=6).grid(row=1, column=3)
        ttk.Label(frame_params, text="Back:").grid(row=1, column=4, sticky="w")
        ttk.Entry(frame_params, textvariable=self.h_bp, width=6).grid(row=1, column=5)
        tk.Label(frame_params, text="Polaridad HSYNC:").grid(row=1, column=4)
        tk.OptionMenu(frame_params, self.h_polarity, "Activa en Bajo", "Activa en Alto").grid(row=1, column=5)
        
        # --- Fila 3: VSYNC timings ---
        ttk.Label(frame_params, text="VSYNC Front:").grid(row=2, column=0, padx=5, sticky="w")
        ttk.Entry(frame_params, textvariable=self.v_fp, width=6).grid(row=2, column=1)
        ttk.Label(frame_params, text="Pulse:").grid(row=2, column=2, sticky="w")
        ttk.Entry(frame_params, textvariable=self.v_sync, width=6).grid(row=2, column=3)
        ttk.Label(frame_params, text="Back:").grid(row=2, column=4, sticky="w")
        ttk.Entry(frame_params, textvariable=self.v_bp, width=6).grid(row=2, column=5)
        tk.Label(frame_params, text="Polaridad VSYNC:").grid(row=2, column=4)
        tk.OptionMenu(frame_params, self.v_polarity, "Activa en Bajo", "Activa en Alto").grid(row=2, column=5)
        
        # --- Botones principales ---
        frame_buttons = ttk.Frame(self.root)
        frame_buttons.grid(row=1, column=0, pady=10)

        self.btn_load = ttk.Button(frame_buttons, text="Cargar Archivo", command=self.load_file)
        self.btn_load.grid(row=0, column=0, padx=5)

        self.btn_start = ttk.Button(frame_buttons, text="Iniciar Simulación", command=self.start_simulation, state=tk.DISABLED)
        self.btn_start.grid(row=0, column=1, padx=5)

        # --- Área de imagen ---
        self.fig, self.ax = plt.subplots(figsize=(6, 4))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.root)
        self.canvas.get_tk_widget().grid(row=2, column=0, padx=10, pady=5)

        # --- Controles de frame ---
        frame_nav = ttk.Frame(self.root)
        frame_nav.grid(row=3, column=0, pady=10)

        self.btn_prev = ttk.Button(frame_nav, text="⏪", command=self.prev_frame, state=tk.DISABLED)
        self.btn_prev.grid(row=0, column=0, padx=5)

        self.btn_next = ttk.Button(frame_nav, text="⏩", command=self.next_frame, state=tk.DISABLED)
        self.btn_next.grid(row=0, column=1, padx=5)

        self.lbl_frame = ttk.Label(frame_nav, text="Frame 0 / 0")
        self.lbl_frame.grid(row=0, column=2, padx=5)
        
        # --- Permitir que la ventana y el gráfico se expandan ---
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(2, weight=1)  # Donde está el canvas de la imagen

        frame_params.columnconfigure(tuple(range(6)), weight=1)
        frame_buttons.columnconfigure(tuple(range(2)), weight=1)
        frame_nav.columnconfigure(tuple(range(3)), weight=1)

        # Hacer que el gráfico se expanda con la ventana
        self.canvas.get_tk_widget().grid(row=2, column=0, padx=10, pady=5, sticky="nsew")

    def load_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if not file_path:
            return

        try:
            with open(file_path, "r") as f:
                self.lines = f.readlines()
            messagebox.showinfo("Archivo cargado", f"Se cargaron {len(self.lines)} líneas.")
            self.btn_start.config(state=tk.NORMAL)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo leer el archivo:\n{e}")

    def start_simulation(self):
        if not self.lines:
            messagebox.showwarning("Advertencia", "Primero carga un archivo de simulación.")
            return

        # --- Parámetros VGA ---
        width = self.res_x.get()
        height = self.res_y.get()
        h_fp, h_sync, h_bp = self.h_fp.get(), self.h_sync.get(), self.h_bp.get()
        v_fp, v_sync, v_bp = self.v_fp.get(), self.v_sync.get(), self.v_bp.get()
        total_x = width + h_fp + h_sync + h_bp
        total_y = height + v_fp + v_sync + v_bp

        # Polaridades
        h_active_low = (self.h_polarity.get() == "Activa en Bajo")
        v_active_low = (self.v_polarity.get() == "Activa en Bajo")

        # Periodo del pixel en ns
        pixel_period_ns = self.pixel_period.get()

        # Buffers
        frames = []
        current_frame = np.zeros((height, width, 3), dtype=np.uint8)
        x = 0
        y = 0
        last_pixel_time = None
        vsync_prev = None
        hsync_prev = None
        frame_started = False
        # Variables auxiliares para sincronía
        hsync_pulse_start = False
        hsync_pulse_end = False
        vsync_pulse_start = False
        vsync_pulse_end = False
        num_frame = 1
        # --- Procesamiento línea por línea ---
        for line in self.lines:
            parts = line.strip().split(',')
            if len(parts) < 6:
                continue

            # Ignorar líneas con 'x'
            if any('x' in p.lower() for p in parts):
                continue

            try:
                time_ns = float(parts[0])
                hsync = int(parts[1])
                vsync = int(parts[2])
                # Leer valores de los canales como cadenas
                r_str = parts[3].strip()
                g_str = parts[4].strip()
                b_str = parts[5].strip()
                
                # Cantidad de bits por canal
                r_bits = len(r_str)
                g_bits = len(g_str)
                b_bits = len(b_str)

                # Convertir a entero
                r_val = int(r_str, 2)
                g_val = int(g_str, 2)
                b_val = int(b_str, 2)

                # Cuantización a 8 bits
                r = r_val << (8 - r_bits) if r_bits < 8 else r_val & 0xFF
                g = g_val << (8 - g_bits) if g_bits < 8 else g_val & 0xFF
                b = b_val << (8 - b_bits) if b_bits < 8 else b_val & 0xFF
            except ValueError:
                continue

            # Saltar si no ha pasado el tiempo de un pixel
            if last_pixel_time is not None:
                if (time_ns - last_pixel_time) < pixel_period_ns:
                    continue
            last_pixel_time = time_ns

            # --- Detectar HSYNC ---
            if hsync_prev is not None:
                if h_active_low:
                    # Detectar flancos ~HSYNC_POL -> HSYNC_POL y HSYNC_POL -> ~HSYNC_POL
                    if hsync_prev == 1 and hsync == 0:
                        hsync_pulse_start = True
                        # print(f"HSyncPulse begin for row {y}")
                    if hsync_pulse_start and hsync_prev == 0 and hsync == 1:
                        hsync_pulse_end = True
                        # print(f"HSyncPulse end for row {y}")

                else:
                    if hsync_prev == 0 and hsync == 1:
                        hsync_pulse_start = True
                        # print(f"HSyncPulse begin for row {y}")
                    if hsync_pulse_start and hsync_prev == 1 and hsync == 0:
                        hsync_pulse_end = True
                        # print(f"HSyncPulse end for row {y}")

            # --- Detectar VSYNC ---
            if vsync_prev is not None:
                if v_active_low:
                    if vsync_prev == 1 and vsync == 0:
                        vsync_pulse_start = True
                        print(f"VSyncPulse begin for frame {num_frame}")
                    if vsync_pulse_start and vsync_prev == 0 and vsync == 1:
                        vsync_pulse_end = True
                        print(f"VSyncPulse end for row {num_frame}")
                else:
                    if vsync_prev == 0 and vsync == 1:
                        vsync_pulse_start = True
                        print(f"VSyncPulse begin for frame {num_frame}")
                    if vsync_pulse_start and vsync_prev == 1 and vsync == 0:
                        vsync_pulse_end = True
                        print(f"VSyncPulse end for row {num_frame}")
            
            # Dibujar solo en área visible
            if 0 <= y < height and 0 <= x < width:
                current_frame[y, x, :] = [r, g, b]
                #if r_val != 15:
                    #print(f"Invalid Pixel P({y},{x})=[{r},{g},{b}] at {last_pixel_time} ns")
            
            # Incrementar a x
            x+=1
            
            # Actualizar vsync y hsync
            vsync_prev = vsync
            hsync_prev = hsync
            
            
            # Incrementar X solo si se completó el pulso y estamos al final de la línea
            if x == total_x:
                x = 0
                if hsync_pulse_start and hsync_pulse_end:
                    # print(f"A row has been completed at {last_pixel_time} ns")
                    y += 1
                hsync_pulse_start = False
                hsync_pulse_end = False
                    
                    
            # Reiniciar frame solo si se completó el pulso y estamos al final del frame
            if y == total_y:
                y = 0
                if vsync_pulse_start and vsync_pulse_end:
                    print(f"A frame has been completed at {last_pixel_time} ns")
                    frames.append(current_frame.copy())
                    current_frame = np.zeros((height, width, 3), dtype=np.uint8)
                    frame_started = True
                vsync_pulse_start = False
                vsync_pulse_end = False
                
        # Agregar el último frame
        if frame_started and y > 0:
            frames.append(current_frame.copy())

        if not frames:
            messagebox.showerror("Error", "No se detectaron frames válidos en el archivo.")
            return

        # Guardar frames y mostrar el primero
        self.frames = frames
        self.current_frame = 0
        self.show_frame()

        # Habilitar navegación
        self.btn_prev.config(state="normal")
        self.btn_next.config(state="normal")
        messagebox.showinfo("Simulación completa", f"Se generaron {len(frames)} frames.")

    def show_frame(self):
        if not self.frames:
            return
        self.ax.clear()
        self.ax.imshow(self.frames[self.current_frame])
        self.ax.axis("off")
        self.canvas.draw()
        self.lbl_frame.config(text=f"Frame {self.current_frame + 1} / {len(self.frames)}")
        self.update_nav_buttons()

    def update_nav_buttons(self):
        """Habilita o deshabilita los botones de navegación según el estado actual."""
        if not self.frames:
            self.btn_prev.config(state=tk.DISABLED)
            self.btn_next.config(state=tk.DISABLED)
            return

        self.btn_prev.config(state=tk.NORMAL if self.current_frame > 0 else tk.DISABLED)
        self.btn_next.config(state=tk.NORMAL if self.current_frame < len(self.frames) - 1 else tk.DISABLED)

    def next_frame(self):
        if self.current_frame < len(self.frames) - 1:
            self.current_frame += 1
            self.show_frame()

    def prev_frame(self):
        if self.current_frame > 0:
            self.current_frame -= 1
            self.show_frame()


if __name__ == "__main__":
    root = tk.Tk()
    app = VGASimulatorGUI(root)
    root.mainloop()
