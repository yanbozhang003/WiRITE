clear;
close all

%% measure distances to sensors on the two sides
fileName = 'B_2';
load(['../csi_log/yanbo/uppercase/trace2/',fileName,'.mat']);
n_pkt = length(CSI_st_all);

% CSI sanitization
csi_11 = zeros(1,1); csi_33 = zeros(1,1); edge   = zeros(1,1);
csi_cnt  = 0; edge_cnt = 0; err_cnt = 0;
for pkt_idx = 1:1:n_pkt
    csi = CSI_st_all(1,pkt_idx).csi;
    nr = CSI_st_all(1,pkt_idx).nr;
    nc = CSI_st_all(1,pkt_idx).nc;
    paylen = CSI_st_all(1,pkt_idx).payload_len;
    
    if nr~=3 || nc~=3
        err_cnt = err_cnt + 1;
        continue
    end
    
    if paylen ~= 120
        edge_cnt = edge_cnt+1;
        edge(edge_cnt) = pkt_idx;
    end
    
    % sanitize
    csi_cnt = csi_cnt + 1;
    csi_11(csi_cnt) = mean(csi(1,1,:)./csi(1,2,:));
    csi_33(csi_cnt) = mean(csi(3,3,:)./csi(3,2,:));

    disp(pkt_idx)
end

% the two rows of csi_sample represent csi samples relative to the left and
% right sensors
csi_sample_struct = cell(1,1);
for i = 1:2:edge_cnt
    ii = i+1;
    csi_sample_tmp = [csi_11(1,edge(i):edge(ii));csi_33(1,edge(i):edge(ii))];
    csi_sample_tmp = movmean(csi_sample_tmp,10,2);
    csi_sample_struct{1,ii/2} = csi_sample_tmp;
end

% csi_sample = [csi_11(1,edge(1):edge(2));csi_33(1,edge(1):edge(2))];
% csi_sample = movmean(csi_sample,10,2);

% angle_sample = angle(csi_sample);
% subplot(2,1,1)
% plot(angle_sample(1,:),'k.-');title('phase relative to left sensor');
% subplot(2,1,2)
% plot(angle_sample(2,:),'k.-');title('phase relative to right sensor');

% compute distance to left and right sensor
traj = cell(1,1);
for samp_idx = 1:1:edge_cnt/2
    csi_sample = csi_sample_struct{1,samp_idx};
    [c_left, r_left, end_idx_left, loss_left, f_left] = f_est(csi_sample(1,:));
    [c_right, r_right, end_idx_right, loss_right, f_right] = f_est(csi_sample(2,:));

    % record trajectory
    b_min = 5;
    b_max = 50;
    c = 4;
    a_min = sqrt(c^2 + b_min.^2);
    a_max = sqrt(c^2 + b_max.^2);
    lambda = 5.8;

    for i = 1:length(f_left)
        if f_left(i) ~= inf && f_right(i) ~= inf
            first_idx = i;
            break;
        end
    end

    pl_left = lambda * angle(f_left(first_idx))/(2*pi);

    traj_idx = 1;
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
save(['./traj_log/uppercase/trace2/',fileName,'.mat'],'traj');
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

