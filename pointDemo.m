clear all;
clc;

% CIPIC�߶ȽǷֲ� ��50�� ��-45��235    �ֲ�ͼ��ReadMe.doc
% elevation_cipic=-45:360/64:235;  
% elevation(9)==0 ����ǰ���߶Ƚ�    elevation(25)==90�����Ϸ��߶Ƚ�   elevation(41)==180�����󷽸߶Ƚ�
% elevation_index=1:50;   %��Ӧ�߶Ƚ���CIPIC Hrtf���е�����

% CIPIC ��λ�Ƿֲ� ��50��  ǰ�󷽸�25��   �ֲ�ͼ��ReadMe.doc
% azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];  
% azimuth(13)==0��ǰ����λ��
% azimuth_index=1:25;


% CIPIC Altitude Angle Distribution A total of 50, from -45 to 235, see ReadMe.doc
% elevation_cipic=-45:360/64:235;
% elevation(9)==0 is the front elevation angle elevation(25)==90 is the directly above elevation angle elevation(41)==180 is the front elevation angle
% elevation_index=1:50;% corresponds to the index of the elevation angle in the CIPIC Hrtf library

% CIPIC azimuth distribution, 50 in total, 25 in the front and rear, see ReadMe.doc for the distribution map
% azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];
% azimuth(13)==0 direct front azimuth
% azimuth_index=1:25;


azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];%azimuth(13)==0 
azimuth=-80;    % for the left surround
%azimuth=80;      % for the right surround
azimuth_index=find(azimuth_cipic==azimuth);%��ȡ65�ȷ�λ�� ������ֵ

elevation_cipic=-45:360/64:235;
elevation=0;%123.75;
elevation_index=find(elevation_cipic==elevation);%��ȡ0�ȸ߶Ƚ� ������ֵ
fprintf(" azimuth_index=%d  elevation_index=%d \n",azimuth_index,elevation_index);
subject_index=1;%cipic subject������

%��ȡazimuth=65��elevation=0�� hrir����
hrtf_l= readCipicHrtf(subject_index,azimuth_index,elevation_index,'l');
hrtf_r= readCipicHrtf(subject_index,azimuth_index,elevation_index,'r');

%wav_file_name='InputWav\es01.wav';
wav_file_name='out(u2)2048_L_in_music.wav';
[wav_data fs]=audioread(wav_file_name);

% decimation order optimze 
M=2;
num = designMultirateFIR(1,M);
firdecim = dsp.FIRDecimator(M,num);

%hrtf_l=firdecim(hrtf_l');      % to make IIR , do't use decimation
%hrtf_r=firdecim(hrtf_r');

figure;
t=1:length(hrtf_l);
t=t/fs;
plot(t,hrtf_l,'b',t,hrtf_r,'r'); grid on;
xlabel('samples: b:left,r:right , Time(sec)');
title('Source at 80 degree');

figure;
[Hl,Fl]=freqz(hrtf_l,1,length(hrtf_l),fs);
[Hr,Fr]=freqz(hrtf_r,1,length(hrtf_r),fs);
semilogx(Fl,mag2db(abs(Hl)),'b',Fr,mag2db(abs(Hr)),'r'); grid on;
xlabel('Freq(Hz)');
title('Source at 80 degree');

%===========prony IIR   50order is good , less than 50 is poor.
bord = 50;
aord = 50;
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
%======================


%binarual_l=filter(hrtf_l,1,wav_data);   % normal FIR
%binarual_r=filter(hrtf_r,1,wav_data);   % FIR

binarual_l=filter(bl,al,wav_data);   %prony  IIR
binarual_r=filter(br,ar,wav_data);   %prony  IIR

binarual_output=[binarual_l binarual_r];

output_wav_file='es01_point_binarual.wav';
audiowrite(output_wav_file,binarual_output,fs);

