function cosTheta = planeAngle(v1,v2,v3,v4)
%compute the angle between the planes spanned by v1&v2 and v3&v4
%
%MP 2019

cosTheta = blade(v1,v2,v3,v4) ./ sqrt( blade(v1,v2,v1,v2) .* blade(v3,v4,v3,v4) );


function b = blade(v1,v2,v3,v4)

mat = [dot(v1,v3) dot(v1,v4);
    dot(v2,v3) dot(v2,v4)];

b = det(mat);