
clear;
close all

tr_idx = 16;

load(['../csi_log/yanbo/test/test_',num2str(tr_idx),'.mat']);
n_pkt = length(CSI_st_all);

csi_11 = zeros(1,1);
csi_33 = zeros(1,1);
edge   = zeros(1,1);
csi_cnt  = 0;
edge_cnt = 0;
err_cnt = 0;
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
    
    % csi sanitization
    csi_cnt = csi_cnt + 1;
    csi_11(csi_cnt) = mean(csi(1,1,:)./csi(1,2,:));
    csi_33(csi_cnt) = mean(csi(3,3,:)./csi(3,2,:));

%     % plot phase
%     x = real(csi_11);y = imag(csi_11);
%     plot(x,y,'k.');
% %     xlim([-512 512]);ylim([-512 512]); 
%     hold on
%     
%     waitforbuttonpress();
    disp(pkt_idx)
end

save(['../csi_log/yanbo/test/test_',num2str(tr_idx),'.mat'],'csi_11','csi_33','edge');