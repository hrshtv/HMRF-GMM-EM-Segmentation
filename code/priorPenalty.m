%{
Description: The prior penalty for the given pixel using a 4 neighbourhood system, without wrap-around, uses the Potts Model 
Inputs:
    X    : The segmented image at any iteration
    xij  : The label at pixel (i,j). This is taken as a separate input to simplify the ICM step.
    mask : The background mask
    i,j  : The pixel's position (assumed to be not at the actual image's boundary)
    beta : The tunable penalty value
Outputs:
    penalty : The prior penalty for the given pixel using a 4 neighbourhood
    system, without wrap-around
%}

function penalty = priorPenalty(X, xij, mask, i, j, beta)
    if beta == 0
        penalty = 0;
    else
        % If neighbour =/= xij, then the penalty is beta
        left  = mask(i-1, j)*(X(i-1, j) ~= xij);
        right = mask(i+1, j)*(X(i+1, j) ~= xij);
        down  = mask(i, j-1)*(X(i, j-1) ~= xij);
        up    = mask(i, j+1)*(X(i, j+1) ~= xij);
        penalty = beta*(left + right + up + down);
    end
end

