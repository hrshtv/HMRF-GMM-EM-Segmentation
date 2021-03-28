%{
Description: Finds the optimal labelling using a modified ICM algorithm 
Inputs:
    seg  : The segmented image
    img  : The original corrupted image
    mask : The background mask
    k    : The number of classes
    mu   : The class means 
    sigma: The class std devs
    beta : The tunable penalty value
    N_ICM: Number of iterations to run the ICM for
Outputs:
    seg  : The updated segmented image
%}

function seg = ICM(seg, img, mask, k, mu, sigma, beta, N_ICM)

    [R, C] = size(img);
    
    for iter = 1:N_ICM
        
        seg_new = zeros(size(img));
        
        % Iterate over all valid pixels
        for r = 1:R
            for c = 1:C
                if mask(r, c) == 1
                    
                    % Iterate over all possible values of x_rc and select the best one
                    pe_best = -inf;
                    class_best = 0;
                    
                    for i = 1:k
                        % The Likelihood Term:
                        term_1 = G(img(r, c), mu(i), sigma(i));
                        % The Prior Term
                        term_2 = exp(-1*priorPenalty(seg, i, mask, r, c, beta));
                        % Posterior Energy
                        pe = term_1*term_2;
                        % Update
                        if pe > pe_best
                            pe_best = pe;
                            class_best = i;
                        end
                    end   
                    
                    seg_new(r, c) = class_best;
                    
                end
            end
        end
        
        % Parallel Update
        seg = seg_new;
        
    end
    
end