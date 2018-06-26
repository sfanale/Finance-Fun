a = transpose([1:19]);
b1 = price2ret(a,[],'Periodic');
b2 = price2ret(a,[],'Continuous');
c1 = cumprod(b1+1) - 1;
display('cumulative periodic')
display(c1(end,:))
c2 = cumprod(b2+1) - 1;
display('cumulative continuous')
display(c2(end,:))
d1 = (a(end,:) -a(1,:))/ a(1,:);
display('final – initial')
display(d1)
