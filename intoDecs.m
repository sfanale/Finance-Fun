function [Dec1, Dec10, Dec2, Dec3, Dec4, Dec5, Dec6, Dec7, Dec8, Dec9] = intoDecs( Univ1)
%Univ in form permno, date, value ; gives back pernmos of each dec in Nx10
%array

Temp2 = sortrows(Univ1,[2,3]); %sort by date then value

orderstat = round((.1)*size(Temp2,1),0); %Find the order statistic i.e. which observations to choose 

permno=Temp2(1:orderstat,1);
Dec1=permno;
permno= Temp2(orderstat*9:end,1);
Dec10=permno;
permno= Temp2(orderstat*1:orderstat*2,1);
Dec2=permno;    %the Permnos of each dec at this date
permno= Temp2(orderstat*2:orderstat*3,1);
Dec3= permno;
permno= Temp2(orderstat*3:orderstat*4,1);
Dec4=permno;
permno= Temp2(orderstat*4:orderstat*5,1);
Dec5= permno;
permno= Temp2(orderstat*5:orderstat*6,1);
Dec6=permno;
permno= Temp2(orderstat*6:orderstat*7,1);
Dec7=permno;
permno= Temp2(orderstat*7:orderstat*8,1);
Dec8=permno;
permno= Temp2(orderstat*8:orderstat*9,1);
Dec9=permno;


end
