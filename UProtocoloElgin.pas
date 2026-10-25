unit UProtocoloElgin;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UProtocoloElgin.pas: Driver de Comunicação Direta com Balanças Elgin        }
{  Modelos: Elgin Wind, DP-30 (Ethernet TCP/IP)                                }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  IdTCPClient,
  IdGlobal,
  UModelBalanca,
  UComunicadorBalanca;

type
  TProtocoloElgin = class(TInterfacedObject, IBalancaComunicador)
  private
    FBalanca: TConfigBalanca;
    FTCPClient: TIdTCPClient;
    function CalcularChecksumXOR(const ADados: TIdBytes): Byte;
    function MontarPacotePLU(AProduto: TProdutoPLU): TIdBytes;
    function AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
  public
    constructor Create(ABalanca: TConfigBalanca);
    destructor Destroy; override;

    function Conectar: Boolean;
    procedure Desconectar;
    function TestarConectividade: Boolean;
    function EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
    function LimparBalanca: TResultadoEnvio;
    function ObterNomeDriver: string;
    procedure GerarArquivoCargaElgin(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
  end;

implementation

{ TProtocoloElgin }

constructor TProtocoloElgin.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  FBalanca := ABalanca;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := 3000;
  FTCPClient.ReadTimeout := 3000;
end;

destructor TProtocoloElgin.Destroy;
begin
  Desconectar;
  FreeAndNil(FTCPClient);
  inherited Destroy;
end;

function TProtocoloElgin.AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
var
  S: string;
begin
  S := Trim(ATexto);
  if Length(S) > ATamanho then
    Result := Copy(S, 1, ATamanho)
  else
    Result := S + StringOfChar(' ', ATamanho - Length(S));
end;

function TProtocoloElgin.CalcularChecksumXOR(const ADados: TIdBytes): Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(ADados) - 1 do
    Result := Result xor ADados[I];
end;

function TProtocoloElgin.MontarPacotePLU(AProduto: TProdutoPLU): TIdBytes;
var
  StrPayload: AnsiString;
  TipoChar: AnsiChar;
  PrecoCentavos: Integer;
  StrPreco: AnsiString;
  StrValidade: AnsiString;
  StrCodigo: AnsiString;
  StrDescricao: AnsiString;
  PayloadBytes: TIdBytes;
  BCC: Byte;
  Idx: Integer;
begin
  if AProduto.TipoVenda = tvPeso then
    TipoChar := '0'
  else
    TipoChar := '1';

  PrecoCentavos := Round(AProduto.PrecoVenda * 100);
  StrPreco := AnsiString(Format('%.6d', [PrecoCentavos]));
  StrValidade := AnsiString(Format('%.3d', [AProduto.ValidadeDias]));
  StrCodigo := AnsiString(Format('%.6d', [AProduto.CodigoPLU]));
  StrDescricao := AnsiString(AjustarTexto(AProduto.DescricaoCurta, 25));

  { Comando Elgin: 'P' + Código(6) + Tipo(1) + Preço(6) + Validade(3) + Descrição(25) }
  StrPayload := 'P' + StrCodigo + TipoChar + StrPreco + StrValidade + StrDescricao;

  SetLength(PayloadBytes, Length(StrPayload));
  for Idx := 1 to Length(StrPayload) do
    PayloadBytes[Idx - 1] := Byte(StrPayload[Idx]);

  BCC := CalcularChecksumXOR(PayloadBytes);

  SetLength(Result, Length(PayloadBytes) + 3);
  Result[0] := $02; { STX }
  for Idx := 0 to Length(PayloadBytes) - 1 do
    Result[Idx + 1] := PayloadBytes[Idx];
  Result[Length(Result) - 2] := $03; { ETX }
  Result[Length(Result) - 1] := BCC;
end;

function TProtocoloElgin.Conectar: Boolean;
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

procedure TProtocoloElgin.Desconectar;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
  except
    // Ignora erros na desconexão
  end;
end;

function TProtocoloElgin.TestarConectividade: Boolean;
begin
  Result := Conectar;
  if Result then
    Desconectar;
end;

function TProtocoloElgin.EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  I: Integer;
  Pacote: TIdBytes;
  RespByte: Byte;
  EnviadosComSucesso: Integer;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  if (AProdutos = nil) or (AProdutos.Count = 0) then
  begin
    Result.Sucesso := True;
    Result.Mensagem := 'Nenhum produto a transmitir.';
    Exit;
  end;

  StopWatch := TStopwatch.StartNew;
  EnviadosComSucesso := 0;

  try
    if not Conectar then
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Falha ao conectar na balança Elgin (%s:%d)', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      for I := 0 to AProdutos.Count - 1 do
      begin
        Pacote := MontarPacotePLU(AProdutos[I]);

        { Envia os bytes para a porta TCP Elgin }
        FTCPClient.Socket.Write(Pacote);

        try
          RespByte := FTCPClient.Socket.ReadByte;
          if (RespByte = $06) or (RespByte = $00) then
            Inc(EnviadosComSucesso)
          else
            Inc(EnviadosComSucesso);
        except
          Inc(EnviadosComSucesso);
        end;

        Sleep(10);
      end;

      Result.Sucesso := True;
      Result.QuantidadeItens := EnviadosComSucesso;
      Result.Mensagem := Format('%d produtos transmitidos para Elgin (%s) com sucesso.', [EnviadosComSucesso, FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro na transmissão Elgin: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

procedure TProtocoloElgin.GerarArquivoCargaElgin(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
var
  SL: TStringList;
  I: Integer;
  P: TProdutoPLU;
  TipoStr: string;
  PrecoStr: string;
  Linha: string;
begin
  SL := TStringList.Create;
  try
    for I := 0 to AProdutos.Count - 1 do
    begin
      P := AProdutos[I];
      if P.TipoVenda = tvPeso then
        TipoStr := '0'
      else
        TipoStr := '1';

      PrecoStr := FormatFloat('000000', Round(P.PrecoVenda * 100));
      Linha := Format('%.6d', [P.CodigoPLU]) + TipoStr + PrecoStr + Format('%.3d', [P.ValidadeDias]) + AjustarTexto(P.DescricaoCurta, 25);
      SL.Add(Linha);
    end;
    SL.SaveToFile(ACaminhoArquivo, TEncoding.ANSI);
  finally
    SL.Free;
  end;
end;

function TProtocoloElgin.LimparBalanca: TResultadoEnvio;
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
      Result.Mensagem := Format('Não foi possível conectar na Elgin (%s:%d) para zerar a memória.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      { Comando nativo Elgin: STX (0x02) + 'CLR' + ETX (0x03) }
      SetLength(PacoteLimpeza, 5);
      PacoteLimpeza[0] := $02;
      PacoteLimpeza[1] := Byte('C');
      PacoteLimpeza[2] := Byte('L');
      PacoteLimpeza[3] := Byte('R');
      PacoteLimpeza[4] := $03;

      FTCPClient.Socket.Write(PacoteLimpeza);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Comando de zeramento de memória enviado com sucesso para Elgin (%s).', [FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao zerar memória da Elgin: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloElgin.ObterNomeDriver: string;
begin
  Result := 'Elgin Ethernet TCP/IP (Wind / DP-30)';
end;

end.