function xue = UserEqui(A,t0,ca,OD,o,d,epsil)

% USEREQUI gets the link volumes under user equilibrium condition using
% Frank-Wolfe Algorithm
%
% INPUT PARAMETERS
%
%	A:      Links, with direction from A(:,1) to A(:,2)
%	t0:     Link free-flow travel time
%	ca:     Link capacity
%	OD:     O-D trip matrix
%	o:      Origin node index (row index of O-D trip matrix)
%	d:      Destination node index (column index of O-D trip matrix)
%	epsil:  Stopping criteria
%
% OUTPUT PARAMETERS
%
%	xue:	Link volumes under user equilibrium


% Initialization
n = size(A,1);   % n = number of links
x0 = zeros(n,1);
t = t0.*(1+0.15*(x0./ca).^4);   % link travel time


% Perform all-or-nothing assignment to get x1
x1 = AllorNothing(A,t,OD,o,d);


% Successive calculation to get the UE solution
ex1x2 = epsil;   % stopping criteria
delta_x1x2 = ex1x2+1;

while delta_x1x2 > ex1x2

    t1 = t0.*(1+0.15*(x1./ca).^4);   % link travel time
    
    % Perform all-or-nothing assignment to get y(n)
    y1 = AllorNothing(A,t1,OD,o,d);

    % Get the optimal value of alpha using bisection method
    a = 0;
    b = 1;
    eab = 1e-5;   % stopping criteria for bisection method
    delta = y1-x1;
    while (b-a)/2 > eab
        alpha = (a+b)/2;
        salpha = sum(delta.*t0.*(1+0.15*(((x1+alpha*delta)./ca).^4)));
        if salpha < 0
            a = alpha;
        else
            b = alpha;
        end
    end

    % Get x(n+1)
    x2 = x1 + alpha*(y1-x1);

    % Convergence test
    delta_x1x2 = sqrt(sum((x2-x1).^2))/sum(x1);

    % Successive x(n+1)
    x1 = x2;

end

xue = x1;
