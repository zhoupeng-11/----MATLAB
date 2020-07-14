%% 图像预处理
clear all;
image=imread('chepai2.jpg');
figure(1),subplot(3,3,1),imshow(image);title('原图');
I1=rgb2gray(image);
figure(1),subplot(3,3,2),imshow(I1);title('灰度图');
figure(1),subplot(3,3,3),imhist(I1);title('灰度图直方图');
I2=edge(I1,'sobel',0.15,'both');
figure(1),subplot(3,3,4),imshow(I2);title('算子边缘检测');
se=[1;1;1];
I3=imerode(I2,se);
figure(1),subplot(3,3,5),imshow(I3);title('腐蚀后图像');
se=strel('rectangle',[20,20]);
I4=imclose(I3,se);
figure(1),subplot(3,3,6),imshow(I4);title('闭运算后');
I5=bwareaopen(I4,2000);
figure(1),subplot(3,3,7),imshow(I5);title('从对象中移除小对象');
se = strel('rectangle',[50 80]);
I6 = imdilate(I5,se);
figure(1),subplot(3,3,8);imshow(I6);title('膨胀处理');
%%

%% 定位车牌

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 找出长宽比在2~4的区域 %%%%%%%%%%%%%%%%%%%%%%%%%%
ed=edge(I6);
L = bwlabel(I6);%标记连通域
L1 = bwlabel(ed);
p=zeros(1,max(L1(:)));
for i=1:max(L(:))%得到连通域的长宽比
    p(i)=sum(ed(L==i));
    [y,x]=find(L==i);
    x0=min(x(:));
    x1=max(x(:));
    y0=min(y(:));
    y1=max(y(:));
    bl=(x1-x0)/(y1-y0);
    if bl>2&&bl<4
        X0 = x0;
        X1 = x1;
        Y0 = y0;
        Y1 = y1;
    end
end
I7=imcrop(image,[X0,Y0,X1-X0,Y1-Y0]);
figure(1),subplot(3,3,9);imshow(I7);title('裁剪后图像');
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%% 根据蓝色像素点定位车牌位置%%%%%%%%%%%%%%%%%%%%%
[x,y,z]=size(I7);
% 以下为找车牌Y方向蓝色的范围
Blue_y=zeros(y,1);% zeros(M,N) 表示的是M行*N列的全0矩阵
for i=1:x    
    for j=1:y         
        if(I7(i,j,3)>(I7(i,j,1)+I7(i,j,2))&&(I7(i,j,3)>128))%% 判断蓝色像素           
            Blue_y(j,1)= Blue_y(j,1)+1;% 蓝色像素点统计          
        end       
    end       
end
PY1=1; 
while ((Blue_y(PY1,1)<10)&&(PY1<y))%Y方向是车牌的宽，大于5个蓝色像素点判为有车牌的区域        
    PY1=PY1+1;  %PY1是Y坐标方向蓝色范围的下限
end   
PY2=y; 
while ((Blue_y(PY2,1)<10)&&(PY2>PY1))        
    PY2=PY2-1; %PY2是Y坐标方向蓝色范围的上限
end   

% 以下为找车牌X方向蓝色的范围
Blue_x=zeros(1,x);
for i=1:x     
    for j=1:y  % 只需扫描的行         
        if(I7(i,j,3)>(I7(i,j,1)+I7(i,j,2))&&(I7(i,j,3)>128)) %% 判断蓝色像素            
            Blue_x(1,i)= Blue_x(1,i)+1; % 蓝色像素点统计                      
        end      
    end   
end
PX1=1;
while ((Blue_x(1,PX1)<5)&&(PX1<x)) %X方向是车牌的高，大于5个蓝色像素点判为车牌的范围
       PX1=PX1+1; %PX1是X坐标方向蓝色范围的下限
end    
PX2=x;
while ((Blue_x(1,PX2)<3)&&(PX2>PX1)) 
       PX2=PX2-1; %PX2是X坐标方向蓝色范围的上限
end    
I8=I7(PX1:PX2,PY1:PY2,:);% 裁剪图像
figure(2);imshow(I8),title('定位剪切后的彩色车牌图像');
%% 

%% 倾斜矫正

I9=rgb2gray(I8);
figure(4),subplot(2,2,1);imshow(I9);title('灰度图');
I10=edge(I9);
figure(4),subplot(2,2,2);imshow(I10);title('边缘检测');
theta=1:180;    
[R,xp]=radon( I10,theta);
[I0,J]=find(R>=max(max(R)));%找倾斜角
qxj=90-J;
I11=imrotate(I8,qxj,'bilinear','crop');
figure(4),subplot(2,2,3);imshow(I8);title('原图');
figure(4),subplot(2,2,4);imshow(I11);title('倾斜矫正');
thresh = graythresh(I9);     %自动确定二值化阈值；
I12 = im2bw(I9,thresh); 
figure(5),subplot(1,2,1);imshow(I12);title('二值化');
I13=imrotate(I12,qxj,'bilinear','crop');
figure(5),subplot(1,2,2);imshow(I13);title('倾斜调整');
%% 


%% 字符切割

%寻找车牌上下边界
[x,y]=size(I13);
white_count_sx=zeros(x,1);

%寻找车牌上边界
for i=1:x
    for j=1:y
        if(I13(i,j)==1)
           white_count_sx(i,1)= white_count_sx(i,1)+1;
        end
    end
end
test=floor(x/2);
for i=test:-1:1
    if (white_count_sx(i,1)<10)
        croppoint_s=i;
        break;
    end
    if(i==1)
        croppoint_x=1;
    end
end

%寻找车牌下边界
for i=test:x
    if (white_count_sx(i,1)<10)
        croppoint_x=i;
        break;
    end
    if(i==x)
        croppoint_x=x;
    end
end
I13=I13(croppoint_s:croppoint_x,1:y,:);
imshow(I13);title('裁去上下边界');

%切割每个字符
[x,y]=size(I13);
white_count=zeros(y,1);
for i=1:x
    for j=1:y
        if(I13(i,j)==1)
           white_count(j,1)= white_count(j,1)+1;
        end
    end
end

[x,y]=size(I13);
s=zeros(1,7);%用于存储字符左边界
e=zeros(1,7);%用于存储字符右边界
area1=floor(1/(7.5*4)*y);
area2=floor((11/(409))*y);

%搜索第二个字符右边界
e(2)=floor((2/7.5)*y);
for i=e(2):-1:(e(2)-area1)
    if(white_count(i,1)>5)
        e(2)=i;
        break;
    end
    if(e(2)==floor((2/7.55)*y))
        e(2)=(e(2)-area1);
    end
end
%寻找第二个字符左边界
s(2)=floor(e(2)-(45/409)*y);
for i=s(2):(e(1)+area2)
    if(white_count(i,1)>5)
        s(2)=i;
        break;
    end
end

%搜索第一个字符右边界
e(1)=s(2)-floor((10/440)*y);
for i=e(1):-1:(s(2)-area2)
    if(white_count(i,1)>10)
        e(1)=i;
        break;
    end
end
%寻找第一个字符左边界
s(1)=floor(e(1)-(45/409)*y);
if(s(1)<=0)
    s(1)=1;
end
for i=s(1):(s(1)+area2)
    if(white_count(i,1)>5)
        s(1)=i;
        break;
    end
end

%搜索第三个字符左边界
s(3)=e(2)+floor((31/440)*y);
for i=s(3):(s(3)+area2)
    if(white_count(i,1)>5)
        s(3)=i;
        break;
    end
end
%寻找第三个字符右边界
e(3)=floor(s(3)+(45/409)*y);
for i=e(3):-1:(e(3)-area2)
    if(white_count(i,1)>5)
        e(3)=i;
        break;
    end
end

%搜索第四~七个字符左边界
for k=4:7
    s(k)=e(k-1)+floor((10/440)*y);
    for i=s(k):(s(k)+area2)
        if(white_count(i,1)>10)
            s(k)=i;
            break;
        end
    end
%寻找第四~七个字符右边界
    e(k)=floor(s(k)+(45/409)*y);
    for i=e(k):-1:(e(k)-area2)
        if(white_count(i,1)>10)
            e(k)=i;
            break;
        end
    end
end

I_C1=I13(1:x,s(1):e(1),:);
I_C2=I13(1:x,s(2):e(2),:);
I_C3=I13(1:x,s(3):e(3),:);
I_C4=I13(1:x,s(4):e(4),:);
I_C5=I13(1:x,s(5):e(5),:);
I_C6=I13(1:x,s(6):e(6),:);
I_C7=I13(1:x,s(7):e(7),:);
figure(6),subplot(1,7,1);imshow(I_C1);
figure(6),subplot(1,7,2);imshow(I_C2);
figure(6),subplot(1,7,3);imshow(I_C3);
figure(6),subplot(1,7,4);imshow(I_C4);
figure(6),subplot(1,7,5);imshow(I_C5);
figure(6),subplot(1,7,6);imshow(I_C6);
figure(6),subplot(1,7,7);imshow(I_C7);
%% 

%% 归一化为40*20

I_C1=imresize(I_C1,[40 20]);
I_C2=imresize(I_C2,[40 20]);
I_C3=imresize(I_C3,[40 20]);
I_C4=imresize(I_C4,[40 20]);
I_C5=imresize(I_C5,[40 20]);
I_C6=imresize(I_C6,[40 20]);
I_C7=imresize(I_C7,[40 20]);

figure(6),subplot(1,7,1);imshow(I_C1);
figure(6),subplot(1,7,2);imshow(I_C2);
figure(6),subplot(1,7,3);imshow(I_C3);
figure(6),subplot(1,7,4);imshow(I_C4);
figure(6),subplot(1,7,5);imshow(I_C5);
figure(6),subplot(1,7,6);imshow(I_C6);
figure(6),subplot(1,7,7);imshow(I_C7);
%% 

%% 字符识别

names3=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','J','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z','K'];
names2=['A','B','C','D','E','F','G','H','J','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z','K'];
names1=['京','冀','吉','宁','川','晋','贵','沪','津','浙','湘','皖','粤','苏','蒙','豫','赣','辽','鄂','闽','陕','鲁','黑'];

%%%%%%%%%%%% 读取模板 %%%%%%%%%%
file_path = 'F:\Documents\资料\项目\cpsb\样本库\';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.bmp'));%获取该文件夹中所有bmp格式的图像
img_num = length(img_path_list);%获取图像总数量
pattern=cell(1,img_num);
if img_num > 0 %有满足条件的图像 
    for j = 1:img_num %逐一读取图像 
        image_name = img_path_list(j).name;% 图像名 
        image_pattern = imread(strcat(file_path,image_name)); 
        image_pattern = im2bw( image_pattern,0.5); %二值化
        pattern{j}=image_pattern;
    end 
end

distance1 =zeros(1,23);
distance2 =zeros(1,24);
distance3 =zeros(1,10);
result=['','','','','','',''];%存放结果
for m = 1:7
    if(m==1)
        for n=35:57
            C=0;
            distance1(n-34)=sum(sum(abs(I_C1-pattern{n})));
        end
        [value1,number1]=min(distance1);
        result(1)=names1(number1);
    elseif(m==2)
        for n=11:34
            C=0;
            distance2(n-10)=sum(sum(abs(I_C2-pattern{n})));
        end
        [value2,number2]=min(distance2);
        result(2)=names2(number2);
    elseif(m==3)
        for n=1:34
            C=0;
            distance3(n)=sum(sum(abs(I_C3-pattern{n})));
        end
        [value3,number3]=min(distance3);
        result(3)=names3(number3);
    elseif(m==4)
        for n=1:36
            C=0;
            distance3(n)=sum(sum(abs(I_C4-pattern{n})));
        end
        [value3,number3]=min(distance3);
        result(4)=names3(number3);
    elseif(m==5)
        for n=1:36
            C=0;
            distance3(n)=sum(sum(abs(I_C5-pattern{n})));
        end
        [value3,number3]=min(distance3);
        result(5)=names3(number3);
    elseif(m==6)
        for n=1:36
            C=0;
            distance3(n)=sum(sum(abs(I_C6-pattern{n})));
        end
        [value3,number3]=min(distance3);
        result(6)=names3(number3);
    elseif(m==7)
        for n=1:36
            C=0;
            distance3(n)=sum(sum(abs(I_C7-pattern{n})));
        end
        [value3,number3]=min(distance3);
        result(7)=names3(number3);
    end
end
%% 



%% 显示结果

disp(result);
figure(6),subplot(1,7,1);imshow(I_C1);title(result(1));
figure(6),subplot(1,7,2);imshow(I_C2);title(result(2));
figure(6),subplot(1,7,3);imshow(I_C3);title(result(3));
figure(6),subplot(1,7,4);imshow(I_C4);title(result(4));
figure(6),subplot(1,7,5);imshow(I_C5);title(result(5));
figure(6),subplot(1,7,6);imshow(I_C6);title(result(6));
figure(6),subplot(1,7,7);imshow(I_C7);title(result(7));
%%
