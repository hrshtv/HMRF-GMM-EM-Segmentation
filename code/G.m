%{
Description: Returns the Gaussian PDF's value at a point
Inputs:
    x     : The point at which to find the Gaussian PDF's value
    mu    : Mean of the Gaussian
    sigma : std dev of the Gaussian 
Outputs:
    p : The PDF value at x
%}

function p = G(x, mu, sigma)
    scale = 1 ./ (sqrt(2*pi)*sigma);
    p = scale .* exp(-1*((x - mu).^2) ./ (2*(sigma.^2)));
end
