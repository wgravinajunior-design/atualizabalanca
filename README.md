# AtualizaBalança Enterprise - GoUp Sistemas
### Sistema Completo em Delphi 12 para Sincronização Direta com Balanças de Rede (v2.5.0 Enterprise)

O **AtualizaBalança Enterprise** é uma solução desktop de alto desempenho construída em **Delphi 12 Athens** com arquitetura tudo-em-um (monolítico modular), sem dependência de serviços externos ou executáveis separados. O sistema monitora o banco de dados Firebird do ERP (**GoUp Sistemas**), detecta produtos alterados e envia automaticamente para as balanças via rede TCP/IP ou DLLs homologadas, **eliminando totalmente a necessidade de softwares intermediários de fábrica (MGV, Athenas, Smart ou Urano Carga)**.

---

## 🚀 Novidades da Versão v2.5.0 Enterprise

1. **Comparador Visual de Alterações (F7):**
   - Comparativo interativo entre a base de dados do ERP e os dados carregados na balança.
   - Destaque em cores para alterações de preço, validade, descrição e informações nutricionais antes da transmissão.

2. **Visualizador Oficial de Tabela Nutricional (RDC 429 e IN 75 Anvisa):**
   - Apresentação completa dos valores por 100g e por porção com percentual de Valor Diário (%VD).
   - Alerta visual automático para **Rotulagem Nutricional Frontal (Lupas da Anvisa)**:
     - 🔍 **Açúcar Adicionado Alto** (>= 15g/100g)
     - 🔍 **Gordura Saturada Alta** (>= 6g/100g)
     - 🔍 **Sódio Alto** (>= 600mg/100g)

3. **Backup & Restauração de Configurações em 1 Clique:**
   - Exportação e importação de toda a configuração do parque de balanças e conexões em arquivo JSON estruturado.

4. **Sistema de Atualização Automática e Histórico de Novidades (F1):**
   - Verificação nativa via API do GitHub Releases com TLS 1.2 sem depender de navegadores externos.
   - Visualizador embutido com notas de versão da build e download direto.

5. **Apagar / Zerar Memória Remota da Balança:**
   - Comando de higienização de memória enviado direto pela rede para remover produtos descontinuados da memória da balança.

---

## 🛠️ Funcionalidades Enterprise Principais

### Micro-API REST Embutida (Porta 8085)
Servidor HTTP nativo (`UServidorRest.pas`) embutido na aplicação para integração com sistemas web, mobile e outros ERPs:
- `GET /status`: Status de cada balança em tempo real e saúde do serviço.
- `POST /sincronizar`: Disparo imediato de carga de itens alterados.
- `POST /carga-total`: Carga de higienização total de memória.
- `GET /logs`: Auditoria em tempo real das últimas 50 transmissões.

### Alertas Proativos via Telegram Bot
Notificações automáticas para a equipe de suporte e TI quando uma balança fica inacessível na rede, com recuperação automática monitorada.

### Diagnóstico e Validação Prévia de PLUs
Varredura de consistência cadastral: detecção de PLUs duplicados, produtos sem preço e itens sem prazo de validade.

### Agendamento Inteligente Noturno
Cargas incrementais ultrarrápidas durante o expediente e carga completa programada para a madrugada.

---

## 📡 Fabricantes e Protocolos Homologados

| Fabricante | Modelos Homologados | Comunicação Direta | Porta Padrão | Driver Delphi |
| :--- | :--- | :---: | :---: | :--- |
| **Balmak** | Athenas I, II, Orion, Orion Touch, Athena Light | TCP/IP Socket | `5000` | `UProtocoloBalmak.pas` |
| **Toledo** | Prix 4, 4 Uno/Due, 5, 5 Plus, 6, 6 Touch | DLL `P05.dll` / Socket | `6500` | `UProtocoloToledo.pas` |
| **Filizola** | Platina, Platina Plus, CS | TCP/IP Socket | `1000` | `UProtocoloFilizola.pas` |
| **Urano** | Top, TopMax, Integra | TCP/IP Socket | `1001` | `UProtocoloUrano.pas` |
| **Elgin** | Wind, DP-30 | TCP/IP Socket | `5000` | `UProtocoloElgin.pas` |
| **Ramuza** | DCR-CL | TCP/IP Socket | `5000` | `UProtocoloRamuza.pas` |
| **Systel** | Cuora, Croma | TCP/IP Socket | `10001` | `UProtocoloSystel.pas` |

---

## ⌨️ Atalhos Rápidos do Sistema

- **F1:** Sobre & Novidades da Build (Checar Atualizações)
- **F5:** Transmitir Produtos Alterados (Carga Rápida)
- **F6:** Transmitir Carga Total para Todas as Balanças
- **F7:** Abrir Comparador Visual de Alterações
- **F8:** Testar Conexão e Latência de Rede (Ping/ms)
- **F12:** Configurações do Sistema e Parque de Balanças

---

## 💻 Compilação e Deploy

O projeto é compilado com o Embarcadero Delphi 12 (DCC32):
```bash
dcc32.exe -B -W -H -Q -U"<DELPHI_LIB_WIN32_RELEASE>" AtualizaBalanca.dpr
```

Gera o executável standalone `AtualizaBalanca.exe` com consumo de memória inferior a 25MB e inicialização em menos de 1 segundo.