%{
Description: Plots the segmented image using a custom colormap
Inputs:
    seg  : The segmented image
    k    : The number of classes
    title_str : The title string 
    path : Path where the image will be saved
Outputs:
    None
%}

function showSegmented(seg, k, title_str, path)
    % Custom color map
    map = [0 0 0; 1 0 0; 0 1 0; 0 1 1];
    % Normalize the image to be in [0, 1]
    seg = seg ./ k; 
    % Show and save the image
    fig = imshow(seg);
    colormap(map);
    title(title_str);
    saveas(fig, path, "jpg");
end

