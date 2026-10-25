# AtualizaBalança Enterprise - GoUp Sistemas
### Sistema Completo em Delphi 12 para Sincronização Direta com Balanças de Rede (v1.0.2 Enterprise)

O **AtualizaBalança Enterprise** é uma solução desktop de alto desempenho construída em **Delphi 12 Athens** com arquitetura tudo-em-um (monolítico modular), sem dependência de serviços externos ou executáveis separados. O sistema monitora o banco de dados Firebird do ERP (**GoUp Sistemas**), detecta produtos alterados e envia automaticamente para as balanças via rede TCP/IP ou DLLs homologadas, **eliminando totalmente a necessidade de softwares intermediários de fábrica (MGV, Athenas, Smart ou Urano Carga)**.

---

## 🚀 Histórico Incremental de Versões

### Build v1.0.2 (Atual)
1. **Editor Visual de Etiquetas Térmicas Integrado (F9):**
   - Simulador físico em tempo real (WYSIWYG) com prévia fiel da etiqueta adesiva.
   - Suporte universal para todos os fabricantes: Toledo Prix, Balmak, Filizola, Urano, Elgin, Ramuza e Systel.
   - 6 formatos padrão de mercado (40x40, 60x30, 60x40, 60x60, 60x70 e 60x80 mm).
   - Configuração de cabeçalho da loja, rodapé de conservação, campos impressos e padrão de código de barras EAN-13.
   - Botão para sincronização imediata do layout na memória da balança via rede TCP/IP.
2. **Centralização Global de Versão:**
   - Constantes unificadas de versionamento (`VERSAO_SISTEMA` e `NUMERO_BUILD`) garantindo sincronismo automático em todas as telas e APIs.
3. **Badge de Build Interativo no Topo:**
   - Indicador moderno no topo da aplicação exibindo a versão corrente e atalho F1.

### Build v1.0.1
1. **Sistema de Atualização Automática Nativo (Auto-Updater):**
   - Verificação via API HTTPS do GitHub Releases utilizando WinInet nativo (sem dependência de DLLs OpenSSL).
2. **Central de Novidades Colorida:**
   - Visualizador categorizado por módulo, tipo e impacto prático na loja.

### Build v1.0.0
1. **Comunicação Direta Socket TCP/IP (Sem MGV ou Athenas):** Transmissão de cargas em tempo real.
2. **Comparador Visual de Alterações (F7):** Auditoria prévia de preços e PLUs antes do envio.
3. **Visualizador Oficial de Tabela Nutricional (RDC 429 e IN 75 Anvisa):** Cálculo por 100g e porção com detecção das 3 Lupas Frontais.
4. **Comando de Zeramento Remoto de Memória:** Limpeza remota de produtos via rede.
5. **Módulo de Backup & Restauração 1-Clique:** Exportação e restauração completa de infraestrutura em formato JSON.

---

## 📡 Fabricantes e Protocolos Homologados

| Fabricante | Modelos Homologados | Comunicação Direta | Formato de Etiquetas | Driver Delphi |
| :--- | :--- | :---: | :---: | :--- |
| **Balmak** | Athenas I, II, Orion, Orion Touch, Athena Light | TCP/IP Socket | 30x30 até 60x80 | `UProtocoloBalmak.pas` |
| **Toledo** | Prix 4, 4 Uno/Due, 5, 5 Plus, 6, 6 Touch | DLL `P05.dll` / Socket | 40x40 até 60x80 | `UProtocoloToledo.pas` |
| **Filizola** | Platina, Platina Plus, CS | TCP/IP Socket | Formatos 1 a 8 | `UProtocoloFilizola.pas` |
| **Urano** | Top, TopMax, Integra | TCP/IP Socket | Modelos 1 a 9 | `UProtocoloUrano.pas` |
| **Elgin** | Wind, DP-30 | TCP/IP Socket | 40x40 até 60x60 | `UProtocoloElgin.pas` |
| **Ramuza** | DCR-CL | TCP/IP Socket | 40x40 até 60x60 | `UProtocoloRamuza.pas` |
| **Systel** | Cuora, Croma | TCP/IP Socket | 40x40 até 60x60 | `UProtocoloSystel.pas` |

---

## ⌨️ Atalhos Rápidos do Teclado

- **F1:** Central de Novidades da Build e Verificação de Versão
- **F5:** Sincronizar Produtos Alterados (Carga Rápida Incremental)
- **F6:** Transmitir Carga Total para Todas as Balanças
- **F7:** Abrir Comparador Visual de Alterações de Preço
- **F8:** Testar Conexão e Latência de Rede com as Balanças
- **F9:** Abrir Editor Visual de Etiquetas Térmicas
- **F12:** Configurações do Sistema e Parque de Balanças