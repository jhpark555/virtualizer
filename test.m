%44100 original  45degree
% H0e045a.wav 
	x1=	[3,0,0,0,-1,1,1,-2,1,3,-3,7,-2,7,-8,16,-11,14,3,23,26,1190,2492,-524,-605,932,-1059,514,2319,1624,3100,5520,2294,-1072,997,163,-3476,-2673,-1059,-2833,-2648,-385,-54,-165,997,1838,1304,1268,1556,901,306,277,-20,-654,-961,-1016,-1282,-1729,-1872,-1616,-1257,-758,-276,21,345,622,696,540,329,206,4,-257,-417,-460,-565,-589,-533,-491,-364,-194,-64,-43,24,76,68,62,55,31,-55,-146,-192,-222,-256,-232,-188,-200,-186,-123,-102,-101,-55,-30,-70,-93,-49,-50,-82,-80,-70,-104,-148,-153,-159,-160,-176,-160,-123,-80,-26,-6,-1,-9,-11,-51,-82,-86,-109,-117]/32768;
		x2=	[-80,98,-104,109,-198,3827,14044,-1104,-13286,-4944,2536,7775,2651,13546,22171,2592,-7664,-94,-4166,-11388,-8443,-9890,-7349,-3719,-1140,553,1452,5620,3898,670,2462,3901,933,-410,61,579,408,-349,-1609,-4459,-5358,-4162,-3138,-2239,-1008,447,919,1299,1772,2000,1891,1684,1122,166,-220,-317,-465,-851,-956,-1093,-1502,-1270,-562,-355,-426,-171,230,406,620,771,657,233,-111,-221,-343,-262,-201,-289,-481,-457,-287,-280,-193,46,97,-11,-92,5,205,358,312,31,-249,-331,-296,-319,-262,-256,-429,-489,-284,47,224,131,-22,-133,-159,-108,-67,-138,-242,-253,-204,-77,10,-11,-90,-152,-95,18,87,98,58,0,-46,-30,53,92]/32768;
	

hrtf_r=resample(x1,32000,44100);   %resample to 32k
hrtf_l=resample(x2,32000,44100);   %resample to 32k

save('para32k.txt','hrtf_l','hrtf_r','-ascii');
format('long');
fileID = fopen('params32k.txt','w');
fprintf(fileID,'%d, \n',hrtf_l);
fprintf(fileID,"++++++++++++++\n");
fprintf(fileID,'%d, \n',hrtf_r);

t0=1:128;     %44.1
t=1:93;       %32

%plot(t0,x1,t,y1);


%wav_file_name='out(u2)2048_L_in_music.wav';
%[wav_data fs]=audioread(wav_file_name);

fs=32000;

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


%wav_file_name='InputWav\es01.wav';
wav_file_name='out(u2)2048_L_in_music.wav';
[wav_data1 fs]=audioread(wav_file_name);

wav_file_name='out(u2)2048_R_in_music.wav';
[wav_data2 fs]=audioread(wav_file_name);


binarual_l=filter(hrtf_l,1,wav_data1);   % normal FIR
binarual_r=filter(hrtf_r,1,wav_data2);   % FIR



binarual_output=[binarual_l binarual_r];
output_wav_file='LR_32kch.wav';
audiowrite(output_wav_file,binarual_output,fs);
