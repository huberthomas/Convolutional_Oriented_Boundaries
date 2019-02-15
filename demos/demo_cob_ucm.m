
%% Demo to show the results of COB UCMs

% Close figures and clear command line
close all; home

% Read an input image

I = imread(fullfile(cob_root, 'demos','2010_005731.png'));
% resize_I = imresize(I, 0.5)


% Run COB. For an image of PASCALContext, it should take:
%  - less than 1s on the GPU
%  - around 8s on the CPU
tic; [ucm2, ucms, ~, O, E] = im2ucm(imresize(I, 0.5)); toc;
hierarchy = ucm2hier(ucm2);
save('img2hier.mat')

% Display result
figure;
subplot(1,2,1),imshow(I);title('Input Image');
subplot(1,2,2),imshow(ucm2(3:2:end,3:2:end).^2,[]);title('COB Ultrametric Contour Map');

%% Display orientations
figure;
for ii=1:3
    for angle = 0:0.1:pi
        % Interpolate the confidence at any given angle from the 8 bins
        conf = interpolate_confs(O.conf,angle);

        im = I+0.5*(255-I);
        conf = conf.^5;
        im(:,:,1) = (double(im(:,:,1)).*(1-conf)) + 255*conf;
        im(:,:,2) = (double(im(:,:,2)).*(1-conf));
        im(:,:,3) = (double(im(:,:,3)).*(1-conf));

        imshow(im);
        pause(0.01);
%         imwrite(im,['orient_' sprintf('%0.1f',angle) '.jpg'])
    end
end



function hierarchy = ucm2hier(ucm)
% UCM can be a file or the matrix
if ischar(ucm) % ucm refers to a file
    % Get UCM -> Must be saved as a variable named 'ucm2' or 'ucm.strength'
    load(ucm);
    if ~exist('ucm2', 'var')
        ucm2 = ucm.strength;
    end
elseif (size(ucm,1)>2 && size(ucm,2)>2) % It is a full ucm
    ucm2 = ucm;
    clear ucm;
else
    error('UCM type not accepted');
end

% Get leaves segmentation
tmp_ucm = ucm2;
tmp_ucm(1:2:end,1:2:end)=1; % Make the gridbmap connected
labels = bwlabel(tmp_ucm' == 0, 8); % Transposed for the scanning to be from
                                    %   left to right and from up to down
labels = labels';

% ---------------------------

hierarchy.ucm2 = ucm2;
hierarchy.leaves_part = labels(2:2:end, 2:2:end);

% To hierarchy
[hierarchy.ms_matrix, hierarchy.start_ths, hierarchy.end_ths] = mex_ucm2hier(uint32(hierarchy.leaves_part), hierarchy.ucm2);

% Store it also as a struct
hierarchy.ms_struct = ms_matrix2struct(hierarchy.ms_matrix);
end

