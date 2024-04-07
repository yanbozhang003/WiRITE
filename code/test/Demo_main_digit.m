function collect_csi

clear all;

cleanupObj = onCleanup(@cleanMeUp);

addpath('../function/msocket_func/');

server_sock 	= mslisten(6767);
sock_vec_in     = zeros(1,1,'int32');

sock_vec_in(1,1)= server_sock;

sock_cnt_in    = length(sock_vec_in);
sock_max    = max(sock_vec_in);
sock_min    = min(sock_vec_in);
car_num = 56;

index = 0;
total = 0;
FILL_FLAG = 0;
csi_cnt = 0;
edge_count = 0;

digit = {'0','1','2','3','4','5','6','7','8','9'};
letter = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','d','e','f','g','h','n','q','r','t'};
chinese = {'��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','ô','��','ľ','��','ţ','Ů','Ƭ','��','��','��','ǧ','Ƿ','Ȯ','��','��','ɽ','��','��','��','ʬ','ʿ','��','��','ˮ','��','��','��','��','��','��','Ϊ','��','��','��','��','��','Ϧ','ϰ','��','��','С','��','��','Ҳ','��','��','��','Ӧ','ӵ','ӽ','��','��','��','��','��','��','��','��','��','��','Ԧ','��','��','��','��','��','��','է','��','��','��','��','��','��','��','֧','֪','֬','֮','ֹ','��','��','��','צ','ר','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��'};

classNames = digit;

if isequal(classNames, digit)
    modelfile = '../ml_model/digit-raw.h5';
    img_size = 28;
elseif isequal(classNames, letter)
    modelfile = '../ml_model/letter-raw.h5';
    img_size = 28;
else
    modelfile = '../ml_model/chinese-raw.h5';
    img_size = 64;
%     img_size = 28;
end
net = importKerasNetwork(modelfile, 'Classes', classNames);

img_dir = './image/';

PLOT = 0;
n_sample_file = 300000;

while 1
    tic
    
    [sock_vec_out,sock_cnt_out,CSI_struct] = msCSI_server_tmp(sock_cnt_in,sock_vec_in,sock_min,sock_max,2);
    if (length(sock_vec_in) > 1)                        % we connect with at least 1 client
        if (length(CSI_struct) >= 1)                     % the output CSI structure must not be empty
            for csi_st_idx = 1:1:length(CSI_struct)     % all the structure
                CSI_entry   = CSI_struct(1,csi_st_idx);
                N_tx        = CSI_entry.nc;
                N_rx        = CSI_entry.nr;
                num_tones   = CSI_entry.num_tones;
                pay_len     = CSI_entry.payload_len;
%               
                if N_rx < 3  || num_tones~= car_num
                    continue;
                end
              
                if N_tx < 3  || num_tones~= car_num
                    continue;
                end
              
                if CSI_struct.MAC_idx ~= 14562
                    continue;
                end
                
                if CSI_struct.noise ~= 0
                    continue;
                end

                if isempty(CSI_struct.csi) == 1
                    continue;
                end
                
                if pay_len ~= 120
                    edge_count = edge_count+1;
                    if mod(edge_count,2)==1
                        FILL_FLAG = 1;
                    elseif mod(edge_count,2)==0
                        FILL_FLAG = 0;
                    end
                end
                
                if FILL_FLAG == 1
                    close all
                    % start filling CSI_st_all
                    csi_cnt = csi_cnt + 1;
                    CSI_st_all(csi_cnt) = CSI_entry;
                elseif FILL_FLAG == 0
                    if csi_cnt ~= 0
                     %% csi sanit
                        csi_cnt  = 0;
                        csi_11 = zeros(1,1); csi_33 = zeros(1,1); edge = zeros(1,1);
                        edge_cnt = 2; edge(1) = 1; edge(2) = length(CSI_st_all);
                        for pkt_idx = 1:1:length(CSI_st_all)
                            csi = CSI_st_all(1,pkt_idx).csi;
                            
                            csi_cnt = csi_cnt + 1
                            csi_11(csi_cnt) = mean(csi(1,1,:)./csi(1,2,:));
                            csi_33(csi_cnt) = mean(csi(3,3,:)./csi(3,2,:));
                        end
                     %% csi to traj, then to img
                        % the two rows of csi_sample represent csi samples relative to the left and
                        % right sensors
                        csi_sample_struct = cell(1,1);
                        for edge_idx = 1:2:edge_cnt
                            ii = edge_idx+1;
                            csi_sample_tmp = [csi_11(1,edge(edge_idx):edge(ii));csi_33(1,edge(edge_idx):edge(ii))];
                            csi_sample_tmp = movmean(csi_sample_tmp,10,2);
                            csi_sample_struct{1,ii/2} = csi_sample_tmp;
                        end
                        
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

                            for iDx = 1:length(f_left)
                                if f_left(iDx) ~= inf && f_right(iDx) ~= inf
                                    first_idx = iDx;
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
                        
%                         save(['test_traj_',num2str(edge_count/2),'.mat'],'traj');
                     %% classification
                        % traj to imag
                        if img_size == 28
                            mul = 20;
                            thk = 5;
                        else
                            mul = 100;
                            thk = 3;
                        end
                        
                        for round_i = 1:length(traj{1})
                            img_raw = traj2img(traj{1}{round_i} * mul, thk);
                            if img_size == 28
                                img_ct = scale_img_28(img_raw);
                                if round_i == 7
                                    img_show = scale_img_64(img_raw);
                                end
                            else
                                img_ct = scale_img_64(img_raw);
                                if round_i == 7
                                    img_show = scale_img_64(img_raw);
                                end
                            end
                            img_ct = max(img_ct, 0);
                            img_final = normalize_sample_2d(img_ct);
                            
                            if round_i == 7
                                img_show = max(img_show,0);
                                img_show_f = normalize_sample_2d(img_show);
                            end

                            img_file = [img_dir, '/', num2str(round_i)];
                            save(img_file, 'img_final');
                        end
                        [label, score] = Demo_classification(net, img_dir, classNames);
                        score_v = score(:,classNames==label)
                        score_v = sort(score_v, 'descend')
                        confidence = mean(score_v);

                        % show classify result (traj, category, confidence)
                        figure('Position',[1000 500 500 500])
                        x = traj{1,1}{1,round(traj_idx/3)}(:,1);
                        y = traj{1,1}{1,round(traj_idx/3)}(:,2);
%                         x = traj{1,1}{1,60}(:,1);
%                         y = traj{1,1}{1,60}(:,2);
                        plot(x, y, 'r.','MarkerSize',10); drawnow;
                        title(sprintf('Category: %s \n Accuracy: %.2f', label, confidence));
                        xlim([0 50]);ylim([0 50]);
                        
                        figure('Position',[1000 500 64 64])
                        imshow(img_show_f);
                        
                        % clear CSI_st_all
                        clear CSI_st_all;
                        csi_cnt = 0;
                    end
                end
                
                total = total + 1
                
                if mod(total, n_sample_file) == 0 
                    cleanMeUp();
                    break;
                end
            end
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%            adjust the sockets 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sock_cnt_in     = sock_cnt_out;
    sock_vec_in     = sock_vec_out;
    sock_max        = max(sock_vec_in);
    sock_min        = min(sock_vec_in);    
    
    toc
end

    
function cleanMeUp()
    for i = 1:1:length(sock_vec_out)
        fprintf('close all active socket and exit!!\n');
        msclose(sock_vec_out(i,1));
    end
    close all;
    clear all;
end

end

