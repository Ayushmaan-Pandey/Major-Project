
clear all 
clc

SearchAgents_no=30; % Number of search agents

Function_name='F1'; % Name of the test function that can be from F1 to F13 ( 
%% 

Max_iteration=1000; % Maximum numbef of iterations

% Load details of the selected benchmark function
[lb,ub,dim,fobj]=Get_Functions_details(Function_name);

[Best_score,Best_pos,SSA_cg_curve]=SSA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);

figure('Position',[500 500 660 290])
%Draw search space
subplot(1,2,1);
func_plot(Function_name);
title('Parameter space')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])

%Draw objective space
subplot(1,2,2);
semilogy(SSA_cg_curve,'Color','r')
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');

axis tight
grid on
box on
legend('SSA')

display(['The best solution obtained by SSA is \m ', num2str(Best_pos)]);
display(['The best optimal value found by SSA is \n ', num2str(Best_score)]);

        


