# Major-Project
Improving Classification Accuracy Using Enhanced Salp Swarm Algorithm

In this project we have studied and compared SSA with other bio-inspired optimisation algorithms and then we have improved basic SSA to enhance solution accuracy , reliability and convergence speed.In the Enhanced SSA we made some changes in c1 parameter. We replaced the original equation with a more converging exponential equation to make SSA converge faster. We used both unimodal and multimodal test functions to test and compare ESSA and SSA. We then used SSA and K- nearest neighbour (KNN) classifier for feature selection in which several datasets were utilised to assess and compare the performance of ESSA. We found that ESSA produced superior results to all other Algorithms in majority of cases.

SSA - It a recently introduced Bio-inspired algorithm that is based on the swarming mevchanism of salps.

KNNClassify.m - KNNCLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the data in SAMPLE into one of the groups in TRAINING using the nearest-neighbor method. SAMPLE and TRAINING must be matrices with the same number of columns. GROUP is a grouping variable for TRAINING. Its unique values define groups, and each element defines the group to which the corresponding row of TRAINING belongs.

Initialisation.m - Initialises the first population of Search Agents.

Get_Function_Details.m - It contains all the information and implementation of benchmark functions used.

Classperf.m - CLASSPERF evaluates the performance of data classifiers. CLASSPERF creates and updates a CLASSPERFORMANCE object which accumulates the results of the classifier.

Classperformance.m - It is a class constructor for CP objects.

Fitness.m - It is used to calculate the Fitness value.

Accuracy.m - It is used to calculate the accuracy.
