%{
Description: Returns the initial segmentation using K-means algorithm
Inputs:
    img  : The input image
    mask : The background mask
    k    : The number of classes to segment into
    eps  : We stop the iterations when |loss_new - loss_prev|/loss_prev <= eps 
Outputs:
    seg   : The segmented image, each pixel \in {1,...,k}
    mu    : k-vector with the class means
    sigma : k-vector with the class std devs
%}

function [seg, mu, sigma] = KMeans(img, mask, k, eps)

    % Set seed to ensure reproducibility
    rng(1);

    % Initialize
    [R, C] = size(img);
    sigma  = zeros(k, 1); 
    
    % Initialize mu by randomly selecting k points from the foreground (To-do: Better initialization scheme)
    fg = img(mask == 1);
    mu = datasample(fg, k, 'Replace', false);
    
    % Compute the initial segmentation (todo: vectorize)
    seg = zeros(size(img));
    for r = 1:R
        for c = 1:C
            if (mask(r, c) == 1)
                [~, idx]  = min(abs(mu - img(r, c)));
                seg(r, c) = idx;
            end
        end
    end
    
    % Iteratively update mus
    n_iter = 0;
    flag = true;
    while flag
        prev_loss = 0;
        new_loss = 0;
        % Update mu and compute energies
        for i = 1:k
            mask_i = (seg == i);
            class_i = img(mask_i);

            % Compute loss before update
            diff = (class_i - mu(i)).^2;
            prev_loss = prev_loss + sum(diff(:));

            % Update the ith mean and compute the corresponding sigma
            mu(i) = mean(class_i(:));
            sigma(i) = std(class_i(:));

            % Update labels
            for r = 1:R
                for c = 1:C
                    if (mask(r, c) == 1)
                        [~, idx] = min(abs(mu - img(r, c)));
                        seg(r, c) = idx;
                    end
                end
            end

            % Compute the new mask
            mask_i  = (seg == i);
            class_i = img(mask_i);

            % Compute loss after update
            diff = (class_i - mu(i)).^2;
            new_loss = new_loss + sum(diff(:));
        end
        
        % Stopping condition
        rel_change = abs(new_loss - prev_loss) / prev_loss;
        if rel_change <= eps
            flag = false;
        end
        
        n_iter = n_iter + 1;
        
    end
    
    fprintf("K-Means ran for %d iterations\n", n_iter);

end

