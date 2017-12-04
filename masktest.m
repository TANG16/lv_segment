a=ones(6,10);
ycontour = [linspace(1,10,10) linspace(10,1,10)];
xcontour = [2*ones(1,10) 4*ones(1,10) ]
mask = poly2mask(ycontour, xcontour, 6, 10)