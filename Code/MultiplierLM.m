function [lambda,miu] = MultiplierLM(AOuter,t0Outer,caOuter,...
    OD,o,d,epsil,totalueOuter,NumLink,y,CandNew,CandExp)

% MULTIPLIERLM gets lambda and miu for the outer network plan
%
% INPUT PARAMETERS
%
%	AOuter:         Links, with direction from A(:,1) to A(:,2)
%	t0Outer:        Link free-flow travel time
%	caOuter:        Link capacity
%	OD:             O-D trip matrix
%	o:              Origin node index (row index of OD matrix)
%	d:              Destination node index (column index of OD matrix)
%	epsil:          Stopping criteria for UE calculation
%	totalueOuter:	Total system UE travel time for y
%	NumLink:        Number of links for the original network A
%	y:              Existing improvement plan
%	CandNew:        Information of new candidate links
%	CandExp:        Information of expanding candidate links
%
% OUTPUT PARAMETERS
%
%	lambda:         Lambda as indicated in the report
%	miu:            Miu as indicated in the report


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


% Initialization of lambda and miu
lambda = zeros(NumCand,2);
miu = zeros(NumCand,2);


% Calculation of lambda and miu
for a = 1:NumCand
    
    % Case of y(a,1)=0 and y(a,2)=0
    if y(a,:) == [0 0]
        
        if a <= NumNew   % Add new candidate link
            
            A10 = [AOuter;ANew(a,:)];
            t010 = [t0Outer;t0New(a)];
            ca10 = [caOuter;caNew(a,1)];
            
            A01= [AOuter;ANew(a,:)];
            t001 = [t0Outer;t0New(a)];
            ca01 = [caOuter;caNew(a,2)];
            
        else   % Change the capacity of expanding candidate link
            
            ind = a-NumNew;
            
            A10 = AOuter;
            t010 = t0Outer;
            ca10 = caOuter;
            ca10(IndExp(ind)) = ca10(IndExp(ind))+caExp(ind,1);
            
            A01 = AOuter;
            t001 = t0Outer;
            ca01 = caOuter;
            ca01(IndExp(ind)) = ca01(IndExp(ind))+caExp(ind,2);
            
        end
        
        % Get z00, z01, z10 values
        z00 = totalueOuter;
        
        x10 = UserEqui(A10,t010,ca10,OD,o,d,epsil);
        t10 = t010.*(1+0.15*(x10./ca10).^4);
        z10 = sum(t10.*x10);
        
        x01 = UserEqui(A01,t001,ca01,OD,o,d,epsil);
        t01 = t001.*(1+0.15*(x01./ca01).^4);
        z01 = sum(t01.*x01);
        
        % Calculate lambda and miu
        lambda(a,1) = z10-z00;
        lambda(a,2) = z01-z00;
        
        miu(a,1) = 0;
        miu(a,2) = 0;
        
    end
    
    
    % Case of y(a,1)=1 and y(a,2)=0
    if y(a,:) == [1 0]
        
        if a <= NumNew
            
            % Delete the candidate link
            LinkCount = 0;
            for i = 1:a
                if sum(y(i,:)) > 0
                    LinkCount = LinkCount+1;
                end
            end
            ind = NumLink+LinkCount;
            
            A00 = [AOuter(1:ind-1,:);AOuter(ind+1:end,:)];
            t000 = [t0Outer(1:ind-1);t0Outer(ind+1:end)];
            ca00 = [caOuter(1:ind-1);caOuter(ind+1:end)];
            
            % Change the capacity of the candidate link
            A01= AOuter;
            t001 = t0Outer;
            ca01 = caOuter;
            ca01(ind) = caNew(a,2);
            
        else   % Change the capacity of expanding candidate link
            
            ind = a-NumNew;
            
            A00 = AOuter;
            t000 = t0Outer;
            ca00 = caOuter;
            ca00(IndExp(ind)) = ca00(IndExp(ind))-caExp(ind,1);
            
            A01 = AOuter;
            t001 = t0Outer;
            ca01 = ca00;
            ca01(IndExp(ind)) = ca01(IndExp(ind))+caExp(ind,2);
            
        end
        
        % Get z00, z01, z10 values
        z10 = totalueOuter;
        
        x00 = UserEqui(A00,t000,ca00,OD,o,d,epsil);
        t00 = t000.*(1+0.15*(x00./ca00).^4);
        z00 = sum(t00.*x00);
        
        x01 = UserEqui(A01,t001,ca01,OD,o,d,epsil);
        t01 = t001.*(1+0.15*(x01./ca01).^4);
        z01 = sum(t01.*x01);
        
        % Calculate lambda and miu
        lambda(a,1) = 0;
        lambda(a,2) = z01-z00;
        
        miu(a,1) = z10-z00;
        miu(a,2) = 0;
        
    end
    
    
    % Case of y(a,1)=0 and y(a,2)=1
    if y(a,:) == [0 1]
        
        if a <= NumNew
            
            % Delete the candidate link
            LinkCount = 0;
            for i = 1:a
                if sum(y(i,:)) > 0
                    LinkCount = LinkCount+1;
                end
            end
            ind = NumLink+LinkCount;
            
            A00 = [AOuter(1:ind-1,:);AOuter(ind+1:end,:)];
            t000 = [t0Outer(1:ind-1);t0Outer(ind+1:end)];
            ca00 = [caOuter(1:ind-1);caOuter(ind+1:end)];
            
            % Change the capacity of the candidate link
            A10= AOuter;
            t010 = t0Outer;
            ca10 = caOuter;
            ca10(ind) = caNew(a,1);
            
        else   % Change the capacity of expanding candidate link
            
            ind = a-NumNew;
            
            A00 = AOuter;
            t000 = t0Outer;
            ca00 = caOuter;
            ca00(IndExp(ind)) = ca00(IndExp(ind))-caExp(ind,2);
            
            A10 = AOuter;
            t010 = t0Outer;
            ca10 = ca00;
            ca10(IndExp(ind)) = ca10(IndExp(ind))+caExp(ind,1);
            
        end
        
        % Get z00, z01, z10 values
        z01 = totalueOuter;
        
        x00 = UserEqui(A00,t000,ca00,OD,o,d,epsil);
        t00 = t000.*(1+0.15*(x00./ca00).^4);
        z00 = sum(t00.*x00);
        
        x10 = UserEqui(A10,t010,ca10,OD,o,d,epsil);
        t10 = t010.*(1+0.15*(x10./ca10).^4);
        z10 = sum(t10.*x10);
        
        % Calculate lambda and miu
        lambda(a,1) = z10-z00;
        lambda(a,2) = 0;
        
        miu(a,1) = 0;
        miu(a,2) = z01-z00;
        
    end
    
end
