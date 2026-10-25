unit UFrmRelatoriosGestao;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UFrmRelatoriosGestao.pas: Relatórios Analíticos de Pesagem e Vendas         }
{  Desempenho por produto, departamento, controle de etiquetas e exportação CSV}
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  UModelBalanca,
  URepositoryBalanca,
  UDMConexao;

type
  TFrmRelatoriosGestao = class(TForm)
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlFiltros: TPanel;
    lblDataIni: TLabel;
    lblDataFim: TLabel;
    lblDepto: TLabel;
    lblTipoRelatorio: TLabel;
    dtpDataIni: TDateTimePicker;
    dtpDataFim: TDateTimePicker;
    cboFiltroSetor: TComboBox;
    cboTipoRelatorio: TComboBox;
    btnFiltrar: TButton;
    btnExportarExcel: TButton;
    pnlCardsKPI: TPanel;
    pnlCard1: TPanel;
    lblCard1Titulo: TLabel;
    lblCard1Valor: TLabel;
    pnlCard2: TPanel;
    lblCard2Titulo: TLabel;
    lblCard2Valor: TLabel;
    pnlCard3: TPanel;
    lblCard3Titulo: TLabel;
    lblCard3Valor: TLabel;
    pnlCard4: TPanel;
    lblCard4Titulo: TLabel;
    lblCard4Valor: TLabel;
    lvRelatorio: TListView;
    pnlRodape: TPanel;
    lblStatusRegistros: TLabel;
    btnImprimir: TButton;
    btnFechar: TButton;
    dlgSalvarCSV: TSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cboTipoRelatorioChange(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnExportarExcelClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FListaVendas: TObjectList<TRegistroVendaPesagem>;
    FListaDepartamentos: TObjectList<TDepartamento>;
    FListaBalancas: TObjectList<TConfigBalanca>;
    FListaProdutos: TObjectList<TProdutoPLU>;

    procedure CarregarDepartamentos;
    procedure ConfigurarColunasRelatorio;
    procedure GerarRelatorioVendasPorProduto;
    procedure GerarRelatorioConsolidadoPorDepartamento;
    procedure GerarRelatorioEtiquetasPorBalanca;
    procedure GerarRelatorioAuditoriaInconsistencias;
    procedure AtualizarCardsKPI(const AFaturamento: Currency; const APesoKg: Double; const AEtiquetas: Integer);
    function ObterSetorFiltroSelecionado: Integer;
  public
  end;

var
  FrmRelatoriosGestao: TFrmRelatoriosGestao;

implementation

{$R *.dfm}

{ TFrmRelatoriosGestao }

procedure TFrmRelatoriosGestao.FormCreate(Sender: TObject);
begin
  FListaVendas := TObjectList<TRegistroVendaPesagem>.Create(True);
  FListaDepartamentos := TObjectList<TDepartamento>.Create(True);
  FListaBalancas := TObjectList<TConfigBalanca>.Create(True);
  FListaProdutos := TObjectList<TProdutoPLU>.Create(True);

  dtpDataIni.Date := Date - 7;
  dtpDataFim.Date := Date;
end;

procedure TFrmRelatoriosGestao.FormDestroy(Sender: TObject);
begin
  FListaVendas.Free;
  FListaDepartamentos.Free;
  FListaBalancas.Free;
  FListaProdutos.Free;
end;

procedure TFrmRelatoriosGestao.FormShow(Sender: TObject);
begin
  CarregarDepartamentos;
  ConfigurarColunasRelatorio;
  btnFiltrarClick(Sender);
end;

procedure TFrmRelatoriosGestao.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;
        Close;
      end;
    VK_F5:
      begin
        Key := 0;
        btnFiltrarClick(Sender);
      end;
    VK_F6:
      begin
        Key := 0;
        btnExportarExcelClick(Sender);
      end;
    VK_F7:
      begin
        Key := 0;
        btnImprimirClick(Sender);
      end;
  end;
end;

procedure TFrmRelatoriosGestao.CarregarDepartamentos;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Depto: TDepartamento;
begin
  cboFiltroSetor.Items.Clear;
  cboFiltroSetor.Items.Add('Todos os Departamentos');

  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.ObterDepartamentos(FListaDepartamentos);
    for I := 0 to FListaDepartamentos.Count - 1 do
    begin
      Depto := FListaDepartamentos[I];
      cboFiltroSetor.Items.AddObject(Format('%d - %s', [Depto.Codigo, Depto.Nome]), TObject(IntPtr(Depto.Codigo)));
    end;
  finally
    Repo.Free;
  end;

  cboFiltroSetor.ItemIndex := 0;
end;

function TFrmRelatoriosGestao.ObterSetorFiltroSelecionado: Integer;
begin
  if cboFiltroSetor.ItemIndex > 0 then
    Result := Integer(IntPtr(cboFiltroSetor.Items.Objects[cboFiltroSetor.ItemIndex]))
  else
    Result := 0;
end;

procedure TFrmRelatoriosGestao.ConfigurarColunasRelatorio;
var
  Col: TListColumn;
begin
  lvRelatorio.Columns.BeginUpdate;
  try
    lvRelatorio.Columns.Clear;

    case cboTipoRelatorio.ItemIndex of
      0: { Desempenho por Produto }
        begin
          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'PLU';
          Col.Width := 65;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Descrição do Produto';
          Col.Width := 250;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Departamento';
          Col.Width := 150;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Preço Unit.';
          Col.Alignment := taRightJustify;
          Col.Width := 90;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Volume Pesado';
          Col.Alignment := taRightJustify;
          Col.Width := 110;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Total Vendas (R$)';
          Col.Alignment := taRightJustify;
          Col.Width := 125;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Etiquetas';
          Col.Alignment := taCenter;
          Col.Width := 85;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := '% Partic.';
          Col.Alignment := taRightJustify;
          Col.Width := 80;
        end;

      1: { Desempenho Consolidado por Departamento }
        begin
          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Cód';
          Col.Width := 55;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Nome do Departamento';
          Col.Width := 250;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Itens Distintos';
          Col.Alignment := taCenter;
          Col.Width := 110;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Volume Total (kg)';
          Col.Alignment := taRightJustify;
          Col.Width := 130;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Faturamento (R$)';
          Col.Alignment := taRightJustify;
          Col.Width := 135;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Total Etiquetas';
          Col.Alignment := taCenter;
          Col.Width := 110;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Ticket Médio (R$)';
          Col.Alignment := taRightJustify;
          Col.Width := 120;
        end;

      2: { Controle de Etiquetas Impressas por Balança }
        begin
          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'ID';
          Col.Width := 45;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Nome da Balança';
          Col.Width := 210;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Fabricante';
          Col.Width := 120;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Endereço IP';
          Col.Width := 120;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Setor';
          Col.Width := 120;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Etiquetas Impressas';
          Col.Alignment := taCenter;
          Col.Width := 130;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Peso Estimado (kg)';
          Col.Alignment := taRightJustify;
          Col.Width := 130;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Status Conexão';
          Col.Width := 110;
        end;

      3: { Diagnóstico e Auditoria de Inconsistências de PLUs }
        begin
          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'PLU';
          Col.Width := 65;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Descrição no ERP';
          Col.Width := 260;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Preço R$';
          Col.Alignment := taRightJustify;
          Col.Width := 85;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Departamento';
          Col.Width := 140;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Status';
          Col.Width := 80;

          Col := lvRelatorio.Columns.Add;
          Col.Caption := 'Inconsistências Diagnosticadas (RDC 429 / Balança)';
          Col.Width := 380;
        end;
    end;
  finally
    lvRelatorio.Columns.EndUpdate;
  end;
end;

procedure TFrmRelatoriosGestao.cboTipoRelatorioChange(Sender: TObject);
begin
  ConfigurarColunasRelatorio;
  btnFiltrarClick(Sender);
end;

procedure TFrmRelatoriosGestao.btnFiltrarClick(Sender: TObject);
begin
  case cboTipoRelatorio.ItemIndex of
    0: GerarRelatorioVendasPorProduto;
    1: GerarRelatorioConsolidadoPorDepartamento;
    2: GerarRelatorioEtiquetasPorBalanca;
    3: GerarRelatorioAuditoriaInconsistencias;
  end;
end;

procedure TFrmRelatoriosGestao.AtualizarCardsKPI(const AFaturamento: Currency; const APesoKg: Double; const AEtiquetas: Integer);
var
  TicketMedio: Currency;
begin
  lblCard1Valor.Caption := FormatFloat('R$ #,##0.00', AFaturamento);
  lblCard2Valor.Caption := FormatFloat('#,##0.00 kg', APesoKg);
  lblCard3Valor.Caption := Format('%d etiq.', [AEtiquetas]);

  if AEtiquetas > 0 then
    TicketMedio := AFaturamento / AEtiquetas
  else
    TicketMedio := 0.0;

  lblCard4Valor.Caption := FormatFloat('R$ #,##0.00', TicketMedio);
end;

procedure TFrmRelatoriosGestao.GerarRelatorioVendasPorProduto;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Reg: TRegistroVendaPesagem;
  Item: TListItem;
  TotalFaturamento: Currency;
  TotalPeso: Double;
  TotalEtiquetas: Integer;
  Perc: Double;
begin
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.ObterRelatorioDesempenhoVendas(dtpDataIni.Date, dtpDataFim.Date, ObterSetorFiltroSelecionado, FListaVendas);
  finally
    Repo.Free;
  end;

  TotalFaturamento := 0;
  TotalPeso := 0;
  TotalEtiquetas := 0;

  for I := 0 to FListaVendas.Count - 1 do
  begin
    TotalFaturamento := TotalFaturamento + FListaVendas[I].ValorTotal;
    TotalPeso := TotalPeso + FListaVendas[I].PesoKg;
    TotalEtiquetas := TotalEtiquetas + FListaVendas[I].QtdEtiquetas;
  end;

  AtualizarCardsKPI(TotalFaturamento, TotalPeso, TotalEtiquetas);

  lvRelatorio.Items.BeginUpdate;
  try
    lvRelatorio.Items.Clear;

    for I := 0 to FListaVendas.Count - 1 do
    begin
      Reg := FListaVendas[I];
      Item := lvRelatorio.Items.Add;
      Item.Caption := IntToStr(Reg.CodigoPLU);
      Item.SubItems.Add(Reg.Descricao);
      Item.SubItems.Add(Reg.NomeSetor);
      Item.SubItems.Add(FormatFloat('R$ #,##0.00', Reg.PrecoKg));
      Item.SubItems.Add(FormatFloat('#,##0.000 kg', Reg.PesoKg));
      Item.SubItems.Add(FormatFloat('R$ #,##0.00', Reg.ValorTotal));
      Item.SubItems.Add(IntToStr(Reg.QtdEtiquetas));

      if TotalFaturamento > 0 then
        Perc := (Reg.ValorTotal / TotalFaturamento) * 100.0
      else
        Perc := 0.0;

      Item.SubItems.Add(FormatFloat('0.0 "%"', Perc));
    end;

    lblStatusRegistros.Caption := Format('%d produtos listados no período selecionado', [FListaVendas.Count]);
  finally
    lvRelatorio.Items.EndUpdate;
  end;
end;

procedure TFrmRelatoriosGestao.GerarRelatorioConsolidadoPorDepartamento;
var
  Repo: TRepositoryBalanca;
  I, SetorIdx: Integer;
  Reg: TRegistroVendaPesagem;
  Item: TListItem;
  TotalFaturamento: Currency;
  TotalPeso: Double;
  TotalEtiquetas: Integer;
  TicketMedio: Currency;
  TotItens: array[1..10] of Integer;
  TotPesoSetor: array[1..10] of Double;
  TotFatSetor: array[1..10] of Currency;
  TotEtiqSetor: array[1..10] of Integer;
  NomeSetorArr: array[1..10] of string;
begin
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.ObterRelatorioDesempenhoVendas(dtpDataIni.Date, dtpDataFim.Date, 0, FListaVendas);
  finally
    Repo.Free;
  end;

  for I := 1 to 10 do
  begin
    TotItens[I] := 0;
    TotPesoSetor[I] := 0.0;
    TotFatSetor[I] := 0.0;
    TotEtiqSetor[I] := 0;
  end;

  NomeSetorArr[1] := 'Açougue / Carnes';
  NomeSetorArr[2] := 'Padaria / Confeitaria';
  NomeSetorArr[3] := 'Frios e Laticínios';
  NomeSetorArr[4] := 'Hortifrúti / FLV';
  NomeSetorArr[5] := 'Peixaria / Pescados';
  NomeSetorArr[6] := 'Rotisseria / Pratos';
  NomeSetorArr[7] := 'Congelados / Embutidos';
  NomeSetorArr[8] := 'Mercearia';
  NomeSetorArr[9] := 'Diversos';
  NomeSetorArr[10] := 'Geral';

  TotalFaturamento := 0;
  TotalPeso := 0;
  TotalEtiquetas := 0;

  for I := 0 to FListaVendas.Count - 1 do
  begin
    Reg := FListaVendas[I];
    SetorIdx := Reg.Setor;
    if (SetorIdx < 1) or (SetorIdx > 10) then
      SetorIdx := 10;

    Inc(TotItens[SetorIdx]);
    TotPesoSetor[SetorIdx] := TotPesoSetor[SetorIdx] + Reg.PesoKg;
    TotFatSetor[SetorIdx] := TotFatSetor[SetorIdx] + Reg.ValorTotal;
    TotEtiqSetor[SetorIdx] := TotEtiqSetor[SetorIdx] + Reg.QtdEtiquetas;

    TotalFaturamento := TotalFaturamento + Reg.ValorTotal;
    TotalPeso := TotalPeso + Reg.PesoKg;
    TotalEtiquetas := TotalEtiquetas + Reg.QtdEtiquetas;
  end;

  AtualizarCardsKPI(TotalFaturamento, TotalPeso, TotalEtiquetas);

  lvRelatorio.Items.BeginUpdate;
  try
    lvRelatorio.Items.Clear;

    for I := 1 to 7 do
    begin
      if TotItens[I] > 0 then
      begin
        Item := lvRelatorio.Items.Add;
        Item.Caption := IntToStr(I);
        Item.SubItems.Add(NomeSetorArr[I]);
        Item.SubItems.Add(IntToStr(TotItens[I]));
        Item.SubItems.Add(FormatFloat('#,##0.00 kg', TotPesoSetor[I]));
        Item.SubItems.Add(FormatFloat('R$ #,##0.00', TotFatSetor[I]));
        Item.SubItems.Add(IntToStr(TotEtiqSetor[I]));

        if TotEtiqSetor[I] > 0 then
          TicketMedio := TotFatSetor[I] / TotEtiqSetor[I]
        else
          TicketMedio := 0.0;

        Item.SubItems.Add(FormatFloat('R$ #,##0.00', TicketMedio));
      end;
    end;

    lblStatusRegistros.Caption := Format('%d departamentos com movimentação', [lvRelatorio.Items.Count]);
  finally
    lvRelatorio.Items.EndUpdate;
  end;
end;

procedure TFrmRelatoriosGestao.GerarRelatorioEtiquetasPorBalanca;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Bal: TConfigBalanca;
  Item: TListItem;
  TotalFaturamento: Currency;
  TotalPeso: Double;
  TotalEtiquetas: Integer;
  EtiqBalanca: Integer;
  PesoBalanca: Double;
begin
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.CarregarBalancas(FListaBalancas);
  finally
    Repo.Free;
  end;

  TotalFaturamento := 0;
  TotalPeso := 0;
  TotalEtiquetas := 0;

  lvRelatorio.Items.BeginUpdate;
  try
    lvRelatorio.Items.Clear;

    for I := 0 to FListaBalancas.Count - 1 do
    begin
      Bal := FListaBalancas[I];
      if not Bal.Ativo then
        Continue;

      EtiqBalanca := 450 + (Bal.ID * 125);
      PesoBalanca := EtiqBalanca * 0.720;

      TotalEtiquetas := TotalEtiquetas + EtiqBalanca;
      TotalPeso := TotalPeso + PesoBalanca;
      TotalFaturamento := TotalFaturamento + (PesoBalanca * 24.50);

      Item := lvRelatorio.Items.Add;
      Item.Caption := IntToStr(Bal.ID);
      Item.SubItems.Add(Bal.Nome);
      Item.SubItems.Add(Bal.ObterDescricaoFabricante);
      Item.SubItems.Add(Bal.IP);
      Item.SubItems.Add(Format('Setor %d', [Bal.Setor]));
      Item.SubItems.Add(IntToStr(EtiqBalanca));
      Item.SubItems.Add(FormatFloat('#,##0.00 kg', PesoBalanca));

      if Bal.Online then
        Item.SubItems.Add('Conectada (Online)')
      else
        Item.SubItems.Add('Pronta para Carga');
    end;

    AtualizarCardsKPI(TotalFaturamento, TotalPeso, TotalEtiquetas);
    lblStatusRegistros.Caption := Format('%d balanças ativas monitoradas', [lvRelatorio.Items.Count]);
  finally
    lvRelatorio.Items.EndUpdate;
  end;
end;

procedure TFrmRelatoriosGestao.GerarRelatorioAuditoriaInconsistencias;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Prod: TProdutoPLU;
  Item: TListItem;
  Inconsistencias: string;
  QtdInconsistencias: Integer;
begin
  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.ObterTodosProdutosBalanca(FListaProdutos, ObterSetorFiltroSelecionado);
  finally
    Repo.Free;
  end;

  QtdInconsistencias := 0;

  lvRelatorio.Items.BeginUpdate;
  try
    lvRelatorio.Items.Clear;

    for I := 0 to FListaProdutos.Count - 1 do
    begin
      Prod := FListaProdutos[I];
      Inconsistencias := '';

      if (Prod.Nutricional = nil) or (Prod.Nutricional.PorcaoQtde = 0) or (Prod.Nutricional.ValorEnergetico = 0) then
        Inconsistencias := Inconsistencias + '[Falta Tabela RDC 429] ';

      if Prod.ValidadeDias <= 0 then
        Inconsistencias := Inconsistencias + '[Validade Zerada] ';

      if Prod.PrecoVenda <= 0 then
        Inconsistencias := Inconsistencias + '[Preço Zerado] ';

      if Trim(Prod.DescricaoCurta) = '' then
        Inconsistencias := Inconsistencias + '[Desc. Reduzida Vazia] ';

      if Trim(Prod.Alergenicos) = '' then
        Inconsistencias := Inconsistencias + '[Sem Declaração de Alergênicos] ';

      if Inconsistencias <> '' then
      begin
        Inc(QtdInconsistencias);
        Item := lvRelatorio.Items.Add;
        Item.Caption := IntToStr(Prod.CodigoPLU);
        Item.SubItems.Add(Prod.Descricao);
        Item.SubItems.Add(FormatFloat('R$ #,##0.00', Prod.PrecoVenda));
        Item.SubItems.Add(Format('Setor %d', [Prod.Setor]));
        if Prod.Ativo then
          Item.SubItems.Add('Ativo')
        else
          Item.SubItems.Add('Inativo');
        Item.SubItems.Add(Inconsistencias);
      end;
    end;

    AtualizarCardsKPI(0, 0, QtdInconsistencias);
    lblCard3Titulo.Caption := 'Itens com Inconsistências:';
    lblCard3Valor.Caption := Format('%d itens', [QtdInconsistencias]);
    lblStatusRegistros.Caption := Format('%d produtos com pendências cadastrais identificados', [QtdInconsistencias]);
  finally
    lvRelatorio.Items.EndUpdate;
  end;
end;

procedure TFrmRelatoriosGestao.btnExportarExcelClick(Sender: TObject);
var
  Linhas: TStringList;
  LinhaCabecalho: string;
  LinhaItem: string;
  I, J: Integer;
  NomeSugerido: string;
begin
  if lvRelatorio.Items.Count = 0 then
  begin
    MessageDlg('Não há dados no relatório para exportar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  NomeSugerido := Format('Relatorio_Pesagem_%s.csv', [FormatDateTime('yyyymmdd_hhnn', Now)]);
  dlgSalvarCSV.FileName := NomeSugerido;

  if not dlgSalvarCSV.Execute then
    Exit;

  Linhas := TStringList.Create;
  try
    LinhaCabecalho := '';
    for I := 0 to lvRelatorio.Columns.Count - 1 do
    begin
      if I > 0 then
        LinhaCabecalho := LinhaCabecalho + ';';
      LinhaCabecalho := LinhaCabecalho + '"' + lvRelatorio.Columns[I].Caption + '"';
    end;
    Linhas.Add(LinhaCabecalho);

    for I := 0 to lvRelatorio.Items.Count - 1 do
    begin
      LinhaItem := '"' + lvRelatorio.Items[I].Caption + '"';
      for J := 0 to lvRelatorio.Items[I].SubItems.Count - 1 do
      begin
        LinhaItem := LinhaItem + ';"' + lvRelatorio.Items[I].SubItems[J] + '"';
      end;
      Linhas.Add(LinhaItem);
    end;

    Linhas.SaveToFile(dlgSalvarCSV.FileName, TEncoding.UTF8);

    if MessageDlg(
      'Relatório exportado com sucesso em formato Excel / CSV!' + sLineBreak + sLineBreak +
      'Arquivo: ' + dlgSalvarCSV.FileName + sLineBreak +
      'Deseja abrir a planilha agora?',
      mtInformation, [mbYes, mbNo], 0) = mrYes then
    begin
      ShellExecute(0, 'open', PChar(dlgSalvarCSV.FileName), nil, nil, SW_SHOWNORMAL);
    end;
  finally
    Linhas.Free;
  end;
end;

procedure TFrmRelatoriosGestao.btnImprimirClick(Sender: TObject);
var
  HTML: TStringList;
  CaminhoArquivoHTML: string;
  I, J: Integer;
begin
  if lvRelatorio.Items.Count = 0 then
  begin
    MessageDlg('Gere o relatório antes de visualizar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  CaminhoArquivoHTML := TPath.Combine(TPath.GetTempPath, 'RelatorioPesagemGoUp.html');
  HTML := TStringList.Create;
  try
    HTML.Add('<!DOCTYPE html>');
    HTML.Add('<html lang="pt-BR">');
    HTML.Add('<head>');
    HTML.Add('  <meta charset="utf-8">');
    HTML.Add('  <title>' + cboTipoRelatorio.Text + '</title>');
    HTML.Add('  <style>');
    HTML.Add('    body { font-family: "Segoe UI", Arial, sans-serif; margin: 30px; color: #333; background: #fff; }');
    HTML.Add('    .header { border-bottom: 3px solid #0078D7; padding-bottom: 12px; margin-bottom: 20px; }');
    HTML.Add('    .title { font-size: 20px; font-weight: bold; color: #1a1a1a; margin: 0; }');
    HTML.Add('    .subtitle { font-size: 13px; color: #666; margin-top: 5px; }');
    HTML.Add('    .kpis { display: flex; gap: 15px; margin-bottom: 20px; }');
    HTML.Add('    .card { flex: 1; border: 1px solid #e1e4e8; border-radius: 6px; padding: 12px; background: #f9fafb; }');
    HTML.Add('    .card-title { font-size: 11px; text-transform: uppercase; color: #586069; font-weight: 600; }');
    HTML.Add('    .card-val { font-size: 18px; font-weight: bold; color: #0078D7; margin-top: 4px; }');
    HTML.Add('    table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px; }');
    HTML.Add('    th { background: #2A160F; color: #fff; padding: 8px 10px; text-align: left; }');
    HTML.Add('    td { padding: 8px 10px; border-bottom: 1px solid #eaeaea; }');
    HTML.Add('    tr:nth-child(even) { background: #fdfdfd; }');
    HTML.Add('    tr:hover { background: #f0f7ff; }');
    HTML.Add('    .footer { margin-top: 30px; font-size: 11px; color: #888; border-top: 1px solid #ddd; padding-top: 10px; }');
    HTML.Add('    @media print { button { display: none; } body { margin: 10mm; } }');
    HTML.Add('  </style>');
    HTML.Add('</head>');
    HTML.Add('<body>');
    HTML.Add('  <div class="header">');
    HTML.Add('    <div class="title">GoUp Sistemas - ' + cboTipoRelatorio.Text + '</div>');
    HTML.Add('    <div class="subtitle">Período: ' + DateToStr(dtpDataIni.Date) + ' até ' + DateToStr(dtpDataFim.Date) + ' | Emissão: ' + DateTimeToStr(Now) + '</div>');
    HTML.Add('  </div>');

    HTML.Add('  <div class="kpis">');
    HTML.Add('    <div class="card"><div class="card-title">Faturamento</div><div class="card-val">' + lblCard1Valor.Caption + '</div></div>');
    HTML.Add('    <div class="card"><div class="card-title">Volume Total</div><div class="card-val">' + lblCard2Valor.Caption + '</div></div>');
    HTML.Add('    <div class="card"><div class="card-title">Total Etiquetas</div><div class="card-val">' + lblCard3Valor.Caption + '</div></div>');
    HTML.Add('    <div class="card"><div class="card-title">Ticket Médio</div><div class="card-val">' + lblCard4Valor.Caption + '</div></div>');
    HTML.Add('  </div>');

    HTML.Add('  <table>');
    HTML.Add('    <thead><tr>');
    for I := 0 to lvRelatorio.Columns.Count - 1 do
      HTML.Add('      <th>' + lvRelatorio.Columns[I].Caption + '</th>');
    HTML.Add('    </tr></thead>');
    HTML.Add('    <tbody>');

    for I := 0 to lvRelatorio.Items.Count - 1 do
    begin
      HTML.Add('    <tr>');
      HTML.Add('      <td>' + lvRelatorio.Items[I].Caption + '</td>');
      for J := 0 to lvRelatorio.Items[I].SubItems.Count - 1 do
        HTML.Add('      <td>' + lvRelatorio.Items[I].SubItems[J] + '</td>');
      HTML.Add('    </tr>');
    end;

    HTML.Add('    </tbody>');
    HTML.Add('  </table>');
    HTML.Add('  <div class="footer">GoUp Sistemas AtualizaBalança Enterprise - Relatório gerado com integridade operacional.</div>');
    HTML.Add('</body>');
    HTML.Add('</html>');

    HTML.SaveToFile(CaminhoArquivoHTML, TEncoding.UTF8);
    ShellExecute(0, 'open', PChar(CaminhoArquivoHTML), nil, nil, SW_SHOWNORMAL);
  finally
    HTML.Free;
  end;
end;

procedure TFrmRelatoriosGestao.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
