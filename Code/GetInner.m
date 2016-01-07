function [yInner,AInner,t0Inner,caInner,totalueInner,countInner,...
    changeMin] = GetInner(A,t0,ca,OD,o,d,epsil,y,totalueOuter,...
    changeSort,changeGSort,changeHSort,CandNew,CandExp)

% GETINNER finds the new improvement plan which can truly reduce the total
% system UE travel time
%
% INPUT PARAMETERS
%
%	A:              Original network links
%	t0:             Original network link free-flow travel time
%	ca:             Original network link capacity
%	OD:             O-D trip matrix
%	o:              Origin node index (row index of OD matrix)
%	d:              Destination node index (column index of OD matrix)
%	epsil:          Stopping criteria for UE calculation
%	y:              Existing improvement plan
%	totalueOuter:	Total system UE travel time for y
%	changeSort:     Change of total travel time and sorted
%	changeGSort:	Decimal g as indicated in the report
%	changeHSort:	Decimal h as indicated in the report
%	CandNew:        Information of new candidate links
%	CandExp:        Information of expanding candidate links
%
% OUTPUT PARAMETERS
%
%	yInner:         New improvement plan
%	AInner:         New network plan links
%	t0Inner:        New network plan link free-flow travel time
%	caInner:        New network plan link capacity
%	totalueInner:   Total system UE travel time for yInner
%	countInner:     Number of iterations in the inner loop
%	changeMin:      Min change of total travel time after inner loop


% Get the information of the candidate links
ANew = CandNew(:,1:2);
t0New = CandNew(:,3);
caNew(:,1) = CandNew(:,4);
caNew(:,2) = CandNew(:,6);

IndExp = CandExp(:,1);
caExp(:,1) = CandExp(:,5);
caExp(:,2) = CandExp(:,7);

NumNew = size(CandNew,1);
NumExp = size(CandExp,1);
NumCand = NumNew+NumExp;


% Initialization of g and h
g = zeros(NumCand,2);
h = zeros(NumCand,2);

idxg = find(y == 0);
sizeg = length(idxg);
idxh = find(y == 1);
sizeh = length(idxh);


% Initialization of totalueInner and index
totalueInner = inf;
iS = 1;


% Get new improvement plan which can truly reduce total travel time
while totalueInner > totalueOuter
    
    % Transfer decimal changeGSort(iS) to binary format g
    ig = sizeg;
    DeciNumg = changeGSort(iS)-1;
    while ig > 0
        g(idxg(ig)) = floor(DeciNumg/(2^(ig-1)));
        DeciNumg = DeciNumg - g(idxg(ig))*2^(ig-1);
        ig = ig-1;
    end
    
    % Transfer decimal changeHSort(iS) to binary format h
    ih = sizeh;
    DeciNumh = changeHSort(iS)-1;
    while ih > 0
        h(idxh(ih)) = floor(DeciNumh/(2^(ih-1)));
        DeciNumh = DeciNumh - h(idxh(ih))*2^(ih-1);
        ih = ih-1;
    end
    
    % New improvement plan
    yInner = y+g-h;
    
    % Get AInner,t0Inner,caInner for yInner
    AInner = A;
    t0Inner = t0;
    caInner = ca;
    for i = 1:NumNew
        if yInner(i,1)+yInner(i,2) > 0
            AInner = [AInner;ANew(i,:)];
            t0Inner = [t0Inner;t0New(i)];
            caInner = [caInner;
                caNew(i,1)*yInner(i,1)+caNew(i,2)*yInner(i,2)];
        end
    end
    for i=1:NumExp
        caInner(IndExp(i)) = ca(IndExp(i)) + ...
            caExp(i,1)*yInner(NumNew+i,1) + caExp(i,2)*yInner(NumNew+i,2);
    end
    
    % Calculate total system UE travel time for yInner
    xueInner = UserEqui(AInner,t0Inner,caInner,OD,o,d,epsil);
    tueInner = t0Inner.*(1+0.15*(xueInner./caInner).^4);
    totalueInner = sum(tueInner.*xueInner);
    
    % If the improvement plan cannot reduce total system travel time,
    % proceed to the next (g,h)
    iS = iS+1;
    
end

countInner = iS-1;
changeMin = changeSort(iS-1);