function [samp_num, CSI_lr_cell, traj, f_lr_cell] = csi_to_traj(word, csi_dir)

file_name = dir(fullfile(csi_dir, [word, '_*.mat']));
%%

lambda = 5.8;
cent_left = [0 0];
cent_right = [41 0];

for i = 1:length(file_name)
    trace(i) = load(fullfile(file_name(i).folder, file_name(i).name));
end

[csi_11, csi_33, edge] = sanit(trace);
%%

samp_s_idx = [];
samp_e_idx = [];
samp_len = [];
% segement csi sequence by the location of edge (paylen~=120)
% each segementation is named a sample
for i = 1:2:length(edge)  
    samp_s_idx((i+1)/2) = edge(i);
    samp_e_idx((i+1)/2) = edge(i+1);
    samp_len((i+1)/2) = samp_e_idx((i+1)/2) - samp_s_idx((i+1)/2) + 1;
end
% 
% %%
samp_num = length(samp_len);
CSI_lr_cell = cell(samp_num,2,1);
f_lr_cell   = cell(samp_num,2,1);
for samp_idx = 1:samp_num
    traj_idx = 1;
    csi_left = csi_11(samp_s_idx(samp_idx):samp_e_idx(samp_idx));
    csi_right = csi_33(samp_s_idx(samp_idx):samp_e_idx(samp_idx));
    
    CSI_lr_cell{samp_idx,1,:} = csi_left;
    CSI_lr_cell{samp_idx,2,:} = csi_right;

    % do circle fitting within a sample
    % *_left: original point at left antenna set
    [c_left, r_left, end_idx_left, loss_left, f_left] = f_est(csi_left);
    [c_right, r_right, end_idx_right, loss_right, f_right] = f_est(csi_right);
    mean_r_left(samp_idx) = mean(r_left(~isinf(r_left)));
    mean_r_right(samp_idx) = mean(r_right(~isinf(r_right)));
    var_r_left(samp_idx) = var(r_left(~isinf(r_left)));
    var_r_right(samp_idx) = var(r_right(~isinf(r_right)));
    
    f_lr_cell{samp_idx,1,:} = f_left;
    f_lr_cell{samp_idx,2,:} = f_right;
    
    of_left = exp(1i*0.4390);
    of_right = exp(1i*1.7300);

    b_min = 5;
    b_max = 50;
    c = 4;
    a_min = sqrt(c^2 + b_min.^2);
    a_max = sqrt(c^2 + b_max.^2);

    for i = 1:length(f_left)
        if f_left(i) ~= inf && f_right(i) ~= inf
            first_idx = i;
            break;
        end
    end
    
    a_left_idx = 1;
    a_right_idx = 1;
%     pl_left = 8 - lambda/2 - lambda * angle(f_left(first_idx)/of_left)/(2*pi); % ?
    pl_left = lambda * angle(f_left(first_idx))/(2*pi);

    while pl_left < 2 * a_max
        if pl_left > 2 * a_min
            a_left = pl_left/2;
%             pl_right = 8 - lambda/2 - lambda * angle(f_right(first_idx)/of_right)/(2*pi);
            pl_right = lambda * angle(f_right(first_idx))/(2*pi);

            while pl_right < 2 * a_max
                if pl_right > 2 * a_min
                    a_right = pl_right/2;
                    [int_x, int_y] = find_traj(a_left, a_right, f_left(first_idx:end), f_right(first_idx:end));
                    if isempty(int_x) == 0
                        traj{samp_idx}{traj_idx} = [int_x int_y];
                        traj_idx = traj_idx + 1;
                    end
                    
                    pl_right = pl_right + lambda;
                else
                    pl_right = pl_right + lambda;
                end
            end
            pl_left = pl_left + lambda;
        else
            pl_left = pl_left + lambda;
        end
    end
end

%%
traj_dir = [csi_dir, '/traj'];

if ~exist(traj_dir, 'dir')
       mkdir(traj_dir);
end

file_name = string([traj_dir, '/', word]);
save(file_name, 'traj');

end
% 
