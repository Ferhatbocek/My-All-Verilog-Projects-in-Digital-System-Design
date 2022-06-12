module LAB7(Clock, Sel1, RnW1, Sel2, RnW2, Sel3, RnW3, Sel4, RnW4, DioExt);
input Clock;  // clock input for all modules
input Sel1, Sel2, Sel3, Sel4;  // module select inputs
input RnW1, RnW2, RnW3, RnW4;  // module read/write control inputs
inout [7:0] DioExt; // IO connection to external data pins // Verilog'da inout, portun yönüdür. Çift yönlü bir baðlantý noktasý için inout kullanýrýz. 

tri [7:0] Dbus;  // internal data bus connecting all modules and // Birden fazla sürücü tarafýndan kullanýlan line için tri kullanýrýz. Fakat ayný anda kullanýlamaz. 
                 // DioExt[7:0] external data pins
Reg8bit R1(Clock, Sel1, RnW1, Dbus);  // register modules
Reg8bit R2(Clock, Sel2, RnW2, Dbus);
Reg8bit R3(Clock, Sel3, RnW3, Dbus);

Accumulator Acc(Clock, Sel4, RnW4, Dbus);

// DioExt[7:0] drive Dbus[7:0] while writing to a register module.
assign Dbus[7:0] = ( (RnW1 | RnW2 | RnW3 | RnW4) == 1'b0 ) ? // Tüm RW bitleri sýfýr olduðunda select bitine baðlý olarak yazma iþlemini gerçekleþtirir. 
                   DioExt[7:0] : 8'bZ;    
// Dbus[7:0] drive DioExt[7:0] while reading from a register module.
assign DioExt[7:0] = ( (RnW1 | RnW2 | RnW3 | RnW4) == 1'b1 ) ? // Tüm RW bitlerinin toplamý 1 olduðunda select bitine baðlý olarak modulden okuma yapacak.
                     Dbus[7:0] : 8'bZ;    // Z bir yüksek empedans durumudur. Yani aslýnda baðlantýsý kesilmiþtir. Bu nedenle baþka bir sürücü ya da register tarafýndan sürülebilir. 
                                          // Z yüksek empedans fiziksel olarak baðlantýsýz durumunu temsil eder. Sonsuz derecede yüksek bir direnç gibi. 
                                          // Yüksek empedansý açýk devre olarak düþünebiliriz. 8'bZ verdiðimizde onu mantýk 1 veya mantýk 0 dýþýnda bir 3. durum olarak kabul etmeliyiz. 
                                          // Kýsa cevap bunun bir açýk devre olduðudur. Yani telin giriþine fiziksel olarak hiçbir þey baðlý deðildir. 
                                          // Çift yönlü bus'larýn uygulanmasý için kullanýþlýdýr. 
endmodule

// Bir tri að ayný anda birden fazla arabellek (buffer) tarafýndan çalýþtýrýlamaz. Bu nedenle herhangi bir zamanda RnW1, RnW2, RnW3, RnW4 kontrol giriþlerinden sadece biri yüksek olabilir. 
// Bir arabellek(buffer) bir sinyal düðümünü yüksek seviyeye sürerken, baþka bir arabellek ayný düðümü düþük seviyeye çektiðinde mantýk çekiþmeleri meydana gelir. 
// Bir mantýk çekiþmesi varsa, sinyal seviyesi tanýmsýzdýr.  

// Blok diyagramda gösterildiði gibi bu deneyde 8 bitlik çift yönlü bir veri yolu uygulanacaktýr. 
// Top level modül 8 bitlik dahili veri yolu(Dbus[7:0]) aracýlýðýyla eriþilebilen birkaç kayýt modülünü(R1, R2 R3 ve Acc) içerir. 

// 8 bitlik bu sürümde etkinleþtirme sinyali hem okuma hem de yazma iþlemleri için ortak olmalýdýr. 
// Ayrýca okuma ve yazma iþlemleri ayrý sinyaller (RnW) kullanýlarak belirlenmelidir.



module Reg8bit(Clk,Sel,RnW,Dio);

input Clk;		   // Saat sinyali tüm registerlarý eþ zamanlý tetikleyecek. 
input Sel;		   // Select inputu okuma ve yazma iþlemlerini aktifleþtirecek. 
input RnW;		   // Okuma ve yazma kontrol inputu.
	               // 0=> store data input at Dio[7:0] if Sel is 1 (Select 1 olduðu müddetçe yazma iþlemini gerçekleþtirecek.)            
				   // 1=> enable output to Dio[7:0] if Sel is 1 // (Herhangi bir register modulünün çýkýþýnýn aktifleþtirip okuma yapabilmesi için RnW sinyali 1 olmalýdýr.)
inout [7:0] Dio;   // Data için hem input hem de output olarak 8 bitlik node tanýmlýyorum. 

reg [7:0] Reg; // Registerlar için 8 bitlik reg tanýmlýyorum. 

always@(posedge Clk)
begin
	if(Sel == 1'b1)    // Hangi register'ýn select biti 1 ise Dio o registera yüklenmiþ olacak. Select biti register'ý aktif eder. 
		Reg[7:0] <= Dio[7:0];
	else
		Reg[7:0] <= Reg[7:0]; // Select biti 0 olan registerda herhangi bir deðiþiklik olmaz. Okuma ve yazma da olmaz. 
end

assign Dio[7:0] = (RnW == 1'b1)? Reg[7:0] : 8'bZ; // RnW = 1 ise bu okuma anlamýna gelir ve register sakladýðý deðeri Dio çift yönlü çýkýþýna verir. 

                                  

endmodule

// 8 bit çift yönlü kayýt ile (bidirectional register) ayný giriþ ve çýkýþa sahip 8 bitlik bir akümülatör oluþturulmalý. 
// Çift yönlü veri pinleri (DioExt[7:0]), kayýt içeriðini (Register'larý) okumak ve yazmak için Dbus[7:0]'a harici eriþim saðlar. 
// DioExt[7:0] pinleri veya kayýt modüllerinden biri Dbus[7:0]'ý çalýþtýrabilir.  
// 3 durumlu ara bellekler (RnW) kontrol sinyallerine göre etkinleþtirilir. 
// RnW = 0 - write / RnW = 1 - read 
// Akümülatör seçildiðinde RnW 0 ise Akümülatör Dio[7:0] verisini akü registerýna eklemelidir. 
// (Okuma iþleminden sonra akü içeriði sonraki saat çeviriminde silinir.)
// Bir saat çevriminde akü okunuyor ve bir sonraki saat çevriminde yazýyorsa, 
// yazýlacak veri ikinci saat çevriminde doðrudan akümülatör kaydýna aktarýlmalýdýr. 


module Accumulator(Clk, Sel, RnW, Dio);
input Clk,Sel,RnW;
inout [7:0] Dio;
reg [7:0] Reg;

always @(posedge Clk)
begin
	if(RnW == 1'b1 && Sel == 1'b1) // Select biti ile hedef register seçilecek ve RnW'nin 1 olmasý ile register resetlenecek.
		Reg[7:0] <= 8'b0;			// reset
	else if(RnW == 1'b0 && Sel == 1'b1) // Select biti ile hedef register seçilecek ve RnW 0 olmasý ile Dio toplanacak. 
		Reg[7:0] <= Reg[7:0] + Dio[7:0];
	else
		Reg[7:0] <= Reg[7:0]; // 3. durum select bitinin 0 olmasý. Bu durumda registerda herhangi bir deðiþim olmayacak.
end

assign Dio[7:0] = (RnW == 1'b1)? Reg[7:0] : 8'bZ; // RnW 1 ise register çýkýþýný Dio'ya aktarýr okuma iþlemi için. 

endmodule 

