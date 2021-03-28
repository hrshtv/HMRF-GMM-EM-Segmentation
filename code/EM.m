%{
Description: The EM Algorithm
Inputs:
    seg  : The segmented image
    img  : The original corrupted image
    mask : The background mask
    k    : The number of classes
    mu   : The class means 
    sigma: The class std devs
    beta : The tunable penalty value
    eps_EM : Specifies the stopping condition for EM
    N_ICM: Number of iterations to run the ICM for
Outputs:
    seg  : The updated segmented image
    M    : The class memberships
    mu   : The updated class means
    sigma: The updated class std devs
%}

function [seg, M, mu, sigma] = EM(seg, img, mask, k, mu, sigma, beta, eps_EM, N_ICM, N_EM_max)

    [R, C] = size(img);
    
    i_em = 0;
    while true

        % E-Step: 
        
        % Print the log posterior probabilities before update
        p_before = logPosterior(seg, img, mask, mu, sigma, beta);
        % Compute MAP Label Image using ICM
        seg = ICM(seg, img, mask, k, mu, sigma, beta, N_ICM);
        % Print the log posterior probabilities after the ICM update
        p_after = logPosterior(seg, img, mask, mu, sigma, beta);
        fprintf("Before: %d | After: %d\n", p_before, p_after);
        
        % Stopping condition
        rel_change = abs(p_after - p_before) / p_before; 
        if rel_change <= eps_EM || (p_after < p_before)
            break;
        end
        
        % Compute memberships
        M = zeros(R, C, k); % M[i,j,k] denotes the membership value for pixel (i,j) to belong to class k
        for r = 1:R
            for c = 1:C
                if mask(r, c) == 1
                    
                    mij = zeros(k, 1);
                    for i = 1:k
                        % The Likelihood Term:
                        term_1 = G(img(r,c), mu(i), sigma(i));
                        % The Prior Term
                        term_2 = exp(-1*priorPenalty(seg, i, mask, r, c, beta));
                        mij(i) = term_1*term_2;
                    end
                    % Normalizing the memberships:
                    mij = mij ./ sum(mij(:));
                    M(r, c, :) = mij;
                    
                end
            end
        end
        
        % M-Step: Update mu and sigmas according to the memberships computed (ICM Update) 
        for i = 1:k
            % Get the memberships computed in the E-Step for class i
            memb  = M(:, :, i);
            % Update the means
            temp  = memb .* img;
            mu(i) = sum(temp(:)) ./ sum(memb(:));
            % Update the sigmas
            devs = (img - mu(i)).^2;
            temp = memb .* devs;
            var  = sum(temp(:)) ./ sum(memb(:));
            sigma(i) = sqrt(var);
        end
        
        i_em = i_em + 1; 

        % Just a sanity check to ensure that we don't run for too long
        if i_em >= N_EM_max
            break;
        end
    
    end
    
end

