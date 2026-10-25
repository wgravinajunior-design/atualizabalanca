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
  IdHTTP,
  IdSSLOpenSSL;

const
  VERSAO_ATUAL = 'v2.5.0';
  REPO_URL = 'https://github.com/wgravinajunior-design/atualizabalanca';
  API_RELEASES_URL = 'https://api.github.com/repos/wgravinajunior-design/atualizabalanca/releases/latest';

type
  TFrmSobreNovidades = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblVersao: TLabel;
    lblStatusUpdate: TLabel;
    grpNovidades: TGroupBox;
    mmoNovidades: TMemo;
    pnlRodape: TPanel;
    btnVerificarAtualizacao: TButton;
    btnVerRepositorio: TButton;
    btnFechar: TButton;

    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFecharClick(Sender: TObject);
    procedure btnVerRepositorioClick(Sender: TObject);
    procedure btnVerificarAtualizacaoClick(Sender: TObject);
  private
    procedure CarregarChangelog;
  public
  end;

var
  FrmSobreNovidades: TFrmSobreNovidades;

implementation

{$R *.dfm}

procedure TFrmSobreNovidades.FormShow(Sender: TObject);
begin
  CarregarChangelog;
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

procedure TFrmSobreNovidades.btnVerRepositorioClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(REPO_URL), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmSobreNovidades.CarregarChangelog;
begin
  mmoNovidades.Lines.BeginUpdate;
  try
    mmoNovidades.Lines.Clear;
    mmoNovidades.Lines.Add('========================================================================');
    mmoNovidades.Lines.Add(' ATUALIZABALANÇA ENTERPRISE - NOTAS DA VERSÃO ' + VERSAO_ATUAL);
    mmoNovidades.Lines.Add(' Build: Outubro / 2026 - GoUp Sistemas');
    mmoNovidades.Lines.Add('========================================================================');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('🚀 1. COMUNICAÇÃO DIRETA VIA REDE (SEM MGV OU ATHENAS)');
    mmoNovidades.Lines.Add('   - Eliminação completa da necessidade de instalar e monitorar softwares');
    mmoNovidades.Lines.Add('     intermediários como Toledo MGV, Balmak Athenas/Dtec ou Filizola Smart.');
    mmoNovidades.Lines.Add('   - Envio de dados e cargas diretamente via pacotes de rede Socket TCP/IP.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('📊 2. AUDITORIA E COMPARATIVO DE PREÇOS (NOVA TECLA F7)');
    mmoNovidades.Lines.Add('   - Nova janela de prévia que compara os preços anteriores com os atuais');
    mmoNovidades.Lines.Add('     do ERP antes de transmitir para as balanças.');
    mmoNovidades.Lines.Add('   - Badges coloridos: Preço Subiu (+%), Preço Baixou (-%), Novo PLU e');
    mmoNovidades.Lines.Add('     alerta para produtos ativos sem Código de Balança preenchido.');
    mmoNovidades.Lines.Add('   - Exportação completa da auditoria para planilha Excel/CSV.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('🧹 3. COMANDO DE APAGAR / ZERAR DADOS DA BALANÇA');
    mmoNovidades.Lines.Add('   - Opção com clique direito para enviar comando direto via rede de zeramento');
    mmoNovidades.Lines.Add('     da memória da balança selecionada.');
    mmoNovidades.Lines.Add('   - Pergunta inteligente oferecendo Carga Total limpa logo após zerar.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('🥗 4. ROTULAGEM NUTRICIONAL OFICIAL ANVISA (RDC 429 E IN 75/2020)');
    mmoNovidades.Lines.Add('   - Consulta direta à tabela TB_PRODUTO_NUTRICIONAL no Firebird.');
    mmoNovidades.Lines.Add('   - Visualizador de Tabela Nutricional por porção e por 100g.');
    mmoNovidades.Lines.Add('   - Detecção automática de Lupas Frontais: Alto em Açúcar, Gordura e Sódio.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('⚡ 5. ISOLAMENTO DE TIMEOUT COM TRANSMISSÃO PARALELA (TTASK)');
    mmoNovidades.Lines.Add('   - Balanças desligadas ou com cabo desconectado não atrasam nem travam');
    mmoNovidades.Lines.Add('     o envio de dados para as outras balanças da loja.');
    mmoNovidades.Lines.Add('');
    mmoNovidades.Lines.Add('💾 6. BACKUP E RESTAURAÇÃO DE CONFIGURAÇÕES EM 1 CLIQUE');
    mmoNovidades.Lines.Add('   - Salve e restaure toda a topologia de balanças e conexões com facilidade.');
    mmoNovidades.Lines.Add('========================================================================');
  finally
    mmoNovidades.Lines.EndUpdate;
  end;
end;

procedure TFrmSobreNovidades.btnVerificarAtualizacaoClick(Sender: TObject);
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  RespostaJSON: string;
  PosTag, PosUrl, PosBody: Integer;
  TagVersao, DownloadUrl, NotasVersao: string;
begin
  Screen.Cursor := crHourGlass;
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      SSL.SSLOptions.Method := sslvTLSv1_2;
      SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.UserAgent := 'AtualizaBalanca-App/' + VERSAO_ATUAL;
      HTTP.Request.Accept := 'application/vnd.github.v3+json';
      HTTP.ConnectTimeout := 5000;
      HTTP.ReadTimeout := 5000;

      RespostaJSON := HTTP.Get(API_RELEASES_URL);

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
        DownloadUrl := REPO_URL + '/releases';

      if (TagVersao <> '') and not SameText(TagVersao, VERSAO_ATUAL) then
      begin
        if MessageDlg(Format('Uma nova versão está disponível no GitHub!'#13#10#13#10 +
                             'Versão Atual: %s'#13#10 +
                             'Nova Versão: %s'#13#10#13#10 +
                             'Deseja abrir a página de download agora?',
                             [VERSAO_ATUAL, TagVersao]),
                      mtInformation, [mbYes, mbNo], 0) = mrYes then
        begin
          ShellExecute(0, 'open', PChar(DownloadUrl), nil, nil, SW_SHOWNORMAL);
        end;
      end
      else
      begin
        ShowMessage(Format('Parabéns! Você já está utilizando a versão mais recente do AtualizaBalança Enterprise (%s).', [VERSAO_ATUAL]));
      end;
    except
      on E: Exception do
      begin
        { Fallback para abrir página de releases no navegador }
        if MessageDlg('Não foi possível consultar a API do GitHub diretamente (' + E.Message + ').'#13#10#13#10 +
                      'Deseja abrir a página de lançamentos no navegador?',
                      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          ShellExecute(0, 'open', PChar(REPO_URL + '/releases'), nil, nil, SW_SHOWNORMAL);
      end;
    end;
  finally
    SSL.Free;
    HTTP.Free;
    Screen.Cursor := crDefault;
  end;
end;

end.
