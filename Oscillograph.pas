unit Oscillograph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ColorGrd, Vcl.Samples.Gauges, Vcl.Touch.Keyboard, Vcl.ComCtrls, Vcl.Mask,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Grids, Vcl.Menus,
  System.Actions, Vcl.ActnList, Vcl.XPMan, Vcl.ExtDlgs, Vcl.ImgList,
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series,
  VclTee.TeeGDIPlus;

type
  TForm1 = class(TForm)
    TrackBar1: TTrackBar;
    StaticText4: TStaticText;
    Edit1: TEdit;
    UpDown1: TUpDown;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    GroupBox2: TGroupBox;
    Edit2: TEdit;
    UpDown2: TUpDown;
    Edit3: TEdit;
    UpDown3: TUpDown;
    ComboBox2: TComboBox;
    Label5: TLabel;
    Button1: TButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    UpDown4: TUpDown;
    UpDown5: TUpDown;
    Edit4: TEdit;
    Edit5: TEdit;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    RadioGroup1: TRadioGroup;
    Button2: TButton;
    Chart1: TChart;
    Button3: TButton;
    Timer1: TTimer;
    SaveDialog1: TSaveDialog;
    Series1: TLineSeries;
    Timer2: TTimer;
    Button4: TButton;
    Button5: TButton;
    BitBtn1: TBitBtn;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    GroupBox6: TGroupBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Timer3: TTimer;
    Label3: TLabel;
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure view(sig,stp:boolean;Sender: TObject);
    procedure UpDown4Click(Sender: TObject; Button: TUDBtnType);
    procedure Timer3Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit4KeyPress(Sender: TObject; var Key: Char);
    procedure Edit5KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
dr=100;                 // Ранг дробления 1-го периода
dr_os=0.01;             // Ранг синхронизации  
speed_r=1;              // Скорость развертки
var
  Form1: TForm1;
    a,d1c,d2c:integer;
    h,sig,stp,s_h,s_upd,z_b,z_c,x_b,x_c:boolean;
    d1,d2,faz,faz2,
    Freq,                              // Частоа
    Amp,                               // Амплитуда
    Dlt,                               // Длительность
    Axsc_t,                            // Масштаб по оси времени
    Axsc_a,                            // Масштаб по оси амплитуды
    t,                                 // Время дискритизации генератора
    dt,                                // Время между точками (Время дискритизации генератора)
    Ts,                                // Период
    mant_f,                            // Мантиса частоты
    mant_a,                            // Мантиса амплитуды
    mant_t_m,                          // Мантиса развертки
    mant_a_m,                          // Мантиса амплитуды осциллографа
    y,                                 // Выходной сигнал генератора
    x                                  // Развертка
    :extended;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
stp:=True;                             // Маркер Вкл/Выкл
view(sig,stp,Sender);                  // Доступность полей ввода Выкл
Freq:=StrToFloat(Edit3.Text)*mant_f;   // Частота
Amp:=StrToFloat(Edit1.Text)*mant_a;    // Амплитуда
Dlt:=StrToFloat(Edit2.Text)/100;       // Длительность
Ts:=1/Freq;                            // Преиод функции
dt:=Ts/dr;                             // Время между точками (1/dr*Freq)
timer1.Interval:=speed_r;                  // Скорость генерирования сигнала
t:=0;
if not(s_h) then                                // Обнуление времени генератора
faz2:=faz;
timer1.Enabled:=true;                  // Запуск генератора
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
d_k:integer;
begin
sig:=SpeedButton3.down;
if sig then
y:=Amp*sin(2*pi*Freq*t+faz2);               // Функция синусоиды
if not(sig) and s_h then begin                 //
if t<=Ts*Dlt then
y:=Amp;
if t>Ts*Dlt then
y:=-Amp;
if t>=Ts then
t:=0;
end;
if not(s_h) and not(sig) then begin
if t=0 then begin
t:=faz2;
end;
if t<=(Ts*Dlt) then
y:=Amp;
if t>(Ts*Dlt) then
y:=-Amp;
if t>=(Ts) then
t:=0;
 label3.Caption:=FloatToStr(t);
end;

t:=t+dt;                               // Время дискритизации генератора
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
timer1.Enabled:=False;                 // Выключение генератора
stp:=False;                            // Маркер Вкл/Выкл
view(sig,stp,Sender);                  // Доступность полей ввода Вкл
end;




procedure TForm1.Button4Click(Sender: TObject);
begin
RadioGroup1.Enabled:=False;            // Запрет доступа к кнопкам синхронизации
button2.Enabled:=false;                // Запрет доступа к кнопке сохранения
groupbox6.Enabled:=false;              // Запрет доступа к кнопкам по спаду/восхожд
if RadioGroup1.ItemIndex=0 then
s_h:=true
else s_h:=false;
x:=0;
chart1.Serieslist[0].Clear ;           // Очистка графика
timer2.Interval:=speed_r;              // Скорость дискретизации осциллографа
h:=false;                              // Переменная синхронизации
d1c:=1;
d2c:=1;
z_b:=False;
z_c:=False;
x_b:=False;
x_c:=False;
timer2.Enabled:=True;                  // Запуск осциллографа
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
timer2.Enabled:=False;                 // Остановка осциллографа
RadioGroup1.Enabled:=True;             // Открытие доступа к кнопкам синхронизации
button2.Enabled:=true;                // Открытие доступа к кнопке сохранения
groupbox6.Enabled:=true;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
Axsc_a:=StrToFloat(Edit5.Text); // Масштаб по оси амплитуды
Axsc_t:=StrToFloat(Edit4.Text); // Масштаб по оси времени
Chart1.LeftAxis.Automatic := False ;        // Отключение авто масштабирования ось y
Chart1.LeftAxis.SetMinMax(-Axsc_a,Axsc_a);     // Задание масштаба ось y
Chart1.BottomAxis.Automatic := False ;// Отключение авто масштабирования ось x
Chart1.BottomAxis.SetMinMax( 0, Axsc_t );// Задание масштаба ось x
if sig then begin
if x=0 then begin
  if (y>=-Amp) and (y<=(-Amp+0.1)) then
    z_b:=True;
  if (y<=Amp) and (y>=(Amp-0.1)) then
    z_b:=False;
  if z_b and (abs(y)<0.1) then
    z_c:=True;
  if not(z_b) and (abs(y)<0.1) then
    z_c:=False;
end;    
if s_h and s_upd then begin
    if z_c and z_b  then begin
      chart1.Serieslist[0].AddXY(x,y/mant_a_m);       // Построение точки
      x:=x+dt/mant_t_m;
      if x>=Axsc_t then begin
        x:=0;
        z_c:=False;
        z_b:=False;
        chart1.Serieslist[0].Clear;
      end; 
    end;
end;
/////
if x=0 then begin
  if (y>=-Amp) and (y<=(-Amp+0.1)) then
    x_b:=False;
  if (y<=Amp) and (y>=(Amp-0.1)) then
    x_b:=True;
  if x_b and (abs(y)<0.1) then
    x_c:=True;
  if not(x_b) and (abs(y)<0.1) then
    x_c:=False;
end;    
if s_h and not(s_upd) then begin
    if x_c and x_b  then begin
      chart1.Serieslist[0].AddXY(x,y/mant_a_m);       // Построение точки
      x:=x+dt/mant_t_m;
      if x>=Axsc_t then begin
        x:=0;
        x_c:=False;
        x_b:=False;
        chart1.Serieslist[0].Clear;
      end; 
    end;
end;
end;
if not(sig) then begin
  if s_h then begin
    if x=0 then begin
      if d1c=1 then
        d1:=y;
      if d1c=2 then
        d2:=y;
      inc(d1c);
      if (d1c=3) and ((d1=-d2) and (d1<0)) and s_upd then
        z_c:=true;
        if (d1c=3) and ((d1=-d2) and (d1>0)) and not(s_upd) then
        z_c:=true;
      if d1c=3 then
      d1c:=1;
    end;
    if z_c then begin
      chart1.Serieslist[0].AddXY(x,y/mant_a_m);       // Построение точки
      x:=x+dt/mant_t_m;
      if x>=Axsc_t then begin
        x:=0;
        z_c:=False;
        chart1.Serieslist[0].Clear;
      end; 
    end;
  end;
end;
if not(s_h) then begin
chart1.Serieslist[0].AddXY(x,y/mant_a_m);       // Построение точки рабочий вариант
x:=x+dt/mant_t_m;
if x>=Axsc_t then begin
  x:=0;
  chart1.Serieslist[0].Clear;
  faz2:=faz;
  end;
end;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
var
st,sb:string;
bbb_l:boolean;
begin
faz:=faz+pi/2-random(3);
if faz>=2*pi then
faz:=0;
bbb_l:=false;
if (StrToInt(edit1.Text)>=0)and(StrToInt(edit1.Text)<10) then begin
 edit1.Text:=IntToStr(50);
 bbb_l:=true;
end;

if bbb_l then
showmessage('Ошибка ввода!');
case combobox3.ItemIndex of
  0: st:='мкС';
  1: st:='мС';
  2: st:='С';
  3: st:='кС';
  4: st:='МС';
end;
chart1.BottomAxis.Title.Caption:=st;
case combobox4.ItemIndex of
  0: sb:='мкВ';
  1: sb:='мВ';
  2: sb:='В';
  3: sb:='кВ';
  4: sb:='МВ';
end;
chart1.LeftAxis.Title.Caption:=sb;
if RadioGroup1.ItemIndex=0 then
s_h:=true
else s_h:=false;
if s_h then begin
speedbutton1.Enabled:=true;
speedbutton2.Enabled:=true;
end;
if not(s_h) then begin
speedbutton1.Enabled:=false;
speedbutton2.Enabled:=false;
end;
end;

procedure Tform1.view(sig,stp:boolean;Sender: TObject);   // Блокировка полей ввода
begin

sig:=SpeedButton3.down;

if not(stp) and sig then begin               // 1(sig) 0(stp)
Edit2.ReadOnly:=True;
Edit2.AutoSelect:=False;
Edit2.Font.Color:=clWindowFrame;
Label5.Font.Color:=clWindowFrame;
Label6.Font.Color:=clWindowFrame;
UpDown2.Max:=0;
end;
if not(stp) then  begin                      // 1/0(sig) 0(stp)
GroupBox1.Enabled:=true;
GroupBox2.Enabled:=true;
combobox2.Enabled:=true;
combobox1.Enabled:=true;
//Edit1.ReadOnly:=False;
//Edit1.AutoSelect:=True;
//Edit3.ReadOnly:=False;
//Edit3.AutoSelect:=True;
Edit1.Font.Color:=clWindowText;
Edit3.Font.Color:=clWindowText;
Label4.Font.Color:=clWindowText;
Label7.Font.Color:=clWindowText;
//UpDown1.Max:=1000;
//UpDown3.Max:=1000;
end;
if not(stp) and not(sig) then begin         // 0(sig) 0(stp)
Edit2.ReadOnly:=False;
Edit2.AutoSelect:=True;
Edit2.Font.Color:=clWindowText;
Label5.Font.Color:=clWindowText;
Label6.Font.Color:=clWindowText;
UpDown2.Max:=100;
UpDown2.Position:=50;
end;
if stp then begin                          // 0/1(sig) 1(stp)
GroupBox1.Enabled:=False;
GroupBox2.Enabled:=False;
combobox2.Enabled:=False;
combobox1.Enabled:=False;
//Edit1.ReadOnly:=True;
//Edit1.AutoSelect:=False;
//Edit2.ReadOnly:=True;
//Edit2.AutoSelect:=False;
//Edit3.ReadOnly:=True;
//Edit3.AutoSelect:=False;
Edit1.Font.Color:=clWindowFrame;
Edit2.Font.Color:=clWindowFrame;
Edit3.Font.Color:=clWindowFrame;
Label5.Font.Color:=clWindowFrame;
Label6.Font.Color:=clWindowFrame;
Label4.Font.Color:=clWindowFrame;
Label7.Font.Color:=clWindowFrame;
//UpDown1.Max:=0;
//UpDown2.Max:=0;
//UpDown3.Max:=0;
end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if Savedialog1.Execute
  then Chart1.SaveToBitmapFile(savedialog1.FileName+'.bmp')
  else Exit;
showmessage('График успешно сохранен');
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
e:integer;
begin
e:=ComboBox1.ItemIndex;
case e of
  0: mant_a:=0.000001;
  1: mant_a:=0.001;
  2: mant_a:=1;
  3: mant_a:=1000;
  4: mant_a:=1000000;
end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
var
e:integer;
begin
e:=ComboBox2.ItemIndex;
case e of
  0: mant_f:=0.000001;
  1: mant_f:=0.001;
  2: mant_f:=1;
  3: mant_f:=1000;
  4: mant_f:=1000000;
end;
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
var
e:integer;
begin
e:=ComboBox3.ItemIndex;
case e of
  0: mant_t_m:=0.000001;
  1: mant_t_m:=0.001;
  2: mant_t_m:=1;
  3: mant_t_m:=1000;
  4: mant_t_m:=1000000;
end;
end;

procedure TForm1.ComboBox4Change(Sender: TObject);
var
e:integer;
begin
e:=ComboBox4.ItemIndex;
case e of
  0: mant_a_m:=0.000001;
  1: mant_a_m:=0.001;
  2: mant_a_m:=1;
  3: mant_a_m:=1000;
  4: mant_a_m:=1000000;
end;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9', ',', Chr(VK_BACK)]) then Key := #0;
end;

procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9', ',', Chr(VK_BACK)]) then Key := #0;
end;

procedure TForm1.Edit3KeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9', ',', Chr(VK_BACK)]) then Key := #0;
end;

procedure TForm1.Edit4Change(Sender: TObject);
begin
Axsc_t:=StrToFloat(Edit4.Text); // Масштаб по оси времени
Chart1.BottomAxis.Automatic := False ;// Отключение авто масштабирования ось x
Chart1.BottomAxis.SetMinMax( 0, Axsc_t );// Задание масштаба ось x
end;

procedure TForm1.Edit4KeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9', ',', Chr(VK_BACK)]) then Key := #0;
end;

procedure TForm1.Edit5Change(Sender: TObject);
begin
Axsc_a:=StrToFloat(Edit5.Text); // Масштаб по оси амплитуды
Chart1.LeftAxis.Automatic := False ;        // Отключение авто масштабирования ось y
Chart1.LeftAxis.SetMinMax(-Axsc_a,Axsc_a);     // Задание масштаба ось y
end;

procedure TForm1.Edit5KeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9', ',', Chr(VK_BACK)]) then Key := #0;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
s_upd:=true;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
s_upd:=false;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
sig:=True;                             // Маркер сигнала
view(sig,stp,Sender);                  // Доступность полей ввода
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
sig:=False;                             // Маркер сигнала
view(sig,stp,Sender);                   // Доступность полей ввода Вкл
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
b,c:integer;
d:real;
begin
b:=TrackBar1.position;
c:=a-b;
if c<0 then
d:=-c/10
else
d:=-c/10;
a:=TrackBar1.position;
Edit3.Text:=FloatToStr(d+StrToFloat(Edit3.Text));
//Edit3.Text:=IntToStr(TrackBar1.position);
end;

procedure TForm1.UpDown4Click(Sender: TObject; Button: TUDBtnType);
begin
{if (StrToFloat(Edit4.Text)>=0) and (StrToFloat(Edit4.Text)<=10) then
UpDown4.Increment:=1;
if (StrToFloat(Edit4.Text)>10) and (StrToFloat(Edit4.Text)<=100) then
UpDown4.Increment:=10;
if (StrToFloat(Edit4.Text)>100) and (StrToFloat(Edit4.Text)<1000) then
UpDown4.Increment:=100; }
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
a:=TrackBar1.position;
mant_f:=1;
mant_a:=1;
mant_a_m:=1;
mant_t_m:=0.001;
dt:=0.0002;
//значения мантис по умолчанию
edit2.Text:=IntToStr(50);
sig:=true;                             // Маркер сигнала по умолчанию
stp:=false;                            // Маркер Вкл/Выкл по умолчанию
view(sig,stp,Sender);                  // Доступность полей ввода по умолчанию
timer1.Enabled:=False;                 // Генератора по умолчанию выключен
timer2.Enabled:=False;                 // Осциллограф по умолчанию выключен
s_upd:=true;
end;

end.
