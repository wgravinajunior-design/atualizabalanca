object FrmConfig: TFrmConfig
  Left = 0
  Top = 0
  Caption = 'Configura'#231#245'es Enterprise de Integra'#231#227'o de Balan'#231'as'
  ClientHeight = 560
  ClientWidth = 740
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 740
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = 5384214
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 14
      Width = 345
      Height = 21
      Caption = 'Configura'#231#245'es do Sistema AtualizaBalan'#231'a'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 515
    Width = 740
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnSalvarGeral: TButton
      Left = 525
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Salvar Tudo'
      Default = True
      TabOrder = 0
      OnClick = btnSalvarGeralClick
    end
    object btnFechar: TButton
      Left = 635
      Top = 8
      Width = 90
      Height = 30
      Cancel = True
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 50
    Width = 740
    Height = 465
    ActivePage = TabBanco
    Align = alClient
    TabOrder = 2
    object TabBanco: TTabSheet
      Caption = '1. Banco de Dados'
      object grpBanco: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 360
        Caption = ' Par'#226'metros de Conex'#227'o Firebird '
        TabOrder = 0
        object lblHost: TLabel
          Left = 24
          Top = 32
          Width = 101
          Height = 15
          Caption = 'Servidor / Host (IP):'
        end
        object lblPorta: TLabel
          Left = 24
          Top = 88
          Width = 31
          Height = 15
          Caption = 'Porta:'
        end
        object lblBanco: TLabel
          Left = 24
          Top = 144
          Width = 127
          Height = 15
          Caption = 'Caminho do Banco .FDB:'
        end
        object lblUsuario: TLabel
          Left = 24
          Top = 200
          Width = 43
          Height = 15
          Caption = 'Usu'#225'rio:'
        end
        object lblSenha: TLabel
          Left = 240
          Top = 200
          Width = 35
          Height = 15
          Caption = 'Senha:'
        end
        object edtHost: TEdit
          Left = 24
          Top = 52
          Width = 280
          Height = 23
          TabOrder = 0
          Text = 'localhost'
        end
        object edtPorta: TEdit
          Left = 24
          Top = 108
          Width = 100
          Height = 23
          TabOrder = 1
          Text = '3050'
        end
        object edtBanco: TEdit
          Left = 24
          Top = 164
          Width = 575
          Height = 23
          TabOrder = 2
          Text = 'C:\GoUpSistemas\Dados\DADOS.FDB'
        end
        object btnBuscarBanco: TButton
          Left = 605
          Top = 163
          Width = 59
          Height = 25
          Caption = 'Buscar...'
          TabOrder = 3
          OnClick = btnBuscarBancoClick
        end
        object edtUsuario: TEdit
          Left = 24
          Top = 220
          Width = 180
          Height = 23
          TabOrder = 4
          Text = 'SYSDBA'
        end
        object edtSenha: TEdit
          Left = 240
          Top = 220
          Width = 180
          Height = 23
          PasswordChar = '*'
          TabOrder = 5
          Text = 'masterkey'
        end
        object btnTestarConexao: TButton
          Left = 24
          Top = 280
          Width = 160
          Height = 32
          Caption = 'Testar Conex'#245'es'
          TabOrder = 6
          OnClick = btnTestarConexaoClick
        end
      end
    end
    object TabBalancas: TTabSheet
      Caption = '2. Balan'#231'as da Rede'
      ImageIndex = 1
      object pnlBalancasLista: TPanel
        Left = 0
        Top = 0
        Width = 732
        Height = 190
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lvBalancas: TListView
          Left = 0
          Top = 0
          Width = 732
          Height = 145
          Align = alClient
          Columns = <
            item
              Caption = 'ID'
              Width = 40
            end
            item
              Caption = 'Nome da Balan'#231'a'
              Width = 160
            end
            item
              Caption = 'Fabricante'
              Width = 90
            end
            item
              Caption = 'Modelo'
              Width = 130
            end
            item
              Caption = 'IP'
              Width = 110
            end
            item
              Caption = 'Porta'
              Width = 55
            end
            item
              Caption = 'Setor'
              Width = 50
            end
            item
              Caption = 'Ativa'
              Width = 50
            end>
          GridLines = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnSelectItem = lvBalancasSelectItem
        end
        object pnlBalancaAcoes: TPanel
          Left = 0
          Top = 145
          Width = 732
          Height = 45
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          object btnNovaBalanca: TButton
            Left = 8
            Top = 8
            Width = 110
            Height = 28
            Caption = '+ Nova Balan'#231'a'
            TabOrder = 0
            OnClick = btnNovaBalancaClick
          end
          object btnExcluirBalanca: TButton
            Left = 128
            Top = 8
            Width = 90
            Height = 28
            Caption = 'Excluir'
            TabOrder = 1
            OnClick = btnExcluirBalancaClick
          end
          object btnTestarBalanca: TButton
            Left = 228
            Top = 8
            Width = 130
            Height = 28
            Caption = 'Testar Conex'#227'o'
            TabOrder = 2
            OnClick = btnTestarBalancaClick
          end
        end
      end
      object grpEdicaoBalanca: TGroupBox
        Left = 0
        Top = 190
        Width = 732
        Height = 245
        Align = alClient
        Caption = ' Dados da Balan'#231'a '
        TabOrder = 1
        object lblNomeBal: TLabel
          Left = 16
          Top = 24
          Width = 97
          Height = 15
          Caption = 'Nome / Identifica'#231#227'o:'
        end
        object lblFabBal: TLabel
          Left = 260
          Top = 24
          Width = 58
          Height = 15
          Caption = 'Fabricante:'
        end
        object lblModBal: TLabel
          Left = 440
          Top = 24
          Width = 44
          Height = 15
          Caption = 'Modelo:'
        end
        object lblIPBal: TLabel
          Left = 16
          Top = 80
          Width = 72
          Height = 15
          Caption = 'Endere'#231'o IP:'
        end
        object lblPortaBal: TLabel
          Left = 180
          Top = 80
          Width = 31
          Height = 15
          Caption = 'Porta:'
        end
        object lblSetorBal: TLabel
          Left = 270
          Top = 80
          Width = 100
          Height = 15
          Caption = 'Setor (0 = Todos):'
        end
        object lblCaminhoDLL: TLabel
          Left = 16
          Top = 135
          Width = 320
          Height = 15
          Caption = 'Pasta de Integra'#231#227'o / Caminho DLL Toledo (Opcional):'
        end
        object edtNomeBal: TEdit
          Left = 16
          Top = 44
          Width = 225
          Height = 23
          TabOrder = 0
        end
        object cbFabricante: TComboBox
          Left = 260
          Top = 44
          Width = 160
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 1
          Text = 'Balmak'
          OnChange = cbFabricanteChange
          Items.Strings = (
            'Balmak'
            'Filizola'
            'Toledo'
            'Urano'
            'Elgin'
            'Ramuza'
            'Systel')
        end
        object cbModelo: TComboBox
          Left = 440
          Top = 44
          Width = 180
          Height = 23
          Style = csDropDownList
          TabOrder = 2
        end
        object edtIPBal: TEdit
          Left = 16
          Top = 100
          Width = 145
          Height = 23
          TabOrder = 3
        end
        object edtPortaBal: TEdit
          Left = 180
          Top = 100
          Width = 70
          Height = 23
          TabOrder = 4
        end
        object edtSetorBal: TEdit
          Left = 270
          Top = 100
          Width = 80
          Height = 23
          TabOrder = 5
          Text = '0'
        end
        object chkBalAtiva: TCheckBox
          Left = 380
          Top = 102
          Width = 120
          Height = 17
          Caption = 'Balan'#231'a Ativa'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object edtCaminhoDLL: TEdit
          Left = 16
          Top = 155
          Width = 604
          Height = 23
          TabOrder = 7
        end
        object btnGravarBalanca: TButton
          Left = 16
          Top = 195
          Width = 120
          Height = 30
          Caption = 'Salvar Balan'#231'a'
          TabOrder = 8
          OnClick = btnGravarBalancaClick
        end
        object btnCancelarEdicao: TButton
          Left = 150
          Top = 195
          Width = 90
          Height = 30
          Caption = 'Cancelar'
          TabOrder = 9
          OnClick = btnCancelarEdicaoClick
        end
      end
    end
    object TabAgendamento: TTabSheet
      Caption = '3. Sincroniza'#231#227'o & Hor'#225'rios'
      ImageIndex = 2
      object grpSyncContinuo: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 145
        Caption = ' 1. Sincroniza'#231#227'o Cont'#237'nua em Tempo Real '
        TabOrder = 0
        object lblIntervalo: TLabel
          Left = 24
          Top = 28
          Width = 210
          Height = 15
          Caption = 'Intervalo de Verifica'#231#227'o Autom'#225'tica:'
        end
        object lblSegundos: TLabel
          Left = 135
          Top = 51
          Width = 53
          Height = 15
          Caption = 'segundos'
        end
        object edtIntervalo: TEdit
          Left = 24
          Top = 48
          Width = 100
          Height = 23
          TabOrder = 0
          Text = '15'
        end
        object chkModoFila: TCheckBox
          Left = 24
          Top = 95
          Width = 500
          Height = 17
          Caption = 'Sincroniza'#231#227'o Autom'#225'tica Incremental por Data de Altera'#231#227'o'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
      end
      object grpAgendamento: TGroupBox
        Left = 16
        Top = 175
        Width = 700
        Height = 205
        Caption = ' 2. Carga Total Noturna Agendada (Higieniza'#231#227'o Di'#225'ria) '
        TabOrder = 1
        object lblHorarioCarga: TLabel
          Left = 24
          Top = 58
          Width = 150
          Height = 15
          Caption = 'Hor'#225'rio Programado da Carga (HH:MM):'
        end
        object lblAgendamentoInfo: TLabel
          Left = 24
          Top = 112
          Width = 620
          Height = 80
          Caption = 
            'A transmiss'#227'o em tempo real sincroniza instantaneamente apenas os produtos alterados (1 a 5 itens) para n'#227'o travar a balan'#231'a em hor'#225'rio de atendimento.'#13#10#13#10 +
            'Com o agendamento noturno ativo, o AtualizaBalan'#231'a envia a carga completa (higieniza'#231#227'o total de mem'#243'ria) no hor'#225'rio definido (ex: 23:00 ou 06:00), garantindo 100% de paridade entre o banco e as balan'#231'as.'
          WordWrap = True
        end
        object chkAgendamentoAtivo: TCheckBox
          Left = 24
          Top = 28
          Width = 400
          Height = 17
          Caption = 'Habilitar Carga Total de Higieniza'#231#227'o Noturna Di'#225'ria'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object edtHorarioCarga: TEdit
          Left = 24
          Top = 78
          Width = 100
          Height = 23
          TabOrder = 1
          Text = '23:00'
        end
      end
    end
    object TabSistema: TTabSheet
      Caption = '4. Sistema & Inicializa'#231#227'o'
      ImageIndex = 3
      object grpSistema: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 360
        Caption = ' Comportamento e Inicializa'#231#227'o do Aplicativo no Windows '
        TabOrder = 0
        object chkIniciarWindows: TCheckBox
          Left = 24
          Top = 35
          Width = 450
          Height = 17
          Caption = 'Iniciar Automaticamente com o Windows (Em Segundo Plano)'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object chkMinimizarBandeja: TCheckBox
          Left = 24
          Top = 75
          Width = 400
          Height = 17
          Caption = 'Minimizar para a Bandeja do Sistema (System Tray)'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object grpBackup: TGroupBox
          Left = 24
          Top = 120
          Width = 650
          Height = 180
          Caption = ' C'#243'pia de Seguran'#231'a (Backup & Restaura'#231#227'o de Configura'#231#245'es) '
          TabOrder = 2
          object lblBackupInfo: TLabel
            Left = 20
            Top = 30
            Width = 600
            Height = 35
            AutoSize = False
            Caption = 
              'Exporte todas as balan'#231'as cadastradas, IPs, portas, setores e par' +
              #226'metros de conex'#227'o em um '#250'nico arquivo de backup, ou restaure em' +
              ' caso de troca de computador.'
            WordWrap = True
          end
          object btnExportarBackup: TButton
            Left = 20
            Top = 85
            Width = 230
            Height = 35
            Caption = 'Criar Arquivo de Backup...'
            TabOrder = 0
            OnClick = btnExportarBackupClick
          end
          object btnRestaurarBackup: TButton
            Left = 270
            Top = 85
            Width = 230
            Height = 35
            Caption = 'Restaurar Configura'#231#245'es...'
            TabOrder = 1
            OnClick = btnRestaurarBackupClick
          end
        end
      end
    end
    object TabNotificacoes: TTabSheet
      Caption = '5. Alertas no Telegram'
      ImageIndex = 4
      object grpTelegram: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 360
        Caption = ' Configura'#231#227'o de Alertas de Balan'#231'a Offline no Telegram '
        TabOrder = 0
        object lblTelegramToken: TLabel
          Left = 24
          Top = 75
          Width = 116
          Height = 15
          Caption = 'Token do Bot Telegram:'
        end
        object lblTelegramChatID: TLabel
          Left = 24
          Top = 140
          Width = 129
          Height = 15
          Caption = 'Chat ID (Usu'#225'rio/Grupo):'
        end
        object lblTelegramInfo: TLabel
          Left = 24
          Top = 210
          Width = 620
          Height = 45
          Caption = 
            'O AtualizaBalan'#231'a dispara alertas autom'#225'ticos e instant'#226'neos para o seu Telegram quando qualquer balan'#231'a da loja ficar offline ou inacess'#237'vel por 3 tentativas consecutivas, e avisa assim que ela se reconectar.'
          WordWrap = True
        end
        object chkTelegramAtivo: TCheckBox
          Left = 24
          Top = 35
          Width = 350
          Height = 17
          Caption = 'Habilitar Notifica'#231#245'es de Queda de Balan'#231'a no Telegram'
          TabOrder = 0
        end
        object edtTelegramToken: TEdit
          Left = 24
          Top = 95
          Width = 500
          Height = 23
          TabOrder = 1
        end
        object edtTelegramChatID: TEdit
          Left = 24
          Top = 160
          Width = 250
          Height = 23
          TabOrder = 2
        end
        object btnTestarTelegram: TButton
          Left = 24
          Top = 275
          Width = 180
          Height = 32
          Caption = 'Testar Envio Telegram'
          TabOrder = 3
          OnClick = btnTestarTelegramClick
        end
      end
    end
    object TabApiRest: TTabSheet
      Caption = '6. Micro-API REST'
      ImageIndex = 5
      object grpApiRest: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 360
        Caption = ' Micro-Servidor REST Embutido (Integra'#231#227'o Direta com ERP) '
        TabOrder = 0
        object lblPortaRest: TLabel
          Left = 24
          Top = 75
          Width = 100
          Height = 15
          Caption = 'Porta do Servidor:'
        end
        object lblApiRestInfo: TLabel
          Left = 24
          Top = 140
          Width = 620
          Height = 110
          Caption = 
            'A Micro-API REST roda de forma 100% nativa dentro do AtualizaBalan'#231'a sem precisar de outras aplica'#231#245'es.'#13#10#13#10 +
            'Endpoints dispon'#237'veis para o seu ERP consumir via HTTP JSON:'#13#10 +
            '  * GET  http://localhost:8085/status       - Retorna o status de cada balan'#231'a e monitoramento'#13#10 +
            '  * POST http://localhost:8085/sincronizar   - For'#231'a a carga imediata dos itens alterados'#13#10 +
            '  * POST http://localhost:8085/carga-total   - For'#231'a a carga completa em todas as balan'#231'as'#13#10 +
            '  * GET  http://localhost:8085/logs          - Retorna os '#250'ltimos 50 eventos de auditoria'
          WordWrap = True
        end
        object chkApiAtiva: TCheckBox
          Left = 24
          Top = 35
          Width = 350
          Height = 17
          Caption = 'Habilitar Micro-API REST Embutida no AtualizaBalan'#231'a'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object edtPortaRest: TEdit
          Left = 24
          Top = 95
          Width = 100
          Height = 23
          TabOrder = 1
          Text = '8085'
        end
      end
    end
    object TabDiagnostico: TTabSheet
      Caption = '7. Diagn'#243'stico de Cadastros'
      ImageIndex = 6
      object grpDiagnostico: TGroupBox
        Left = 16
        Top = 16
        Width = 700
        Height = 360
        Caption = ' Verificador de Integridade dos Cadastros '
        TabOrder = 0
        object btnExecutarDiagnostico: TButton
          Left = 24
          Top = 25
          Width = 200
          Height = 32
          Caption = 'Executar Diagn'#243'stico Agora'
          TabOrder = 0
          OnClick = btnExecutarDiagnosticoClick
        end
        object btnExportarDiagnosticoCSV: TButton
          Left = 235
          Top = 25
          Width = 220
          Height = 32
          Caption = 'Exportar Planilha (CSV / Excel)'
          TabOrder = 1
          OnClick = btnExportarDiagnosticoCSVClick
        end
        object mmoResultadoDiagnostico: TMemo
          Left = 24
          Top = 70
          Width = 650
          Height = 270
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
    end
  end
object OpenDialogBanco: TOpenDialog
    DefaultExt = 'fdb'
    Filter = 
      'Banco de Dados Firebird (*.fdb;*.gdb)|*.fdb;*.gdb|Todos os Arquivo' +
      's (*.*)|*.*'
    Title = 'Selecionar Banco de Dados Firebird'
    Left = 460
    Top = 150
  end
  object SaveDialogCSV: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*'
    Title = 'Salvar Relat'#243'rio de Diagn'#243'stico de PLUs'
    Left = 520
    Top = 150
  end
  object SaveDialogBackup: TSaveDialog
    DefaultExt = 'json'
    Filter = 'Backup de Configura'#231#245'es (*.json)|*.json|Todos os Arquivos (*.*)|*.*'
    Title = 'Salvar Backup de Configura'#231#245'es das Balan'#231'as'
    Left = 580
    Top = 150
  end
  object OpenDialogBackup: TOpenDialog
    DefaultExt = 'json'
    Filter = 'Backup de Configura'#231#245'es (*.json)|*.json|Todos os Arquivos (*.*)|*.*'
    Title = 'Selecionar Arquivo de Backup para Restaura'#231#227'o'
    Left = 640
    Top = 150
  end
end