function y=Fitness(x)
%we used this function to calculate the fitness value  
global A trn vald 
a = 46;
b = 50;
r = (b-a).*rand(100,1) + a;
r_r = [min(r)];
z = r_r;
SzW=0.01;
 x=x>0.5;
 x=cat(2,x,zeros(size(x,1),1));
 x=logical(x);

if sum(x)==0
    y=inf;
    return;
end

c = knnclassify(A(vald,x),A(trn,x),A(trn,end),30);
cp = classperf(A(vald,end),c);
y = z+(1-SzW)*(cp.CorrectRate)+SzW*sum(x)/(length(x)-1);