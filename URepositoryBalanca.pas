unit URepositoryBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  URepositoryBalanca.pas: Repositório de Acesso a Dados FireDAC e INI         }
{  Arquitetura Não-Intrusiva: Banco de Dados em Modo Somente Leitura (Read-Only)}
{  Nenhuma tabela, trigger ou generator é criado no Firebird do ERP.           }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.StrUtils,
  System.Generics.Collections,
  System.SyncObjs,
  System.IOUtils,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  UModelBalanca;

type
  TRepositoryBalanca = class
  private
    FConnection: TFDConnection;
    procedure PreencherProdutoPLU(AQry: TFDQuery; AItem: TProdutoPLU);
    class var FLogLock: TCriticalSection;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    constructor Create(AConnection: TFDConnection);

    { Gerenciamento de Balanças (Persistência em Arquivo INI / CONF) }
    procedure CarregarBalancas(ALista: TObjectList<TConfigBalanca>);
    procedure SalvarBalanca(ABalanca: TConfigBalanca);
    procedure ExcluirBalanca(const AID: Integer);
    procedure AtualizarStatusBalanca(const AID: Integer; const AOnline: Boolean; const AUltimoLog: string);

    { Consulta de Produtos (Acesso Somente Leitura ao Firebird) }
    procedure ObterProdutosAlteradosFila(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer; var AIDsFila: TList<Integer>);
    procedure ObterProdutosAlteradosTimestamp(ALista: TObjectList<TProdutoPLU>; const ADataCorte: TDateTime; const ASetor: Integer);
    procedure ObterTodosProdutosBalanca(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer);

    { Auditoria e Logs Locais (Arquivo de Texto em Disco) }
    procedure MarcarFilaProcessada(AIDsFila: TList<Integer>; const ALog: string);
    procedure RegistrarLogEnvio(const AIDBalanca: Integer; const AItens: Integer; const AStatus: string; const ATempoMs: Cardinal; const AMsg: string);
    function ObterUltimosLogsJSON(const AQtd: Integer = 50): string;
    function ObterStatusBalancasJSON: string;
  end;

implementation

uses
  UDMConexao;

{ TRepositoryBalanca }

class constructor TRepositoryBalanca.CreateClass;
begin
  FLogLock := TCriticalSection.Create;
end;

class destructor TRepositoryBalanca.DestroyClass;
begin
  FreeAndNil(FLogLock);
end;

constructor TRepositoryBalanca.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure TRepositoryBalanca.CarregarBalancas(ALista: TObjectList<TConfigBalanca>);
begin
  if Assigned(DMConexao) then
    DMConexao.CarregarBalancasINI(ALista);
end;

procedure TRepositoryBalanca.SalvarBalanca(ABalanca: TConfigBalanca);
var
  Lista: TObjectList<TConfigBalanca>;
  I: Integer;
  Encontrou: Boolean;
  NovoItem: TConfigBalanca;
begin
  if not Assigned(ABalanca) or not Assigned(DMConexao) then
    Exit;

  Lista := TObjectList<TConfigBalanca>.Create(True);
  try
    DMConexao.CarregarBalancasINI(Lista);
    Encontrou := False;

    for I := 0 to Lista.Count - 1 do
    begin
      if (ABalanca.ID > 0) and (Lista[I].ID = ABalanca.ID) then
      begin
        Lista[I].Nome := ABalanca.Nome;
        Lista[I].Fabricante := ABalanca.Fabricante;
        Lista[I].Modelo := ABalanca.Modelo;
        Lista[I].IP := ABalanca.IP;
        Lista[I].Porta := ABalanca.Porta;
        Lista[I].Setor := ABalanca.Setor;
        Lista[I].Ativo := ABalanca.Ativo;
        Lista[I].CaminhoDLL := ABalanca.CaminhoDLL;
        Encontrou := True;
        Break;
      end;
    end;

    if not Encontrou then
    begin
      NovoItem := TConfigBalanca.Create;
      NovoItem.ID := Lista.Count + 1;
      NovoItem.Nome := ABalanca.Nome;
      NovoItem.Fabricante := ABalanca.Fabricante;
      NovoItem.Modelo := ABalanca.Modelo;
      NovoItem.IP := ABalanca.IP;
      NovoItem.Porta := ABalanca.Porta;
      NovoItem.Setor := ABalanca.Setor;
      NovoItem.Ativo := ABalanca.Ativo;
      NovoItem.CaminhoDLL := ABalanca.CaminhoDLL;
      Lista.Add(NovoItem);
      ABalanca.ID := NovoItem.ID;
    end;

    DMConexao.SalvarBalancasINI(Lista);
  finally
    Lista.Free;
  end;
end;

procedure TRepositoryBalanca.ExcluirBalanca(const AID: Integer);
var
  Lista: TObjectList<TConfigBalanca>;
  I: Integer;
begin
  if (AID <= 0) or not Assigned(DMConexao) then
    Exit;

  Lista := TObjectList<TConfigBalanca>.Create(True);
  try
    DMConexao.CarregarBalancasINI(Lista);
    for I := Lista.Count - 1 downto 0 do
    begin
      if Lista[I].ID = AID then
      begin
        Lista.Delete(I);
        Break;
      end;
    end;
    DMConexao.SalvarBalancasINI(Lista);
  finally
    Lista.Free;
  end;
end;

procedure TRepositoryBalanca.AtualizarStatusBalanca(const AID: Integer; const AOnline: Boolean; const AUltimoLog: string);
begin
  { Status mantido em memória e registrado via log local }
end;

procedure TRepositoryBalanca.PreencherProdutoPLU(AQry: TFDQuery; AItem: TProdutoPLU);
begin
  AItem.ID := AQry.FieldByName('PRD_ID').AsInteger;
  AItem.CodigoPLU := AQry.FieldByName('PRD_BALANCA_CODIGO').AsInteger;
  AItem.CodigoBarras := Trim(AQry.FieldByName('PRD_CODIGO').AsString);
  AItem.Descricao := Trim(AQry.FieldByName('PRD_DESCRICAO').AsString);
  AItem.DescricaoCurta := Trim(AQry.FieldByName('PRD_DESCRICAO_CURTA').AsString);
  if AItem.DescricaoCurta = '' then
    AItem.DescricaoCurta := Copy(AItem.Descricao, 1, 25);

  AItem.PrecoVenda := AQry.FieldByName('PRD_PRECO_VENDA').AsCurrency;
  AItem.ValidadeDias := AQry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger;
  if AQry.FieldByName('PRD_BALANCA_TIPO').AsInteger = 1 then
    AItem.TipoVenda := tvUnidade
  else
    AItem.TipoVenda := tvPeso;

  AItem.TeclaAcesso := AQry.FieldByName('PRD_BALANCA_TECLA').AsInteger;
  AItem.Setor := AQry.FieldByName('PRD_SETOR').AsInteger;
  AItem.Ativo := (AQry.FieldByName('PRD_STATUS').AsString = 'A');
  AItem.UltimaAlteracao := AQry.FieldByName('PRD_ULTIMA_ALTERACAO').AsDateTime;

  { Informações de Receita / Ingredientes / Alergênicos }
  AItem.Receita := Trim(AQry.FieldByName('PRD_INFADPROD').AsString);
  AItem.Alergenicos := Trim(AQry.FieldByName('PRD_OBS_RESUMIDA').AsString);

  { Informações Nutricionais Completas (RDC 429) }
  if not AQry.FieldByName('PRDN_PRODUTO').IsNull then
  begin
    AItem.Nutricional.PorcaoQtde := AQry.FieldByName('PRDN_PORCAO_QTDE').AsInteger;
    AItem.Nutricional.ValorEnergetico := AQry.FieldByName('PRDN_VALOR_ENERGETICO').AsInteger;
    AItem.Nutricional.Carboidratos := AQry.FieldByName('PRDN_CARBOIDRATO').AsFloat;
    AItem.Nutricional.AcucaresTotais := AQry.FieldByName('PRDN_ACUCAR_TOTAL').AsFloat;
    AItem.Nutricional.AcucaresAdicionados := AQry.FieldByName('PRDN_ACUCAR_ADICIONADO').AsFloat;
    AItem.Nutricional.Proteinas := AQry.FieldByName('PRDN_PROTEINA').AsFloat;
    AItem.Nutricional.GordurasTotais := AQry.FieldByName('PRDN_GORDURA_TOTAL').AsFloat;
    AItem.Nutricional.GordurasSaturadas := AQry.FieldByName('PRDN_GORDURA_SATURADA').AsFloat;
    AItem.Nutricional.GordurasTrans := AQry.FieldByName('PRDN_GORDURA_TRANS').AsFloat;
    AItem.Nutricional.FibraAlimentar := AQry.FieldByName('PRDN_FIBRA').AsFloat;
    AItem.Nutricional.Sodio := AQry.FieldByName('PRDN_SODIO').AsFloat;
  end;
end;

procedure TRepositoryBalanca.ObterProdutosAlteradosFila(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer; var AIDsFila: TList<Integer>);
var
  DataCorte: TDateTime;
  IntervaloDias: Double;
begin
  AIDsFila.Clear;
  if Assigned(DMConexao) and (DMConexao.IntervaloSyncSegundos > 0) then
    IntervaloDias := DMConexao.IntervaloSyncSegundos / 86400.0
  else
    IntervaloDias := 30.0 / 86400.0;

  DataCorte := Now - IntervaloDias;
  ObterProdutosAlteradosTimestamp(ALista, DataCorte, ASetor);
end;

procedure TRepositoryBalanca.ObterProdutosAlteradosTimestamp(ALista: TObjectList<TProdutoPLU>; const ADataCorte: TDateTime; const ASetor: Integer);
var
  Qry: TFDQuery;
  Item: TProdutoPLU;
begin
  ALista.Clear;
  if not Assigned(FConnection) or not FConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_DESCRICAO_CURTA, ' +
      '  P.PRD_PRECO_VENDA, ' +
      '  P.PRD_BALANCA_VALIDADE, ' +
      '  P.PRD_BALANCA_TIPO, ' +
      '  P.PRD_BALANCA_TECLA, ' +
      '  P.PRD_SETOR, ' +
      '  P.PRD_STATUS, ' +
      '  P.PRD_ULTIMA_ALTERACAO, ' +
      '  P.PRD_INFADPROD, ' +
      '  P.PRD_OBS_RESUMIDA, ' +
      '  N.PRDN_PRODUTO, ' +
      '  N.PRDN_PORCAO_QTDE, ' +
      '  N.PRDN_VALOR_ENERGETICO, ' +
      '  N.PRDN_CARBOIDRATO, ' +
      '  N.PRDN_ACUCAR_TOTAL, ' +
      '  N.PRDN_ACUCAR_ADICIONADO, ' +
      '  N.PRDN_PROTEINA, ' +
      '  N.PRDN_GORDURA_TOTAL, ' +
      '  N.PRDN_GORDURA_SATURADA, ' +
      '  N.PRDN_GORDURA_TRANS, ' +
      '  N.PRDN_FIBRA, ' +
      '  N.PRDN_SODIO ' +
      'FROM TB_PRODUTO P ' +
      'LEFT JOIN TB_PRODUTO_NUTRICIONAL N ON (N.PRDN_PRODUTO = P.PRD_ID) ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_ULTIMA_ALTERACAO >= :CORTE ' +
      '  AND (:SETOR = 0 OR P.PRD_SETOR = :SETOR) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.ParamByName('CORTE').AsDateTime := ADataCorte;
    Qry.ParamByName('SETOR').AsInteger := ASetor;
    Qry.Open;

    while not Qry.Eof do
    begin
      Item := TProdutoPLU.Create;
      PreencherProdutoPLU(Qry, Item);
      ALista.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoryBalanca.ObterTodosProdutosBalanca(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer);
var
  Qry: TFDQuery;
  Item: TProdutoPLU;
begin
  ALista.Clear;
  if not Assigned(FConnection) or not FConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_DESCRICAO_CURTA, ' +
      '  P.PRD_PRECO_VENDA, ' +
      '  P.PRD_BALANCA_VALIDADE, ' +
      '  P.PRD_BALANCA_TIPO, ' +
      '  P.PRD_BALANCA_TECLA, ' +
      '  P.PRD_SETOR, ' +
      '  P.PRD_STATUS, ' +
      '  P.PRD_ULTIMA_ALTERACAO, ' +
      '  P.PRD_INFADPROD, ' +
      '  P.PRD_OBS_RESUMIDA, ' +
      '  N.PRDN_PRODUTO, ' +
      '  N.PRDN_PORCAO_QTDE, ' +
      '  N.PRDN_VALOR_ENERGETICO, ' +
      '  N.PRDN_CARBOIDRATO, ' +
      '  N.PRDN_ACUCAR_TOTAL, ' +
      '  N.PRDN_ACUCAR_ADICIONADO, ' +
      '  N.PRDN_PROTEINA, ' +
      '  N.PRDN_GORDURA_TOTAL, ' +
      '  N.PRDN_GORDURA_SATURADA, ' +
      '  N.PRDN_GORDURA_TRANS, ' +
      '  N.PRDN_FIBRA, ' +
      '  N.PRDN_SODIO ' +
      'FROM TB_PRODUTO P ' +
      'LEFT JOIN TB_PRODUTO_NUTRICIONAL N ON (N.PRDN_PRODUTO = P.PRD_ID) ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND (:SETOR = 0 OR P.PRD_SETOR = :SETOR) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.ParamByName('SETOR').AsInteger := ASetor;
    Qry.Open;

    while not Qry.Eof do
    begin
      Item := TProdutoPLU.Create;
      PreencherProdutoPLU(Qry, Item);
      ALista.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoryBalanca.MarcarFilaProcessada(AIDsFila: TList<Integer>; const ALog: string);
begin
  { Arquitetura baseada em timestamp: dispensada gravação em tabela de fila }
end;

procedure TRepositoryBalanca.RegistrarLogEnvio(const AIDBalanca: Integer; const AItens: Integer; const AStatus: string; const ATempoMs: Cardinal; const AMsg: string);
var
  CaminhoLog: string;
  Linha: string;
  Balancas: TObjectList<TConfigBalanca>;
  NomeBalanca: string;
  I: Integer;
begin
  NomeBalanca := Format('Balança #%d', [AIDBalanca]);
  if Assigned(DMConexao) then
  begin
    Balancas := TObjectList<TConfigBalanca>.Create(True);
    try
      DMConexao.CarregarBalancasINI(Balancas);
      for I := 0 to Balancas.Count - 1 do
      begin
        if Balancas[I].ID = AIDBalanca then
        begin
          NomeBalanca := Balancas[I].Nome;
          Break;
        end;
      end;
    finally
      Balancas.Free;
    end;
  end;

  Linha := Format('%s|%d|%s|%d|%s|%d|%s', [
    FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
    AIDBalanca,
    NomeBalanca,
    AItens,
    AStatus,
    ATempoMs,
    AMsg
  ]);

  CaminhoLog := ExtractFilePath(ParamStr(0)) + 'AtualizaBalanca.log';

  FLogLock.Enter;
  try
    try
      TFile.AppendAllText(CaminhoLog, Linha + sLineBreak, TEncoding.UTF8);
    except
      { Não bloqueia execução se houver concorrência temporária no arquivo }
    end;
  finally
    FLogLock.Leave;
  end;
end;

function TRepositoryBalanca.ObterUltimosLogsJSON(const AQtd: Integer): string;
var
  CaminhoLog: string;
  Linhas: TStringDynArray;
  JSON: string;
  Primeiro: Boolean;
  I, Inicio, Contador: Integer;
  Partes: TArray<string>;
begin
  CaminhoLog := ExtractFilePath(ParamStr(0)) + 'AtualizaBalanca.log';
  JSON := '{"logs":[';
  Primeiro := True;

  FLogLock.Enter;
  try
    if TFile.Exists(CaminhoLog) then
    begin
      Linhas := TFile.ReadAllLines(CaminhoLog, TEncoding.UTF8);
      Contador := Length(Linhas);
      if Contador > AQtd then
        Inicio := Contador - AQtd
      else
        Inicio := 0;

      for I := Contador - 1 downto Inicio do
      begin
        if Trim(Linhas[I]) = '' then
          Continue;

        Partes := Linhas[I].Split(['|']);
        if Length(Partes) >= 7 then
        begin
          if not Primeiro then
            JSON := JSON + ',';
          Primeiro := False;

          JSON := JSON + Format(
            '{"id":%d,"data_hora":"%s","balanca":"%s","itens":%s,"status":"%s","tempo_ms":%s,"mensagem":"%s"}',
            [I + 1,
             Partes[0],
             Partes[2],
             Partes[3],
             Partes[4],
             Partes[5],
             Partes[6]]
          );
        end;
      end;
    end;
  finally
    FLogLock.Leave;
  end;

  JSON := JSON + ']}';
  Result := JSON;
end;

function TRepositoryBalanca.ObterStatusBalancasJSON: string;
var
  Lista: TObjectList<TConfigBalanca>;
  JSON: string;
  Primeiro: Boolean;
  I: Integer;
  Bal: TConfigBalanca;
begin
  JSON := '{"balancas":[';
  Primeiro := True;

  if Assigned(DMConexao) then
  begin
    Lista := TObjectList<TConfigBalanca>.Create(True);
    try
      DMConexao.CarregarBalancasINI(Lista);
      for I := 0 to Lista.Count - 1 do
      begin
        Bal := Lista[I];
        if not Primeiro then
          JSON := JSON + ',';
        Primeiro := False;

        JSON := JSON + Format(
          '{"id":%d,"nome":"%s","fabricante":"%s","modelo":"%s","ip":"%s","porta":%d,"setor":%d,"ativo":"%s","ultima_sync":"%s","ultimo_log":"%s"}',
          [Bal.ID,
           Bal.Nome,
           Bal.ObterDescricaoFabricante,
           Bal.ObterDescricaoModelo,
           Bal.IP,
           Bal.Porta,
           Bal.Setor,
           IfThen(Bal.Ativo, 'S', 'N'),
           FormatDateTime('yyyy-mm-dd hh:nn:ss', Bal.UltimaSincronizacao),
           Bal.UltimoLog]
        );
      end;
    finally
      Lista.Free;
    end;
  end;

  JSON := JSON + ']}';
  Result := JSON;
end;

end.