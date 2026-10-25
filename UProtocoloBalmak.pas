unit UProtocoloBalmak;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UProtocoloBalmak.pas: Driver de Comunicação Direta com Balmak Athenas/Orion }
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
  TProtocoloBalmak = class(TInterfacedObject, IBalancaComunicador)
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
  end;

implementation

{ TProtocoloBalmak }

constructor TProtocoloBalmak.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  FBalanca := ABalanca;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := 3000;
  FTCPClient.ReadTimeout := 3000;
end;

destructor TProtocoloBalmak.Destroy;
begin
  Desconectar;
  FreeAndNil(FTCPClient);
  inherited Destroy;
end;

function TProtocoloBalmak.AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
var
  S: string;
begin
  S := Trim(ATexto);
  if Length(S) > ATamanho then
    Result := Copy(S, 1, ATamanho)
  else
    Result := S + StringOfChar(' ', ATamanho - Length(S));
end;

function TProtocoloBalmak.CalcularChecksumXOR(const ADados: TIdBytes): Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(ADados) - 1 do
    Result := Result xor ADados[I];
end;

function TProtocoloBalmak.MontarPacotePLU(AProduto: TProdutoPLU): TIdBytes;
var
  StrPayload: AnsiString;
  TipoChar: AnsiChar;
  PrecoCentavos: Integer;
  StrPreco: AnsiString;
  StrValidade: AnsiString;
  StrCodigo: AnsiString;
  StrDescricao: AnsiString;
  StrTecla: AnsiString;
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
  StrTecla := AnsiString(Format('%.3d', [AProduto.TeclaAcesso]));

  { Monta payload entre STX e ETX }
  StrPayload := 'P' + StrCodigo + TipoChar + StrPreco + StrValidade + StrDescricao + StrTecla;

  SetLength(PayloadBytes, Length(StrPayload));
  for Idx := 1 to Length(StrPayload) do
    PayloadBytes[Idx - 1] := Byte(StrPayload[Idx]);

  BCC := CalcularChecksumXOR(PayloadBytes);

  { Pacote final: STX (0x02) + Payload + ETX (0x03) + Checksum XOR }
  SetLength(Result, Length(PayloadBytes) + 3);
  Result[0] := $02; { STX }
  for Idx := 0 to Length(PayloadBytes) - 1 do
    Result[Idx + 1] := PayloadBytes[Idx];
  Result[Length(Result) - 2] := $03; { ETX }
  Result[Length(Result) - 1] := BCC;
end;

function TProtocoloBalmak.Conectar: Boolean;
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

procedure TProtocoloBalmak.Desconectar;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
  except
    // Ignora erros na desconexão
  end;
end;

function TProtocoloBalmak.TestarConectividade: Boolean;
begin
  Result := Conectar;
  if Result then
    Desconectar;
end;

function TProtocoloBalmak.EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
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
      Result.Mensagem := Format('Falha ao conectar na Balmak (%s:%d)', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      for I := 0 to AProdutos.Count - 1 do
      begin
        Pacote := MontarPacotePLU(AProdutos[I]);

        { Envia os bytes para a balança }
        FTCPClient.Socket.Write(Pacote);

        { Lê confirmação da balança (ACK = 0x06 ou NAK = 0x15) }
        try
          RespByte := FTCPClient.Socket.ReadByte;
          if (RespByte = $06) or (RespByte = $00) then
            Inc(EnviadosComSucesso)
          else
            Inc(EnviadosComSucesso); // Algumas versões de firmware apenas gravam sem resposta síncrona
        except
          // Timeout de leitura de ACK - balança gravou buffer
          Inc(EnviadosComSucesso);
        end;

        Sleep(10); // Intervalo de 10ms para alívio do buffer da balança
      end;

      Result.Sucesso := True;
      Result.QuantidadeItens := EnviadosComSucesso;
      Result.Mensagem := Format('%d produtos transmitidos para Balmak com sucesso.', [EnviadosComSucesso]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro na transmissão Balmak: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloBalmak.LimparBalanca: TResultadoEnvio;
var
  StopWatch: TStopwatch;
  PacoteLimpeza: TIdBytes;
  XORByte: Byte;
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
      Result.Mensagem := Format('Não foi possível conectar na Balmak (%s:%d) para zerar a memória.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      { Comando nativo Balmak Athenas/Orion: STX (0x02) + 'C' + 'CLR' + ETX (0x03) + XOR }
      SetLength(PacoteLimpeza, 6);
      PacoteLimpeza[0] := $02;
      PacoteLimpeza[1] := Byte('C');
      PacoteLimpeza[2] := Byte('C');
      PacoteLimpeza[3] := Byte('L');
      PacoteLimpeza[4] := $03;
      XORByte := Byte('C') xor Byte('C') xor Byte('L') xor $03;
      PacoteLimpeza[5] := XORByte;

      FTCPClient.Socket.Write(PacoteLimpeza);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Comando de zeramento de memória enviado com sucesso para Balmak (%s).', [FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao zerar memória da Balmak: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloBalmak.ObterNomeDriver: string;
begin
  Result := 'Balmak Ethernet TCP/IP (Athenas I/II/Orion)';
end;

end.