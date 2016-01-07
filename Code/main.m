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

NumLink = size(A,1);


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

M = [MNew;MExp];
Budget = 95;


%% Active Set Approach
y = zeros(NumCand,2);

AOuter = A;
t0Outer = t0;
caOuter = ca;

xueOuter = UserEqui(AOuter,t0Outer,caOuter,OD,o,d,epsil);
tueOuter = t0Outer.*(1+0.15*(xueOuter./caOuter).^4);
totalueOuter = sum(tueOuter.*xueOuter);

changeMin = -100;

OuterCount = 0;
InnerCount = 0;

tic
while true
    
    [lambda,miu] = MultiplierLM(AOuter,t0Outer,caOuter,...
        OD,o,d,epsil,totalueOuter,NumLink,y,CandNew,CandExp);
    
    OuterCount = OuterCount+1;
    
    [changeSort,changeGSort,changeHSort] = ...
        DecisionGH(y,NumCand,M,Budget,lambda,miu);

    changeMin = changeSort(1);
    
    if changeMin >= 0
        break;
    end
    
    [yInner,AInner,t0Inner,caInner,totalueInner,countInner,...
        changeMin] = GetInner(A,t0,ca,OD,o,d,epsil,y,totalueOuter,...
        changeSort,changeGSort,changeHSort,CandNew,CandExp);
    
    if changeMin >= 0
        break;
    end
    
    y = yInner;
    AOuter = AInner;
    t0Outer = t0Inner;
    caOuter = caInner;
    totalueOuter = totalueInner;
    
    InnerCount = InnerCount+countInner;
    
    Money = sum(sum(M.*y));
    
end


y
totalueOuter
Money = sum(sum(M.*y))
OuterCount
InnerCount
t=toc

