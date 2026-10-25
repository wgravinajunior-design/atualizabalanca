unit UFrmNutricional;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança Enterprise                           }
{  UFrmNutricional.pas: Visualizador Oficial de Tabela Nutricional RDC 429     }
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
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
  Vcl.Clipbrd,
  UModelBalanca;

type
  TFrmNutricional = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblProdutoInfo: TLabel;
    pnlLupas: TPanel;
    lblRotulagemFrontalTit: TLabel;
    lblLupaAcucar: TLabel;
    lblLupaGordura: TLabel;
    lblLupaSodio: TLabel;
    pnlPorcao: TPanel;
    lblPorcaoTexto: TLabel;
    lvNutricional: TListView;
    pnlRodape: TPanel;
    lblObsAnvisa: TLabel;
    btnCopiarTabela: TButton;
    btnFechar: TButton;

    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFecharClick(Sender: TObject);
    procedure btnCopiarTabelaClick(Sender: TObject);
  private
    FProduto: TProdutoPLU;
    procedure AdicionarNutriente(const ANome: string; const AValor100g, AValorPorcao: Double; const AUnidade: string; const AVDRef: Double);
    procedure AdicionarNutrienteInt(const ANome: string; const AValor100g, AValorPorcao: Integer; const AUnidade: string; const AVDRef: Double);
    procedure AtualizarTabela;
  public
    procedure CarregarProduto(AProduto: TProdutoPLU);
  end;

var
  FrmNutricional: TFrmNutricional;

implementation

{$R *.dfm}

{ TFrmNutricional }

procedure TFrmNutricional.CarregarProduto(AProduto: TProdutoPLU);
begin
  FProduto := AProduto;
  AtualizarTabela;
end;

procedure TFrmNutricional.FormShow(Sender: TObject);
begin
  AtualizarTabela;
end;

procedure TFrmNutricional.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TFrmNutricional.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmNutricional.AdicionarNutriente(const ANome: string; const AValor100g, AValorPorcao: Double;
  const AUnidade: string; const AVDRef: Double);
var
  Item: TListItem;
  PercentualVD: Double;
begin
  Item := lvNutricional.Items.Add;
  Item.Caption := ANome;
  Item.SubItems.Add(Format('%.1f %s', [AValor100g, AUnidade]));
  Item.SubItems.Add(Format('%.1f %s', [AValorPorcao, AUnidade]));

  if AVDRef > 0 then
  begin
    PercentualVD := (AValorPorcao / AVDRef) * 100.0;
    Item.SubItems.Add(Format('%.0f%%', [PercentualVD]));
  end
  else
    Item.SubItems.Add('**');
end;

procedure TFrmNutricional.AdicionarNutrienteInt(const ANome: string; const AValor100g, AValorPorcao: Integer;
  const AUnidade: string; const AVDRef: Double);
var
  Item: TListItem;
  PercentualVD: Double;
begin
  Item := lvNutricional.Items.Add;
  Item.Caption := ANome;
  Item.SubItems.Add(Format('%d %s', [AValor100g, AUnidade]));
  Item.SubItems.Add(Format('%d %s', [AValorPorcao, AUnidade]));

  if AVDRef > 0 then
  begin
    PercentualVD := (AValorPorcao / AVDRef) * 100.0;
    Item.SubItems.Add(Format('%.0f%%', [PercentualVD]));
  end
  else
    Item.SubItems.Add('**');
end;

procedure TFrmNutricional.AtualizarTabela;
var
  N: TInfoNutricional;
  Porcao: Double;
  Fator100g: Double;
  Val100g_Energ: Integer;
  Val100g_Carbo, Val100g_AcucTot, Val100g_AcucAdic, Val100g_Prot: Double;
  Val100g_GordTot, Val100g_GordSat, Val100g_GordTrans, Val100g_Fibra, Val100g_Sodio: Double;
  LupaAcucar, LupaGordura, LupaSodio: Boolean;
begin
  if FProduto = nil then
  begin
    lblProdutoInfo.Caption := 'Nenhum produto selecionado.';
    Exit;
  end;

  lblProdutoInfo.Caption := Format('Produto: [PLU: %d | Cód. ERP: %s] %s',
    [FProduto.CodigoPLU, FProduto.CodigoBarras, FProduto.Descricao]);

  N := FProduto.Nutricional;
  if N.PorcaoQtde > 0 then
    Porcao := N.PorcaoQtde
  else
    Porcao := 50.0; // Padrão 50g

  Fator100g := 100.0 / Porcao;

  Val100g_Energ := Round(N.ValorEnergetico * Fator100g);
  Val100g_Carbo := N.Carboidratos * Fator100g;
  Val100g_AcucTot := N.AcucaresTotais * Fator100g;
  Val100g_AcucAdic := N.AcucaresAdicionados * Fator100g;
  Val100g_Prot := N.Proteinas * Fator100g;
  Val100g_GordTot := N.GordurasTotais * Fator100g;
  Val100g_GordSat := N.GordurasSaturadas * Fator100g;
  Val100g_GordTrans := N.GordurasTrans * Fator100g;
  Val100g_Fibra := N.FibraAlimentar * Fator100g;
  Val100g_Sodio := N.Sodio * Fator100g;

  { Regras Oficiais Anvisa IN 75/2020 para Alimentos Sólidos:
    - Açúcar Adicionado >= 15g por 100g
    - Gordura Saturada >= 6g por 100g
    - Sódio >= 600mg por 100g }
  LupaAcucar := (Val100g_AcucAdic >= 15.0);
  LupaGordura := (Val100g_GordSat >= 6.0);
  LupaSodio := (Val100g_Sodio >= 600.0);

  if LupaAcucar then
  begin
    lblLupaAcucar.Color := clBlack;
    lblLupaAcucar.Caption := '🔍 ALTO EM AÇÚCAR';
  end
  else
  begin
    lblLupaAcucar.Color := $00E0E0E0;
    lblLupaAcucar.Font.Color := clGray;
    lblLupaAcucar.Caption := 'Açúcar Normal';
  end;

  if LupaGordura then
  begin
    lblLupaGordura.Color := clBlack;
    lblLupaGordura.Caption := '🔍 ALTO EM GORD. SAT.';
  end
  else
  begin
    lblLupaGordura.Color := $00E0E0E0;
    lblLupaGordura.Font.Color := clGray;
    lblLupaGordura.Caption := 'Gord. Sat. Normal';
  end;

  if LupaSodio then
  begin
    lblLupaSodio.Color := clBlack;
    lblLupaSodio.Caption := '🔍 ALTO EM SÓDIO';
  end
  else
  begin
    lblLupaSodio.Color := $00E0E0E0;
    lblLupaSodio.Font.Color := clGray;
    lblLupaSodio.Caption := 'Sódio Normal';
  end;

  lblPorcaoTexto.Caption := Format('Porção: %.0f g | Unidade de Venda: %s', [Porcao, FProduto.DescricaoCurta]);

  lvNutricional.Items.BeginUpdate;
  try
    lvNutricional.Items.Clear;

    { Valores Diários de Referência da Anvisa (RDC 429):
      Energia: 2000 kcal
      Carboidratos: 300 g
      Açúcares Adicionados: 50 g
      Proteínas: 50 g
      Gorduras Totais: 65 g
      Gorduras Saturadas: 20 g
      Gorduras Trans: sem VD definido
      Fibras: 25 g
      Sódio: 2000 mg }
    AdicionarNutrienteInt('Valor Energético (kcal)', Val100g_Energ, N.ValorEnergetico, 'kcal', 2000.0);
    AdicionarNutriente('Carboidratos', Val100g_Carbo, N.Carboidratos, 'g', 300.0);
    AdicionarNutriente('  Açúcares Totais', Val100g_AcucTot, N.AcucaresTotais, 'g', 0.0);
    AdicionarNutriente('  Açúcares Adicionados', Val100g_AcucAdic, N.AcucaresAdicionados, 'g', 50.0);
    AdicionarNutriente('Proteínas', Val100g_Prot, N.Proteinas, 'g', 50.0);
    AdicionarNutriente('Gorduras Totais', Val100g_GordTot, N.GordurasTotais, 'g', 65.0);
    AdicionarNutriente('  Gorduras Saturadas', Val100g_GordSat, N.GordurasSaturadas, 'g', 20.0);
    AdicionarNutriente('  Gorduras Trans', Val100g_GordTrans, N.GordurasTrans, 'g', 0.0);
    AdicionarNutriente('Fibra Alimentar', Val100g_Fibra, N.FibraAlimentar, 'g', 25.0);
    AdicionarNutriente('Sódio', Val100g_Sodio, N.Sodio, 'mg', 2000.0);
  finally
    lvNutricional.Items.EndUpdate;
  end;
end;

procedure TFrmNutricional.btnCopiarTabelaClick(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Add(Format('TABELA NUTRICIONAL - %s', [lblProdutoInfo.Caption]));
    SL.Add(lblPorcaoTexto.Caption);
    SL.Add('-------------------------------------------------------------');
    SL.Add('NUTRIENTE'#9'100g'#9'PORCAO'#9'%VD*');

    for I := 0 to lvNutricional.Items.Count - 1 do
    begin
      SL.Add(Format('%s'#9'%s'#9'%s'#9'%s', [
        lvNutricional.Items[I].Caption,
        lvNutricional.Items[I].SubItems[0],
        lvNutricional.Items[I].SubItems[1],
        lvNutricional.Items[I].SubItems[2]
      ]));
    end;
    SL.Add('-------------------------------------------------------------');
    SL.Add(lblObsAnvisa.Caption);

    Clipboard.AsText := SL.Text;
    ShowMessage('Tabela Nutricional copiada para a área de transferência com sucesso!');
  finally
    SL.Free;
  end;
end;

end.
