# ----MATLAB
这是一个在MATLAB上实现车牌识别的程序，识别算法有两种，分别为神经网络和模板匹配

1、文件夹“charSamples”为神经网络训练的样本图片

2、文件夹“样本库”为模板匹配方法的模板

3、在神经网络训练中，我将文件夹“charSamples”中的样本图片都转     换成适合神经网络输入的列向量存到Excel表格中（为文件夹“代码     ”中的pattern3.xlsx）

4、文件夹“代码”中的
	cpsb_ModelMatch.m为模板匹配方法代码
	cpsb_NeuralNetwork.m为神经网络方法代码
	myNeuralNetworkFunction.m为神经网络训练代码
	WriteModel2Excel.m为将样本图片写入Excel文件的代码
	label_generate.m为生成神经网络输出数据的代码
	shuzizifu3.mat保存训练好的神经网络
