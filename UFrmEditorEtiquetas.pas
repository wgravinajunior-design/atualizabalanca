unit UFrmEditorEtiquetas;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança Enterprise                           }
{  UFrmEditorEtiquetas.pas: Editor Visual e Configurador de Etiquetas Térmicas }
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.IniFiles,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  UModelBalanca,
  UDMConexao,
  URepositoryBalanca,
  UComunicadorBalanca;

type
  TFrmEditorEtiquetas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEsquerda: TPanel;
    grpBalancaFormato: TGroupBox;
    lblBalancaAlvo: TLabel;
    lblTamanhoEtiqueta: TLabel;
    cbBalancaAlvo: TComboBox;
    cbTamanhoEtiqueta: TComboBox;
    grpTextos: TGroupBox;
    lblNomeLoja: TLabel;
    lblRodape: TLabel;
    edtNomeLoja: TEdit;
    edtRodape: TEdit;
    grpCampos: TGroupBox;
    chkImprimirLoja: TCheckBox;
    chkImprimirPLU: TCheckBox;
    chkImprimirDescricao: TCheckBox;
    chkImprimirDatas: TCheckBox;
    chkImprimirHora: TCheckBox;
    chkImprimirTara: TCheckBox;
    chkImprimirPrecoKg: TCheckBox;
    chkImprimirPeso: TCheckBox;
    chkImprimirTotal: TCheckBox;
    chkImprimirBarras: TCheckBox;
    chkImprimirNutricional: TCheckBox;
    chkImprimirReceita: TCheckBox;
    chkImprimirRodape: TCheckBox;
    grpPadraoBarras: TGroupBox;
    cbPadraoBarras: TComboBox;
    pnlAcoesEsquerda: TPanel;
    btnEnviarBalanca: TButton;
    btnSalvarPadrao: TButton;
    btnFechar: TButton;
    pnlDireita: TPanel;
    lblPreviaTitulo: TLabel;
    sbPrevia: TScrollBox;
    pnlEtiquetaFisica: TPanel;
    lblPreviaLoja: TLabel;
    lblPreviaProduto: TLabel;
    lblPreviaPLU: TLabel;
    lblPreviaDatas: TLabel;
    pnlPreviaValores: TPanel;
    lblPreviaPrecoUnit: TLabel;
    lblPreviaPesoLiq: TLabel;
    lblPreviaTotalTit: TLabel;
    lblPreviaTotalVal: TLabel;
    pnlPreviaBarras: TPanel;
    lblPreviaBarrasDesenho: TLabel;
    lblPreviaBarrasNumero: TLabel;
    pnlPreviaNutricional: TPanel;
    lblPreviaNutriTit: TLabel;
    lblPreviaNutriLupas: TLabel;
    lblPreviaNutriLinhas: TLabel;
    lblPreviaIngredientes: TLabel;
    lblPreviaRodape: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFecharClick(Sender: TObject);
    procedure cbBalancaAlvoChange(Sender: TObject);
    procedure cbTamanhoEtiquetaChange(Sender: TObject);
    procedure edtNomeLojaChange(Sender: TObject);
    procedure edtRodapeChange(Sender: TObject);
    procedure chkElementoClick(Sender: TObject);
    procedure cbPadraoBarrasChange(Sender: TObject);
    procedure btnSalvarPadraoClick(Sender: TObject);
    procedure btnEnviarBalancaClick(Sender: TObject);
  private
    FConfig: TConfigEtiqueta;
    FBalancas: TObjectList<TConfigBalanca>;
    procedure CarregarBalancasCombo;
    procedure CarregarConfiguracaoINI;
    procedure SalvarConfiguracaoINI;
    procedure AtualizarPreviaEtiqueta;
    procedure SincronizarTelaParaConfig;
  public
    procedure SelecionarBalancaPorID(const AIDBalanca: Integer);
  end;

var
  FrmEditorEtiquetas: TFrmEditorEtiquetas;

implementation

{$R *.dfm}

{ TFrmEditorEtiquetas }

procedure TFrmEditorEtiquetas.FormCreate(Sender: TObject);
begin
  FConfig := TConfigEtiqueta.Create;
  FBalancas := TObjectList<TConfigBalanca>.Create(True);

  cbTamanhoEtiqueta.Items.Clear;
  cbTamanhoEtiqueta.Items.Add('40 x 40 mm (Compacta - Preço, Peso e Código de Barras)');
  cbTamanhoEtiqueta.Items.Add('60 x 30 mm (Horizontal - Açougue e Fatiados)');
  cbTamanhoEtiqueta.Items.Add('60 x 40 mm (Padrão de Mercado - Loja, PLU, Barras e Valores)');
  cbTamanhoEtiqueta.Items.Add('60 x 60 mm (Nutricional - RDC 429 Anvisa e Ingredientes)');
  cbTamanhoEtiqueta.Items.Add('60 x 70 mm (Expandida - Rotulagem Completa e Lupas Frontais)');
  cbTamanhoEtiqueta.Items.Add('60 x 80 mm (Industrial - Padaria / Rotulagem Industrial)');
  cbTamanhoEtiqueta.ItemIndex := 2; // 60x40 padrão

  cbPadraoBarras.Items.Clear;
  cbPadraoBarras.Items.Add('EAN-13: Prefixo 2 + 5 dígitos PLU + 5 dígitos Total + DV [Padrão Supermercado]');
  cbPadraoBarras.Items.Add('EAN-13: Prefixo 2 + 5 dígitos PLU + 5 dígitos Peso Líquido + DV');
  cbPadraoBarras.Items.Add('EAN-13: Prefixo 2 + 4 dígitos PLU + 6 dígitos Total + DV');
  cbPadraoBarras.Items.Add('EAN-13 Livre (Código de barras gravado no cadastro do ERP)');
  cbPadraoBarras.ItemIndex := 0;

  CarregarConfiguracaoINI;
end;

procedure TFrmEditorEtiquetas.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FConfig);
  FreeAndNil(FBalancas);
end;

procedure TFrmEditorEtiquetas.FormShow(Sender: TObject);
begin
  CarregarBalancasCombo;
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TFrmEditorEtiquetas.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmEditorEtiquetas.CarregarBalancasCombo;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Bal: TConfigBalanca;
begin
  cbBalancaAlvo.Items.Clear;
  cbBalancaAlvo.Items.AddObject('🌟 [TODAS AS BALANÇAS DA LOJA]', nil);

  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.CarregarBalancas(FBalancas);
    for I := 0 to FBalancas.Count - 1 do
    begin
      Bal := FBalancas[I];
      cbBalancaAlvo.Items.AddObject(
        Format('[ID: %d] %s (%s - %s:%d)', [Bal.ID, Bal.Nome, Bal.ObterDescricaoFabricante, Bal.IP, Bal.Porta]),
        Bal);
    end;
  finally
    Repo.Free;
  end;

  if cbBalancaAlvo.ItemIndex < 0 then
    cbBalancaAlvo.ItemIndex := 0;
end;

procedure TFrmEditorEtiquetas.SelecionarBalancaPorID(const AIDBalanca: Integer);
var
  I: Integer;
  Bal: TConfigBalanca;
begin
  for I := 1 to cbBalancaAlvo.Items.Count - 1 do
  begin
    if Assigned(cbBalancaAlvo.Items.Objects[I]) then
    begin
      Bal := TConfigBalanca(cbBalancaAlvo.Items.Objects[I]);
      if Bal.ID = AIDBalanca then
      begin
        cbBalancaAlvo.ItemIndex := I;
        Break;
      end;
    end;
  end;
end;

procedure TFrmEditorEtiquetas.CarregarConfiguracaoINI;
var
  Ini: TIniFile;
  CaminhoINI: string;
begin
  CaminhoINI := ExtractFilePath(ParamStr(0)) + 'ConfigBalanca.ini';
  Ini := TIniFile.Create(CaminhoINI);
  try
    FConfig.FormatoID := Ini.ReadInteger('ETIQUETA', 'FormatoID', 3);
    FConfig.NomeLoja := Ini.ReadString('ETIQUETA', 'NomeLoja', 'GOUP SUPERMERCADOS');
    FConfig.MensagemRodape := Ini.ReadString('ETIQUETA', 'Rodape', 'Conserve sob refrigeração. Obrigado pela preferência!');
    FConfig.ImprimirLoja := Ini.ReadBool('ETIQUETA', 'ImprimirLoja', True);
    FConfig.ImprimirPLU := Ini.ReadBool('ETIQUETA', 'ImprimirPLU', True);
    FConfig.ImprimirDescricao := Ini.ReadBool('ETIQUETA', 'ImprimirDescricao', True);
    FConfig.ImprimirDataEmbalagem := Ini.ReadBool('ETIQUETA', 'ImprimirDataEmbalagem', True);
    FConfig.ImprimirDataValidade := Ini.ReadBool('ETIQUETA', 'ImprimirDataValidade', True);
    FConfig.ImprimirHora := Ini.ReadBool('ETIQUETA', 'ImprimirHora', True);
    FConfig.ImprimirTara := Ini.ReadBool('ETIQUETA', 'ImprimirTara', True);
    FConfig.ImprimirPrecoUnitario := Ini.ReadBool('ETIQUETA', 'ImprimirPrecoUnitario', True);
    FConfig.ImprimirPeso := Ini.ReadBool('ETIQUETA', 'ImprimirPeso', True);
    FConfig.ImprimirTotal := Ini.ReadBool('ETIQUETA', 'ImprimirTotal', True);
    FConfig.ImprimirCodigoBarras := Ini.ReadBool('ETIQUETA', 'ImprimirCodigoBarras', True);
    FConfig.ImprimirNutricional := Ini.ReadBool('ETIQUETA', 'ImprimirNutricional', True);
    FConfig.ImprimirReceitaAlergicos := Ini.ReadBool('ETIQUETA', 'ImprimirReceitaAlergicos', True);
    FConfig.ImprimirRodape := Ini.ReadBool('ETIQUETA', 'ImprimirRodape', True);
    FConfig.TipoCodigoBarras := Ini.ReadInteger('ETIQUETA', 'TipoCodigoBarras', 0);

    edtNomeLoja.Text := FConfig.NomeLoja;
    edtRodape.Text := FConfig.MensagemRodape;
    chkImprimirLoja.Checked := FConfig.ImprimirLoja;
    chkImprimirPLU.Checked := FConfig.ImprimirPLU;
    chkImprimirDescricao.Checked := FConfig.ImprimirDescricao;
    chkImprimirDatas.Checked := FConfig.ImprimirDataEmbalagem;
    chkImprimirHora.Checked := FConfig.ImprimirHora;
    chkImprimirTara.Checked := FConfig.ImprimirTara;
    chkImprimirPrecoKg.Checked := FConfig.ImprimirPrecoUnitario;
    chkImprimirPeso.Checked := FConfig.ImprimirPeso;
    chkImprimirTotal.Checked := FConfig.ImprimirTotal;
    chkImprimirBarras.Checked := FConfig.ImprimirCodigoBarras;
    chkImprimirNutricional.Checked := FConfig.ImprimirNutricional;
    chkImprimirReceita.Checked := FConfig.ImprimirReceitaAlergicos;
    chkImprimirRodape.Checked := FConfig.ImprimirRodape;

    if (FConfig.FormatoID >= 1) and (FConfig.FormatoID <= 6) then
      cbTamanhoEtiqueta.ItemIndex := FConfig.FormatoID - 1
    else
      cbTamanhoEtiqueta.ItemIndex := 2;

    cbPadraoBarras.ItemIndex := FConfig.TipoCodigoBarras;
  finally
    Ini.Free;
  end;
end;

procedure TFrmEditorEtiquetas.SalvarConfiguracaoINI;
var
  Ini: TIniFile;
  CaminhoINI: string;
begin
  SincronizarTelaParaConfig;
  CaminhoINI := ExtractFilePath(ParamStr(0)) + 'ConfigBalanca.ini';
  Ini := TIniFile.Create(CaminhoINI);
  try
    Ini.WriteInteger('ETIQUETA', 'FormatoID', FConfig.FormatoID);
    Ini.WriteString('ETIQUETA', 'NomeLoja', FConfig.NomeLoja);
    Ini.WriteString('ETIQUETA', 'Rodape', FConfig.MensagemRodape);
    Ini.WriteBool('ETIQUETA', 'ImprimirLoja', FConfig.ImprimirLoja);
    Ini.WriteBool('ETIQUETA', 'ImprimirPLU', FConfig.ImprimirPLU);
    Ini.WriteBool('ETIQUETA', 'ImprimirDescricao', FConfig.ImprimirDescricao);
    Ini.WriteBool('ETIQUETA', 'ImprimirDataEmbalagem', FConfig.ImprimirDataEmbalagem);
    Ini.WriteBool('ETIQUETA', 'ImprimirDataValidade', FConfig.ImprimirDataValidade);
    Ini.WriteBool('ETIQUETA', 'ImprimirHora', FConfig.ImprimirHora);
    Ini.WriteBool('ETIQUETA', 'ImprimirTara', FConfig.ImprimirTara);
    Ini.WriteBool('ETIQUETA', 'ImprimirPrecoUnitario', FConfig.ImprimirPrecoUnitario);
    Ini.WriteBool('ETIQUETA', 'ImprimirPeso', FConfig.ImprimirPeso);
    Ini.WriteBool('ETIQUETA', 'ImprimirTotal', FConfig.ImprimirTotal);
    Ini.WriteBool('ETIQUETA', 'ImprimirCodigoBarras', FConfig.ImprimirCodigoBarras);
    Ini.WriteBool('ETIQUETA', 'ImprimirNutricional', FConfig.ImprimirNutricional);
    Ini.WriteBool('ETIQUETA', 'ImprimirReceitaAlergicos', FConfig.ImprimirReceitaAlergicos);
    Ini.WriteBool('ETIQUETA', 'ImprimirRodape', FConfig.ImprimirRodape);
    Ini.WriteInteger('ETIQUETA', 'TipoCodigoBarras', FConfig.TipoCodigoBarras);
  finally
    Ini.Free;
  end;
end;

procedure TFrmEditorEtiquetas.SincronizarTelaParaConfig;
begin
  FConfig.FormatoID := cbTamanhoEtiqueta.ItemIndex + 1;
  FConfig.TamanhoDescricao := cbTamanhoEtiqueta.Text;
  FConfig.NomeLoja := Trim(edtNomeLoja.Text);
  FConfig.MensagemRodape := Trim(edtRodape.Text);
  FConfig.ImprimirLoja := chkImprimirLoja.Checked;
  FConfig.ImprimirPLU := chkImprimirPLU.Checked;
  FConfig.ImprimirDescricao := chkImprimirDescricao.Checked;
  FConfig.ImprimirDataEmbalagem := chkImprimirDatas.Checked;
  FConfig.ImprimirDataValidade := chkImprimirDatas.Checked;
  FConfig.ImprimirHora := chkImprimirHora.Checked;
  FConfig.ImprimirTara := chkImprimirTara.Checked;
  FConfig.ImprimirPrecoUnitario := chkImprimirPrecoKg.Checked;
  FConfig.ImprimirPeso := chkImprimirPeso.Checked;
  FConfig.ImprimirTotal := chkImprimirTotal.Checked;
  FConfig.ImprimirCodigoBarras := chkImprimirBarras.Checked;
  FConfig.ImprimirNutricional := chkImprimirNutricional.Checked;
  FConfig.ImprimirReceitaAlergicos := chkImprimirReceita.Checked;
  FConfig.ImprimirRodape := chkImprimirRodape.Checked;
  FConfig.TipoCodigoBarras := cbPadraoBarras.ItemIndex;
end;

procedure TFrmEditorEtiquetas.AtualizarPreviaEtiqueta;
var
  Formato: Integer;
  TextoDatas: string;
begin
  Formato := cbTamanhoEtiqueta.ItemIndex;

  { Cabeçalho }
  lblPreviaLoja.Visible := chkImprimirLoja.Checked and (Trim(edtNomeLoja.Text) <> '');
  lblPreviaLoja.Caption := edtNomeLoja.Text;

  { Produto e PLU }
  lblPreviaProduto.Visible := chkImprimirDescricao.Checked;
  lblPreviaPLU.Visible := chkImprimirPLU.Checked;

  { Datas }
  if chkImprimirDatas.Checked then
  begin
    TextoDatas := 'EMB: 25/10/2026   VAL: 30/10/2026';
    if chkImprimirHora.Checked then
      TextoDatas := TextoDatas + ' 16:45';
    if chkImprimirTara.Checked then
      TextoDatas := TextoDatas + '   TARA: 0.020 kg';
    lblPreviaDatas.Caption := TextoDatas;
    lblPreviaDatas.Visible := True;
  end
  else
    lblPreviaDatas.Visible := False;

  { Valores }
  lblPreviaPrecoUnit.Visible := chkImprimirPrecoKg.Checked;
  lblPreviaPesoLiq.Visible := chkImprimirPeso.Checked;
  lblPreviaTotalTit.Visible := chkImprimirTotal.Checked;
  lblPreviaTotalVal.Visible := chkImprimirTotal.Checked;
  pnlPreviaValores.Visible := chkImprimirPrecoKg.Checked or chkImprimirPeso.Checked or chkImprimirTotal.Checked;

  { Código de Barras }
  pnlPreviaBarras.Visible := chkImprimirBarras.Checked;
  case cbPadraoBarras.ItemIndex of
    1: lblPreviaBarrasNumero.Caption := '2  001010  001250'; // Peso
    2: lblPreviaBarrasNumero.Caption := '2  010100  087385'; // 4 dígitos
    3: lblPreviaBarrasNumero.Caption := '7  891234  567890'; // Livre
  else
    lblPreviaBarrasNumero.Caption := '2  001010  087385'; // Preço Total
  end;

  { Tabela Nutricional RDC 429 e Ingredientes }
  case Formato of
    0: // 40x40 Compacta: Não cabe tabela nutricional nem ingredientes
    begin
      pnlEtiquetaFisica.Width := 340;
      pnlEtiquetaFisica.Height := 340;
      pnlPreviaNutricional.Visible := False;
      lblPreviaIngredientes.Visible := False;
    end;
    1: // 60x30 Horizontal
    begin
      pnlEtiquetaFisica.Width := 440;
      pnlEtiquetaFisica.Height := 280;
      pnlPreviaNutricional.Visible := False;
      lblPreviaIngredientes.Visible := False;
    end;
    2: // 60x40 Padrão
    begin
      pnlEtiquetaFisica.Width := 440;
      pnlEtiquetaFisica.Height := 420;
      pnlPreviaNutricional.Visible := False;
      lblPreviaIngredientes.Visible := chkImprimirReceita.Checked;
    end;
    3: // 60x60 Nutricional
    begin
      pnlEtiquetaFisica.Width := 440;
      pnlEtiquetaFisica.Height := 510;
      pnlPreviaNutricional.Visible := chkImprimirNutricional.Checked;
      lblPreviaIngredientes.Visible := chkImprimirReceita.Checked;
    end;
    4: // 60x70 Expandida
    begin
      pnlEtiquetaFisica.Width := 440;
      pnlEtiquetaFisica.Height := 560;
      pnlPreviaNutricional.Visible := chkImprimirNutricional.Checked;
      lblPreviaIngredientes.Visible := chkImprimirReceita.Checked;
    end;
    5: // 60x80 Industrial
    begin
      pnlEtiquetaFisica.Width := 440;
      pnlEtiquetaFisica.Height := 600;
      pnlPreviaNutricional.Visible := chkImprimirNutricional.Checked;
      lblPreviaIngredientes.Visible := chkImprimirReceita.Checked;
    end;
  end;

  { Rodapé }
  lblPreviaRodape.Visible := chkImprimirRodape.Checked and (Trim(edtRodape.Text) <> '');
  lblPreviaRodape.Caption := edtRodape.Text;
end;

procedure TFrmEditorEtiquetas.cbBalancaAlvoChange(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.cbTamanhoEtiquetaChange(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.edtNomeLojaChange(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.edtRodapeChange(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.chkElementoClick(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.cbPadraoBarrasChange(Sender: TObject);
begin
  AtualizarPreviaEtiqueta;
end;

procedure TFrmEditorEtiquetas.btnSalvarPadraoClick(Sender: TObject);
begin
  SalvarConfiguracaoINI;
  ShowMessage('Layout e preferências de etiqueta salvos como padrão do sistema com sucesso!'#13#10 +
              'Esses parâmetros serão utilizados automaticamente em todas as próximas sincronizações.');
end;

procedure TFrmEditorEtiquetas.btnEnviarBalancaClick(Sender: TObject);
var
  Driver: IBalancaComunicador;
  Bal: TConfigBalanca;
  Resultado: TResultadoEnvio;
  I, Sucessos, Falhas: Integer;
  MsgRelatorio: string;
begin
  SincronizarTelaParaConfig;
  SalvarConfiguracaoINI;

  Screen.Cursor := crHourGlass;
  try
    Sucessos := 0;
    Falhas := 0;
    MsgRelatorio := '';

    if cbBalancaAlvo.ItemIndex = 0 then
    begin
      { Envia para todas as balanças ativas }
      for I := 0 to FBalancas.Count - 1 do
      begin
        Bal := FBalancas[I];
        if Bal.Ativo then
        begin
          Driver := TFabricaComunicador.CriarComunicador(Bal);
          Resultado := Driver.ConfigurarLayoutEtiqueta(FConfig);

          if Resultado.Sucesso then
          begin
            Inc(Sucessos);
            MsgRelatorio := MsgRelatorio + Format('✅ [%s - %s] %s'#13#10, [Bal.Nome, Bal.IP, Resultado.Mensagem]);
          end
          else
          begin
            Inc(Falhas);
            MsgRelatorio := MsgRelatorio + Format('❌ [%s - %s] %s'#13#10, [Bal.Nome, Bal.IP, Resultado.Mensagem]);
          end;
        end;
      end;

      if Sucessos > 0 then
        ShowMessage(Format('Sincronização de layout concluída!'#13#10#13#10 +
                           'Balanças atualizadas com sucesso: %d'#13#10 +
                           'Falhas de conexão: %d'#13#10#13#10 +
                           'Relatório:'#13#10'%s', [Sucessos, Falhas, MsgRelatorio]))
      else
        ShowMessage(Format('Não foi possível sincronizar o layout com as balanças:'#13#10#13#10'%s', [MsgRelatorio]));
    end
    else
    begin
      { Envia para uma balança individual selecionada }
      if Assigned(cbBalancaAlvo.Items.Objects[cbBalancaAlvo.ItemIndex]) then
      begin
        Bal := TConfigBalanca(cbBalancaAlvo.Items.Objects[cbBalancaAlvo.ItemIndex]);
        Driver := TFabricaComunicador.CriarComunicador(Bal);
        Resultado := Driver.ConfigurarLayoutEtiqueta(FConfig);

        if Resultado.Sucesso then
          ShowMessage(Format('🎉 Layout de etiqueta configurado e gravado com sucesso!'#13#10#13#10 +
                             'Balança: %s (%s - %s:%d)'#13#10 +
                             'Modelo de Etiqueta: %s'#13#10#13#10 +
                             '%s', [Bal.Nome, Bal.ObterDescricaoFabricante, Bal.IP, Bal.Porta, FConfig.TamanhoDescricao, Resultado.Mensagem]))
        else
          ShowMessage(Format('Falha ao gravar layout na balança [%s]:'#13#10#13#10'%s', [Bal.Nome, Resultado.Mensagem]));
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
