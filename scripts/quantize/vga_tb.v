`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2025 11:37:57
// Design Name: 
// Module Name: vga_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// https://madlittlemods.github.io/vga-simulator/
//////////////////////////////////////////////////////////////////////////////////


// -------------------------------------------------------------------
// Ejemplo de logger VGA en Verilog (equivalente al proceso VHDL)
// -------------------------------------------------------------------
module vga_tb();
    // Signals
    reg clk;
    reg rst;
    wire vsync;
    wire hsync;
    wire [3:0] vgaRed;
    wire [3:0] vgaGreen;
    wire [3:0] vgaBlue;
    
    // Device under test
    top_level dut(
        .clk(clk),
        .btnC(rst),
        .Vsync(vsync),
        .Hsync(hsync),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );

    integer file;
    
    always #5 clk <= ~clk;
    
    // Al final de la simulación, cierra el archivo
    initial begin
        // Abre el archivo para escritura (modo texto)
        file = $fopen("write.txt", "w");
        if (file == 0) begin
            $display("Error: no se pudo abrir el archivo write.txt");
            $finish;
        end
        rst = 0;
        clk = 0;
        #20;
        rst = 1;
        #17000000;
        $fclose(file);
        $display("Archivo cerrado correctamente.");
        $finish;
    end
    
    
    // Este bloque se activa con cada flanco positivo del reloj de píxel
    always @(posedge clk) begin
        // Escribir tiempo simulado (en ns) y señales
        $fwrite(file, "%0t ns: %b %b %04b %04b %04b\n", 
            $time,          // tiempo actual en la simulación
            hsync,          // señal de sincronía horizontal
            vsync,          // señal de sincronía vertical
            vgaRed,            // componente rojo
            vgaGreen,          // componente verde
            vgaBlue            // componente azul
        );
    end
endmodule

