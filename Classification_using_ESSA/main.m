
clear all
clc
global A trn vald ;
SearchAgents_no=5; % Number of search agents


Max_iteration=100; % Maximum numbef of iterations
A = load('zoo.dat');
 


r=randperm(size(A,1));
trn=r(1:floor(length(r)/2));
vald=r(floor(length(r)/2)+1:end);
tic
[Best_score,Best_pos,SSA_cg_curve]=ESSA(SearchAgents_no,Max_iteration,0,1,size(A,2)-1,'Fitness');
time = toc;
acc = Accuracy(Best_pos);


fprintf('Accuracy  %f\tFitness:  %f\tSolution:  %s\tDimention: %d\tTime:  %f\n',acc,Best_score,num2str(Best_pos,'%1d'),sum(Best_pos(:)),time);
        


