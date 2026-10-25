unit UProtocoloToledo;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UProtocoloToledo.pas: Driver Toledo Prix (4, 5, 6) com Nutricional RDC 429  }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  Winapi.Windows,
  IdTCPClient,
  IdGlobal,
  UModelBalanca,
  UComunicadorBalanca;

type
  { Ponteiros para funções exportadas das DLLs oficiais Toledo (P05.dll / CargaBal.dll) }
  TToledoAbrePorta = function(Porta: Integer; Velocidade: Integer): Integer; stdcall;
  TToledoFechaPorta = function: Integer; stdcall;
  TToledoEnviaCarga = function(CaminhoArquivo: PAnsiChar; IPBalanca: PAnsiChar; Porta: Integer): Integer; stdcall;

  TProtocoloToledo = class(TInterfacedObject, IBalancaComunicador)
  private
    FBalanca: TConfigBalanca;
    FTCPClient: TIdTCPClient;
    FDLLHandle: HMODULE;

    FToledoAbrePorta: TToledoAbrePorta;
    FToledoFechaPorta: TToledoFechaPorta;
    FToledoEnviaCarga: TToledoEnviaCarga;

    procedure CarregarDLLToledoSeExistir;
    procedure DescarregarDLLToledo;
    function AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
    function EnviarViaSocketDireto(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
    function EnviarViaDLLOficial(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
  public
    constructor Create(ABalanca: TConfigBalanca);
    destructor Destroy; override;

    function Conectar: Boolean;
    procedure Desconectar;
    function TestarConectividade: Boolean;
    function EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
    function LimparBalanca: TResultadoEnvio;
    function ObterNomeDriver: string;

    { Geração de Arquivos Padrão Toledo (Itens, Informação Nutricional e Receitas) }
    procedure GerarArquivoItensAut(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
    procedure GerarArquivoNutricional(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
    procedure GerarArquivoReceitas(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
  end;

implementation

{ TProtocoloToledo }

constructor TProtocoloToledo.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  FBalanca := ABalanca;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := 3000;
  FTCPClient.ReadTimeout := 3000;
  FDLLHandle := 0;

  CarregarDLLToledoSeExistir;
end;

destructor TProtocoloToledo.Destroy;
begin
  Desconectar;
  DescarregarDLLToledo;
  FreeAndNil(FTCPClient);
  inherited Destroy;
end;

procedure TProtocoloToledo.CarregarDLLToledoSeExistir;
var
  CaminhoDLL: string;
begin
  FToledoAbrePorta := nil;
  FToledoFechaPorta := nil;
  FToledoEnviaCarga := nil;

  CaminhoDLL := FBalanca.CaminhoDLL;
  if (CaminhoDLL = '') or not FileExists(CaminhoDLL) then
    CaminhoDLL := ExtractFilePath(ParamStr(0)) + 'P05.dll';

  if FileExists(CaminhoDLL) then
  begin
    FDLLHandle := LoadLibrary(PChar(CaminhoDLL));
    if FDLLHandle <> 0 then
    begin
      @FToledoAbrePorta := GetProcAddress(FDLLHandle, 'AbrePorta');
      @FToledoFechaPorta := GetProcAddress(FDLLHandle, 'FechaPorta');
      @FToledoEnviaCarga := GetProcAddress(FDLLHandle, 'EnviaCarga');
    end;
  end;
end;

procedure TProtocoloToledo.DescarregarDLLToledo;
begin
  if FDLLHandle <> 0 then
  begin
    FreeLibrary(FDLLHandle);
    FDLLHandle := 0;
  end;
end;

function TProtocoloToledo.AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
var
  S: string;
begin
  S := Trim(ATexto);
  if Length(S) > ATamanho then
    Result := Copy(S, 1, ATamanho)
  else
    Result := S + StringOfChar(' ', ATamanho - Length(S));
end;

function TProtocoloToledo.Conectar: Boolean;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;

    FTCPClient.Host := FBalanca.IP;
    FTCPClient.Port := FBalanca.Porta;
    FTCPClient.Connect;
    Result := FTCPClient.Connected;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TProtocoloToledo.Desconectar;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
  except
    // Ignora erros na desconexão
  end;
end;

function TProtocoloToledo.TestarConectividade: Boolean;
begin
  Result := Conectar;
  if Result then
    Desconectar;
end;

procedure TProtocoloToledo.GerarArquivoItensAut(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
var
  SL: TStringList;
  I: Integer;
  P: TProdutoPLU;
  SetorStr: string;
  TipoStr: string;
  CodigoStr: string;
  PrecoStr: string;
  ValidadeStr: string;
  DescricaoStr: string;
  Linha: string;
begin
  SL := TStringList.Create;
  try
    for I := 0 to AProdutos.Count - 1 do
    begin
      P := AProdutos[I];

      if P.Setor > 0 then
        SetorStr := Format('%.2d', [P.Setor])
      else
        SetorStr := '01';

      if P.TipoVenda = tvPeso then
        TipoStr := '0'
      else
        TipoStr := '1';

      CodigoStr := Format('%.6d', [P.CodigoPLU]);
      PrecoStr := Format('%.6d', [Round(P.PrecoVenda * 100)]);
      ValidadeStr := Format('%.3d', [P.ValidadeDias]);
      DescricaoStr := AjustarTexto(P.DescricaoCurta, 25);

      Linha := SetorStr + TipoStr + CodigoStr + PrecoStr + ValidadeStr + DescricaoStr;
      SL.Add(Linha);
    end;
    SL.SaveToFile(ACaminhoArquivo, TEncoding.ANSI);
  finally
    SL.Free;
  end;
end;

procedure TProtocoloToledo.GerarArquivoNutricional(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
var
  SL: TStringList;
  I: Integer;
  P: TProdutoPLU;
  N: TInfoNutricional;
  Linha: string;
begin
  SL := TStringList.Create;
  try
    for I := 0 to AProdutos.Count - 1 do
    begin
      P := AProdutos[I];
      N := P.Nutricional;
      if (N.ValorEnergetico > 0) or (N.Carboidratos > 0) or (N.Proteinas > 0) then
      begin
        { Layout Nutricional Toledo RDC 429:
          PLU(6) + Porção(3) + Unidade(2) + Energetico(4) + Carboidratos(4) + AcucarTotal(4) +
          AcucarAdicionado(4) + Proteinas(4) + GordurasTotais(4) + GordurasSat(4) + GordurasTrans(4) + Fibras(4) + Sodio(4) }
        Linha := Format('%.6d', [P.CodigoPLU]) +
                 Format('%.3d', [N.PorcaoQtde]) +
                 AjustarTexto(N.PorcaoUnidade, 2) +
                 Format('%.4d', [N.ValorEnergetico]) +
                 Format('%.4d', [Round(N.Carboidratos * 10)]) +
                 Format('%.4d', [Round(N.AcucaresTotais * 10)]) +
                 Format('%.4d', [Round(N.AcucaresAdicionados * 10)]) +
                 Format('%.4d', [Round(N.Proteinas * 10)]) +
                 Format('%.4d', [Round(N.GordurasTotais * 10)]) +
                 Format('%.4d', [Round(N.GordurasSaturadas * 10)]) +
                 Format('%.4d', [Round(N.GordurasTrans * 10)]) +
                 Format('%.4d', [Round(N.FibraAlimentar * 10)]) +
                 Format('%.4d', [Round(N.Sodio)]);
        SL.Add(Linha);
      end;
    end;
    if SL.Count > 0 then
      SL.SaveToFile(ACaminhoArquivo, TEncoding.ANSI);
  finally
    SL.Free;
  end;
end;

procedure TProtocoloToledo.GerarArquivoReceitas(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
var
  SL: TStringList;
  I: Integer;
  P: TProdutoPLU;
  TextoExtra: string;
  Linha: string;
begin
  SL := TStringList.Create;
  try
    for I := 0 to AProdutos.Count - 1 do
    begin
      P := AProdutos[I];
      TextoExtra := Trim(P.Receita);
      if P.Alergenicos <> '' then
      begin
        if TextoExtra <> '' then
          TextoExtra := TextoExtra + ' | ';
        TextoExtra := TextoExtra + 'ALÉRGICOS: ' + P.Alergenicos;
      end;

      if TextoExtra <> '' then
      begin
        { Layout Receita / Informação Adicional Toledo: PLU(6) + Texto da Receita / Alergênicos }
        Linha := Format('%.6d', [P.CodigoPLU]) + Copy(TextoExtra, 1, 500);
        SL.Add(Linha);
      end;
    end;
    if SL.Count > 0 then
      SL.SaveToFile(ACaminhoArquivo, TEncoding.ANSI);
  finally
    SL.Free;
  end;
end;

function TProtocoloToledo.EnviarViaDLLOficial(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  ArquivoTemp: string;
  RetornoDLL: Integer;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  StopWatch := TStopwatch.StartNew;
  ArquivoTemp := ExtractFilePath(ParamStr(0)) + 'ITENSAUT_TEMP.TXT';

  try
    GerarArquivoItensAut(AProdutos, ArquivoTemp);

    if Assigned(FToledoEnviaCarga) then
    begin
      RetornoDLL := FToledoEnviaCarga(PAnsiChar(AnsiString(ArquivoTemp)), PAnsiChar(AnsiString(FBalanca.IP)), FBalanca.Porta);
      if RetornoDLL = 0 then
      begin
        Result.Sucesso := True;
        Result.QuantidadeItens := AProdutos.Count;
        Result.Mensagem := Format('%d produtos transmitidos com sucesso via Toledo DLL (%s).', [AProdutos.Count, FBalanca.IP]);
      end
      else
      begin
        Result.Sucesso := False;
        Result.Mensagem := Format('Retorno de erro da DLL Toledo: Código %d', [RetornoDLL]);
      end;
    end
    else
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Função EnviaCarga não encontrada na DLL Toledo.';
    end;
  finally
    if FileExists(ArquivoTemp) then
      System.SysUtils.DeleteFile(ArquivoTemp);
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloToledo.EnviarViaSocketDireto(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  I: Integer;
  P: TProdutoPLU;
  LinhaPLU: AnsiString;
  PacoteBytes: TIdBytes;
  Idx: Integer;
  Enviados: Integer;
  PastaDestino: string;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  StopWatch := TStopwatch.StartNew;
  Enviados := 0;

  { Tenta conexão direta na porta 6500 da Toledo }
  if Conectar then
  begin
    try
      for I := 0 to AProdutos.Count - 1 do
      begin
        P := AProdutos[I];
        LinhaPLU := AnsiString(Format('%.2d', [P.Setor]) +
                               Format('%.6d', [P.CodigoPLU]) +
                               Format('%.6d', [Round(P.PrecoVenda * 100)]) +
                               Format('%.3d', [P.ValidadeDias]) +
                               AjustarTexto(P.DescricaoCurta, 25));

        SetLength(PacoteBytes, Length(LinhaPLU) + 2);
        PacoteBytes[0] := $02; { STX }
        for Idx := 1 to Length(LinhaPLU) do
          PacoteBytes[Idx] := Byte(LinhaPLU[Idx]);
        PacoteBytes[Length(PacoteBytes) - 1] := $03; { ETX }

        FTCPClient.Socket.Write(PacoteBytes);
        Inc(Enviados);
        Sleep(10);
      end;

      Result.Sucesso := True;
      Result.QuantidadeItens := Enviados;
      Result.Mensagem := Format('%d produtos transmitidos diretamente via socket para Toledo Prix (%s).', [Enviados, FBalanca.IP]);
    finally
      Desconectar;
    end;
  end
  else
  begin
    { Fallback: se houver pasta de monitoramento Toledo, gera ITENSAUT.TXT, TXINFO.TXT e TXRECEIT.TXT }
    PastaDestino := FBalanca.CaminhoDLL;
    if (PastaDestino <> '') and DirectoryExists(PastaDestino) then
    begin
      GerarArquivoItensAut(AProdutos, IncludeTrailingPathDelimiter(PastaDestino) + 'ITENSAUT.TXT');
      GerarArquivoNutricional(AProdutos, IncludeTrailingPathDelimiter(PastaDestino) + 'TXINFO.TXT');
      GerarArquivoReceitas(AProdutos, IncludeTrailingPathDelimiter(PastaDestino) + 'TXRECEIT.TXT');

      Result.Sucesso := True;
      Result.QuantidadeItens := AProdutos.Count;
      Result.Mensagem := Format('%d produtos e tabelas nutricionais gerados para carga Toledo.', [AProdutos.Count]);
    end
    else
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Não foi possível conectar na Toledo Prix (%s:%d). Verifique o IP ou forneça a P05.dll.', [FBalanca.IP, FBalanca.Porta]);
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloToledo.EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
begin
  if (AProdutos = nil) or (AProdutos.Count = 0) then
  begin
    Result.Sucesso := True;
    Result.QuantidadeItens := 0;
    Result.DataHora := Now;
    Result.TempoMs := 0;
    Result.Mensagem := 'Nenhum produto a transmitir.';
    Exit;
  end;

  if Assigned(FToledoEnviaCarga) then
    Result := EnviarViaDLLOficial(AProdutos)
  else
    Result := EnviarViaSocketDireto(AProdutos);
end;

function TProtocoloToledo.LimparBalanca: TResultadoEnvio;
var
  StopWatch: TStopwatch;
  PacoteLimpeza: TIdBytes;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  StopWatch := TStopwatch.StartNew;
  try
    if not Conectar then
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Não foi possível conectar na Toledo Prix (%s:%d) para zerar a memória.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      { Comando nativo Toledo Prix: STX (0x02) + 'C' + 'CLR' + ETX (0x03) }
      SetLength(PacoteLimpeza, 5);
      PacoteLimpeza[0] := $02;
      PacoteLimpeza[1] := Byte('C');
      PacoteLimpeza[2] := Byte('C');
      PacoteLimpeza[3] := Byte('L');
      PacoteLimpeza[4] := $03;

      FTCPClient.Socket.Write(PacoteLimpeza);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Comando de zeramento de memória enviado com sucesso para Toledo Prix (%s).', [FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao zerar memória da Toledo Prix: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloToledo.ObterNomeDriver: string;
begin
  if Assigned(FToledoEnviaCarga) then
    Result := 'Toledo Prix (Driver DLL Oficial P05.dll com RDC 429)'
  else
    Result := 'Toledo Prix (Comunicação Direta Socket TCP/IP com RDC 429)';
end;

end.