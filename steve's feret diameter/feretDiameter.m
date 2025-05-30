function [d,V1,V2] = feretDiameter(V,theta)
% Copyright 2017-2018 The MathWorks, Inc.

% Rotate points so that the direction of interest is vertical.

alpha = 90 - theta;

ca = cosd(alpha);
sa = sind(alpha);
R = [ca -sa; sa ca];

% Vr = (R * V')';
Vr = V * R';

y = Vr(:,2);
ymin = min(y,[],1);
ymax = max(y,[],1);

d = ymax - ymin;

if nargout > 1
    V1 = V(y == ymin,:);
    V2 = V(y == ymax,:);
end
end
