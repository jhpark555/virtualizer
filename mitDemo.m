%{
    MIT head model azimuth

            315 0   45
           -90 HEAD  90
            225 0  135
%}
clear all;
clear figure;
clc;


full=0;     % 1 is wav file format , 0 is full model type.

if full==1
   %[x,Fs]=audioread('mit\elev0\H0e090a.wav');       % 128 taps compact
    
   [x1,Fs]=audioread('full\elev0\L0e045a.wav');     % in case full model 512 taps
   [x2,Fs]=audioread('full\elev0\R0e300a.wav');
  
   x1=x1(1:2:512);   % to reduce samples
   x2=x2(2:2:512);   % to reduce samples 
   x(:,1)=x1;
   x(:,2)=x2;
%save NameOfTextFile.txt x -ASCII
else
%fp = fopen('compact\elev0\H0e000a.dat','r','ieee-be');
%	data = fread(fp, 256, 'short');
%	fclose(fp);


% elevation 0,30,110,250,330,30,330
fp = fopen('KEMAR\L0e330a.dat','r','ieee-be');
	data1 = fread(fp, inf, 'short');
	fclose(fp);

fp = fopen('KEMAR\R0e110a.dat','r','ieee-be');
	data2 = fread(fp, inf, 'short');
	fclose(fp);

	leftimp = data1(1:2:256);
	rightimp = data2(2:2:256);
end

if full==1
    fprintf("Mit wav format model\n");
    hrtf_l= x(:,1);
    hrtf_r= x(:,2);
else
    fprintf("Mit compact model \n");
    hrtf_l=leftimp/32768;
    hrtf_r=rightimp/32768;
end

%wav_file_name='InputWav\es01.wav';
wav_file_name='out(u2)2048_L_in_music.wav';
[wav_data1 fs]=audioread(wav_file_name);

wav_file_name='out(u2)2048_R_in_music.wav';
[wav_data2 fs]=audioread(wav_file_name);

% decimation order optimze 
%M=2;
%num = designMultirateFIR(1,M);
%firdecim = dsp.FIRDecimator(M,num);

%hrtf_l=firdecim(hrtf_l');      % to make IIR , do't use decimation
%hrtf_r=firdecim(hrtf_r');

figure;
t=1:length(hrtf_l);
t=t/fs;
plot(t,hrtf_l,'b',t,hrtf_r,'r'); grid on;
xlabel('samples: b:left,r:right , Time(sec)');
title('FIR impulse');

figure;
[Hl,Fl]=freqz(hrtf_l,1,length(hrtf_l),fs);
[Hr,Fr]=freqz(hrtf_r,1,length(hrtf_r),fs);
semilogx(Fl,mag2db(abs(Hl)),'b',Fr,mag2db(abs(Hr)),'r'); grid on;
xlabel('Freq(Hz)');
title(' FIR');

%===========Prony method IIR   50order is good , less than 50 is poor.
bord = 25;
aord = 25;
ImpL=impz(hrtf_l,1);
ImpR=impz(hrtf_r,1);
[bl,al]= prony(ImpL,bord,aord);
[br,ar]= prony(ImpR,bord,aord);
figure;
subplot(2,1,1) 
stem(impz(bl,al,length(hrtf_l)))
title 'Impulse Response with Prony Design'

subplot(2,1,2)
stem(hrtf_l)
title 'Input Impulse Response'

figure;
[Hl,Fl]=freqz(ImpL,1,length(hrtf_l),fs);
[Hr,Fr]=freqz(ImpR,1,length(hrtf_r),fs);
semilogx(Fl,mag2db(abs(Hl)),'b',Fr,mag2db(abs(Hr)),'r'); grid on;
xlabel('Freq(Hz)');
title(' Prony');

%======================


%binarual_l=filter(hrtf_l,1,wav_data1);   % normal FIR
%binarual_r=filter(hrtf_r,1,wav_data2);   % FIR

binarual_l=filter(bl,al,wav_data1);   %prony  IIR
binarual_r=filter(br,ar,wav_data2);   %prony  IIR

binarual_output=[binarual_l binarual_r];
output_wav_file='LR_ch.wav';
audiowrite(output_wav_file,binarual_output,fs);

