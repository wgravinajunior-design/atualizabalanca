unit UServicoNotificacao;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UServicoNotificacao.pas: Notificações Nativas via Telegram e Webhook (HTTPS)}
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.NetEncoding,
  Winapi.Windows,
  Winapi.WinInet;

type
  TServicoNotificacao = class
  private
    class function EnviarRequisicaoHTTPS(const AURL: string; const AMetodo: string; const ADados: string; const AContentType: string): Boolean;
    class function FormatarParaURL(const ATexto: string): string;
  public
    class function EnviarTelegram(const AToken: string; const AChatID: string; const AMensagem: string): Boolean;
    class function EnviarWebhook(const AURLWebhook: string; const AJsonPayload: string): Boolean;
  end;

implementation

{ TServicoNotificacao }

class function TServicoNotificacao.FormatarParaURL(const ATexto: string): string;
begin
  Result := TNetEncoding.URL.Encode(ATexto);
end;

class function TServicoNotificacao.EnviarRequisicaoHTTPS(const AURL: string; const AMetodo: string; const ADados: string; const AContentType: string): Boolean;
var
  hSessao, hConexao, hRequisicao: HINTERNET;
  URLParts: TURLComponents;
  HostName: array[0..255] of Char;
  UrlPath: array[0..1024] of Char;
  Flags: DWORD;
  Headers: string;
  DadosBytes: TBytes;
begin
  Result := False;

  ZeroMemory(@URLParts, SizeOf(TURLComponents));
  URLParts.dwStructSize := SizeOf(TURLComponents);
  URLParts.lpszHostName := HostName;
  URLParts.dwHostNameLength := Length(HostName);
  URLParts.lpszUrlPath := UrlPath;
  URLParts.dwUrlPathLength := Length(UrlPath);

  if not InternetCrackUrl(PChar(AURL), Length(AURL), 0, URLParts) then
    Exit;

  hSessao := InternetOpen('GoUp-AtualizaBalanca', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hSessao = nil then
    Exit;

  try
    hConexao := InternetConnect(hSessao, URLParts.lpszHostName, URLParts.nPort, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if hConexao = nil then
      Exit;

    try
      Flags := INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE;
      if URLParts.nScheme = INTERNET_SCHEME_HTTPS then
        Flags := Flags or INTERNET_FLAG_SECURE or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID;

      hRequisicao := HttpOpenRequest(hConexao, PChar(AMetodo), URLParts.lpszUrlPath, nil, nil, nil, Flags, 0);
      if hRequisicao = nil then
        Exit;

      try
        Headers := 'Content-Type: ' + AContentType + #13#10 + 'Accept: application/json' + #13#10;
        HttpAddRequestHeaders(hRequisicao, PChar(Headers), Length(Headers), HTTP_ADDREQ_FLAG_REPLACE or HTTP_ADDREQ_FLAG_ADD);

        DadosBytes := TEncoding.UTF8.GetBytes(ADados);
        if Length(DadosBytes) > 0 then
          Result := HttpSendRequest(hRequisicao, nil, 0, Pointer(DadosBytes), Length(DadosBytes))
        else
          Result := HttpSendRequest(hRequisicao, nil, 0, nil, 0);
      finally
        InternetCloseHandle(hRequisicao);
      end;
    finally
      InternetCloseHandle(hConexao);
    end;
  finally
    InternetCloseHandle(hSessao);
  end;
end;

class function TServicoNotificacao.EnviarTelegram(const AToken: string; const AChatID: string; const AMensagem: string): Boolean;
var
  URL: string;
  Payload: string;
begin
  Result := False;
  if (Trim(AToken) = '') or (Trim(AChatID) = '') then
    Exit;

  URL := Format('https://api.telegram.org/bot%s/sendMessage', [Trim(AToken)]);
  Payload := Format('chat_id=%s&text=%s&parse_mode=HTML', [Trim(AChatID), FormatarParaURL(AMensagem)]);

  Result := EnviarRequisicaoHTTPS(URL, 'POST', Payload, 'application/x-www-form-urlencoded');
end;

class function TServicoNotificacao.EnviarWebhook(const AURLWebhook: string; const AJsonPayload: string): Boolean;
begin
  Result := False;
  if Trim(AURLWebhook) = '' then
    Exit;

  Result := EnviarRequisicaoHTTPS(Trim(AURLWebhook), 'POST', AJsonPayload, 'application/json; charset=utf-8');
end;

end.