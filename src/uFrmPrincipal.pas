unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Vcl.CheckLst,
  System.Actions, Vcl.ActnList, MIDASLIB, Vcl.Mask, Vcl.DBCtrls, Vcl.DBActns,
  Vcl.Buttons, Vcl.FileCtrl, Pedido;

type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    PageControl1: TPageControl;
    tsImport: TTabSheet;
    tsPedidos: TTabSheet;
    DBGrid1: TDBGrid;
    Panel3: TPanel;
    Button1: TButton;
    odgPrincipal: TOpenDialog;
    cdsPrincipal: TClientDataSet;
    dtsPrincipal: TDataSource;
    cdsPrincipalPEDIDO_ELO7: TStringField;
    cdsPrincipalCOMPRADOR: TStringField;
    cdsPrincipalSTATUS_ELO7: TStringField;
    cdsPrincipalDATA_PEDIDO: TDateField;
    cdsPrincipalTOTAL_ITENS: TSmallintField;
    cdsPrincipalVALOR_TOTAL: TFloatField;
    cdsPrincipalTIPO_FRETE: TStringField;
    cdsPrincipalVALOR_FRETE: TFloatField;
    tsConfig: TTabSheet;
    pnlRodape: TPanel;
    dbgPrincipal: TDBGrid;
    pnlResultado: TPanel;
    pnl1: TPanel;
    pb1: TProgressBar;
    edtCaminhoArquivo: TEdit;
    btnArquivo: TButton;
    btnReset: TButton;
    btnProcessa: TButton;
    actReset: TActionList;
    actCarregaArquivo: TAction;
    stbPrincipal: TStatusBar;
    lbl1: TLabel;
    btnDiretorio: TBitBtn;
    btn2: TBitBtn;
    actCancelConfig: TDataSetCancel;
    actPostConfig: TDataSetPost;
    btn1: TBitBtn;
    actCarregaDiretorioDest: TAction;
    dbePASTA_DESTINO: TDBEdit;
    dbePASTA_ORIGEM: TDBEdit;
    lbl2: TLabel;
    btnCarregaDiretorio: TBitBtn;
    actCarregaDiretorioOrig: TAction;
    dbg1: TDBGrid;
    act1: TAction;
    actProcessaArquivo: TAction;
    procedure Button1Click(Sender: TObject);
    procedure btnArquivoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure actCarregaArquivoExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actCarregaDiretorioDestExecute(Sender: TObject);
    procedure actCarregaDiretorioOrigExecute(Sender: TObject);
    procedure act1Execute(Sender: TObject);
    procedure act1Update(Sender: TObject);
    procedure actProcessaArquivoExecute(Sender: TObject);
    procedure actProcessaArquivoUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uDtmPrincipal, uFrmPedidosHistorico;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
begin
  if not dtmPrincipal.qryVwPedidos.Active then
    dtmPrincipal.qryVwPedidos.Open()
  else
    dtmPrincipal.qryVwPedidos.Refresh;
end;

procedure TfrmPrincipal.DBGrid1DblClick(Sender: TObject);
var
  frmPedidosHis: TfrmPedidosHistorico;
begin
  frmPedidosHis := TfrmPedidosHistorico.Create(nil);
  try
    dtmPrincipal.qryPedidosHis.Close;
    dtmPrincipal.qryPedidosHis.Filtered := False;
    dtmPrincipal.qryPedidosHis.Filter := 'PEDIDO_ELO7 = '''
      + dtmPrincipal.qryPedidosPEDIDO_ELO7.AsString + '''';
    dtmPrincipal.qryPedidosHis.Filtered := True;
    dtmPrincipal.qryPedidosHis.Open();

    frmPedidosHis.ShowModal;

  finally
    FreeAndNil(frmPedidosHis);
  end;

end;

procedure TfrmPrincipal.act1Execute(Sender: TObject);
begin
  edtCaminhoArquivo.Text := '';
  cdsPrincipal.EmptyDataSet;
  pb1.Position := 0;
end;

procedure TfrmPrincipal.act1Update(Sender: TObject);
begin
  (Sender as TAction).Enabled := edtCaminhoArquivo.Text <> '';
end;

procedure TfrmPrincipal.actCarregaArquivoExecute(Sender: TObject);
var
  i, j, iTotalItens: Integer;
  sArquivo, sCampo, sLinha, sPedidoElo7, sComprador, sStatusElo7, sTipoFrete: string;
  slLinha,  slCSV: TStringList;
  dDataPedido: TDate;
  dValorTotal, dValorFrete: Double;
begin
  if FileExists(edtCaminhoArquivo.Text) then
  begin
    sArquivo := ExtractFileName(edtCaminhoArquivo.Text);

    slLinha := TStringList.Create;
    slCSV := TStringList.Create;
    try
      slCSV.LoadFromFile(edtCaminhoArquivo.Text);

      for i := 1 to  slCSV.Count -1 do
      begin
        sLinha := slCSV[i] + ';';
        slLinha.Clear;

        for j := 1 to Length(sLinha) do
        begin
          if sLinha[j] = ';' then
          begin
            slLinha.Add(sCampo);
            sCampo := '';
            Continue;
          end;
          sCampo := sCampo + sLinha[j]
        end;

        sPedidoElo7 := slLinha[0];
        sComprador := slLinha[1];
        sStatusElo7 := slLinha[2];
        dDataPedido := StrToDate(slLinha[3]);
        iTotalItens := StrToInt(slLinha[4]);
        dValorTotal := StrToFloat(StringReplace(slLinha[5], '.', ',', [rfReplaceAll]));
        sTipoFrete := slLinha [6];

        if (slLinha[7] <> '') then
          dValorFrete := StrToFloat(StringReplace(slLinha[7], '.', ',', [rfReplaceAll]))
        else
          dValorFrete := 0;

        cdsPrincipal.Append;
        cdsPrincipalPEDIDO_ELO7.AsString := sPedidoElo7;
        cdsPrincipalCOMPRADOR.AsString := sComprador;
        cdsPrincipalSTATUS_ELO7.AsString := sStatusElo7;
        cdsPrincipalDATA_PEDIDO.Value := dDataPedido;
        cdsPrincipalTOTAL_ITENS.Value := iTotalItens;
        cdsPrincipalVALOR_TOTAL.Value := dValorTotal;
        cdsPrincipalTIPO_FRETE.AsString := sTipoFrete;
        cdsPrincipalVALOR_FRETE.Value := dValorFrete;
        cdsPrincipal.Post;
      end;
      cdsPrincipal.First;
    finally
      slCSV.Free;
    end;
  end;

end;

procedure TfrmPrincipal.actCarregaDiretorioDestExecute(Sender: TObject);
var
  chosenDirectory: string;
begin
  if selectdirectory('Selecione o diret�rio dos importados', 'C:\', chosenDirectory) then
  begin
    if dtmPrincipal.cdsConfig.IsEmpty then
      dtmPrincipal.cdsConfig.Append
    else
      dtmPrincipal.cdsConfig.Edit;
    dtmPrincipal.cdsConfigPASTA_DESTINO.AsString := chosenDirectory;
  end;
end;

procedure TfrmPrincipal.actCarregaDiretorioOrigExecute(Sender: TObject);
var
  chosenDirectory: string;
begin
  if selectdirectory('Selecione o diret�rio dos importados', 'C:\', chosenDirectory) then
  begin
    if dtmPrincipal.cdsConfig.IsEmpty then
      dtmPrincipal.cdsConfig.Append
    else
      dtmPrincipal.cdsConfig.Edit;
    dtmPrincipal.cdsConfigPASTA_ORIGEM.AsString := chosenDirectory;
  end;
end;

procedure TfrmPrincipal.actProcessaArquivoExecute(Sender: TObject);
var
  iRegistrosNovos, iRegistrosAtualizados: Integer;
  sArquivo, sArquivoFinal: string;
  objPedido: TPedido;
begin
  if not cdsPrincipal.IsEmpty then
  begin
    iRegistrosNovos := 0;
    iRegistrosAtualizados := 0;

    sArquivo := ExtractFileName(edtCaminhoArquivo.Text);

    if not dtmPrincipal.qryPedidos.Active then
      dtmPrincipal.qryPedidos.Open();

    pb1.Max := cdsPrincipal.RecordCount;
    pb1.Step := Round(cdsPrincipal.RecordCount / 100);

    cdsPrincipal.First;
    while not cdsPrincipal.Eof do
    begin
      objPedido := TPedido.Create;
      try
        objPedido.PEDIDO_ELO7 := cdsPrincipalPEDIDO_ELO7.AsString;
        objPedido.STATUS_ELO7 := cdsPrincipalSTATUS_ELO7.AsString;
        objPedido.DATA_PEDIDO := cdsPrincipalDATA_PEDIDO.AsDateTime;
        objPedido.TOTAL_ITENS := cdsPrincipalTOTAL_ITENS.AsInteger;
        objPedido.VALOR_TOTAL := cdsPrincipalVALOR_TOTAL.AsFloat;
        objPedido.TIPO_FRETE := cdsPrincipalTIPO_FRETE.AsString;
        objPedido.VALOR_FRETE := cdsPrincipalVALOR_FRETE.AsFloat;
        objPedido.COMPRADOR := cdsPrincipalCOMPRADOR.AsString;

        case objPedido.InserePedido of
          1: Inc(iRegistrosNovos);
          2: Inc(iRegistrosAtualizados);
        end;
      finally
        objPedido.Free;
      end;

      pb1.Position := cdsPrincipal.RecNo +1;
      cdsPrincipal.Next;
    end;

    cdsPrincipal.First;

    dtmPrincipal.qryResultadoImport.Close;
//    dtmPrincipal.qryResultadoImport.ParamByName('pData').AsDate := Now;
    dtmPrincipal.qryResultadoImport.Open();

    sArquivoFinal := Copy(sArquivo, 1,Length(sArquivo) -4)
      + '_' + FormatDateTime('yyyymmdd', Now)
      + ExtractFileExt(sArquivo);

    // registra log com o nome do arquivo e teve registros novos ou atualizados
    dtmPrincipal.sbInsereLog(sArquivoFinal, iRegistrosNovos, iRegistrosAtualizados);

    if DirectoryExists(dtmPrincipal.cdsConfigPASTA_DESTINO.AsString) then
      MoveFile(PChar(edtCaminhoArquivo.Text), PChar(dtmPrincipal.cdsConfigPASTA_DESTINO.AsString + '\' + sArquivoFinal));

    ShowMessage('Conclu�do!!!' + #13
      + 'Registros Inseridos: ' + IntToStr(iRegistrosNovos) + #13
      + 'Registros Atualizados: ' + IntToStr(iRegistrosAtualizados));
  end;
end;

procedure TfrmPrincipal.actProcessaArquivoUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FileExists(edtCaminhoArquivo.Text)
    and not cdsPrincipal.IsEmpty;
end;

procedure TfrmPrincipal.btnArquivoClick(Sender: TObject);
begin
  if DirectoryExists(dtmPrincipal.PathOrigem) then
    odgPrincipal.InitialDir := dtmPrincipal.PathOrigem;

  if odgPrincipal.Execute then
  begin
    edtCaminhoArquivo.Text := odgPrincipal.FileName;

//    if FindFirst(ExtractFileDir(odgPrincipal.FileName) + '\*.csv', faAnyFile, SR) = 0 then
//    begin
//      repeat
//        if (SR.Attr <> faDirectory) then
//        begin
//          clbPrincipal.AddItem(SR.Name, Self);
//        end;
//      until FindNext(SR) <> 0;
//      FindClose(SR);
//    end;

    actCarregaArquivo.Execute;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  cdsPrincipal.CreateDataSet;
  cdsPrincipal.Open;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  stbPrincipal.Panels[0].Text := 'Server DB: ' + dtmPrincipal.Server;
  stbPrincipal.Panels[1].Text := 'vers�o: ' + dtmPrincipal.Server;
end;

end.
