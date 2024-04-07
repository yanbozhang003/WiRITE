clear;
close all

letter = {'E','F','G','H','I','G','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

for letter_idx = 16:1:length(letter)
%% measure distances to sensors on the two sides
fileName = [letter{letter_idx},'_1'];
load(['../csi_log/yanbo/uppercase/trace1/',fileName,'.mat']);
n_pkt = length(CSI_st_all);

% CSI sanitization
[csi_11, csi_33, edge] = sanit_ori(CSI_st_all);

samp_s_idx = [];
samp_e_idx = [];
samp_len = [];
lambda = 5.8;
% segement csi sequence by the location of edge (paylen~=120)
% each segementation is named a sample
edge_num = length(edge);
if mod(edge_num,2)==1
    edge_num = edge_num-1;
end
for i = 1:2:edge_num
    samp_s_idx((i+1)/2) = edge(i);
    samp_e_idx((i+1)/2) = edge(i+1);
    samp_len((i+1)/2) = samp_e_idx((i+1)/2) - samp_s_idx((i+1)/2) + 1;
end

samp_num = length(samp_len);
for samp_idx = 1:samp_num
    traj_idx = 1;
    csi_left = csi_11(samp_s_idx(samp_idx):samp_e_idx(samp_idx));
    csi_right = csi_33(samp_s_idx(samp_idx):samp_e_idx(samp_idx));

    % do circle fitting within a sample
    % *_left: original point at left antenna set
    [c_left, r_left, end_idx_left, loss_left, f_left] = f_est(csi_left);
    [c_right, r_right, end_idx_right, loss_right, f_right] = f_est(csi_right);
%     mean_r_left(samp_idx) = mean(r_left(~isinf(r_left)));
%     mean_r_right(samp_idx) = mean(r_right(~isinf(r_right)));
%     var_r_left(samp_idx) = var(r_left(~isinf(r_left)));
%     var_r_right(samp_idx) = var(r_right(~isinf(r_right)));
    
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
save(['./traj_log/uppercase/trace1/',fileName,'.mat'],'traj');
end
% angle_left = unwrap(angle(f_left));
% angle_right = unwrap(angle(f_right));
% 
% speed_light = 3*10^8;
% d_leftSensor = abs(angle_left)/(2*pi*5.8*10^9)*speed_light;
% d_rightSensor = abs(angle_right)/(2*pi*5.8*10^9)*speed_light;
% d_leftSensor = d_leftSensor * 100;
% d_rightSensor = d_rightSensor * 100;
% 
% % subplot(2,1,1)
% % plot(d_leftSensor,'k.-');
% % title('distance to the left sensor');
% % subplot(2,1,2)
% % plot(d_rightSensor,'k.-');
% % title('distance to the right sensor');
% 
% % record trajectory
% x_vec = (d_rightSensor.^2 - d_leftSensor.^2 -1296)/(-36);
% y_vec = sqrt(d_leftSensor.^2-(x_vec-6).^2);
% 
% % plot
% for i = 1:1:length(d_rightSensor)
%     r_left = d_leftSensor(i);
%     r_right = d_rightSensor(i);
%     
%     circle(sensor_x(1),sensor_y(1),r_left);hold on
%     circle(sensor_x(2),sensor_y(2),r_right);hold off
% %     plot(x_vec(i),y_vec(i),'r.','MarkerSize',20);hold on
%     
%     waitforbuttonpress();
% end

%% plot circle function
function h = circle(x,y,r)
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit, 'k--');
    hold off
end

