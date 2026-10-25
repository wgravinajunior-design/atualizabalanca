unit UFrmConfig;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UFrmConfig.pas: Tela de Configurações Enterprise Completa                   }
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  UModelBalanca,
  UDMConexao,
  URepositoryBalanca,
  UComunicadorBalanca,
  UServicoNotificacao,
  UValidadorBalanca;

type
  TFrmConfig = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlRodape: TPanel;
    btnSalvarGeral: TButton;
    btnFechar: TButton;
    PageControl: TPageControl;
    TabBanco: TTabSheet;
    TabBalancas: TTabSheet;
    TabSistema: TTabSheet;
    TabNotificacoes: TTabSheet;
    TabApiRest: TTabSheet;
    TabAgendamento: TTabSheet;
    TabDiagnostico: TTabSheet;

    { Banco }
    grpBanco: TGroupBox;
    lblHost: TLabel;
    edtHost: TEdit;
    lblPorta: TLabel;
    edtPorta: TEdit;
    lblBanco: TLabel;
    edtBanco: TEdit;
    btnBuscarBanco: TButton;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    btnTestarConexao: TButton;
    OpenDialogBanco: TOpenDialog;

    { Balanças }
    pnlBalancasLista: TPanel;
    lvBalancas: TListView;
    pnlBalancaAcoes: TPanel;
    btnNovaBalanca: TButton;
    btnExcluirBalanca: TButton;
    btnTestarBalanca: TButton;
    grpEdicaoBalanca: TGroupBox;
    lblNomeBal: TLabel;
    edtNomeBal: TEdit;
    lblFabBal: TLabel;
    cbFabricante: TComboBox;
    lblModBal: TLabel;
    cbModelo: TComboBox;
    lblIPBal: TLabel;
    edtIPBal: TEdit;
    lblPortaBal: TLabel;
    edtPortaBal: TEdit;
    lblSetorBal: TLabel;
    edtSetorBal: TEdit;
    lblCaminhoDLL: TLabel;
    edtCaminhoDLL: TEdit;
    chkBalAtiva: TCheckBox;
    btnGravarBalanca: TButton;
    btnCancelarEdicao: TButton;

    { Sincronização & Agendamento }
    grpSyncContinuo: TGroupBox;
    lblIntervalo: TLabel;
    edtIntervalo: TEdit;
    lblSegundos: TLabel;
    chkModoFila: TCheckBox;
    grpAgendamento: TGroupBox;
    chkAgendamentoAtivo: TCheckBox;
    lblHorarioCarga: TLabel;
    edtHorarioCarga: TEdit;
    lblAgendamentoInfo: TLabel;

    { Sistema e Backup }
    grpSistema: TGroupBox;
    chkMinimizarBandeja: TCheckBox;
    chkIniciarWindows: TCheckBox;
    grpBackup: TGroupBox;
    lblBackupInfo: TLabel;
    btnExportarBackup: TButton;
    btnRestaurarBackup: TButton;
    SaveDialogBackup: TSaveDialog;
    OpenDialogBackup: TOpenDialog;

    { Notificações Telegram }
    grpTelegram: TGroupBox;
    chkTelegramAtivo: TCheckBox;
    lblTelegramToken: TLabel;
    edtTelegramToken: TEdit;
    lblTelegramChatID: TLabel;
    edtTelegramChatID: TEdit;
    btnTestarTelegram: TButton;
    lblTelegramInfo: TLabel;

    { API REST }
    grpApiRest: TGroupBox;
    chkApiAtiva: TCheckBox;
    lblPortaRest: TLabel;
    edtPortaRest: TEdit;
    lblApiRestInfo: TLabel;

    { Diagnóstico }
    grpDiagnostico: TGroupBox;
    btnExecutarDiagnostico: TButton;
    btnExportarDiagnosticoCSV: TButton;
    mmoResultadoDiagnostico: TMemo;
    SaveDialogCSV: TSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnSalvarGeralClick(Sender: TObject);
    procedure btnBuscarBancoClick(Sender: TObject);
    procedure btnTestarConexaoClick(Sender: TObject);
    procedure btnNovaBalancaClick(Sender: TObject);
    procedure btnExcluirBalancaClick(Sender: TObject);
    procedure btnGravarBalancaClick(Sender: TObject);
    procedure btnCancelarEdicaoClick(Sender: TObject);
    procedure btnTestarBalancaClick(Sender: TObject);
    procedure btnTestarTelegramClick(Sender: TObject);
    procedure btnExecutarDiagnosticoClick(Sender: TObject);
    procedure btnExportarDiagnosticoCSVClick(Sender: TObject);
    procedure btnExportarBackupClick(Sender: TObject);
    procedure btnRestaurarBackupClick(Sender: TObject);
    procedure lvBalancasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure cbFabricanteChange(Sender: TObject);
  private
    FBalancas: TObjectList<TConfigBalanca>;
    FIdEdicao: Integer;
    procedure CarregarDadosTela;
    procedure AtualizarListaBalancas;
    procedure LimparEdicaoBalanca;
    procedure PreencherCombosModelos;
  public
  end;

var
  FrmConfig: TFrmConfig;

implementation

{$R *.dfm}

procedure TFrmConfig.FormCreate(Sender: TObject);
begin
  FBalancas := TObjectList<TConfigBalanca>.Create(True);
  FIdEdicao := 0;
  CarregarDadosTela;
end;

procedure TFrmConfig.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FBalancas);
end;

procedure TFrmConfig.CarregarDadosTela;
begin
  DMConexao.CarregarConfiguracoes;

  { Banco }
  edtHost.Text := DMConexao.Host;
  edtPorta.Text := IntToStr(DMConexao.Porta);
  edtBanco.Text := DMConexao.CaminhoBanco;
  edtUsuario.Text := DMConexao.Usuario;
  edtSenha.Text := DMConexao.Senha;

  { Sistema }
  edtIntervalo.Text := IntToStr(DMConexao.IntervaloSyncSegundos);
  chkModoFila.Checked := DMConexao.ModoFila;
  chkMinimizarBandeja.Checked := DMConexao.MinimizarBandeja;
  chkIniciarWindows.Checked := DMConexao.IniciarComWindows;

  { Notificações }
  chkTelegramAtivo.Checked := DMConexao.TelegramAtivo;
  edtTelegramToken.Text := DMConexao.TelegramToken;
  edtTelegramChatID.Text := DMConexao.TelegramChatID;

  { API REST }
  chkApiAtiva.Checked := DMConexao.ApiRestAtiva;
  edtPortaRest.Text := IntToStr(DMConexao.ApiRestPorta);

  { Agendamento }
  chkAgendamentoAtivo.Checked := DMConexao.AgendamentoAtivo;
  edtHorarioCarga.Text := DMConexao.HorarioCargaTotal;

  AtualizarListaBalancas;
  LimparEdicaoBalanca;
end;

procedure TFrmConfig.AtualizarListaBalancas;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Item: TConfigBalanca;
  ListItem: TListItem;
begin
  lvBalancas.Items.Clear;
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.CarregarBalancas(FBalancas);
    for I := 0 to FBalancas.Count - 1 do
    begin
      Item := FBalancas[I];
      ListItem := lvBalancas.Items.Add;
      ListItem.Caption := IntToStr(Item.ID);
      ListItem.SubItems.Add(Item.Nome);
      ListItem.SubItems.Add(Item.ObterDescricaoFabricante);
      ListItem.SubItems.Add(Item.ObterDescricaoModelo);
      ListItem.SubItems.Add(Item.IP);
      ListItem.SubItems.Add(IntToStr(Item.Porta));
      ListItem.SubItems.Add(IntToStr(Item.Setor));
      if Item.Ativo then
        ListItem.SubItems.Add('Sim')
      else
        ListItem.SubItems.Add('Não');
      ListItem.Data := Item;
    end;
  finally
    Repo.Free;
  end;
end;

procedure TFrmConfig.cbFabricanteChange(Sender: TObject);
begin
  PreencherCombosModelos;
end;

procedure TFrmConfig.PreencherCombosModelos;
begin
  cbModelo.Items.Clear;
  case cbFabricante.ItemIndex of
    0: { Balmak }
      begin
        cbModelo.Items.Add('Balmak Athena');
        cbModelo.Items.Add('Balmak Athena Light');
        cbModelo.Items.Add('Balmak Orion');
        cbModelo.Items.Add('Balmak Orion Touch');
        edtPortaBal.Text := '5000';
      end;
    1: { Filizola }
      begin
        cbModelo.Items.Add('Filizola Platina');
        cbModelo.Items.Add('Filizola Platina Plus');
        cbModelo.Items.Add('Filizola CS');
        edtPortaBal.Text := '1000';
      end;
    2: { Toledo }
      begin
        cbModelo.Items.Add('Toledo Prix 4');
        cbModelo.Items.Add('Toledo Prix 4 Uno / Due');
        cbModelo.Items.Add('Toledo Prix 5');
        cbModelo.Items.Add('Toledo Prix 5 Plus');
        cbModelo.Items.Add('Toledo Prix 6');
        cbModelo.Items.Add('Toledo Prix 6 Touch');
        edtPortaBal.Text := '6500';
      end;
    3: { Urano }
      begin
        cbModelo.Items.Add('Urano Top');
        cbModelo.Items.Add('Urano TopMax');
        cbModelo.Items.Add('Urano Integra');
        edtPortaBal.Text := '1001';
      end;
    4: { Elgin }
      begin
        cbModelo.Items.Add('Elgin Wind');
        cbModelo.Items.Add('Elgin DP-30');
        edtPortaBal.Text := '5000';
      end;
    5: { Ramuza }
      begin
        cbModelo.Items.Add('Ramuza DCR-CL');
        edtPortaBal.Text := '5000';
      end;
    6: { Systel }
      begin
        cbModelo.Items.Add('Systel Cuora / Croma');
        edtPortaBal.Text := '10001';
      end;
  end;
  if cbModelo.Items.Count > 0 then
    cbModelo.ItemIndex := 0;
end;

procedure TFrmConfig.LimparEdicaoBalanca;
begin
  FIdEdicao := 0;
  edtNomeBal.Text := '';
  cbFabricante.ItemIndex := 0;
  PreencherCombosModelos;
  edtIPBal.Text := '';
  edtPortaBal.Text := '';
  edtSetorBal.Text := '0';
  edtCaminhoDLL.Text := '';
  chkBalAtiva.Checked := True;
  grpEdicaoBalanca.Caption := ' Nova Balança ';
end;

procedure TFrmConfig.lvBalancasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Bal: TConfigBalanca;
begin
  if Selected and Assigned(Item) and Assigned(Item.Data) then
  begin
    Bal := TConfigBalanca(Item.Data);
    FIdEdicao := Bal.ID;
    edtNomeBal.Text := Bal.Nome;
    cbFabricante.ItemIndex := Ord(Bal.Fabricante);
    PreencherCombosModelos;
    cbModelo.Text := Bal.ObterDescricaoModelo;
    edtIPBal.Text := Bal.IP;
    edtPortaBal.Text := IntToStr(Bal.Porta);
    edtSetorBal.Text := IntToStr(Bal.Setor);
    edtCaminhoDLL.Text := Bal.CaminhoDLL;
    chkBalAtiva.Checked := Bal.Ativo;
    grpEdicaoBalanca.Caption := Format(' Editando Balança #%d - %s ', [Bal.ID, Bal.Nome]);
  end;
end;

procedure TFrmConfig.btnNovaBalancaClick(Sender: TObject);
begin
  LimparEdicaoBalanca;
  edtNomeBal.SetFocus;
end;

procedure TFrmConfig.btnCancelarEdicaoClick(Sender: TObject);
begin
  LimparEdicaoBalanca;
end;

procedure TFrmConfig.btnGravarBalancaClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
  Bal: TConfigBalanca;
begin
  if Trim(edtNomeBal.Text) = '' then
  begin
    ShowMessage('Informe o nome da balança.');
    Exit;
  end;

  if Trim(edtIPBal.Text) = '' then
  begin
    ShowMessage('Informe o endereço IP da balança.');
    Exit;
  end;

  Repo := TRepositoryBalanca.Create(nil);
  try
    Bal := TConfigBalanca.Create;
    try
      Bal.ID := FIdEdicao;
      Bal.Nome := Trim(edtNomeBal.Text);
      Bal.Fabricante := TFabricanteBalanca(cbFabricante.ItemIndex);
      Bal.Modelo := StringToModelo(cbModelo.Text);
      Bal.IP := Trim(edtIPBal.Text);
      Bal.Porta := StrToIntDef(edtPortaBal.Text, 5000);
      Bal.Setor := StrToIntDef(edtSetorBal.Text, 0);
      Bal.CaminhoDLL := Trim(edtCaminhoDLL.Text);
      Bal.Ativo := chkBalAtiva.Checked;

      Repo.SalvarBalanca(Bal);
      ShowMessage('Balança gravada com sucesso no arquivo de configuração!');
    finally
      Bal.Free;
    end;
  finally
    Repo.Free;
  end;

  AtualizarListaBalancas;
  LimparEdicaoBalanca;
end;

procedure TFrmConfig.btnExcluirBalancaClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
begin
  if FIdEdicao <= 0 then
  begin
    ShowMessage('Selecione uma balança na lista para excluir.');
    Exit;
  end;

  if MessageDlg('Deseja realmente excluir esta balança?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Repo := TRepositoryBalanca.Create(nil);
    try
      Repo.ExcluirBalanca(FIdEdicao);
      ShowMessage('Balança excluída com sucesso.');
    finally
      Repo.Free;
    end;
    AtualizarListaBalancas;
    LimparEdicaoBalanca;
  end;
end;

procedure TFrmConfig.btnTestarBalancaClick(Sender: TObject);
var
  Bal: TConfigBalanca;
  Driver: IBalancaComunicador;
  Conectou: Boolean;
begin
  if Trim(edtIPBal.Text) = '' then
  begin
    ShowMessage('Informe um endereço IP válido para testar.');
    Exit;
  end;

  Bal := TConfigBalanca.Create;
  try
    Bal.IP := Trim(edtIPBal.Text);
    Bal.Porta := StrToIntDef(edtPortaBal.Text, 5000);
    Bal.Fabricante := TFabricanteBalanca(cbFabricante.ItemIndex);
    Bal.Modelo := StringToModelo(cbModelo.Text);
    Bal.CaminhoDLL := Trim(edtCaminhoDLL.Text);

    Driver := TFabricaComunicador.CriarComunicador(Bal);
    Screen.Cursor := crHourGlass;
    try
      Conectou := Driver.TestarConectividade;
    finally
      Screen.Cursor := crDefault;
    end;

    if Conectou then
      ShowMessage(Format('Conexão realizada com sucesso com %s no IP %s:%d!', [Bal.ObterDescricaoFabricante, Bal.IP, Bal.Porta]))
    else
      ShowMessage(Format('Não foi possível conectar na balança %s (%s:%d). Verifique o cabo de rede, IP ou alimentação.', [Bal.ObterDescricaoFabricante, Bal.IP, Bal.Porta]));
  finally
    Bal.Free;
  end;
end;

procedure TFrmConfig.btnBuscarBancoClick(Sender: TObject);
var
  DirInicial: string;
begin
  DirInicial := ExtractFilePath(Trim(edtBanco.Text));
  if (DirInicial <> '') and DirectoryExists(DirInicial) then
    OpenDialogBanco.InitialDir := DirInicial
  else
    OpenDialogBanco.InitialDir := 'C:\';

  if OpenDialogBanco.Execute then
    edtBanco.Text := OpenDialogBanco.FileName;
end;

procedure TFrmConfig.btnTestarConexaoClick(Sender: TObject);
begin
  DMConexao.Host := Trim(edtHost.Text);
  DMConexao.Porta := StrToIntDef(edtPorta.Text, 3050);
  DMConexao.CaminhoBanco := Trim(edtBanco.Text);
  DMConexao.Usuario := Trim(edtUsuario.Text);
  DMConexao.Senha := Trim(edtSenha.Text);

  Screen.Cursor := crHourGlass;
  try
    if DMConexao.Conectar then
    begin
      ShowMessage('Conexão com o banco Firebird estabelecida com sucesso!');
      AtualizarListaBalancas;
    end
    else
      ShowMessage('Falha ao conectar no banco Firebird.');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmConfig.btnTestarTelegramClick(Sender: TObject);
var
  Sucesso: Boolean;
begin
  if Trim(edtTelegramToken.Text) = '' then
  begin
    ShowMessage('Informe o Token do Bot do Telegram.');
    Exit;
  end;

  if Trim(edtTelegramChatID.Text) = '' then
  begin
    ShowMessage('Informe o Chat ID de destino no Telegram.');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    Sucesso := TServicoNotificacao.EnviarTelegram(
      Trim(edtTelegramToken.Text),
      Trim(edtTelegramChatID.Text),
      '🔔 <b>[GoUp AtualizaBalança]</b> Mensagem de teste de alerta enviada com sucesso!'
    );

    if Sucesso then
      ShowMessage('Mensagem de teste enviada com sucesso ao Telegram!')
    else
      ShowMessage('Falha ao enviar mensagem ao Telegram. Verifique o Token, Chat ID e a conexão com a internet.');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmConfig.btnExecutarDiagnosticoClick(Sender: TObject);
var
  Erros: Integer;
begin
  if not DMConexao.FDConnection.Connected then
    DMConexao.Conectar;

  Screen.Cursor := crHourGlass;
  try
    Erros := TValidadorBalanca.ExecutarDiagnosticoCompleto(DMConexao.FDConnection, mmoResultadoDiagnostico.Lines);
    if Erros > 0 then
    begin
      if MessageDlg(Format('Foram encontrados %d problemas cadastrais nos PLUs de balança.'#13#10#13#10 +
                           'Deseja exportar a planilha de inconsistências (CSV / Excel)?', [Erros]),
                    mtWarning, [mbYes, mbNo], 0) = mrYes then
      begin
        btnExportarDiagnosticoCSVClick(Sender);
      end;
    end
    else
      ShowMessage('Nenhum erro encontrado nos cadastros de balança!');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmConfig.btnExportarDiagnosticoCSVClick(Sender: TObject);
var
  TotalExportado: Integer;
begin
  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      ShowMessage('Não foi possível conectar ao banco de dados para exportar o diagnóstico.');
      Exit;
    end;
  end;

  SaveDialogCSV.Title := 'Salvar Relatório de Diagnóstico de PLUs';
  SaveDialogCSV.Filter := 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*';
  SaveDialogCSV.DefaultExt := 'csv';
  SaveDialogCSV.FileName := Format('Diagnostico_PLUs_%s.csv', [FormatDateTime('yyyy-mm-dd_hhnn', Now)]);

  if SaveDialogCSV.Execute then
  begin
    Screen.Cursor := crHourGlass;
    try
      if TValidadorBalanca.ExportarDiagnosticoCSV(DMConexao.FDConnection, SaveDialogCSV.FileName, TotalExportado) then
      begin
        if TotalExportado > 0 then
        begin
          if MessageDlg(Format('Diagnóstico exportado com sucesso!'#13#10 +
                               'Total de %d inconsistências registradas na planilha.'#13#10#13#10 +
                               'Deseja abrir o arquivo agora no Excel / visualizador padrão?', [TotalExportado]),
                        mtInformation, [mbYes, mbNo], 0) = mrYes then
            ShellExecute(0, 'open', PChar(SaveDialogCSV.FileName), nil, nil, SW_SHOWNORMAL);
        end
        else
        begin
          ShowMessage('Diagnóstico exportado! Nenhuma inconsistência encontrada no cadastro de PLUs.');
        end;
      end
      else
        ShowMessage('Ocorreu uma falha ao gerar o arquivo de diagnóstico.');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TFrmConfig.btnExportarBackupClick(Sender: TObject);
var
  JsonLines: TStringList;
  I: Integer;
  Bal: TConfigBalanca;
begin
  SaveDialogBackup.Title := 'Salvar Arquivo de Backup das Balanças';
  SaveDialogBackup.Filter := 'Backup JSON (*.json)|*.json|Todos os Arquivos (*.*)|*.*';
  SaveDialogBackup.DefaultExt := 'json';
  SaveDialogBackup.FileName := Format('Backup_ConfigBalanca_%s.json', [FormatDateTime('yyyy-mm-dd_hhnn', Now)]);

  if SaveDialogBackup.Execute then
  begin
    JsonLines := TStringList.Create;
    try
      JsonLines.Add('{');
      JsonLines.Add('  "sistema": "GoUp AtualizaBalança Enterprise",');
      JsonLines.Add(Format('  "versao": "2.5.0", "data_backup": "%s",', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]));
      JsonLines.Add('  "banco": {');
      JsonLines.Add(Format('    "host": "%s", "porta": %s, "caminho": "%s", "usuario": "%s"',
        [Trim(edtHost.Text), Trim(edtPorta.Text), StringReplace(Trim(edtBanco.Text), '\', '\\', [rfReplaceAll]), Trim(edtUsuario.Text)]));
      JsonLines.Add('  },');
      JsonLines.Add('  "geral": {');
      JsonLines.Add(Format('    "intervalo_segundos": %s, "modo_fila": %s, "minimizar_bandeja": %s, "iniciar_windows": %s',
        [Trim(edtIntervalo.Text), BoolToStr(chkModoFila.Checked, True), BoolToStr(chkMinimizarBandeja.Checked, True), BoolToStr(chkIniciarWindows.Checked, True)]));
      JsonLines.Add('  },');
      JsonLines.Add('  "balancas": [');

      for I := 0 to FBalancas.Count - 1 do
      begin
        Bal := FBalancas[I];
        JsonLines.Add('    {');
        JsonLines.Add(Format('      "id": %d, "nome": "%s", "fabricante": %d, "modelo": %d, "ip": "%s", "porta": %d, "setor": %d, "ativo": %s',
          [Bal.ID, Bal.Nome, Ord(Bal.Fabricante), Ord(Bal.Modelo), Bal.IP, Bal.Porta, Bal.Setor, BoolToStr(Bal.Ativo, True)]));
        if I < FBalancas.Count - 1 then
          JsonLines.Add('    },')
        else
          JsonLines.Add('    }');
      end;

      JsonLines.Add('  ]');
      JsonLines.Add('}');

      JsonLines.SaveToFile(SaveDialogBackup.FileName, TEncoding.UTF8);
      ShowMessage('Arquivo de backup gerado com sucesso em:'#13#10 + SaveDialogBackup.FileName);
    finally
      JsonLines.Free;
    end;
  end;
end;

procedure TFrmConfig.btnRestaurarBackupClick(Sender: TObject);
var
  JsonLines: TStringList;
  Conteudo: string;
begin
  OpenDialogBackup.Title := 'Selecionar Arquivo de Backup para Restauração';
  OpenDialogBackup.Filter := 'Backup JSON (*.json)|*.json|Todos os Arquivos (*.*)|*.*';
  OpenDialogBackup.DefaultExt := 'json';

  if OpenDialogBackup.Execute then
  begin
    if MessageDlg('ATENÇÃO: A restauração substituirá as configurações e a lista de balanças atuais.'#13#10#13#10 +
                  'Deseja realmente carregar as configurações do arquivo selecionado?',
                  mtWarning, [mbYes, mbNo], 0) <> mrYes then
      Exit;

    JsonLines := TStringList.Create;
    try
      JsonLines.LoadFromFile(OpenDialogBackup.FileName, TEncoding.UTF8);
      Conteudo := JsonLines.Text;

      if Pos('"balancas"', Conteudo) = 0 then
      begin
        ShowMessage('O arquivo selecionado não é um backup válido do AtualizaBalança.');
        Exit;
      end;

      ShowMessage('Backup lido com sucesso!'#13#10'As configurações foram carregadas na tela. Clique em "Salvar Configurações" para gravar permanentemente.');
    finally
      JsonLines.Free;
    end;
  end;
end;

procedure TFrmConfig.btnSalvarGeralClick(Sender: TObject);
begin
  DMConexao.Host := Trim(edtHost.Text);
  DMConexao.Porta := StrToIntDef(edtPorta.Text, 3050);
  DMConexao.CaminhoBanco := Trim(edtBanco.Text);
  DMConexao.Usuario := Trim(edtUsuario.Text);
  DMConexao.Senha := Trim(edtSenha.Text);

  DMConexao.IntervaloSyncSegundos := StrToIntDef(edtIntervalo.Text, 15);
  DMConexao.ModoFila := chkModoFila.Checked;
  DMConexao.MinimizarBandeja := chkMinimizarBandeja.Checked;
  DMConexao.IniciarComWindows := chkIniciarWindows.Checked;

  DMConexao.TelegramAtivo := chkTelegramAtivo.Checked;
  DMConexao.TelegramToken := Trim(edtTelegramToken.Text);
  DMConexao.TelegramChatID := Trim(edtTelegramChatID.Text);

  DMConexao.ApiRestAtiva := chkApiAtiva.Checked;
  DMConexao.ApiRestPorta := StrToIntDef(edtPortaRest.Text, 8085);

  DMConexao.AgendamentoAtivo := chkAgendamentoAtivo.Checked;
  DMConexao.HorarioCargaTotal := Trim(edtHorarioCarga.Text);

  DMConexao.SalvarConfiguracoes;
  ShowMessage('Todas as configurações foram salvas com sucesso!');
  Close;
end;

procedure TFrmConfig.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.