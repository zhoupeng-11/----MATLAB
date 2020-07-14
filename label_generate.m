label=zeros(34,1700);
k=0;
for k=1:34
    for i=1:34
        for j=(k*50-49):(k*50)
            if(i==k)
                label(i,j)=1;
            else
                label(i,j)=0;
            end
        end
    end
end
xlswrite('pattern3.xlsx', label,'sheet1','A801:BMJ834');   