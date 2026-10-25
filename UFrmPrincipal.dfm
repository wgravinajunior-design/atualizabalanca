object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'GoUp Sistemas - AtualizaBalan'#231'a Enterprise'
  ClientHeight = 650
  ClientWidth = 1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 5384214
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 960
    object imgLogoApp: TImage
      Left = 14
      Top = 10
      Width = 46
      Height = 46
      Proportional = True
      Stretch = True
    end
    object lblTitulo: TLabel
      Left = 68
      Top = 10
      Width = 354
      Height = 21
      Caption = 'GoUp Sistemas - Atualizador de dados Balan'#231'a'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 68
      Top = 36
      Width = 107
      Height = 15
      Caption = 'Sincroniza'#231#227'o Direta'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object pnlStatusTopo: TPanel
      Left = 490
      Top = 14
      Width = 180
      Height = 38
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblStatusServico: TLabel
        Left = 10
        Top = 3
        Width = 119
        Height = 15
        Caption = 'Banco: Desconectado'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusRest: TLabel
        Left = 10
        Top = 19
        Width = 104
        Height = 13
        Caption = 'API REST: :8085 Ativa'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object btnConectarBanco: TButton
      Left = 680
      Top = 14
      Width = 115
      Height = 38
      Caption = 'Conectar Banco'
      TabOrder = 1
      OnClick = btnConectarBancoClick
    end
    object btnConfiguracoes: TButton
      Left = 805
      Top = 14
      Width = 115
      Height = 38
      Caption = 'Configura'#231#245'es'
      TabOrder = 2
      OnClick = btnConfiguracoesClick
    end
    object pnlBadgeBuild: TPanel
      Left = 930
      Top = 15
      Width = 135
      Height = 36
      Cursor = crHandPoint
      Hint = 'Clique para ver as novidades da build e checar atualiza'#231#245'es (F1)'
      BevelOuter = bvNone
      Color = 2758415
      ParentBackground = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = lblBadgeBuildClick
      object lblBadgeBuild: TLabel
        Left = 0
        Top = 0
        Width = 88
        Height = 17
        Cursor = crHandPoint
        Hint = 'Clique para ver as novidades da build e checar atualiza'#231#245'es (F1)'
        Align = alClient
        Alignment = taCenter
        Caption = #9889' Build 1.0.3'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6210850
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        OnClick = lblBadgeBuildClick
      end
    end
  end
  object pnlCards: TPanel
    Left = 0
    Top = 65
    Width = 1080
    Height = 85
    Align = alTop
    BevelOuter = bvNone
    Color = clWhitesmoke
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 960
    object pnlCardStatus: TPanel
      Left = 15
      Top = 10
      Width = 220
      Height = 65
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblCardStatusTit: TLabel
        Left = 15
        Top = 12
        Width = 98
        Height = 15
        Caption = 'Status do Monitor:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardStatusVal: TLabel
        Left = 15
        Top = 30
        Width = 56
        Height = 25
        Caption = 'ATIVO'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardBalancas: TPanel
      Left = 250
      Top = 10
      Width = 220
      Height = 65
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblCardBalancasTit: TLabel
        Left = 15
        Top = 12
        Width = 104
        Height = 15
        Caption = 'Balan'#231'as Instaladas:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardBalancasVal: TLabel
        Left = 15
        Top = 30
        Width = 98
        Height = 25
        Caption = '3 / 3 Ativas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardItens: TPanel
      Left = 485
      Top = 10
      Width = 220
      Height = 65
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblCardItensTit: TLabel
        Left = 15
        Top = 12
        Width = 104
        Height = 15
        Caption = 'Sincronizados Hoje:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardItensVal: TLabel
        Left = 15
        Top = 30
        Width = 11
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5384214
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardUltimaSync: TPanel
      Left = 720
      Top = 10
      Width = 225
      Height = 65
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblCardUltimaSyncTit: TLabel
        Left = 15
        Top = 12
        Width = 106
        Height = 15
        Caption = #218'ltima Transmiss'#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardUltimaSyncVal: TLabel
        Left = 15
        Top = 34
        Width = 67
        Height = 15
        Caption = 'Aguardando'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlControles: TPanel
    Left = 0
    Top = 150
    Width = 1080
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object btnCadastroProdutos: TButton
      Left = 10
      Top = 9
      Width = 112
      Height = 32
      Hint = 
        'Abre o cadastro completo de produtos, departamentos e tabela nut' +
        'ricional RDC 429 (Atalho: F2)'
      Caption = 'Produtos (F2)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnCadastroProdutosClick
    end
    object btnCargaAlterados: TButton
      Left = 127
      Top = 9
      Width = 115
      Height = 32
      Hint = 
        'Envia imediatamente os produtos que tiveram pre'#231'o ou dados alter' +
        'ados no sistema (Atalho: F5)'
      Caption = 'Sincronizar (F5)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnCargaAlteradosClick
    end
    object btnCargaTotal: TButton
      Left = 247
      Top = 9
      Width = 105
      Height = 32
      Hint = 
        'Transmite o cadastro completo de produtos para todas as balan'#231'as' +
        ' ativas (Atalho: F6)'
      Caption = 'Carga Total (F6)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnCargaTotalClick
    end
    object btnCompararAlteracoes: TButton
      Left = 357
      Top = 9
      Width = 120
      Height = 32
      Hint = 
        'Exibe o comparativo de pre'#231'os anteriores x atuais e produtos pen' +
        'dentes de preenchimento de c'#243'digo (Atalho: F7)'
      Caption = 'Ver Altera'#231#245'es (F7)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnCompararAlteracoesClick
    end
    object btnTestarConexoes: TButton
      Left = 482
      Top = 9
      Width = 120
      Height = 32
      Hint = 
        'Verifica a comunica'#231#227'o de rede com cada uma das balan'#231'as cadastr' +
        'adas (Atalho: F8)'
      Caption = 'Testar Balan'#231'as (F8)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnTestarConexoesClick
    end
    object btnEditorEtiquetas: TButton
      Left = 607
      Top = 9
      Width = 105
      Height = 32
      Hint = 
        'Abre o editor visual de etiquetas para personalizar e enviar lay' +
        'out para as balan'#231'as (Atalho: F9)'
      Caption = 'Etiquetas (F9)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnEditorEtiquetasClick
    end
    object btnRelatoriosGestao: TButton
      Left = 717
      Top = 9
      Width = 115
      Height = 32
      Hint = 
        'Emite relat'#243'rios gerenciais de vendas por peso, pre'#231'o, transa'#231#245'e' +
        's e etiquetas (Atalho: F10)'
      Caption = 'Relat'#243'rios (F10)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = btnRelatoriosGestaoClick
    end
    object btnIniciarPausar: TButton
      Left = 837
      Top = 9
      Width = 120
      Height = 32
      Hint = 
        'Pausa ou retoma o ciclo autom'#225'tico de sincroniza'#231#227'o em segundo p' +
        'lano'
      Caption = 'Pausar Monitor'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = btnIniciarPausarClick
    end
    object btnValidarPLUs: TButton
      Left = 962
      Top = 9
      Width = 108
      Height = 32
      Hint = 
        'Executa diagn'#243'stico de integridade dos c'#243'digos, pre'#231'os e validad' +
        'es no banco'
      Caption = 'Diagn'#243'stico PLUs'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = btnValidarPLUsClick
    end
  end
  object pnlCentral: TPanel
    Left = 0
    Top = 200
    Width = 1080
    Height = 450
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitWidth = 960
    object grpBalancas: TGroupBox
      Left = 0
      Top = 0
      Width = 1080
      Height = 220
      Align = alTop
      Caption = 
        ' Balan'#231'as em Monitoramento (Duplo clique ou clique direito para ' +
        'a'#231#245'es r'#225'pidas) '
      TabOrder = 0
      ExplicitWidth = 960
      object lvBalancas: TListView
        Left = 2
        Top = 17
        Width = 956
        Height = 201
        Align = alClient
        Columns = <
          item
            Caption = 'ID'
            Width = 40
          end
          item
            Caption = 'Identifica'#231#227'o'
            Width = 180
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
            Caption = 'Endere'#231'o IP'
            Width = 120
          end
          item
            Caption = 'Porta'
            Width = 60
          end
          item
            Caption = 'Setor'
          end
          item
            Caption = 'Status'
            Width = 80
          end
          item
            Caption = #218'ltima Carga'
            Width = 130
          end
          item
            Caption = #218'ltima Mensagem'
            Width = 260
          end>
        GridLines = True
        RowSelect = True
        PopupMenu = PopupMenuBalanca
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvBalancasDblClick
      end
    end
    object grpLogs: TGroupBox
      Left = 0
      Top = 220
      Width = 1080
      Height = 230
      Align = alClient
      Caption = ' Registro de Atividades e Transmiss'#245'es em Tempo Real '
      TabOrder = 1
      ExplicitWidth = 960
      object pnlLogToolbar: TPanel
        Left = 2
        Top = 17
        Width = 1076
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 956
        object lblLogInfo: TLabel
          Left = 10
          Top = 8
          Width = 133
          Height = 15
          Caption = 'Eventos em Tempo Real'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblFiltroLog: TLabel
          Left = 180
          Top = 8
          Width = 33
          Height = 15
          Caption = 'Filtrar:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object cbFiltroLog: TComboBox
          Left = 220
          Top = 4
          Width = 220
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Todos os Registros'
          OnChange = cbFiltroLogChange
          Items.Strings = (
            'Todos os Registros'
            'Apenas Falhas / Erros'
            'Apenas Transmiss'#245'es com Sucesso'
            'Apenas Alertas')
        end
        object btnCopiarLog: TButton
          Left = 746
          Top = 3
          Width = 98
          Height = 26
          Hint = 'Copia o log filtrado para a '#225'rea de transfer'#234'ncia'
          Caption = 'Copiar Log'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = btnCopiarLogClick
        end
        object btnLimparLog: TButton
          Left = 852
          Top = 3
          Width = 98
          Height = 26
          Hint = 'Limpa a visualiza'#231#227'o de logs da tela'
          Caption = 'Limpar Log'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = btnLimparLogClick
        end
      end
      object mmoLogs: TMemo
        Left = 2
        Top = 49
        Width = 1076
        Height = 179
        Align = alClient
        Color = 1973790
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15132390
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
        ExplicitWidth = 956
      end
    end
  end
  object TrayIcon: TTrayIcon
    BalloonHint = 'AtualizaBalan'#231'a est'#225' em execu'#231#227'o em segundo plano.'
    BalloonTitle = 'GoUp Sistemas - AtualizaBalan'#231'a Enterprise'
    BalloonFlags = bfInfo
    PopupMenu = PopupMenuTray
    Visible = True
    OnDblClick = TrayIconDblClick
    Left = 480
    Top = 20
  end
  object PopupMenuTray: TPopupMenu
    Left = 540
    Top = 20
    object mnAbrir: TMenuItem
      Caption = 'Abrir AtualizaBalan'#231'a'
      Default = True
      OnClick = mnAbrirClick
    end
    object mnIniciarPausar: TMenuItem
      Caption = 'Pausar Monitoramento'
      OnClick = btnIniciarPausarClick
    end
    object mnSincronizarAgora: TMenuItem
      Caption = 'Sincronizar Agora'
      OnClick = btnCargaAlteradosClick
    end
    object mnDiagnostico: TMenuItem
      Caption = 'Validar Cadastros de PLU'
      OnClick = btnValidarPLUsClick
    end
    object mnSeparador: TMenuItem
      Caption = '-'
    end
    object mnSair: TMenuItem
      Caption = 'Sair do Sistema'
      OnClick = mnSairClick
    end
  end
  object PopupMenuBalanca: TPopupMenu
    Left = 600
    Top = 20
    object mnTestarBalancaIndividual: TMenuItem
      Caption = 'Testar Conex'#227'o com esta Balan'#231'a'
      OnClick = mnTestarBalancaIndividualClick
    end
    object mnCargaBalancaIndividual: TMenuItem
      Caption = 'Enviar Carga para esta Balan'#231'a'
      OnClick = mnCargaBalancaIndividualClick
    end
    object mnLimparMemoriaBalanca: TMenuItem
      Caption = 'Apagar / Zerar Dados desta Balan'#231'a...'
      OnClick = mnLimparMemoriaBalancaClick
    end
    object mnVerTabelaNutricional: TMenuItem
      Caption = 'Ver Tabela Nutricional (RDC 429)...'
      OnClick = mnVerTabelaNutricionalClick
    end
    object mnEditorEtiquetaBalanca: TMenuItem
      Caption = 'Editar Layout de Etiqueta (F9)...'
      OnClick = mnEditorEtiquetaBalancaClick
    end
    object mnSepBalanca: TMenuItem
      Caption = '-'
    end
    object mnPropriedadesBalanca: TMenuItem
      Caption = 'Ver Configura'#231#245'es...'
      OnClick = mnPropriedadesBalancaClick
    end
  end
  object SaveDialogCSV: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*'
    Title = 'Salvar Relat'#243'rio de Diagn'#243'stico de PLUs'
    Left = 660
    Top = 20
  end
end
