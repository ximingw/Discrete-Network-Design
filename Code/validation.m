close all; clear; clc

A = xlsread('NetworkData.xlsx','Link','B2:C77');
t0 = xlsread('NetworkData.xlsx','Link','D2:D77');
ca = xlsread('NetworkData.xlsx','Link','E2:E77');

OD = xlsread('NetworkData.xlsx','OD','C3:P16');
o = xlsread('NetworkData.xlsx','OD','B3:B16');
d = xlsread('NetworkData.xlsx','OD','C2:P2');

CandNew = xlsread('NetworkData.xlsx','Candidate','B2:H7');
CandExp = xlsread('NetworkData.xlsx','Candidate','A9:H10');

epsil = 1e-5;


%% Get the information of the candidate links
ANew = CandNew(:,1:2);
t0New = CandNew(:,3);
caNew(:,1) = CandNew(:,4);
caNew(:,2) = CandNew(:,6);
MNew(:,1) = CandNew(:,5);
MNew(:,2) = CandNew(:,7);

IndExp = CandExp(:,1);
caExp(:,1) = CandExp(:,5);
caExp(:,2) = CandExp(:,7);
MExp(:,1) = CandExp(:,6);
MExp(:,2) = CandExp(:,8);

NumNew = size(CandNew,1);
NumExp = size(CandExp,1);

NumCand = NumNew+NumExp;

Budget = 95;


%% Validate by enumeration

% Enumerate all the 3^NumCand improvement plans
% First transfer plan number into ternary number
a = zeros(NumCand,3^NumCand);
for j = 1:3^NumCand
    i = NumCand;
    DeciNum = j-1;
    while i > 0
        a(i,j) = floor(DeciNum/(3^(i-1)));
        DeciNum = DeciNum - a(i,j)*3^(i-1);
        i = i-1;
    end
end

% Initialization of the outputs
totalueMin = inf;
ValidCount = 0;

tic

for count = 1:3^NumCand
    
    y = zeros(NumCand,2);
    
    % Get y from a
    for i = 1:NumCand
        if a(i,count) == 1
            y(i,:) = [1 0];
        end
        if a(i,count) == 2
            y(i,:) = [0 1];
        end
    end
    
    % Get AE,t0E,caE for the corresponding plan
    AE = A;
    t0E = t0;
    caE = ca;
    for i = 1:NumNew
        if a(i,count) > 0
            AE = [AE;ANew(i,:)];
            t0E = [t0E;t0New(i)];
            caE = [caE;caNew(i,1)*y(i,1)+caNew(i,2)*y(i,2)];
        end
    end
    for i=1:NumExp
        caE(IndExp(i)) = ca(IndExp(i)) + ...
            caExp(i,1)*y(NumNew+i,1) + caExp(i,2)*y(NumNew+i,2);
    end

    % Money spent on the corresponding plan
    Money = 0;
    for mn = 1:NumNew
        Money = Money + MNew(mn,1)*y(mn,1) + MNew(mn,2)*y(mn,2);
    end
    for me = 1:NumExp
        Money = Money + ...
            MExp(me,1)*y(NumNew+me,1) + MExp(me,2)*y(NumNew+me,2);
    end
    
    % Get UE total system travel time if budget satisfied
    if Money <= Budget
        ValidCount = ValidCount+1;
        xueE = UserEqui(AE,t0E,caE,OD,o,d,epsil);
        tueE = t0E.*(1+0.15*(xueE./caE).^4);
        totalueE = sum(tueE.*xueE);
        if totalueE < totalueMin
            yMin = y;
            totalueMin = totalueE;
            totalMoney = Money;
        end
    end
    
end

ValidCount
t = toc

yMin
totalueMin
totalMoney
