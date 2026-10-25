unit UFrmPrincipal;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UFrmPrincipal.pas: Dashboard Principal, Micro-API REST e Diagnóstico        }
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
  System.Threading,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Clipbrd,
  UModelBalanca,
  UDMConexao,
  URepositoryBalanca,
  UComunicadorBalanca,
  UThreadMonitor,
  UServidorRest,
  UValidadorBalanca,
  UFrmConfig,
  UFrmComparador,
  UFrmNutricional,
  UFrmSobreNovidades,
  UFrmEditorEtiquetas,
  UFrmCadastroProdutos,
  UFrmRelatoriosGestao;

type
  TFrmPrincipal = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlStatusTopo: TPanel;
    lblStatusServico: TLabel;
    lblStatusRest: TLabel;
    btnConectarBanco: TButton;
    btnConfiguracoes: TButton;
    pnlBadgeBuild: TPanel;
    lblBadgeBuild: TLabel;
    pnlCards: TPanel;
    pnlCardStatus: TPanel;
    lblCardStatusTit: TLabel;
    lblCardStatusVal: TLabel;
    pnlCardBalancas: TPanel;
    lblCardBalancasTit: TLabel;
    lblCardBalancasVal: TLabel;
    pnlCardItens: TPanel;
    lblCardItensTit: TLabel;
    lblCardItensVal: TLabel;
    pnlCardUltimaSync: TPanel;
    lblCardUltimaSyncTit: TLabel;
    lblCardUltimaSyncVal: TLabel;
    pnlControles: TPanel;
    btnCadastroProdutos: TButton;
    btnCargaAlterados: TButton;
    btnCargaTotal: TButton;
    btnCompararAlteracoes: TButton;
    btnTestarConexoes: TButton;
    btnEditorEtiquetas: TButton;
    btnRelatoriosGestao: TButton;
    btnIniciarPausar: TButton;
    btnValidarPLUs: TButton;
    pnlCentral: TPanel;
    grpBalancas: TGroupBox;
    lvBalancas: TListView;
    grpLogs: TGroupBox;
    pnlLogToolbar: TPanel;
    lblLogInfo: TLabel;
    lblFiltroLog: TLabel;
    cbFiltroLog: TComboBox;
    btnCopiarLog: TButton;
    btnLimparLog: TButton;
    mmoLogs: TMemo;
    TrayIcon: TTrayIcon;
    PopupMenuTray: TPopupMenu;
    mnAbrir: TMenuItem;
    mnIniciarPausar: TMenuItem;
    mnSincronizarAgora: TMenuItem;
    mnDiagnostico: TMenuItem;
    mnSeparador: TMenuItem;
    mnSair: TMenuItem;
    PopupMenuBalanca: TPopupMenu;
    mnTestarBalancaIndividual: TMenuItem;
    mnCargaBalancaIndividual: TMenuItem;
    mnLimparMemoriaBalanca: TMenuItem;
    mnVerTabelaNutricional: TMenuItem;
    mnEditorEtiquetaBalanca: TMenuItem;
    mnSepBalanca: TMenuItem;
    mnPropriedadesBalanca: TMenuItem;
    SaveDialogCSV: TSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnConectarBancoClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure lblBadgeBuildClick(Sender: TObject);
    procedure btnIniciarPausarClick(Sender: TObject);
    procedure btnCargaAlteradosClick(Sender: TObject);
    procedure btnCargaTotalClick(Sender: TObject);
    procedure btnTestarConexoesClick(Sender: TObject);
    procedure btnValidarPLUsClick(Sender: TObject);
    procedure cbFiltroLogChange(Sender: TObject);
    procedure btnCopiarLogClick(Sender: TObject);
    procedure btnLimparLogClick(Sender: TObject);
    procedure lvBalancasDblClick(Sender: TObject);
    procedure mnTestarBalancaIndividualClick(Sender: TObject);
    procedure mnCargaBalancaIndividualClick(Sender: TObject);
    procedure mnLimparMemoriaBalancaClick(Sender: TObject);
    procedure mnVerTabelaNutricionalClick(Sender: TObject);
    procedure mnEditorEtiquetaBalancaClick(Sender: TObject);
    procedure mnPropriedadesBalancaClick(Sender: TObject);
    procedure btnCompararAlteracoesClick(Sender: TObject);
    procedure btnEditorEtiquetasClick(Sender: TObject);
    procedure btnCadastroProdutosClick(Sender: TObject);
    procedure btnRelatoriosGestaoClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure mnAbrirClick(Sender: TObject);
    procedure mnSairClick(Sender: TObject);
  private
    FMonitorThread: TThreadMonitorBalanca;
    FServidorRest: TServidorRest;
    FBalancas: TObjectList<TConfigBalanca>;
    FHistoricoLogs: TStringList;
    FTotalItensHoje: Integer;
    FEncerrando: Boolean;
    FJaIniciouMinimizado: Boolean;

    procedure IniciarMonitoramento;
    procedure PararMonitoramento;
    procedure IniciarServidorRest;
    procedure PararServidorRest;

    procedure AtualizarGridBalancas;
    procedure AtualizarStatusConexaoUI;
    procedure AdicionarLog(const ANivel: string; const AMensagem: string);
    procedure AtualizarEstatisticas(const ATotal: Integer; const ADataHora: TDateTime);
    procedure AtualizarStatusBalancaNoGrid(const AIDBalanca: Integer; const AOnline: Boolean; const AUltimoLog: string);

    { Callbacks do Monitor }
    procedure OnLogCallback(const ANivel: string; const AMsg: string);
    procedure OnStatusBalancaCallback(const AIDBalanca: Integer; const AOnline: Boolean; const AUltimoLog: string);
    procedure OnEstatisticaCallback(const ATotal: Integer; const ADataHora: TDateTime);

    { Callbacks da Micro-API REST }
    function RestOnSincronizar(const ATotal: Boolean): string;
    function RestOnObterStatus: string;
    function RestOnObterLogs: string;
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
  I: Integer;
  ParamMinimizado: Boolean;
begin
  FEncerrando := False;
  FJaIniciouMinimizado := False;
  FMonitorThread := nil;
  FServidorRest := nil;
  FBalancas := TObjectList<TConfigBalanca>.Create(True);
  FHistoricoLogs := TStringList.Create;
  FTotalItensHoje := 0;
  lblBadgeBuild.Caption := '⚡ Build ' + NUMERO_BUILD;

  ParamMinimizado := False;
  for I := 1 to ParamCount do
  begin
    if SameText(ParamStr(I), '/minimized') or SameText(ParamStr(I), '-minimized') then
      ParamMinimizado := True;
  end;

  AdicionarLog('INFO', 'Iniciando AtualizaBalança Enterprise...');

  IniciarServidorRest;
  AtualizarGridBalancas;

  try
    if DMConexao.Conectar then
    begin
      AdicionarLog('SUCESSO', 'Conectado ao Firebird: ' + DMConexao.CaminhoBanco);
      IniciarMonitoramento;
    end
    else
    begin
      AdicionarLog('ALERTA', 'Banco Firebird desconectado. Clique em "Conectar Banco" ou ajuste em Configurações.');
    end;
  except
    on E: Exception do
      AdicionarLog('ERRO', 'Falha ao conectar no Firebird: ' + E.Message);
  end;

  AtualizarStatusConexaoUI;

  if ParamMinimizado then
    FJaIniciouMinimizado := True;
end;

procedure TFrmPrincipal.AtualizarStatusConexaoUI;
begin
  if DMConexao.FDConnection.Connected then
  begin
    btnConectarBanco.Caption := 'Desconectar Banco';
    lblStatusServico.Caption := 'Banco: Conectado (' + DMConexao.Host + ')';
    lblStatusServico.Font.Color := clGreen;
  end
  else
  begin
    btnConectarBanco.Caption := 'Conectar Banco';
    lblStatusServico.Caption := 'Banco: Desconectado';
    lblStatusServico.Font.Color := clMaroon;
  end;
end;

procedure TFrmPrincipal.btnConectarBancoClick(Sender: TObject);
begin
  if DMConexao.FDConnection.Connected then
  begin
    if MessageDlg('Deseja desconectar do banco de dados Firebird e pausar o monitoramento?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      PararMonitoramento;
      DMConexao.Desconectar;
      AtualizarStatusConexaoUI;
      AdicionarLog('INFO', 'Desconectado do banco Firebird pelo operador.');
    end;
  end
  else
  begin
    Screen.Cursor := crHourGlass;
    try
      try
        if DMConexao.Conectar then
        begin
          AdicionarLog('SUCESSO', 'Conectado ao banco Firebird: ' + DMConexao.CaminhoBanco);
          AtualizarGridBalancas;
          IniciarMonitoramento;
          AtualizarStatusConexaoUI;
          ShowMessage('Conectado ao banco Firebird com sucesso!'#13#10'Monitoramento contínuo ativo.');
        end
        else
        begin
          AdicionarLog('ERRO', 'Não foi possível conectar ao Firebird. Verifique as configurações.');
          ShowMessage('Não foi possível conectar ao banco Firebird. Verifique o caminho e os parâmetros em Configurações.');
        end;
      except
        on E: Exception do
        begin
          AdicionarLog('ERRO', 'Erro ao conectar ao Firebird: ' + E.Message);
          ShowMessage('Erro ao conectar ao Firebird: ' + E.Message);
        end;
      end;
    finally
      AtualizarStatusConexaoUI;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  if FJaIniciouMinimizado then
  begin
    FJaIniciouMinimizado := False;
    Hide;
    TrayIcon.Visible := True;
  end;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  FEncerrando := True;
  PararServidorRest;
  PararMonitoramento;
  FreeAndNil(FBalancas);
  FreeAndNil(FHistoricoLogs);
end;

procedure TFrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not FEncerrando and DMConexao.MinimizarBandeja then
  begin
    CanClose := False;
    Hide;
    TrayIcon.Visible := True;
    TrayIcon.ShowBalloonHint;
  end
  else
    CanClose := True;
end;

procedure TFrmPrincipal.TrayIconDblClick(Sender: TObject);
begin
  Show;
  BringToFront;
end;

procedure TFrmPrincipal.mnAbrirClick(Sender: TObject);
begin
  Show;
  BringToFront;
end;

procedure TFrmPrincipal.mnSairClick(Sender: TObject);
begin
  FEncerrando := True;
  Close;
end;

procedure TFrmPrincipal.AdicionarLog(const ANivel: string; const AMensagem: string);
var
  Hora: string;
  Linha: string;
  PastaLogs, NomeArquivo: string;
  F: TextFile;
  DeveExibir: Boolean;
  FiltroIndex: Integer;
begin
  Hora := FormatDateTime('hh:nn:ss', Now);
  Linha := Format('[%s] [%-7s] %s', [Hora, ANivel, AMensagem]);

  if Assigned(FHistoricoLogs) then
  begin
    FHistoricoLogs.Add(ANivel + '|' + Linha);
    if FHistoricoLogs.Count > 3000 then
      FHistoricoLogs.Delete(0);
  end;

  FiltroIndex := 0;
  if Assigned(cbFiltroLog) and (cbFiltroLog.ItemIndex >= 0) then
    FiltroIndex := cbFiltroLog.ItemIndex;

  case FiltroIndex of
    1: DeveExibir := SameText(ANivel, 'ERRO');
    2: DeveExibir := SameText(ANivel, 'SUCESSO');
    3: DeveExibir := SameText(ANivel, 'ALERTA');
  else
    DeveExibir := True;
  end;

  if DeveExibir then
  begin
    mmoLogs.Lines.Add(Linha);
    if mmoLogs.Lines.Count > 1000 then
      mmoLogs.Lines.Delete(0);
  end;

  try
    PastaLogs := ExtractFilePath(ParamStr(0)) + 'Logs';
    if not DirectoryExists(PastaLogs) then
      CreateDir(PastaLogs);

    NomeArquivo := PastaLogs + PathDelim + 'Log_' + FormatDateTime('yyyy-mm-dd', Now) + '.log';
    AssignFile(F, NomeArquivo);
    try
      if FileExists(NomeArquivo) then
        Append(F)
      else
        Rewrite(F);
      WriteLn(F, Linha);
    finally
      CloseFile(F);
    end;
  except
    // Preserva integridade da execucao caso haja bloqueio de disco
  end;
end;

procedure TFrmPrincipal.cbFiltroLogChange(Sender: TObject);
var
  I, PosSep, FiltroIndex: Integer;
  ItemStr, Nivel, Linha: string;
  DeveExibir: Boolean;
begin
  if not Assigned(FHistoricoLogs) then
    Exit;

  FiltroIndex := cbFiltroLog.ItemIndex;
  mmoLogs.Lines.BeginUpdate;
  try
    mmoLogs.Lines.Clear;
    for I := 0 to FHistoricoLogs.Count - 1 do
    begin
      ItemStr := FHistoricoLogs[I];
      PosSep := Pos('|', ItemStr);
      if PosSep > 0 then
      begin
        Nivel := Copy(ItemStr, 1, PosSep - 1);
        Linha := Copy(ItemStr, PosSep + 1, Length(ItemStr));
      end
      else
      begin
        Nivel := '';
        Linha := ItemStr;
      end;

      case FiltroIndex of
        1: DeveExibir := SameText(Nivel, 'ERRO');
        2: DeveExibir := SameText(Nivel, 'SUCESSO');
        3: DeveExibir := SameText(Nivel, 'ALERTA');
      else
        DeveExibir := True;
      end;

      if DeveExibir then
        mmoLogs.Lines.Add(Linha);
    end;
  finally
    mmoLogs.Lines.EndUpdate;
  end;
end;

procedure TFrmPrincipal.AtualizarGridBalancas;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Bal: TConfigBalanca;
  Item: TListItem;
  Ativas: Integer;
begin
  lvBalancas.Items.Clear;
  Ativas := 0;
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.CarregarBalancas(FBalancas);
    for I := 0 to FBalancas.Count - 1 do
    begin
      Bal := FBalancas[I];
      if Bal.Ativo then
        Inc(Ativas);

      Item := lvBalancas.Items.Add;
      Item.Caption := IntToStr(Bal.ID);
      Item.SubItems.Add(Bal.Nome);
      Item.SubItems.Add(Bal.ObterDescricaoFabricante);
      Item.SubItems.Add(Bal.ObterDescricaoModelo);
      Item.SubItems.Add(Bal.IP);
      Item.SubItems.Add(IntToStr(Bal.Porta));
      Item.SubItems.Add(IntToStr(Bal.Setor));

      if Bal.Online then
        Item.SubItems.Add('Online')
      else
        Item.SubItems.Add('Aguardando');

      if Bal.UltimaSincronizacao > 0 then
        Item.SubItems.Add(DateTimeToStr(Bal.UltimaSincronizacao))
      else
        Item.SubItems.Add('Nunca');

      Item.SubItems.Add(Bal.UltimoLog);
      Item.Data := Bal;
    end;
  finally
    Repo.Free;
  end;

  lblCardBalancasVal.Caption := Format('%d / %d Ativas', [Ativas, FBalancas.Count]);
end;

procedure TFrmPrincipal.AtualizarStatusBalancaNoGrid(const AIDBalanca: Integer; const AOnline: Boolean; const AUltimoLog: string);
var
  I: Integer;
  Item: TListItem;
  Bal: TConfigBalanca;
begin
  for I := 0 to lvBalancas.Items.Count - 1 do
  begin
    Item := lvBalancas.Items[I];
    if Assigned(Item.Data) then
    begin
      Bal := TConfigBalanca(Item.Data);
      if Bal.ID = AIDBalanca then
      begin
        Bal.Online := AOnline;
        Bal.UltimaSincronizacao := Now;
        Bal.UltimoLog := AUltimoLog;

        while Item.SubItems.Count < 9 do
          Item.SubItems.Add('');

        if AOnline then
          Item.SubItems[6] := 'Online'
        else
          Item.SubItems[6] := 'Offline';

        Item.SubItems[7] := DateTimeToStr(Now);
        Item.SubItems[8] := AUltimoLog;
        Break;
      end;
    end;
  end;
end;

procedure TFrmPrincipal.AtualizarEstatisticas(const ATotal: Integer; const ADataHora: TDateTime);
begin
  FTotalItensHoje := ATotal;
  lblCardItensVal.Caption := IntToStr(FTotalItensHoje);
  if ADataHora > 0 then
    lblCardUltimaSyncVal.Caption := FormatDateTime('dd/mm hh:nn:ss', ADataHora)
  else
    lblCardUltimaSyncVal.Caption := 'Aguardando';
end;

procedure TFrmPrincipal.IniciarMonitoramento;
begin
  if Assigned(FMonitorThread) then
    Exit;

  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      AdicionarLog('ERRO', 'Não foi possível conectar ao banco Firebird para iniciar o serviço.');
      Exit;
    end;
  end;

  FMonitorThread := TThreadMonitorBalanca.Create(
    DMConexao.Host,
    DMConexao.Porta,
    DMConexao.CaminhoBanco,
    DMConexao.Usuario,
    DMConexao.Senha,
    DMConexao.IntervaloSyncSegundos,
    DMConexao.ModoFila,
    DMConexao.TelegramAtivo,
    DMConexao.TelegramToken,
    DMConexao.TelegramChatID,
    DMConexao.AgendamentoAtivo,
    DMConexao.HorarioCargaTotal
  );

  FMonitorThread.OnLog := OnLogCallback;
  FMonitorThread.OnStatusBalanca := OnStatusBalancaCallback;
  FMonitorThread.OnEstatistica := OnEstatisticaCallback;
  FMonitorThread.Start;

  lblStatusServico.Caption := 'Monitor: ATIVO';
  lblStatusServico.Font.Color := clGreen;
  lblCardStatusVal.Caption := 'ATIVO';
  lblCardStatusVal.Font.Color := clGreen;
  btnIniciarPausar.Caption := 'Pausar Monitoramento';
  mnIniciarPausar.Caption := 'Pausar Monitoramento';

  AdicionarLog('INFO', Format('Monitoramento automático iniciado (Intervalo: %ds).', [DMConexao.IntervaloSyncSegundos]));
end;

procedure TFrmPrincipal.PararMonitoramento;
begin
  if not Assigned(FMonitorThread) then
    Exit;

  AdicionarLog('INFO', 'Pausando monitoramento...');
  FMonitorThread.Terminate;
  FMonitorThread.WaitFor;
  FreeAndNil(FMonitorThread);

  lblStatusServico.Caption := 'Monitor: PAUSADO';
  lblStatusServico.Font.Color := clMaroon;
  lblCardStatusVal.Caption := 'PAUSADO';
  lblCardStatusVal.Font.Color := clMaroon;
  btnIniciarPausar.Caption := 'Iniciar Monitoramento';
  mnIniciarPausar.Caption := 'Iniciar Monitoramento';

  AdicionarLog('INFO', 'Monitoramento pausado pelo usuário.');
end;

procedure TFrmPrincipal.IniciarServidorRest;
begin
  if not DMConexao.ApiRestAtiva then
  begin
    lblStatusRest.Caption := 'API REST: Desativada';
    lblStatusRest.Font.Color := clGray;
    Exit;
  end;

  if Assigned(FServidorRest) then
    PararServidorRest;

  FServidorRest := TServidorRest.Create(DMConexao.ApiRestPorta);
  FServidorRest.OnSincronizar := RestOnSincronizar;
  FServidorRest.OnObterStatus := RestOnObterStatus;
  FServidorRest.OnObterLogs := RestOnObterLogs;

  if FServidorRest.Iniciar then
  begin
    lblStatusRest.Caption := Format('API REST: :%d Ativa', [DMConexao.ApiRestPorta]);
    lblStatusRest.Font.Color := clNavy;
    AdicionarLog('INFO', Format('Micro-API REST embutida ativa na porta %d (Endpoints: /status, /sincronizar, /carga-total, /logs)', [DMConexao.ApiRestPorta]));
  end
  else
  begin
    lblStatusRest.Caption := 'API REST: Erro';
    lblStatusRest.Font.Color := clRed;
    AdicionarLog('ERRO', Format('Não foi possível iniciar a API REST na porta %d (%s).', [DMConexao.ApiRestPorta, FServidorRest.UltimoErro]));
  end;
end;

procedure TFrmPrincipal.PararServidorRest;
begin
  if Assigned(FServidorRest) then
  begin
    FServidorRest.Parar;
    FreeAndNil(FServidorRest);
    lblStatusRest.Caption := 'API REST: Parada';
    lblStatusRest.Font.Color := clGray;
  end;
end;

function TFrmPrincipal.RestOnSincronizar(const ATotal: Boolean): string;
begin
  if Assigned(FMonitorThread) then
  begin
    FMonitorThread.ForcarSincronizacao(ATotal);
    if ATotal then
      Result := '{"sucesso":true,"mensagem":"Carga total disparada via API REST."}'
    else
      Result := '{"sucesso":true,"mensagem":"Sincronizacao de alterados disparada via API REST."}';
  end
  else
    Result := '{"sucesso":false,"mensagem":"O servico de monitoramento esta pausado no momento."}';
end;

function TFrmPrincipal.RestOnObterStatus: string;
var
  Repo: TRepositoryBalanca;
  BalancasJSON: string;
  StatusMonitor: string;
begin
  if Assigned(FMonitorThread) then
    StatusMonitor := 'ativo'
  else
    StatusMonitor := 'pausado';

  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  try
    BalancasJSON := Repo.ObterStatusBalancasJSON;
  finally
    Repo.Free;
  end;

  Result := Format(
    '{"sistema":"GoUp AtualizaBalanca","status":"online","monitor":"%s","total_hoje":%d,"ultima_sync":"%s",%s',
    [StatusMonitor, FTotalItensHoje, DateTimeToStr(Now), Copy(BalancasJSON, 2, Length(BalancasJSON))]
  );
end;

function TFrmPrincipal.RestOnObterLogs: string;
var
  Repo: TRepositoryBalanca;
begin
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  try
    Result := Repo.ObterUltimosLogsJSON(50);
  finally
    Repo.Free;
  end;
end;

procedure TFrmPrincipal.OnLogCallback(const ANivel: string; const AMsg: string);
begin
  AdicionarLog(ANivel, AMsg);
end;

procedure TFrmPrincipal.OnStatusBalancaCallback(const AIDBalanca: Integer; const AOnline: Boolean; const AUltimoLog: string);
begin
  AtualizarStatusBalancaNoGrid(AIDBalanca, AOnline, AUltimoLog);
end;

procedure TFrmPrincipal.OnEstatisticaCallback(const ATotal: Integer; const ADataHora: TDateTime);
begin
  AtualizarEstatisticas(ATotal, ADataHora);
end;

procedure TFrmPrincipal.btnIniciarPausarClick(Sender: TObject);
begin
  if Assigned(FMonitorThread) then
    PararMonitoramento
  else
    IniciarMonitoramento;
end;

procedure TFrmPrincipal.btnConfiguracoesClick(Sender: TObject);
var
  Frm: TFrmConfig;
  EstavaAtivo: Boolean;
begin
  EstavaAtivo := Assigned(FMonitorThread);
  if EstavaAtivo then
    PararMonitoramento;

  Frm := TFrmConfig.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;

  AtualizarGridBalancas;
  AtualizarStatusConexaoUI;
  IniciarServidorRest;

  if EstavaAtivo and DMConexao.FDConnection.Connected then
    IniciarMonitoramento;
end;

procedure TFrmPrincipal.btnValidarPLUsClick(Sender: TObject);
var
  Diagnostico: TStringList;
  Erros: Integer;
  TotalExportado: Integer;
begin
  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      AdicionarLog('ERRO', 'Não foi possível conectar ao banco Firebird para diagnóstico.');
      ShowMessage('Não foi possível conectar ao banco Firebird. Verifique as configurações.');
      Exit;
    end;
  end;

  Diagnostico := TStringList.Create;
  Screen.Cursor := crHourGlass;
  try
    Erros := TValidadorBalanca.ExecutarDiagnosticoCompleto(DMConexao.FDConnection, Diagnostico);
    mmoLogs.Lines.AddStrings(Diagnostico);

    if Erros > 0 then
    begin
      if MessageDlg(Format('Diagnóstico concluído: foram detectados %d problemas nos cadastros de PLUs.'#13#10 +
                           'Consulte a caixa de logs para ver a lista detalhada.'#13#10#13#10 +
                           'Deseja exportar a planilha de inconsistências (CSV / Excel)?', [Erros]),
                    mtWarning, [mbYes, mbNo], 0) = mrYes then
      begin
        SaveDialogCSV.Title := 'Salvar Relatório de Diagnóstico de PLUs';
        SaveDialogCSV.Filter := 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*';
        SaveDialogCSV.DefaultExt := 'csv';
        SaveDialogCSV.FileName := Format('Diagnostico_PLUs_%s.csv', [FormatDateTime('yyyy-mm-dd_hhnn', Now)]);

        if SaveDialogCSV.Execute then
        begin
          if TValidadorBalanca.ExportarDiagnosticoCSV(DMConexao.FDConnection, SaveDialogCSV.FileName, TotalExportado) then
          begin
            AdicionarLog('SUCESSO', 'Planilha de inconsistências exportada com sucesso: ' + SaveDialogCSV.FileName);
            if MessageDlg('Planilha gerada com sucesso!'#13#10'Deseja abrir o arquivo agora no Excel / visualizador padrão?',
                          mtConfirmation, [mbYes, mbNo], 0) = mrYes then
              ShellExecute(0, 'open', PChar(SaveDialogCSV.FileName), nil, nil, SW_SHOWNORMAL);
          end
          else
            AdicionarLog('ERRO', 'Falha ao gravar arquivo CSV de diagnóstico.');
        end;
      end;
    end
    else
      ShowMessage('Diagnóstico concluído: Todos os PLUs cadastrados estão íntegros e sem conflitos!');
  finally
    Diagnostico.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmPrincipal.btnCargaAlteradosClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
  Produtos: TObjectList<TProdutoPLU>;
  ProdutosSetor: TObjectList<TProdutoPLU>;
  IDsFila: TList<Integer>;
  Bal: TConfigBalanca;
  Driver: IBalancaComunicador;
  Resultado: TResultadoEnvio;
  I, J: Integer;
begin
  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      AdicionarLog('ERRO', 'Não foi possível conectar ao banco Firebird.');
      ShowMessage('Não foi possível conectar ao banco Firebird. Verifique as configurações.');
      Exit;
    end;
  end;

  Screen.Cursor := crHourGlass;
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  Produtos := TObjectList<TProdutoPLU>.Create(True);
  ProdutosSetor := TObjectList<TProdutoPLU>.Create(False);
  IDsFila := TList<Integer>.Create;
  try
    AdicionarLog('INFO', 'Buscando produtos alterados manualmente...');
    if DMConexao.ModoFila then
      Repo.ObterProdutosAlteradosFila(Produtos, 0, IDsFila)
    else
      Repo.ObterProdutosAlteradosTimestamp(Produtos, Now - (1 / 24), 0);

    if Produtos.Count = 0 then
    begin
      AdicionarLog('INFO', 'Nenhum produto alterado pendente de sincronização.');
      ShowMessage('Nenhum produto alterado pendente no momento.');
      Exit;
    end;

    AdicionarLog('INFO', Format('Iniciando envio manual de %d itens...', [Produtos.Count]));

    for I := 0 to FBalancas.Count - 1 do
    begin
      Bal := FBalancas[I];
      if not Bal.Ativo then
        Continue;

      ProdutosSetor.Clear;
      for J := 0 to Produtos.Count - 1 do
      begin
        if (Bal.Setor = 0) or (Produtos[J].Setor = Bal.Setor) then
          ProdutosSetor.Add(Produtos[J]);
      end;

      if ProdutosSetor.Count = 0 then
        Continue;

      Driver := TFabricaComunicador.CriarComunicador(Bal);
      Resultado := Driver.EnviarProdutos(ProdutosSetor);

      if Resultado.Sucesso then
      begin
        Inc(FTotalItensHoje, Resultado.QuantidadeItens);
        AdicionarLog('SUCESSO', Format('[%s] %s', [Bal.Nome, Resultado.Mensagem]));
        AtualizarStatusBalancaNoGrid(Bal.ID, True, Resultado.Mensagem);
        Repo.RegistrarLogEnvio(Bal.ID, Resultado.QuantidadeItens, 'S', Resultado.TempoMs, Resultado.Mensagem);
      end
      else
      begin
        AdicionarLog('ERRO', Format('[%s] %s', [Bal.Nome, Resultado.Mensagem]));
        AtualizarStatusBalancaNoGrid(Bal.ID, False, Resultado.Mensagem);
        Repo.RegistrarLogEnvio(Bal.ID, 0, 'E', Resultado.TempoMs, Resultado.Mensagem);
      end;
    end;

    if DMConexao.ModoFila and (IDsFila.Count > 0) then
      Repo.MarcarFilaProcessada(IDsFila, 'SINCRONIZADO MANUALMENTE COM SUCESSO');

    AtualizarEstatisticas(FTotalItensHoje, Now);
    ShowMessage('Sincronização manual concluída!');
  finally
    IDsFila.Free;
    ProdutosSetor.Free;
    Produtos.Free;
    Repo.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmPrincipal.btnCargaTotalClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
  Produtos: TObjectList<TProdutoPLU>;
  ProdutosSetor: TObjectList<TProdutoPLU>;
  Bal: TConfigBalanca;
  Driver: IBalancaComunicador;
  Resultado: TResultadoEnvio;
  I, J: Integer;
begin
  if MessageDlg('Atenção: A Carga Total enviará TODOS os produtos de balança cadastrados.'#13#10 +
                'Deseja continuar?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      AdicionarLog('ERRO', 'Não foi possível conectar ao banco Firebird.');
      ShowMessage('Não foi possível conectar ao banco Firebird. Verifique as configurações.');
      Exit;
    end;
  end;

  Screen.Cursor := crHourGlass;
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  Produtos := TObjectList<TProdutoPLU>.Create(True);
  ProdutosSetor := TObjectList<TProdutoPLU>.Create(False);
  try
    AdicionarLog('INFO', 'Carregando banco completo de produtos de balança...');
    Repo.ObterTodosProdutosBalanca(Produtos, 0);

    if Produtos.Count = 0 then
    begin
      AdicionarLog('ALERTA', 'Nenhum produto cadastrado com código de balança (PRD_BALANCA_CODIGO > 0).');
      ShowMessage('Nenhum produto com código de balança cadastrado no sistema.');
      Exit;
    end;

    AdicionarLog('INFO', Format('Total de %d produtos encontrados. Transmitindo para as balanças...', [Produtos.Count]));

    for I := 0 to FBalancas.Count - 1 do
    begin
      Bal := FBalancas[I];
      if not Bal.Ativo then
        Continue;

      ProdutosSetor.Clear;
      for J := 0 to Produtos.Count - 1 do
      begin
        if (Bal.Setor = 0) or (Produtos[J].Setor = Bal.Setor) then
          ProdutosSetor.Add(Produtos[J]);
      end;

      if ProdutosSetor.Count = 0 then
        Continue;

      AdicionarLog('INFO', Format('Enviando carga completa para [%s] (%d itens)...', [Bal.Nome, ProdutosSetor.Count]));
      Driver := TFabricaComunicador.CriarComunicador(Bal);
      Resultado := Driver.EnviarProdutos(ProdutosSetor);

      if Resultado.Sucesso then
      begin
        AdicionarLog('SUCESSO', Format('[%s] Carga total concluída: %s', [Bal.Nome, Resultado.Mensagem]));
        AtualizarStatusBalancaNoGrid(Bal.ID, True, Resultado.Mensagem);
        Repo.RegistrarLogEnvio(Bal.ID, Resultado.QuantidadeItens, 'S', Resultado.TempoMs, Resultado.Mensagem);
      end
      else
      begin
        AdicionarLog('ERRO', Format('[%s] Falha na carga total: %s', [Bal.Nome, Resultado.Mensagem]));
        AtualizarStatusBalancaNoGrid(Bal.ID, False, Resultado.Mensagem);
        Repo.RegistrarLogEnvio(Bal.ID, 0, 'E', Resultado.TempoMs, Resultado.Mensagem);
      end;
    end;

    AtualizarEstatisticas(FTotalItensHoje + Produtos.Count, Now);
    ShowMessage('Carga total transmitida com sucesso!');
  finally
    ProdutosSetor.Free;
    Produtos.Free;
    Repo.Free;
    Screen.Cursor := crDefault;
  end;
end;

type
  TTesteBalancaWorker = class
  public
    Balanca: TConfigBalanca;
    Online: Boolean;
    Msg: string;
    constructor Create(ABalanca: TConfigBalanca);
    destructor Destroy; override;
    procedure Executar;
  end;

constructor TTesteBalancaWorker.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  Balanca := TConfigBalanca.Create;
  Balanca.ID := ABalanca.ID;
  Balanca.Nome := ABalanca.Nome;
  Balanca.IP := ABalanca.IP;
  Balanca.Porta := ABalanca.Porta;
  Balanca.Fabricante := ABalanca.Fabricante;
  Balanca.Modelo := ABalanca.Modelo;
  Balanca.Ativo := ABalanca.Ativo;
  Balanca.Setor := ABalanca.Setor;
  Online := False;
  Msg := '';
end;

destructor TTesteBalancaWorker.Destroy;
begin
  Balanca.Free;
  inherited Destroy;
end;

procedure TTesteBalancaWorker.Executar;
var
  Driver: IBalancaComunicador;
begin
  try
    Driver := TFabricaComunicador.CriarComunicador(Balanca);
    if Driver.TestarConectividade then
    begin
      Online := True;
      Msg := 'Conexão OK';
    end
    else
    begin
      Online := False;
      Msg := 'Falha de conexão / Offline';
    end;
  except
    on E: Exception do
    begin
      Online := False;
      Msg := 'Erro: ' + E.Message;
    end;
  end;
end;

procedure TFrmPrincipal.btnTestarConexoesClick(Sender: TObject);
var
  Workers: TObjectList<TTesteBalancaWorker>;
  Tarefas: TArray<ITask>;
  I: Integer;
  Bal: TConfigBalanca;
  Worker: TTesteBalancaWorker;
begin
  if FBalancas.Count = 0 then
  begin
    AdicionarLog('ALERTA', 'Nenhuma balança cadastrada para testar conexões.');
    ShowMessage('Nenhuma balança cadastrada. Acesse Configurações para cadastrar balanças.');
    Exit;
  end;

  AdicionarLog('INFO', 'Testando conectividade de rede com todas as balanças em paralelo...');
  Screen.Cursor := crHourGlass;
  Workers := TObjectList<TTesteBalancaWorker>.Create(True);
  try
    for I := 0 to FBalancas.Count - 1 do
    begin
      Bal := FBalancas[I];
      if Bal.Ativo then
        Workers.Add(TTesteBalancaWorker.Create(Bal));
    end;

    if Workers.Count = 0 then
    begin
      AdicionarLog('ALERTA', 'Nenhuma balança ativa encontrada no cadastro.');
      Exit;
    end;

    SetLength(Tarefas, Workers.Count);
    for I := 0 to Workers.Count - 1 do
    begin
      Worker := Workers[I];
      Tarefas[I] := TTask.Run(
        procedure
        begin
          Worker.Executar;
        end
      );
    end;

    TTask.WaitForAll(Tarefas, 5000);

    for I := 0 to Workers.Count - 1 do
    begin
      Worker := Workers[I];
      if Worker.Online then
      begin
        AdicionarLog('SUCESSO', Format('Balança [%s] (%s:%d) está ONLINE e respondendo.', [Worker.Balanca.Nome, Worker.Balanca.IP, Worker.Balanca.Porta]));
        AtualizarStatusBalancaNoGrid(Worker.Balanca.ID, True, Worker.Msg);
      end
      else
      begin
        AdicionarLog('ERRO', Format('Balança [%s] (%s:%d) está OFFLINE ou inacessível.', [Worker.Balanca.Nome, Worker.Balanca.IP, Worker.Balanca.Porta]));
        AtualizarStatusBalancaNoGrid(Worker.Balanca.ID, False, Worker.Msg);
      end;
    end;
  finally
    Workers.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmPrincipal.btnLimparLogClick(Sender: TObject);
begin
  if Assigned(FHistoricoLogs) then
    FHistoricoLogs.Clear;
  mmoLogs.Clear;
  AdicionarLog('INFO', 'Log limpo pelo operador.');
end;

procedure TFrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F1:
    begin
      Key := 0;
      lblBadgeBuildClick(Self);
    end;
    VK_F2:
    begin
      Key := 0;
      btnCadastroProdutosClick(Self);
    end;
    VK_F5:
    begin
      Key := 0;
      btnCargaAlteradosClick(Self);
    end;
    VK_F6:
    begin
      Key := 0;
      btnCargaTotalClick(Self);
    end;
    VK_F7:
    begin
      Key := 0;
      btnCompararAlteracoesClick(Self);
    end;
    VK_F8:
    begin
      Key := 0;
      btnTestarConexoesClick(Self);
    end;
    VK_F9:
    begin
      Key := 0;
      btnEditorEtiquetasClick(Self);
    end;
    VK_F10:
    begin
      Key := 0;
      btnRelatoriosGestaoClick(Self);
    end;
    VK_F12:
    begin
      Key := 0;
      btnConfiguracoesClick(Self);
    end;
  end;
end;

procedure TFrmPrincipal.btnCopiarLogClick(Sender: TObject);
begin
  if mmoLogs.Lines.Count = 0 then
  begin
    ShowMessage('Não há registros de log para copiar no momento.');
    Exit;
  end;

  Clipboard.AsText := mmoLogs.Text;
  AdicionarLog('INFO', 'Logs copiados para a área de transferência com sucesso.');
  ShowMessage('Todo o histórico de logs foi copiado para a área de transferência!');
end;

procedure TFrmPrincipal.lvBalancasDblClick(Sender: TObject);
begin
  mnTestarBalancaIndividualClick(Sender);
end;

procedure TFrmPrincipal.mnTestarBalancaIndividualClick(Sender: TObject);
var
  Bal: TConfigBalanca;
  Driver: IBalancaComunicador;
  Conectou: Boolean;
begin
  if lvBalancas.Selected = nil then
  begin
    ShowMessage('Selecione uma balança na lista para testar a conexão.');
    Exit;
  end;

  if Assigned(lvBalancas.Selected.Data) then
  begin
    Bal := TConfigBalanca(lvBalancas.Selected.Data);
    Screen.Cursor := crHourGlass;
    try
      AdicionarLog('INFO', Format('Testando conectividade direta com [%s] (%s:%d)...', [Bal.Nome, Bal.IP, Bal.Porta]));
      Driver := TFabricaComunicador.CriarComunicador(Bal);
      Conectou := Driver.TestarConectividade;

      if Conectou then
      begin
        AdicionarLog('SUCESSO', Format('Balança [%s] está ONLINE e respondendo perfeitamente.', [Bal.Nome]));
        AtualizarStatusBalancaNoGrid(Bal.ID, True, 'Conexão OK');
        ShowMessage(Format('Balança "%s" (%s:%d) está ONLINE e respondendo com sucesso!', [Bal.Nome, Bal.IP, Bal.Porta]));
      end
      else
      begin
        AdicionarLog('ERRO', Format('Balança [%s] (%s:%d) está OFFLINE ou inacessível na rede.', [Bal.Nome, Bal.IP, Bal.Porta]));
        AtualizarStatusBalancaNoGrid(Bal.ID, False, 'Falha de conexão');
        ShowMessage(Format('Atenção: Balança "%s" (%s:%d) está OFFLINE ou inacessível no momento.'#13#10 +
                           'Verifique o cabo de rede, Wi-Fi e o endereço IP cadastrado.', [Bal.Nome, Bal.IP, Bal.Porta]));
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TFrmPrincipal.mnCargaBalancaIndividualClick(Sender: TObject);
var
  Bal: TConfigBalanca;
  Repo: TRepositoryBalanca;
  Produtos: TObjectList<TProdutoPLU>;
  ProdutosSetor: TObjectList<TProdutoPLU>;
  Driver: IBalancaComunicador;
  Resultado: TResultadoEnvio;
  J: Integer;
begin
  if lvBalancas.Selected = nil then
  begin
    ShowMessage('Selecione uma balança na lista.');
    Exit;
  end;

  if not Assigned(lvBalancas.Selected.Data) then
    Exit;

  Bal := TConfigBalanca(lvBalancas.Selected.Data);

  if MessageDlg(Format('Deseja enviar a carga de produtos exclusivamente para a balança "%s" (%s:%d)?',
                       [Bal.Nome, Bal.IP, Bal.Porta]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if not DMConexao.FDConnection.Connected then
  begin
    if not DMConexao.Conectar then
    begin
      AdicionarLog('ERRO', 'Não foi possível conectar ao banco Firebird.');
      ShowMessage('Não foi possível conectar ao banco Firebird. Verifique as configurações.');
      Exit;
    end;
  end;

  Screen.Cursor := crHourGlass;
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  Produtos := TObjectList<TProdutoPLU>.Create(True);
  ProdutosSetor := TObjectList<TProdutoPLU>.Create(False);
  try
    AdicionarLog('INFO', Format('Carregando cadastro de produtos para [%s]...', [Bal.Nome]));
    Repo.ObterTodosProdutosBalanca(Produtos, 0);

    for J := 0 to Produtos.Count - 1 do
    begin
      if (Bal.Setor = 0) or (Produtos[J].Setor = Bal.Setor) then
        ProdutosSetor.Add(Produtos[J]);
    end;

    if ProdutosSetor.Count = 0 then
    begin
      AdicionarLog('ALERTA', Format('Nenhum produto cadastrado para o setor da balança [%s].', [Bal.Nome]));
      ShowMessage('Nenhum produto encontrado para o setor desta balança.');
      Exit;
    end;

    AdicionarLog('INFO', Format('Enviando carga para [%s] (%d itens)...', [Bal.Nome, ProdutosSetor.Count]));
    Driver := TFabricaComunicador.CriarComunicador(Bal);
    Resultado := Driver.EnviarProdutos(ProdutosSetor);

    if Resultado.Sucesso then
    begin
      AdicionarLog('SUCESSO', Format('[%s] Carga individual enviada com sucesso: %s', [Bal.Nome, Resultado.Mensagem]));
      AtualizarStatusBalancaNoGrid(Bal.ID, True, Resultado.Mensagem);
      Repo.RegistrarLogEnvio(Bal.ID, Resultado.QuantidadeItens, 'S', Resultado.TempoMs, Resultado.Mensagem);
      ShowMessage(Format('Carga enviada com sucesso para [%s]!'#13#10'%s', [Bal.Nome, Resultado.Mensagem]));
    end
    else
    begin
      AdicionarLog('ERRO', Format('[%s] Falha no envio da carga: %s', [Bal.Nome, Resultado.Mensagem]));
      AtualizarStatusBalancaNoGrid(Bal.ID, False, Resultado.Mensagem);
      Repo.RegistrarLogEnvio(Bal.ID, 0, 'E', Resultado.TempoMs, Resultado.Mensagem);
      ShowMessage(Format('Falha ao enviar carga para [%s]:'#13#10'%s', [Bal.Nome, Resultado.Mensagem]));
    end;
  finally
    ProdutosSetor.Free;
    Produtos.Free;
    Repo.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmPrincipal.mnPropriedadesBalancaClick(Sender: TObject);
begin
  btnConfiguracoesClick(Sender);
end;

procedure TFrmPrincipal.btnCompararAlteracoesClick(Sender: TObject);
var
  Frm: TFrmComparador;
begin
  Frm := TFrmComparador.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
  AtualizarGridBalancas;
end;

procedure TFrmPrincipal.mnLimparMemoriaBalancaClick(Sender: TObject);
var
  Bal: TConfigBalanca;
  Driver: IBalancaComunicador;
  Resultado: TResultadoEnvio;
begin
  if lvBalancas.Selected = nil then
  begin
    ShowMessage('Selecione uma balança na lista para apagar os dados.');
    Exit;
  end;

  if not Assigned(lvBalancas.Selected.Data) then
    Exit;

  Bal := TConfigBalanca(lvBalancas.Selected.Data);

  if MessageDlg(Format('⚠️ ATENÇÃO: Você está prestes a APAGAR todos os produtos gravados na memória da balança "%s" (%s:%d).'#13#10#13#10 +
                       'Essa operação enviará o comando de zeramento direto via rede para a balança.'#13#10#13#10 +
                       'Tem certeza absoluta que deseja prosseguir com a limpeza da memória?', [Bal.Nome, Bal.IP, Bal.Porta]),
                mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    AdicionarLog('INFO', Format('Enviando comando de zeramento direto para [%s] (%s:%d)...', [Bal.Nome, Bal.IP, Bal.Porta]));
    Driver := TFabricaComunicador.CriarComunicador(Bal);
    Resultado := Driver.LimparBalanca;

    if Resultado.Sucesso then
    begin
      AdicionarLog('SUCESSO', Format('[%s] %s', [Bal.Nome, Resultado.Mensagem]));
      AtualizarStatusBalancaNoGrid(Bal.ID, True, 'Memória Zerada');

      if MessageDlg(Format('A memória da balança "%s" foi zerada com sucesso!'#13#10#13#10 +
                           'Deseja transmitir uma Carga Total limpa agora para esta balança?', [Bal.Nome]),
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        mnCargaBalancaIndividualClick(Sender);
      end;
    end
    else
    begin
      AdicionarLog('ERRO', Format('[%s] %s', [Bal.Nome, Resultado.Mensagem]));
      AtualizarStatusBalancaNoGrid(Bal.ID, False, 'Falha ao zerar');
      ShowMessage(Format('Falha ao zerar dados da balança [%s]:'#13#10'%s', [Bal.Nome, Resultado.Mensagem]));
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmPrincipal.lblBadgeBuildClick(Sender: TObject);
var
  Frm: TFrmSobreNovidades;
begin
  Frm := TFrmSobreNovidades.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrincipal.mnVerTabelaNutricionalClick(Sender: TObject);
var
  Frm: TFrmNutricional;
  Bal: TConfigBalanca;
  Repo: TRepositoryBalanca;
  ListaProdutos: TObjectList<TProdutoPLU>;
  ProdExibicao: TProdutoPLU;
  CriouProdLocal: Boolean;
begin
  if lvBalancas.Selected = nil then
  begin
    ShowMessage('Selecione uma balança na lista para visualizar a Tabela Nutricional.');
    Exit;
  end;

  Bal := nil;
  if Assigned(lvBalancas.Selected.Data) then
    Bal := TConfigBalanca(lvBalancas.Selected.Data);

  ProdExibicao := nil;
  CriouProdLocal := False;
  ListaProdutos := nil;

  if (Bal <> nil) and DMConexao.FDConnection.Connected then
  begin
    Repo := TRepositoryBalanca.Create(nil);
    try
      ListaProdutos := TObjectList<TProdutoPLU>.Create(True);
      Repo.ObterTodosProdutosBalanca(ListaProdutos, Bal.Setor);
      if ListaProdutos.Count > 0 then
        ProdExibicao := ListaProdutos[0];
    finally
      Repo.Free;
    end;
  end;

  if ProdExibicao = nil then
  begin
    ProdExibicao := TProdutoPLU.Create;
    CriouProdLocal := True;
    ProdExibicao.CodigoPLU := 101;
    ProdExibicao.CodigoBarras := '7891234567890';
    ProdExibicao.Descricao := 'Bolo Recheado de Chocolate Premium (Amostra RDC 429)';
    ProdExibicao.PrecoVenda := 29.90;
    ProdExibicao.ValidadeDias := 5;
    ProdExibicao.Nutricional.PorcaoQtde := 60;
    ProdExibicao.Nutricional.PorcaoUnidade := 'g';
    ProdExibicao.Nutricional.ValorEnergetico := 220;
    ProdExibicao.Nutricional.Carboidratos := 32.0;
    ProdExibicao.Nutricional.AcucaresTotais := 19.5;
    ProdExibicao.Nutricional.AcucaresAdicionados := 16.0;
    ProdExibicao.Nutricional.Proteinas := 3.8;
    ProdExibicao.Nutricional.GordurasTotais := 8.5;
    ProdExibicao.Nutricional.GordurasSaturadas := 4.2;
    ProdExibicao.Nutricional.GordurasTrans := 0.0;
    ProdExibicao.Nutricional.FibraAlimentar := 1.5;
    ProdExibicao.Nutricional.Sodio := 180.0;
  end;

  Frm := TFrmNutricional.Create(Self);
  try
    Frm.CarregarProduto(ProdExibicao);
    Frm.ShowModal;
  finally
    Frm.Free;
    if CriouProdLocal then
      ProdExibicao.Free
    else if Assigned(ListaProdutos) then
      ListaProdutos.Free;
  end;
end;

procedure TFrmPrincipal.btnEditorEtiquetasClick(Sender: TObject);
var
  Frm: TFrmEditorEtiquetas;
begin
  Frm := TFrmEditorEtiquetas.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrincipal.btnCadastroProdutosClick(Sender: TObject);
var
  Frm: TFrmCadastroProdutos;
begin
  Frm := TFrmCadastroProdutos.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrincipal.btnRelatoriosGestaoClick(Sender: TObject);
var
  Frm: TFrmRelatoriosGestao;
begin
  Frm := TFrmRelatoriosGestao.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrincipal.mnEditorEtiquetaBalancaClick(Sender: TObject);
var
  Frm: TFrmEditorEtiquetas;
  Bal: TConfigBalanca;
begin
  Frm := TFrmEditorEtiquetas.Create(Self);
  try
    if (lvBalancas.Selected <> nil) and Assigned(lvBalancas.Selected.Data) then
    begin
      Bal := TConfigBalanca(lvBalancas.Selected.Data);
      Frm.SelecionarBalancaPorID(Bal.ID);
    end;
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

end.