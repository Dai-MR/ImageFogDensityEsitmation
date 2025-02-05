%DaiEestiFogDensityValBy3FeaturesFuse.m
%Esitimate fog density using image according to three image features：
%1.Average S values in HSV format
%2.Rate of white points in ranged points 
%3.Jdark, i.e. dark channel map 
%Input: a folder of images in the format "png","jpg", of "jpeg".
%Output:Estimated fog density of each image, and save to
%"***_Fden_Ours_t***s.xls"
%2024.7

% clear all;
disp('**Estimate fog density of RGB image using our method** ');
%----threshold begin
VarThresh  = 0.018^2; % 0.065;
Scal = 1;

%------end threshold--------------

opfilePath = uigetdir('..');  %Open image folder，analysis all image in the folder
img_path_list = dir(strcat(opfilePath,'\*.png' ));%image list
img_num = length(img_path_list);%the number of images
if img_num<1
img_path_list = dir(strcat(opfilePath,'\*.jpg' ));%image list
img_num = length(img_path_list);%the number of images
end
if img_num<1
img_path_list = dir(strcat(opfilePath,'\*.jpeg' ));%image list
img_num = length(img_path_list);%the number of images
end
if img_num<1
img_path_list = dir(strcat(opfilePath,'\*.bmp' ));%image list
img_num = length(img_path_list);%the number of images
end
%
F2S =zeros(img_num,1);%record average s-values 
rgdVar = zeros(img_num,1);%Rate of white points in ranged points
Fdark  = zeros(img_num,1);%Jdark, i.e. dark channel map 


fileNm=[];
%读取每辐图像，并计算特征
tic
ImgOpend = 0;
for q = 1:img_num %逐一读取有雾图像
    image_name = img_path_list(q).name  % 图像名
    ImgOpend = ImgOpend+1;
    fileNm{ImgOpend,1}=image_name;
    J = [];
    J = imread(strcat(opfilePath,'\',image_name));
    %Fea1: s mean
    HSVi = rgb2hsv(J);
    Si = HSVi(:,:,2) ;
    [m, n] = size( Si );
    F2S(ImgOpend,1) = mean(Si(:));
    %Fea2: rate of white points in all points
    J1 = double(J)./255;
    Xm = sum(J1,3);
    X2 =  sum(J1.^2,3);
    varM = (X2- Xm.^2/3)/2;%每个像素点的色彩方差
    varMv = varM(:);
    idx = find( varMv  < VarThresh );%方差在一定范围内的点所占比例
    rgdVar(ImgOpend,1) = size(idx,1)/m/n;   
    %Fea3: Jdark
    Jdark = darkChannel3onlyDark( J,3,0.95);
    [m,n]=size(Jdark); 
    Dkv=[];
    Dkv = double(Jdark(:));
    idx = find(Dkv<0.85);
    Dkv1 = Dkv(idx);
    Fdark(ImgOpend,1) = mean(Dkv1 );  
end%end q

%转化为雾浓度估计
VisD = 500; %默认500;  %无雾图像强度信息
P2 = 0.05;  % 默认 0.05;
P3 = 20000;%默认20000
maxS =  max( F2S );
AdjLight = maxS *( 1+ P2 * exp( VisD*VisD/P3/P3 ) );
AdjF2S = F2S/AdjLight;
LowR = min( min( rgdVar ),0.3);
AdjRgdVar = (rgdVar-LowR)/(1-LowR);
alph1 = 0.50; %默认
alph2 = 0.25;%city %0.45;
Fden = alph1*(1- AdjF2S ) + alph2* AdjRgdVar + (1-alph1-alph2)*Fdark; % stdlized

OursTm = toc

iSN = 1:1:img_num;
fig=figure('Color','w');
plot(iSN, F2S,'r-o','LineWidth',2);
text(iSN',F2S',fileNm);
hold on
plot(iSN, rgdVar,'g-+','LineWidth',2);
plot(iSN, Fdark,'b-+','LineWidth',2);
legend('Fsatu', 'Frate','Fdark');
title('Features:Fsatu, Frate, Fdark');


fig2 = figure('Color','w');
plot(iSN, Fden,'b-*','LineWidth',2);
text(iSN,Fden,fileNm);
title('Fog density estimation');

return ;
%Save
svFilePN=[opfilePath,'_Fden_Ours_t',num2str(OursTm),'s1.xls'];
xlswrite(svFilePN,[{'image'},{'AdjF2S'},{'AdjRgdVar'},{'Fdark'},{'Fden'}],'Sheet1','A1:E1');
rowRang = num2str(img_num+1);
xlswrite(svFilePN,fileNm,'Sheet1',['A2:A',rowRang] );
xlswrite(svFilePN,AdjF2S,'Sheet1',['B2:B',rowRang] );
xlswrite(svFilePN,AdjRgdVar,'Sheet1',['C2:C',rowRang] );
xlswrite(svFilePN,Fdark,'Sheet1',['D2:D',rowRang] );
xlswrite(svFilePN,Fden,'Sheet1',['E2:E',rowRang] );

saveas(gcf, [opfilePath,'_Fden_Ours.png'] );
