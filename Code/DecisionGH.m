function [changeSort,changeGSort,changeHSort] = ...
    DecisionGH(y,NumCand,M,Budget,lambda,miu)

% DECISIONGH gets all the possible g and h and corresponding change of
% total system UE travel time estimated using lambda and miu
% 
% INPUT PARAMETERS
%
%	y:              Existing improvement plan
%	NumCand:        Number of candidate links
%	M:              Construction cost for candidate links
%	Budget:         Total budget available
%	lambda:         Lambda as indicated in the report
%	miu:            Miu as indicated in the report
%
% OUTPUT PARAMETERS
%
%	changeSort:     Change of total travel time and sorted
%	changeGSort:	Correpsonding decimal g as indicated in the report
%	changeHSort:	Correpsonding decimal h as indicated in the report


% Initialization of g and h
g = zeros(NumCand,2);
h = zeros(NumCand,2);

idxg = find(y == 0);
sizeg = length(idxg);
idxh = find(y == 1);
sizeh = length(idxh);

% Initialization of the outputs
change = [];
changeG = [];
changeH = [];

% Calculation of the outputs
for jg = 1:2^sizeg   % Loop g
    
    % Transfer decimal jg to binary format g
    ig = sizeg;
    DeciNumg = jg-1;
    while ig > 0
        g(idxg(ig)) = floor(DeciNumg/(2^(ig-1)));
        DeciNumg = DeciNumg - g(idxg(ig))*2^(ig-1);
        ig = ig-1;
    end
    
    for jh = 1:2^sizeh   % Loop h
        
        % Transfer decimal jh to binary format h
        ih = sizeh;
        DeciNumh = jh-1;
        while ih > 0
            h(idxh(ih)) = floor(DeciNumh/(2^(ih-1)));
            DeciNumh = DeciNumh - h(idxh(ih))*2^(ih-1);
            ih = ih-1;
        end
        
        % Total money spent on this (g,h)
        MoneyP = sum(sum(M.*y))+sum(sum(M.*g))-sum(sum(M.*h));
        % Check the constraint of y(a,1)+y(a,2)<=1
        validgh = zeros(NumCand,1);
        for iv = 1:NumCand
            validgh(iv) = y(iv,1)+g(iv,1)-h(iv,1)+...
                y(iv,2)+g(iv,2)-h(iv,2);
        end
        
        % Only calculate change for valid (g,h)
        if MoneyP <= Budget && max(validgh) <= 1
            
            % Change estimated using lambda and miu
            change = [change;sum(sum(lambda.*g))-sum(sum(miu.*h))];
            
            % Add (g,h) as valid
            changeG = [changeG;jg];
            changeH = [changeH;jh];
            
        end
    end
end

% Sort the outputs
[changeSort,idxSort] = sort(change);
changeGSort = changeG(idxSort);
changeHSort = changeH(idxSort);
