function y=Fitness(x)
%we used this function to calculate the fitness value  
global A trn vald 
a = 26;
b = 30;
r = (b-a).*rand(100,1) + a;
r_r = [min(r)];
z = r_r;
p = 0.1;
 x=x>0.5;
 x=cat(2,x,zeros(size(x,1),1));
 x=logical(x);

if sum(x)==0
    y=inf;
    return;
end

c = knnclassify(A(vald,x),A(trn,x),A(trn,end),10);
cp = classperf(A(vald,end),c);
y = (1-p)*(cp.ErrorRate)+p*sum(x)/(length(x)-1)-z;
