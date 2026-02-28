import 'package:flutter/material.dart';

class ImpresionesPage extends StatelessWidget {
  const ImpresionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controlador para que la barra amarilla mueva todo el contenido vertical
    final ScrollController _scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ÁREA PRINCIPAL DE CONTENIDO
          Expanded(
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: Color(0xFFF1C40F), // Amarillo El Principito
              thickness: 12,
              radius: Radius.circular(10),
              thumbVisibility: true, // Siempre visible como en tu diseño
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección del Visor de Documento (Hero)
                    _buildDocumentPreviewHeader(),

                    SizedBox(height: 25),

                    // Título de Páginas
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Páginas",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6B91),
                        ),
                      ),
                    ),

                    // Grid de miniaturas de páginas
                    _buildPagesGrid(),

                    SizedBox(height: 40),
                    _buildSimpleFooter(),
                  ],
                ),
              ),
            ),
          ),

          // Margen estético derecho para la scrollbar lateral
          Container(
            width: 5,
            color: Color(0xFFD6EAF8).withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  // --- Header con Visor y Botones Responsivos ---
  Widget _buildDocumentPreviewHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Wrap(
        spacing: 30,
        runSpacing: 25,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          // Miniatura del documento (Lado izquierdo)
          Container(
            width: 150,
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child:  Center(
                child: Text(
                    "1",
                    style: TextStyle(color: Color(0xFF1A4661), fontSize: 30, fontWeight: FontWeight.bold)
                )
            ),
          ),

          // Información y bloque de botones (Lado derecho)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Documento",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                 Text("20 de Febrero de 2026", style: TextStyle(color: Colors.white70)),
                 SizedBox(height: 15),
                 Text("ubicacion/documento/destino.pdf", style: TextStyle(color: Colors.white, fontSize: 14)),
                 SizedBox(height: 15),
                 Text(
                  "Descripción del documento lorem ipsun derump pardasin para impresión profesional.",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                 SizedBox(height: 30),

                // CONTENEDOR DE BOTONES
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón Principal: Imprimir
                    SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF1C40F),
                          foregroundColor: Color(0xFF1A4661),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 3,
                        ),
                        child: Text("Imprimir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Botones secundarios (Wrap evita el desbordamiento en móvil)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.upload, size: 18),
                          label: Text("Subir Archivo", style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white, width: 1.5),
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2A6B91),
                            foregroundColor: Colors.white,
                            padding:  EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            elevation: 0,
                          ),
                          child: Text("Opciones", style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Cuadrícula de Páginas ---
  Widget _buildPagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // El scroll lo maneja el padre
      padding: EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columnas como en tu diseño
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(12),
        child: Text(
            "${index + 1}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A6B91), fontSize: 16)
        ),
      ),
    );
  }

  // --- Pie de página azul marino ---
  Widget _buildSimpleFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0.5),
      ),
    );
  }
}