module LAB7(Clock, Sel1, RnW1, Sel2, RnW2, Sel3, RnW3, Sel4, RnW4, DioExt);
input Clock;  // clock input for all modules
input Sel1, Sel2, Sel3, Sel4;  // module select inputs
input RnW1, RnW2, RnW3, RnW4;  // module read/write control inputs
inout [7:0] DioExt; // IO connection to external data pins // Verilog'da inout, portun y�n�d�r. �ift y�nl� bir ba�lant� noktas� i�in inout kullan�r�z. 

tri [7:0] Dbus;  // internal data bus connecting all modules and // Birden fazla s�r�c� taraf�ndan kullan�lan line i�in tri kullan�r�z. Fakat ayn� anda kullan�lamaz. 
                 // DioExt[7:0] external data pins
Reg8bit R1(Clock, Sel1, RnW1, Dbus);  // register modules
Reg8bit R2(Clock, Sel2, RnW2, Dbus);
Reg8bit R3(Clock, Sel3, RnW3, Dbus);

Accumulator Acc(Clock, Sel4, RnW4, Dbus);

// DioExt[7:0] drive Dbus[7:0] while writing to a register module.
assign Dbus[7:0] = ( (RnW1 | RnW2 | RnW3 | RnW4) == 1'b0 ) ? // T�m RW bitleri s�f�r oldu�unda select bitine ba�l� olarak yazma i�lemini ger�ekle�tirir. 
                   DioExt[7:0] : 8'bZ;    
// Dbus[7:0] drive DioExt[7:0] while reading from a register module.
assign DioExt[7:0] = ( (RnW1 | RnW2 | RnW3 | RnW4) == 1'b1 ) ? // T�m RW bitlerinin toplam� 1 oldu�unda select bitine ba�l� olarak modulden okuma yapacak.
                     Dbus[7:0] : 8'bZ;    // Z bir y�ksek empedans durumudur. Yani asl�nda ba�lant�s� kesilmi�tir. Bu nedenle ba�ka bir s�r�c� ya da register taraf�ndan s�r�lebilir. 
                                          // Z y�ksek empedans fiziksel olarak ba�lant�s�z durumunu temsil eder. Sonsuz derecede y�ksek bir diren� gibi. 
                                          // Y�ksek empedans� a��k devre olarak d���nebiliriz. 8'bZ verdi�imizde onu mant�k 1 veya mant�k 0 d���nda bir 3. durum olarak kabul etmeliyiz. 
                                          // K�sa cevap bunun bir a��k devre oldu�udur. Yani telin giri�ine fiziksel olarak hi�bir �ey ba�l� de�ildir. 
                                          // �ift y�nl� bus'lar�n uygulanmas� i�in kullan��l�d�r. 
endmodule

// Bir tri a� ayn� anda birden fazla arabellek (buffer) taraf�ndan �al��t�r�lamaz. Bu nedenle herhangi bir zamanda RnW1, RnW2, RnW3, RnW4 kontrol giri�lerinden sadece biri y�ksek olabilir. 
// Bir arabellek(buffer) bir sinyal d���m�n� y�ksek seviyeye s�rerken, ba�ka bir arabellek ayn� d���m� d���k seviyeye �ekti�inde mant�k �eki�meleri meydana gelir. 
// Bir mant�k �eki�mesi varsa, sinyal seviyesi tan�ms�zd�r.  

// Blok diyagramda g�sterildi�i gibi bu deneyde 8 bitlik �ift y�nl� bir veri yolu uygulanacakt�r. 
// Top level mod�l 8 bitlik dahili veri yolu(Dbus[7:0]) arac�l���yla eri�ilebilen birka� kay�t mod�l�n�(R1, R2 R3 ve Acc) i�erir. 

// 8 bitlik bu s�r�mde etkinle�tirme sinyali hem okuma hem de yazma i�lemleri i�in ortak olmal�d�r. 
// Ayr�ca okuma ve yazma i�lemleri ayr� sinyaller (RnW) kullan�larak belirlenmelidir.



module Reg8bit(Clk,Sel,RnW,Dio);

input Clk;		   // Saat sinyali t�m registerlar� e� zamanl� tetikleyecek. 
input Sel;		   // Select inputu okuma ve yazma i�lemlerini aktifle�tirecek. 
input RnW;		   // Okuma ve yazma kontrol inputu.
	               // 0=> store data input at Dio[7:0] if Sel is 1 (Select 1 oldu�u m�ddet�e yazma i�lemini ger�ekle�tirecek.)            
				   // 1=> enable output to Dio[7:0] if Sel is 1 // (Herhangi bir register modul�n�n ��k���n�n aktifle�tirip okuma yapabilmesi i�in RnW sinyali 1 olmal�d�r.)
inout [7:0] Dio;   // Data i�in hem input hem de output olarak 8 bitlik node tan�ml�yorum. 

reg [7:0] Reg; // Registerlar i�in 8 bitlik reg tan�ml�yorum. 

always@(posedge Clk)
begin
	if(Sel == 1'b1)    // Hangi register'�n select biti 1 ise Dio o registera y�klenmi� olacak. Select biti register'� aktif eder. 
		Reg[7:0] <= Dio[7:0];
	else
		Reg[7:0] <= Reg[7:0]; // Select biti 0 olan registerda herhangi bir de�i�iklik olmaz. Okuma ve yazma da olmaz. 
end

assign Dio[7:0] = (RnW == 1'b1)? Reg[7:0] : 8'bZ; // RnW = 1 ise bu okuma anlam�na gelir ve register saklad��� de�eri Dio �ift y�nl� ��k���na verir. 

                                  

endmodule

// 8 bit �ift y�nl� kay�t ile (bidirectional register) ayn� giri� ve ��k��a sahip 8 bitlik bir ak�m�lat�r olu�turulmal�. 
// �ift y�nl� veri pinleri (DioExt[7:0]), kay�t i�eri�ini (Register'lar�) okumak ve yazmak i�in Dbus[7:0]'a harici eri�im sa�lar. 
// DioExt[7:0] pinleri veya kay�t mod�llerinden biri Dbus[7:0]'� �al��t�rabilir.  
// 3 durumlu ara bellekler (RnW) kontrol sinyallerine g�re etkinle�tirilir. 
// RnW = 0 - write / RnW = 1 - read 
// Ak�m�lat�r se�ildi�inde RnW 0 ise Ak�m�lat�r Dio[7:0] verisini ak� register�na eklemelidir. 
// (Okuma i�leminden sonra ak� i�eri�i sonraki saat �eviriminde silinir.)
// Bir saat �evriminde ak� okunuyor ve bir sonraki saat �evriminde yaz�yorsa, 
// yaz�lacak veri ikinci saat �evriminde do�rudan ak�m�lat�r kayd�na aktar�lmal�d�r. 


module Accumulator(Clk, Sel, RnW, Dio);
input Clk,Sel,RnW;
inout [7:0] Dio;
reg [7:0] Reg;

always @(posedge Clk)
begin
	if(RnW == 1'b1 && Sel == 1'b1) // Select biti ile hedef register se�ilecek ve RnW'nin 1 olmas� ile register resetlenecek.
		Reg[7:0] <= 8'b0;			// reset
	else if(RnW == 1'b0 && Sel == 1'b1) // Select biti ile hedef register se�ilecek ve RnW 0 olmas� ile Dio toplanacak. 
		Reg[7:0] <= Reg[7:0] + Dio[7:0];
	else
		Reg[7:0] <= Reg[7:0]; // 3. durum select bitinin 0 olmas�. Bu durumda registerda herhangi bir de�i�im olmayacak.
end

assign Dio[7:0] = (RnW == 1'b1)? Reg[7:0] : 8'bZ; // RnW 1 ise register ��k���n� Dio'ya aktar�r okuma i�lemi i�in. 

endmodule 

