% DOlby Hrtf model simulation
clear all;
clc;

c= 343 ;  % m/s spped of sound
a=8.75/100;  % cm head radius
fs= 44100;  % sample rate
Ts=1/fs;

theta=deg2rad(5);

beta= 2*c/(a*fs);
alphai_theta= 1+cos(theta-deg2rad(90));% 1+sin(theta);
alphac_theta= 1-cos(theta-deg2rad(90));%1-sin(theta);

bi0= beta+2*alphai_theta;
bi1= beta-2*alphai_theta;
ai0= beta+2;
ai1= beta-2;

bc0= beta+2*alphac_theta;
bc1= 2*alphac_theta;
ac0= beta+2;
ac1= beta-2;

num_ipsi=[ bi0 bi1]; 
den_ipsi=[ai0 ai1];
num_contra=[bc0 bc1];
den_contra=[ac0 ac1];

Hipsi=tf(num_ipsi,den_ipsi,Ts);
Hcontra=tf(num_contra,den_contra,Ts,'InputDelay',100);
Hhrtf=Hipsi*Hcontra;

%bode(Hhrtf);
%impulse(Hhrtf);

num_itf=[bc0 bc1];
den_itf=[bi0 bi1];
num_eqf=[ai0 ai1];
den_eqf=[bi0 bi1];

Hitf=tf(num_itf,den_itf,Ts,'InputDelay',100);
Heqf=tf(num_eqf,den_eqf,Ts,'InputDelay',100);

Hcor=Hitf*Heqf;
figure;

Hsurr=Hhrtf*Hcor;
bode(Hsurr);
%impulse(Heqf);

wav_file_name='out(u2)2048_L_in_music.wav';
[wav_data fs]=audioread(wav_file_name);

T = 1/fs;
t = 0:Ts:(length(wav_data(:,1))-1)*Ts; % get time of samples;

binarual_l=lsim(Hsurr,wav_data(:,1),t);   %prony  IIR
binarual_r=lsim(Hsurr,wav_data(:,1),t);   %prony  IIR

binarual_output=[binarual_l binarual_r];

output_wav_file='es01_point_binarual.wav';
audiowrite(output_wav_file,binarual_output,fs);