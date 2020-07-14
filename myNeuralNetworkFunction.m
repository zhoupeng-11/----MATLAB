%数据导入
data=importdata('pattern3.xlsx');
input=data(1:200,1:1711);
output=data(201:234,1:1711); 

input_train=input(1:200,1:1711);  %神经网络输入数据 
label_train=output(1:34,1:1711);  %神经网络输出对比标准

%BP神经网络设置
net=newff(minmax(input_train),label_train,18,{'logsig','purelin'});
net.trainparam.show = 50; % 显示训练结果(训练50次显示一次)
net.trainParam.epochs=10000;
net.trainParam.lr=0.01;
net.trainParam.mc=0.9;
net.trainParam.goal=0.01;
net.trainParam.max_fail=6;
net=init(net);

net=train(net,input_train,label_train);%神经网络训练
save('shuzizifu3','net');%保存神经网络

%读入测试图像
image=imread('C:\Users\11422\Desktop\cpsb\测试\09.png');
image=imresize(image,[20 10]);
image=reshape(image,200,1);
input_test=image;
y=sim(net,input_test);%y=sim(net,x);net表示已训练好的网络，x表示输入数据，y表示网络预测数据。表示用训练好的网络预测输出函数
[num,n]=max(y);