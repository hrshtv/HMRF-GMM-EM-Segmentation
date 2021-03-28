%{
Description: Computes the log of the posterior probability for the labels (up to a constant)
Inputs:
    seg  : The segmented image
    img  : The original corrupted image
    mask : The background mask
    mu   : The class means 
    sigma: The class std devs
    beta : The tunable penalty value
Outputs:
    logp : log posterior probability for the labels (up to a constant)
%}

function logp = logPosterior(seg, img, mask, mu, sigma, beta)

    nlogp = 0; % stores the negative log posterior (up to a constant)
    [R, C]  = size(img);
    
    % Iterate over all (valid) pixels
    for r = 1:R
        for c = 1:C
            if mask(r, c) == 1
                
                % Get the label of x_(r,c)
                xi = seg(r, c); 
                yi = img(r, c);
                
                % Negative Log-Likelihood Term
                nlogl  = -1*log(G(yi, mu(xi), sigma(xi)));
                
                % Negative Log-Prior Term
                nlogpr = 0.5*(priorPenalty(seg, xi, mask, r, c, beta));  
                
                % Update the negative log posterior
                nlogp = nlogp + nlogl + nlogpr;
                
            end
        end
    end

    % The posterior probability: As all the normalizing constants have been
    % removed from the logp expression, -logp is a very large quantity (as
    % summed over a lot of pixels) and exp(-logp) becomes inf, thus we use logp instead of p
    logp = -1*nlogp;
    
end

