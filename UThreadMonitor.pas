unit UThreadMonitor;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UThreadMonitor.pas: Thread de Monitoramento, Alertas Telegram e Agendamento }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Phys.FB,
  FireDAC.VCLUI.Wait,
  UModelBalanca,
  URepositoryBalanca,
  UComunicadorBalanca,
  UServicoNotificacao,
  System.Threading;

type
  TOnLogEvent = procedure(const ANivel: string; const AMensagem: string) of object;
  TOnStatusBalancaEvent = procedure(const AIDBalanca: Integer; const AOnline: Boolean; const AUltimoLog: string) of object;
  TOnEstatisticaEvent = procedure(const ATotalEnviado: Integer; const AUltimaDataHora: TDateTime) of object;

  TThreadMonitorBalanca = class(TThread)
  private
    FHost: string;
    FPorta: Integer;
    FCaminhoBanco: string;
    FUsuario: string;
    FSenha: string;
    FIntervaloSegundos: Integer;
    FModoFila: Boolean;
    FUltimaVerificacao: TDateTime;
    FTotalHoje: Integer;

    { Notificações Telegram / Webhook }
    FTelegramAtivo: Boolean;
    FTelegramToken: string;
    FTelegramChatID: string;

    { Agendamento de Carga Total Diária }
    FAgendamentoAtivo: Boolean;
    FHorarioCargaTotal: string; { Ex: '23:00' }
    FUltimaDataCargaTotal: TDateTime;

    { Forçar sincronização imediata por demanda (REST ou botão) }
    FForcarCargaImediata: Boolean;
    FForcarCargaTotal: Boolean;

    FFalhasConsecutivas: TDictionary<Integer, Integer>;

    FOnLog: TOnLogEvent;
    FOnStatusBalanca: TOnStatusBalancaEvent;
    FOnEstatistica: TOnEstatisticaEvent;

    FLogMsg: string;
    FLogNivel: string;
    FStatusID: Integer;
    FStatusOnline: Boolean;
    FStatusLog: string;

    procedure SincronizarLog;
    procedure SincronizarStatus;
    procedure SincronizarEstatistica;
    procedure DispararLog(const ANivel: string; const AMsg: string);
    procedure DispararStatus(const AID: Integer; const AOnline: Boolean; const ALog: string);
    function CriarConexaoThread: TFDConnection;
    procedure VerificarAgendamentoCargaTotal;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; const APorta: Integer; const ACaminhoBanco: string;
      const AUsuario: string; const ASenha: string; const AIntervaloSegundos: Integer;
      const AModoFila: Boolean; const ATelegramAtivo: Boolean; const ATelegramToken: string;
      const ATelegramChatID: string; const AAgendamentoAtivo: Boolean; const AHorarioCargaTotal: string);
    destructor Destroy; override;

    procedure ForcarSincronizacao(const ACargaTotal: Boolean);

    property OnLog: TOnLogEvent read FOnLog write FOnLog;
    property OnStatusBalanca: TOnStatusBalancaEvent read FOnStatusBalanca write FOnStatusBalanca;
    property OnEstatistica: TOnEstatisticaEvent read FOnEstatistica write FOnEstatistica;
  end;

implementation

type
  TEnvioBalancaWorker = class
  public
    Balanca: TConfigBalanca;
    Produtos: TObjectList<TProdutoPLU>;
    Resultado: TResultadoEnvio;
    constructor Create(ABalanca: TConfigBalanca);
    destructor Destroy; override;
  end;

constructor TEnvioBalancaWorker.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  Balanca := ABalanca;
  Produtos := TObjectList<TProdutoPLU>.Create(False);
end;

destructor TEnvioBalancaWorker.Destroy;
begin
  Produtos.Free;
  inherited Destroy;
end;

{ TThreadMonitorBalanca }

constructor TThreadMonitorBalanca.Create(const AHost: string; const APorta: Integer;
  const ACaminhoBanco: string; const AUsuario: string; const ASenha: string;
  const AIntervaloSegundos: Integer; const AModoFila: Boolean; const ATelegramAtivo: Boolean;
  const ATelegramToken: string; const ATelegramChatID: string; const AAgendamentoAtivo: Boolean;
  const AHorarioCargaTotal: string);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FFalhasConsecutivas := TDictionary<Integer, Integer>.Create;
  FHost := AHost;
  FPorta := APorta;
  FCaminhoBanco := ACaminhoBanco;
  FUsuario := AUsuario;
  FSenha := ASenha;
  FIntervaloSegundos := AIntervaloSegundos;
  if FIntervaloSegundos < 5 then
    FIntervaloSegundos := 5;
  FModoFila := AModoFila;
  FTelegramAtivo := ATelegramAtivo;
  FTelegramToken := ATelegramToken;
  FTelegramChatID := ATelegramChatID;
  FAgendamentoAtivo := AAgendamentoAtivo;
  FHorarioCargaTotal := AHorarioCargaTotal;
  FUltimaDataCargaTotal := 0;

  FForcarCargaImediata := False;
  FForcarCargaTotal := False;

  FUltimaVerificacao := Now - (1 / 24);
  FTotalHoje := 0;
end;

destructor TThreadMonitorBalanca.Destroy;
begin
  FreeAndNil(FFalhasConsecutivas);
  inherited Destroy;
end;

function TThreadMonitorBalanca.CriarConexaoThread: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.Params.Clear;
  Result.Params.DriverID := 'FB';
  Result.Params.Database := FCaminhoBanco;
  Result.Params.UserName := FUsuario;
  Result.Params.Password := FSenha;
  Result.Params.Values['Server'] := FHost;
  Result.Params.Values['Port'] := IntToStr(FPorta);
  Result.Params.Values['CharacterSet'] := 'WIN1252';
  Result.LoginPrompt := False;
end;

procedure TThreadMonitorBalanca.SincronizarLog;
begin
  if Assigned(FOnLog) then
    FOnLog(FLogNivel, FLogMsg);
end;

procedure TThreadMonitorBalanca.SincronizarStatus;
begin
  if Assigned(FOnStatusBalanca) then
    FOnStatusBalanca(FStatusID, FStatusOnline, FStatusLog);
end;

procedure TThreadMonitorBalanca.SincronizarEstatistica;
begin
  if Assigned(FOnEstatistica) then
    FOnEstatistica(FTotalHoje, FUltimaVerificacao);
end;

procedure TThreadMonitorBalanca.DispararLog(const ANivel: string; const AMsg: string);
begin
  FLogNivel := ANivel;
  FLogMsg := AMsg;
  Synchronize(SincronizarLog);
end;

procedure TThreadMonitorBalanca.DispararStatus(const AID: Integer; const AOnline: Boolean; const ALog: string);
begin
  FStatusID := AID;
  FStatusOnline := AOnline;
  FStatusLog := ALog;
  Synchronize(SincronizarStatus);
end;

procedure TThreadMonitorBalanca.ForcarSincronizacao(const ACargaTotal: Boolean);
begin
  if ACargaTotal then
    FForcarCargaTotal := True
  else
    FForcarCargaImediata := True;
end;

procedure TThreadMonitorBalanca.VerificarAgendamentoCargaTotal;
var
  HoraAtualStr: string;
begin
  if not FAgendamentoAtivo or (Trim(FHorarioCargaTotal) = '') then
    Exit;

  HoraAtualStr := FormatDateTime('hh:nn', Now);
  if (HoraAtualStr = FHorarioCargaTotal) and (Trunc(FUltimaDataCargaTotal) < Trunc(Now)) then
  begin
    FUltimaDataCargaTotal := Now;
    FForcarCargaTotal := True;
    DispararLog('INFO', Format('⏰ Horário agendado (%s) atingido. Iniciando Carga Total Noturna...', [FHorarioCargaTotal]));
  end;
end;

procedure TThreadMonitorBalanca.Execute;
var
  Conn: TFDConnection;
  Repo: TRepositoryBalanca;
  Balancas: TObjectList<TConfigBalanca>;
  ProdutosAlterados: TObjectList<TProdutoPLU>;
  IDsFila: TList<Integer>;
  Resultado: TResultadoEnvio;
  Balanca: TConfigBalanca;
  I, J, FalhasQtd: Integer;
  SegundosContados: Integer;
  DataExecucao: TDateTime;
  EhCargaTotal: Boolean;
  Workers: TObjectList<TEnvioBalancaWorker>;
  Worker, CurrentWorker: TEnvioBalancaWorker;
  Tarefas: array of ITask;
begin
  DispararLog('INFO', 'Serviço de monitoramento contínuo de balanças iniciado.');

  Conn := CriarConexaoThread;
  try
    try
      Conn.Connected := True;
    except
      on E: Exception do
      begin
        DispararLog('ERRO', 'Falha ao conectar no banco Firebird: ' + E.Message);
        Exit;
      end;
    end;

    Repo := TRepositoryBalanca.Create(Conn);
    Balancas := TObjectList<TConfigBalanca>.Create(True);
    ProdutosAlterados := TObjectList<TProdutoPLU>.Create(True);
    IDsFila := TList<Integer>.Create;
    try
      while not Terminated do
      begin
        try
          DataExecucao := Now;

          { Verifica se atingiu o horário agendado de carga total }
          VerificarAgendamentoCargaTotal;

          EhCargaTotal := FForcarCargaTotal;
          FForcarCargaTotal := False;
          FForcarCargaImediata := False;

          { 1. Carrega balanças ativas }
          Repo.CarregarBalancas(Balancas);

          { 2. Busca produtos }
          if EhCargaTotal then
          begin
            DispararLog('INFO', 'Executando Carga Total em todas as balanças ativas...');
            Repo.ObterTodosProdutosBalanca(ProdutosAlterados, 0);
          end
          else if FModoFila then
            Repo.ObterProdutosAlteradosFila(ProdutosAlterados, 0, IDsFila)
          else
            Repo.ObterProdutosAlteradosTimestamp(ProdutosAlterados, FUltimaVerificacao, 0);

          if ProdutosAlterados.Count > 0 then
          begin
            DispararLog('INFO', Format('Processando %d produto(s) para transmissão...', [ProdutosAlterados.Count]));

            Workers := TObjectList<TEnvioBalancaWorker>.Create(True);
            try
              { 1. Prepara a lista de balanças e filtra os produtos do setor }
              for I := 0 to Balancas.Count - 1 do
              begin
                Balanca := Balancas[I];
                if not Balanca.Ativo then
                  Continue;

                Worker := TEnvioBalancaWorker.Create(Balanca);
                for J := 0 to ProdutosAlterados.Count - 1 do
                begin
                  if (Balanca.Setor = 0) or (ProdutosAlterados[J].Setor = Balanca.Setor) then
                    Worker.Produtos.Add(ProdutosAlterados[J]);
                end;

                if Worker.Produtos.Count > 0 then
                  Workers.Add(Worker)
                else
                  Worker.Free;
              end;

              { 2. Executa a transmissão TCP de todas as balanças em PARALELO e ISOLADO }
              if Workers.Count > 0 then
              begin
                SetLength(Tarefas, Workers.Count);
                for I := 0 to Workers.Count - 1 do
                begin
                  CurrentWorker := Workers[I];
                  Tarefas[I] := TTask.Run(
                    procedure
                    var
                      Driver: IBalancaComunicador;
                    begin
                      try
                        Driver := TFabricaComunicador.CriarComunicador(CurrentWorker.Balanca);
                        CurrentWorker.Resultado := Driver.EnviarProdutos(CurrentWorker.Produtos);
                      except
                        on E: Exception do
                        begin
                          CurrentWorker.Resultado.Sucesso := False;
                          CurrentWorker.Resultado.Mensagem := 'Falha na transmissão: ' + E.Message;
                          CurrentWorker.Resultado.QuantidadeItens := 0;
                          CurrentWorker.Resultado.TempoMs := 0;
                        end;
                      end;
                    end
                  );
                end;

                { Aguarda a conclusão de todas as balanças com timeout global de 10s }
                TTask.WaitForAll(Tarefas, 10000);

                { 3. Registra os resultados e atualiza status no banco Firebird }
                for I := 0 to Workers.Count - 1 do
                begin
                  CurrentWorker := Workers[I];
                  Balanca := CurrentWorker.Balanca;
                  Resultado := CurrentWorker.Resultado;

                  if Resultado.Sucesso then
                  begin
                    if FFalhasConsecutivas.TryGetValue(Balanca.ID, FalhasQtd) and (FalhasQtd >= 3) then
                    begin
                      if FTelegramAtivo then
                        TServicoNotificacao.EnviarTelegram(FTelegramToken, FTelegramChatID,
                          Format('✅ <b>[GoUp AtualizaBalança]</b> A balança <b>"%s"</b> (IP %s) recuperou a conexão e está ONLINE!',
                            [Balanca.Nome, Balanca.IP]));
                    end;

                    FFalhasConsecutivas.AddOrSetValue(Balanca.ID, 0);
                    Inc(FTotalHoje, Resultado.QuantidadeItens);
                    DispararLog('SUCESSO', Format('[%s] %s (%d ms)', [Balanca.Nome, Resultado.Mensagem, Resultado.TempoMs]));
                    DispararStatus(Balanca.ID, True, Resultado.Mensagem);
                    Repo.AtualizarStatusBalanca(Balanca.ID, True, Resultado.Mensagem);
                    Repo.RegistrarLogEnvio(Balanca.ID, Resultado.QuantidadeItens, 'S', Resultado.TempoMs, Resultado.Mensagem);
                  end
                  else
                  begin
                    if not FFalhasConsecutivas.TryGetValue(Balanca.ID, FalhasQtd) then
                      FalhasQtd := 0;
                    Inc(FalhasQtd);
                    FFalhasConsecutivas.AddOrSetValue(Balanca.ID, FalhasQtd);

                    DispararLog('ERRO', Format('[%s] Falha no envio: %s', [Balanca.Nome, Resultado.Mensagem]));
                    DispararStatus(Balanca.ID, False, Resultado.Mensagem);
                    Repo.AtualizarStatusBalanca(Balanca.ID, False, Resultado.Mensagem);
                    Repo.RegistrarLogEnvio(Balanca.ID, 0, 'E', Resultado.TempoMs, Resultado.Mensagem);

                    if FTelegramAtivo and (FalhasQtd = 3) then
                    begin
                      TServicoNotificacao.EnviarTelegram(FTelegramToken, FTelegramChatID,
                        Format('⚠️ <b>[GoUp AtualizaBalança] ALERTA:</b>'#10 +
                               'A balança <b>"%s"</b> (IP: <code>%s:%d</code>) está <b>OFFLINE</b> ou não respondeu a 3 tentativas consecutivas!'#10 +
                               'Verifique o cabo de rede ou a alimentação da balança.',
                          [Balanca.Nome, Balanca.IP, Balanca.Porta]));
                    end;
                  end;
                end;
              end;
            finally
              Workers.Free;
            end;

            { Marca fila como processada se não for carga total manual }
            if not EhCargaTotal and FModoFila and (IDsFila.Count > 0) then
              Repo.MarcarFilaProcessada(IDsFila, 'SINCRONIZADO COM SUCESSO');
          end;

          FUltimaVerificacao := DataExecucao;
          Synchronize(SincronizarEstatistica);
        except
          on E: Exception do
            DispararLog('ERRO', 'Erro no monitoramento: ' + E.Message);
        end;

        { Intervalo configurado ou interrupção imediata se solicitado }
        SegundosContados := 0;
        while (not Terminated) and (not FForcarCargaImediata) and (not FForcarCargaTotal) and (SegundosContados < FIntervaloSegundos) do
        begin
          Sleep(1000);
          Inc(SegundosContados);
        end;
      end;
    finally
      IDsFila.Free;
      ProdutosAlterados.Free;
      Balancas.Free;
      Repo.Free;
    end;
  finally
    Conn.Free;
  end;

  DispararLog('INFO', 'Serviço de monitoramento finalizado.');
end;

end.