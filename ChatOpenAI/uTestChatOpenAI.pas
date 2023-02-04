unit uTestChatOpenAI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, Datasnap.Provider, Datasnap.DBClient, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids , System.Threading, Vcl.StdCtrls, Vcl.Imaging.jpeg,
  Vcl.ExtCtrls;

type
  TuTest = class(TForm)
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    DataSource1: TDataSource;
    ClientDataSet2: TClientDataSet;
    DataSetProvider2: TDataSetProvider;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    CheckBox1: TCheckBox;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
    procedure p ;
  public
    { Public declarations }

  end;

var
  uTest: TuTest;

implementation

{$R *.dfm}


procedure CopyRecord(DataSetOrigem, DataSetDestino: TClientDataSet );
var
  FieldOrigem, FieldDestino: TField;
begin
  DataSetDestino.Append;
  for FieldOrigem in DataSetOrigem.Fields do
  begin
    FieldDestino := DataSetDestino.FieldByName(FieldOrigem.FieldName);
    FieldDestino.Value := FieldOrigem.Value;
  end;
  DataSetDestino.Post;
end;

procedure CopyAllRecords(DataSetOrigem, DataSetDestino: TClientDataSet);
var
  FieldOrigem: TField;
  FieldDestino: array of TField;
  i: Integer;
begin
  SetLength(FieldDestino, DataSetOrigem.FieldCount);
  DataSetOrigem.DisableControls;
  for i := 0 to DataSetOrigem.FieldCount - 1 do
    FieldDestino[i] := DataSetDestino.FieldByName(DataSetOrigem.Fields[i].FieldName);

  DataSetDestino.DisableControls;
  try
    DataSetOrigem.First;
    while not DataSetOrigem.Eof do
    begin
      DataSetDestino.Append;
      for i := 0 to DataSetOrigem.FieldCount - 1 do
      begin
        FieldOrigem := DataSetOrigem.Fields[i];
        FieldDestino[i].Value := FieldOrigem.Value;
      end;
      DataSetDestino.Post;

      DataSetOrigem.Next;
    end;
  finally
    DataSetDestino.EnableControls;
    DataSetOrigem.EnableControls;

    try
     DataSetDestino.Refresh ;
    except
     //clean cache
     DataSetDestino.MergeChangeLog ;
    end;

  end;
end;


procedure TuTest.FormCreate(Sender: TObject);
var
 i :Integer;
begin
  ClientDataSet1.Close;
  ClientDataSet1.FieldDefs.Clear;
  ClientDataSet1.FieldDefs.add('codigo',ftInteger);
  ClientDataSet1.FieldDefs.add('nome',ftString,50);
  ClientDataSet1.CreateDataSet;

  ClientDataSet2.Close;
  ClientDataSet2.FieldDefs.Clear;
  ClientDataSet2.FieldDefs.add('codigo',ftInteger);
  ClientDataSet2.FieldDefs.add('nome',ftString,50);
  ClientDataSet2.CreateDataSet;
  for i := 0 to 100000 do
  begin
     ClientDataSet1.Append;
     ClientDataSet1.FieldByName('codigo').Value := i;
     ClientDataSet1.FieldByName('nome').Value := IntToStr(i) + ' registros';
     ClientDataSet1.post;
  end;
end;

procedure TuTest.p;
begin
 CopyAllRecords (ClientDataSet1, ClientDataSet2);
end;

procedure TuTest.SpeedButton1Click(Sender: TObject);
begin
    CopyRecord (ClientDataSet1, ClientDataSet2 );
end;

procedure TuTest.SpeedButton2Click(Sender: TObject);
var
  Inicio: TDateTime;
  Fim: TDateTime;
  Tasks: array [0..2] of ITask;
begin
  Inicio := Now;
  if CheckBox1.Checked then
  begin
    Tasks[0] := TTask.Create( p );
    Tasks[0].Start;
  end
  else
  CopyAllRecords (ClientDataSet1, ClientDataSet2);

  Fim := Now;
  ShowMessage(Format('inseridos '+InttoStr(ClientDataSet2.RecordCount)+ ' registro(s) em %s segundos.',
  [FormatDateTime('ss', Fim - Inicio)]));
end;


end.
