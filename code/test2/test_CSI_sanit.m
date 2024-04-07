clear;
close all

load('../csi_log/yanbo/test/A_11.mat');

num_CSI = length(CSI_st_all);

CSI_sanit_vec = zeros(1,2);
for i = 1:1:num_CSI
    
    CSI = CSI_st_all(i).csi;
    
    csi_11 = mean(CSI(1,1,:)./CSI(1,2,:));
    csi_33 = mean(CSI(3,3,:)./CSI(3,2,:));
    
    CSI_sanit_vec(i,1) = csi_11;
    CSI_sanit_vec(i,2) = csi_33;
end

CSI_sanit_pha = unwrap(angle(CSI_sanit_vec(:,2)));

figure(1)
plot(CSI_sanit_pha);hold on
ylabel('phase')

% figure(2)
% for i = 21:length(CSI_sanit_pha)
%     i
%     
%     scatter(real(CSI_sanit_vec(i)),imag(CSI_sanit_vec(i)),'filled','b');    
%     xlim([-0.1 0.1]);ylim([-0.1 0.1])
%     hold on
%     
%     waitforbuttonpress();
% end

