module toplevel(Clk,Send,PDin,PDout,PDready,ParErr);

input Clk;
input Send;
input [7:0] PDin;

output PDready;
output [7:0] PDout;
output ParErr; // Al?c?da hata durumunu g?sterecek. Parity bitini kontrol edecek. 

wire SDout;
wire SCout;
wire parity1;

serialtransmitter X(Clk,Send,PDin,SCout,SDout);
serialreceiver Y(SCout, SDout, PDout, PDready,ParErr);

endmodule 

//G?nderme giri?(Send) darbesi bir saat d?ng?s?nden daha uzun oldu?unda ?al??acak ?ekilde de?i?tirin. 
//G?nderme giri?i(Send), 1'e ayarland?ktan sonra y?kselen Clk kenar?nda ge?erlidir, ancak birka? saat ?evrimi i?in 1'de kalabilir.

//SERIAL TRANSMITTER (Long Send ?nput Pulse)

//Seri verici ve PDin, CLK zamanlamas?ndan ba??ms?z olarak bir saat d?ng?s? s?ras?nda herhangi bir zamanda ?al??acak ?ekilde de?i?tiriyoruz. 
//Yani Send bir saat d?ng?s?nden daha uzun s?re boyunca PDini bekler ve PDin geldi?i anda bu register'a y?klenmi? olur. 

//Seri data'ya bir e?lik(parity) biti ekliyoruz b?ylece transmitterdan receiver'a gelen datan?n do?rulu?unu denetleyece?iz.  
//?letilen 8 bitlik data tek say?da 1 biti i?eriyorsa parity 1 aksi halde 0 olacak. 

//Receiver'da hata durumunu g?steren bir ParErr ??k??? olacak ve al?nan 8 bit datadan sonra e?lik bitini kontrol edecek. 
//Al?nan veriden elde edilen e?lik biti ile ParErr e?le?irse  0'da kalacak. 
//E?er al?nan data, g?nderilen data ile uyu?muyorsa ParErr, PDready darbesi ile e? zamanl? ve bir sonraki veri aktar?m?na kadar 1'de kalacakt?r. 

module serialtransmitter(Clk,Send,PDin,SCout,SDout);
input Clk;
input Send;
input [7:0] PDin; 

output SCout; 
output reg SDout;

reg [9:0] SR; // 10 bitlik bir register gerekiyor toplamda. Start biti ve Parity biti dahil oldu?u i?in. 
assign SCout = Clk; 
wire A; 
wire Send2; 
reg Send1;
assign A = ^PDin[7:0]; // Paralel 8 bit datan?n tek ya da ?ift say?da 1 i?erdi?ini tespit etmek i?in ex-ordan ge?iriyorum.  if A=1 Tek / A=2 ?ift


always@(posedge Clk)
begin
	Send1 <= Send;
end
assign Send2 = Send & ~Send1; // 1 sayk?l kadar gecikme olu?turuyorum b?ylecek start bitinin olu?turabilece?i senkronizasyon sorununu kald?r?yorum.

always @(posedge Clk)
begin
	if (Send2 == 1'b1)  //Send2'nin 1 olmas? 10 bitlik datan?n iletimi i?in gerekli ba?lang?c? sa?layacakt?r. Fakat ?ncelikle veri y?klenir. 
	begin
		if(SR[9:0] == 10'b0 ) // Send2 1 ise ve SR tamamen 0 ise SR[9] 1 olmal? bu benim start bitim olacak. 
		begin
			SR[9] <= 1'b1; //Start biti 1 olacak
			SR[8:1] <= PDin[7:0]; // 8 bitlik paralel data SR registera y?klenecek. 
			SR[0] <= A; // Parity biti SR[0]'a y?klenecek 
			SDout <=1'b0; // Son olarak SDout'u 0 y?kleyerek veri g?nderimini tamaml?yorum. 
		end
		else  // Start biti yani Send2 0 ise start verilmi? ve register kayd?rma i?lemine ba?lam?? demektir. 
		begin
			SDout <= SR[9];  // Most significant biti ??k??a veriyorum. 
			SR[9:1] <= SR[8:0]; // Shift register kayd?rma i?lemini ger?ekle?tiriyor. 
			SR[0] <= 1'b0; // Kayd?rma ger?ekle?tirilirken register tamamen s?f?rlan?yor. 
		end
	end
	else // Send2 hep 0 olsayd? ne olmas? gerekirdi burada bunu soruyorum. Send2'nin hep 0 olmas? herhangi bir data iletimi olmad??? anlam?na gelir.
	begin 
		if(SR[9:0] == 10'b0 ) // Register?n t?m bitleri s?f?rlan?r.  
		begin
			SDout <= 1'b0; // Seri data ??k??? s?rekli s?f?rd?r. 
		end
		else // Ve di?er durum yani Send2'nin 1 olmas? b?ylece data iletimi ba?lamal?. 
		begin
			SDout <= SR[9]; 
			SR[9:1] <= SR[8:0]; 
			SR[0] <= 1'b0;
		end
	end
end
endmodule 

//SERIAL RECE?VER

module serialreceiver(SCin, SDin, PDout, PDready,ParErr);
input SCin;
input SDin;

output reg PDready;
output reg [7:0] PDout;
output reg ParErr;

reg [3:0] counter = 4'b0; // 10 bitlik datan?n saya? ile aktar?m?n?n ger?ekle?tirilebilmesi i?in 4 bit saya? yeterli 

always@(posedge SCin)
begin

	PDout[0] <= SDin; // LSB to LSB - MSB to MSB ?eklinde seri data giri?ini paralel ??k??a aktar?yorum. 
	PDout[7:1] <= PDout[6:0];
	
	
	if(SDin == 1'b1) // Datan?n Receiver'a ula?t??? anda bunu kontrol etmem gerekir. Buradan SDin'i kontrol ediyorum. Data geldi mi? 
	begin
		if(counter[3:0] == 4'b0000) // Sayac?m tamamen s?f?r ise 
		begin
			PDout <= 1'b0; // paralel ??k?? tamamen s?f?r
			PDready <= 0; // PDready 8 bitlik datan?n tamamen paralel ??k??a verildi?i zaman 1 olacak. 
			counter[3:0] <= counter[3:0] + 1'b1; // Counter saymaya ba?layacak. 
		end
		else if(counter[3:0] == 4'b1010) //  Sayac?n 10'a kadar sayd???, start ve parity biti de dahil olmak ?zere 10 biti aktard??? anlam?na gelir.
		begin
			PDready <= 0; 
			PDout[7:0] <= 8'b0;
			counter[3:0] <= 4'b0000; // paralel ??k?? ve saya? s?f?rlan?r
		end
		else
		begin
			counter[3:0] <= counter[3:0] + 1'b1; 
			PDready <= 0;
			if(counter[3:0] == 4'b1001) // Sayac?n 9 a kadar sayd??? ve bir sonraki saat d?ng?s?nde PDready 1'leyerek datan?n aktar?ld???n? g?sterir
			begin
				PDready <= 1'b1; // 8 bitlik paralel data art?k haz?r. Tamamen ??k??a aktar?ld?. 
				PDout[7:0] <= PDout[7:0]; // 1 sayk?ll?k saat d?ng?s?nden sonra register paralel ??k??lar?nda 8 bit datay? tutacak. 
				ParErr <= SDin^(^PDout[7:0]); // Paralel datan?n her biti ile SDin ex-or'dan ge?irilecek.
			end                               // B?ylece datan?n do?rulu?unu test edece?im.  
		                                      // Datadan gelen parity ile ParErr e?le?miyorsa e?er 1 e?le?iyorsa ParErr 0 kalacakt?r. 
		end
	end
	
	else
	begin
		if(counter[3:0] == 4'b0) // Saya? s?f?r iken if else yap?s? gere?i her kar??t durumu tan?mlamam gerekiyor. 
		begin
			PDout<=1'b0;
			PDout[7:0] <= 0;
			PDready <= 0;
		end
		else if(counter[3:0] == 4'b1010) // Saya? 10 a kadar sayd? 10 bit aktar?ld? ve i?lem tamamland?. 
		begin
			PDready <= 0;
			counter[3:0] <= 4'b0000;
			PDout[7:0] <= 8'b0;
		end
		else
		begin
			counter[3:0] <= counter[3:0] + 1'b1; 
			PDready <= 0;
			if(counter[3:0] == 4'b1001) //Sayac?n 9 a kadar sayd??? ve bir sonraki saat d?ng?s?nde PDready 1'leyerek datan?n aktar?ld???n? g?sterir
			begin
				PDready <= 1;
				PDout[7:0] <= PDout[7:0];
				ParErr <= SDin^(^PDout[7:0]); // Aktar?lan datan?n do?rulu?unun testi i?in ParrErr ile datan?n parity bitini kar??la?t?r?yorum.

			end
		end
	end
		
end
endmodule 