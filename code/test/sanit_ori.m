function [csi_11, csi_33, edge] = sanit_ori(CSI_st_all)

n_k = 56;
mac_left = 14562;

csi_11 = [];
csi_33 = [];

edge = [];
pkt_idx = 0;

for j = 1:length(CSI_st_all)
    entry = CSI_st_all(j);
    csi = entry.csi;

    if entry.MAC_idx == mac_left

        pkt_idx = pkt_idx + 1;

        csi_11 = [csi_11 mean(csi(1,1,:)./csi(1,2,:))];
        csi_33 = [csi_33 mean(csi(3,3,:)./csi(3,2,:))];

        temp_len = entry.payload_len;
        if temp_len ~= 120 % ?
            if length(edge) > 1
                if pkt_idx - edge(end) > 1
                    edge = [edge pkt_idx];
                end
            else
                 edge = [edge pkt_idx];
            end
        end
    end             
end

length(edge)
csi_11 = movmean(csi_11, 10);
csi_33 = movmean(csi_33, 10);
% %
% subplot(2,1,1)
% plot(normalize_sample(angle(csi_11)), 'r-')
% hold on;
% plot(edge, ones(length(edge),1), 'ko')
% legend('L11 amp', 'L11 phase')
% 
% subplot(2,1,2)
% plot(normalize_sample(abs(csi_33)), 'r-')
% hold on
% plot(normalize_sample(angle(csi_33)), 'b-')
% hold on
% plot(edge)
% legend('L33 amp', 'L33 phase')

%%
% samp_folder = [dir_name, '/sample'];
% if ~exist(samp_folder, 'dir')
%        mkdir(samp_folder);
% end

% samp_file = [samp_folder, '/sample_', word];
% save(samp_file, 'csi_11', 'csi_33', 'edge', 'ts');

% csvwrite(fullfile(dir_name, ['dudu_', num2str(tr_num)]), ft_f_norm(:,1));
% csvwrite(fullfile(dir_name, ['durl_', num2str(tr_num)]), ft_f_norm(:,2));
% csvwrite(fullfile(dir_name, ['edge_', num2str(tr_num)]), edge);
% csvwrite(fullfile(dir_name, ['A_edge_gauss_', num2str(tr_num)]), edge_gauss);
