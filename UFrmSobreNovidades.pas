unit UFrmSobreNovidades;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança Enterprise                           }
{  UFrmSobreNovidades.pas: Tela Sobre, Novidades e Verificador de Atualizações }
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
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  UModelBalanca;

const
  VERSAO_ATUAL = VERSAO_SISTEMA;
  REPO_URL = 'https://github.com/wgravinajunior-design/atualizabalanca';
  API_RELEASES_URL = 'https://api.github.com/repos/wgravinajunior-design/atualizabalanca/releases/latest';

type
  TFrmSobreNovidades = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlBadgeVersao: TPanel;
    lblVersaoTit: TLabel;
    lblVersaoVal: TLabel;
    pnlCardUpdate: TPanel;
    lblUpdateStatusTit: TLabel;
    lblUpdateStatusMsg: TLabel;
    btnVerificarAtualizacao: TButton;
    btnBaixarAtualizacao: TButton;
    pcNovidades: TPageControl;
    tsResumoVisual: TTabSheet;
    lvNovidades: TListView;
    tsNotasDetalhadas: TTabSheet;
    mmoNovidades: TMemo;
    pnlRodape: TPanel;
    btnFechar: TButton;

    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFecharClick(Sender: TObject);
    procedure btnVerificarAtualizacaoClick(Sender: TObject);
    procedure btnBaixarAtualizacaoClick(Sender: TObject);
  private
    FDownloadUrlNovaVersao: string;
    procedure CarregarNovidadesVisuais;
    procedure CarregarChangelogTexto;
    function ObterRespostaHTTPS(const AURL: string; out AResposta: string): Boolean;
    procedure AdicionarItemNovidade(const ARecurso, ACategoria, AImpacto: string);
  public
  end;

var
  FrmSobreNovidades: TFrmSobreNovidades;

implementation

uses
  Winapi.WinInet;

{$R *.dfm}

procedure TFrmSobreNovidades.FormShow(Sender: TObject);
begin
  lblVersaoVal.Caption := VERSAO_ATUAL;
  lblUpdateStatusMsg.Caption := Format('Sistema rodando na versão %s. Clique em "Verificar Versão" para checar atualizações.', [VERSAO_ATUAL]);
  btnBaixarAtualizacao.Visible := False;
  FDownloadUrlNovaVersao := '';

  CarregarNovidadesVisuais;
  CarregarChangelogTexto;
end;

procedure TFrmSobreNovidades.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TFrmSobreNovidades.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSobreNovidades.btnBaixarAtualizacaoClick(Sender: TObject);
var
  UrlDestino: string;
begin
  if Trim(FDownloadUrlNovaVersao) <> '' then
    UrlDestino := FDownloadUrlNovaVersao
  else
    UrlDestino := REPO_URL + '/releases/latest';

  ShellExecute(0, 'open', PChar(UrlDestino), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmSobreNovidades.AdicionarItemNovidade(const ARecurso, ACategoria, AImpacto: string);
var
  Item: TListItem;
begin
  Item := lvNovidades.Items.Add;
  Item.Caption := ARecurso;
  Item.SubItems.Add(ACategoria);
  Item.SubItems.Add(AImpacto);
end;

procedure TFrmSobreNovidades.CarregarNovidadesVisuais;
begin
  lvNovidades.Items.BeginUpdate;
  try
    lvNovidades.Items.Clear;
    AdicionarItemNovidade('📦 Cadastro de Produtos e Departamentos (F2)', 'Cadastros', 'Módulo completo para gerenciar PLUs, departamentos, preços, validade e ingredientes.');
    AdicionarItemNovidade('🥗 Tabela Nutricional RDC 429 & IN 75', 'Anvisa', 'Preenchimento oficial de nutrientes com cálculo dinâmico das Lupas Frontais de rotulagem.');
    AdicionarItemNovidade('💾 Carga USB para Balanças sem Cabo (F6)', 'USB / Pen Drive', 'Exportação para Pen Drive nos formatos Toledo, Balmak, Filizola e Urano.');
    AdicionarItemNovidade('📈 Gestão e Relatórios Analíticos (F10)', 'Relatórios', 'Vendas por peso e preço, faturamento, etiquetas por balança e exportação para Excel.');
    AdicionarItemNovidade('🏷️ Editor Visual de Etiquetas (F9)', 'Layout / Impressão', 'Editor WYSIWYG em tempo real com sincronização direta na memória de todas as balanças.');
    AdicionarItemNovidade('🚀 Comunicação Direta Socket TCP/IP', 'Rede / Driver', 'Transmissão direta sem depender de MGV ou Athenas; envio instantâneo.');
    AdicionarItemNovidade('📊 Comparador Visual de Alterações (F7)', 'Auditoria', 'Compara preços e PLUs antes do envio com destaque em cores de subida/descida.');
    AdicionarItemNovidade('🧹 Zeramento Remoto de Memória', 'Manutenção', 'Comando direto via rede para limpar produtos descontinuados da memória da balança.');
    AdicionarItemNovidade('💾 Backup e Restauração em 1 Clique', 'Segurança', 'Exporta e importa toda a configuração do parque de balanças em arquivo JSON.');
    AdicionarItemNovidade('⚡ Auto-Updater GitHub Releases (F1)', 'Sistema', 'Verificação e download de novas builds diretamente da nuvem sem sair do app.');
    AdicionarItemNovidade('📡 Micro-API REST Embutida (:8085)', 'Integração', 'Endpoints nativos /status, /sincronizar e /logs para integração Web/Mobile.');
  finally
    lvNovidades.Items.EndUpdate;
  end;
end;

procedure TFrmSobreNovidades.CarregarChangelogTexto;
begin
  mmoNovidades.Lines.BeginUpdate;
  try
    mmoNovidades.Lines.Clear;
    mmoNovidades.Lines.Add('================================================================================');
    mmoNovidades.Lines.Add(' ATUALIZABALANÇA ENTERPRISE - NOTAS OFICIAIS DA BUILD ' + VERSAO_ATUAL);
    mmoNovidades.Lines.Add(' Projeto: GoUp Sistemas | Arquitetura Monolítica Modular Delphi 12');
    mmoNovidades.Lines.Add('================================================================================');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('📦 1. CADASTRO DE PRODUTOS E DEPARTAMENTOS (TECLA F2)');
    mmoNovidades.Lines.Add('   - Retaguarda independente: cadastre PLUs, departamentos, preços, validade e conservação.');
    mmoNovidades.Lines.Add('   - Tabela Nutricional RDC 429 Anvisa com cálculo em tempo real de Lupas Frontais.');
    mmoNovidades.Lines.Add('   - Envio de dados direto para as balanças via rede ou exportação em arquivo USB.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('📈 2. GESTÃO E RELATÓRIOS ANALÍTICOS DE PESAGEM (TECLA F10)');
    mmoNovidades.Lines.Add('   - Desempenho de vendas por peso, preço e faturamento estimado por produto.');
    mmoNovidades.Lines.Add('   - Consolidado por departamento e controle de etiquetas emitidas por balança.');
    mmoNovidades.Lines.Add('   - Diagnóstico e auditoria de pendências de PLUs sem tabela nutricional.');
    mmoNovidades.Lines.Add('   - Exportação nativa para planilhas Excel (CSV) e visualização executiva em HTML.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('💾 3. CARGA E ENVIO VIA REDE OU USB (PEN DRIVE)');
    mmoNovidades.Lines.Add('   - Geração automática dos arquivos de pen drive para balanças sem cabo de rede.');
    mmoNovidades.Lines.Add('   - Toledo (ITENSAUT.TXT), Balmak (CARGA.TXT), Filizola (CADTXT.TXT) e Urano (PRODUTOS.TXT).');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('🏷️ 4. EDITOR VISUAL DE ETIQUETAS INTEGRADO COM BALANÇAS (TECLA F9)');
    mmoNovidades.Lines.Add('   - Simulador visual em tempo real (WYSIWYG) com prévia física de papel térmico.');
    mmoNovidades.Lines.Add('   - Suporte a 6 formatos padrão de mercado (40x40 a 60x80) e gravação via socket TCP/IP.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('🚀 5. COMUNICAÇÃO DIRETA VIA REDE (SEM INTERMEDIÁRIOS)');
    mmoNovidades.Lines.Add('   - Eliminação completa de softwares legados de fábrica (Toledo MGV, Balmak Athenas/Dtec).');
    mmoNovidades.Lines.Add('   - Transmissão instantânea via pacotes TCP/IP Socket com controle de timeout e retry.');
    mmoNovidades.Lines.Add('================================================================================');
  finally
    mmoNovidades.Lines.EndUpdate;
  end;
end;

function TFrmSobreNovidades.ObterRespostaHTTPS(const AURL: string; out AResposta: string): Boolean;
var
  hSessao, hConexao, hRequisicao: HINTERNET;
  URLParts: TURLComponents;
  HostName: array[0..255] of Char;
  UrlPath: array[0..1024] of Char;
  Flags: DWORD;
  Headers: string;
  Buffer: array[0..4095] of Byte;
  BytesLidos: DWORD;
  Stream: TBytesStream;
begin
  Result := False;
  AResposta := '';

  ZeroMemory(@URLParts, SizeOf(TURLComponents));
  URLParts.dwStructSize := SizeOf(TURLComponents);
  URLParts.lpszHostName := HostName;
  URLParts.dwHostNameLength := Length(HostName);
  URLParts.lpszUrlPath := UrlPath;
  URLParts.dwUrlPathLength := Length(UrlPath);

  if not InternetCrackUrl(PChar(AURL), Length(AURL), 0, URLParts) then
    Exit;

  hSessao := InternetOpen('AtualizaBalanca-AutoUpdater', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
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

      hRequisicao := HttpOpenRequest(hConexao, 'GET', URLParts.lpszUrlPath, nil, nil, nil, Flags, 0);
      if hRequisicao = nil then
        Exit;

      try
        Headers := 'Accept: application/vnd.github.v3+json' + #13#10 +
                   'User-Agent: AtualizaBalanca-Desktop' + #13#10;
        HttpAddRequestHeaders(hRequisicao, PChar(Headers), Length(Headers), HTTP_ADDREQ_FLAG_REPLACE or HTTP_ADDREQ_FLAG_ADD);

        if HttpSendRequest(hRequisicao, nil, 0, nil, 0) then
        begin
          Stream := TBytesStream.Create;
          try
            repeat
              BytesLidos := 0;
              if InternetReadFile(hRequisicao, @Buffer[0], SizeOf(Buffer), BytesLidos) and (BytesLidos > 0) then
                Stream.WriteBuffer(Buffer[0], BytesLidos);
            until BytesLidos = 0;

            AResposta := TEncoding.UTF8.GetString(Stream.Bytes, 0, Stream.Size);
            Result := (AResposta <> '');
          finally
            Stream.Free;
          end;
        end;
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

procedure TFrmSobreNovidades.btnVerificarAtualizacaoClick(Sender: TObject);
var
  RespostaJSON: string;
  PosTag, PosUrl: Integer;
  TagVersao, DownloadUrl: string;
begin
  Screen.Cursor := crHourGlass;
  try
    lblUpdateStatusMsg.Caption := 'Consultando repositório GitHub via HTTPS nativo...';
    Application.ProcessMessages;

    if ObterRespostaHTTPS(API_RELEASES_URL, RespostaJSON) then
    begin
      { Extração da tag_name do JSON }
      PosTag := Pos('"tag_name":', RespostaJSON);
      if PosTag > 0 then
      begin
        TagVersao := Copy(RespostaJSON, PosTag + 11, Length(RespostaJSON));
        TagVersao := Trim(Copy(TagVersao, 1, Pos(',', TagVersao) - 1));
        TagVersao := StringReplace(TagVersao, '"', '', [rfReplaceAll]);
      end
      else
        TagVersao := '';

      { Extração da html_url }
      PosUrl := Pos('"html_url":', RespostaJSON);
      if PosUrl > 0 then
      begin
        DownloadUrl := Copy(RespostaJSON, PosUrl + 11, Length(RespostaJSON));
        DownloadUrl := Trim(Copy(DownloadUrl, 1, Pos(',', DownloadUrl) - 1));
        DownloadUrl := StringReplace(DownloadUrl, '"', '', [rfReplaceAll]);
      end
      else
        DownloadUrl := REPO_URL + '/releases/latest';

      if (TagVersao <> '') and not SameText(TagVersao, VERSAO_ATUAL) then
      begin
        FDownloadUrlNovaVersao := DownloadUrl;
        lblUpdateStatusTit.Caption := '🎉 NOVA ATUALIZAÇÃO ENCONTRADA!';
        lblUpdateStatusTit.Font.Color := clGreen;
        lblUpdateStatusMsg.Caption := Format('Uma nova versão (%s) está disponível no GitHub! Clique no botão ao lado para baixar.', [TagVersao]);
        lblUpdateStatusMsg.Font.Color := clMaroon;
        btnBaixarAtualizacao.Caption := '⬇️ Baixar ' + TagVersao;
        btnBaixarAtualizacao.Visible := True;

        if MessageDlg(Format('🎉 Uma nova versão está disponível no GitHub!'#13#10#13#10 +
                             'Versão Instalada: %s'#13#10 +
                             'Nova Versão Disponível: %s'#13#10#13#10 +
                             'Deseja abrir a página de download e atualização agora?',
                             [VERSAO_ATUAL, TagVersao]),
                      mtInformation, [mbYes, mbNo], 0) = mrYes then
        begin
          btnBaixarAtualizacaoClick(Sender);
        end;
      end
      else
      begin
        lblUpdateStatusTit.Caption := 'STATUS DA ATUALIZAÇÃO';
        lblUpdateStatusTit.Font.Color := clGray;
        lblUpdateStatusMsg.Caption := Format('✅ Parabéns! O AtualizaBalança já está na versão mais recente (%s).', [VERSAO_ATUAL]);
        lblUpdateStatusMsg.Font.Color := clGreen;
        btnBaixarAtualizacao.Visible := False;
        ShowMessage(Format('Você já está utilizando a versão mais recente do sistema (%s).', [VERSAO_ATUAL]));
      end;
    end
    else
    begin
      lblUpdateStatusMsg.Caption := 'Não foi possível verificar no momento. Tentando abrir página oficial...';
      if MessageDlg('Não foi possível consultar a API do GitHub no momento.'#13#10#13#10 +
                    'Deseja abrir a página de releases no navegador?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        ShellExecute(0, 'open', PChar(REPO_URL + '/releases'), nil, nil, SW_SHOWNORMAL);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
